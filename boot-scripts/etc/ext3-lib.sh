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

#****h* comoonics-bootimage/ext3-lib.sh
#  NAME
#    ext3-lib.sh
#    $id$
#  DESCRIPTION
#*******

#****f* ext3-lib.sh/ext3_load
#  NAME
#    ext3_load
#  SYNOPSIS
#    function ext3_load
#  DESCRIPTION
#    This function loads all relevant ext3 modules
#  IDEAS
#  SOURCE
#
function ext3_load {

  EXT3_MODULES="ext3"

  echo_local -n "Loading EXT3 modules ($EXT3_MODULES)..."
  for module in ${EXT3_MODULES}; do
    exec_local /sbin/modprobe ${module}
  done
  return_code

  echo_local_debug  "Loaded modules:"
  exec_local_debug /sbin/lsmod

  return $return_c
}
#************ ext3_load

#****f* clusterfs-lib.sh/ext3_get_drivers
#  NAME
#    ext3_get_drivers
#  SYNOPSIS
#    function ext3_get_drivers()
#  DESCRIPTION
#    Returns the all drivers for this clusterfs. 
#  SOURCE
function ext3_get_drivers {
	echo "ext3 jbd"
}
#*********** ext3_get_drivers

#****f* ext3-lib.sh/ext3_services_start
#  NAME
#    ext3_services_start
#  SYNOPSIS
#    function ext3_services_start
#  DESCRIPTION
#    This function starts all relevant services
#  IDEAS
#  SOURCE
#
function ext3_services_start {
	return 0
}
#************ ext3_services_start

#****f* ext3-lib.sh/ext3_services_restart
#  NAME
#    ext3_services_restart
#  SYNOPSIS
#    function ext3_services_restart(lockmethod)
#  DESCRIPTION
#    This function restarts all ext3 relevant services
#  IDEAS
#  SOURCE
#
function ext3_services_restart {
	return 0
}
#************ ext3_services_restart

function ext3_checkhosts_alive {
	return 0
}
#********* ext3_checkhosts_alive

#************* ext3_chroot_needed
#  NAME
#    ext3_chroot_needed
#  SYNOPSIS
#    function ext3_chroot_needed(initrd|init|..)
#  DESCRIPTION
#    Returns 0 if this rootfilesystem needs a chroot inside initrd or init. Otherwise not 0
#  IDEAS
#  SOURCE
#
function ext3_chroot_needed {
	return 1
}
#*********** ext3_chroot_needed

#****f* boot-scripts/etc/ext3-lib.sh/ext3_getdefaults
#  NAME
#    ext3_getdefaults
#  SYNOPSIS
#    ext3_getdefaults(parameter)
#  DESCRIPTION
#    returns defaults for the specified filesystem. Parameter must be given to return the apropriate default
#  SOURCE
function ext3_getdefaults {
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
#********** ext3_getdefaults

#****f* ext3-lib.sh/ext3_services_restart_newroot
#  NAME
#    ext3_services_restart_newroot
#  SYNOPSIS
#    function ext3_services_restart_newroot(lockmethod)
#  DESCRIPTION
#    This function loads all relevant gfs modules
#  IDEAS
#  SOURCE
#
function ext3_services_restart_newroot {
	return 0
}
#************ ext3_services_restart_newroot

#****f* ext3-lib.sh/ext3_fsck_needed
#  NAME
#    ext3_fsck_needed
#  SYNOPSIS
#    function ext3_fsck_needed(root, rootfs)
#  DESCRIPTION
#    Will always return 1 for no fsck needed. This can only be triggered by rootfsck 
#    bootoption.
#
function ext3_fsck_needed {
	local device=$1
	local fsck="fsck"
	local options="-t noopts -T"
	$fsck $options $device 2>/dev/null
}
#********* ext3_fsck_needed

#****f* ext3-lib.sh/ext3_fsck
#  NAME
#    ext3_fsck
#  SYNOPSIS
#    function ext3_fsck_needed(root, rootfs)
#  DESCRIPTION
#    If this function is called. It will always execute an ext3fsck on the given root.
#    Be very very carefull with this function!!
#
function ext3_fsck {
	local root="$1"
	local fsck="fsck.ext3"
	local options=""
	echo_local -n "Calling $fsck on filesystem $root"
	exec_local $fsck $options $root
	return_code
}
#********* ext3_fsck

#****f* ext3-lib.sh/ext3_get_mountopts
#  NAME
#    ext3_get_mountopts
#  SYNOPSIS
#    ext3_get_mountopts(nodename)
#  DESCRIPTION
#    Gets the mountopts for this node
#  IDEAS
#  SOURCE
#
function ext3_get_mountopts() {
   _mount_opts=$(ext3_get mountopts "$@")
   if [ -z "$_mount_opts" ]; then
     echo $default_mountopts
   else
     echo $_mount_opts
   fi
}
#************ ext3_get_mountopts

#****f* boot-scripts/etc/clusterfs-lib.sh/ext3_get
#  NAME
#    ext3_get
#  SYNOPSIS
#    ext3_get [querymap] opts
#  DESCRIPTTION
#    returns the name of the cluster.
#  SOURCE
#
ext3_get() {
   cc_get $@
}
# *********** ext3_get
