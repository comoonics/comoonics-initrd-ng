#
# $Id: gfs-lib.sh,v 1.9 2005-01-03 08:30:43 marc Exp $
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
	chroot=`getBootParm chroot`
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

# syntax: cca_get_host_param name [default] [host]
cca_get_node_param() {
  local param=$1
  local default=$2
  local hostname=$3
  [ -z "$hostname" ] && hostname=$(hostname)
  value=$(ccs_read string nodes.ccs nodes/$hostname/$param 2>/dev/null)
  if [ -z "$value" ]; then value=$default; fi
  
  echo $value
}

cca_get_syslog_server() {
  cca_get_node_param com_syslog_server "$2" $1
}

cca_get_lockservers() {
   ccs_read string cluster.ccs cluster/lock_gulm
}

function cca_generate_hosts {
    local ccs_read="/opt/atix/comoonics_cs/ccs_fileread"
    local cca_dir=$1
    local hosts_file=$2

    local ccs_cmd="/opt/atix/comoonics_cs/ccs_fileread"

    if [ ! -d $cca_dir ]; then 
	ccs_cmd="/opt/atix/comoonics_cs/ccs_read"; 
    else
	ccs_dir=$1"/"
    fi
    if [ -n "$debug" ]; then set -x; fi
    cp -f $hosts_file $hosts_file.bak
    (cat $hosts_file.bak && \
	$ccs_cmd $opts strings ${cca_dir}nodes.ccs nodes/.*/ip_interfaces/eth[0-9] | awk -F= '
/\s+/ { 
   match($1, /[^\/]+\/([^\/]+)\//, hostname);
   match($2, /"(.+)"/, ip); 
   print ip[1], hostname[1]; 
}') | sort -u >> $hosts_file
    ret=$?
    if [ $? -ne 0 ]; then cp $hosts_file.bak $hosts_file; fi
    if [ -n "$debug" ]; then set +x; fi
    return $ret
}

# returns all configured networkdevices from the cca serperted by " "
function cca_get_netdevices {
    local ccs_cmd="/opt/atix/comoonics_cs/ccs_fileread"
    local cca_dir=$1

    local hostname=$(cca_get_my_hostname $cca_dir)
    local netdevs=$($ccs_cmd strings ${cca_dir}/nodes.ccs nodes/$hostname/ip_interfaces/eth[0-9]+ | awk -F= '{ 
  match($1, /[^\/]+\/([^\/]+)$/, netdev)
  print netdev[1]; 
}') || return 1
    if [ -n "$netdevs" ]; then
	echo $netdevs
    else
	return 1
    fi
}

#
# gets for this very host the hostname (identified by the macaddress
function cca_get_my_hostname {
    local netdev=$2
    local cca_dir=$1
    local ccs_read="/opt/atix/comoonics_cs/ccs_fileread"
    if [ -z "$netdev" ]; then netdev="eth0"; fi
    local mac=$(ifconfig $netdev | grep HWaddr | awk '{print $5;}')
    local hostname=$(cat $cca_dir/nodes.ccs | awk -v mac=$mac '
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
    if [ -n "$hostname" ]; then 
	echo $hostname
	return 0
    else
	return 1
    fi
}

function cca_autoconfigure_network {
  if [ -n "$debug" ]; then set -x; fi
  local ipconfig=$1
  local netdev=$2
  local cca_dir=$3
  local ccs_read="/opt/atix/comoonics_cs/ccs_fileread"
  if [ -z "$netdev" ]; then netdev="eth0"; fi
  local hostname=$(cca_get_my_hostname $cca_dir $netdev)
  local ip_addr=$($ccs_read string ${cca_dir}/nodes.ccs nodes/$hostname/eth0) || (set+x; return 1)
  local gateway=$($ccs_read string ${cca_dir}/nodes.ccs nodes/$hostname/eth0_gateway) || local gateway=""
  local netmask=$($ccs_read string ${cca_dir}/nodes.ccs nodes/$hostname/eth0_netmask) || (set +x; return 1)
  echo ${ip_addr}"::"${gateway}":"${netmask}":"${hostname}
  if [ -n "$debug" ]; then set +x; fi
}

function copy_relevant_files {
  local cdsl_local_dir=$(shift)
  # backup old files
  olddir=$(pwd)
  if [ -n "$debug" ]; then set -x; fi
  echo -en "\tBacking up created config files"
  (if [ -f /mnt/newroot/etc/modules.conf ]; then
     mv -f /mnt/newroot/etc/modules.conf /mnt/newroot/etc/modules.conf.com_back
   fi &&
   if [ -f /mnt/newroot/etc/sysconfig/hwconf ]; then
     mv -f /mnt/newroot/etc/sysconfig/hwconf /mnt/newroot/etc/sysconfig/hwconf.com_back
   fi && 
   echo "(OK)" ) || (ret_c=$? && echo "(FAILED)")
  echo -en "\tCreating config dirs if not exist.."
  (if [ ! -d /mnt/newroot/${cdsl_local_dir}/etc ]; then 
    mkdir -p /mnt/newroot/${cdsl_local_dir}/etc
   fi &&
   if [ ! -d /mnt/newroot/${cdsl_local_dir}/etc/sysconfig ]; then 
     mkdir -p /mnt/newroot/${cdsl_local_dir}/etc/sysconfig
   fi && echo "(OK)") || (ret_c=$? && echo "(FAILED)")
  echo -en "\tCopying the configfiles.."
  cd /mnt/newroot/${cdsl_local_dir}/etc
  (cp -f /etc/modules.conf /mnt/newroot/${cdsl_local_dir}/etc/modules.conf &&
   ([ -n "$cdsl_local_dir" ] && 
       ln -sf ../${cdsl_local_dir}/etc/modules.conf modules.conf)
   cd sysconfig
   cp -f /etc/sysconfig/hwconf /mnt/newroot/${cdsl_local_dir}/etc/sysconfig/
   ([ -n "$cdsl_local_dir" ] && 
       ln -fs ../../${cdsl_local_dir}/etc/sysconfig/hwconf hwconf)
   cp -f /etc/sysconfig/network /mnt/newroot/${cdsl_local_dir}/etc/sysconfig/
   ([ -n "$cdsl_local_dir" ] && 
       ln -fs ../../${cdsl_local_dir}/etc/sysconfig/network network) &&
   echo "(OK)") || (ret_c=$? && echo "(FAILED)")
  ret_c=$?
  cd $olddir
  if [ -n "$debug" ]; then set +x; fi
  return $ret_c
}
# This function starts the syslog-server to log the gfs-bootprocess
function gfs_start_syslog {
  local syslog_server=$(cca_get_syslog_server)
  echo_local_debug "Syslog server: $syslog_server, hostname: "$(/bin/hostname)
  if [ -n "$syslog_server" ]; then
    echo '*.* @'"$syslog_server" >> /etc/syslog.conf
  else
    echo "*.* -/var/log/comoonics_boot.syslog" >> /etc/syslog.conf
  fi
  
  echo "syslog          514/udp" >> /etc/services
  exec_local /sbin/syslogd -m 1 -a /var/lib/lock_gulmd/dev/log
}

# This function starts the lockgulmd in a chroot environment per default
# If no_chroot is given as param the chroot is skipped
function gfs_start_lockgulmd {
  lock_gulm_dirs=$(cat /etc/lock_gulmd_dirs.list)
  lock_gulm_mv_files=$(cat /etc/lock_gulmd_mv_files.list)
  lock_gulm_cp_files=$(cat /etc/lock_gulmd_cp_files.list)
  if [ "$1" = "no_chroot" ]; then
    /sbin/lock_gulmd
  else
    chroot_dir="/var/lib/lock_gulmd"
    echo_local -n "..build chroot.."
    mkdir -p $chroot_dir
    for dir in $lock_gulm_dirs; do
      mkdir -p $chroot_dir/$dir 2>/dev/null
    done
    for file in $lock_gulm_cp_files; do
      cp -a $file $chroot_dir/$file 2>/dev/null
    done
    for file in $lock_gulm_mv_files; do
      mv $file $chroot_dir/$file 2>/dev/null
      ln -sf $chroot_dir/$file $file 2>/dev/null
    done
    for file in /usr/kerberos/lib/*; do
      ln -sf $file /usr/lib/$(basename $file) 2>/dev/null
      ln -sf $file ${chroot_dir}/usr/lib/$(basename $file) 2>/dev/null
    done
    [ -n "$debug" ] && set +x
    echo_local -n "..syslogd ..."
    gfs_start_syslog

    echo_local -n "..lock_gulmd.."
    /usr/sbin/chroot $chroot_dir /sbin/lock_gulmd || 
    ( echo_local -n "chroot not worked failing back.." && /sbin/lock_gulmd)
    [ -n "$debug" ] && set +x
  fi
  sts=1
  if [ $? -eq 0 ]; then
    echo_local -n "check.."
    for i in $(seq 1 10); do
      sleep 1
      echo_local -n "."
      if gulm_tool getstats localhost:ltpx &> /dev/null; then
	sts=0
	break
      fi
    done
  fi
  if [ $sts -eq 0 ]; then return 0; else return 1; fi
}

# $Log: gfs-lib.sh,v $
# Revision 1.9  2005-01-03 08:30:43  marc
# first offical rpm version
# - major changes in way of starting lock_gulmd. Is started now in a change root
# - logs are also written to a started syslogd
# - cca-param support for com_syslog_server
# - minor changes
#
# Revision 1.8  2004/09/29 14:32:16  marc
# vacation checkin, stable version
#
# Revision 1.7  2004/09/26 14:57:42  marc
# cosmetic change
#
# Revision 1.6  2004/09/26 14:25:50  marc
# update in copy_config_files
#
# Revision 1.5  2004/09/26 14:08:38  marc
# added copy_relevant_files
#
# Revision 1.4  2004/09/12 11:11:06  marc
# added generation of hosts file from cca
#
# Revision 1.3  2004/09/08 16:13:30  marc
# first stable version for autoconfigure from cca
#
# Revision 1.2  2004/08/11 16:53:52  marc
# major enhancements concerning the cca-autoconfiguration
#
# Revision 1.1  2004/07/31 11:24:44  marc
# initial revision
#
