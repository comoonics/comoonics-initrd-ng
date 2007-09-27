#
# $Id: gfs-lib.sh,v 1.4 2007-09-27 12:01:20 marc Exp $
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
	echo_local "Loading RHEL5 gfs dependencies"
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

  echo_local -n "Mounting configfs"
  exec_local mount -t configfs none $chroot_path/sys/kernel/config
  return_code

  services="ccsd cman groupd fenced dlm_controld gfs_controld qdiskd clvmd"
  for service in $services; do
    gfs_start_$service $chroot_path
    if [ $? -ne 0 ]; then
      return $?
    fi
  done
  return $return_c
}
#************ gfs_services_start


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
     skipped
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
  start_service_chroot $chroot_path '/sbin/fence_tool -c -w join'
  #echo_local "Waiting for fenced to complete join"
  #exec_local fence_tool wait
  return_code
}
#************ gfs_start_fenced
