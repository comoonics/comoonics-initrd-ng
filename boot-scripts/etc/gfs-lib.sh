#
# $Id: gfs-lib.sh,v 1.48 2008-05-28 10:12:27 mark Exp $
#
# @(#)$File$
#
# Copyright (c) 2001 ATIX GmbH, 2007 ATIX AG.
# Einsteinstrasse 10, 85716 Unterschleissheim, Germany
# All rights reserved.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

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

#****h* comoonics-bootimage/gfs-lib.sh
#  NAME
#    gfs-lib.sh
#    $id$
#  DESCRIPTION
#*******

default_lockmethod="lock_dlm"
default_mountopts="defaults,noatime,nodiratime"
#ccs_xml_query="/opt/atix/comoonics-cs/ccs_xml_query"
ccs_xml_query="/usr/bin/com-queryclusterconf"
cl_check_nodes="/usr/bin/cl_checknodes"

#****f* gfs-lib.sh/getGFSMajorVersion
#  NAME
#    getGFSMajorVersion
#  SYNOPSIS
#    function getGFSMajorVersion()
#  DESCRIPTION
#    returns the gfs-majorversion
#  IDEAS
#  SOURCE
#
function getGFSMajorVersion {
    modinfo gfs | awk '$1 == "description:" {
  match($5, /v([[:digit:]]+)\./, version);
  print version[1];
}'
}
#************ getGFSMajorVersion

#****f* gfs-lib.sh/getGFSMinorVersion
#  NAME
#    getGFSMinorVersion
#  SYNOPSIS
#    function getGFSMinorVersion()
#  DESCRIPTION
#    returns the gfs-minorversion
#  IDEAS
#  SOURCE
#
function getGFSMinorVersion {
    modinfo gfs | awk '$1 == "description:" {
  match($5, /v[[:digit:]]+\.([[:digit:]]+)/, version);
  print version[1];
}'
}
#********* getGFSMinorVersion

#****f* gfs-lib.sh/gfs_get_rootvolume
#  NAME
#    gfs_get_rootvolume
#  SYNOPSIS
#    gfs_get_rootvolume(cluster_conf, nodename)
#  DESCRIPTION
#    Gets the rootvolume for this node
#  IDEAS
#  SOURCE
#
function gfs_get_rootvolume {
   local xml_file=$1
   local hostname=$2
   [ -z "$hostname" ] && hostname=$(gfs_get_nodename $xml_file)
   local xml_cmd="${ccs_xml_query} -f $xml_file"
   $xml_cmd -q rootvolume $hostname
}
#************ gfs_get_rootvolume

#****f* gfs-lib.sh/gfs_get_rootsource
#  NAME
#    gfs_get_rootsource
#  SYNOPSIS
#    gfs_get_rootsource(cluster_conf, nodename)
#  DESCRIPTION
#    Gets the rootsource for this node
#  IDEAS
#  SOURCE
#
function gfs_get_rootsource {
   local xml_file=$1
   local hostname=$2
   [ -z "$hostname" ] && hostname=$(gfs_get_nodename $xml_file)
   local xpath="/cluster/clusternodes/clusternode[@name=\"$hostname\"]/com_info/rootsource/@name"
   local xml_cmd="${ccs_xml_query} -f $xml_file"
   $xml_cmd -q query_value $xpath
}
#************ gfs_get_rootsource

#****f* gfs-lib.sh/gfs_get_rootfs
#  NAME
#    gfs_get_rootfs
#  SYNOPSIS
#    gfs_get_rootfs(cluster_conf, nodename, [rootfs])
#  DESCRIPTION
#    Gets the root filesystem type for this node
#    Default is ""
#  IDEAS
#  SOURCE
#
function gfs_get_rootfs {
   local xml_file=$1
   local hostname=$2

   [ -z "$hostname" ] && hostname=$(gfs_get_nodename $xml_file)
   local xml_cmd="${ccs_xml_query} -f $xml_file"

   local __rootfs=$($xml_cmd -q rootfs $hostname)

   if [ -z "$__rootfs" ]; then
     echo ""
   else
     echo $__rootfs
   fi
}
#************ gfs_get_rootfs

