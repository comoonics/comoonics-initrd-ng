#
# $Id: drbd-lib.sh,v 1.2 2008-06-10 09:54:45 marc Exp $
#
# @(#)$File$
#
# Initial version by Gordan Bobic @ Shattered Silicon Ltd. UK
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
# Library for the drbd-interface

#****h* comoonics-bootimage/drbd-lib.sh
#  NAME
#    drbd-lib.sh
#    $id$
#  DESCRIPTION
#*******

drbdparser3="^drbd"

#****f* drbd-lib.sh/loadDRBD
#  NAME
#    loadDRBD
#  SYNOPSIS
#    function loadDRBD
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function loadDRBD {
	local drbdmodules="drbd"
	echo_local -n "Loading drbdmodules"
	for module in $drbdmodules; do
		exec_local modprobe $module
	done
	return_code
}
#************ loadDRBD

#****f* drbd-lib.sh/startDRBD
#  NAME
#    startDRBD
#  SYNOPSIS
#    function startDRBD
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function startDRBD {
	local rootsource=$1
	local nodename=$2
	local drbdmodules="drbd"
	echo_local -n "Starting drbd"

	exec_local hostname $nodename
	modprobe -q drbd

	echo_local_debug "****************************************"
	echo_local_debug "hostname: $nodename"
	echo_local_debug "****************************************"

	service drbd start

	return_code
}
#************ startDRBD

#****f* drbd-lib.sh/isDRBDRootsource
#  NAME
#    isDRBDRootsource
#  SYNOPSIS
#    function isDRBDRootsource
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function isDRBDRootsource {
	local rootsource=$1
	if [ -z "$rootsource" ]; then
		return 1
	else
      echo $1 | awk '
/'$drbdparser3'/ {
	exit 0
  }
  {
  	exit 1
  }'
      return $?
    fi
    return 1
}
#************ isDRBDRootsource

# $Log: drbd-lib.sh,v $
# Revision 1.2  2008-06-10 09:54:45  marc
# - fixed bug with parser
#
# Revision 1.1  2008/03/18 17:40:11  marc
# initial revision
#
#
