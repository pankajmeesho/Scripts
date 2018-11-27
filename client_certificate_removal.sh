#! /bin/bash
# this script has been created to remove vpn client
# created by Pankaj Pandey 08-10-2018

# function for help

set -e
#set -x

help_function () {
echo "Below are the steps to use this script:"
echo "let say we want to remove client1"
echo "Command need to type:"
echo "./client_certificate_removal.sh client1"
}

# fucntion for removing client VPN

remove_client(){
cd /root/openvpn-ca
source vars
./revoke-full $1
cp /root/openvpn-ca/keys/crl.pem /etc/openvpn
service openvpn@server stop
service openvpn@server start
}

if [ $1 == "-h" ];then
help_function
else
echo "Removing client certificate for: $1"
echo "#########################################################################################"
remove_client
fi