#****f* gfs-lib.sh/gfs_get_mountopts
#  NAME
#    gfs_get_mountopts
#  SYNOPSIS
#    gfs_get_mountopts(cluster_conf, nodename)
#  DESCRIPTION
#    Gets the mountopts for this node
#  IDEAS
#  SOURCE
#
function gfs_get_mountopts {
   local xml_file=$1
   local hostname=$2
   [ -z "$hostname" ] && hostname=$(gfs_get_nodename $xml_file)
   local xml_cmd="${ccs_xml_query} -f $xml_file"
   _mount_opts=$($xml_cmd -q mountopts $hostname)
   if [ -z "$_mount_opts" ]; then
     echo $default_mountopts
   else
     echo $_mount_opts
   fi
}
#************ gfs_get_mountopts

#****f* gfs-lib.sh/gfs_get_chroot_mountpoint
#  NAME
#    gfs_get_chroot_mountpoint
#  SYNOPSIS
#    gfs_get_chroot_mountpoint(cluster_conf, nodename)
#  DESCRIPTION
#    Gets the mountpoint for the chroot environment of this node
#  IDEAS
#  SOURCE
#
function gfs_get_chroot_mountpoint {
   local xml_file=$1
   local hostname=$2
   [ -z "$hostname" ] && hostname=$(gfs_get_nodename $xml_file)
   local xpath="/cluster/clusternodes/clusternode[@name=\"$hostname\"]/com_info/chrootenv/@mountpoint"
   local xml_cmd="${ccs_xml_query} -f $xml_file"
   $xml_cmd -q query_value $xpath
}
#************ gfs_get_chroot_mountpoint

#****f* gfs-lib.sh/gfs_get_chroot_fstype
#  NAME
#    gfs_get_chroot_fstype
#  SYNOPSIS
#    gfs_get_chroot_fstype(cluster_conf, nodename)
#  DESCRIPTION
#    Gets the filesystem type for the chroot environment of this node
#  IDEAS
#  SOURCE
#
function gfs_get_chroot_fstype {
   local xml_file=$1
   local hostname=$2
   [ -z "$hostname" ] && hostname=$(gfs_get_nodename $xml_file)
   local xpath="/cluster/clusternodes/clusternode[@name=\"$hostname\"]/com_info/chrootenv/@fstype"
   local xml_cmd="${ccs_xml_query} -f $xml_file"
   $xml_cmd -q query_value $xpath
}
#************ gfs_get_chroot_fstype

#****f* gfs-lib.sh/gfs_get_chroot_device
#  NAME
#    gfs_get_chroot_device
#  SYNOPSIS
#    gfs_get_chroot_device(cluster_conf, nodename)
#  DESCRIPTION
#    Gets the mountpoint for the chroot environment of this node
#  IDEAS
#  SOURCE
#
function gfs_get_chroot_device {
   local xml_file=$1
   local hostname=$2
   [ -z "$hostname" ] && hostname=$(gfs_get_nodename $xml_file)
   local xpath="/cluster/clusternodes/clusternode[@name=\"$hostname\"]/com_info/chrootenv/@device"
   local xml_cmd="${ccs_xml_query} -f $xml_file"
   $xml_cmd -q query_value $xpath
}
#************ gfs_get_chroot_device

#****f* gfs-lib.sh/gfs_get_chroot_mountopts
#  NAME
#    gfs_get_chroot_mountopts
#  SYNOPSIS
#    gfs_get_chroot_mountopts(cluster_conf, nodename)
#  DESCRIPTION
#    Gets the mount options for the chroot environment of this node
#  IDEAS
#  SOURCE
#
function gfs_get_chroot_mountopts {
   local xml_file=$1
   local hostname=$2
   [ -z "$hostname" ] && hostname=$(gfs_get_nodename $xml_file)
   local xpath="/cluster/clusternodes/clusternode[@name=\"$hostname\"]/com_info/chrootenv/@mountoptions"
   local xml_cmd="${ccs_xml_query} -f $xml_file"
   $xml_cmd -q query_value $xpath
}
#************ gfs_get_chroot_mountopts

#****f* gfs-lib.sh/gfs_get_chroot_dir
#  NAME
#    gfs_get_chroot_dir
#  SYNOPSIS
#    gfs_get_chroot_dir(cluster_conf, nodename)
#  DESCRIPTION
#    Gets the directory for the chroot environment of this node
#  IDEAS
#  SOURCE
#
function gfs_get_chroot_dir {
   local xml_file=$1
   local hostname=$2
   [ -z "$hostname" ] && hostname=$(gfs_get_nodename $xml_file)
   local xpath="/cluster/clusternodes/clusternode[@name=\"$hostname\"]/com_info/chrootenv/@chrootdir"
   local xml_cmd="${ccs_xml_query} -f $xml_file"
   $xml_cmd -q query_value $xpath
}
#************ gfs_get_chroot_dir



