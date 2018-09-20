#!/bin/bash
grace=2629743
count=0
aws acm list-certificates|jq '.CertificateSummaryList[].CertificateArn'|sed 's/"//g' > /tmp/certificate_arn

while read line
do
status=$(aws acm describe-certificate --certificate-arn $line|jq '.[].Status'|sed 's/"//g')

if [ $status == "ISSUED" ]; then
	#echo "Status:$status"
	#echo "ok"
        dns=$(aws acm describe-certificate --certificate-arn $line|jq '.[].DomainName'|sed 's/"//g')
	ssldate=$(aws acm describe-certificate --certificate-arn $line|jq '.Certificate.NotAfter')
        server_name=$(aws acm describe-certificate --certificate-arn $line|jq '.Certificate.NotAfter')
	nowdate=`date '+%s'`
	diff="$((${ssldate}-${nowdate}))"


	if [ "$diff" -gt "$grace" ];then
		echo "OK:Certificate for $dns"
	else
		count="$(($count + 1))"
		echo "Critical:Certificate for $dns"
	fi

fi

#echo $count

done < /tmp/certificate_arn

if [ "$count" -gt 0 ];then
echo "Critical: Some certificates are going to expire in next 30 days"
exit 2
else
echo "OK: None of the certificate is going to expire in next 30 days"
exit 0
fi
