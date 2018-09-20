!#/bin/bash
set -x
set -e

ls -ltr /docker-images/docker/registry/v2/blobs/sha256|awk '{print $9}'|sed '/^$/d' > /tmp/dir.txt
while read line
do

echo "line is: $line"
cd /docker-images/docker/registry/v2/blobs/sha256
cd $line

rm -rf $(ls -ltr|grep -w 'Jan'|awk '{print $9}')
rm -rf $(ls -ltr|grep -w 'Feb'|awk '{print $9}')
rm -rf $(ls -ltr|grep -w 'Mar'|awk '{print $9}')
rm -rf $(ls -ltr|grep -w 'Apr'|awk '{print $9}')
rm -rf $(ls -ltr|grep -w '2017'|awk '{print $9}')
rm -rf $(ls -ltr|grep -w '2016'|awk '{print $9}')

done < /tmp/dir.txt
docker restart $(docker ps -a -q)
