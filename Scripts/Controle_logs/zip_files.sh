#!/bin/bash

DATE=$(date +"%y%m%d")
DAY=$(date -d "$DATE - 1 day" "+%d")
MON=$(date "+%m")
YEAR=$(date "+%Y")
cd /root/cron/check_email/logs/

zip check_email_logs_$DAY$MON$YEAR.zip *.log
mv *.zip old_logs/
rm -fr *.log
