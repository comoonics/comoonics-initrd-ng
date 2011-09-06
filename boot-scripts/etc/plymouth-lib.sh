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

plymouth_setup() {
  local isplymouth=$(getParameter rd.plymouth)
  local plymouthd=$(which plymouthd 2>/dev/null)
  [ -z "$isplymouth" ] && isplymouth=$(getParameter rd_NO_PLYMOUTH)
  [ -z "$isplymouth" ] && isplymouth=1
  which plymouth &>/dev/null && which plymouthd &>/dev/null || isplymouth=0
  repository_store_value plymouth $isplymouth
  if [ "$isplymouth" = "1" ]; then
    [ -c /dev/null ] || mknod -m 0666 /dev/null c 1 3
    # first trigger graphics subsystem
    udevadm trigger --action=add --attr-match=class=0x030000 >/dev/null 2>&1
    # first trigger graphics and tty subsystem
    udevadm trigger --action=add --subsystem-match=graphics --subsystem-match=drm --subsystem-match=tty >/dev/null 2>&1

    udevadm settle --timeout=30 2>&1
    [ -c /dev/zero ] || mknod -m 0666 /dev/zero c 1 5
    [ -c /dev/tty0 ] || mknod -m 0620 /dev/tty0 c 4 0
    [ -e /dev/systty ] || ln -s tty0 /dev/systty
    [ -c /dev/fb0 ] || mknod -m 0660 /dev/fb0 c 29 0
    [ -e /dev/fb ] || ln -s fb0 /dev/fb

    echo_local -n "Starting plymouth daemon .."
    test -n "$plymouthd" && test -x $plymouthd && exec_local $plymouthd --attach-to-session
    if [ $? -eq 0 ]; then
    	success
    elif ! test -x "$plymouthd"; then
        skipped
    else
        failure
    fi
    echo_local
    mkdir -m 0755 /dev/.systemd >/dev/null 2>&1
    >/dev/.systemd/plymouth
    /lib/udev/console_init tty0
    plymouth_cmd --show-splash 2>&1
  fi
}

plymouth_start() {
  plymouth_cmd --newroot=${1:-/}
}

plymouth_hide() {
  plymouth_cmd --hide-splash	
}

plymouth_cmd() {
  local plymouth=$(which plymouth 2>/dev/null)
  if [ -n "$plymouth" ] && [ -x $plymouth ] && [ $(repository_get_value plymouth 0) -eq 1 ]; then
  	echo_local -n "plymouth $@"
  	$plymouth $@
  	return_code
  fi
}
	