#****f* gfs-lib.sh/gfs_get_scsifailover
#  NAME
#    gfs_get_scsifailover
#  SYNOPSIS
#    gfs_get_scsifailover(cluster_conf, nodename)
#  DESCRIPTION
#    Gets the mountopts for this node
#  IDEAS
#  SOURCE
#
function gfs_get_scsifailover {
   local xml_file=$1
   local nodename=$2
   [ -z "$nodename" ] && nodename=$(gfs_get_nodename $xml_file)
   local xml_cmd="${ccs_xml_query} -f $xml_file"
   local _scsifailover=$($xml_cmd -q scsifailover $nodename)
   if [ -z "$_scsifailover" ]; then
     echo ""
   else
     echo $_scsifailover
   fi
}
#************ gfs_get_scsifailover

#****f* gfs-lib.sh/gfs_get_node_hostname
#  NAME
#    gfs_get_node_hostname
#  SYNOPSIS
#    gfs_get_node_hostname(clusterconf, [nodename])
#  DESCRIPTION
#    returns the hostname for this node
#    !!!THIS FUNCTION SHOULD NOT BE NEEDED ANY MORE!!!!
#  IDEAS
#  SOURCE
#
function gfs_get_node_hostname {
   local xml_file=$1
   local nodename=$2
   [ -z "$nodename" ] && nodename=$(gfs_get_nodename)
   local xml_cmd="${ccs_xml_query} -f $xml_file"
   $xml_cmd -q hostname $nodename 2>/dev/null
   return $?
}
#************ gfs_get_node_hostname

#****f* gfs-lib.sh/gfs_get_nodename
#  NAME
#    gfs_get_nodename
#  SYNOPSIS
#    function gfs_get_nodename(cluster_conf, netdev)
#  DESCRIPTION
#    gets for this very host the nodename (identified by the macaddress)
#  IDEAS
#  SOURCE
#
function gfs_get_nodename {
    local ccs_file=$1
    local mac=$2

    local xml_cmd="${ccs_xml_query}"
    $xml_cmd -f $ccs_file -q nodename $mac
}
#************ gfs_get_nodename

#****f* gfs-lib.sh/gfs_get_nodeid
#  NAME
#    gfs_get_nodeid
#  SYNOPSIS
#    function gfs_get_nodeid(cluster_conf, mac)
#  DESCRIPTION
#    gets for this very host the nodeid (identified by the macaddress)
#  IDEAS
#  SOURCE
#
function gfs_get_nodeid {
    local ccs_file=$1
    local mac=$2

    local xml_cmd="${ccs_xml_query}"
    $xml_cmd -f $ccs_file -q nodeid $mac
}
#************ gfs_get_nodeid

#****f* gfs-lib.sh/gfs_get_clu_nodename
#  NAME
#    gfs_get_clu_nodename
#  SYNOPSIS
#    function gfs_get_clu_nodename()
#  DESCRIPTION
#    gets the nodename of this node from the cluster infrastructure
#  SOURCE
function gfs_get_clu_nodename {
  cat /proc/cluster/status | grep "Node name:"  | awk  '{print $3}'
}
#******* cc_get_clu_nodename



#****f* gfs-lib.sh/gfs_get_netdevs
#  NAME
#    gfs_get_netdevs
#  SYNOPSIS
#    function gfs_get_netdevs(cluster_conf, nodename)
#  DESCRIPTION
#    returns all configured networkdevices from the cluster.conf xml file
#    seperated by " "
#  IDEAS
#  SOURCE
#
function gfs_get_netdevs {
#	if [ -n "$debug" ]; then set -x; fi
  local xml_cmd="${ccs_xml_query}"
  local xmlfile=$1
  local nodename=$2

  local netdevs=$($xml_cmd -f $xmlfile -q netdevs $nodename " ");
  echo $netdevs
#	if [ -n "$debug" ]; then set +x; fi
  return 0
}
#********* gfs_get_netdevs

#****f* gfs-lib.sh/gfs_auto_hosts
#  NAME
#    gfs_auto_hosts
#  SYNOPSIS
#    function gfs_auto_hosts(cluster_conf)
#  DESCRIPTION
#    Generates a hostsfile of all hosts in the cluster configuration
#  IDEAS
#  SOURCE
#
function gfs_auto_hosts {
    local xml_cmd="${ccs_xml_query}"
    local xmlfile=$1
    local hostsfile=$2

#    if [ -n "$debug" ]; then set -x; fi
#    cp -f $hostsfile $hostsfile.bak
    $xml_cmd -f $xmlfile -q hosts
    cat $hostsfile
    ret=$?
#    if [ -n "$debug" ]; then set +x; fi
    return $ret
}
#************ gfs_auto_hosts

