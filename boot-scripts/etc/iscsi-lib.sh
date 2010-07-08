#
# $Id: iscsi-lib.sh,v 1.17 2010-07-08 08:16:28 marc Exp $
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
# Library for the iscsi-interface

#****h* comoonics-bootimage/iscsi-lib.sh
#  NAME
#    iscsi-lib.sh
#    $id$
#  DESCRIPTION
#*******

iscsiparser1="iscsi://([^:/]+)"
iscsiparser2="iscsi://([^:]+):([[:digit:]]+)/"
iscsiparser3="^iscsi"
iscsiparser4="iscsi://([^:]+):([[:digit:]]+)/(.+)"


#****f* iscsi-lib.sh/getISCSIInitiatorFromParam
#  NAME
#    getISCSIInitiatorFromParam
#  SYNOPSIS
#    function getISCSIInitiatorServerFromParam {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function getISCSIInitiatorFromParam {
    echo $1 | awk '
{
   match($1, "'$iscsiparser4'", iscsiparms);
   print iscsiparms[3];
}'
}

#****f* iscsi-lib.sh/getISCSIServerFromParam
#  NAME
#    getISCSIServerFromParam
#  SYNOPSIS
#    function getISCSIServerFromParam {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function getISCSIServerFromParam {
    echo $1 | awk '
{
   match($1, "'$iscsiparser1'", iscsiparms);
   print iscsiparms[1];
}'
}

#************ getISCSIServerFromParam

#****f* iscsi-lib.sh/getISCSIPortFromParam
#  NAME
#    getISCSIPortFromParam
#  SYNOPSIS
#    function getISCSIPortFromParam {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function getISCSIPortFromParam {
    echo $1 | awk '
{
   match($1, "'$iscsiparser2'", iscsiparms);
   print iscsiparms[2];
}'
}
#************ getISCSIPortFromParam

#****f* iscsi-lib.sh/createCiscoISCSICfgString
#  NAME
#    createCiscoISCSICfgString
#  SYNOPSIS
#    function createCiscoISCSICfgString {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function createCiscoISCSICfgString {
    echo -n "DiscoveryAddress=$1" && ([ -n "$2" ] && echo ":$2") || echo
}
#************ createCiscoISCSICfgString

#****f* iscsi-lib.sh/iscsi_get_drivers
#  NAME
#    iscsi_get_drivers
#  SYNOPSIS
#    function iscsi_get_drivers() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function iscsi_get_drivers {
   echo "cxgb3i bnx2i iscsi_tcp ib_iser scsi_transport_iscsi"
}
#************ iscsi_get_drivers

#****f* iscsi-lib.sh/load_iscsi
#  NAME
#    load_iscsi
#  SYNOPSIS
#    function load_iscsi
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function load_iscsi {
	local iscsimodules=$(iscsi_get_drivers)
	echo_local -n "Loading iscsimodules"
	for module in $iscsimodules; do
		exec_local modprobe $module
	done
	return_code
}
#************ load_iscsi

#****f* iscsi-lib.sh/start_iscsi
#  NAME
#    start_iscsi
#  SYNOPSIS
#    function start_iscsi(rootsource)
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function start_iscsi {
	local rootsource=$1
	local root=$2
	local chroot="chroot $root"
	if [ -z "$root" ]; then
	   chroot=""
	fi
	
	local iscsiserver=$(getISCSIServerFromParam $rootsource)
	local iscsiinitiatorname=$(getISCSIInitiatorFromParam $rootsource)
	echo_local -n "Starting iscsid in $root"
	
	if [ -n "$iscsiinitiatorname" ]; then
		echo "InitiatorName=$iscsiinitiatorname" >$chroot/etc/iscsi/initiatorname.iscsi
		echo_local -n "Initiatorname is $iscsiinitiatorname"
	fi
    exec_local $chroot brcm_iscsiuio
    exec_local $chroot iscsid
	return_code $?
	if [ -n "$iscsiserver" ]; then
	   rm -rf $chroot/var/lib/iscsi

       iscsi_add_nics $iscsiserver
	   echo_local -n "Importing from node $iscsiserver"
	   exec_local $chroot iscsiadm --mode discovery --type sendtargets --portal $iscsiserver &&
       exec_local $chroot iscsiadm --mode node --loginall=automatic
       return_code $?
	else
	   echo_local -n "Importing old nodes"
       exec_local $chroot iscsiadm --mode node --loginall=automatic
       return_code
	fi
    touch $root/var/lock/subsys/iscsi 2>/dev/null
    touch $root/var/lock/subsys/iscsid 2>/dev/null
}
#************ start_iscsi

