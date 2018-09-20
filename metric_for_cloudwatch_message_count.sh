#!/bin/bash

DATE_WITH_TIME=$(date "+%Y-%m-%dT%H:%M:%SZ")
echo $DATE_WITH_TIME

#expedia_count=$(/usr/local/bin/scripts/check_rabbitmq_queue -H "localhost" --port=15672 --queue="expedia_rate_queue" -w 800 -c 1000 --vhost=cm -u cmuser -p M3b00|awk -F'|' '{print $2}'|awk -F';' '{print $1}'|sed 's/^ *//g'|awk -F'=' '{print $2}')

work_queue_count=$(/usr/local/bin/scripts/check_rabbitmq_queue -H "localhost" --port=15672 --queue="work-queue" -w 12 -c 15 --vhost=b2b -u b2badmin -p M3800|awk -F'|' '{print $2}'|awk -F';' '{print $1}'|sed 's/^ *//g'|awk -F'=' '{print $2}')

task_queue_count=$(/usr/local/bin/scripts/check_rabbitmq_queue -H "localhost" --port=15672 --queue="task-queue" -w 50000 -c 60000 --vhost=b2b -u b2badmin -p M3800|awk -F'|' '{print $2}'|awk -F';' '{print $1}'|sed 's/^ *//g'|awk -F'=' '{print $2}')


#aws cloudwatch put-metric-data --metric-name expedia_rate_queue_message_count --namespace RabbitMQ --region ap-south-1 --value $expedia_count --timestamp $DATE_WITH_TIME

aws cloudwatch put-metric-data --metric-name work_queue_message_count --namespace RabbitMQ --region ap-south-1 --value $work_queue_count --timestamp $DATE_WITH_TIME

aws cloudwatch put-metric-data --metric-name task_queue_message_count --namespace RabbitMQ --region ap-south-1 --value $task_queue_count --timestamp $DATE_WITH_TIME

#aws cloudwatch put-metric-data --metric-name dead_letter_queue_message_count --namespace RabbitMQ --region ap-south-1 --value $dead_letter_queue_count --timestamp $DATE_WITH_TIME
