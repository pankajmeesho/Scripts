#! /bin/bash
# create to check status memory usage in rmq node
# created by : pankaj pandey
# created date 8th July 2018
# usage: run directly "/bin/bash check-memory.sh"
host=$(hostname -I|awk '{print $1}')
port=15672

curl -i -u devops:M3800 -X GET http://$host:$port/api/nodes > /tmp/node 2> /tmp/test

sed '1,8d' /tmp/node > /tmp/json

used_mem=$(cat /tmp/json |jq '.[].mem_used'|head -1)
mem_limit=$(cat /tmp/json |jq '.[].mem_limit')

defined_mem_threshold=3028004864
if [ $defined_mem_threshold -lt $used_mem ]; then
echo "RMQ Memory Water Mark Status:Critical"
exit 2
else
echo "RMQ Memory Water Mark Status: OK"
exit 0
fi
