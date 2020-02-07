#!/bin/bash
###########################################################################
##                                                                       ##
##                                                                       ##
## Script for routine CARGA_ARIBA                                        ##
##                                                                       ##
## By Luan Azevedo - Apr 2018                                            ##
##                                                                       ##
###########################################################################

#Import parameters file
source /root/cron/parameters_ariba

SCRIPT="CARGA"
LOG_FILE="/var/log/interface/CARGA_ARIBA.log"
SPOOL="/var/log/interface/CARGA_ARIBA"
SQLFILE="/var/tmp/carga_ariba.sql"
SQLPLUS="sqlplus /nolog @$SQLFILE"
DIR1="/shared/ariba"

#Procedures Oracle
ORA_PROC1="ARIBA_ACCOUNT"
ORA_PROC2="ARIBA_COMPANYSITE"
ORA_PROC3="ARIBA_CONTRACT"
ORA_PROC4="ARIBA_COSTCENTER"
ORA_PROC5="ARIBA_COSTCENTERMGMT"
ORA_PROC6="ARIBA_ERPCOMMODITY"
ORA_PROC7="ARIBA_FLEXDIMENSION1"
ORA_PROC8="ARIBA_INVOICE3"
ORA_PROC9="ARIBA_PART"
ORA_PROC10="ARIBA_PO3"
ORA_PROC11="ARIBA_SUPPLIER"
ORA_PROC12="ARIBA_USER"

#Import functions files
source /root/cron/functions_ariba

#Generate SQLFILE file
cat > $SQLFILE << EOF
connect $SQLUSER/$SQLPASS@$SQLSERV
spool $SPOOL/spool_$SCRIPT_$DATE.log
set echo on
set time on
select sysdate from dual;
EXEC $ORA_PROC1
EXEC $ORA_PROC2
EXEC $ORA_PROC3
EXEC $ORA_PROC4
EXEC $ORA_PROC5
EXEC $ORA_PROC6
EXEC $ORA_PROC7
EXEC $ORA_PROC8
EXEC $ORA_PROC9
EXEC $ORA_PROC10
EXEC $ORA_PROC11
EXEC $ORA_PROC12
spool off;
EXIT;
EOF

#remove old files
cd $DIR1
rm *.*

execute $SQLPLUS
rm $SQLFILE

cd $DIR1
count_files
zip_file

execute $sshpass -p $PASSSFTP sftp $USERSFTP@$SERVERSFTP << EOF
put -p /shared/ariba/LatAmericaCRHBrazil_$MONTH$YEAR.zip
bye
EOF

log "Finished OK"
exit 0
