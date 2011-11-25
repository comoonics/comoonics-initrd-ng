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
repository_has_key cdsl_local_dir || repository_store_value cdsl_local_dir "/.cdsl.local"
#******** cdsl_local_dir

#****d* boot-scripts/etc/clusterfs-lib.sh/cdsl_prefix
#  NAME
#    cdsl_prefix
#  DESCRIPTION
#    where the local dir for cdsls can be found
repository_has_key cdsl_prefix || repository_store_value cdsl_prefix "/.cluster/cdsl"
#******** cdsl_prefix
repository_has_key confdir || repository_store_value confdir /etc/conf.d

#****f* boot-scripts/etc/clusterfs-lib.sh/getCluType
#  NAME
#    getCluType
#  SYNOPSIS
#    function getCluType(conf, dir)
#  DESCRIPTTION
#    returns the type of the cluster. Until now only "gfs"
#    is returned.
#  SOURCE
#
function getCluType {
   local conf=$1
   local clutype=""
   
   if repository_has_key clutype; then
   	  repository_get_value clutype
   	  return 0
   fi
   if [ -z "$conf" ]; then
   	  conf=$(repository_get_value cluster_conf /etc/cluster/cluster.conf)
   fi
   repository_has_key ccs_xml_query || repository_store_value ccs_xml_query "/usr/bin/com-queryclusterconf"

   if [ -z "$conf" ] || [ ! -f "$conf" ] || [ ! -e "$(repository_get_value ccs_xml_query)" ]; then
   	  clutype="osr"
   else
     # first test for gfs type
     clutype=$($(repository_get_value ccs_xml_query) --filename $conf -q clustertype 2>/dev/null) || clutype=$($(repository_get_value ccs_xml_query) --filename $conf -q query_value /cluster/@type 2>/dev/null)
     if [ -z "$clutype" ] && $(repository_get_value ccs_xml_query) --filename $conf query_value /cluster/clusternodes/clusternode/com_info &>/dev/null; then
   	    clutype="gfs"
     fi
   fi
   echo "$clutype"
   repository_store_value clutype "$clutype" 
   
   return 0
}
#******** getCluType

#****f* boot-scripts/etc/clusterfs-lib.sh/getClusterParameter
#  NAME
#    getClusterParameter
#  SYNOPSIS
#    getClusterParameter(parametername, nodeid[, nodename])
#  DESCRIPTION
#    returns the parameter of the cluster configuration
#  SOURCE
function getClusterParameter() {
	local name=$1
	shift
	local out=""
	if [ -z $(repository_get_value clutype "") ]; then
		return 0
	fi
	# first we need to find our nodeid
	#maybe it is already in the repository
	local nodeid=${1:-$(repository_get_value nodeid)}
    local nodename=${2:-$(repository_get_value nodename)}
    if [ -z "$nodeid" ]; then 
		# we need to query it
		nodeid=$(cc_find_nodeid)
		if [ -n "$nodeid" ]; then
			repository_store_value nodeid $nodeid
		else
			return 1
		fi
	fi	
	if [ -z "$nodename" ]; then
		nodename=$(cc_get_nodename_by_id $nodeid) 
		if [ -n "$nodename" ]; then
			repository_store_value nodename $nodename
		fi
	fi
	# maybe we can find the value in the repository
	if repository_has_key $name; then
		out=$(repository_get_value $name)
	elif clusterfs_is_valid_param $name; then
		out=$(clusterfs_get_$name $nodeid 2>/dev/null)
		[ $? -eq 0 ] && [ -n "$out" ] || out=$(clusterfs_get $name $nodeid 2>/dev/null)
		[ $? -eq 0 ] && [ -n "$out" ] && [ -z "$nodename" ] || out=$(clusterfs_get_$name $nodename 2>/dev/null)
		[ $? -eq 0 ] && [ -n "$out" ] && [ -z "$nodename" ] || out=$(clusterfs_get $name $nodename 2>/dev/null)
	else
		out=$(cc_get_$name $nodeid 2>/dev/null)
		[ $? -eq 0 ] && [ -n "$out" ] || out=$(cc_get $name $nodeid 2>/dev/null)
		[ $? -eq 0 ] && [ -n "$out" ] && [ -z "$nodename" ] || out=$(cc_get_$name $nodename 2>/dev/null)
		[ $? -eq 0 ] && [ -n "$out" ] && [ -z "$nodename" ] || out=$(cc_get $name $nodename 2>/dev/null)
	fi
	[ -n "$out" ] && echo -n $out
	test -n "$out"
}
#****** getClusterFSParameters

