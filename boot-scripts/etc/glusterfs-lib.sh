#
# $Id: glusterfs-lib.sh,v 1.1 2009-01-28 09:40:12 marc Exp $
#
# @(#)$File$
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
#    glusterfs-mountopt=...  The mount options given to the mount command (i.e. noatime,nodiratime)
#    com-stepmode=...      If set it asks for <return> after every step
#    com-debug=...         If set debug info is output

#****h* comoonics-bootimage/glusterfs-lib.sh
#  NAME
#    glusterfs-lib.sh
#    $id$
#  DESCRIPTION
#*******

default_mountopts="noatime,nodiratime"
#ccs_xml_query="/opt/atix/comoonics-cs/ccs_xml_query"
ccs_xml_query="/usr/bin/com-queryclusterconf"
cl_check_nodes="/usr/bin/cl_checknodes"

#****f* boot-scripts/etc/clusterfs-lib.sh/glusterfs_get_rootfs
#  NAME
#    glusterfs_get_rootfs
#  SYNOPSIS
#    function glusterfs_get_rootfs(cluster_conf, nodeid, nodename)
#  DESCRIPTTION
#    returns the type of the root filesystem.
#  SOURCE
#
function glusterfs_get_rootfs {
   local cluster_conf=$1
   local nodeid=$2
   local nodename=$3
   [ -z "$nodename" ] && nodename=$(glusterfs_get_nodename $cluster_conf)
   local xml_cmd="${ccs_xml_query} -f $cluster_conf"
   $xml_cmd -q rootfs $nodename
}
#******** glusterfs_get_rootfs

#****f* glusterfs-lib.sh/glusterfs_get_rootvolume
#  NAME
#    glusterfs_get_rootvolume
#  SYNOPSIS
#    glusterfs_get_rootvolume(cluster_conf, nodename)
#  DESCRIPTION
#    Gets the rootvolume for this node
#  IDEAS
#  SOURCE
#
function glusterfs_get_rootvolume {
   local xml_file=$1
   local hostname=$2
   [ -z "$hostname" ] && hostname=$(glusterfs_get_nodename $xml_file)
   local xml_cmd="${ccs_xml_query} -f $xml_file"
   $xml_cmd -q rootvolume $hostname
}
#************ glusterfs_get_rootvolume

#****f* glusterfs-lib.sh/glusterfs_get_rootsource
#  NAME
#    glusterfs_get_rootsource
#  SYNOPSIS
#    glusterfs_get_rootsource(cluster_conf, nodename)
#  DESCRIPTION
#    Gets the rootsource for this node
#  IDEAS
#  SOURCE
#
function glusterfs_get_rootsource {
   local xml_file=$1
   local hostname=$2
   [ -z "$hostname" ] && hostname=$(glusterfs_get_nodename $xml_file)
   local xpath="/cluster/clusternodes/clusternode[@name=\"$hostname\"]/com_info/rootsource/@name"
   local xml_cmd="${ccs_xml_query} -f $xml_file"
   $xml_cmd -q query_value $xpath
}
#************ glusterfs_get_rootsource

#****f* glusterfs-lib.sh/glusterfs_get_rootfs
#  NAME
#    glusterfs_get_rootfs
#  SYNOPSIS
#    glusterfs_get_rootfs(cluster_conf, nodename, [rootfs])
#  DESCRIPTION
#    Gets the root filesystem type for this node
#    Default is ""
#  IDEAS
#  SOURCE
#
function glusterfs_get_rootfs {
   local xml_file=$1
   local hostname=$2

   [ -z "$hostname" ] && hostname=$(glusterfs_get_nodename $xml_file)
   local xml_cmd="${ccs_xml_query} -f $xml_file"

   local __rootfs=$($xml_cmd -q rootfs $hostname)

   if [ -z "$__rootfs" ]; then
     echo ""
   else
     echo $__rootfs
   fi
}
#************ glusterfs_get_rootfs

