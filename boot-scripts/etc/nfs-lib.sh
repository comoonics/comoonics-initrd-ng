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

#****h* comoonics-bootimage/nfs-lib.sh
#  NAME
#    gfs-lib.sh
#    $id$
#  DESCRIPTION
#*******

# functions for nfsversion 4
function nfs4_getdefaults {
	local param=$1
	case "$param" in
		lock_method|lockmethod)
		    echo ""
		    ;;
		mount_opts|mountopts)
		    echo ""
		    ;;
	    *)
	        return 0
	        ;;
	esac
}
function nfs4_init {
	nfs_init $*
}
function nfs4_load {
	nfs_load $*
}
function nfs4_services_start {
  local services="rpcpipefs rpcbind rpc_idmapd"
  for service in $services; do
    nfs4_start_$service $*    
  done
  return 0
}
function nfs4_services_stop {
  local services="rpc_idmapd rpcbind rpcpipefs"
  for service in $services; do
    nfs4_stop_$service $*
  done
  return 0
}
# obsolete
#function nfs4_services_restart {
#	return nfs_services_restart $* 
#}
function nfs4_start_rpcpipefs {
	nfs_start_rpcpipefs $*
}
function nfs4_stop_rpcpipefs {
	nfs_stop_rpcpipefs $*
}
function nfs4_get_drivers {
	nfs_get_drivers $*
}
function nfs4_services_restart_newroot {
  local newroot=$1
  local lock_method=$2
  local lvm_sup=$3
  local chroot_path=$4

  local services=""
  if [ -n "$services" ]; then
    for service in $services; do
      exec_local nfs4_stop_$service "no_chroot"
      if [ $? -ne 0 ]; then
        return $?
      fi
    done

    for service in $services; do
      exec_local nfs4_start_$service "$newroot" "$lock_method" "$lvm_sup" "$chroot_path"
      if [ $? -ne 0 ]; then
        return $?
      fi
    done
  fi

#  nfs_services_restart_newroot $*

  if [ -d "$newroot/var/lib/nfs/rpc_pipefs" ]; then
    rm -rf $newroot/var/lib/nfs/rpc_pipefs 2>/dev/null
    ln -s $newroot/$chroot_path/var/lib/nfs/rpc_pipefs $newroot/var/lib/nfs/rpc_pipefs 2>/dev/null
  fi

  if is_mounted $new_root/proc; then
     for path in $(get_dep_filesystems $new_root/proc); do
        echo_local -n "Umounting filesystem $path"
        exec_local umount_filesystem $path
        return_code
     done
  fi
  echo_local -n "Umounting $new_root/proc"
  exec_local umount_filesystem $new_root/proc
  return_code $?

  return $return_c
}

#****f* nfs-lib.sh/nfs4_start_rpcbind
#  NAME
#    nfs4_start_rpcbind
#  SYNOPSIS
#    function nfs4_start_rpcbind
#  DESCRIPTION
#    This function starts the rpcbind daemon
#  IDEAS
#  SOURCE
#
function nfs4_start_rpcbind {
  nfs_start_rpcbind $*
}
#************ nfs4_start_rpcbind

#****f* nfs-lib.sh/nfs4_stop_rpcbind
#  NAME
#    nfs4_stop_rpcbind
#  SYNOPSIS
#    function nfs4_stop_rpcbind
#  DESCRIPTION
#    This function stops the rpcbind daemon
#  IDEAS
#  SOURCE
#
function nfs4_stop_rpcbind {
  nfs_stop_rpcbind $*
}
#************ nfs4_stop_rpcbind

#****f* nfs-lib.sh/nfs4_start_portmap
#  NAME
#    nfs4_start_portmap
#  SYNOPSIS
#    function nfs4_start_portmap
#  DESCRIPTION
#    This function starts the rpcbind daemon
#  IDEAS
#  SOURCE
#
function nfs4_start_portmap {
  nfs_start_portmap $*
}
#************ nfs4_start_portmap

#****f* nfs-lib.sh/nfs4_stop_portmap
#  NAME
#    nfs4_stop_portmap
#  SYNOPSIS
#    function nfs4_stop_portmap
#  DESCRIPTION
#    This function stops the rpcbind daemon
#  IDEAS
#  SOURCE
#
function nfs4_stop_portmap {
  nfs_stop_portmap $*
}
#************ nfs4_stop_portmap

