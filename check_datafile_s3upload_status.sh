#!/bin/bash


current_date=$(date +"%Y-%m-%d")
current_time=$(date +"%T")
current_date_time="$current_date $current_time"
delay=40
count=0
bucket_name='dw-etl'
dict_list=('new_catalog_views' 'new_catalog_shared' 'new_catalog_opened' 'new_catalog_clicked' 'new_notification_sent_etl' 'new_product_clicked')


for i in "${dict_list[@]}"; do
        last_current_date_time=$(s3cmd ls s3://$bucket_name/$i/|sort|tail -n 1|awk '{print $1 " "$2 ":00"}')
        diff=$(date -ud@$(($(date -ud "$current_date_time" +%s)-$(date -ud "$last_current_date_time" +%s))) +%T)
#        echo "diff is:$diff"
        update_diff=$( echo $diff|awk -F: '{ print ($1 * 3600) + $2 }')
#        echo "min:$update_diff"
        if [ $update_diff -ge $delay ];then
		echo "date in Directory: $i last uploaded at: $last_current_date_time"
                count="$(($count + 1))"

        fi
done

if [ "$count" -gt 0 ];then
echo "Critical: Data has not been pushed to S3 from last 40 mins"
exit 2
else
echo "OK: Data has been pushed to S3"
exit 0
fi
