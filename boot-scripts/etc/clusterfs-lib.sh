#
# $Id: clusterfs-lib.sh,v 1.45 2010-03-08 13:08:36 marc Exp $
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
#    com-stepmode=...      If set it asks for <return> after every step
#    com-debug=...         If set debug info is output
#****h* boot-scripts/etc/clusterfs-lib.sh
#  NAME
#    clusterfs-lib.sh
#    $id$
#  DESCRIPTION
#    Libraryfunctions for general clusterfs support.
#*******

#****d* boot-scripts/etc/clusterfs-lib.sh/cdsl_local_dir
#  NAME
#    cdsl_local_dir
#  DESCRIPTION
#    where the local dir for cdsls can be found
repository_has_key cdsl_local_dir || repository_store_value cdsl_local_dir "/cdsl.local"
#******** cdsl_local_dir

#****d* boot-scripts/etc/clusterfs-lib.sh/cdsl_prefix
#  NAME
#    cdsl_prefix
#  DESCRIPTION
#    where the local dir for cdsls can be found
repository_has_key cdsl_prefix || repository_store_value cdsl_prefix "/cluster/cdsl"
#******** cdsl_prefix

repository_has_key osrquerymap || repository_store_value osrquerymap /etc/comoonics/querymap.cfg 


#****f* boot-scripts/etc/clusterfs-lib.sh/getClusterFSParameters
#  NAME
#    getClusterFSParameters
#  SYNOPSIS
#    function getClusterFSParameters() {
#  DESCRIPTION
#    sets all clusterfs relevant parameters given by the bootloader
#    via /proc/cmdline as global variables.
#    The following global variables are set
#      * root: The rootdevice parameter
#      * rootsource: The rootdevicesource (scsi|iscsi|gnbd)
#      * lockmethod: If supported by the clusterfs implementation.
#           Valid modes are (lock_gulm|lock_dlm)
#      * sourceserver: Root source server if (iscsi|gnbd)
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function getClusterFSParameters() {
  getBootParm rootsource
  echo -n ":"
  getBootParm root
  echo -n ":"
  getBootParm lockmethod $default_lockmethod
  echo -n ":"
  getBootParm sourceserver
  echo -n ":"
  getBootParm quorumack
  echo -n ":"
  getBootParm nodeid
  echo -n ":"
  getBootParm nodename
  echo -n ":"
  getBootParm fstype
  echo -n ":"
}
#******** getClusterFSParameters

#****f* boot-scripts/etc/clusterfs-lib.sh/getCluType
#  NAME
#    getCluType
#  SYNOPSIS
#    function getCluType()
#  DESCRIPTTION
#    returns the type of the cluster. Until now only "gfs"
#    is returned.
#  SOURCE
#
function getCluType {
   local conf=$1
   local clutype=""
   
   typeset -f osr_nodeids_file &> /dev/null
   if test $? -eq 0 && test -f $(osr_nodeids_file); then
   	  echo "osr"
   	  return 0
   fi
   
   if [ -z "$conf" ]; then
   	  conf=$cluster_conf
   fi
   clutype=$(com-queryclusterconf -f $conf clustertype 2>/dev/null)
   if [ $? -eq 0 ]; then
   	  echo "$clutype"
   	  return 0
   fi
   clutype=$(com-queryclusterconf -f $conf query_value /cluster/@type 2>/dev/null)
   if [ $? -eq 0 ] && [ -n "$clutype" ]; then
   	  echo "$clutype"
   	  return 0
   fi
   echo "gfs"
}
#******** getCluType

#****f* boot-scripts/etc/clusterfs-lib.sh/getRootFS
#  NAME
#    getRootFS
#  SYNOPSIS
#    function getRootFS(cluster_conf, nodeid, nodename)
#  DESCRIPTTION
#    returns the type of the root filesystem. Until now only "gfs"
#    is returned.
#  SOURCE
#
function getRootFS {
   local cluster_conf=$1
   local nodeid=$2
   local nodename=$3
   local clutype=$(repository_get_value clutype)
   local rootfs=$(${clutype}_get_rootfs $cluster_conf $nodeid $nodename)
   if [ -z "$rootfs" ]; then
     rootfs="gfs"
   fi
   echo "$rootfs"
}
#******** getRootFS

#****f* bootsr/get_rootfs
#  NAME
#    get_rootfs
#  SYNOPSIS
#    function returns the rootfstype of amounted rootfs
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function get_mounted_rootfs {
   root="/"
   if [ -n "$1" ]; then
   	 root=$1
   fi
   awk '
$1 == "rootfs" { next }
$2 == "'$root'" { print $3 }
' /proc/mounts
}
#************ get_rootfs

#****f* boot-scripts/etc/clusterfs-lib.sh/getClusterParameter
#  NAME
#    getClusterParameter
#  SYNOPSIS
#    getClusterParameter(parametername, cluster_conf, nodeid, nodename)
#  DESCRIPTION
#    returns the parameter of the cluster configuration
#  SOURCE
function getClusterParameter() {
	local name=$1
	shift
	local cluster_conf=""
	local out=""
	if [ -n "$1" ] && [ -e $1 ]; then
		cluster_conf=$1
		shift
	else
	    cluster_conf=$(repository_get_value cluster_conf)
	fi
	# first we need to find our nodeid
	#maybe it is already in the repository
	local nodeid=""
    local nodename=""
	[ -n "$1" ] && nodeid="$1"
	[ -n "$2" ] && nodename="$2"
	if [ -z "$nodeid" ] && repository_has_key nodeid; then
		nodeid=$(repository_get_value nodeid)
    elif [ -z "$nodeid" ]; then 
		# we need to query it
		nodeid=$(cc_find_nodeid $cluster_conf)
		if [ -n "$nodeid" ]; then
			repository_store_value nodeid $nodeid
		else
			return 1
		fi
	fi	
	if [ -z "$nodename" ] && repository_has_key nodename; then
		nodename=$(repository_get_value nodename)
    elif [ -z "$nodename" ]; then
		nodename=$(cc_get_nodename_by_id $cluster_conf $nodeid) 
		if [ -n "$nodename" ]; then
			repository_store_value nodename $nodename
		else
			return 1
		fi
	fi
	# maybe we can find the value in the repository
	if repository_has_key $name; then
		repository_get_value $name
	else
		out=$(cc_get_$name $cluster_conf $nodeid 2>/dev/null)
		[ $? -eq 0 ] && [ -n "$out" ] || out=$(cc_get $cluster_conf $name $nodeid 2>/dev/null)
		[ $? -eq 0 ] && [ -n "$out" ] || out=$(cc_get_$name $cluster_conf $nodename 2>/dev/null)
		[ $? -eq 0 ] && [ -n "$out" ] || out=$(cc_get $cluster_conf $name $nodename 2>/dev/null)
		echo -n $out
		test -n "$out"
	fi
}