#****f* glusterfs-lib.sh/glusterfs_get_mountopts
#  NAME
#    glusterfs_get_mountopts
#  SYNOPSIS
#    glusterfs_get_mountopts(cluster_conf, nodename)
#  DESCRIPTION
#    Gets the mountopts for this node
#  IDEAS
#  SOURCE
#
function glusterfs_get_mountopts {
   local xml_file=$1
   local hostname=$2
   [ -z "$hostname" ] && hostname=$(glusterfs_get_nodename $xml_file)
   local xml_cmd="${ccs_xml_query} -f $xml_file"
   _mount_opts=$($xml_cmd -q mountopts $hostname)
   if [ -z "$_mount_opts" ]; then
     echo $default_mountopts
   else
     echo $_mount_opts
   fi
}
#************ glusterfs_get_mountopts

#****f* glusterfs-lib.sh/glusterfs_get_chroot_mountpoint
#  NAME
#    glusterfs_get_chroot_mountpoint
#  SYNOPSIS
#    glusterfs_get_chroot_mountpoint(cluster_conf, nodename)
#  DESCRIPTION
#    Gets the mountpoint for the chroot environment of this node
#  IDEAS
#  SOURCE
#
function glusterfs_get_chroot_mountpoint {
   local xml_file=$1
   local hostname=$2
   [ -z "$hostname" ] && hostname=$(glusterfs_get_nodename $xml_file)
   local xpath="/cluster/clusternodes/clusternode[@name=\"$hostname\"]/com_info/chrootenv/@mountpoint"
   local xml_cmd="${ccs_xml_query} -f $xml_file"
   $xml_cmd -q query_value $xpath
}
#************ glusterfs_get_chroot_mountpoint

#****f* glusterfs-lib.sh/glusterfs_get_chroot_fstype
#  NAME
#    glusterfs_get_chroot_fstype
#  SYNOPSIS
#    glusterfs_get_chroot_fstype(cluster_conf, nodename)
#  DESCRIPTION
#    Gets the filesystem type for the chroot environment of this node
#  IDEAS
#  SOURCE
#
function glusterfs_get_chroot_fstype {
   local xml_file=$1
   local hostname=$2
   [ -z "$hostname" ] && hostname=$(glusterfs_get_nodename $xml_file)
   local xpath="/cluster/clusternodes/clusternode[@name=\"$hostname\"]/com_info/chrootenv/@fstype"
   local xml_cmd="${ccs_xml_query} -f $xml_file"
   $xml_cmd -q query_value $xpath
}
#************ glusterfs_get_chroot_fstype

#****f* glusterfs-lib.sh/glusterfs_get_chroot_device
#  NAME
#    glusterfs_get_chroot_device
#  SYNOPSIS
#    glusterfs_get_chroot_device(cluster_conf, nodename)
#  DESCRIPTION
#    Gets the mountpoint for the chroot environment of this node
#  IDEAS
#  SOURCE
#
function glusterfs_get_chroot_device {
   local xml_file=$1
   local hostname=$2
   [ -z "$hostname" ] && hostname=$(glusterfs_get_nodename $xml_file)
   local xpath="/cluster/clusternodes/clusternode[@name=\"$hostname\"]/com_info/chrootenv/@device"
   local xml_cmd="${ccs_xml_query} -f $xml_file"
   $xml_cmd -q query_value $xpath
}
#************ glusterfs_get_chroot_device

#****f* glusterfs-lib.sh/glusterfs_get_chroot_mountopts
#  NAME
#    glusterfs_get_chroot_mountopts
#  SYNOPSIS
#    glusterfs_get_chroot_mountopts(cluster_conf, nodename)
#  DESCRIPTION
#    Gets the mount options for the chroot environment of this node
#  IDEAS
#  SOURCE
#
function glusterfs_get_chroot_mountopts {
   local xml_file=$1
   local hostname=$2
   [ -z "$hostname" ] && hostname=$(glusterfs_get_nodename $xml_file)
   local xpath="/cluster/clusternodes/clusternode[@name=\"$hostname\"]/com_info/chrootenv/@mountoptions"
   local xml_cmd="${ccs_xml_query} -f $xml_file"
   $xml_cmd -q query_value $xpath
}
#************ glusterfs_get_chroot_mountopts

