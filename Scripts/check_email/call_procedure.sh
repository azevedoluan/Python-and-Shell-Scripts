#!/bin/bash

#Import parameters
source /root/cron/check_email/parameters

SCRIPT="call_procedure"
LOG_FILE="/root/cron/check_email/logs/call_check_email.log"
SPOOL="/root/cron/check_email/spools"
SQLFILE="/root/cron/check_email/tmp/call_procedure.sql"
SQLPLUS="sqlplus /nolog @$SQLFILE"
ARG1=\'$1\'
ARG2=\'$2\'

#Import functions
source /root/cron/check_email/functions

#Procedures Oracle
ORA_PROC1="CONSULTA_VENDAS_EMAIL"

#Generate SQLFILE file
cat > $SQLFILE << EOF
connect $SQLUSER/$SQLPASS@$SQLSERV
spool $SPOOL/spool_call_procedure_$DATE.log
set echo on
set time on
select sysdate from dual;
EXEC $ORA_PROC1.PCI($ARG1,$ARG2)
spool off;
EXIT;
EOF

execute $SQLPLUS
rm $SQLFILE

exit 0