#****f* nfs-lib.sh/nfs4_start_rpc_idmapd
#  NAME
#    nfs4_start_rpc_idmapd
#  SYNOPSIS
#    function nfs4_start_rpc_idmapd
#  DESCRIPTION
#    This function starts the rpc4_idmapd daemon
#  IDEAS
#  SOURCE
#
function nfs4_start_rpc_idmapd {
  local chrootpath=$1
  if [ -z $chrootpath ] || [ "$chrootpath" = "no_chroot" ]; then
	  start_service $chrootpath rpc.idmapd && \
	  touch /var/lock/subsys/rpcidmapd 2>/dev/null
  else
      start_service_chroot $chrootpath rpc.idmapd && \
	  touch $chrootpath/var/lock/subsys/rpcidmapd 2>/dev/null
  fi
}
#************ nfs4_start_rpc_idmapd

#****f* nfs-lib.sh/nfs4_stop_rpc_idmapd
#  NAME
#    nfs4_stop_rpc_idmapd
#  SYNOPSIS
#    function nfs4_stop_rpc_idmapd
#  DESCRIPTION
#    This function stops the rpc4_idmapd daemon
#  IDEAS
#  SOURCE
#
function nfs4_stop_rpc_idmapd {
  killall rpc.idmapd && \
  rm $1/var/lock/subsys/rpcidmapd 2>/dev/null
}
#************ nfs4_stop_rpc_idmapd

function nfs4_checkhosts_alive {
	nfs_checkhosts_alive $*
}
#************* nfs4_chroot_needed
#  NAME
#    nfs4_blkstorage_needed
#  SYNOPSIS
#    function nfs4_blkstorage_needed(initrd|init|..)
#  DESCRIPTION
#    Returns 0 if this rootfilesystem needs a blkstorage inside initrd or init.
#  IDEAS
#  SOURCE
#
function nfs4_blkstorage_needed {
	return 1
}
#************ nfs_blkstorage_needed

# for nfsv4 we need a chroot cause some services (rpc.idmapd, rpcbind) have to be running
# not on the rootfs. 
function nfs4_chroot_needed {
	return 0
}

#****f* nfs-lib.sh/nfs4_get_userspace_procs
#  NAME
#    nfs4_get_userspace_procs
#  SYNOPSIS
#    function nfs4_get_userspace_procs(nodename)
#  DESCRIPTION
#    gets userspace programs that are to be running dependent on rootfs
#  SOURCE
function nfs4_get_userspace_procs {
  local clutype=$1
  local rootfs=$2

  echo -e "rpcbind \n\
rpc.idmapd"
}
#******** nfs4_get_userspace_procs

#************* nfs_chroot_needed
#  NAME
#    nfs_chroot_needed
#  SYNOPSIS
#    function nfs_chroot_needed(initrd|init|..)
#  DESCRIPTION
#    Returns 0 if this rootfilesystem needs a chroot inside initrd or init. Otherwise not 0
#  IDEAS
#  SOURCE
#
function nfs_chroot_needed {
	return 1
}
#*********** nfs_chroot_needed

#************* nfs_chroot_needed
#  NAME
#    nfs_blkstorage_needed
#  SYNOPSIS
#    function nfs_blkstorage_needed(initrd|init|..)
#  DESCRIPTION
#    Returns 0 if this rootfilesystem needs a blkstorage inside initrd or init.
#  IDEAS
#  SOURCE
#
function nfs_blkstorage_needed {
	return 1
}
#************ nfs_blkstorage_needed


#****f* boot-scripts/etc/clusterfs-lib.sh/nfs_getdefaults
#  NAME
#    nfs_getdefaults
#  SYNOPSIS
#    nfs_getdefaults(parameter)
#  DESCRIPTION
#    returns defaults for the specified filesystem. Parameter must be given to return the apropriate default
#  SOURCE
function nfs_getdefaults {
	local param=$1
	case "$param" in
		lock_method|lockmethod)
		    echo ""
		    ;;
		mount_opts|mountopts)
		    echo "nolock"
		    ;;
		mounttimes|mountwait)
			echo "2"
			;;
	    *)
	        return 0
	        ;;
	esac
}
#********** clusterfs_getdefaults