#****f* boot-scripts/etc/clusterfs-lib.sh/cluster_ip_config
#  NAME
#    cluster_ip_config
#  SYNOPSIS
#    cluster_ip_config(cluster_conf, nodename)
#  DESCRIPTION
#    returns the following parameters got from the cluster configuration
#      * ipConfig: the ipConfiguration used to do locking
#  SOURCE
function cluster_ip_config {
  local cluster_conf=$1
  local nodename=$2
  local nodeid=$4

  for _dev in $(cc_get_netdevs "${cluster_conf}" $nodename); do
    cc_auto_netconfig "${cluster_conf}" "$nodename" "$_dev" "$nodeid"
  done
}
#******** cluster_ip_config

#****f* clusterfs-lib.sh/cc_validate
#  NAME
#    cc_validate
#  SYNOPSIS
#    function cc_validate(cluster_conf)
#  DESCRIPTION
#    validates the cluster configuration. 
#  SOURCE
function cc_validate {
  local clutype=$(repository_get_value clutype)
  ${clutype}_validate $*
}
#*********** cc_validate

#****f* clusterfs-lib.sh/cc_get_clustername
#  NAME
#    cc_get_clustername
#  SYNOPSIS
#    function cc_get_clustername([cluster_conf])
#  DESCRIPTION
#    Returns clustername. 
#  SOURCE
cc_get_clustername() {
  local clutype=$(repository_get_value clutype)
  ${clutype}_get_clustername $@	
}
#************* cc_get_clustername

#****f* clusterfs-lib.sh/cc_convert
#  NAME
#    cc_convert
#  SYNOPSIS
#    function cc_convert([cluster_conf])
#  DESCRIPTION
#    Returns clustername. 
#  SOURCE
cc_convert() {
  local clutype=$(repository_get_value clutype)
  ${clutype}_convert $@	
}
#************* cc_convert

#****f* clusterfs-lib.sh/cc_get_nic_names
#  NAME
#    cc_get_nic_names
#  SYNOPSIS
#    function cc_get_nic_names(cluster_conf)
#  DESCRIPTION
#    Returns the nic drivers for the given node if specified in cluster configuration. 
#  SOURCE
function cc_get_nic_names {
  local clutype=$(repository_get_value clutype)
  ${clutype}_get_nic_names "$1" "$2" "$3" "$4"
}
#*********** cc_get_nic_names

#****f* clusterfs-lib.sh/cc_get_nic_drivers
#  NAME
#    cc_get_nic_drivers
#  SYNOPSIS
#    function cc_get_nic_drivers(cluster_conf)
#  DESCRIPTION
#    Returns the nic drivers for the given node if specified in cluster configuration. 
#  SOURCE
function cc_get_nic_drivers {
  local clutype=$(repository_get_value clutype)
  ${clutype}_get_nic_drivers "$1" "$2" "$3" "$4"
}
#*********** cc_get_nic_drivers

#****f* clusterfs-lib.sh/cc_get_all_drivers
#  NAME
#    cc_get_all_drivers
#  SYNOPSIS
#    function cc_get_all_drivers(cluster_conf)
#  DESCRIPTION
#    Returns the all specified drivers for all nodes if specified in cluster configuration. 
#  SOURCE
function cc_get_all_drivers {
  local clutype=$(repository_get_value clutype)
  local rootfs=$(repository_get_value rootfs)
  ${clutype}_get_all_drivers "$1" "$2" "$3" "$4"
  cc_get_cluster_drivers
  if [ "$clutype" != "$rootfs" ]; then 
    clusterfs_get_drivers
  fi
}
#*********** cc_get_all_drivers

#****f* clusterfs-lib.sh/cc_get_cluster_drivers
#  NAME
#    cc_get_cluster_drivers
#  SYNOPSIS
#    function cc_get_cluster_drivers(cluster_conf)
#  DESCRIPTION
#    Returns the all drivers for this clustertype. 
#  SOURCE
function cc_get_cluster_drivers {
  ${clutype}_get_drivers
}
#*********** cc_get_cluster_drivers

#****f* clusterfs-lib.sh/cc_find_nodeid
#  NAME
#    cc_find_nodeid
#  SYNOPSIS
#    function cc_find_nodeid(cluster_conf)
#  DESCRIPTION
#    try to find the nodeid of this node
#  NOTE
#    Must not be overwritten by cluster implementation 
#  SOURCE
function cc_find_nodeid {
	local cluster_conf=$1
	local hwids=$(repository_get_value hardwareids)
	[ -z "$macs" ] && macs=$(ifconfig -a | grep -i hwaddr | awk '{print $5;};')
	for hwid in $hwids; do
		local mac=$(echo "$hwid" | cut -f2- -d:)
    	local nodeid=$(cc_get_nodeid ${cluster_conf} $mac 2>/dev/null)
    	if [ -n "$nodeid" ]; then
    		break
    	fi
  	done
	if [ -z "$nodeid" ]; then
		return 1
	fi
	echo $nodeid
	return 0  
}
#******* cc_get_nodeid

#****f* boot-scripts/etc/clusterfs-lib.sh/cc_getdefaults
#  NAME
#    cc_getdefaults
#  SYNOPSIS
#    cc_getdefaults(parameter)
#  DESCRIPTION
#    returns defaults for the specified cluster. Parameter must be given to return the apropriate default
#  SOURCE
function cc_getdefaults {
  local clutype=$(repository_get_value clutype)
  ${clutype}_getdefaults $*
}
#********** cc_getdefaults

#****f* clusterfs-lib.sh/cc_get
#  NAME
#    cc_get
#  SYNOPSIS
#    function cc_get query
#  DESCRIPTION
#    gets a value generically
#  SOURCE
function cc_get {
  local clutype=$(repository_get_value clutype)

  ${clutype}_get $@
}
#******* cc_get

#****f* clusterfs-lib.sh/cc_get_nodeids
#  NAME
#    cc_get_nodeids
#  SYNOPSIS
#    function cc_get_nodeids(cluster_conf, netdev)
#  DESCRIPTION
#    gets the nodeid of this node referenced by the networkdevice
#  SOURCE
function cc_get_nodeids {
  local cluster_conf=$1
  local clutype=$(repository_get_value clutype)

  ${clutype}_get_nodeids $cluster_conf
}
#******* cc_get_nodeids

#****f* clusterfs-lib.sh/cc_get_macs
#  NAME
#    cc_get_macs
#  SYNOPSIS
#    function cc_get_macs(cluster_conf, netdev)
#  DESCRIPTION
#    gets the nodeid of this node referenced by the networkdevice
#  SOURCE
function cc_get_macs {
  local cluster_conf=$1
  local clutype=$(repository_get_value clutype)

  ${clutype}_get_macs $cluster_conf
}
#******* cc_get_macs

