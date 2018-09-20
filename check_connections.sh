#!/bin/bash
# Description: this script is used to check number of close_wait connection
# Created by: Pankaj Pandey


count=`netstat -punta|grep -i 'CLOSE_WAIT'|wc -l`
if [ $count -gt 30 ]; then
echo "Warning"
exit 1
elif [ $count -gt 45 ]; then
echo "Critical"
exit 2
else
echo "OK"
exit 0
fi




