#!/bin/bash
set -x
echo $host

# check number of healthy host count

healthy_host_count=$(aws elbv2 describe-target-health --target-group-arn $target_group_arn|jq ".TargetHealthDescriptions[].TargetHealth[]"|wc -l)

if [ $healthy_host_count -ge 1 ]; then
	echo "total healthy host count is: $healthy_host_count"
	echo "fetching instance id of the host"
	instance_id=$(aws ec2 describe-addresses --public-ips $host|jq ".Addresses[].InstanceId"|sed 's/"//g')
	private_ip=$(aws ec2 describe-addresses --public-ips $host|jq ".Addresses[].PrivateIpAddress"|sed 's/"//g')
	echo "instance id: $instance_id"
	echo "private_ip:$private_ip"

	echo "removing instance $instance_id from target group"
	aws elbv2 deregister-targets --target-group-arn $target_group_arn --targets Id=$instance_id
	echo "$instance_id is draining, so pause it for 2 mins"
	sleep 2m

	echo "copying deployment script to remote machine"

	scp /home/jenkins/supply-deployment-scripts/supply_api_deployment.sh ubuntu@$host:/home/ubuntu

	echo "login to $instance_id"
	ssh -i /home/jenkins/.ssh/id_rsa ubuntu@$host "
	cd /home/ubuntu
	./supply_api_deployment.sh $private_ip
	"
	exit_status=$(echo $?)

	echo $exit_status
	
    if [ $exit_status -eq 0 ];then
		echo "Adding instance $instance_id back to the target group and will wait for 1 mins to become instance healthy"
		aws elbv2 register-targets --target-group-arn $target_group_arn --targets Id=$instance_id,Port=80
		sleep 1m
		echo "checking status of newly added instance in target group"
		instance_status=$(aws elbv2 describe-target-health --targets Id=$instance_id,Port=80 --target-group-arn $target_group_arn|jq ".TargetHealthDescriptions[].TargetHealth[]"|sed 's/"//g')
        if [ $instance_status == "healthy" ]; then
        	echo "Instance $instance_id is : $instance_status"
            echo "Deployment completed successfully"
            exit 0
         
    	else
        	echo "instance is not healthy! we will check after 1 min again"
            sleep 1m
            instance_status=$(aws elbv2 describe-target-health --targets Id=$instance_id,Port=80 --target-group-arn $target_group_arn|jq ".TargetHealthDescriptions[].TargetHealth[]"|sed 's/"//g')
        	if [ $instance_status == "healthy" ]; then
            	echo "Instance $instance_id is : $instance_status"
            	echo "Deployment completed successfully"
            	exit 0
            else
            	echo "removing instance from elb as it's status is not healthy after deployment"
                aws elbv2 deregister-targets --target-group-arn $target_group_arn --targets Id=$instance_id
                exit 0
            fi
            exit 2
    	fi

	else
    	echo "deployment script failed !! please check console output to debug it more"
    fi


else
	echo "minimum 3 healthy host count is needed in target group"
	exit 2
fi