#****f* clusterfs-lib.sh/nfs_get_drivers
#  NAME
#    nfs_get_drivers
#  SYNOPSIS
#    function nfs_get_drivers()
#  DESCRIPTION
#    Returns the all drivers for this clusterfs. 
#  SOURCE
function nfs_get_drivers {
	echo "sunrpc nfs lockd fscache nfs_acl"
}
#*********** nfs_get_drivers

#****f* nfs-lib.sh/nfs_get_mountopts
#  NAME
#    nfs_get_mountopts
#  SYNOPSIS
#    nfs_get_mountopts(nodename)
#  DESCRIPTION
#    Gets the mountopts for this node
#  IDEAS
#  SOURCE
#
function nfs_get_mountopts() {
   _mount_opts=$(nfs_get mountopts "$@")
   if [ -z "$_mount_opts" ]; then
     echo $default_mountopts
   else
     echo $_mount_opts
   fi
}
#************ nfs_get_mountopts

#****f* nfs-lib.sh/nfs_load
#  NAME
#    nfs_load
#  SYNOPSIS
#    function nfs_load
#  DESCRIPTION
#    This function loads all relevant nfs modules
#  IDEAS
#  SOURCE
#
function nfs_load {

  local NFS_MODULES="$(nfs_get_drivers)"

  echo_local -n "Loading NFS modules ($NFS_MODULES)..."
  for module in ${NFS_MODULES}; do
    exec_local /sbin/modprobe ${module}
  done

  echo_local_debug  "Loaded modules:"
  exec_local_debug /sbin/lsmod

  return $return_c
}
#************ nfs_load

#****f* nfs-lib.sh/nfs_services_start
#  NAME
#    nfs_services_start
#  SYNOPSIS
#    function nfs_services_start
#  DESCRIPTION
#    This function starts all relevant services
#  IDEAS
#  SOURCE
#
function nfs_services_start {
  local services="portmap"
  for service in $services; do
    nfs_start_$service $*
  done
  return 0
}
#************ nfs_services_start

#****f* nfs-lib.sh/nfs_services_stop
#  NAME
#    nfs_services_stop
#  SYNOPSIS
#    function nfs_services_stop
#  DESCRIPTION
#    This function starts all relevant services
#  IDEAS
#  SOURCE
#
function nfs_services_stop {
  local services="portmap"
  for service in $services; do
    nfs_stop_$service $*
  done
  return 0
}
#************ nfs_services_stop

#****f* nfs-lib.sh/nfs_start_rpcpipefs
#  NAME
#    nfs_start_rpcpipefs
#  SYNOPSIS
#    function nfs_start_rpcpipefs
#  DESCRIPTION
#    This function mounts the rpcpipefs and creates the link for it.
#  IDEAS
#  SOURCE
#
function nfs_start_rpcpipefs {
  local newrootpath=$1
  local chroot_path=$4
  local precmd=""
  echo_local_debug "nfs_start_rpcpipefs($newrootpath, $chroot_path)"
  local pipefspath="/var/lib/nfs/rpc_pipefs"
  if [ -n "$newrootpath" ] && [ ! -d $(dirname ${newrootpath}${pipefspath}) ]; then
    if [ -e ${newrootpath}$(dirname ${pipefspath}) ] || [ -L ${newrootpath}$(dirname ${pipefspath}) ]; then
      rm -f ${newrootpath}$(dirname ${pipefspath}) 2>/dev/null
    fi
    if [ -z "$chroot_path" ] && [ ! -d ${newrootpath}$(dirname ${pipefspath}) ]; then
  		mkdir -p ${newrootpath}$(dirname ${pipefspath}) 2>/dev/null
	fi
  fi
  if [ -n "$newrootpath" ] && [ ! -d ${newrootpath}${pipefspath} ]; then
    if [ -e ${newrootpath}${pipefspath} ] || [ -L ${newrootpath}${pipefspath} ]; then
      rm -f ${newrootpath}${pipefspath} 2>/dev/null
    fi
    if [ -z "$chroot_path" ] && [ ! -d "${newrootpath}${pipefspath}" ]; then
  		mkdir -p ${newrootpath}${pipefspath} 2>/dev/null
	fi
  fi
  [ -n "$newrootpath" ] && [ -d "$newrootpath" ] && precmd="chroot $newrootpath "
  exec_local $precmd mount -t rpc_pipefs sunrpc ${chroot_path}/${pipefspath}
  if [ -n "$newrootpath" ] && [ -e ${pipefspath} ]; then
  	mv ${pipefspath} ${pipefspath}.old 2>/dev/null
  fi
  if [ -n "$newrootpath" ] && [ -z "$chroot_path" ]; then
    ln -s ${newrootpath}${pipefspath} ${pipefspath} 2>/dev/null
  fi
  if [ -n "$newrootpath" ] && [ -n "$chroot_path" ]; then
    ln -s ${newrootpath}/${chroot_path}/${pipefspath} ${newrootpath}/${pipefspath} 2>/dev/null
  fi
  touch $newrootpath/var/lock/subsys/rpcpipefs 2>/dev/null
}
#************ nfs_start_rpcpipefs

