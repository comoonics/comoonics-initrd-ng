#
# $Id: boot-lib.sh,v 1.89 2010/12/07 13:27:13 marc Exp $
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

# Load the policy might be overwritten if necessary by the distributions
# selinux_exec_local_policy SELINUX selinuxparam permissive NEWROOT
# For RHEL5 load_policy is call different to RHEL6 so it will be overwritten here!
function selinux_exec_load_policy() {
#   local SELINUX=${1:-enforcing}
#   local selinuxparam=${2}
#   local permissive=${3:-0}
#   local NEWROOT=${4:-/mnt/newroot}
#   local ret=0
#   local out=
#   echo_local -n "Loading SELinux policy ($SELINUX/$selinuxparam/$permissive)"
#   # load_policy does mount /proc and /selinux in 
#   # libselinux,selinux_init_load_policy()
#   if [ -x "$NEWROOT/sbin/load_policy" ]; then
#      out=$(chroot "$NEWROOT" /sbin/load_policy -q 2>&1)
#      ret=$?
#      echo_local $out
#   else
#      out=$(chroot "$NEWROOT" /usr/sbin/load_policy -q 2>&1)
#      ret=$?
#      echo_local $out
#   fi
#   return $ret
   return
}
