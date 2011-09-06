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

set_timeouts()
{
	local chroot_path=$1
    local CLUSTER=$2
    local configfs_path=$3
    local O2CB_HEARTBEAT_THRESHOLD_FILE_OLD=${chroot_path}/proc/fs/ocfs2_nodemanager/hb_dead_threshold
    local O2CB_HEARTBEAT_THRESHOLD_FILE=${chroot_path}/${configfs_path}/cluster/${CLUSTER}/heartbeat/dead_threshold
    if [ -n "$O2CB_HEARTBEAT_THRESHOLD" ]; then
        if [ -f "$O2CB_HEARTBEAT_THRESHOLD_FILE" ]; then
            echo "$O2CB_HEARTBEAT_THRESHOLD" > "$O2CB_HEARTBEAT_THRESHOLD_FILE"
        elif [ -f "$O2CB_HEARTBEAT_THRESHOLD_FILE_OLD" ]; then
            echo "$O2CB_HEARTBEAT_THRESHOLD" > "$O2CB_HEARTBEAT_THRESHOLD_FILE_OLD"
        fi
    fi

    O2CB_IDLE_TIMEOUT_MS_FILE=${chroot_path}/${configfs_path}/cluster/${CLUSTER}/idle_timeout_ms
    if [ -n "$O2CB_IDLE_TIMEOUT_MS" ]; then
        if [ -f "$O2CB_IDLE_TIMEOUT_MS_FILE" ]; then
            echo "$O2CB_IDLE_TIMEOUT_MS" > "$O2CB_IDLE_TIMEOUT_MS_FILE"
        fi
    fi

    O2CB_KEEPALIVE_DELAY_MS_FILE=${chroot_path}/${configfs_path}/cluster/${CLUSTER}/keepalive_delay_ms
    if [ -n "$O2CB_KEEPALIVE_DELAY_MS" ]; then
        if [ -f "$O2CB_KEEPALIVE_DELAY_MS_FILE" ]; then
            echo "$O2CB_KEEPALIVE_DELAY_MS" > "$O2CB_KEEPALIVE_DELAY_MS_FILE"
        fi
    fi

    O2CB_RECONNECT_DELAY_MS_FILE=${chroot_path}/${configfs_path}/cluster/${CLUSTER}/reconnect_delay_ms
    if [ -n "$O2CB_RECONNECT_DELAY_MS" ]; then
        if [ -f "$O2CB_RECONNECT_DELAY_MS_FILE" ]; then
            echo "$O2CB_RECONNECT_DELAY_MS" > "$O2CB_RECONNECT_DELAY_MS_FILE"
        fi
    fi
}

#****f* boot-scripts/etc/clusterfs-lib.sh/ocfs2_getdefaults
#  NAME
#    ocfs2_getdefaults
#  SYNOPSIS
#    ocfs2_getdefaults(parameter)
#  DESCRIPTION
#    returns defaults for the specified filesystem. Parameter must be given to return the apropriate default
#  SOURCE
function ocfs2_getdefaults {
	local param=$1
	case "$param" in
		lock_method|lockmethod)
		    echo "ocfs2_dlm"
		    ;;
		mount_opts|mountopts)
		    echo "noatime"
		    ;;
		root_source|rootsource)
		    echo "scsi"
		    ;;
		rootfs|root_fs)
		    echo "ocfs2"
		    ;;
	    scsi_failover|scsifailover)
	        echo "mapper"
	        ;;
	    ip)
	        echo "cluster"
	        ;;
	    *)
	        return 0
	        ;;
	esac
}
#********** ocfs2_getdefaults

#************* ocfs2_chroot_needed
#  NAME
#    ocfs2_chroot_needed
#  SYNOPSIS
#    function ocfs2_chroot_needed(initrd|init|..)
#  DESCRIPTION
#    Returns 0 if this rootfilesystem needs a chroot inside initrd or init. Otherwise not 0
#  IDEAS
#  SOURCE
#
function ocfs2_chroot_needed {
	return 0
}
#*********** ocfs2_chroot_needed

