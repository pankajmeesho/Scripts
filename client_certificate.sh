#!/bin/bash


cd /root/openvpn-ca

source /root/openvpn-ca/vars


./build-key $1

cd /root/client-configs

./make_config.sh $1


cat /root/steps.txt| mutt -s "VPN clinet configuration guide" $1@gmail.com -a /root/client-configs/files/$1.ovpn
