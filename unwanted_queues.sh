#!/bin/bash
rm -rf queue.txt
IFS=$'\n'
ordered_vhosts=$(rabbitmqctl list_vhosts -q | xargs -n1 | sort -u)

for V in $ordered_vhosts; do
    echo "*****Vhost $V Total queues " $(rabbitmqctl list_queues -q -p $V | wc -l)
    for Q in $(rabbitmqctl list_queues -q name messages -p $V | xargs -n2 | sort -u); do
        echo "[vhost==> $V] [queue-name total-messages] [$Q]" >> queue.txt
    done
done


UNWANTED_QUEUES=$(cat queue.txt|grep 'celeryev\|bcast')

count=$(echo $UNWANTED_QUEUES|wc -w)

WEBHOOK_URL="https://hooks.slack.com/services/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";
SLACK_CHANNEL="#bugs";


ICON_EMOJI=":loudspeaker:"
SERVICESTATE="CRITICAL"
ICINGA_HOSTNAME="shared-p-rmq-cluster-ui-01.treebo.com(RMQ-Cluster-01)"
ICINGA_SERVICEDISPLAYNAME="Unwanted Queues List"

if [ $count -gt 2 ];then
	SERVICESTATE="CRITICAL"
	curl -X POST --data "payload={\"channel\": \"${SLACK_CHANNEL}\", \"icon_emoji\": \":vertical_traffic_light:\", \"text\": \"${ICON_EMOJI} host: $ICINGA_HOSTNAME\nservice: $ICINGA_SERVICEDISPLAYNAME\nstate: $SERVICESTATE\nmessage: $UNWANTED_QUEUES\"}" ${WEBHOOK_URL}

else
	SERVICESTATE="OK"
	curl -X POST --data "payload={\"channel\": \"${SLACK_CHANNEL}\", \"icon_emoji\": \":vertical_traffic_light:\", \"text\": \"${ICON_EMOJI} host: $ICINGA_HOSTNAME\nservice: $ICINGA_SERVICEDISPLAYNAME\nstate: $SERVICESTATE\nmessage: All queues are correct one\"}" ${WEBHOOK_URL}

fi
