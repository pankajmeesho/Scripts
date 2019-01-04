#!/bin/bash

set -u

FLAG=0
DBID="catalog"
REGION=ap-southeast-1

/opt/sensu/embedded/bin/check-rds.rb -i $DBID  --cpu-critical-over 80 --cpu-warning-over 75 -r $REGION -n
FLAG=$?
/opt/sensu/embedded/bin/check-rds.rb -i $DBID  --connections-critical-over 120 --connections-warning-over 100 -r $REGION -n
FLAG=$?
/opt/sensu/embedded/bin/check-rds.rb -i $DBID  --iops-critical-over 1050 --iops-warning-over 950 -r $REGION -n
FLAG=$?
/opt/sensu/embedded/bin/check-rds.rb -i $DBID  --memory-warning-over 70 --memory-critical-over 80 -r $REGION -n
FLAG=$?
/opt/sensu/embedded/bin/check-rds.rb -i $DBID  --disk-warning-over 70 --disk-critical-over 80 -r $REGION -n
FLAG=$?

exit  $((FLAG))