#****f* boot-scripts/etc/clusterfs-lib.sh/getRootFS
#  NAME
#    getRootFS
#  SYNOPSIS
#    function getRootFS(nodeid)
#  DESCRIPTTION
#    returns the type of the root filesystem. Until now only "gfs"
#    is returned.
#  SOURCE
#
function getRootFS {
   local nodeid=$1
   local clutype=$(repository_get_value clutype)
   local rootfs=$(${clutype}_get_rootfs $nodeid)
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

#****f* boot-scripts/etc/clusterfs-lib.sh/cluster_ip_config
#  NAME
#    cluster_ip_config
#  SYNOPSIS
#    cluster_ip_config(nodename/nodeid)
#  DESCRIPTION
#    returns the following parameters got from the cluster configuration
#      * ipConfig: the ipConfiguration used to do locking
#  SOURCE
function cluster_ip_config {
  local nodenameorid=$1
  local distro=$(repository_get_value distribution)
  local networkdir=$(repository_get_value confdir)/network
  local ifcfgfile=
  local ifcfgfile2=

  if [ -d $networkdir ]; then
    for ifcfgfile in $(ls -1 $networkdir/ifcfg-*.$nodenameorid 2>/dev/null); do
  	  [ -d $(${distro}_get_networkpath) ] || mkdir $(${distro}_get_networkpath)
      ifcfgfile2=$(echo $(basename $ifcfgfile) | sed -e 's/\.'$nodenameorid'$//')
  	  cp $ifcfgfile $(${distro}_get_networkpath)/$ifcfgfile2
  	  source $(${distro}_get_networkpath)/$ifcfgfile2
  	  echo $DEVICE
    done
  fi
  for _dev in $(cc_get_netdevs $nodenameorid); do
    cc_auto_netconfig "$nodenameorid" "$_dev"
  done
}
#******** cluster_ip_config

#****f* clusterfs-lib.sh/cc_validate
#  NAME
#    cc_validate
#  SYNOPSIS
#    function cc_validate()
#  DESCRIPTION
#    validates the cluster configuration. 
#  SOURCE
function cc_validate {
  local clutype=$(repository_get_value clutype)
  ${clutype}_validate "$@"
}
#*********** cc_validate

#****f* clusterfs-lib.sh/cc_get_clustername
#  NAME
#    cc_get_clustername
#  SYNOPSIS
#    function cc_get_clustername()
#  DESCRIPTION
#    Returns clustername. 
#  SOURCE
cc_get_clustername() {
  local clutype=$(repository_get_value clutype)
  ${clutype}_get_clustername "$@"	
}
#************* cc_get_clustername

#****f* clusterfs-lib.sh/cc_convert
#  NAME
#    cc_convert
#  SYNOPSIS
#    function cc_convert()
#  DESCRIPTION
#    Returns clustername. 
#  SOURCE
cc_convert() {
  local clutype=$(repository_get_value clutype)
  ${clutype}_convert "$@"
}
#************* cc_convert

#****f* clusterfs-lib.sh/cc_get_nic_names
#  NAME
#    cc_get_nic_names
#  SYNOPSIS
#    function cc_get_nic_names(nodeid nic)
#  DESCRIPTION
#    Returns the nic drivers for the given node if specified in cluster configuration. 
#  SOURCE
function cc_get_nic_names {
  local clutype=$(repository_get_value clutype)
  ${clutype}_get_nic_names "$1" "$2"
}
#*********** cc_get_nic_names

#****f* clusterfs-lib.sh/cc_get_nic_drivers
#  NAME
#    cc_get_nic_drivers
#  SYNOPSIS
#    function cc_get_nic_drivers(nodeid nic)
#  DESCRIPTION
#    Returns the nic drivers for the given node if specified in cluster configuration. 
#  SOURCE
function cc_get_nic_drivers {
  local clutype=$(repository_get_value clutype)
  ${clutype}_get_nic_drivers "$1" "$2"
}
#*********** cc_get_nic_drivers

#****f* clusterfs-lib.sh/cc_get_all_drivers
#  NAME
#    cc_get_all_drivers
#  SYNOPSIS
#    function cc_get_all_drivers()
#  DESCRIPTION
#    Returns the all specified drivers for all nodes if specified in cluster configuration. 
#  SOURCE
function cc_get_all_drivers {
  local clutype=$(repository_get_value clutype)
  local rootfs=$(repository_get_value rootfs)
  ${clutype}_get_all_drivers
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
#    function cc_get_cluster_drivers()
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
#    function cc_find_nodeid()
#  DESCRIPTION
#    try to find the nodeid of this node
#  NOTE
#    Must not be overwritten by cluster implementation 
#  SOURCE
function cc_find_nodeid {
	local nodeid=$(getBootParm nodeid)
	local macs=
	if [ -z "$nodeid" ]; then
	   local hwids=$(repository_get_value hardwareids)
	   [ -z "$hwids" ] && hwids=$(hardware_ids silent)
	   for hwid in $hwids; do
    	 nodeid=$(cc_get_nodeid $hwid 2>/dev/null)
    	 if [ -n "$nodeid" ]; then
    		break
    	 fi
  	   done
	fi
	if [ -z "$nodeid" ]; then
		return 1
	fi
	echo $nodeid
	return 0  
}
#******* cc_find_nodeid

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
  ${clutype}_getdefaults "$@"
}
#********** cc_getdefaults

#****f* clusterfs-lib.sh/cc_get_valid_params
#  NAME
#    cc_get_valid_params
#  SYNOPSIS
#    function cc_get_valid_params
#  DESCRIPTION
#    returns all valid params
#  SOURCE
function cc_get_valid_params {
   echo "votes tmpfix quorumack ip rootvolume rootsource syslogserver syslogfilter bridgename bridgescript bridgenetdev bridgeantispoof scsi_failover scsidriver rootfs"
}
#********** cc_get_valid_params

#****f* clusterfs-lib.sh/cc_is_valid_param
#  NAME
#    cc_is_valid_param
#  SYNOPSIS
#    function cc_is_valid_param param
#  DESCRIPTION
#    Checks if this parameter is a valid clusterparam
#  SOURCE
function cc_is_valid_param {
    local valid
    if [ -n "$1" ]; then
      for valid in $(cc_get_valid_params); do
        if [ "$valid" = "$1" ]; then
           return 0
        fi
      done
    fi
    return 1
}
#********** cc_is_valid_param

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

  ${clutype}_get "$@"
}
#******* cc_get

