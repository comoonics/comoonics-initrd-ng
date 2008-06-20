#
# $Id: clusterfs-lib.sh,v 1.22 2008-06-20 13:42:46 mark Exp $
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
  local _nodeid=$3
  local _nodename=$4
  local _foundmac=
  macs=$(ifconfig -a | grep -i hwaddr | awk '{print $5;};')
  for mac in $macs; do
    [ -z "$_nodeid" ] && _nodeid=$(cc_get_nodeid ${cluster_conf} $mac 2>/dev/null)
    [ -z "$_nodename" ] && _nodename=$(cc_get_nodename ${cluster_conf} $mac 2>/dev/null)
  done
  echo $_nodeid
  echo $_nodename

  cc_get_rootvolume ${cluster_conf} $_nodename
  echo
  cc_get_mountopts ${cluster_conf} $_nodename
  echo
  scsifailover=$(cc_get_scsifailover ${cluster_conf} $_nodename)
  [ -z "$scsifailover" ] && scsifailover="driver"
  echo $scsifailover
  __rootfs=$(cc_get_rootfs ${cluster_conf} $_nodename)
  [ -z "$__rootfs" ] && __rootfs=$(getRootFS $cluster_conf $nodeid $nodename)
  echo $__rootfs
  __rootsource=$(cc_get_rootsource ${cluster_conf} $_nodename)
  [ -z "$__rootsource" ] && __rootsource="scsi"
  echo $__rootsource

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
function cc_get_nodeid_by_nodename {
   local cluster_conf=$1
   local mac=$2

   ${clutype}_get_nodeid $cluster_conf $mac
}
#******* cc_get_nodeid

#****f* clusterfs-lib.sh/cc_get_clu_nodename
#  NAME
#    cc_get_clu_nodename
#  SYNOPSIS
#    function cc_get_clu_nodename()
#  DESCRIPTION
#    gets the cluster nodename of this node from the cluster infrastructure
#  SOURCE
function cc_get_clu_nodename {
  ${clutype}_get_clu_nodename
}
#******* cc_get_clu_nodename


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

   ${clutype}_get_nodeid $cluster_conf $mac
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

   ${clutype}_get_nodename $cluster_conf $mac
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

   ${clutype}_get_rootfs $cluster_conf $nodename
}
#******** cc_get_rootfs

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

   ${clutype}_get_mountopts $cluster_conf $nodename
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

   local dir=$(${clutype}_get_chroot_dir $cluster_conf $nodename)
   if [ -n "$dir" ]; then
      echo $dir
   else
      cc_get_chroot_mountpoint $cluster_conf $nodename
   fi
}
#******** cc_get_chroot_dir


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
#  SOURCE
function cc_auto_netconfig {
   local cluster_conf=$1
   local nodename=$2
   local netdev=$3

   ${clutype}_auto_netconfig $cluster_conf $nodename $netdev
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

   cp /etc/hosts /etc/hosts.bak
   ${clutype}_auto_hosts $cluster_conf /etc/hosts.bak > /etc/hosts
}
#******** cc_auto_netconfig

#****f* clusterfs-lib.sh/cc_auto_syslogconfig
#  NAME
#    cc_auto_syslogconfig
#  SYNOPSIS
#    function cc_auto_syslogconfig(cluster_conf, nodename, chroot_path, locallog)
#  DESCRIPTION
#    creates config for the syslog service
#    to enable local logging use "yes"
#  SOURCE
function cc_auto_syslogconfig {
  local cluster_conf=$1
  local nodename=$2
  local chroot_path=$3
  local local_log=$4
  local syslog_server_list=$(${clutype}_get_syslogserver $cluster_conf $nodename)

  if [ -n "$syslog_server_list" ]; then
    echo_local -n "Creating syslog config for syslog servers: $syslog_server_list"
    exec_local /bin/rm $chroot_path/etc/syslog.conf
    for syslog_server in $syslog_server_list; do
  	  echo '*.* @'"$syslog_server" >> $chroot_path/etc/syslog.conf
    done
    if [ "$local_log" == "yes" ]; then
      echo "*.* -/var/log/comoonics_boot.syslog" >> $chroot_path/etc/syslog.conf
    fi

    echo "syslog          514/udp" >> $chroot_path/etc/services
    return_code 0
    return 0
  else
#    return_code 1
    return 1
  fi
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
   ${rootfs}_services_restart_newroot $*
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
  [ -n $5 ] && tries=$5
  local waittime=5
  [ -n $6 ] && waittime=$6
  local i=0

  #TODO: skip device check at least for nfs services
  echo_local -n "Mounting $dev on $mountpoint.."
  if [ ! -e $dev -a $fstype != "nfs" ]; then
    echo_local -n "device not found error"
    failure
    return $?
  fi
  if [ ! -d $mountpoint ]; then
    mkdir -p $mountpoint
  fi
  echo_local_debug "tries: $tries, waittime: $waittime"
  while [ $i -lt $tries ]; do
  	echo_local_debug "try: $i"
  	let i=$i+1
  	sleep $waittime
  	exec_local mount -t $fstype -o $mountopts $dev $mountpoint && break
  done
  return_code
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
   ${rootfs}_checkhosts_alive
}
#********* cluster_checkhosts_alive

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
  echo_local -n ".(hw $return_c)."
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
# Revision 1.22  2008-06-20 13:42:46  mark
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
