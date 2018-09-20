#!/bin/bash

/usr/sbin/logrotate -f /usr/local/bin/scripts/logrotate-treebo.conf > /tmp/log 2>&1

if [[ $? -ne 0 ]] ;then
echo $(date +%d-%m-%Y-%H )" :Error Rotating logs files" >> /tmp/logrotatestatus
else
echo $(date +%d-%m-%Y-%H )" :Success Rotating logs files" >> /tmp/logrotatestatus
fi