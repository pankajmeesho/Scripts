#!/bin/bash

aws rds describe-db-instances|jq '.DBInstances[].DBInstanceIdentifier'|sed 's/"//g' > /tmp/rds
while read line
do
type=$(aws rds describe-db-instances --db-instance-identifier $line|jq '.DBInstances[].PubliclyAccessible')
echo "$line  type: $type"
done < /tmp/rds
