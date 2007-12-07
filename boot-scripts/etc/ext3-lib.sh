#
# $Id: ext3-lib.sh,v 1.2 2007-12-07 16:39:59 reiner Exp $
#
# @(#)$File$
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
# Revision 1.2  2007-12-07 16:39:59  reiner
# Added GPL license and changed ATIX GmbH to AG.
#
# Revision 1.1  2007/03/09 17:57:01  mark
# initial check in
#
