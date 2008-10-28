#
# $Id: nfs-lib.sh,v 1.6 2008-10-28 12:52:07 marc Exp $
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

#****h* comoonics-bootimage/nfs-lib.sh
#  NAME
#    gfs-lib.sh
#    $id$
#  DESCRIPTION
#*******

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
                readonly)
                    echo 0
                    ;;
	    *)
	        return 0
	        ;;
	esac
}
#********** clusterfs_getdefaults

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

  NFS_MODULES="nfs nfslock"

  echo_local -n "Loading NFS modules ($NFS_MODULES)..."
  for module in ${NFS_MODULES}; do
    exec_local /sbin/modprobe ${module}
  done
  return_code

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
  services=""
  for service in $services; do
    nfs_start_$service
  done
  return 0
}
#************ nfs_services_start

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
  start_service /sbin/portmap "no_chroot"
}
#************ nfs_start_portmap

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
  start_service /sbin/rpc.lockd "no_chroot"
}
#************ nfs_start_rpc_statd

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
  start_service /sbin/rpc.statd "no_chroot"
}
#************ nfs_start_rpc_statd



#****f* nfs-lib.sh/nfs_services_restart
#  NAME
#    nfs_services_restart
#  SYNOPSIS
#    function nfs_services_restart(lockmethod)
#  DESCRIPTION
#    This function loads all relevant gfs modules
#  IDEAS
#  SOURCE
#
function nfs_services_restart {
  local old_root=$1
  local new_root=$2

  services=""
  for service in $services; do
    nfs_restart_$service $old_root $new_root
    if [ $? -ne 0 ]; then
      echo $service > $new_root/${cdsl_local_dir}/FAILURE_$service
#      return $?
    fi
    step
  done
  
  return $return_c
}
#************ nfs_services_restart

#****f* nfs-lib.sh/nfs_services_restart_newroot
#  NAME
#    nfs_services_restart_newroot
#  SYNOPSIS
#    function nfs_services_restart_newroot(lockmethod)
#  DESCRIPTION
#    This function loads all relevant gfs modules
#  IDEAS
#  SOURCE
#
function nfs_services_restart_newroot {
  local chroot_path=$1
  local lock_method=$2
  local lvm_sup=$3

  echo "Umounting $chroot_path/proc"
  exec_local umount $chroot_path/proc
  return_code
}
#************ nfs_services_restart_newroot

function nfs_checkhosts_alive {
	return 0
}
#********* gfs_checkhosts_alive

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

# $Log: nfs-lib.sh,v $
# Revision 1.6  2008-10-28 12:52:07  marc
# fixed bug#288 where default mountoptions would always include noatime,nodiratime
#
# Revision 1.5  2008/08/14 14:35:24  marc
# - optimized to more modern version
# - added getdefaults
# - other minor bugfixes
#
# Revision 1.4  2008/06/20 15:50:36  mark
# get default mount opts right
#
# Revision 1.3  2008/06/10 09:59:09  marc
# - added empty nfs_init
#
# Revision 1.2  2007/12/07 16:39:59  reiner
# Added GPL license and changed ATIX GmbH to AG.
#
# Revision 1.1  2007/03/09 17:56:33  mark
# initial check in
#
