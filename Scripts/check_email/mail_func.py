import mail_param
import imaplib
import email
import subprocess
import errno
import socket

#Read mailbox
def read_email():
    mail = imaplib.IMAP4_SSL(mail_param.SRV, mail_param.PORT)
    mail.login(mail_param.MAIL, mail_param.PWD)
    #Select mailbox
    mail.select('inbox')

    #Search all emails in mailbox
    type, data = mail.search(None, 'ALL')
    #Checking if there are emails
    if data[0] == '':
        subprocess.call(["/<path>/check_email/log.sh", "\"No email\""])
        mail.close()
        mail.logout()
        res = "No email"
        return res
    else:
        mail_ids = data[0]
    #List of email ids
    id_list = mail_ids.split()
    first_id = int(id_list[0])
    last_id = int(id_list[-1])

    #Fetch the emails on id list
    for i in range(last_id,first_id-1, -1):
        typ, data = mail.fetch(i, '(RFC822)')

        #Select data of fetched email
        for response_part in data:
            if isinstance(response_part, tuple):
                msg = email.message_from_string(response_part[1])
                mail_from = msg['from']
                mail_sub = msg['subject']
                #Getting only "FROM" without the full name
                aux = str(mail_from)
                a = aux.split('<')
                if a >= 0:
                    aux1 = aux.split('<')
                    aux2 = aux1[1].split('>')
                    aux3 = aux2[0]
                    arg1 = str(mail_sub)
                    arg2 = aux3
                else:
                    arg1 = str(mail_sub)
                    arg2 = str(mail_from)
                try:
                    exit_code = subprocess.call(["/<path>/check_email/call_procedure.sh", arg1, arg2])
                    #Checking if the shell script executed successful and deleted processed email
                    if exit_code == 0:
                        mail.store(i, '+FLAGS', '(\\Deleted)')
                        mail.expunge()
                    else:
                        subprocess.call(["/<path>/check_email/log.sh", "\"Script failed\""])
                        res = "Script failed"
                        return res
                #Time out exception
                except mail.abort:
                    mail = imaplib.IMAP4_SSL(mail_param.SRV, mail_param.PORT)
                    mail.login(mail_param.MAIL, mail_param.PWD)
                    mail.select('inbox')
                    type, data = mail.search(None, 'SEEN')
                    mail_ids = data[0]
                    id_list = mail_ids.split()
                    first_id = int(id_list[0])
                    last_id = int(id_list[-1])
                    if first_id == last_id:
                        typ, data = mail.fetch(first_id, '(RFC822)')
                        for response_part in data:
                            if isinstance(response_part, tuple):
                                mail.store(first_id, '+FLAGS', '(\\Deleted)')
                                mail.expunge()
                                subprocess.call(["/<path>/check_email/log.sh", "\"Finished after time out\""])
                    else:
                        for i in range(last_id,first_id-1, -1):
                            typ, data = mail.fetch(i, '(RFC822)')
                            for response_part in data:
                                if isinstance(response_part, tuple):
                                    mail.store(i, '+FLAGS', '(\\Deleted)')
                                    mail.expunge()
                                    subprocess.call(["/<path>/check_email/log.sh", "\"Finished with socket error\""])            
                    mail.close()
                    mail.logout()
                    res = "Finished with socket error"
                    return res
    #Close the mailbox
    mail.close()
    #Logout the mailbox
    mail.logout()
    subprocess.call(["/<path>/check_email/log.sh", "\"Script executed successful\""])
    res = "Success"
    return res
