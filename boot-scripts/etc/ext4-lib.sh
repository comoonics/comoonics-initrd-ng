#
# $Id: ext4-lib.sh,v 1.10 2010/08/18 11:49:27 marc Exp $
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

#****h* comoonics-bootimage/ext4-lib.sh
#  NAME
#    ext4-lib.sh
#    $id$
#  DESCRIPTION
#*******

#****f* ext4-lib.sh/ext4_load
#  NAME
#    ext4_load
#  SYNOPSIS
#    function ext4_load
#  DESCRIPTION
#    This function loads all relevant ext4 modules
#  IDEAS
#  SOURCE
#
function ext4_load {

  EXT_MODULES="ext4"

  echo_local -n "Loading EXT4 modules ($EXT4_MODULES)..."
  for module in ${EXT4_MODULES}; do
    exec_local /sbin/modprobe ${module}
  done
  return_code

  echo_local_debug  "Loaded modules:"
  exec_local_debug /sbin/lsmod

  return $return_c
}
#************ ext4_load

#****f* clusterfs-lib.sh/ext4_get_drivers
#  NAME
#    ext4_get_drivers
#  SYNOPSIS
#    function ext4_get_drivers()
#  DESCRIPTION
#    Returns the all drivers for this clusterfs. 
#  SOURCE
function ext4_get_drivers {
	echo "ext4 ext3 jbd"
}
#*********** ext4_get_drivers

#****f* ext4-lib.sh/ext4_services_start
#  NAME
#    ext4_services_start
#  SYNOPSIS
#    function ext4_services_start
#  DESCRIPTION
#    This function starts all relevant services
#  IDEAS
#  SOURCE
#
function ext4_services_start {
	return 0
}
#************ ext4_services_start

#****f* ext4-lib.sh/ext4_services_restart
#  NAME
#    ext4_services_restart
#  SYNOPSIS
#    function ext4_services_restart(lockmethod)
#  DESCRIPTION
#    This function restarts all ext4 relevant services
#  IDEAS
#  SOURCE
#
function ext4_services_restart {
	return 0
}
#************ ext4_services_restart

function ext4_checkhosts_alive {
	return 0
}
#********* ext4_checkhosts_alive

#************* ext4_chroot_needed
#  NAME
#    ext4_chroot_needed
#  SYNOPSIS
#    function ext4_chroot_needed(initrd|init|..)
#  DESCRIPTION
#    Returns 0 if this rootfilesystem needs a chroot inside initrd or init. Otherwise not 0
#  IDEAS
#  SOURCE
#
function ext4_chroot_needed {
	return 1
}
#*********** ext4_chroot_needed

#****f* boot-scripts/etc/ext4-lib.sh/ext4_getdefaults
#  NAME
#    ext4_getdefaults
#  SYNOPSIS
#    ext4_getdefaults(parameter)
#  DESCRIPTION
#    returns defaults for the specified filesystem. Parameter must be given to return the apropriate default
#  SOURCE
function ext4_getdefaults {
	local param=$1
	case "$param" in
		lock_method|lockmethod)
		    echo ""
		    ;;
		mount_opts|mountopts)
		    echo "ro"
		    ;;
		root_source|rootsource)
		    echo "scsi"
		    ;;
        readonly)
            echo 1
            ;;
	    scsi_failover|scsifailover)
	        echo "driver"
	        ;;
	    *)
	        return 0
	        ;;
	esac
}
#********** ext4_getdefaults

#****f* ext4-lib.sh/ext4_services_restart_newroot
#  NAME
#    ext4_services_restart_newroot
#  SYNOPSIS
#    function ext4_services_restart_newroot(lockmethod)
#  DESCRIPTION
#    This function loads all relevant gfs modules
#  IDEAS
#  SOURCE
#
function ext4_services_restart_newroot {
  local chroot_path=$1
  local lock_method=$2
  local lvm_sup=$3

  echo "Umounting $chroot_path/proc"
  exec_local umount $chroot_path/proc
  return_code
}
#************ ext4_services_restart_newroot

#****f* ext4-lib.sh/ext4_fsck_needed
#  NAME
#    ext4_fsck_needed
#  SYNOPSIS
#    function ext4_fsck_needed(root, rootfs)
#  DESCRIPTION
#    Will always return 1 for no fsck needed. This can only be triggered by rootfsck 
#    bootoption.
#
function ext4_fsck_needed {
	local device=$1
	local fsck="fsck"
	local options="-t noopts -T"
	$fsck $options $device 2>/dev/null
}
#********* ext4_fsck_needed

#****f* ext4-lib.sh/ext4_fsck
#  NAME
#    ext4_fsck
#  SYNOPSIS
#    function ext4_fsck_needed(root, rootfs)
#  DESCRIPTION
#    If this function is called. It will always execute an ext4fsck on the given root.
#    Be very very carefull with this function!!
#
function ext4_fsck {
	local root="$1"
	local fsck="fsck.ext4"
	local options=""
	echo_local -n "Calling $fsck on filesystem $root"
	exec_local $fsck $options $root
	return_code
}
#********* ext4_fsck

#****f* ext4-lib.sh/ext4_get_mountopts
#  NAME
#    ext4_get_mountopts
#  SYNOPSIS
#    ext4_get_mountopts(cluster_conf, nodename)
#  DESCRIPTION
#    Gets the mountopts for this node
#  IDEAS
#  SOURCE
#
function ext4_get_mountopts() {
   local xml_file=$1
   local hostname=$2
   [ -z "$hostname" ] && hostname=$(ext4_get_nodename $xml_file)
   local xml_cmd="${ccs_xml_query} -f $xml_file"
   _mount_opts=$($xml_cmd -q mountopts $hostname)
   if [ -z "$_mount_opts" ]; then
     echo $default_mountopts
   else
     echo $_mount_opts
   fi
}
#************ ext4_get_mountopts

#****f* boot-scripts/etc/clusterfs-lib.sh/ext4_get
#  NAME
#    ext4_get
#  SYNOPSIS
#    ext4_get [cluster_conf] [querymap] opts
#  DESCRIPTTION
#    returns the name of the cluster.
#  SOURCE
#
ext4_get() {
   cc_get $@
}
# *********** ext4_get

# $Log: ext4-lib.sh,v $
#
