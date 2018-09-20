#!/bin/bash
#Author - Pankaj Pandey
# Description - To push treebo-web yestedays logs to s3 after log rotation.
# log files are list of log filea that you want to upload
LogFiles=(/var/log/nginx/pricing.access.log
    /var/log/nginx/pricing.error.log
    /var/log/supervisor/supervisord.log
    /var/log/pricing/worker.log
    /var/log/pricing/pricing.log
    /var/log/pricing/default.log)

date="-`date +%Y%m%d --date '2 days ago'`.gz"

echo "--------------------$(date +%Y-%m-%d )------------------"
for file in "${LogFiles[@]}";do

        if [ -f $file$date ];then
                echo "$file$date exists"
                echo 'Starting S3 Log Upload...'
                BUCKET_NAME="treebo-pricing"
                # Fetch the instance id from the instance
                INSTANCE_ID="`wget -q -O - http://169.254.169.254/latest/meta-data/instance-id`"
                if [ -z $INSTANCE_ID ]; then
                        echo "Error: Couldn't fetch Instance ID .. Exiting .."
                        exit;
                else
                        # Upload log file to Amazon S3 bucket
                        ip="$(ip route get 1 | awk '{print $NF;exit}')"
                        /usr/bin/s3cmd -c /root/.s3cfg put "$file$date" s3://$BUCKET_NAME/pricing/logs/$INSTANCE_ID-$ip/
                        if [ $? -eq 0 ];then
                        # Removing Pushed Log File
                                echo "pushed $file$date to s3 Bucket path s3://$BUCKET_NAME/pricing/logs/$INSTANCE_ID-$ip/ "
                        else
                                echo "unable push to s3 kindly troubleshoot"
                        fi
                fi
        else
                echo "$file$date is not present"
        fi
done
