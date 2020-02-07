#!/bin/bash
VOLUMES=$(df -PTkl | awk '{print $7}' | grep -v Mounted | awk -F % '{print $1}')
MAX_TAM=1048576
SERVER=$(uname -a | awk '{print $2}')

for i in $VOLUMES
do
    CHECK_PERCENT=$(df -PTkl $i | awk '{print $6}' | grep -v Capacity | awk -F % '{print $1}')
    case $CHECK_PERCENT in
        9[5-9])
            CHECK_SAPCE=$(df -PTkl $i | awk '{print $5'} | grep -v Available | awk -F % '{print $1}')
            if [ "$CHECK_SAPCE" -lt "$MAX_TAM" ]
            then
                echo "Volume $i com $CHECK_PERCENT% de uso (menos de 1GB livre)." | mutt -s "$SERVER - ALERTA DE DISCO" -- <account@email.com>
            fi
            ;;
        100)
            echo "Servidor $SERVER - Volume $i com $CHECK_PERCENT% de uso." | mutt -s "CRHDB01 - ALERTA DE DISCO" -- <account@email.com>
            ;;
    esac
done
