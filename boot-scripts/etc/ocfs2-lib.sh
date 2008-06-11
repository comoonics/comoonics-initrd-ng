#
# $Id: ocfs2-lib.sh,v 1.2 2008-06-11 15:03:25 marc Exp $
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
   MODULES="configfs ocfs2_nodemanager ocfs2_dlm ocfs2_dlmfs"
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
    local CLUSTER=$(com-queryclusterconf query_value /cluster/@name)
    
    echo_local -n "Creating $CLUSTERCONF ..."
    mkdir /etc/ocfs2
    com-queryclusterconf convert ocfs2 > $CLUSTERCONF &&
    com-queryclusterconf convert ocfs2 > ${chroot_path}/$CLUSTERCONF
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
    if [ $? = 0 ]
    then
        set_timeouts "/" $CLUSTER sys/kernel/config
        success
        return 0
    else
    	failed
        echo_local "$OUTPUT"
        return 1
    fi
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
    local CLUSTER=$(com-queryclusterconf query_value /cluster/@name)
    
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
		mount -t configfs configfs /sys/kernel/config
		;;
		stop)
		umount /sys/kernel/config
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

# $Log: ocfs2-lib.sh,v $
# Revision 1.2  2008-06-11 15:03:25  marc
# - more output when failing to leave cluster
#
# Revision 1.1  2008/06/10 09:59:26  marc
# *** empty log message ***
#
# Revision 1.2  2007/12/07 16:39:59  reiner
# Added GPL license and changed ATIX GmbH to AG.
#
# Revision 1.1  2007/03/09 17:56:33  mark
# initial check in
#