#****f* ocfs2-lib.sh/ocfs2_get_drivers
#  NAME
#    ocfs2_get_drivers
#  SYNOPSIS
#    function ocfs2_get_drivers
#  DESCRIPTION
#    This function loads all relevant ocfs2 modules
#  IDEAS
#  SOURCE
#
function ocfs2_get_drivers {
	echo "configfs ocfs2_nodemanager ocfs2_dlm ocfs2_dlmfs ocfs2"
}
#************ ocfs2_get_drivers

#****f* ocfs2-lib.sh/ocfs2_load
#  NAME
#    ocfs2_load
#  SYNOPSIS
#    function ocfs2_load
#  DESCRIPTION
#    This function loads all relevant ocfs2 modules
#  IDEAS
#  SOURCE
#
function ocfs2_load {
   MODULES=$(ocfs2_get_drivers)
   echo_local -n "Loading OCFS2 modules ($MODULES)..."
   for module in $MODULES; do
      exec_local /sbin/modprobe ${module}
   done
   return_code

   echo_local_debug  "Loaded modules:"
   exec_local_debug /sbin/lsmod

   return $return_c
}
#************ ocfs2_load

#****f* ocfs2-lib.sh/ocfs2_services_start
#  NAME
#    ocfs2_services_start
#  SYNOPSIS
#    function ocfs2_services_start
#  DESCRIPTION
#    This function starts all relevant services
#  IDEAS
#  SOURCE
#
function ocfs2_services_start {
    local chroot_path=$1
    local lock_method=$2
    local lvm_sup=$3

    local CLUSTERCONF="/etc/ocfs2/cluster.conf"
    local CLUSTER=$(cc_get_clustername)
    
    echo_local -n "Creating $CLUSTERCONF ..."
    mkdir $(dirname $CLUSTERCONF) 2>/dev/null
    mkdir ${chroot_path}/$(dirname $CLUSTERCONF) 2>/dev/null
    cc_convert ocfs2 > $CLUSTERCONF &&
    cc_convert ocfs2 > ${chroot_path}/$CLUSTERCONF
    return_code $?
    
    if [ -z "$CLUSTER" ]
    then
        echo_local "O2CB cluster not known"
        return 1
    fi

    if ! [ -f ${CLUSTERCONF} ]
    then
        echo_local -n "Could not find O2CB cluster configuration : "
        return 1
    fi

	echo_local -n "Setting nodename as hostname (hostname=$nodename)"
	exec_local hostname $nodename
	return_code

    echo_local -n "Mounting configfs"
    exec_local mount -t configfs none /sys/kernel/config
    return_code

    echo_local -n "Mounting dlmfs"
    [ ! -d $chroot_path/dlm ] && mkdir /dlm
    exec_local mount -t ocfs2_dlmfs ocfs2_dlmfs /dlm
    return_code

    echo_local -n "Starting O2CB cluster ${CLUSTER}: "
    OUTPUT="`o2cb_ctl -H -n "${CLUSTER}" -t cluster -a online=yes 2>&1`"
    return_c=$?
    if [ $return_c -eq 0 ]
    then
        set_timeouts "/" $CLUSTER sys/kernel/config
        success
    else
    	failure
        echo_local "$OUTPUT"
    fi
    return $return_c
}
#************ ocfs2_services_start

#****f* ocfs2-lib.sh/ocfs2_services_stop
#  NAME
#    ocfs2_services_stop
#  SYNOPSIS
#    function ocfs2_services_stop
#  DESCRIPTION
#    This function stop all relevant services
#  IDEAS
#  SOURCE
#
function ocfs2_services_stop {
    local chroot_path=$1
    local lock_method=$2
    local lvm_sup=$3
    local CLUSTER=$(cc_get_clustername $(repository_get_value nodeid))
    
    echo_local -n "Stopping O2CB cluster ${CLUSTER}: "
    OUTPUT="`o2cb_ctl -H -n "${CLUSTER}" -t cluster -a online=no 2>&1`"
    return_c=$?
    if [ $return_c -ne 0 ]; then
    	echo_local "Error: $OUTPUT"
    fi
    return_code
    
    return $return_c
}
#************** ocfs2_services_stop

