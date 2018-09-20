#!/usr/bin/env bash
days=`uptime | awk -F" " {'print $3'}`
up=`/usr/bin/awk '{printf("%02d:%02d",($1/60/60%24),($1/60%60))}' /proc/uptime|awk  -F":" {'print $1'}`
uptime=`uptime | awk -F"," {'print $1 $2'} | awk -F" " {'print $3" " $4", " $5" Hrs"'}`
if [ $days -lt 1 ] && [ $up -le 1 ]
then
echo "CRITICAL: Uptime is less than 1 hr. Current uptime - $uptime"
exit 2
else
echo "OK: Current uptime - $uptime" 
exit 0
fi