#****f* clusterfs-lib.sh/cc_get_nodeid
#  NAME
#    cc_get_nodeid
#  SYNOPSIS
#    function cc_get_nodeid(cluster_conf, netdev)
#  DESCRIPTION
#    gets the nodeid of this node referenced by the networkdevice
#  SOURCE
function cc_get_nodeid {
  local cluster_conf=$1
  local mac=$2
  local clutype=$(repository_get_value clutype)

  ${clutype}_get_nodeid $cluster_conf $mac
}
#******* cc_get_nodeid

#****f* clusterfs-lib.sh/cc_get_nodename_by_id
#  NAME
#    cc_get_nodename_by_id
#  SYNOPSIS
#    function cc_get_nodename_by_id(cluster_conf, id)
#  DESCRIPTION
#    gets the nodename of this node referenced by the nodeid
#  SOURCE
function cc_get_nodename_by_id {
  local cluster_conf=$1
  local id=$2
  local clutype=$(repository_get_value clutype)

  ${clutype}_get_nodename_by_id $cluster_conf $id
}
#******** cc_get_nodename_by_id

#****f* clusterfs-lib.sh/cc_get_rootvolume
#  NAME
#    cc_get_rootvolume
#  SYNOPSIS
#    function cc_get_rootvolume(cluster_conf, nodename)
#  DESCRIPTION
#    gets the nodename of this node referenced by the networkdevice
#  SOURCE
function cc_get_rootvolume {
  local cluster_conf=$1
  local nodename=$2
  local clutype=$(repository_get_value clutype)

  ${clutype}_get_rootvolume $cluster_conf $nodename
}
#******** cc_get_rootvolume

#****f* clusterfs-lib.sh/cc_get_rootsource
#  NAME
#    cc_get_rootsource
#  SYNOPSIS
#    function cc_get_rootsource(cluster_conf, nodename)
#  DESCRIPTION
#    gets the nodename of this node referenced by the networkdevice
#  SOURCE
function cc_get_rootsource {
  local cluster_conf=$1
  local nodename=$2
  local clutype=$(repository_get_value clutype)

  ${clutype}_get_rootsource $cluster_conf $nodename
}
#******** cc_get_rootsource

#****f* clusterfs-lib.sh/cc_get_rootfs
#  NAME
#    cc_get_rootfs
#  SYNOPSIS
#    function cc_get_rootfs(cluster_conf, nodename)
#  DESCRIPTION
#    gets the rootfs type of this node referenced by the networkdevice
#  SOURCE
function cc_get_rootfs {
  local cluster_conf=$1
  local nodename=$2
  local clutype=$(repository_get_value clutype)

  ${clutype}_get_rootfs $cluster_conf $nodename
}
#******** cc_get_rootfs

#****f* clusterfs-lib.sh/cc_get_userspace_procs
#  NAME
#    cc_get_userspace_procs
#  SYNOPSIS
#    function cc_get_userspace_procs(cluster_conf, nodename)
#  DESCRIPTION
#    gets userspace programs that are to be running dependent on rootfs
#  SOURCE
function cc_get_userspace_procs {
  local clutype=$1
  [ -z "$clutype" ] && clutype=$(repository_get_value clutype)

  typeset -f ${clutype}_get_userspace_procs >/dev/null 2>/dev/null
  if [ $? -eq 0 ]; then
    ${clutype}_get_userspace_procs $*
  fi
}
#******** cc_get_userspace_procs

#****f* clusterfs-lib.sh/cc_get_mountopts
#  NAME
#    cc_get_mountopts
#  SYNOPSIS
#    function cc_get_mountopts(cluster_conf, nodename)
#  DESCRIPTION
#    gets the nodename of this node referenced by the networkdevice
#  SOURCE
function cc_get_mountopts {
  local cluster_conf=$1
  local nodename=$2
  local rootfs=$(repository_get_value rootfs)
  local clutype=$(repository_get_value clutype)
   
  typeset -f ${rootfs}_get_mountopts >/dev/null 2>/dev/null
  if [ $? -eq 0 ]; then
    ${rootfs}_get_mountopts $cluster_conf $nodename
  else
    ${rootfs}_getdefaults mountopts
  fi
}
#******** cc_get_mountopts

#****f* clusterfs-lib.sh/cc_get_chroot_mountpoint
#  NAME
#    cc_get_chroot_mountpoint
#  SYNOPSIS
#    function cc_get_chrootmountpoint(cluster_conf, nodename)
#  DESCRIPTION
#    gets the mountpoint for the chroot environment of this node referenced by the networkdevice
#    default is /comoonics
#  SOURCE
function cc_get_chroot_mountpoint {
  local cluster_conf=$1
  local nodename=$2
  local clutype=$(repository_get_value clutype)

  local mp=$(${clutype}_get_chroot_mountpoint $cluster_conf $nodename)
  if [ -n "$mp" ]; then
     echo $mp
  else
     echo $DFLT_CHROOT_MOUNT
  fi
}
#******** cc_get_chroot_mountpoint


#****f* clusterfs-lib.sh/cc_get_chroot_fstype
#  NAME
#    cc_get_chroot_mountpoint
#  SYNOPSIS
#    function cc_get_chrootfstype(cluster_conf, nodename)
#  DESCRIPTION
#    gets the filesystem type for the chroot environment of this node referenced by the networkdevice
#    defaults to tmpfs
#  SOURCE
function cc_get_chroot_fstype {
  local cluster_conf=$1
  local nodename=$2
  local clutype=$(repository_get_value clutype)

  local fs=$(${clutype}_get_chroot_fstype $cluster_conf $nodename)
  if [ -n "$fs" ]; then
     echo $fs
  else
     echo "tmpfs"
  fi
}
#******** cc_get_chroot_fstype

#****f* clusterfs-lib.sh/cc_get_chroot_device
#  NAME
#    cc_get_chroot_device
#  SYNOPSIS
#    function cc_get_chrootdevice(cluster_conf, nodename)
#  DESCRIPTION
#    gets the device for the chroot environment of this node referenced by the networkdevice
#    defaults to nobe
#  SOURCE
function cc_get_chroot_device {
  local cluster_conf=$1
  local nodename=$2
  local clutype=$(repository_get_value clutype)

  local dev=$(${clutype}_get_chroot_device $cluster_conf $nodename)
  if [ -n "$dev" ]; then
    echo $dev
  else
    echo "none"
  fi
}
#******** cc_get_chroot_device

#****f* clusterfs-lib.sh/cc_get_chroot_mountopts
#  NAME
#    cc_get_chroot_mountopts
#  SYNOPSIS
#    function cc_get_chrootmountopts(cluster_conf, nodename)
#  DESCRIPTION
#    gets the mount options for the chroot environment of this node referenced by the networkdevice
#    defaults to defaults
#  SOURCE
function cc_get_chroot_mountopts {
  local cluster_conf=$1
  local nodename=$2
  local clutype=$(repository_get_value clutype)

  local mo=$(${clutype}_get_chroot_mountopts $cluster_conf $nodename)
  if [ -n "$mo" ]; then
     echo $mo
  else
     echo "defaults"
  fi
}
#******** cc_get_chroot_mountopts

