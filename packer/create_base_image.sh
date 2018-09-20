#!/bin/bash

source ~/.bashrc

if [ "$(uname)" == "Darwin" ]; then
 UUID_SOUTH=$(python -c 'import sys,uuid; sys.stdout.write(uuid.uuid4().hex)')
else
 UUID_SOUTH=$(cat /proc/sys/kernel/random/uuid)
fi

echo "Generating 14.04 AMI for AP-SOUTH:"
packer build -var "aws_access_key=$AWS_ACCESS_KEY_ID"  -var "aws_secret_key=$AWS_SECRET_ACCESS_KEY"  \
-var-file regions/ap-south-1-14.04 -var "build_uuid=$UUID_SOUTH" -var "region=ap-south-1 ansible_os_family=Debian" treebo-base.json

echo "Generating 16.04 AMI for AP-SOUTH:"
packer build -var "aws_access_key=$AWS_ACCESS_KEY_ID"  -var "aws_secret_key=$AWS_SECRET_ACCESS_KEY"  \
-var-file regions/ap-south-1-16.04 -var "build_uuid=$UUID_SOUTH" -var "region=ap-south-1 ansible_os_family=Debian" treebo-base.json


if [ "$(uname)" == "Darwin" ]; then
 UUID_SOUTHEAST=$(python -c 'import sys,uuid; sys.stdout.write(uuid.uuid4().hex)')
else
 UUID_SOUTHEAST=$(cat /proc/sys/kernel/random/uuid)
fi

echo "Generating 14.04 AMI for AP-SOUTH-EAST:"
packer build  -var "aws_access_key=$AWS_ACCESS_KEY_ID"  -var "aws_secret_key=$AWS_SECRET_ACCESS_KEY"  \
-var-file regions/ap-southeast-1 -var "build_uuid=$UUID_SOUTHEAST"  -var "region=ap-southeast-1 ansible_os_family=Debian" treebo-base.json

echo "Generating 16.04 AMI for AP-SOUTH-EAST:"
packer build  -var "aws_access_key=$AWS_ACCESS_KEY_ID"  -var "aws_secret_key=$AWS_SECRET_ACCESS_KEY"  \
-var-file regions/ap-southeast-1 -var "build_uuid=$UUID_SOUTHEAST"  -var "region=ap-southeast-1 ansible_os_family=Debian" treebo-base.json
