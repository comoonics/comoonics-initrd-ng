#
# $Id: clusterfs-lib.sh,v 1.1 2006-05-07 11:33:40 marc Exp $
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
cdsl_local_dir="/cdsl.local"
#******** cdsl_local_dir

#****d* boot-scripts/etc/clusterfs-lib.sh/cdsl_prefix
#  NAME
#    cdsl_prefix
#  DESCRIPTION
#    where the local dir for cdsls can be found
cdsl_prefix="/cluster/cdsl"
#******** cdsl_prefix

#****d* boot-scripts/etc/clusterfs-lib.sh/cluster_conf
#  NAME
#    cluster_conf
#  DESCRIPTION
#    clusterconfig file defaults to /etc/cluster/cluster.conf
cluster_conf="/etc/cluster/cluster.conf"
#******** cluster_conf

if [ ! -e $cluster_conf ]; then
  error_local "Critical error could not find cluster configuration."
  exit_linuxrc 1
fi

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
	getBootParm rootsource scsi
	getBootParm root
	getBootParm lockmethod
	getBootParm sourceserver
}
#******** getClusterFSParameters

#****f* boot-scripts/etc/clusterfs-lib.sh/getRootFS
#  NAME
#    getRootFS
#  SYNOPSIS
#    function getRootFS()
#  DESCRIPTTION
#    returns the type of the root filesystem. Until now only "gfs"
#    is returned.
#  SOURCE
#
function getRootFS {
   echo "gfs"
}
#******** getRootFS

#****f* boot-scripts/etc/clusterfs-lib.sh/cluster_config
#  NAME
#    cluster_config
#  SYNOPSIS
#    cluster_config(cluster_conf, ipConfig)
#  DESCRIPTION
#    returns the following parameters got from the cluster configuration
#      * nodeid: the unique id of this node
#      * nodename: the name of this node
#      * rootvolume: the root volume to be mounted by this node (can be 
#          overwritten by the bootparam "root"
#      * ipConfig: the ipConfiguration used to do locking
#  SOURCE
function clusterfs_config {
  local cluster_conf=$1
  local ipConfig=$2

  # Here we still have a dependency on eth0 should be changed soon!!!
  local _nodeid=
  local _nodename=
  local _foundmac=
  macs=$(ifconfig -a | grep -i hwaddr | awk '{print $5;};')
  for mac in $macs; do
    [ -z "$_nodeid" ] && _nodeid=$(cc_get_nodeid ${cluster_conf} $mac)
    [ -z "$_nodename" ] && _nodename=$(cc_get_nodename ${cluster_conf} $mac)
  done
  echo $_nodeid
  echo $_nodename

  cc_get_rootvolume ${cluster_conf} $_nodename
  echo
  for _dev in $(cc_get_netdevs ${cluster_conf} $_nodename); do
    cc_auto_netconfig ${cluster_conf} $_nodename $_dev
  done
}
#******** cluster_config

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

   ${rootfs}_get_nodeid $cluster_conf $mac
}
#******* cc_get_nodeid

#****f* clusterfs-lib.sh/cc_get_nodename
#  NAME
#    cc_get_nodename
#  SYNOPSIS
#    function cc_get_nodename(cluster_conf, netdev)
#  DESCRIPTION
#    gets the nodename of this node referenced by the networkdevice
#  SOURCE
function cc_get_nodename {
   local cluster_conf=$1
   local mac=$2

   ${rootfs}_get_nodename $cluster_conf $mac
}
#******** cc_get_nodename

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

   ${rootfs}_get_rootvolume $cluster_conf $nodename
}
#******** cc_get_rootvolume

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

   ${rootfs}_get_netdevs $cluster_conf $nodename
}
#******** cc_get_netdevs

#****f* clusterfs-lib.sh/cc_auto_netconfig
#  NAME
#    cc_auto_netconfig
#  SYNOPSIS
#    function cc_auto_netconfig(cluster_conf, nodename)
#  DESCRIPTION
#    gets the network devcices of this node referenced by the networkdevice
#  SOURCE
function cc_auto_netconfig {
   local cluster_conf=$1
   local nodename=$2

   ${rootfs}_auto_netconfig $cluster_conf $nodename
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

   ${rootfs}_auto_hosts $cluster_conf >> /etc/hosts
}
#******** cc_auto_netconfig

#****f* clusterfs-lib.sh/cc_auto_syslogconfig
#  NAME
#    cc_auto_syslogconfig
#  SYNOPSIS
#    function cc_auto_syslogconfig(cluster_conf, nodename)
#  DESCRIPTION
#    creates config for the syslog service
#  SOURCE
function cc_auto_syslogconfig {
  local cluster_conf=$1
  local nodename=$2
  local syslog_server=$(${rootfs}_get_syslogserver $cluster_conf $nodename)

  echo_local -n "Creating syslog config for syslog server: $syslog_server"
  if [ -n "$syslog_server" ]; then
    echo '*.* @'"$syslog_server" >> /etc/syslog.conf
  else
    echo "*.* -/var/log/comoonics_boot.syslog" >> /etc/syslog.conf
  fi
  
  echo "syslog          514/udp" >> /etc/services
  return_code $?
}
#******** cc_auto_syslogconfig

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
   ${rootfs}_services_start $*
}
#***** clusterfs_services_start

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
   ${rootfs}_services_restart $1 $2
}
#***** clusterfs_services_restart

