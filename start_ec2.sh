#!/bin/bash
# before running the script you need to install "jq" in you machine where you running this script
# you need to install awcli and configure it link: https://docs.aws.amazon.com/cli/latest/userguide/installing.html
# you shoud have permission to stop, start and read the ec2 instances
# change permission of this script command "chmod 755 stop_ec2.sh"


echo "enter tag key name"
read tag_key
echo "enter tag key value"
read tag_value
echo "enter region code"
read region_code
aws ec2 describe-instances --region $region_code --filters "Name=instance-state-name,Values=stopped" "Name=tag:$tag_key,Values=$tag_value" |jq '.Reservations[].Instances[].InstanceId'|sed 's/"//g' > /tmp/instance.txt
while read line
do
echo "stopping the instance: $line"
aws ec2 start-instances --instance-ids $line
done < /tmp/instance.txt
