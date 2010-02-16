#
# $Id: gfs-lib.sh,v 1.5 2010-02-16 10:06:01 marc Exp $
#
# @(#)$File$
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
#****h* boot-scripts/etc/rhel5/gfs-lib.sh
#  NAME
#    gfs-lib.sh
#    $id$
#  DESCRIPTION
#    Libraryfunctions for gfs support functions for Red Hat
#    Enterprise Linux 4.
#*******

#****f* clusterfs-lib.sh/gfs_get_drivers
#  NAME
#    gfs_get_drivers
#  SYNOPSIS
#    function gfs_get_drivers()
#  DESCRIPTION
#    Returns the all drivers for this clusterfs. 
#  SOURCE
function gfs_get_drivers {
	echo "cman dlm lock_dlm gfs configfs lock_gulm lock_nolock"
}
#*********** gfs_get_drivers

#****f* gfs-lib.sh/gfs_get_userspace_procs
#  NAME
#    gfs_get_userspace_procs
#  SYNOPSIS
#    function gfs_get_userspace_procs(cluster_conf, nodename)
#  DESCRIPTION
#    gets userspace programs that are to be running dependent on rootfs
#  SOURCE
function gfs_get_userspace_procs {
  local clutype=$1
  local rootfs=$2

  echo ""

}
#******** gfs_get_userspace_procs

#****f* bootsr/get_lockcount
#  NAME
#    get_getlockcount
#  SYNOPSIS
#    function get_lockcount default_lockcount
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function get_lockcount {
  local DEF_LOCK_COUNT=$1
  local MAX_LOCK_COUNT=$2
  [ -z "$DEF_LOCK_COUNT" ] && DEF_LOCK_COUNT=${DEFAULT_LOCK_COUNT}
  [ -z "$DEF_LOCK_COUNT" ] && DEF_LOCK_COUNT=50000
  [ -z "$MAX_LOCK_COUNT" ] && MAX_LOCK_COUNT=0
  cat /proc/meminfo | grep MemTotal | awk -v maxlockcount=$MAX_LOCK_COUNT -v deflockcount=$DEF_LOCK_COUNT '
  {
  	lockcount=int($2/1024/512*deflockcount);
  	if ((lockcount > maxlockcount) && (maxlockcount > 0))
  	  lockcount=maxlockcount;
  	print lockcount;
  }
'
}
#************ get_lockcount

#****f* gfs-lib.sh/gfs_init
#  NAME
#    gfs_init
#  SYNOPSIS
#    function gfs_init(start|stop|restart) rootfs CHROOT_PATH
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function gfs_init {
  local DEFAULT_LOCK_COUNT=50000
  local action=$1
  local rootfs="gfs"
  local CHROOT_PATH=$3
  local VAR_RUN_FILES="cluster/ccsd.pid cluster/ccsd.sock cman_admin cman_client"
	
  case "$action" in
        start)
           /bin/mount -at $rootfs 2>&1 | tee -a /var/log/bootsr | logger -t com-bootsr
           count=$(get_lockcount ${DEFAULT_LOCK_COUNT} ${MAX_LOCK_COUNT})
	       echo_local_debug -n "Changing dlm:drop_count to $count"
	       echo $count > /proc/cluster/lock_dlm/drop_count
           # Create symbolic links
           for file in ${VAR_RUN_FILES}; do
  	          [ -e /var/run/${file} ] && rm -f /var/run/${file}
  	          test -d /var/run/$(dirname ${file}) || mkdir -p /var/run/$(dirname ${file}) 2>/dev/null
  	          test -e ${CHROOT_PATH}/var/run/${file} && /bin/ln -sf ${CHROOT_PATH}/var/run/${file} /var/run/$(dirname $file)
           done
           ;;
         stop)
           ;;
  esac
  return 0
}
#********* gfs_init

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

  local services="fenced cman"
  if [ -n "$lvm_sup" ] && [ $lvm_sup -eq 0 ]; then
  	services="fenced clvmd cman"
  fi
  for service in $services; do
    gfs_stop_$service $chroot_path
#    if [ $? -ne 0 ]; then
#      return $?
#    fi
  done
  return $return_c
}
#************ gfs_services_stop

###############
# $Log: gfs-lib.sh,v $
# Revision 1.5  2010-02-16 10:06:01  marc
# - added gfs_services_stop
#
# Revision 1.4  2010/02/05 12:26:52  marc
# - backport to upstream
# - moved get_lockcount to be defined here (used by bootsr)
#
# Revision 1.3  2009/04/14 14:50:03  marc
# overwritten gfs_get_userspaceprocs are there are none needed in RHEL4
#
# Revision 1.2  2009/03/25 13:52:52  marc
# initial revision
#
