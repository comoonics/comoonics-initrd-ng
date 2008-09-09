#
# $Id: gfs-lib.sh,v 1.1.2.1 2008-09-09 15:08:48 mark Exp $
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

if [ -z "$__RHEL4_GFS_LIB__" ]; then
	__RHEL4_GFS_LIB__=1
	echo_local "Loading RHEL4 gfs dependencies"
fi

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

  services=""
  if [ "$lvm_sup" -eq 0 ]; then
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
