#
# $Id: glusterfs-lib.sh,v 1.3 2009-04-14 14:54:16 marc Exp $
#
# @(#)$File$
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
#    glusterfs-mountopt=...  The mount options given to the mount command (i.e. noatime,nodiratime)
#    com-stepmode=...      If set it asks for <return> after every step
#    com-debug=...         If set debug info is output

#****h* comoonics-bootimage/glusterfs-lib.sh
#  NAME
#    glusterfs-lib.sh
#    $id$
#  DESCRIPTION
#*******

#****f* boot-scripts/etc/clusterfs-lib.sh/glusterfs_getdefaults
#  NAME
#    glusterfs_getdefaults
#  SYNOPSIS
#    glusterfs_getdefaults(parameter)
#  DESCRIPTION
#    returns defaults for the specified filesystem. Parameter must be given to return the apropriate default
#  SOURCE
function glusterfs_getdefaults {
	local param=$1
	case "$param" in
		mount_opts|mountopts)
		    echo "noatime,nodiratime"
		    ;;
		rootfs|root_fs)
		    echo "glusterfs"
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
#********** glusterfs_getdefaults

#****f* glusterfs-lib.sh/glusterfs_get_mountopts
#  NAME
#    glusterfs_get_mountopts
#  SYNOPSIS
#    glusterfs_get_mountopts(cluster_conf, nodename)
#  DESCRIPTION
#    Gets the mountopts for this node
#  IDEAS
#  SOURCE
#
function glusterfs_get_mountopts {
   local xml_file=$1
   local hostname=$2
   [ -z "$hostname" ] && hostname=$(glusterfs_get_nodename $xml_file)
   local xml_cmd="${ccs_xml_query} -f $xml_file"
   _mount_opts=$($xml_cmd -q mountopts $hostname)
   if [ -z "$_mount_opts" ]; then
     echo $default_mountopts
   else
     echo $_mount_opts
   fi
}
#************ glusterfs_get_mountopts

#****f* glusterfs-lib.sh/glusterfs_get_drivers
#  NAME
#    glusterfs_get_drivers
#  SYNOPSIS
#    function glusterfs_get_drivers() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function glusterfs_get_drivers {
	echo "fuse"
}
#************ glusterfs_get_drivers

#****f* glusterfs-lib.sh/glusterfs_load
#  NAME
#    glusterfs_load
#  SYNOPSIS
#    function glusterfs_load()
#  DESCRIPTION
#    This function loads all relevant glusterfs modules
#  IDEAS
#  SOURCE
#
function glusterfs_load {
  ## THIS will be overwritten for rhel5 ##

  GLUSTERFS_MODULES=$(glusterfs_get_drivers)

  echo_local -n "Loading GlusterFS modules ($GLUSTERFS_MODULES)..."
  for module in ${GLUSTERFS_MODULES}; do
    exec_local /sbin/modprobe ${module}
  done
  return_code

  echo_local_debug  "Loaded modules:"
  exec_local_debug /sbin/lsmod

  return $return_c
}
#************ glusterfs_load

#****f* glusterfs-lib.sh/glusterfs_services_start
#  NAME
#    glusterfs_services_start
#  SYNOPSIS
#    function glusterfs_services_start()
#  DESCRIPTION
#    This function loads all relevant glusterfs modules
#  IDEAS
#  SOURCE
#
function glusterfs_services_start {
  ## THIS will be overwritten for rhel5 ##
  local chroot_path=$1
  local rootsource=$(glusterfs_get_rootsource $cluster_conf $nodename)
  echo_local "cluster_conf: $cluster_conf"
  echo_local "nodename: $nodename"
  echo_local "rootsource: $rootsource"

  echo_local "Mounting tmproot $rootsource /mnt/tmproot"
  mkdir /mnt/tmproot 2>/dev/null
  exec_local mount $rootsource /mnt/tmproot
  
  return $return_c
}
#************ glusterfs_services_start

#****f* glusterfs-lib.sh/glusterfs_services_restart_newroot
#  NAME
#    glusterfs_services_restart_newroot
#  SYNOPSIS
#    function glusterfs_services_restart_newroot()
#  DESCRIPTION
#    This function starts all needed services in newroot
#  IDEAS
#  SOURCE
#
function glusterfs_services_restart_newroot() {
  ## THIS will be overwritten for rhel5 ##
  exec_local /bin/true
}
#************ glusterfs_services_restart_newroot

#****f* glusterfs-lib.sh/glusterfs_init
#  NAME
#    glusterfs_init
#  SYNOPSIS
#    function glusterfs_init(start|stop|restart)
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function glusterfs_init {
	return 0
}
#********* glusterfs_init

# $Log: glusterfs-lib.sh,v $
# Revision 1.3  2009-04-14 14:54:16  marc
# - added get_drivers functions
#
# Revision 1.2  2009/01/28 10:01:42  marc
# First shot for:
# Removed everything that is defined and therefore called from gfs-lib.sh ({clutype}_lib.sh) and left everything that is defined by glusterfs-lib.sh ({rootfs}-lib.sh).
#
# Revision 1.1  2009/01/28 09:40:12  marc
# Import from Gordan Bobic.
#
