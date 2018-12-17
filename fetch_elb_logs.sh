get_bucket_info()
{
echo "enter name of the bucket"
read bucket
echo "enter the year"
read year
echo "enter month"
read month
echo "enter day of month"
read day
}

remove_old_log()
{
echo "removing old logs"
rm -rf /Users/apple/Documents/elb/log/*
}
fetch_data()
{

	echo "fetching data from sbucket"
	s4cmd get -r s3://$bucket/access-log/AWSLogs/847438129436/elasticloadbalancing/ap-southeast-1/$year/$month/$day/* /Users/apple/Documents/elb/log/
}

unzipped_data()
{
	echo "unzipping data"
        gunzip /Users/apple/Documents/elb/log/*.gz
        echo "removing zipped data"
        rm -rf /Users/apple/Documents/elb/log/*.gz
}

number_of_request()
{
echo "count all requests and sort them in descending order so that most requested URLs will be listed"
elb-log-analyzer /Users/apple/Documents/elb/log/ --limit=30
}
most_client_request()
{
 echo "client IPs that make requests the most" 
 elb-log-analyzer /Users/apple/Documents/elb/log/ --col2=client ---col3=elb_status_code --sortBy=3 --limit=30
}

status_code()
{
 elb-log-analyzer /Users/apple/Documents/elb/log/ --col1=count --col2=requested_resource --col3=elb_status_code --sortBy=3 --limit=30
 echo "================================"
}

get_bucket_info
remove_old_log
fetch_data
unzipped_data
number_of_request
most_client_request
status_code
