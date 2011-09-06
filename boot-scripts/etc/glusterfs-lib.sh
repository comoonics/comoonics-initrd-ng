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
  local rootsource=$(glusterfs_get_rootsource $(repository_get_value nodeid))
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

#****f* glusterfs-lib.sh/glusterfs_get_userspace_procs
#  NAME
#    glusterfs_get_userspace_procs
#  SYNOPSIS
#    function glusterfs_get_userspace_procs(nodename)
#  DESCRIPTION
#    gets userspace programs that are to be running dependent on rootfs
#  SOURCE
function glusterfs_get_userspace_procs {
   echo -e "glusterfs \n\
glusterfsd"
}
#******** glusterfs_get_userspace_procs

#****f* boot-scripts/etc/clusterfs-lib.sh/glusterfs_get
#  NAME
#    glusterfs_get
#  SYNOPSIS
#    glusterfs_get opts
#  DESCRIPTTION
#    returns the name of the cluster.
#  SOURCE
#
glusterfs_get() {
   cc_get $@
}
# *********** glusterfs_get