function iscsi_add_nics() {
  local iscsiserver=$1
  local iscsinetwork=""
  local ipaddr=""
  for nic in $(ip addr show | grep "^[[:digit:]][[:digit:]]*: [[:alpha:]][[:alpha:]]*" | cut --delimiter=: --field=2); do
         ipaddr=$(ip addr show dev $nic | grep "inet " | cut --fields=6 --delimiter=' ')
         if [ -n "$ipaddr" ]; then
           ipbits=$(echo $ipaddr | sed -e 's/^[^\/]*\///')
           eval $(ipcalc --ipv4 --prefix="" --network ${iscsiserver}"/"${ipbits})
           iscsinetwork=$NETWORK
	       eval $(ipcalc --ipv4 --prefix="" --network $ipaddr)
	       if [ "$iscsinetwork" = "$NETWORK" ]; then
             echo_local -n "Adding nic $nic to iscsi configuration"
	         # here we need to add the command to add a nic to the iscsi environment
	         exec_local $chroot iscsiadm -m iface -I $nic -o new &&
	         exec_local $chroot iscsiadm -m iface -I $nic -o update -n iface.net_ifacename -v $nic
	         return_code $?
	       fi
	     fi
  done
  unset NETWORK
}

#****f* iscsi-lib.sh/restart_iscsi_newroot
#  NAME
#    restart_iscsi_newroot
#  SYNOPSIS
#    function restart_iscsi_newroot(rootsource, newroot, chroot)
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function restart_iscsi_newroot {
   local rootsource=$1
   local newroot=$2
   local chroot=$3
   
   local rservices="iscsid brcm_iscsiuio"
   local services="brcm_iscsiuio iscsid"
   for service in $rservices; do
	  echo_local -n "Stopping $service"
      killall $service
      killall -0 $service 2>/dev/null && sleep 3
      killall -0 $service 2>/dev/null && killall -9 $service
      killall -0 $service 2>/dev/null
      return_code
   done
   rm -f $newroot/var/lock/subsys/iscsi 2>/dev/null
   rm -f $newroot/var/lock/subsys/iscsid 2>/dev/null
   echo
   for service in $services; do
	  echo_local -n "Starting $service in $newroot"
      exec_local chroot $newroot $service
      return_code
   done
   touch $newroot/var/lock/subsys/iscsi 2>/dev/null
   touch $newroot/var/lock/subsys/iscsid 2>/dev/null
   unset services
}
#*************** restart_iscsi_newroot

#****f* iscsi-lib.sh/is_iscsi_rootsource
#  NAME
#    is_iscsi_rootsource
#  SYNOPSIS
#    function is_iscsi_rootsource
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function is_iscsi_rootsource {
	local rootsource=$1
	if [ -z "$rootsource" ]; then
		return 1
	else
      echo $1 | awk '
/'$iscsiparser3'/ {
	exit 0
  }
  {
  	exit 1
  }'
      return $?
    fi
    return 1
}
#************ is_iscsi_rootsource

# $Log: iscsi-lib.sh,v $
# Revision 1.17  2010-07-08 08:16:28  marc
# removed an obsolete touch
#
# Revision 1.16  2010/06/08 13:44:43  marc
# - start_iscsi: fixed start in chroot
# - restart_iscsi_newroot: don't reregistrate everything but just restart the daemons
#
# Revision 1.15  2010/05/27 09:51:33  marc
# iscsi_get_drivers:
#    - added drivers: cxgb3i bnx2i ib_iser, removed: libiscsi
# load_iscsi
#    - changed name from load_ISCSI to load_iscsi
# start_iscsi
#    - changed name from startISCSI to start_iscsi
#    - added support for multiple nics from the same network (bases for dm-multipath)
#    - code more similar to initscript
# iscsi_add_nics (new)
#    - add found nics to iscsi environment
# restart_iscsi_newroot (new)
#    - restarts iscsid in newroot
# is_iscsi_rootsource
#    - changed name from isISCSIRootsource to is_iscsi_rootsource
#
# Revision 1.14  2009/08/11 09:57:48  marc
# Here is a patch that uses an extended rootsource syntax for setting an
# node-specific Initiatorname.
# The syntax used is: <rootsource
# name="iscsi://<target-ip>:<port>/<Initiatorname>"/>
# (Michael Peus)
#
# Revision 1.13  2009/04/14 14:54:16  marc
# - added get_drivers functions
#
# Revision 1.12  2008/06/10 09:58:43  marc
# - fixed bug with parser
#
# Revision 1.11  2008/01/24 13:32:13  marc
# - rewrote iscsi configuration to be more generic
#
# Revision 1.10  2007/12/07 16:39:59  reiner
# Added GPL license and changed ATIX GmbH to AG.
#
# Revision 1.9  2007/10/16 08:02:21  marc
# - preview version
#
# Revision 1.8  2006/05/03 12:45:13  marc
# added documentation
#
# Revision 1.7  2004/09/29 14:32:16  marc
# vacation checkin, stable version
#
# Revision 1.6  2004/09/24 14:40:47  marc
# parser1=>parser2
#
# Revision 1.5  2004/09/24 14:33:27  marc
# bug in parser1
#
# Revision 1.4  2004/09/24 14:25:04  marc
# added second parser to support urls like iscsi://hostname//
#
# Revision 1.3  2004/09/24 09:02:19  marc
# another change for iscsi.cfg
#
# Revision 1.2  2004/09/24 08:56:14  marc
# bug in iscsi.cfg
#
# Revision 1.1  2004/09/23 16:30:01  marc
# initial revision
#
