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
	    *)
	        return 0
	        ;;
	esac
}
#********** clusterfs_getdefaults

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
  local services="rpcbind rpc_statd"
  for service in $services; do
    nfs_start_$service || breakp $(errormsg err_cc_start_service $service)
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
  local services="rpcbind  rpc_statd"
  for service in $services; do
    nfs_stop_$service
  done
  return 0
}
#************ nfs_services_stop

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
  local new_root=$1
  local lock_method=$2
  local lvm_sup=$3
  local services=
  local service=

  services="rpc_statd rpcbind"
  for service in $services; do
  	echo_local_debug "Stopping service $service .."
    nfs_stop_$service "/"
    if [ $? -ne 0 ]; then
      echo $service > $new_root/$(repository_get_value cdsl_local_dir)/FAILURE_$service
    fi
  done
  services="rpcpipefs rpcbind rpc_statd"
  for service in $services; do
    nfs_start_$service $new_root
    if [ $? -ne 0 ]; then
      echo $service > $new_root/${cdsl_local_dir}/FAILURE_$service
    fi
  done
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

#****f* nfs-lib.sh/nfs_get_userspace_procs
#  NAME
#    nfs_get_userspace_procs
#  SYNOPSIS
#    function nfs_get_userspace_procs(nodename)
#  DESCRIPTION
#    gets userspace programs that are to be running dependent on rootfs
#  SOURCE
function nfs_get_userspace_procs {
  echo -e "rpcbind"
}
#******** nfs_get_userspace_procs