#****f* ocfs2-lib.sh/ocfs2_services_restart
#  NAME
#    ocfs2_services_restart
#  SYNOPSIS
#    function ocfs2_services_restart(lockmethod)
#  DESCRIPTION
#    This function loads all relevant gfs modules
#  IDEAS
#  SOURCE
#
function ocfs2_services_restart_newroot {
  local new_root=$1
  local lockmethod=$2
  local lvm_sup=$3

  echo_local -n "Umounting configfs. Hoping to be remouted later."
  exec_local umount /sys/kernel/config
  return_code
  
  echo_local -n "Moving dlmfs to $new_root/dlm"
  exec_local mount --move /dlm $new_root/dlm
  return_code

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
#************ ocfs2_services_restart

function ocfs2_checkhosts_alive {
	return 0
}
#********* ocfs2_checkhosts_alive

#****f* ocfs2-lib.sh/ocfs2_init
#  NAME
#    ocfs2_init
#  SYNOPSIS
#    function ocfs2_init(start|stop|restart)
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function ocfs2_init {
	case "$1" in
		start)
		  if ! is_mounted /sys/kernel/config; then
		    mount -t configfs configfs /sys/kernel/config
		  fi
		;;
		stop)
		  if is_mounted /sys/kernel/config; then
  		    umount /sys/kernel/config
		  fi
		;;
		restart)
		  ocfs2_init start
		  ocfs2_init stop
		;;
		*)
		;;
	esac
}
#********* ocfs2_init

#****f* ocfs2-lib.sh/ocfs2_fsck_needed
#  NAME
#    ocfs2_fsck_needed
#  SYNOPSIS
#    function ocfs2_fsck_needed(root, rootfs)
#  DESCRIPTION
#    Will always return 1 for no fsck needed. This can only be triggered by rootfsck 
#    bootoption.
#
function ocfs2_fsck_needed {
	local device=$1
	fsck -t noopts -T $device
}
#********* ocfs2_fsck_needed

#****f* ocfs2-lib.sh/ocfs2_fsck
#  NAME
#    ocfs2_fsck
#  SYNOPSIS
#    function ocfs2_fsck_needed(root, rootfs)
#  DESCRIPTION
#    If this function is called. It will always execute an ocfs2fsck on the given root.
#    Be very very carefull with this function!!
#
function ocfs2_fsck {
	local root="$1"
	local fsck="fsck.ocfs2"
	local options=""
	echo_local -n "Calling $fsck on filesystem $root"
	exec_local $fsck $options $root
	return_code
}
#********* ocfs2_fsck

#****f* ocfs2-lib.sh/ocfs2_get_mountopts
#  NAME
#    ocfs2_get_mountopts
#  SYNOPSIS
#    ocfs2_get_mountopts(nodename)
#  DESCRIPTION
#    Gets the mountopts for this node
#  IDEAS
#  SOURCE
#
function ocfs2_get_mountopts() {
   _mount_opts=$(ocfs2_get mountopts "$@")
   if [ -z "$_mount_opts" ]; then
     echo $default_mountopts
   else
     echo $_mount_opts
   fi
}
#************ ocfs2_get_mountopts

#****f* boot-scripts/etc/clusterfs-lib.sh/ocfs2_get
#  NAME
#    ocfs2_get
#  SYNOPSIS
#    ocfs2_get opts
#  DESCRIPTTION
#    returns the name of the cluster.
#  SOURCE
#
ocfs2_get() {
   cc_get $@
}
# *********** ocfs2_get
