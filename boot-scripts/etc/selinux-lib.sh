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

# selinux_load_policy(newroot)
function selinux_load_policy() {
    local NEWROOT=$1
    local permissive=0
	# If SELinux is disabled exit now 
    local selinuxparam=$(getParameter "selinux")
    local ret=0
    if [ "$selinuxparam" == "0" ]; then
    	echo_local_debug "SELinux parameter selinux=0 detected disabling SELinux."
    	return 0
    fi
    
    SELINUX="enforcing"
    [ -e "$NEWROOT/etc/selinux/config" ] && . "$NEWROOT/etc/selinux/config"
    
    local enforcing=$(getParameter enforcing)
    if [ "$enforcing" = 0 ] || [ "$SELINUX" = "permissive" ]; then
        permissive=1
    fi

    # Attempt to load SELinux Policy
    if [ -x "$NEWROOT/usr/sbin/load_policy" -o -x "$NEWROOT/sbin/load_policy" ]; then

       if [ "$SELINUX" = "disabled" ]; then
          return 0;
       fi
       
       selinux_exec_load_policy "$SELINUX" "$selinuxparam" "$permissive" "$NEWROOT"
       ret=$?

       if [ $ret -eq 0 -o $ret -eq 2 ]; then
          # If machine requires a relabel, force to permissive mode
          [ -e "$NEWROOT"/.autorelabel ] && ( echo 0 > "$NEWROOT"/selinux/enforce )
          chroot "$NEWROOT" /sbin/restorecon -R /dev
          return 0
       fi

       error_local "Initial SELinux policy load failed."
       if [ $ret -eq 3 -o $permissive -eq 0 ]; then
          error_local "Machine in enforcing mode."
          error_local "Not continuing"
          return 1
       fi
       return 0
    elif [ $permissive -eq 0 -a "$SELINUX" != "disabled" ]; then
       error_local "Machine in enforcing mode and cannot execute load_policy."
       error_local "To disable selinux, add selinux=0 to the kernel command line."
       error_local "Not continuing"
       return 1
    fi
}

# Load the policy might be overwritten if necessary by the distributions
# selinux_exec_local_policy SELINUX selinuxparam permissive NEWROOT
# Might be overwritten in distribution!
function selinux_exec_load_policy() {
   local SELINUX=${1:-enforcing}
   local selinuxparam=${2}
   local permissive=${3:-0}
   local NEWROOT=${4:-/mnt/newroot}
   local ret=0
   local out=
   echo_local -n "Loading SELinux policy ($SELINUX/$selinuxparam/$permissive)"
   # load_policy does mount /proc and /selinux in 
   # libselinux,selinux_init_load_policy()
   if [ -x "$NEWROOT/sbin/load_policy" ]; then
      out=$(chroot "$NEWROOT" /sbin/load_policy -i 2>&1)
      ret=$?
      echo_local $out
   else
      out=$(chroot "$NEWROOT" /usr/sbin/load_policy -i 2>&1)
      ret=$?
      echo_local $out
   fi
   return $ret
}
