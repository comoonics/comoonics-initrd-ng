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

# Dependencies for RHEL6

#****f* gfs-lib.sh/gfs2_get_userspace_procs
#  NAME
#    gfs2_get_userspace_procs
#  SYNOPSIS
#    gfs2_get_userspace_procs()
#  DESCRIPTION
#    gets userspace program pids that are to be running dependent on rootfs
#    NOTE:
#    As of RHEL6 killall5 supports omit pids we return the pids of the processes
#    not the names any more.
#  SOURCE
function gfs2_get_userspace_procs() {
  for service in corosync fenced gfs_controld dlm_controld groupd qdiskd; do
      pidof $service 2>/dev/null
  done
}
#******** gfs2_get_userspace_procs
