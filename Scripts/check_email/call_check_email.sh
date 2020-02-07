#!/bin/bash

#Import parameters
source /root/cron/check_email/parameters

SCRIPT="call_check_email"
LOG_FILE="/root/cron/check_email/logs/call_check_email.log"
PYTHON="/usr/bin/python /root/cron/check_email/check_email.py"

#Import functions
source /root/cron/check_email/functions

#ALTERADO NO CHAMADO 732062
#Check lock file
AUX=$(ls /root/cron/check_email/tmp)
if [ "$AUX" = "call_check_email.lck" ]; then
    check_lck
fi
#FIM DA ALTERACAO

#execute lock
lock

execute $PYTHON
log "Finished OK"
terminate	
