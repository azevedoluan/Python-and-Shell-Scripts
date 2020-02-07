import mail_func
from datetime import datetime

#Getting date/hour
data_atual = datetime.now()
data_hora = data_atual.strftime('%d/%m/%Y %H:%M')

#Call function read_email
print("Connecting in mailbox at (" + data_hora + ")")

print("Call function")
res = mail_func.read_email()
print(res)
print("Finished")
exit()
