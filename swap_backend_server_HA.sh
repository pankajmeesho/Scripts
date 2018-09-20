#!/bin/bash
# create by Pankaj Pandey
# created at 16th April 2018
# created to swap direct machine in HA

echo "enter hostname of the machine currently under HA"
read current_hostname
echo "enter private IP of the machine currently under HA"
read current_private_ip

current=$(echo "server $current_hostname $current_private_ip")

echo "enter hostname of the machine that you want to insert into HA"
read new_hostname

echo "enter private IP of the machine that you want to insert into HA"
read new_private_ip

new=$(echo "server $new_hostname $new_private_ip")

echo "swapping machine"
echo "current machine :$current"
echo "new machine :$new"


sed -i -e 's/'"${current}"'/'"${new}"'/g' /etc/haproxy/haproxy.cfg

echo "reloading haproxy service"

service haproxy reload