#****f* glusterfs-lib.sh/glusterfs_get_chroot_dir
#  NAME
#    glusterfs_get_chroot_dir
#  SYNOPSIS
#    glusterfs_get_chroot_dir(cluster_conf, nodename)
#  DESCRIPTION
#    Gets the directory for the chroot environment of this node
#  IDEAS
#  SOURCE
#
function glusterfs_get_chroot_dir {
   local xml_file=$1
   local hostname=$2
   [ -z "$hostname" ] && hostname=$(glusterfs_get_nodename $xml_file)
   local xpath="/cluster/clusternodes/clusternode[@name=\"$hostname\"]/com_info/chrootenv/@chrootdir"
   local xml_cmd="${ccs_xml_query} -f $xml_file"
   $xml_cmd -q query_value $xpath
}
#************ glusterfs_get_chroot_dir



#****f* glusterfs-lib.sh/glusterfs_get_scsifailover
#  NAME
#    glusterfs_get_scsifailover
#  SYNOPSIS
#    glusterfs_get_scsifailover(cluster_conf, nodename)
#  DESCRIPTION
#    Gets the mountopts for this node
#  IDEAS
#  SOURCE
#
function glusterfs_get_scsifailover {
   local xml_file=$1
   local nodename=$2
   [ -z "$nodename" ] && nodename=$(glusterfs_get_nodename $xml_file)
   local xml_cmd="${ccs_xml_query} -f $xml_file"
   local _scsifailover=$($xml_cmd -q scsifailover $nodename)
   if [ -z "$_scsifailover" ]; then
     echo ""
   else
     echo $_scsifailover
   fi
}
#************ glusterfs_get_scsifailover

#****f* glusterfs-lib.sh/glusterfs_get_node_hostname
#  NAME
#    glusterfs_get_node_hostname
#  SYNOPSIS
#    glusterfs_get_node_hostname(clusterconf, [nodename])
#  DESCRIPTION
#    returns the hostname for this node
#    !!!THIS FUNCTION SHOULD NOT BE NEEDED ANY MORE!!!!
#  IDEAS
#  SOURCE
#
function glusterfs_get_node_hostname {
   local xml_file=$1
   local nodename=$2
   [ -z "$nodename" ] && nodename=$(glusterfs_get_nodename)
   local xml_cmd="${ccs_xml_query} -f $xml_file"
   $xml_cmd -q hostname $nodename 2>/dev/null
   return $?
}
#************ glusterfs_get_node_hostname

#****f* glusterfs-lib.sh/glusterfs_get_nodename
#  NAME
#    glusterfs_get_nodename
#  SYNOPSIS
#    function glusterfs_get_nodename(cluster_conf, netdev)
#  DESCRIPTION
#    gets for this very host the nodename (identified by the macaddress)
#  IDEAS
#  SOURCE
#
function glusterfs_get_nodename {
    local ccs_file=$1
    local mac=$2

    local xml_cmd="${ccs_xml_query}"
    $xml_cmd -f $ccs_file -q nodename $mac
}
#************ glusterfs_get_nodename

#****f* glusterfs-lib.sh/glusterfs_get_nodeid
#  NAME
#    glusterfs_get_nodeid
#  SYNOPSIS
#    function glusterfs_get_nodeid(cluster_conf, mac)
#  DESCRIPTION
#    gets for this very host the nodeid (identified by the macaddress)
#  IDEAS
#  SOURCE
#
function glusterfs_get_nodeid {
    local ccs_file=$1
    local mac=$2

    local xml_cmd="${ccs_xml_query}"
    $xml_cmd -f $ccs_file -q nodeid $mac
}
#************ glusterfs_get_nodeid

#****f* glusterfs-lib.sh/glusterfs_get_clu_nodename
#  NAME
#    glusterfs_get_clu_nodename
#  SYNOPSIS
#    function glusterfs_get_clu_nodename()
#  DESCRIPTION
#    gets the nodename of this node from the cluster infrastructure
#  SOURCE
function glusterfs_get_clu_nodename {
  cat /proc/cluster/status | grep "Node name:"  | awk  '{print $3}'
}
#******* cc_get_clu_nodename



#****f* glusterfs-lib.sh/glusterfs_get_netdevs
#  NAME
#    glusterfs_get_netdevs
#  SYNOPSIS
#    function glusterfs_get_netdevs(cluster_conf, nodename)
#  DESCRIPTION
#    returns all configured networkdevices from the cluster.conf xml file
#    seperated by " "
#  IDEAS
#  SOURCE
#
function glusterfs_get_netdevs {
#	if [ -n "$debug" ]; then set -x; fi
  local xml_cmd="${ccs_xml_query}"
  local xmlfile=$1
  local nodename=$2

  local netdevs=$($xml_cmd -f $xmlfile -q netdevs $nodename " ");
  echo $netdevs
#	if [ -n "$debug" ]; then set +x; fi
  return 0
}
#********* glusterfs_get_netdevs

