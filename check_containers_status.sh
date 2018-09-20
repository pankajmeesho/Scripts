#!/bin/bash
# this script will send alert if any of the docker containeris not running
# created by Pankaj
total=$(sudo docker ps -a|wc -l)
running=$(sudo docker ps|wc -l)
if [ $total = $running ];then
echo "OK: All containers are running"
exit 0
else
echo "Critical: All containers are not running"
exit 2
fi
