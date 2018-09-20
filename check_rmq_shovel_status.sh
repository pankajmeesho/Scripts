#!/bin/bash
# create to check status of Shovel
# created by : pankaj pandey
# creation date 24th July 2018


host=$(hostname -I|awk '{print $1}')
port=15672


curl -i -u devops:M3800 -X GET http://$host:$port/api/shovels > /tmp/shovel 2> /tmp/test1

sed '1,7d' /tmp/shovel > /tmp/shovel_json

cat /tmp/shovel_json|jq '.[].name'|sed 's/"//g' > /tmp/shovel_name

cat /tmp/shovel_json|jq '.[].state'|sed 's/"//g' > /tmp/shovel_status

paste /tmp/shovel_name /tmp/shovel_status > /tmp/shovel_name_status

grep -v 'terminated' /tmp/shovel_name_status > /tmp/shovel_name_status_without_terminated

while read line
do
name=$(echo "$line"|awk '{print $1}')
state=$(echo "$line"|awk '{print $2}')

run="running"
terminate="terminated"


if [ $state = $run ] || [ $state = $terminate ]; then

echo "OK: ALL shovels are running"
exit 0
else

echo "Critical: Shovel: $name  State: $state"
exit 2
fi

done < /tmp/shovel_name_status_without_terminated