#****f* gfs-lib.sh/gfs_auto_netconfig
#  NAME
#    gfs_auto_netconfig
#  SYNOPSIS
#    function gfs_auto_netconfig(ipConfig, $netdev, cluster_conf)
#  DESCRIPTION
#  IDEAS
#  SOURCE
#
function gfs_auto_netconfig {
#  if [ -n "$debug" ]; then set -x; fi
  local xml_file=$1
  local nodename=$2
  local netdev=$3
  local xml_cmd="${ccs_xml_query}"
  if [ -z "$netdev" ]; then netdev="eth0"; fi

  local ip_addr=$($xml_cmd -f $xml_file -q ip $nodename $netdev 2>/dev/null)
  local mac_addr=$($xml_cmd -f $xml_file -q query_value /cluster/clusternodes/clusternode[@name=\"$nodename\"]/com_info/eth[@name=\"$netdev\"]/mac 2>/dev/null)
  if [ -z "$mac_addr" ]; then
  	local mac_addr=$(ifconfig $netdev | grep -i hwaddr | awk '{print $5;};')
  fi
  mac_addr=${mac_addr//:/-}
  if [ $? -eq 0 ] && [ "$ip_addr" != "" ]; then
    local gateway=$($xml_cmd -f $xml_file -q gateway $nodename $netdev) || local gateway=""
    local netmask=$($xml_cmd -f $xml_file -q mask $nodename $netdev)
    echo ${ip_addr}"::"${gateway}":"${netmask}"::"$netdev":"$mac_addr
  else
    local master=$($xml_cmd -f $xml_file -q master $nodename $netdev 2>/dev/null)
    local slave=$($xml_cmd -f $xml_file -q slave $nodename $netdev 2>/dev/null)
    echo ":${master}:${slave}:::${netdev}:${mac_addr}"
  fi

#  if [ -n "$debug" ]; then set +x; fi
}
#************ gfs_auto_netconfig

#****f* gfs-lib.sh/gfs_get_syslogserver
#  NAME
#    gfs_get_syslogserver
#  SYNOPSIS
#    function gfs_get_syslogserver(cluster_conf)
#  DESCRIPTION
#    This function starts the syslog-server to log the gfs-bootprocess
#  IDEAS
#  SOURCE
#
function gfs_get_syslogserver {
  local xml_file=$1
  local xml_cmd="${ccs_xml_query}"
  local nodename=$2
  $xml_cmd -f $xml_file -q syslog $nodename
}
#************ gfs_get_syslogserver

#****f* gfs-lib.sh/gfs_load
#  NAME
#    gfs_load
#  SYNOPSIS
#    function gfs_load(lockmethod)
#  DESCRIPTION
#    This function loads all relevant gfs modules
#  IDEAS
#  SOURCE
#
function gfs_load {
  ## THIS will be overwritten for rhel5 ##
  local lock_method=$1

  GFS_MODULES="gfs cman"

  case $lock_method in
    lock_dlm)
      GFS_MODULES="${GFS_MODULES} lock_dlm"
      ;;
    lock_gulm)
      GFS_MODULES="${GFS_MODULES} lock_gulm"
      ;;
    *)
      GFS_MODULES="${GFS_MODULES} lock_dlm"
      ;;
  esac

  echo_local -n "Loading GFS modules ($GFS_MODULES)..."
  for module in ${GFS_MODULES}; do
    exec_local /sbin/modprobe ${module}
  done
  return_code

  echo_local_debug  "Loaded modules:"
  exec_local_debug /sbin/lsmod

  return $return_c
}
#************ gfs_load

#****f* gfs-lib.sh/gfs_services_start
#  NAME
#    gfs_services_start
#  SYNOPSIS
#    function gfs_services_start(lockmethod)
#  DESCRIPTION
#    This function loads all relevant gfs modules
#  IDEAS
#  SOURCE
#
function gfs_services_start {
  ## THIS will be overwritten for rhel5 ##
  local chroot_path=$1
  local lock_method=$2
  local lvm_sup=$3

  services="ccsd $lock_method cman qdiskd fenced"
  if [ "$lvm_sup" -eq 0 ]; then
  	services="$services clvmd"
  fi
  for service in $services; do
    gfs_start_$service $chroot_path
    if [ $? -ne 0 ]; then
      return $?
    fi
  done
  return $return_c
}
#************ gfs_services_start