#****f* clusterfs-lib.sh/cc_get_chroot_dir
#  NAME
#    cc_get_chroot_dir
#  SYNOPSIS
#    function cc_get_chroot_dir(cluster_conf, nodename)
#  DESCRIPTION
#    gets the directory (including mounpoint) for the chroot environment of this node referenced by the networkdevice
#    defaults to cc_get_chroot_mountpoint
#  SOURCE
function cc_get_chroot_dir {
  local cluster_conf=$1
  local nodename=$2
  local clutype=$(repository_get_value clutype)

  local dir=$(${clutype}_get_chroot_dir $cluster_conf $nodename)
  if [ -n "$dir" ]; then
     echo $dir
  else
     cc_get_chroot_mountpoint $cluster_conf $nodename
  fi
}
#******** cc_get_chroot_dir

#****f* clusterfs-lib.sh/cc_get_syslogserver
#  NAME
#    cc_get_syslogserver
#  SYNOPSIS
#    function cc_get_syslogserver(cluster_conf, nodename)
#  DESCRIPTION
#    Returns the syslog server set in the cluster
#  SOURCE
cc_get_syslogserver() {
  local clutype=$(repository_get_value clutype)
  ${clutype}_get_syslogserver $@
}
#*************** cc_get_syslogserver

#****f* clusterfs-lib.sh/cc_get_syslogfilter
#  NAME
#    cc_get_syslogfilter
#  SYNOPSIS
#    function cc_get_syslogfilter(cluster_conf, nodename)
#  DESCRIPTION
#    Returns the syslog server set in the cluster
#  SOURCE
cc_get_syslogfilter() {
  local clutype=$(repository_get_value clutype)
${clutype}_get_syslogfilter $@
}
#*************** cc_get_syslogfilter

#****f* clusterfs-lib.sh/cc_init
#  NAME
#    cc_init
#  SYNOPSIS
#    function cc_init( start|stop|restart clutype CHROOT_PATH [opts])
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function cc_init {
  local proc=
  local clutype=$3
  [ -z "$clutype" ] && clutype=$(repository_get_value clutype)

  typeset -f ${clutype}_init >/dev/null 2>/dev/null
  if [ $? -eq 0 ]; then
    ${clutype}_init $*
  fi
  return 0
}
#********* cc_init

#****f* clusterfs-lib.sh/cc_get_scsifailover
#  NAME
#    cc_get_scsifailover
#  SYNOPSIS
#    function cc_get_scsifailover(cluster_conf, nodename)
#  DESCRIPTION
#    gets the nodename of this node referenced by the networkdevice
#  SOURCE
function cc_get_scsifailover {
  local cluster_conf=$1
  local nodename=$2
  local clutype=$(repository_get_value clutype)

  ${clutype}_get_scsifailover $cluster_conf $nodename
}
#******** cc_get_scsifailover

#****f* clusterfs-lib.sh/cc_get_netdevs
#  NAME
#    cc_get_netdevs
#  SYNOPSIS
#    function cc_get_netdevs(cluster_conf, nodename)
#  DESCRIPTION
#    gets the network devcices of this node referenced by the networkdevice
#  SOURCE
function cc_get_netdevs {
  local cluster_conf=$1
  local nodename=$2
  local nodeid=$3
  local clutype=$(repository_get_value clutype)

  ${clutype}_get_netdevs $cluster_conf $nodename
}
#******** cc_get_netdevs

