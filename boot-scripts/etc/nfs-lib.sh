#
# $Id: nfs-lib.sh,v 1.1 2007-03-09 17:56:33 mark Exp $
#
# @(#)$File$
#
# Copyright (c) 2001 ATIX GmbH.
# Einsteinstrasse 10, 85716 Unterschleissheim, Germany
# All rights reserved.
#
# This software is the confidential and proprietary information of ATIX
# GmbH. ("Confidential Information").  You shall not
# disclose such Confidential Information and shall use it only in
# accordance with the terms of the license agreement you entered into
# with ATIX.
#

#****h* comoonics-bootimage/nfs-lib.sh
#  NAME
#    gfs-lib.sh
#    $id$
#  DESCRIPTION
#*******

default_mountopts="defaults,noatime,nodiratime"

#****f* nfs-lib.sh/nfs_load
#  NAME
#    nfs_load
#  SYNOPSIS
#    function nfs_load
#  DESCRIPTION
#    This function loads all relevant nfs modules
#  IDEAS
#  SOURCE
#
function nfs_load {

  NFS_MODULES="nfs"

  echo_local -n "Loading NFS modules ($NFS_MODULES)..."
  for module in ${NFS_MODULES}; do
    exec_local /sbin/modprobe ${module}
  done
  return_code

  echo_local_debug  "Loaded modules:"
  exec_local_debug /sbin/lsmod

  return $return_c
}
#************ nfs_load

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
  services="portmap rpc_lockd rpc_statd"
  for service in $services; do
    nfs_start_$service
    if [ $? -ne 0 ]; then
      return $?
    fi
  done
  return $return_c
}
#************ nfs_services_start

#****f* nfs-lib.sh/nfs_start_portmap
#  NAME
#    nfs_start_portmap
#  SYNOPSIS
#    function nfs_start_portmap
#  DESCRIPTION
#    This function starts the portmap daemon
#  IDEAS
#  SOURCE
#
function nfs_start_portmap {
  start_service /sbin/portmap "no_chroot"
}
#************ nfs_start_portmap

#****f* nfs-lib.sh/nfs_start_rpc_lockd
#  NAME
#    nfs_start_rpc_lockd
#  SYNOPSIS
#    function nfs_start_rpc_lockd
#  DESCRIPTION
#    This function starts the rpc_lockd daemon
#  IDEAS
#  SOURCE
#
function nfs_start_rpc_lockd {
  start_service /sbin/rpc.lockd "no_chroot"
}
#************ nfs_start_rpc_statd

#****f* nfs-lib.sh/nfs_start_rpc_statd
#  NAME
#    nfs_start_rpc_statd
#  SYNOPSIS
#    function nfs_start_rpc_statd
#  DESCRIPTION
#    This function starts the rpc_statd daemon
#  IDEAS
#  SOURCE
#
function nfs_start_rpc_statd {
  start_service /sbin/rpc.statd "no_chroot"
}
#************ nfs_start_rpc_statd



#****f* nfs-lib.sh/nfs_services_restart
#  NAME
#    nfs_services_restart
#  SYNOPSIS
#    function nfs_services_restart(lockmethod)
#  DESCRIPTION
#    This function loads all relevant gfs modules
#  IDEAS
#  SOURCE
#
function nfs_services_restart {
  local old_root=$1
  local new_root=$2

  services=""
  for service in $services; do
    nfs_restart_$service $old_root $new_root
    if [ $? -ne 0 ]; then
      echo $service > $new_root/${cdsl_local_dir}/FAILURE_$service
#      return $?
    fi
    step
  done
  return $return_c
}
#************ nfs_services_restart

function nfs_checkhosts_alive {
	return 0
}
#********* gfs_checkhosts_alive

# $Log: nfs-lib.sh,v $
# Revision 1.1  2007-03-09 17:56:33  mark
# initial check in
#
