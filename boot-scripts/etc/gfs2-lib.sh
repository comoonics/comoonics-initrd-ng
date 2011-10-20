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

# Library for gfs2 as rootfs lib (RHEL5/RHEL6)

#****h* comoonics-bootimage/gfs2-lib.sh
#  NAME
#    gfs-lib.sh
#  DESCRIPTION
#*******

[ -z "$default_lockmethod" ] && default_lockmethod="lock_dlm"
[ -z "$default_mountopts" ] && default_mountopts="noatime"

#****f* boot-scripts/etc/clusterfs-lib.sh/gfs2_getdefaults
#  NAME
#    gfs2_getdefaults
#  SYNOPSIS
#    gfs2_getdefaults(parameter)
#  DESCRIPTION
#    returns defaults for the specified filesystem. Parameter must be given to return the apropriate default
#  SOURCE
function gfs2_getdefaults() {
	local param=$1
	local distribution=$(repository_get_value distribution)
	
	case "$param" in
		lock_method|lockmethod)
		    echo "lock_dlm"
		    ;;
		mount_opts|mountopts)
		    echo "noatime,localflocks"
		    ;;
		root_source|rootsource)
		    echo "scsi"
		    ;;
		rootfs|root_fs)
			if [ -n "$distribution" ]; then
	          if [ ${distribution:0:4} = "sles" ]; then
	            echo "ocfs2"
			  else
			    echo "gfs2"
	          fi
            else 
		      echo "gfs2"
            fi
		    ;;
	    scsi_failover|scsifailover)
	        echo "driver"
	        ;;
	    ip)
	        echo "cluster"
	        ;;
	    *)
	        return 0
	        ;;
	esac
}
#********** gfs2_getdefaults

#****f* gfs2-lib.sh/gfs2_get_drivers
#  NAME
#    gfs2_get_drivers
#  SYNOPSIS
#    gfs2_get_drivers()
#  DESCRIPTION
#    Returns the all drivers for this clusterfs. 
#  SOURCE
function gfs2_get_drivers() {
	echo "dlm lock_dlm gfs gfs2 configfs lock_nolock"
}
#*********** gfs2_get_drivers

#****f* gfs2-lib.sh/gfs2_load
#  NAME
#    gfs_load
#  SYNOPSIS
#    gfs2_load(lockmethod)
#  DESCRIPTION
#    This Function loads all relevant gfs2 modules
#  IDEAS
#  SOURCE
#
function gfs2_load() {
}
#************ gfs2_load

#****f* gfs2-lib.sh/gfs2_services_start
#  NAME
#    gfs2_services_start
#  SYNOPSIS
#    gfs2_services_start(lockmethod)
#  DESCRIPTION
#    This Function loads all relevant gfs modules
#  IDEAS
#  SOURCE
#
function gfs2_services_start() {
return 0
}
#************ gfs2_services_start

#****f* gfs2-lib.sh/gfs2_checkhosts_alive
#  NAME
#    gfs_checkhosts_alive
#  SYNOPSIS
#    gfs_checkhosts_alive()
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function gfs2_checkhosts_alive() {
    $(repository_get_value cl_check_nodes)
}
#********* gfs_checkhosts_alive

#****f* gfs2-lib.sh/gfs2_fsck_needed
#  NAME
#    gfs2_fsck_needed
#  SYNOPSIS
#    gfs2_fsck_needed(root, rootfs)
#  DESCRIPTION
#    Will always return 1 for no fsck needed. This can only be triggered by rootfsck 
#    bootoption.
#
function gfs2_fsck_needed() {
	return 1
}
#********* gfs_fsck_needed

#****f* gfs2-lib.sh/gfs2_fsck
#  NAME
#    gfs_fsck
#  SYNOPSIS
#    gfs2_fsck_needed(root, rootfs)
#  DESCRIPTION
#    If this Function is called. It will always execute an gfsfsck on the given root.
#    Be very very carefull with this Function!!
#
function gfs2_fsck() {
	local root="$1"
	local fsck="fsck.gfs2"
	local options="-y"
	echo_local -n "Calling $fsck on filesystem $root"
	exec_local $fsck $options $root
	return_code
}
#********* gfs2_fsck

# for gfs we need a chroot
function gfs2_chroot_needed() {
	return 0
}
#******* gfs_chroot_needed

#****f* boot-scripts/etc/clusterfs-lib.sh/gfs2_get
#  NAME
#    gfs2_get
#  SYNOPSIS
#    gfs2_get opts
#  DESCRIPTTION
#    returns the name of the cluster.
#  SOURCE
#
gfs2_get() {
   cc_get $@
}
# *********** gfs2_get
