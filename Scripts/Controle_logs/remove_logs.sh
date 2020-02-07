#!/bin/bash
##############################################################################
# Rotina que remove os spools gerados deixando os ultimos 30 dias            #
#                                                                            #
#                                                                            #
# by Luan Azevedo - Sep 2017                                                 #
#                                                                            #
##############################################################################



cd /var/log/interface/

#load functions file

source /u01/Rotinas/Scripts/functions

for D in $(/bin/ls -d */); do
     cd $D
     mv *.zip logs.zip.old
     create_dir $DATE
     move $DATE
     zip_dir $DATE
     sleep 45
     remove $DATE
     rm -fr *.old
     cd ..
done

cd /root/cron/check_email/spools/
mv *.zip logs.zip.old
create_dir $DATE
move $DATE
zip_dir $DATE
sleep 45
remove $DATE
rm -fr *.old

