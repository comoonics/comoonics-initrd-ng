#!/bin/bash

__prefix="/tmp"

source $(dirname $0)/etc/boot-lib.sh

#debug="true"
stepmode="true"

ip1="192.168.168.100::192.168.168.1:255.255.255.0:server1:eth0"
ip2="dhcp"

echo "Testing for ip $ip1 ..."
ip2Config $ip1

cat ${__prefix}/etc/sysconfig/network
cat ${__prefix}/etc/sysconfig/network-scripts/ifcfg-eth0

step

echo "Testing for ip $ip2 ..."
ip2Config $ip2

cat ${__prefix}/etc/sysconfig/network
cat ${__prefix}/etc/sysconfig/network-scripts/ifcfg-eth0

step