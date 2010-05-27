#
# $Id: gfs-lib.sh,v 1.20 2010-05-27 09:42:43 marc Exp $
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
#    Enterprise Linux 5.
#*******

if [ -z "$__RHEL5_GFS_LIB__" ]; then
	__RHEL5_GFS_LIB__=1
    # FENCED_START_TIMEOUT -- amount of time to wait for starting fenced
    #     before giving up.  If FENCED_START_TIMEOUT is positive, then we will
    #     wait FENCED_START_TIMEOUT seconds before giving up and failing when
    #     fenced does not start.  If FENCED_START_TIMEOUT is zero, then
    #     wait indefinately for fenced to start.
    [ -z "$FENCED_START_TIMEOUT" ] && FENCED_START_TIMEOUT=300

    # FENCED_MEMBER_DELAY -- amount of time to delay fence_tool join to allow
    #     all nodes in cluster.conf to become cluster members.  In seconds.
    [ -z "$FENCED_MEMBER_DELAY" ] && FENCED_MEMBER_DELAY=45
    # CMAN_CLUSTER_TIMEOUT -- amount of time to wait for joinging a cluster
    #     before giving up.  If CMAN_CLUSTER_TIMEOUT is positive, then we will
    #     wait CMAN_CLUSTER_TIMEOUT seconds before giving up and failing when
    #     a cluster is not joined.  If CMAN_CLUSTER_TIMEOUT is zero, then
    #     wait indefinately for a cluster join.  If CMAN_CLUSTER_TIMEOUT is
    #     negative, do not check to see that the cluster has been joined
    [ -z "$CMAN_CLUSTER_TIMEOUT" ] && CMAN_CLUSTER_TIMEOUT=120

    # CMAN_QUORUM_TIMEOUT -- amount of time to wait for a quorate cluster on
    #     startup quorum is needed by many other applications, so we may as
    #     well wait here.  If CMAN_QUORUM_TIMEOUT is less than 1, quorum will
    #     be ignored.
    #CMAN_QUORUM_TIMEOUT=300
    [ -z "$CMAN_QUORUM_TIMEOUT" ] && CMAN_QUORUM_TIMEOUT=0
    
    # CMAN_SHUTDOWN_TIMEOUT -- amount of time to wait for cman to become a
    #     cluster member before calling cman_tool leave during shutdown.  
    #     default is 60 seconds
    [ -z "$CMAN_SHUTDOWN_TIMEOUT" ] && CMAN_SHUTDOWN_TIMEOUT=60
    
fi

#****f* gfs-lib.sh/gfs_load
#  NAME
#    gfs_load
#  SYNOPSIS
#    function gfs_load(lockmethod)
#  DESCRIPTION
#    This function loads all relevant gfs modules
#  IDEAS
#  SOURCE
#
function gfs_load {
  local lock_method=$1

GFS_MODULES="configfs gfs2 gfs dlm"

  case $lock_method in
    lock_dlm)
      GFS_MODULES="${GFS_MODULES} lock_dlm"
      ;;
    lock_gulm)
      GFS_MODULES="${GFS_MODULES} lock_gulm"
      ;;
    *)
      GFS_MODULES="${GFS_MODULES} lock_dlm"
      ;;
  esac

  echo_local -n "Loading GFS modules ($GFS_MODULES)..."
  for module in ${GFS_MODULES}; do
    exec_local /sbin/modprobe ${module}
  done
  return_code

  echo_local_debug  "Loaded modules:"
  exec_local_debug /sbin/lsmod

  return $return_c
}
#************ gfs_load

#****f* gfs-lib.sh/gfs_services_start
#  NAME
#    gfs_services_start
#  SYNOPSIS
#    function gfs_services_start
#  DESCRIPTION
#    This function loads all relevant gfs modules
#  IDEAS
#  SOURCE
#
function gfs_services_start {
  local chroot_path=$1
  local lock_method=$2
  local lvm_sup=$3

  echo_local -n "Mounting configfs"
  exec_local mount -t configfs none $chroot_path/sys/kernel/config
  return_code

  local services="ccsd cman groupd qdiskd fenced dlm_controld gfs_controld"
  if [ -n "$lvm_sup" ] && [ "$lvm_sup" -eq 0 ]; then
  	services="$services clvmd"
  fi

  for service in $services; do
    gfs_start_$service $chroot_path
    if [ $? -ne 0 ]; then
      return $?
    fi
  done
  return $return_c
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

  local services="fenced cman"
  if [ -n "$lvm_sup" ] && [ $lvm_sup -eq 0 ]; then
  	services="fenced clvmd cman"
  fi
  for service in $services; do
    gfs_stop_$service $chroot_path
    if [ $? -ne 0 ]; then
      return $?
    fi
  done
  return $return_c
}
#************ gfs_services_stop

