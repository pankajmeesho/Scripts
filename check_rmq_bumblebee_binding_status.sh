#!/bin/bash
# create to check status of Shovel
# created by : pankaj pandey
# creation date 24th July 2018

#set -x
#set -e

host=$(hostname -I|awk '{print $1}')
port=15672
vhost="bumblebee"
count=0
curl -i -u devops:M3800 -X GET http://$host:$port/api/queues/$vhost > /tmp/all_queues_bb 2> /tmp/queues_test_bb

sed '1,8d' /tmp/all_queues_bb > /tmp/all_queues_json_bb

cat /tmp/all_queues_json_bb|jq '.[].name'|sed 's/"//g'|grep -v 'celeryev.'|grep -v 'celery@'|grep -v 'bcast.' > /tmp/valid_queues_bb

while read line
do
curl -i -u devops:M3800 -X GET http://$host:$port/api/queues/$vhost/$line/bindings > /tmp/bindings_bb 2> /tmp/bb_binding_test_bb

sed '1,8d' /tmp/bindings_bb > /tmp/json_bindings_bb

bind_count=$(cat /tmp/json_bindings_bb |jq '.[].routing_key'|wc -l)
if [ $bind_count -lt 2 ];then
echo "Critical: Binding missing for $line queue in $vhost vhost"
(( count++ ))
fi

done < /tmp/valid_queues_bb

if [ $count -gt 0 ];then
exit 2
else
echo "OK: All Queues have bindings"
exit 0
fi
