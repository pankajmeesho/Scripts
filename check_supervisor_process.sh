#!/bin/bash
# created by : DevOps Team
# created on : 09 Oct 2018
# script name: worker_processes_status.sh
# location    : /usr/local/bin/scripts/
# info       : this script is used to check whether all worker processes are running or not



total_processes=$(sudo supervisorctl status|wc -l)
running_processes=$(sudo supervisorctl status|grep 'RUNNING'|wc -l)

if [ $total_processes -eq $running_processes ]; then
echo "OK: All the Prcoesses are running"
exit 0
else
sudo supervisorctl status|awk '{print $1}' > /tmp/process_list
	while read line
	do

		count=$(sudo supervisorctl status|grep "$line"|grep -i 'RUNNING'|wc -l)
		if [ $count -eq 0 ]; then
			echo "$line is not running"
		fi
	done < /tmp/process_list
exit 2
fi
