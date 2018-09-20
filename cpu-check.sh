#!/bin/bash

#set -x

n=4
TOTL_CPU_USAGE=0
for (( i=1 ; i<=$n ; i++ ))
do
        CPU_USAGE=$(top -b -n2 -p 1 | fgrep "Cpu(s)" | tail -1 | awk -F'id,' -v prefix="$prefix" '{ split($1, vs, ","); v=vs[length(vs)]; sub("%", "", v); printf "%s%.1f%%\n", prefix, 100 - v }'|sed 's/%//')
        CPU_USAGE=${CPU_USAGE%.*}

        let "TOTL_CPU_USAGE+=$CPU_USAGE"
        sleep 5

done

AVG_CPU_USAGE=$((TOTL_CPU_USAGE/n))

#echo "$AVG_CPU_USAGE"

#THRESHOLD="85"
if [[ $AVG_CPU_USAGE -lt 85 ]]; then

echo "OK: CPU Utilization is $AVG_CPU_USAGE%"
exit 0

else
echo "Critical: CPU Utilization is $AVG_CPU_USAGE%"
exit 2

fi