#****f* clusterfs-lib.sh/cc_get_nodeids
#  NAME
#    cc_get_nodeids
#  SYNOPSIS
#    function cc_get_nodeids(netdev)
#  DESCRIPTION
#    gets the nodeid of this node referenced by the networkdevice
#  SOURCE
function cc_get_nodeids {
  local clutype=$(repository_get_value clutype)

  ${clutype}_get_nodeids
}
#******* cc_get_nodeids

#****f* clusterfs-lib.sh/cc_get_macs
#  NAME
#    cc_get_macs
#  SYNOPSIS
#    function cc_get_macs()
#  DESCRIPTION
#    gets the nodeid of this node referenced by the networkdevice
#  SOURCE
function cc_get_macs {
  local clutype=$(repository_get_value clutype)

  ${clutype}_get_macs
}
#******* cc_get_macs

#****f* clusterfs-lib.sh/cc_get_nodeid
#  NAME
#    cc_get_nodeid
#  SYNOPSIS
#    function cc_get_nodeid(hwid)
#  DESCRIPTION
#    gets the nodeid of this node referenced by the given hardware id. Default is to use a macaddress.
#  SOURCE
function cc_get_nodeid {
  local clutype=$(repository_get_value clutype)

  ${clutype}_get_nodeid "$@"
}
#******* cc_get_nodeid

#****f* clusterfs-lib.sh/cc_get_nodename_by_id
#  NAME
#    cc_get_nodename_by_id
#  SYNOPSIS
#    function cc_get_nodename_by_id(id)
#  DESCRIPTION
#    gets the nodename of this node referenced by the nodeid
#  SOURCE
function cc_get_nodename_by_id {
  local clutype=$(repository_get_value clutype)

  ${clutype}_get_nodename_by_id "$@"
}
#******** cc_get_nodename_by_id

#****f* clusterfs-lib.sh/cc_get_rootvolume
#  NAME
#    cc_get_rootvolume
#  SYNOPSIS
#    function cc_get_rootvolume(nodenameorid)
#  DESCRIPTION
#    gets the nodename of this node referenced by the nodename or id
#  SOURCE
function cc_get_rootvolume {
  local clutype=$(repository_get_value clutype)

  ${clutype}_get_rootvolume "$@"
}
#******** cc_get_rootvolume

