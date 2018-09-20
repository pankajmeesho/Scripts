#!/bin/bash
# created by Pankaj Pandey
#created at: 19th feb 2018
#purpose: monitor total number of message in ready state in rmq cluster

curl -u devops:M3800 http://shared-p-rmq-cluster-ui-01.treebo.com:15672/api/overview > /usr/local/bin/scripts/rmq_stats.txt
ready_message_count=$(cat /usr/local/bin/scripts/rmq_stats.txt|jq .queue_totals.messages_ready)
retry_message_count=$(cat /usr/local/bin/scripts/rmq_stats.txt|jq .message_stats.redeliver)
#echo "ready_message_count:$ready_message_count"

if [ $ready_message_count -gt 250000 ];then
echo "Critical: total number of messages $ready_message_count crossed the limit of 250000"
exit 2
elif [ $ready_message_count -eq $retry_message_count ];then
echo "Critical: Number of ready_message_count equal to retry_message_count"
exit 2
else
echo "Ok: total number of messages count $ready_message_count under 250000"
exit 0
fi
