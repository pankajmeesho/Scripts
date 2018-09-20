#!/bin/bash
# created by Pankaj Pandey
# created at 29-05-2018
# this check was creetaed to get status of used file descriptor in by rabbitmq node

total_fd_limit=$(rabbitmqctl status|grep -A 2 'file_descriptors'|grep 'total_limit'|awk -F',' '{print $2}'|sed 's/}//g')
total_fd_used=$(rabbitmqctl status|grep -A 2 'file_descriptors'|grep 'total_used'|awk -F',' '{print $2}'|sed 's/}//g')
#echo $total_fd_limit
#echo $total_fd_used

threshold_fd_limit=$(expr $total_fd_limit / 10)
#echo $mid_fd_value
if [ $total_fd_used -gt $threshold_fd_limit ]; then
echo "Critical: Too Many Oepn File Descriptor:$total_fd_used"
exit 2
else
echo "OK: Oepn File Descriptor count is: $total_fd_used Ok"
fi