#****f* clusterfs-lib.sh/cc_get_rootsource
#  NAME
#    cc_get_rootsource
#  SYNOPSIS
#    function cc_get_rootsource(nodenameorid)
#  DESCRIPTION
#    gets the rootsource of this node referenced by the nodename or nodeid.
#  SOURCE
function cc_get_rootsource {
  local clutype=$(repository_get_value clutype)

  ${clutype}_get_rootsource "$@"
}
#******** cc_get_rootsource

#****f* clusterfs-lib.sh/cc_get_rootfs
#  NAME
#    cc_get_rootfs
#  SYNOPSIS
#    function cc_get_rootfs(nodenameorid)
#  DESCRIPTION
#    gets the rootfs type of this node referenced by the nodename or nodeid
#  SOURCE
function cc_get_rootfs {
  local clutype=$(repository_get_value clutype)

  ${clutype}_get_rootfs "$@"
}
#******** cc_get_rootfs

#****f* clusterfs-lib.sh/cc_get_userspace_procs
#  NAME
#    cc_get_userspace_procs
#  SYNOPSIS
#    function cc_get_userspace_procs(rootfstype)
#  DESCRIPTION
#    gets userspace programs that are to be running dependent on rootfs
#  SOURCE
function cc_get_userspace_procs {
  local rootfs=${1:-$(repository_get_value rootfs)}

  typeset -f ${rootfs}_get_userspace_procs >/dev/null 2>/dev/null
  if [ $? -eq 0 ]; then
    ${rootfs}_get_userspace_procs $*
  fi
}
#******** cc_get_userspace_procs

#****f* clusterfs-lib.sh/cc_get_mountopts
#  NAME
#    cc_get_mountopts
#  SYNOPSIS
#    function cc_get_mountopts(nodenameorid)
#  DESCRIPTION
#    gets the mountopts for the given nodename or nodeid.
#    If no function {rootfstype}_get_mountopts is found the {rootfstype}_getdefaults mountopts call is used.
#  SOURCE
function cc_get_mountopts {
  local rootfs=$(repository_get_value rootfs)
  local clutype=$(repository_get_value clutype)
   
  typeset -f ${rootfs}_get_mountopts >/dev/null 2>/dev/null
  if [ $? -eq 0 ]; then
    ${rootfs}_get_mountopts "$@"
  else
    ${rootfs}_getdefaults mountopts
  fi
}
#******** cc_get_mountopts