#****f* nfs-lib.sh/nfs_stop_rpcpipefs
#  NAME
#    nfs_stop_rpcpipefs
#  SYNOPSIS
#    function nfs_stop_rpcpipefs
#  DESCRIPTION
#    This function mounts the rpcpipefs and creates the link for it.
#  IDEAS
#  SOURCE
#
function nfs_stop_rpcpipefs {
	rm $1/var/lock/subsys/rpcpipefs 2>/dev/null
	true
}
#************ nfs_stop_rpcpipefs

#****f* nfs-lib.sh/nfs_start_rpcbind
#  NAME
#    nfs_start_rpcbind
#  SYNOPSIS
#    function nfs_start_rpcbind
#  DESCRIPTION
#    This function starts the rpcbind daemon
#  IDEAS
#  SOURCE
#
function nfs_start_rpcbind {
  local chrootpath=$1
  if [ -z $chrootpath ] || [ "$chrootpath" = "no_chroot" ]; then
	  start_service $chrootpath /sbin/rpcbind && \
	  touch /var/lock/subsys/rpcbind 2>/dev/null
  else
      start_service_chroot $chrootpath /sbin/rpcbind && \
	  touch $chrootpath/var/lock/subsys/rpcbind 2>/dev/null
  fi
}
#************ nfs_start_rpcbind

#****f* nfs-lib.sh/nfs_stop_rpcbind
#  NAME
#    nfs_stop_rpcbind
#  SYNOPSIS
#    function nfs_stop_rpcbind
#  DESCRIPTION
#    This function stops the rpcbind daemon
#  IDEAS
#  SOURCE
#
function nfs_stop_rpcbind {
  killall rpcbind && \
  rm $1/var/lock/subsys/rpcbind  2>/dev/null
}
#************ nfs_stop_rpcbind

#****f* nfs-lib.sh/nfs_start_portmap
#  NAME
#    nfs_start_portmap
#  SYNOPSIS
#    function nfs_start_portmap
#  DESCRIPTION
#    This function starts the portmap daemon
#  IDEAS
#  SOURCE
#
function nfs_start_portmap {
  local chrootpath=$1
  if [ -z $chrootpath ] || [ "$chrootpath" = "no_chroot" ]; then
	  start_service $chrootpath /sbin/portmap && \
	  touch /var/lock/subsys/portmap 2>/dev/null
  else
      start_service_chroot $chrootpath /sbin/portmap && \
	  touch $chrootpath/var/lock/subsys/portmap 2>/dev/null
  fi
}
#************ nfs_start_portmap

#****f* nfs-lib.sh/nfs_stop_portmap
#  NAME
#    nfs_stop_portmap
#  SYNOPSIS
#    function nfs_stop_portmap
#  DESCRIPTION
#    This function starts the portmap daemon
#  IDEAS
#  SOURCE
#
function nfs_stop_portmap {
  killall portmap 2>/dev/null && \
  rm $1/var/lock/subsys/portmap 2>/dev/null
}
#************ nfs_stop_portmap