#****f* gfs-lib.sh/gfs_services_restart_newroot
#  NAME
#    gfs_services_restart_newroot
#  SYNOPSIS
#    function gfs_services_restart_newroot()
#  DESCRIPTION
#    This function restarts all needed services in newroot
#  IDEAS
#  SOURCE
#
function gfs_services_restart_newroot {
  local chroot_path=$1
  local lock_method=$2
  local lvm_sup=$3
  local comoonicspath=$4
  local clusterfiles=$5
  
  [ -z "$clusterfiles" ] && clusterfiles="/var/run/cman_admin /var/run/cman_client"

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
      gfs_start_$service $chroot_path
      if [ $? -ne 0 ]; then
        return $?
      fi
    done
  fi

  if is_mounted $chroot_path/proc; then
     for path in $(get_dep_filesystems $chroot_path/proc); do
        echo_local -n "Umounting filesystem $path"
        exec_local umount_filesystem $path
        return_code
     done
  fi
  echo_local -n "Umounting $chroot_path/proc"
  exec_local umount_filesystem $chroot_path/proc
  return_code $?

  return $return_c
}
#************ gfs_services_start_newroot

#****f* gfs-lib.sh/gfs_start_qdiskd
#  NAME
#    gfs_start_qdiskd
#  SYNOPSIS
#    function gfs_start_qdiskd {
#  DESCRIPTION
#    Function starts the qdiskd in chroot environment
#  IDEAS
#  SOURCE
#
function gfs_start_qdiskd {
  local chroot_path=$1

  $ccs_xml_query query_xml /cluster/quorumd > /dev/null 2>&1
  if [ $? -eq 0 ]; then
     start_service_chroot $chroot_path /usr/sbin/qdiskd
  else
  	 echo_local -n "Starting qdiskd"
     passed
     echo_local
  fi
}
#************ gfs_start_qdiskd

#****f* gfs-lib.sh/gfs_start_fenced
#  NAME
#    gfs_start_fenced
#  SYNOPSIS
#    function gfs_start_fenced {
#  DESCRIPTION
#    Function starts the fenced in a changeroot environment
#  IDEAS
#  SOURCE
#
function gfs_start_fenced {
  local chroot_path=$1
  local fenced_opts="-c"
  local fence_tool_opts=""

  echo_local -n "Starting fenced.."
  start_service_chroot $chroot_path "fenced $fenced_opts"
  return_code
  # fence_tool -c is not supported from RHEL5.2 up so we need to check (ABI compatibility)
  fence_tool -h | grep -- '-c' > /dev/null 2>&1
  if [ $? -eq 0 ]; then
  	fence_tool_opts="-c"
  fi
  chroot $chroot_path /usr/sbin/cman_tool status | grep Flags | grep 2node &> /dev/null
  echo_local -n "Joining fencedomain.."
  if [ $? -ne 0 ]; then
    errors="$errors\n"$( chroot $chroot_path /sbin/fence_tool $fence_tool_opts -w -t $FENCED_START_TIMEOUT join \
                 > /dev/null 2>&1 )
    return_c=$?
  else
    fence_tool -h | grep -- '-m' > /dev/null 2>&1
    # fence_tool -m is not supported from RHEL5.2 down so we need to check (ABI compatibility)
    if [ $? -eq 0 ]; then
    	fence_tool_opts="$fence_tool_opts -m $FENCED_MEMBER_DELAY"
    fi    
    errors="$errors\n"$( chroot $chroot_path /sbin/fence_tool $fence_tool_opts -w -t $FENCED_START_TIMEOUT \
                 join \
                 > /dev/null 2>&1 )
    return_c=$?
  fi
  return_code $return_c
}
#************ gfs_start_fenced

#****f* gfs-lib.sh/gfs_start_cman
#  NAME
#    gfs_start_cman
#  SYNOPSIS
#    function gfs_start_cman
#  DESCRIPTION
#    Function starts the cman in a changeroot environment
#  IDEAS
#  SOURCE
#
function gfs_start_cman {
  local chroot_path=$1
  local cmd="cman_tool join -w"
  local cman_join_opts=""
  local nodename=$(repository_get_value nodename)
  
  [ -n "$nodename" ] && cman_join_opts=" -n $nodename "  
  
  if repository_has_key votes; then
  	local votes=$(repository_get_value votes)
  	cman_join_opts=" -v $votes"
	echo_local_debug "Votes value has been set to $votes"
  fi

  # cman
  chroot $chroot_path /usr/sbin/cman_tool status &> /dev/null
  if [ $? -ne 0 ]
  then
    echo_local -n "Joining the cluster manager"
    errors="errors\n"$( chroot $chroot_path /usr/sbin/cman_tool -t $CMAN_CLUSTER_TIMEOUT -w join \
              $cman_join_opts 2>&1 )
    return_c=$?

    if [ -n "$votes" ]; then
	  errors="errors\n"$( chroot $chroot_path cman_tool votes -v $votes )
    fi
    if [ $CMAN_QUORUM_TIMEOUT -gt 0 ]; then
      errors="errors\n"$( chroot $chroot_path /usr/sbin/cman_tool -t $CMAN_QUORUM_TIMEOUT \
               -q wait 2>&1 )
      return_c=$?
    fi

    return_code $return_c
  fi
}
#************ gfs_start_cman

###############
# $Log: gfs-lib.sh,v $
# Revision 1.20  2010-05-27 09:42:43  marc
# - reworked umount of proc.
#
# Revision 1.19  2009/03/16 19:23:54  marc
# fix for bug #335 fence_tool -m
#
# Revision 1.18  2009/02/20 09:49:42  marc
# added nodename option to cman_tool join.
#
# Revision 1.17  2009/02/08 13:14:07  marc
# implemented the gfs join process as specified in RedHat initscripts
#