#****f* clusterfs-lib.sh/clusterfs_mount
#  NAME
#    clusterfs_mount
#  SYNOPSIS
#    function clusterfs_mount(fstype, dev, mountpoint, mountopts)
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function clusterfs_mount {
  local fstype=$1
  local dev=$2
  local mountpoint=$3
  local mountopts=$4

  echo_local -n "Mounting $dev on $mountpoint.."
  if [ ! -e $dev ]; then 
    echo_local -n "device not fount error"
    failure
    return $return_c
  fi
  if [ ! -d $mountpoint ]; then 
    mkdir -p $mountpoint
  fi
  exec_local mount -t $fstype -o $mountopts $dev $mountpoint
  return_code
  return $return_c
}
#***** clusterfs_mount

#****f* gfs-lib.sh/cluster_restart_cluster_services
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
  ${rootfs}_restart_cluster_services $1 $2
}
#******** cluster_restart_cluster_services

#****f* clusterfs-lib.sh/clusterfs_mount_cdsl
#  NAME
#    clusterfs_mount_cdsl
#  SYNOPSIS
#    function clusterfs_mount_cdsl(mountpoint, cdsl_dir, nodeid, prefix="/cluster/cdsl")
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

  echo_local -n "Mounting $cdsl_dir on ${prefix}/${nodeid}.."
  if [ ! -d ${mountpoint}/${prefix} ]; then 
    echo_local "no cdsldir found \"${mountpoint}/${prefix}\""
    warning
  fi
  exec_local mount --bind  ${mountpoint}/${prefix}/${nodeid} ${mountpoint}/${cdsl_dir}
  return_code
}
#***** clusterfs__mount_cdsl

#****f* clusterfs-lib.sh/copy_relevant_files
#  NAME
#    copy_relevant_files
#  SYNOPSIS
#    function copy_relevant_files(cdsl_local_dir, newroot)
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function copy_relevant_files {
  local cdsl_local_dir=$1
  local new_root=$2

  # backup old files
  olddir=$(pwd)
#  if [ -n "$debug" ]; then set -x; fi
  echo_local -en "\tBacking up created config files [$cdsl_local_dir]"
  if [ -f $newroot/etc/sysconfig/hwconf ]; then
    exec_local mv -f $newroot/etc/sysconfig/hwconf $newroot/etc/sysconfig/hwconf.com_back
  fi
  return_code_passed

  echo_local -en "\tCreating config dirs if not exist.."
  if [ ! -d $newroot/${cdsl_local_dir}/etc ]; then 
    mkdir -p $newroot/${cdsl_local_dir}/etc
  fi &&
  if [ ! -d $newroot/${cdsl_local_dir}/etc/sysconfig ]; then 
    exec_local mkdir -p $newroot/${cdsl_local_dir}/etc/sysconfig
  fi
  return_code

  echo_local -en "\tCopying the configfiles ${cdsl_local_dir}.."
  cd $newroot/${cdsl_local_dir}/etc
  (cp -f $modules_conf $newroot/${cdsl_local_dir}/$modules_conf &&
   ([ -n "$cdsl_local_dir" ] && 
    cd $newroot && 
    ln -sf ../${cdsl_local_dir}/etc/$modules_conf etc/$modules_conf)
   cd sysconfig 
   [ ! -f  $newroot/${cdsl_local_dir}/etc/sysconfig/hwconf ] && 
   cp -f /etc/sysconfig/hwconf $newroot/${cdsl_local_dir}/etc/sysconfig/
   ([ -n "$cdsl_local_dir" ] && 
    [ ! -f ${cdsl_local_dir}/etc/sysconfig/hwconf ] && 
    cd $newroot && 
    ln -fs ${cdsl_local_dir}/etc/sysconfig/hwconf etc/sysconfig/hwconf))
#   [ ! -f $newroot/${cdsl_local_dir}/etc/sysconfig/network ] && 
#   cp -f /etc/sysconfig/network $newroot/${cdsl_local_dir}/etc/sysconfig/
#   ([ -n "$cdsl_local_dir" ] && 
#    [ ! -f $newroot/${cdsl_local_dir}/etc/sysconfig/network ] && 
#    cd $newroot/ && 
#    ln -fs ${cdsl_local_dir}/etc/sysconfig/network etc/sysconfig/network))
  return_code
}
#************ copy_relevant_files 


# $Log: clusterfs-lib.sh,v $
# Revision 1.1  2006-05-07 11:33:40  marc
# initial revision
#