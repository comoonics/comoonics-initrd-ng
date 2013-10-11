#
# Copyright (c) 2007 ATIX GmbH.
# Einsteinstrasse 10, 85716 Unterschleissheim, Germany
# All rights reserved.
#
# This software is the confidential and proprietary information of ATIX
# GmbH. ("Confidential Information").  You shall not
# disclose such Confidential Information and shall use it only in
# accordance with the terms of the license agreement you entered into
# with ATIX.
#
#****h* boot-scripts/etc/rhel6/gfs-lib.sh
#  NAME
#    gfs-lib.sh
#    $id$
#  DESCRIPTION
#    Libraryfunctions for gfs support functions for Red Hat
#    Enterprise Linux 6.
#    The idea is to use the provided initscripts wherever possible.
#    So we start up /etc/init.d/cman start setup for loading gfs.
#    For servicestarting we use /etc/init.d/cman start (will load over again
#    but that's ok).
#*******

#****f* gfs-lib.sh/gfs_load
#  NAME
#    gfs_load
#  SYNOPSIS
#    function gfs_load(lockmethod)
#  DESCRIPTION
#    This function loads all relevant gfs modules
#    Will call the cman initscript with relevant parameters.
#  IDEAS
#  SOURCE
#
function gfs_load {
   #   /etc/init.d/cman start setup
   true
}
#************ gfs_load

#****f* gfs-lib.sh/gfs_get_userspace_procs
#  NAME
#    gfs_get_userspace_procs
#  SYNOPSIS
#    gfs_get_userspace_procs()
#  DESCRIPTION
#    gets userspace programs that are to be running dependent on rootfs
#    NOTE:
#    As of RHEL6 killall5 supports omit pids we return the pids of the processes
#    not the names any more.
#  SOURCE
function gfs_get_userspace_procs() {
  for service in corosync fenced gfs_controld dlm_controld groupd qdiskd; do
      pidof $service 2>/dev/null
  done
}
#******** gfs_get_userspace_procs

#****f* gfs-lib.sh/gfs_services_start
#  NAME
#    gfs_services_start
#  SYNOPSIS
#    function gfs_services_start
#  DESCRIPTION
#    This function loads all relevant gfs modules
#    Will call the cman initscript with relevant parameters.
#    Then we'll also need a bind mount from $chroot_path/var/run to /var/run
#    to make all cluster scripts work.
#  IDEAS
#  SOURCE
#
function gfs_services_start {
        local precmd=""

        setHWClock
        
        [ -n "$chroot_path" ] && precmd="chroot $chroot_path"

        mount --rbind $chroot_path/var/run /var/run
        $precmd /etc/init.d/cman start setup
        cp -a /dev/misc $chroot_path/dev/misc 
        $precmd /etc/init.d/cman start
        if [ -n "$lvm_sup" ] && [ $lvm_sup -eq 0 ]; then
           $precmd /etc/init.d/clvmd start setup
           cp -a /dev/misc ${chroot_path}/dev/
        fi
}
#************ gfs_services_start

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
function gfs_services_stop {
  local chroot_path=$1
  local lock_method=$2
  local lvm_sup=$3

  /etc/init.d/cman stop
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
function gfs_services_restart_newroot {
  local new_root=$1
  local lock_method=$2
  local lvm_sup=$3
  local comoonicspath=$4
  #  local clusterfiles=${5-/var/run/cman_admin /var/run/cman_client}

  local services=""
#  if [ -d "${chroot_path}/${comoonicspath}" ]; then
#    echo_local -n "Creating clusterfiles ${clusterfiles}.."
#    for _clusterfile in $clusterfiles; do
#        exec_local chroot $chroot_path ln -sf ${comoonicspath}/${_clusterfile} ${_clusterfile}
#    done
#    success
#    echo
#  fi
  if [ -n "$lvm_sup" ] && [ "$lvm_sup" -eq 0 ]; then
    services="$services clvmd"
  fi
  if [ -n "$services" ]; then
    for service in $services; do
      gfs_stop_$service $chroot_path
      if [ $? -ne 0 ]; then
        return $?
      fi
    done

    for service in $services; do
      if [ "$service" != "clvmd" ]; then
        gfs_start_$service $chroot_path
        if [ $? -ne 0 ]; then
          return $?
        fi
      fi
    done
  fi

  for path in $chroot_path/proc /var/run; do
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
