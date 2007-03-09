#
# $Id: ext3-lib.sh,v 1.1 2007-03-09 17:57:01 mark Exp $
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
#    ext3-lib.sh
#    $id$
#  DESCRIPTION
#*******

default_mountopts="ro"

#****f* ext3-lib.sh/ext3_load
#  NAME
#    ext3_load
#  SYNOPSIS
#    function ext3_load
#  DESCRIPTION
#    This function loads all relevant ext3 modules
#  IDEAS
#  SOURCE
#
function ext3_load {

  EXT3_MODULES="ext3"

  echo_local -n "Loading EXT3 modules ($EXT3_MODULES)..."
  for module in ${EXT3_MODULES}; do
    exec_local /sbin/modprobe ${module}
  done
  return_code

  echo_local_debug  "Loaded modules:"
  exec_local_debug /sbin/lsmod

  return $return_c
}
#************ ext3_load

#****f* ext3-lib.sh/ext3_services_start
#  NAME
#    ext3_services_start
#  SYNOPSIS
#    function ext3_services_start
#  DESCRIPTION
#    This function starts all relevant services
#  IDEAS
#  SOURCE
#
function ext3_services_start {

  services=""
  for service in $services; do
    nfs_start_$service
    if [ $? -ne 0 ]; then
      return $?
    fi
  done
  return $return_c
}
#************ ext3_services_start

#****f* ext3-lib.sh/ext3_services_restart
#  NAME
#    ext3_services_restart
#  SYNOPSIS
#    function ext3_services_restart(lockmethod)
#  DESCRIPTION
#    This function restarts all ext3 relevant services
#  IDEAS
#  SOURCE
#
function ext3_services_restart {
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
#************ ext3_services_restart

function ext3_checkhosts_alive {
	return 0
}
#********* ext3_checkhosts_alive

# $Log: ext3-lib.sh,v $
# Revision 1.1  2007-03-09 17:57:01  mark
# initial check in
#
