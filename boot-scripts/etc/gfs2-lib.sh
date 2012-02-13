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

#****f* gfs-lib.sh/gfs2_get_userspace_procs
#  NAME
#    gfs2_get_userspace_procs
#  SYNOPSIS
#    gfs2_get_userspace_procs()
#  DESCRIPTION
#    gets userspace program pids that are to be running dependent on rootfs
function gfs2_get_userspace_procs() {
  echo -e "aisexec \n\
ccsd \n\
fenced \n\
gfs_controld \n\
dlm_controld \n\
groupd \n\
qdiskd \n\
clvmd"
}
#******** gfs2_get_userspace_procs

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
   #   /etc/init.d/cman start setup
   true
}
#************ gfs2_load


#****f* gfs2-lib.sh/gfs2_load
#  NAME
#    gfs_load
#  SYNOPSIS
#    gfs2_init(action, chroot_path, rootfs, lvmsup)
#  DESCRIPTION
#    This Function does init functions dependent on root file system relative to given action.
#    Actions might be start|stop called from bootsr.
#
#    For action stop:
#    Prerequesite is that clvmd has been stopped by the init process before.
#    In this case clvmd is started again in the chroot_path in order to being able to deactivate
#    the volume group for the root filesystem.
#
#    For action start:
#    Nothing to be done.
#  IDEAS
#  SOURCE
#
function gfs2_init() {
   local action=$1
   local chroot_path=$2
   local lvm_sup=$4
   local precmd=""
   [ -n "$chroot_path" ] && precmd="chroot $chroot_path"
            
   case "$action" in
       start)
              true
              ;;
       stop)
        if [ -n "$lvm_sup" ] && [ $lvm_sup -eq 0 ]; then
            $precmd /etc/init.d/clvmd start
        fi
        ;;
       *)
        ;;
   esac                           
}
#************ gfs2_load

#****f* gfs2-lib.sh/gfs2_services_start
#  NAME
#    gfs2_services_start
#  SYNOPSIS
#    gfs2_services_start(lockmethod)
#  DESCRIPTION
#    This function loads all relevant gfs modules
#    Will call the cman initscript with relevant parameters.
#    Then we'll also need a bind mount from $chroot_path/var/run to /var/run
#    to make all cluster scripts work.
#  IDEAS
#  SOURCE
#
function gfs2_services_start() {
        local chroot_path=$1
        local lock_method=$2
        local lvm_sup=$3
        local precmd=""

        setHWClock
        
        [ -n "$chroot_path" ] && precmd="chroot $chroot_path"

        mount --rbind $chroot_path/var/run /var/run
        $precmd /etc/init.d/cman start setup
        cp -a /dev/misc $chroot_path/dev/misc 
        $precmd /etc/init.d/cman start
        if [ -n "$lvm_sup" ] && [ $lvm_sup -eq 0 ]; then
        #        $precmd /etc/init.d/messagebus start
            /etc/init.d/clvmd start
        fi
}
#************ gfs2_services_start

#****f* gfs-lib.sh/gfs_services_stop
#  NAME
#    gfs_services_stop
#  SYNOPSIS
#    function gfs_services_stop
#  DESCRIPTION
#    This function loads all relevant gfs modules
#  IDEAS
#  SOURCE
#
function gfs2_services_stop {
  local chroot_path=$1
  local lock_method=$2
  local lvm_sup=$3

  /etc/init.d/cman stop
  if [ -n "$lvm_sup" ] && [ $lvm_sup -eq 0 ]; then
     /etc/init.d/clvmd start
  fi
}
#************ gfs_services_stop

#****f* gfs-lib.sh/gfs_services_restart_newroot
#  NAME
#    gfs_services_restart_newroot
#  SYNOPSIS
#    function gfs_services_restart_newroot(new_root, lock_method, lvm_sup, comoonicspath)
#  DESCRIPTION
#    This function restarts all needed services in newroot
#    Only clvmd will be stopped.
#    It will be started later on by the init process.
#  PARAMETERS
#    new_root: Path where the root filesystem is mounted
#    lock_method: what lockmethod to use (obsolete)
#    lvm_sup: if lvm (clvmd) should be started
#    comoonicspath: where the chroot can be found.
#  IDEAS
#  SOURCE
#
function gfs2_services_restart_newroot {
  local new_root=$1
  local lock_method=$2
  local lvm_sup=$3
  local comoonicspath=$4
  local clusterfiles=${5-/var/run/cman_admin /var/run/cman_client}

  local services=""
  if [ -d "${chroot_path}/${comoonicspath}" ]; then
    echo_local -n "Creating clusterfiles ${clusterfiles}.."
    for _clusterfile in $clusterfiles; do
        exec_local chroot $chroot_path ln -sf ${comoonicspath}/${_clusterfile} ${_clusterfile}
    done
    success
    echo
  fi
  if [ -n "$lvm_sup" ] && [ "$lvm_sup" -eq 0 ]; then
      /etc/init.d/clvmd stop
      if [ $? -ne 0 ]; then
        return $?
      fi
  fi
  for path in $new_root/proc /var/run; do
     if is_mounted $path; then
        for deppath in $(get_dep_filesystems $deppath); do
           echo_local -n "Umounting filesystem $deppath"
           exec_local umount_filesystem $deppath
           return_code
        done
     fi
     echo_local -n "Umounting $path"
     exec_local umount_filesystem $path
     return_code $?
  done
  return $return_c
}
#************ gfs_services_start_newroot

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