#****f* nfs-lib.sh/nfs_start_rpc_lockd
#  NAME
#    nfs_start_rpc_lockd
#  SYNOPSIS
#    function nfs_start_rpc_lockd
#  DESCRIPTION
#    This function starts the rpc_lockd daemon
#  IDEAS
#  SOURCE
#
function nfs_start_rpc_lockd {
  local chrootpath=$1
  if [ -z $chrootpath ] || [ "$chrootpath" = "no_chroot" ]; then
	  start_service $chrootpath /sbin/rpc.lockd && \
	  touch /var/lock/subsys/rpclockd 2>/dev/null
  else
      start_service_chroot $chrootpath /sbin/rpc.lockd && \
	  touch $chrootpath/var/lock/subsys/rpclockd 2>/dev/null
  fi
}
#************ nfs_start_rpc_lockd

#****f* nfs-lib.sh/nfs_start_rpc_statd
#  NAME
#    nfs_start_rpc_statd
#  SYNOPSIS
#    function nfs_start_rpc_statd
#  DESCRIPTION
#    This function starts the rpc_statd daemon
#  IDEAS
#  SOURCE
#
function nfs_start_rpc_statd {
  local chrootpath=$1
  if [ -z $chrootpath ] || [ "$chrootpath" = "no_chroot" ]; then
	  start_service $chrootpath /sbin/rpc.statd && \
	  touch /var/lock/subsys/rpcstatd 2>/dev/null
  else
      start_service_chroot $chrootpath /sbin/rpc.statd && \
	  touch $chrootpath/var/lock/subsys/rpcstatd 2>/dev/null
  fi
}
#************ nfs_start_rpc_statd

#****f* nfs-lib.sh/nfs_stop_rpc_statd
#  NAME
#    nfs_stop_rpc_statd
#  SYNOPSIS
#    function nfs_stop_rpc_statd
#  DESCRIPTION
#    This function stops the rpc.statd daemon
#  IDEAS
#  SOURCE
#
function nfs_stop_rpc_statd {
  local chrootpath=$1
  stop_service rpc.statd "$chrootpath"
}
#************ nfs_start_rpc_stop

#****f* nfs-lib.sh/nfs_services_restart_newroot
#  NAME
#    nfs_services_restart_newroot
#  SYNOPSIS
#    function nfs_services_restart_newroot(lockmethod)
#  DESCRIPTION
#    This function loads all relevant nfs modules
#  IDEAS
#  SOURCE
#
function nfs_services_restart_newroot {
  local new_root=$1
  local lock_method=$2
  local lvm_sup=$3

  services="portmap"
  for service in $services; do
    nfs_stop_$service $new_root
  done
  services="rpcpipefs"
  for service in $services; do
    nfs_start_$service $new_root
  done
#  nfs_stop_portmap $chroot_path

  if is_mounted $new_root/proc; then
     for path in $(get_dep_filesystems $new_root/proc); do
        echo_local -n "Umounting filesystem $path"
        exec_local umount_filesystem $path
        return_code
     done
  fi
  echo_local -n "Umounting $new_root/proc"
  exec_local umount_filesystem $new_root/proc
  return_code $?
}
#************ nfs_services_restart_newroot

function nfs_checkhosts_alive {
	return 0
}
#********* nfs_checkhosts_alive

#****f* nfs-lib.sh/nfs_init
#  NAME
#    nfs_init
#  SYNOPSIS
#    function nfs_init(start|stop|restart)
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function nfs_init {
	return 0
}
#********* nfs_init

#****f* nfs-lib.sh/nfs_get_userspace_procs
#  NAME
#    nfs_get_userspace_procs
#  SYNOPSIS
#    function nfs_get_userspace_procs(clust er_conf,nodename)
#  DESCRIPTION
#    gets userspace programs that are to be running dependent on rootfs
#  SOURCE
function nfs_get_userspace_procs {
  local clutype=$1
  local rootfs=$2

  echo -e ""
}
#******** nfs_get_userspace_procs

#****f* boot-scripts/etc/clusterfs-lib.sh/nfs_get
#  NAME
#    nfs_get
#  SYNOPSIS
#    nfs_get opts
#  DESCRIPTTION
#    returns the name of the cluster.
#  SOURCE
#
nfs_get() {
   cc_get $@
}
# *********** nfs_get