#****f* clusterfs-lib.sh/cc_auto_netconfig
#  NAME
#    cc_auto_netconfig
#  SYNOPSIS
#    function cc_auto_netconfig(cluster_conf, nodename, netdev)
#  DESCRIPTION
#    gets the network devcices of this node referenced by the networkdevice
#    The return syntax for ip is as follows:
#    cc_auto_netconfig=> {ipaddr} :        :{gateway}:{netmask}::{netdev}:{mac_addr}:{type}:{bridge}:{onboot}:{driver}:({property:name=value}':')+ |
#                                 :{master}:{slave}  :         ::{netdev}:{mac_addr}:{type}:{bridge}:{onboot}:{driver}:({attrs:name=value}':')+
#  SOURCE
function cc_auto_netconfig {
  local cluster_conf=$1
  local nodename=$2
  local netdev=$3
  local nodeid=$4
  local clutype=$(repository_get_value clutype)

  typeset -f ${clutype}_auto_netconfig &>/dev/null
  # this is the old way you should not need to implement ${clutype}_auto_netconfig
  if [ $? -eq 0 ]; then
    ${clutype}_auto_netconfig $cluster_conf $nodename $netdev
  else
    if [ -z "$netdev" ]; then netdev="eth0"; fi

    local ip_addr=$(cc_get $cluster_conf ip $nodeid $netdev 2>/dev/null)
    local mac_addr=$(cc_get $cluster_conf eth_name_mac $nodeid $netdev 2>/dev/null)
    local type=$(cc_get $cluster_conf eth_name_type $nodeid $netdev 2>/dev/null)
    local bridge=$(cc_get $cluster_conf eth_name_bridge $nodeid $netdev 2>/dev/null)
    local onboot=$(cc_get $cluster_conf eth_name_onboot $nodeid $netdev 2>/dev/null)
    local driver=$(cc_get $cluster_conf eth_name_driver $nodeid $netdev 2>/dev/null)
    local properties=$(cc_get $cluster_conf eth_name_properties $nodeid $netdev 2>/dev/null | tr " " ":")
    if [ -z "$onboot" ]; then
  	  onboot="yes"
    fi 
    if [ -z "$mac_addr" ]; then
  	  local mac_addr=$(ip addr show $netdev scope link 2>/dev/null | grep link/ether | awk '{print $2;}')
    fi
    mac_addr=${mac_addr//:/-}
    if [ "$ip_addr" != "" ]; then
      local gateway=$(cc_get $cluster_conf eth_name_gateway $nodeid $netdev 2>/dev/null) || local gateway=""
      local netmask=$(cc_get $cluster_conf eth_name_mask $nodeid $netdev 2>/dev/null)
      echo ${ip_addr}"::"${gateway}":"${netmask}"::"$netdev":"$mac_addr":"$type":"$bridge":"$onboot":"$driver":"$properties
    else
      local master=$(cc_get $cluster_conf eth_name_master $nodeid $netdev 2>/dev/null)
      local slave=$(cc_get $cluster_conf eth_name_slave $nodeid $netdev 2>/dev/null)
      echo ":"${master}":"${slave}":::"${netdev}":"${mac_addr}":"${type}":"${bridge}":"$onboot":"$driver":"$properties
    fi
  fi
}
#******** cc_auto_netconfig

#****f* clusterfs-lib.sh/cc_auto_hosts
#  NAME
#    cc_auto_hosts
#  SYNOPSIS
#    function cc_auto_hosts(cluster_conf)
#  DESCRIPTION
#    gets the network devcices of this node referenced by the networkdevice
#  SOURCE
function cc_auto_hosts {
  local cluster_conf=$1
  local clutype=$(repository_get_value clutype)

  cp /etc/hosts /etc/hosts.bak
  ${clutype}_auto_hosts "$cluster_conf" /etc/hosts.bak > /etc/hosts
}
#******** cc_auto_hosts

#****f* clusterfs-lib.sh/cc_auto_syslogconfig
#  NAME
#    cc_auto_syslogconfig
#  SYNOPSIS
#    function cc_auto_syslogconfig(cluster_conf, nodename, chroot_path, locallog, syslog_logfile)
#  DESCRIPTION
#    creates config for the syslog service
#    to enable local logging use "yes"
#    It will also detect the different syslog implementations and start the apropriate syslogservers
#  SOURCE
function cc_auto_syslogconfig {
  local cluster_conf=$1
  local nodename=$2
  local chroot_path=$3
  local local_log=$4
  local syslog_logfile=$5
  local clutype=$(repository_get_value clutype)
  local syslog_type=$(repository_get_value syslog_type)
  local syslog_template
  local syslog_server=""
  local syslog_filter

  if [ -z "$syslog_type" ]; then
  	syslog_type=$(detect_syslog 2>/dev/null)
  	if [ -z "$syslog_type" ]; then
  		warn "Could not detect syslog type either no syslog installed in initrd or no syslog bootimage package installed."
  		return 1
  	fi
  fi
  repository_store_value syslogtype "$syslog_type"
  
  if [ -z "$syslog_logfile" ]; then
    syslog_logfile=$(repository_get_value syslog_logfile)
    if [ -z "$syslog_logfile" ]; then
      syslog_logfile="/var/log/comoonics-boot.syslog"
    fi
  fi
  if [ -n "$cluster_conf" ] && [ -n "$nodename" ]; then
    syslog_server=$(getParameter syslogserver 2>/dev/null)
    syslog_filter=$(getParameter syslogfilter 2>/dev/null)
  fi
  [ -z "$syslog_filter" ] && syslog_filter="kern.*"
  repository_store_value syslogfilter "$syslog_filter"

  if [ -n "$syslog_type" ]; then
    syslog_template=$(getParameter syslogtemplate $(${clutype}_get_syslogtemplate $cluster_conf $nodename 2>/dev/null) 2>/dev/null)
	if [ -z "$syslog_template" ]; then
		syslog_template="/etc/templates/${syslog_type}.conf"
	fi
	repository_store_value syslogtemplate $syslog_template
    
    echo_local -n "Creating syslog config for syslog destinations: $syslog_filter:$syslog_server"
    mkdir -p $(dirname $(repository_get_value syslogconf $(default_syslogconf $syslog_type)))
    exec_local $(echo ${syslog_type} | tr '-' '_')_config $syslog_template "$syslog_filter:$syslog_server" > $(repository_get_value syslogconf $(default_syslogconf $syslog_type))
    return_code

    local services=$(repository_get_value servicesfile "/etc/services")
    echo "syslog          514/udp" >> ${chroot_path}${services}
  fi
  [ -n "$syslog_type" ]
}
#******** cc_auto_syslogconfig

#****f* clusterfs-lib.sh/cc_syslog_start
#  NAME
#    cc_syslog_start
#  SYNOPSIS
#    function cc_syslog_start(chroot_path)
#  DESCRIPTION
#    Starts the apropriate syslogd as required
#  SOURCE
function cc_syslog_start {
	local syslog_type=$(repository_get_value syslogtype)
	
	if [ -n "$syslog_type" ]; then
	  echo_local -n "Starting syslog server $syslog_type "
	  $(echo ${syslog_type} | tr '-' '_')_start $*
	  return_code $?
	else
	  return 1
	fi
}
#******** cc_syslog_start

#****f* clusterfs-lib.sh/cc_auto_getbridges
#  NAME
#    cc_auto_getbridges
#  SYNOPSIS
#    function cc_auto_getbridges(cluster_conf, nodename)
#  DESCRIPTION
#    gets all bridgenames defined for the cluster and need for the cluster
#  SOURCE
function cc_auto_getbridges {
  local cluster_conf=$1
  local nodename=$2
  local clutype=$(repository_get_value clutype)

  typeset -f ${clutype}_get_bridges >/dev/null 2>/dev/null
  if [ $? -eq 0 ]; then
    ${clutype}_get_bridges $cluster_conf $nodename
  else
    return 1
  fi
}
#******** cc_auto_getbridges

function cc_get_bridgename {
  local cluster_conf=$1
  local nodename=$2
  cc_auto_getbridges $cluster_conf $nodename
}
function cc_get_bridgescript {
  local cluster_conf=$1
  local nodename=$2
  local clutype=$(repository_get_value clutype)

  bridgename=$(repository_get_value bridgename)
  ${clutype}_get_bridge_param $cluster_conf $nodename $bridgename script
}
function cc_get_bridgevifnum {
  local cluster_conf=$1
  local nodename=$2
  local clutype=$(repository_get_value clutype)

  bridgename=$(repository_get_value bridgename)
  ${clutype}_get_bridge_param $cluster_conf $nodename $bridgename vifnum
}
function cc_get_bridgenetdev {
  local cluster_conf=$1
  local nodename=$2
  local clutype=$(repository_get_value clutype)

  bridgename=$(repository_get_value bridgename)
  ${clutype}_get_bridge_param $cluster_conf $nodename $bridgename netdev
}
function cc_get_bridgeantispoof {
  local cluster_conf=$1
  local nodename=$2
  local clutype=$(repository_get_value clutype)

  bridgename=$(repository_get_value bridgename)
  ${clutype}_get_bridge_param $cluster_conf $nodename $bridgename antispoof
}

#****f* boot-scripts/etc/clusterfs-lib.sh/clusterfs_getdefaults
#  NAME
#    clusterfs_getdefaults
#  SYNOPSIS
#    clusterfs_getdefaults(parameter)
#  DESCRIPTION
#    returns defaults for the specified filesystem. Parameter must be given to return the apropriate default
#  SOURCE
function clusterfs_getdefaults {
  local rootfs=$(repository_get_value rootfs)
  ${rootfs}_getdefaults $*
}
#********** clusterfs_getdefaults

#****f* clusterfs-lib.sh/clusterfs_load
#  NAME
#    clusterfs_load
#  SYNOPSIS
#    function clusterfs_load(lockmethod)
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function clusterfs_load {
  local rootfs=$(repository_get_value rootfs)
  ${rootfs}_load $*
}
#***** clusterfs_load

#****f* clusterfs-lib.sh/clusterfs_services_start
#  NAME
#    clusterfs_services_start
#  SYNOPSIS
#    function clusterfs_services_start(lockmethod)
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function clusterfs_services_start {
  local rootfs=$(repository_get_value rootfs)
  ${rootfs}_services_start $*
}
#***** clusterfs_services_start

#****f* clusterfs-lib.sh/clusterfs_services_stop
#  NAME
#    clusterfs_services_stop
#  SYNOPSIS
#    function clusterfs_services_stop
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function clusterfs_services_stop {
  local rootfs=$(repository_get_value rootfs)
  ${rootfs}_services_stop $*
}
#***** clusterfs_services_stop

#****f* clusterfs-lib.sh/clusterfs_services_restart
#  NAME
#    clusterfs_services_restart
#  SYNOPSIS
#    function clusterfs_services_restart(lockmethod)
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function clusterfs_services_restart {
  local rootfs=$(repository_get_value rootfs)
  ${rootfs}_services_restart $*
}
#***** clusterfs_services_restart

#****f* clusterfs-lib.sh/clusterfs_services_start_newroot
#  NAME
#    clusterfs_services_start_newroot
#  SYNOPSIS
#    function clusterfs_services_start_newroot($newroot)
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function clusterfs_services_restart_newroot {
  local rootfs=$(repository_get_value rootfs)
  ${rootfs}_services_restart_newroot "$1" "$2" "$3" "$4"
}
#***** clusterfs_services_restart_newroot


#****f* clusterfs-lib.sh/clusterfs_mount
#  NAME
#    clusterfs_mount
#  SYNOPSIS
#    function clusterfs_mount(fstype, dev, mountpoint, mountopts, [tries=1], [waittime=5])
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function clusterfs_mount {
  local fstype=$1
  local dev=$2
  local mountpoint=$3
  local mountopts=$4
  local tries=1
  [ -n "$5" ] && tries=$5
  local waittime=5
  [ -n "$6" ] && waittime=$6
  local i=0

  #TODO: skip device check at least for nfs services
  echo_local -n "Mounting $dev on $mountpoint.."
  if [ ! -e $dev ] && [ "${fstype:0:3}" != "nfs" ] && [ "${fstype}" != "bind" ]  && [ "${fstype}" != "rbind" ]; then
     breakp $(errormsg err_rootfs_device)
  fi
  if [ ! -d $mountpoint ]; then
    mkdir -p $mountpoint
  fi
  echo_local_debug -N -n "tries: $tries, waittime: $waittime "
  while [ $i -lt $tries ]; do
  	echo_local -N -n "."
  	let i=$i+1
  	sleep $waittime
  	return_c=0
  	[ -n "$mountopts" ] && mountopts="-o $mountopts"
  	[ -n "$fstype" ] && ! [ "$fstype" = "bind" ] && fstype="-t $fstype"
  	[ "$fstype" = "bind" ] && fstype="--$fstype"
  	exec_local mount $fstype $mountopts $dev $mountpoint && break
  	return_c=$?
  done
  return_code $return_c
}
#***** clusterfs_mount

#****f* clusterfs-lib.sh/clusterfs_get_userspace_procs
#  NAME
#    clusterfs_get_userspace_procs
#  SYNOPSIS
#    function clusterfs_get_userspace_procs(cluster_conf, nodename)
#  DESCRIPTION
#    gets userspace programs that are to be running dependent on rootfs
#  SOURCE
function clusterfs_get_userspace_procs {
  local rootfs=$1
  [ -z "$rootfs" ] && rootfs=$(repository_get_value rootfs)

  typeset -f ${rootfs}_get_userspace_procs >/dev/null 2>/dev/null
  if [ $? -eq 0 ]; then
    ${rootfs}_get_userspace_procs $*
  fi
}
#******** clusterfs_get_userspace_procs

#****f* clusterfs-lib.sh/clusterfs_init
#  NAME
#    clusterfs_init
#  SYNOPSIS
#    function clusterfs_init(start|stop|restart) rootfs CHROOT_PATH
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function clusterfs_init {
  local proc=
  local rootfs=$3
  [ -z "$rootfs" ] && rootfs=$(repository_get_value rootfs)

  typeset -f ${rootfs}_init >/dev/null 2>/dev/null
  if [ $? -eq 0 ]; then
    ${rootfs}_init $*
  fi
  for proc in $(clusterfs_get_userspace_procs); do
	touch /var/lock/subsys/$(echo $proc | sed -e s/[-_.]//g)
  done
  return 0
}
#********* clusterfs_init


#****f* clusterfs-lib.sh/cluster_restart_cluster_services
#  NAME
#    cluster_restart_cluster_services
#  SYNOPSIS
#    function cluster_restart_cluster_services(old_root, new_root)
#  DESCRIPTION
#    Function restarts the ccsd and fenced for removing the deps on /initrd
#  IDEAS
#  SOURCE
#
function cluster_restart_cluster_services {
  local rootfs=$(repository_get_value rootfs)
  ${rootfs}_restart_cluster_services $1 $2
}
#******** cluster_restart_cluster_services

#****f* clusterfs-lib.sh/cluster_checkhosts_alive
#  NAME
#    cluster_checkhosts_alive
#  SYNOPSIS
#    function cluster_checkhosts_alive()
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function cluster_checkhosts_alive {
  local rootfs=$(repository_get_value rootfs)
  ${rootfs}_checkhosts_alive
}
#********* cluster_checkhosts_alive

#****f* clusterfs-lib.sh/clusterfs_mount_cdsl
#  NAME
#    clusterfs_mount_cdsl
#  SYNOPSIS
#    function clusterfs_mount_cdsl(mountpoint, cdsl_dir, nodeid, prefix="/cluster/cdsl", bindtype="rbind")
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function clusterfs_mount_cdsl {
  local mountpoint=$1
  local cdsl_dir=$2
  local nodeid=$3
  local prefix="/cluster/cdsl"
  if [ -n "$4" ]; then
    prefix=$4
  fi
  local bindtype="rbind"
  [ -n "$5" ] && local bindtype="$5"

  echo_local -n "Mounting $cdsl_dir on ${prefix}/${nodeid}.."
  if [ ! -d ${mountpoint}/${prefix} ]; then
    echo_local "no cdsldir found \"${mountpoint}/${prefix}\""
    warning
  fi
  exec_local mount --${bindtype} ${mountpoint}/${prefix}/${nodeid} ${mountpoint}/${cdsl_dir}
  return_code
}
#***** clusterfs__mount_cdsl

#****f* clusterfs-lib.sh/clusterfs_chroot_needed
#  NAME
#    clusterfs_chroot_needed
#  SYNOPSIS
#    clusterfs_chroot_needed "initrd"*|"init"
#  IDEAS
#    Should just cascade to ${rootfs_chroot_needed} $* and return 0 to indicate that
#    by a chroot is always needed. Defaults to 0
function clusterfs_chroot_needed {
  local rootfs=$(repository_get_value rootfs)
  typeset -f ${rootfs}_chroot_needed >/dev/null
  if [ $? -eq 0 ]; then
    ${rootfs}_chroot_needed $*
    return $?
  else
    return 0
  fi
}
#***** clusterfs_chroot_needed

#****f* clusterfs-lib.sh/clusterfs_fsck_needed
#  NAME
#    clusterfs_fsck_needed
#  SYNOPSIS
#    clusterfs_fsck_needed root rootfs
#  IDEAS
#    Will check if the rootfilesystem needs to be checked. 0 on success 1 otherwise. 
#    Has to be implemented by the rootfslib with the function ${rootfs}_fsck_needed
function clusterfs_blkstorage_needed {
  local rootfs="$1"
  [ -z "$rootfs" ] && rootfs=$(repository_get_value rootfs)
  typeset -f ${rootfs}_blkstorage_needed >/dev/null
  if [ $? -eq 0 ]; then
    ${rootfs}_blkstorage_needed $*
    return $?
  else
    return 0
  fi
}
#************* clusterfs_rootfs_needed
	
#****f* clusterfs-lib.sh/clusterfs_fsck_needed
#  NAME
#    clusterfs_fsck_needed
#  SYNOPSIS
#    clusterfs_fsck_needed root rootfs
#  IDEAS
#    Will check if the rootfilesystem needs to be checked. 0 on success 1 otherwise. 
#    Has to be implemented by the rootfslib with the function ${rootfs}_fsck_needed
function clusterfs_fsck_needed {
  local root="$1"
  local rootfs="$2"
  [ -z "$root" ] && root=$(repository_get_value root)
  [ -z "$rootfs" ] && rootfs=$(repository_get_value rootfs)
  typeset -f ${rootfs}_fsck_needed >/dev/null
  if [ $? -eq 0 ]; then
    ${rootfs}_fsck_needed $*
    return $?
  else
    return 1
  fi
}
#************* clusterfs_rootfs_needed

#****f* clusterfs-lib.sh/clusterfs_fsck
#  NAME
#    clusterfs_fsck
#  SYNOPSIS
#    clusterfs_fsck root rootfs
#  IDEAS
#    Will autocheck the rootfilesystem if implemented. 
#    Has to be implemented by the rootfslib with the function ${rootfs}_fsck
function clusterfs_fsck {
  local root="$1"
  local rootfs="$2"
  [ -z "$root" ] && root=$(repository_get_value root)
  [ -z "$rootfs" ] && rootfs=$(repository_get_value rootfs)
  typeset -f ${rootfs}_fsck >/dev/null
  if [ $? -eq 0 ]; then
    ${rootfs}_fsck $*
    return $?
  else
    return 1
  fi
}
#************* clusterfs_rootfs_needed

#****f* clusterfs-lib.sh/clusterfs_get_drivers
#  NAME
#    clusterfs_get_drivers
#  SYNOPSIS
#    function clusterfs_get_drivers()
#  DESCRIPTION
#    Returns the all drivers for this clusterfs. 
#  SOURCE
function clusterfs_get_drivers {
  local rootfs="$1"

  [ -z "$rootfs" ] && rootfs=$(repository_get_value rootfs)
  ${rootfs}_get_drivers
}
#*********** clusterfs_get_drivers

#****f* clusterfs-lib.sh/copy_relevant_files
#  NAME
#    copy_relevant_files
#  SYNOPSIS
#    function copy_relevant_files(cdsl_local_dir, newroot)
#  MODIFICATION HISTORY
#     HAS TO BE MADE DISTRIBUTION DEPENDENT!!
#     WILL NOT WORK WITH OTHER DISTROS!!!!!!
#  IDEAS
#  SOURCE
#
function copy_relevant_files {
  local cdsl_local_dir=$1
  local newroot=$2
  local netdevs=$3

  # backup old files
  olddir=$(pwd)
  return_c=1
  echo_local -n "Backing up created config files [$cdsl_local_dir]"
  if [ ! -L $newroot/etc/sysconfig/hwconf ]; then
    exec_local mv -f $newroot/etc/sysconfig/hwconf $newroot/etc/sysconfig/hwconf.com_back
  fi && /bin/true
  return_code_passed $?

  return_c=1
  echo_local -n "Creating config dirs if not exist.."
  if [ ! -d $newroot/${cdsl_local_dir}/etc ]; then
    mkdir -p $newroot/${cdsl_local_dir}/etc
  fi &&
  if [ ! -d $newroot/${cdsl_local_dir}/etc/sysconfig ]; then
    exec_local mkdir -p $newroot/${cdsl_local_dir}/etc/sysconfig
  fi && /bin/true
  return_code_passed $?

  echo_local -n "Copying the configfiles ${cdsl_local_dir}.."
  cd $newroot/${cdsl_local_dir}/etc
  cp -f $modules_conf $newroot/${cdsl_local_dir}/$modules_conf &&
  ([ -n "$cdsl_local_dir" ] &&
   cd $newroot/etc &&
   ln -sf ../${cdsl_local_dir}/$modules_conf $(basename $modules_conf))
  return_c=$?
  if [ -L ${newroot}/${cdsl_local_dir}/etc/cluster ]; then
    rm -f ${newroot}/${cdsl_local_dir}/etc/cluster && mkdir ${newroot}/${cdsl_local_dir}/etc/cluster
  fi
  if [ -f ${newroot}/${cdsl_local_dir}/etc/cluster/cluster.conf ]; then
    cp -f ${new_root}/${cdsl_local_dir}/etc/cluster/cluster.conf ${newroot}/${cdsl_local_dir}/etc/cluster/cluster.conf.bak
  fi
  cp /etc/cluster/cluster.conf ${newroot}/${cdsl_local_dir}/etc/cluster/cluster.conf
  [ $return_c -eq 0 ] && return_c=$?
#   cd sysconfig
#   cp -f /etc/sysconfig/hwconf $newroot/${cdsl_local_dir}/etc/sysconfig/
#    [ ! -f ${newroot}/etc/sysconfig/hwconf ] &&
#    cd $newroot &&
#    ln -fs ${cdsl_local_dir}/etc/sysconfig/hwconf etc/sysconfig/hwconf)
  return_code=$return_c
  echo_local -N -n ".(hw $return_c)."
#  cd $newroot
#  for netdev in $netdevs; do
#    cp -f /etc/sysconfig/network-scripts/ifcfg-$netdev $newroot/${cdsl_local_dir}/etc/sysconfig/network-scripts/ifcfg-$netdev &&
#    cd ${newroot}/etc/sysconfig/network-scripts &&
#    ln -sf ../../../${cdsl_local_dir}/etc/sysconfig/network-scripts/ifcfg-$netdev ifcfg-$netdev
#    __ret=$?
#    [ $return_code -eq 0 ] && return_code=$__ret
#    echo_local -n ".($dev $return_c $__ret)."
#  done
  return_code_warning
}
#************ copy_relevant_files


# $Log: clusterfs-lib.sh,v $
# Revision 1.45  2010-03-08 13:08:36  marc
# bug in getClusterParameter that would not return in special cases.
#
# Revision 1.44  2010/02/21 12:00:23  marc
# added default for querymap
#
# Revision 1.43  2010/02/17 09:45:43  marc
# typedef => typeset in getCluType fixed for type osr
#
# Revision 1.42  2010/02/07 20:34:35  marc
# - removed osr-lib deps.
#
# Revision 1.41  2010/02/05 12:34:12  marc
# - global parameters (cdsl_local_dir, cdsl_prefix) will only be defined if not already defined.
# - cc_init: gets clusterconf as optional parameter
# - clusterfs_mount: bind mounts are also working when called, return_code returned
# - clusterfs_init: will get parameters
# - clusterfs_mount_cdsl: default rbind is used;
#
# Revision 1.40  2010/01/11 10:03:55  marc
# corrected typos
#
# Revision 1.39  2010/01/04 13:06:08  marc
# getCluType: support for osr cluster
# getClusterParameter: Test compatible, also accepts nodename and nodeid
# cluster_ip_config: Support for nodeid
# clusterfs_config: obsolete, removed
# cc_find_nodeid: docu
# cc_get: docu
# cc_get_nodeid:obsolete, removed
# cc_get_clu_nodename:obsolete, removed
# cc_get_nodename:obsolete, removed
# cc_get_mountopts: is dependent on rootfs not on clutype
# cc_get_netdevs: nodeid might also be passed
# cc_auto_netconfig: moved from gfs-lib.sh to here as it is cluster independent and added query for properties
# cc_auto_hosts: typo
# cc_auto_getbridges: optional to be implemented (by cluster)
# clusterfs_mount: cosmetics
#
# Revision 1.38  2009/12/09 09:08:49  marc
# typo in cc_get
#
# Revision 1.37  2009/09/28 12:53:13  marc
# - added functions
#   cc_get
#   cc_get_syslog*
# - changed and implemented syslog functionality to support different types of syslog (rsyslogd, syslog-ng, syslogd)
#
# Revision 1.36  2009/04/20 07:07:26  marc
# - bugfixes
# - added cc_init and clusterfs_init
#
# Revision 1.35  2009/04/14 14:53:47  marc
# - added cc_get_userspace_procs and clusterfs_get_userspace_procs
# - fixed syslog/klog bug and changed default loglevel for console only if debug is on
#
# Revision 1.34  2009/03/25 13:50:26  marc
# - added get_drivers functions to return modules in more general
# - fixed Bug 338 (klogd not being started in initrd)
#
# Revision 1.33  2009/02/24 20:37:20  marc
# rollback to older version
#
# Revision 1.32  2009/02/24 11:58:19  marc
# added cc_get_nic_drives
#
# Revision 1.31  2009/02/18 17:57:45  marc
# setup default syslog file
#
# Revision 1.30  2009/02/02 20:12:09  marc
# - Bugfix in hardware detection
# - Introduced function to not load storage when not needed
#
# Revision 1.29  2009/01/29 15:57:03  marc
# Upstream with new HW Detection see bug#325
#
# Revision 1.28  2009/01/28 12:52:11  marc
# Many changes:
# - moved some functions to std-lib.sh
# - no "global" variables but repository
# - bugfixes
# - support for step with breakpoints
# - errorhandling
# - little clean up
# - better seperation from cc and rootfs functions
#
# Revision 1.27  2008/12/01 11:22:47  marc
# fixed Bug #300 that clutype is setup where it should not
#
# Revision 1.26  2008/10/28 12:52:07  marc
# fixed bug#288 where default mountoptions would always include noatime,nodiratime
#
# Revision 1.25  2008/10/14 10:57:07  marc
# Enhancement #273 and dependencies implemented (flexible boot of local fs systems)
#
# Revision 1.24  2008/08/14 13:37:35  marc
# - added bridge functions
# - added cc_getdefaults
# - rewrote getCluType
#
# Revision 1.23  2008/07/03 12:43:39  mark
# add new methods to support generic getParameter method
#
# Revision 1.22  2008/06/20 13:42:46  mark
# fixes some comments
#
# Revision 1.21  2008/06/10 09:54:31  marc
# - beautified syslog handling
# - removed gfs dependencies towards more generic approach
#
# Revision 1.20  2008/05/17 08:30:41  marc
# changed the way the /etc/hosts is created a little bit.
#
# Revision 1.19  2008/01/24 13:27:41  marc
# default rootsource should be scsi
#
# Revision 1.18  2007/12/07 16:39:59  reiner
# Added GPL license and changed ATIX GmbH to AG.
#
# Revision 1.17  2007/10/16 08:00:11  marc
# - added basic rootsource support
#
# Revision 1.16  2007/10/10 12:18:31  mark
# redesigned cc_auto_syslogconfig to support diffrent configurations
#
# Revision 1.15  2007/10/09 16:47:21  mark
# added clusterfs_services_start_newroot
#
# Revision 1.14  2007/10/05 09:03:03  mark
# added clusterfs_services_stop
#
# Revision 1.13  2007/08/06 15:50:11  mark
# reorganized libraries
# added methods for chroot management
# fits for bootimage release 1.3
#
# Revision 1.12  2007/03/09 18:02:02  mark
# separated fstype and clutype
#
# Revision 1.11  2007/02/09 11:04:52  marc
# added bootparams nodeid and nodename
#
# Revision 1.10  2006/11/10 11:35:24  mark
# modified clusterfs_mount, added retry option
#
# Revision 1.9  2006/10/19 10:06:25  marc
# clusterconf in chroot on tmp support
#
# Revision 1.8  2006/10/06 08:33:42  marc
# added bootparam quorumack
#
# Revision 1.7  2006/08/28 16:06:45  marc
# bugfixes
# new version of start_service
#
# Revision 1.6  2006/07/03 08:32:27  marc
# changed hostgeneration function
#
# Revision 1.5  2006/06/19 15:55:45  marc
# added device mapper support
#
# Revision 1.4  2006/06/09 14:04:27  marc
# only error detect in mount
#
# Revision 1.3  2006/06/07 09:42:23  marc
# *** empty log message ***
#
# Revision 1.2  2006/05/12 13:03:42  marc
# First stable Version for 1.0.
#
# Revision 1.1  2006/05/07 11:33:40  marc
# initial revision
#