#****f* gfs-lib.sh/gfs_services_restart_newroot
#  NAME
#    gfs_services_restart_newroot
#  SYNOPSIS
#    function gfs_services_restart_newroot()
#  DESCRIPTION
#    This function starts all needed services in newroot
#  IDEAS
#  SOURCE
#
function gfs_services_restart_newroot() {
  ## THIS will be overwritten for rhel5 ##
  exec_local /bin/true
}
#************ gfs_services_restart_newroot

#****f* gfs-lib.sh/gfs_services_restart
#  NAME
#    gfs_services_restart
#  SYNOPSIS
#    function gfs_services_restart(lockmethod)
#  DESCRIPTION
#    This function loads all relevant gfs modules
#  IDEAS
#  SOURCE
#
function gfs_services_restart {
  local old_root=$1
  local new_root=$2

  services="ccsd fenced"
  for service in $services; do
    gfs_restart_$service $old_root $new_root
    if [ $? -ne 0 ]; then
      echo $service > $new_root/${cdsl_local_dir}/FAILURE_$service
#      return $?
    fi
    step
  done
  return $return_c
}
#************ gfs_services_restart

#****f* gfs-lib.sh/gfs_start_lock_gulm
#  NAME
#    gfs_start_lock_gulm
#  SYNOPSIS
#    function gfs_start_lock_gulm
#  DESCRIPTION
#    Function starts the lock_gulm in a changeroot environment
#  IDEAS
#  SOURCE
#
function gfs_start_lock_gulm {
  local chroot_path=$1
  start_service_chroot $chroot_path '/sbin/lock_gulmd'
  sts=1
  if [ $? -eq 0 ]; then
    echo_local -n "   check Lockgulmd.."
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
#************ gfs_start_lock_gulmd

#****f* gfs-lib.sh/gfs_start_lock_dlm
#  NAME
#    gfs_start_lock_dlm
#  SYNOPSIS
#    function gfs_start_lock_dlm
#  DESCRIPTION
#    Function starts the lock_dlm in a changeroot environment
#  IDEAS
#  SOURCE
#
function gfs_start_lock_dlm {
  return 0
}
#************ gfs_start_lock_dlm

#****f* gfs-lib.sh/gfs_start_cman
#  NAME
#    gfs_start_cman
#  SYNOPSIS
#    function gfs_start_cman
#  DESCRIPTION
#    Function starts the cman in a changeroot environment
#  IDEAS
#  SOURCE
#
function gfs_start_cman {
  echo_local -n "Joining the cluster manager"
  sleep 5
  start_service_chroot $chroot_path cman_tool join -w
  return_code
}
#************ gfs_start_cman

#****f* gfs-lib.sh/gfs_stop_cman
#  NAME
#    gfs_stop_cman
#  SYNOPSIS
#    function gfs_stop_cman
#  DESCRIPTION
#    Function stops the cman in a changeroot environment
#  IDEAS
#  SOURCE
#
function gfs_stop_cman {
  echo_local -n "Leaving the cluster"
  exec_local cman_tool leave remove -w
  return_code
}
#************ gfs_stop_cman

#****f* gfs-lib.sh/gfs_start_fenced
#  NAME
#    gfs_start_fenced
#  SYNOPSIS
#    function gfs_start_fenced {
#  DESCRIPTION
#    Function starts the fenced in a changeroot environment
#  IDEAS
#  SOURCE
#
function gfs_start_fenced {
  ## THIS will be overwritten for rhel5 ##
  local chroot_path=$1
  #start_service_chroot $chroot_path 'fenced -c'
  start_service_chroot $chroot_path '/sbin/fence_tool -c -w join'
  #echo_local "Waiting for fenced to complete join"
  #exec_local fence_tool wait
  return_code
}
#************ gfs_start_fenced

#****f* gfs-lib.sh/gfs_stop_fenced
#  NAME
#    gfs_stop_fenced
#  SYNOPSIS
#    function gfs_stop_fenced {
#  DESCRIPTION
#    Function stops the fenced in a changeroot environment
#  IDEAS
#  SOURCE
#
function gfs_stop_fenced {
  local chroot_path=$1
  echo_local "stopping fenced"
  exec_local '/sbin/fence_tool leave -w'
  return_code
}
#************ gfs_start_fenced

#****f* gfs-lib.sh/gfs_start_ccsd
#  NAME
#    gfs61_start_ccsd
#  SYNOPSIS
#    function gfs_start_ccsd {
#  DESCRIPTION
#    Function starts the ccsd in nochroot environment
#  IDEAS
#  SOURCE
#
function gfs_start_ccsd {
  local chroot_path=$1
  start_service_chroot $chroot_path /sbin/ccsd
}

#************ gfs_start_ccsd

#****f* gfs-lib.sh/gfs_restart_ccsd
#  NAME
#    gfs_restart_ccsd
#  SYNOPSIS
#    function gfs_restart_ccsd(old_root, new_root)
#  DESCRIPTION
#    Function restarts the ccsd for removing the deps on /initrd
#  IDEAS
#  SOURCE
#
function gfs_restart_ccsd {
   old_root=$1
   new_root=$2

#   set -x
   echo_local -n "Restarting ccsd ($old_root=>$new_root) "$(pwd)
   [ -e ${old_root}/var/run/cluster/ccsd.pid ] &&
   kill $(cat ${old_root}/var/run/cluster/ccsd.pid) &&
   rm ${old_root}/var/run/cluster/ccsd.pid &&
   rm -rf ${new_root}/var/run/cluster &&
   mkdir ${new_root}/var/run/cluster
   echo_local -n ".(kill)."
   if [ $? -ne 0 ]; then
      pids=$(ps ax | grep ccsd | awk '$5!="grep" { print $1; }')
      if [ -n "$pids" ]; then
        kill $pids
      fi
      pids=$(ps ax | grep ccsd | awk '$5!="grep" { print $1; }')
      if [ -n "$pids" ]; then
        kill -9 $pids
      fi
    fi
    chroot $new_root /sbin/ccsd &&
    echo_local -n ".(start)."
    return_code $?
}
#******gfs_restart_ccsd

#****f* gfs-lib.sh/gfs_start_clvmd
#  NAME
#    gfs_start_clvmd
#  SYNOPSIS
#    function gfs_start_clvmd(chroot)
#  DESCRIPTION
#    Function starts the clvmd in a chroot environment
#  IDEAS
#  SOURCE
#
function gfs_start_clvmd {
   chroot_path=$1

   echo_local -n "Starting clvmd ($chroot_path) "
   start_service_chroot $chroot_path /usr/sbin/clvmd
   return_code $?
   sleep 10
   echo_local -n "Activating VGs:"
   exec_local_stabilized 5 10 chroot $chroot_path /sbin/lvm vgscan --mknodes >/dev/null 2>&1
   exec_local_stabilized 5 10 chroot $chroot_path /sbin/lvm vgchange -ay >/dev/null 2>&1
   exec_local_stabilized 5 10 /sbin/lvm vgscan --mknodes >/dev/null 2>&1
   exec_local_stabilized 5 10 /sbin/lvm vgchange -ay >/dev/null 2>&1
   return_code $?
}
#******gfs_start_clvmd

#****f* gfs-lib.sh/gfs_stop_clvmd
#  NAME
#    gfs_stop_clvmd
#  SYNOPSIS
#    function gfs_stop_clvmd(chroot)
#  DESCRIPTION
#    Function stops the clvmd in a chroot environment
#  IDEAS
#  SOURCE
#
function gfs_stop_clvmd {
   chroot_path=$1

   echo_local -n "Stopping clvmd ($chroot_path) "
   exec_local killall clvmd
   if pidof clvmd > /dev/null; then
       killall -9 clvmd
   fi
   return_code $?
}
#******gfs_stop_clvmd

#****f* gfs-lib.sh/gfs_restart_clvmd
#  NAME
#    gfs_restart_clvmd
#  SYNOPSIS
#    function gfs_restart_clvmd(old_root, new_root)
#  DESCRIPTION
#    Function restarts the clvmd for removing the deps on /initrd
#  IDEAS
#  SOURCE
#
function gfs_restart_clvmd {
   old_root=$1
   new_root=$2

#   set -x
   echo_local -n "Starting clvmd ($new_root) "$(pwd)
   chroot $new_root /usr/sbin/clvmd
   return_code $?
   echo_local -n "ActivatinActivating VGs:"
   chroot $new_root /sbin/vgscan --mknodes >/dev/null 2>&1
   chroot $new_root /sbin/vgchange -ayl >/dev/null 2>&1
   return_code $?
}
#******gfs_restart_clvmd

#****f* gfs-lib.sh/gfs_restart_fenced
#  NAME
#    gfs_restart_fenced
#  SYNOPSIS
#    function gfs_restart_fenced(old_root, new_root)
#  DESCRIPTION
#    Function restarts the fenced for removing the deps on /initrd
#  IDEAS
#  SOURCE
#
function gfs_restart_fenced {
   old_root=$1
   new_root=$2

   echo_local -n "Restarting fenced ($old_root=>$new_root) "
   [ ! -d ${new_root}/cluster/shared/var/lib/fence_tool ] && mkdir -p ${new_root}/cluster/shared/var/lib/fence_tool
   mount -t tmpfs none ${new_root}/cluster/shared/var/lib/fence_tool &&
   echo_local -n ".(mount)." &&
   cp -a ${old_root}/var/lib/fence_tool/* ${new_root}/cluster/shared/var/lib/fence_tool &&
   echo_local -n ".(cp)." &&
   kill $(cat ${old_root}/var/lib/fence_tool/var/run/fenced.pid) &&
   echo_local -n ".(kill)." &&
   rm ${old_root}/var/lib/fence_tool/var/run/fenced.pid
   if [ $? -ne 0 ]; then
     pids=$(ps ax | grep fenced | awk '$5!="grep" { print $1; }')
     if [ -n "$pids" ]; then
       kill $pids
     fi
     pids=$(ps ax | grep fenced | awk '$5!="grep" { print $1; }')
     if [ -n "$pids" ]; then
       kill -9 $pids
     fi
   fi &&
   chroot ${new_root}/cluster/shared/var/lib/fence_tool /sbin/fenced
   error_code=$?
   return_code $error_code
#   set +x

   return $error_code
}
#************ gfs_restart_fenced

#****f* gfs-lib.sh/gfs_start_qdiskd
#  NAME
#    gfs_start_qdiskd
#  SYNOPSIS
#    function gfs_start_qdiskd {
#  DESCRIPTION
#    Function starts the qdiskd in chroot environment
#  IDEAS
#  SOURCE
#
function gfs_start_qdiskd {
  ## THIS will be overwritten for rhel5 ##
  local chroot_path=$1

  $ccs_xml_query query_xml /cluster/quorumd >/dev/null 2>&1
  if [ $? -eq 0 ]; then
     start_service_chroot $chroot_path /sbin/qdiskd -Q
  else
  	 echo_local -n "Starting qdiskd"
     passed
     echo_local
  fi
}
#************ gfs_start_qdiskd

#****f* gfs-lib.sh/gfs_start_groupd
#  NAME
#    gfs_start_groupd
#  SYNOPSIS
#    function gfs_start_groupd {
#  DESCRIPTION
#    Function starts the groupd in chroot environment
#  IDEAS
#  SOURCE
#
function gfs_start_groupd {
  local chroot_path=$1
  start_service_chroot $chroot_path  /sbin/groupd
}
#************ gfs_start_groupd

#****f* gfs-lib.sh/gfs_start_dlm_controld
#  NAME
#    gfs_start_dlm_controld
#  SYNOPSIS
#    function gfs_start_dlm_controld {
#
#  DESCRIPTION
#    Function starts the dlm_controld in chroot environment
#  IDEAS
#  SOURCE
#
function gfs_start_dlm_controld {
  local chroot_path=$1
  start_service_chroot $chroot_path /sbin/dlm_controld
}
#************ gfs_start_dlm_controld

#****f* gfs-lib.sh/gfs_start_gfs_controld
#  NAME
#    gfs_start_gfs_controld
#  SYNOPSIS
#    function gfs_start_gfs_controld {
#
#  DESCRIPTION
#    Function starts the gfs_controld in chroot environment
#  IDEAS
#  SOURCE
#
function gfs_start_gfs_controld {
  local chroot_path=$1
  start_service_chroot $chroot_path /sbin/gfs_controld
}
#************ gfs_start_gfs_controld



#****f* clusterfs-lib.sh/gfs_checkhosts_alive
#  NAME
#    gfs_checkhosts_alive
#  SYNOPSIS
#    function gfs_checkhosts_alive()
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function gfs_checkhosts_alive {
#   local xml_file=/etc/cluster/cluster.conf
#   local twonodes=$($ccs_xml_query -f $xml_file -q query_value cluster/cman/@two_node 2>/dev/null) || local twonodes=0
#   if [ $twonodes -eq 1 ]; then
    $cl_check_nodes
#   else
#      /bin/true
#   fi
}
#********* gfs_checkhosts_alive

# $Log: gfs-lib.sh,v $
# Revision 1.48  2008-05-28 10:12:27  mark
# added exec_local_stabilized
# fix for bz 193
#
# Revision 1.47  2008/05/17 08:30:52  marc
# changed the way the /etc/hosts is created a little bit.
#
# Revision 1.46  2008/04/03 15:57:21  mark
# Workaround bz# 193
#
# Revision 1.45  2008/01/24 13:30:04  marc
# - RFE#145 macaddress will be generated in configuration files
#
# Revision 1.44  2007/12/07 16:39:59  reiner
# Added GPL license and changed ATIX GmbH to AG.
#
# Revision 1.43  2007/10/18 08:03:37  mark
# added some fancy qdisk messages
#
# Revision 1.42  2007/10/16 08:01:24  marc
# - added get_rootsource
# - fixed BUG 142
# - lvm switch support
#
# Revision 1.41  2007/10/09 16:47:44  mark
# added gfs_services_restart_newroot
#
# Revision 1.40  2007/10/05 09:02:40  mark
# added stop methods
#
# Revision 1.39  2007/10/02 11:53:11  mark
# add another vgscan to source /dev
#
# Revision 1.38  2007/09/27 12:01:29  marc
# cosmetic change
#
# Revision 1.37  2007/09/27 09:32:11  marc
# - BUG 125: made qdiskd only to be started only when configured in cluster.conf
#
# Revision 1.36  2007/09/19 08:57:20  mark
# overwrite start_fenced for rhel5
#
# Revision 1.35  2007/09/18 10:10:25  mark
# removed duplicate start of fenced
#
# Revision 1.34  2007/09/07 08:01:12  mark
# bug fixes
# added some start methods
#
# Revision 1.33  2007/08/06 15:50:11  mark
# reorganized libraries
# added methods for chroot management
# fits for bootimage release 1.3
#
# Revision 1.32  2007/08/06 09:14:48  mark
# Fixed BZ #76
#
# Revision 1.31  2007/03/09 18:01:44  mark
# separated fstype and clutype
#
# Revision 1.30  2006/11/10 11:36:26  mark
# - modified gfs_start_fenced: added fence_tool wait, removed undefined -w option from fenced
#
# Revision 1.29  2006/10/06 08:32:57  marc
# added cl_checknodes as variable
#
# Revision 1.28  2006/08/28 16:06:45  marc
# bugfixes
# new version of start_service
#
# Revision 1.27  2006/08/08 08:31:52  marc
# changed path to new version
#
# Revision 1.26  2006/07/03 08:33:05  marc
# bugfix in hostsgeneration
#
# Revision 1.25  2006/06/19 15:55:45  marc
# added device mapper support
#
# Revision 1.24  2006/05/12 13:06:41  marc
# First stable Version 1.0 for initrd.
#
# Revision 1.23  2006/05/07 11:35:20  marc
# major change to version 1.0.
# Complete redesign.
#
# Revision 1.22  2006/05/03 12:45:20  marc
# added documentation
#
# Revision 1.21  2006/04/13 18:49:51  marc
# better errorhandling on fence_tool chroot
#
# Revision 1.20  2006/04/09 16:33:15  marc
# changed fencing from fence_tool join to fenced. Because fence_tool returns 1
#
# Revision 1.19  2006/04/08 18:00:19  marc
# added nodename and hostname as hostname
#
# Revision 1.18  2006/02/16 13:59:30  marc
# minor changes
#   copy configs
#
# Revision 1.17  2006/02/03 12:40:13  marc
# small change in copying files
#
# Revision 1.16  2006/01/28 15:10:53  marc
# reenabled the restart of fenced in ccsd in initrd
# removing files in initrd
#
# Revision 1.15  2006/01/25 14:49:19  marc
# new i/o redirection
# new switchroot
# bugfixes
# new stepmode
#
# Revision 1.14  2006/01/23 14:12:24  mark
# ...
#
# Revision 1.13  2005/07/08 13:00:34  mark
# added devfs support
#
# Revision 1.11  2005/06/08 13:35:26  marc
# added chroot_syslog
#
# Revision 1.10  2005/01/05 10:53:33  marc
# moved syslog and ccsd in chroot to /var/lib/lock_gulmd
# added function gfs_start_service
#
# Revision 1.9  2005/01/03 08:30:43  marc
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
