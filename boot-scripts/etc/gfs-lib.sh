#
# $Id: gfs-lib.sh,v 1.2 2004-08-11 16:53:52 marc Exp $
#
# @(#)$File$
#
# Copyright (c) 2001 ATIX GmbH.
# Einsteinstrasse 10, 85716 Unterschleissheim, Germany
# All rights reserved.
#
# This software is the confidential and proprietary information of ATIX
# GmbH. ("Confidential Information").  You shall not
# disclose such Confidential Information and shall use it only in
# accordance with the terms of the license agreement you entered into
# with ATIX.
#
# Kernelparameter for changing the bootprocess for the comoonics generic hardware detection alpha1
#    gfs-poolsource=... The poolsource possibilities (scsi*, gnbd)
#    gfs-pool=...       The gfs-pool to boot from
#    gfs-poolcca=... The gfs-cidev-pool to be given (defaults to ${gfspool}_cca, applies to 5.2)
#    gfs-poolcidev=... The gfs-cidev-pool to be given (defaults to ${gfspool}_cidev, applies to 5.1.1)
#    gfs-lockmethod=... The gfs-locking method (lock_gulm*, lock_dmep, nolock)
#    gfs-gnbdserver=.. The server serving the gnbd based scsi discs over ip
#    gfs-mountopt=...  The mount options given to the mount command (i.e. noatime,nodiratime)
#    com-stepmode=...      If set it asks for <return> after every step
#    com-debug=...         If set debug info is output

function getGFSParameters() {

	echo_local "*********************************"
	echo_local "Scanning for GFS parameters"
	echo_local "*********************************"
	poolsource=`getBootParm poolsource scsi`
	pool_name=`getBootParm pool`
	pool_cca_name=`getBootParm poolcca`
	pool_cidev_name=`getBootParm poolcidev`
	gfs_lock_method=`getBootParm lockmethod`
	gnbd_server=`getBootParm gnbdserver`

}

#
# returns the gfs-majorversion
function getGFSMajorVersion() {
    modinfo gfs | awk '$1 == "description:" {
  match($5, /v([[:digit:]]+)\./, version);
  print version[1];
}'
}

#
# returns the gfs-minorversion
function getGFSMinorVersion() {
    modinfo gfs | awk '$1 == "description:" {
  match($5, /v[[:digit:]]+\.([[:digit:]]+)/, version);
  print version[1];
}'
}

# returns the first found cca
# could be optimized a little bit with a given cca.
gfs_autodetect_cca() {
    ccadevs=( $( pool_tool -s | awk '/CCA device /{print $1}' | xargs -r ) )
    [ -z "${ccadevs[0]}" ] && return 1
    
    echo ${ccadevs[0]}
    return 0
}


cca_get_clustername() {
    ccs_read string cluster.ccs cluster/name 2>/dev/null
}

cca_get_node_sharedroot() {
   local hostname=$1
   [ -z "$hostname" ] && hostname=$(hostname)
   ccs_read string nodes.ccs nodes/$hostname/com_sharedroot
}

cca_get_node_role() {
   local hostname=$1
   [ -z "$hostname" ] && hostname=$(hostname)
   ccs_read string nodes.ccs nodes/$hostname/com_role
}

cca_get_lockservers() {
   ccs_read string cluster.ccs cluster/lock_gulm
}

function cca_autoconfigure_network {
    local ipconfig=$1
    local netdev=$2
    mac=$(ifconfig $netdev | grep HWaddr | awk '{print $5;}')
    hostname=$(ccs_read file nodes.ccs | awk -v mac=$mac '
/com_hostname=".+"/ {
   match($1, /com_hostname="(.+)"/, hn); hostname=hn[1]; print "Found hostname ",hostname;
}
/com_hostname[[:space:]]+=".+"/{
   match($2, /="(.+)"/, hn); hostname=hn[1];
}
/com_hostname[[:space:]]+=[[:space:]]".+"/{
   match($3, /"(.+)"/, hn); hostname=hn[1];
}

/eth0_mac=\".+\"/ {
   match($1, /mac="(.+)"/, mc);
   if (tolower(mac) == tolower(mc[1])) {
     print hostname;
   }
}
/eth0_mac[[:space:]]+=\".+\"/{
   match($2, /="(.+)"/, mc);
   if (tolower(mac) == tolower(mc[1])) {
     print hostname;
   }
}
/eth0_mac[[:space:]]+=[[:space:]]+\".+\"/{
   match($3, /"(.+)"/, mc);
   if (tolower(mac) == tolower(mc[1])) {
     print hostname;
   }
}
')
    ipcfg=$(ccs_read section nodes.ccs nodes/$hostname | grep "eth0" | awk -v hostname=$hostname -F '=' '
function getValue(pre) {
  match(pre, /"(.+)"/, val);
  return val[1];
}
$1 ~ /eth0[[:space:]]/ {
  ip=getValue($2);
}
$1 ~ /eth0_netmask[[:space:]]/ {
  netmask=getValue($2);
}
$1 ~ /eth0_gateway[[:space:]]/ {
  gateway=getValue($2);
}
END {
  printf "%s::%s:%s:%s:eth0", ip, gateway, netmask, hostname;
}
'
)
    echo $ipcfg;
}

# $Log: gfs-lib.sh,v $
# Revision 1.2  2004-08-11 16:53:52  marc
# major enhancements concerning the cca-autoconfiguration
#
# Revision 1.1  2004/07/31 11:24:44  marc
# initial revision
#