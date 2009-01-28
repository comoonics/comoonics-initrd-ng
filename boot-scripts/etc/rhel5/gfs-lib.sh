#
# $Id: gfs-lib.sh,v 1.15 2009-01-28 12:46:55 marc Exp $
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
#	echo_local "Loading RedHat 5 Cluster dependencies"
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
  		exec_local chroot $chroot_path $ln -sf ${comoonicspath}/${_clusterfile} ${_clusterfile}
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

  exec_local umount $chroot_path/proc

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
  start_service_chroot $chroot_path 'fenced -c'
  # fence_tool -c is not supported from RHEL5.2 up so we need to check (ABI compatibility)
  fence_tool -h | grep -- '-c' > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    start_service_chroot $chroot_path '/sbin/fence_tool -c -w join'
  else
    start_service_chroot $chroot_path '/sbin/fence_tool -w join'
  fi
  #echo_local "Waiting for fenced to complete join"
  #exec_local fence_tool wait
  return_code
}
#************ gfs_start_fenced
