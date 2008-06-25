#/bin/bash
#****h* comoonics-bootimage/utils/release_rpmlock.sh
#  NAME
#    release_rpmlock.sh
#    
#  DESCRIPTION
#*******
#
# $Id: release_rpmlock.sh,v 1.1 2008-06-25 12:48:33 mark Exp $
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

MAX_RUNS=30
SLEEP_TIME=10

function release_locks() {
	for i in $(lsof | grep "/lib/rpm" | awk '{print $2}' | sort -u); do 
        /bin/kill -SIGSTOP $i
        /bin/kill -SIGCONT $i
	done
}

# first run
release_locks

run=0
while [ $run -lt $MAX_RUNS ] && /usr/bin/killall -0 rpmq &> /dev/null; do
	release_locks
	sleep $SLEEP_TIME
	let run=$run+1
done  