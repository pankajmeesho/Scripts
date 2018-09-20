#!/bin/bash
# created by Pankaj Pandey
# created at 29-05-2018
# this check was creetaed to get status of used file descriptor in by rabbitmq node

total_sockets_limit=$(rabbitmqctl status|grep -A 4 'file_descriptors'|grep 'sockets_limit'|awk -F',' '{print $2}'|sed 's/}//g')
total_sockets_used=$(rabbitmqctl status|grep -A 4 'file_descriptors'|grep 'sockets_used'|awk -F',' '{print $2}'|sed 's/}//g'|sed 's/]//g')

#echo $total_sockets_limit
#echo $total_sockets_used

threshold_sockets_limit=$(expr $total_sockets_limit / 10)
#echo $threshold_sockets_limit
if [ $total_sockets_used -eq 0 ]; then
echo "Critical: None of the socket connection getting used:$total_sockets_used"
exit 2
elif [ $total_sockets_used -gt $threshold_sockets_limit ];then
echo "Critical: Too many socket connections:$total_sockets_used"
exit 2
else
echo "OK: Socket Connection count is: $total_sockets_used Ok"
exit 0
fi