#****f* glusterfs-lib.sh/glusterfs_auto_hosts
#  NAME
#    glusterfs_auto_hosts
#  SYNOPSIS
#    function glusterfs_auto_hosts(cluster_conf)
#  DESCRIPTION
#    Generates a hostsfile of all hosts in the cluster configuration
#  IDEAS
#  SOURCE
#
function glusterfs_auto_hosts {
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
#************ glusterfs_auto_hosts

#****f* glusterfs-lib.sh/glusterfs_auto_netconfig
#  NAME
#    glusterfs_auto_netconfig
#  SYNOPSIS
#    function glusterfs_auto_netconfig(ipConfig, $netdev, cluster_conf)
#  DESCRIPTION
#  IDEAS
#  SOURCE
#
function glusterfs_auto_netconfig {
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
#************ glusterfs_auto_netconfig

#****f* glusterfs-lib.sh/glusterfs_get_syslogserver
#  NAME
#    glusterfs_get_syslogserver
#  SYNOPSIS
#    function glusterfs_get_syslogserver(cluster_conf)
#  DESCRIPTION
#    This function starts the syslog-server to log the glusterfs-bootprocess
#  IDEAS
#  SOURCE
#
function glusterfs_get_syslogserver {
  local xml_file=$1
  local xml_cmd="${ccs_xml_query}"
  local nodename=$2
  $xml_cmd -f $xml_file -q syslog $nodename
}
#************ glusterfs_get_syslogserver

#****f* glusterfs-lib.sh/glusterfs_load
#  NAME
#    glusterfs_load
#  SYNOPSIS
#    function glusterfs_load()
#  DESCRIPTION
#    This function loads all relevant glusterfs modules
#  IDEAS
#  SOURCE
#
function glusterfs_load {
  ## THIS will be overwritten for rhel5 ##

  GLUSTERFS_MODULES="fuse"

  echo_local -n "Loading GlusterFS modules ($GLUSTERFS_MODULES)..."
  for module in ${GLUSTERFS_MODULES}; do
    exec_local /sbin/modprobe ${module}
  done
  return_code

  echo_local_debug  "Loaded modules:"
  exec_local_debug /sbin/lsmod

  return $return_c
}
#************ glusterfs_load

#****f* glusterfs-lib.sh/glusterfs_services_start
#  NAME
#    glusterfs_services_start
#  SYNOPSIS
#    function glusterfs_services_start()
#  DESCRIPTION
#    This function loads all relevant glusterfs modules
#  IDEAS
#  SOURCE
#
function glusterfs_services_start {
  ## THIS will be overwritten for rhel5 ##
  local chroot_path=$1
  local rootsource=$(glusterfs_get_rootsource $cluster_conf $nodename)
  echo_local "cluster_conf: $cluster_conf"
  echo_local "nodename: $nodename"
  echo_local "rootsource: $rootsource"

  echo_local "Mounting tmproot $rootsource /mnt/tmproot"
  mkdir /mnt/tmproot
  mount $rootsource /mnt/tmproot
  
  return $return_c
}
#************ glusterfs_services_start

#****f* glusterfs-lib.sh/glusterfs_services_restart_newroot
#  NAME
#    glusterfs_services_restart_newroot
#  SYNOPSIS
#    function glusterfs_services_restart_newroot()
#  DESCRIPTION
#    This function starts all needed services in newroot
#  IDEAS
#  SOURCE
#
function glusterfs_services_restart_newroot() {
  ## THIS will be overwritten for rhel5 ##
  exec_local /bin/true
}
#************ glusterfs_services_restart_newroot

#****f* glusterfs-lib.sh/glusterfs_init
#  NAME
#    glusterfs_init
#  SYNOPSIS
#    function glusterfs_init(start|stop|restart)
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function glusterfs_init {
	return 0
}
#********* glusterfs_init

# $Log: glusterfs-lib.sh,v $
# Revision 1.1  2009-01-28 09:40:12  marc
# Import from Gordan Bobic.
#