#****f* clusterfs-lib.sh/cc_get_chroot_mountpoint
#  NAME
#    cc_get_chroot_mountpoint
#  SYNOPSIS
#    function cc_get_chrootmountpoint(nodenameorid)
#  DESCRIPTION
#    gets the mountpoint for the chroot environment of this node referenced by the nodename or nodeid.
#    default is /var/comoonics/chroot see $DFLT_CHROOT_MOUNT global variable for default fallback.
#  SOURCE
function cc_get_chroot_mountpoint {
  local clutype=$(repository_get_value clutype)

  local mp=$(${clutype}_get chroot_mountpoint "$@")
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
#    function cc_get_chrootfstype(nodenameorid)
#  DESCRIPTION
#    gets the filesystem type for the chroot environment of this node referenced by the nodename or nodeid
#    defaults to tmpfs
#  SOURCE
function cc_get_chroot_fstype {
  local clutype=$(repository_get_value clutype)

  local fs=$(${clutype}_get chroot_fstype "$@")
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
#    function cc_get_chrootdevice(nodenameorid)
#  DESCRIPTION
#    gets the device for the chroot environment of this node referenced by the nodename or nodeid
#    defaults to none
#  SOURCE
function cc_get_chroot_device {
  local clutype=$(repository_get_value clutype)

  local dev=$(${clutype}_get chroot_device "$@")
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
#    function cc_get_chrootmountopts(nodenameorid)
#  DESCRIPTION
#    gets the mount options for the chroot environment of this node referenced by the nodename or nodeid
#    defaults to defaults
#  SOURCE
function cc_get_chroot_mountopts {
  local clutype=$(repository_get_value clutype)

  local mo=$(${clutype}_get chroot_mountopts "$@")
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
#    function cc_get_chroot_dir(nodename)
#  DESCRIPTION
#    gets the directory (including mounpoint) for the chroot environment of this node referenced by the nodename or nodeid.
#    defaults to cc_get_chroot_mountpoint (/var/comoonics/chroot)
#  SOURCE
function cc_get_chroot_dir {
  local clutype=$(repository_get_value clutype)

  local dir=$(${clutype}_get chroot_dir "$@")
  if [ -n "$dir" ]; then
     echo $dir
  else
     cc_get_chroot_mountpoint "$@"
  fi
}
#******** cc_get_chroot_dir

#****f* clusterfs-lib.sh/cc_get_syslogserver
#  NAME
#    cc_get_syslogserver
#  SYNOPSIS
#    function cc_get_syslogserver(nodenameodid)
#  DESCRIPTION
#    Returns the syslog server set for this node specified by the nodename or the nodeid.
#  SOURCE
cc_get_syslogserver() {
  local clutype=$(repository_get_value clutype)
  ${clutype}_get_syslogserver "$@"
}
#*************** cc_get_syslogserver

#****f* clusterfs-lib.sh/cc_get_syslogfilter
#  NAME
#    cc_get_syslogfilter
#  SYNOPSIS
#    function cc_get_syslogfilter(nodenameorid)
#  DESCRIPTION
#    Returns the syslog server set in the cluster
#  SOURCE
cc_get_syslogfilter() {
  local clutype=$(repository_get_value clutype)
  ${clutype}_get_syslogfilter "$@"
}
#*************** cc_get_syslogfilter

#****f* clusterfs-lib.sh/cc_init
#  NAME
#    cc_init
#  SYNOPSIS
#    function cc_init( start|stop|restart clutype CHROOT_PATH [opts])
#  MODIFICATION HISTORY
#  IDEAS
#    Calls the initialization function of the specific cluster (referenced by repository clutype).
#  SOURCE
#
function cc_init {
  local proc=
  local clutype=${2:-$(repository_get_value clutype)}

  typeset -f ${clutype}_init >/dev/null 2>/dev/null
  if [ $? -eq 0 ]; then
    ${clutype}_init "$@"
  fi
  return 0
}
#********* cc_init

#****f* clusterfs-lib.sh/cc_get_scsifailover
#  NAME
#    cc_get_scsifailover
#  SYNOPSIS
#    function cc_get_scsifailover(nodenameorid)
#  DESCRIPTION
#    gets the scsi failover type for the specified nodename or nodeid. Will forward to {clutype}_get_scsifailover.
#  SOURCE
function cc_get_scsifailover {
  local clutype=$(repository_get_value clutype)

  ${clutype}_get_scsifailover "$@"
}
#******** cc_get_scsifailover

#****f* clusterfs-lib.sh/cc_get_netdevs
#  NAME
#    cc_get_netdevs
#  SYNOPSIS
#    function cc_get_netdevs(nodenameorid)
#  DESCRIPTION
#    gets the network devices of this node referenced by the nodename or nodeid
#  SOURCE
function cc_get_netdevs {
  local clutype=$(repository_get_value clutype)

  ${clutype}_get_netdevs "$@"
}
#******** cc_get_netdevs

#****f* clusterfs-lib.sh/cc_auto_netconfig
#  NAME
#    cc_auto_netconfig
#  SYNOPSIS
#    function cc_auto_netconfig(nodenameorid, netdev)
#  DESCRIPTION
#    Returns a specific ip string found for the given node and network interface.
#    The node must be referenced as nodeid or nodename and the network interface with the name of the network interface.
#    The return syntax for ip is as follows:
#    cc_auto_netconfig=> {ipaddr} :        :{gateway}:{netmask}::{netdev}:{mac_addr}:{type}:{bridge}:{onboot}:{driver}:({property:name=value}':')+ |
#                                 :{master}:{slave}  :         ::{netdev}:{mac_addr}:{type}:{bridge}:{onboot}:{driver}:({attrs:name=value}':')+
#    This function might be overwritten by {clutype}_auto_netconfig *
#    As parameters are seperated by ":" the ":" in the mac_address will be replaced by "-". Should be replaced back if 
#    later needed.
#  SOURCE
function cc_auto_netconfig {
  local clutype=$(repository_get_value clutype)
  local netdev=${2:-eth0}

  typeset -f ${clutype}_auto_netconfig &>/dev/null
  # this is the old way you should not need to implement ${clutype}_auto_netconfig
  if [ $? -eq 0 ]; then
    ${clutype}_auto_netconfig "$@"
  else
    local ip_addr=$(cc_get ip "$@" 2>/dev/null)
    local mac_addr=$(cc_get eth_name_mac "$@" 2>/dev/null | tr [a-f] [A-F])
    local type=$(cc_get eth_name_type "$@" 2>/dev/null)
    local bridge=$(cc_get eth_name_bridge "$@" 2>/dev/null)
    local onboot=$(cc_get eth_name_onboot "$@" 2>/dev/null)
    local driver=$(cc_get eth_name_driver "$@" 2>/dev/null)
    local properties=$(cc_get eth_name_properties "$@" 2>/dev/null | tr --delete '\n' | tr " " ":")
    local master=$(cc_get eth_name_master "$@" 2>/dev/null)
    local slave=$(cc_get eth_name_slave "$@" 2>/dev/null)
    local gateway=$(cc_get eth_name_gateway "$@" 2>/dev/null) || local gateway=""
    local netmask=$(cc_get eth_name_mask "$@" 2>/dev/null)
    if [ -z "$onboot" ]; then
  	  onboot="yes"
    fi 
    if [ -z "$mac_addr" ] && [ -f /sys/class/net/${netdev}/address ]; then
  	  mac_addr=$(cat /sys/class/net/${netdev}/address | tr [a-f] [A-F])
    fi
    mac_addr=${mac_addr//:/-}
    if [ "$ip_addr" != "" ]; then
      echo ${ip_addr}"::"${gateway}":"${netmask}"::"$netdev":"$mac_addr":"$type":"$bridge":"$onboot":"$driver":"$properties
    else
      echo ":"${master}":"${slave}":::"${netdev}":"${mac_addr}":"${type}":"${bridge}":"$onboot":"$driver":"$properties
    fi
  fi
}
#******** cc_auto_netconfig

#****f* clusterfs-lib.sh/cc_auto_hosts
#  NAME
#    cc_auto_hosts
#  SYNOPSIS
#    function cc_auto_hosts()
#  DESCRIPTION
#    generates a hosts file if possible.
#  SOURCE
function cc_auto_hosts {
  local clutype=$(repository_get_value clutype)

  cp /etc/hosts /etc/hosts.bak
  ${clutype}_auto_hosts "$@" /etc/hosts.bak > /etc/hosts
}
#******** cc_auto_hosts

#****f* clusterfs-lib.sh/cc_auto_syslogconfig
#  NAME
#    cc_auto_syslogconfig
#  SYNOPSIS
#    function cc_auto_syslogconfig(nodenameorid, chroot_path, locallog, syslog_logfile, syslog_server)
#  DESCRIPTION
#    creates config for the syslog service
#    to enable local logging use "yes" for locallog.
#    It will also detect the different syslog implementations and start the apropriate syslogservers
#  SOURCE
function cc_auto_syslogconfig {
  local nodenameorid=$1
  local chroot_path=$2
  local local_log=$3
  local syslog_logfile=$4
  local clutype=$(repository_get_value clutype)
  local syslog_type=$(repository_get_value syslog_type)
  local syslog_template=
  local syslog_server=$5
  local syslog_filter=
  local no_klog=$6

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
  if [ -n "$nodenameorid" ] && [ -z "$syslog_server" ]; then
    syslog_server=$(getParameter syslogserver 2>/dev/null)
    syslog_filter=$(getParameter syslogfilter 2>/dev/null)
  fi
  [ -z "$syslog_filter" ] && syslog_filter="kern,daemon.info:$syslog_logfile"
  repository_store_value syslogfilter "$syslog_filter"

  if [ -n "$syslog_type" ]; then
    syslog_template=$(getParameter syslogtemplate $(${clutype}_get_syslogtemplate "$@" 2>/dev/null) 2>/dev/null)
	if [ -z "$syslog_template" ]; then
		syslog_template="/etc/templates/${syslog_type}.conf"
	fi
	repository_store_value syslogtemplate $syslog_template
    
    echo_local -n "Creating syslog config for syslog destinations: $syslog_filter server: $syslog_server"
    mkdir -p ${chroot_path}/$(dirname $(repository_get_value syslogconf $(default_syslogconf $syslog_type)))
    exec_local $(echo ${syslog_type} | tr '-' '_')_config $syslog_template "$no_klog" $syslog_filter $syslog_server > ${chroot_path}/$(repository_get_value syslogconf $(default_syslogconf $syslog_type))
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

#****f* clusterfs-lib.sh/clusterfs_get_valid_params
#  NAME
#    clusterfs_get_valid_params
#  SYNOPSIS
#    function clusterfs_get_valid_params
#  DESCRIPTION
#    returns all valid params
#  SOURCE
function clusterfs_get_valid_params {
   echo "sourceserver lockmethod root mountopts rootfsck mounttimes mountwait"
}
#********** clusterfs_get_valid_params

#****f* clusterfs-lib.sh/clusterfs_is_valid_param
#  NAME
#    clusterfs_is_valid_param
#  SYNOPSIS
#    function clusterfs_is_valid_param param
#  DESCRIPTION
#    Checks if this parameter is a valid clusterparam
#  SOURCE
function clusterfs_is_valid_param {
    local valid
    if [ -n "$1" ]; then
      for valid in $(clusterfs_get_valid_params); do
        if [ "$valid" = "$1" ]; then
           return 0
        fi
      done
    fi
    return 1
}
#********** clusterfs_is_valid_param

#****f* clusterfs-lib.sh/clusterfs_get
#  NAME
#    clusterfs_get
#  SYNOPSIS
#    function clusterfs_get query
#  DESCRIPTION
#    gets a value generically
#  SOURCE
function clusterfs_get {
  local rootfs=$(repository_get_value rootfs)
  ${rootfs}_get "$@"
}
#******* clusterfs_get

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
  ${rootfs}_getdefaults "$@"
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
  ${rootfs}_load "$@"
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
  ${rootfs}_services_start "$@"
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
  ${rootfs}_services_stop "$@"
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
  ${rootfs}_services_restart "$@"
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
  ${rootfs}_services_restart_newroot "$@"
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
     breakp "$(errormsg err_fs_device $dev)"
  fi
  if [ ! -d $mountpoint ]; then
    mkdir -p $mountpoint
  fi
  [ -n "$mountopts" ] && mountopts="-o $mountopts"
  [ -n "$fstype" ] && ! [ "$fstype" = "bind" ] && fstype="-t $fstype"
  [ "$fstype" = "bind" ] && fstype="--$fstype"
  echo_local_debug -N -n "tries: $tries, waittime: $waittime "
  while [ $i -lt $tries ]; do
  	echo_local -N -n "."
  	let i=$i+1
  	sleep $waittime
  	return_c=0
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
#    function clusterfs_get_userspace_procs(nodename)
#  DESCRIPTION
#    gets userspace programs that are to be running dependent on rootfs
#  SOURCE
function clusterfs_get_userspace_procs {
  local rootfs=$1
  [ -z "$rootfs" ] && rootfs=$(repository_get_value rootfs)

  typeset -f ${rootfs}_get_userspace_procs >/dev/null 2>/dev/null
  if [ $? -eq 0 ]; then
    ${rootfs}_get_userspace_procs "$@"
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
  local rootfs=$2
  [ -z "$rootfs" ] && rootfs=$(repository_get_value rootfs)

  typeset -f ${rootfs}_init >/dev/null 2>/dev/null
  if [ $? -eq 0 ]; then
    ${rootfs}_init "$@"
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
  ${rootfs}_restart_cluster_services "$@"
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
  local prefix="/.cluster/cdsl"
  if [ -n "$4" ]; then
    prefix=$4
  fi
  local bindtype="rbind"
  [ -n "$5" ] && local bindtype="$5"

  echo_local -n "Mounting ${mountpoint}/$cdsl_dir on ${mountpoint}/${prefix}/${nodeid}.."
  if [ ! -d ${mountpoint}/${prefix} ]; then
    echo_local "no cdsldir found \"${mountpoint}/${prefix}\""
    warning
  fi
  exec_local mount --${bindtype} ${mountpoint}/${prefix}/${nodeid} ${mountpoint}/${cdsl_dir}
  return_code
}
#***** clusterfs_mount_cdsl

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
    ${rootfs}_chroot_needed "$@"
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
    ${rootfs}_blkstorage_needed "$@"
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
    ${rootfs}_fsck_needed "$@"
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
  local root=${1:-$(repository_get_value root)}
  local rootfs=${2:-$(repository_get_value rootfs)}
  typeset -f ${rootfs}_fsck >/dev/null
  if [ $? -eq 0 ]; then
    ${rootfs}_fsck "$@"
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
