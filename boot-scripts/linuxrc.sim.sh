#!/bin/bash
#
# $Id: linuxrc.sim.sh,v 1.2 2009-01-28 12:57:55 marc Exp $
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

predir=$(dirname $0)
source ${predir}/etc/boot-lib.sh
source ${predir}/etc/chroot-lib.sh
source ${predir}/etc/std-lib.sh

distribution=$(getDistribution)
[ -e ${predir}/etc/${distribution}/boot-lib.sh ] && source ${predir}/etc/${distribution}/boot-lib.sh

errlog=/tmp/com-bootimage-simulator.err
outlog=/tmp/com-bootimage-simulator.log
exec 3>>$outlog
exec 4>>$errlog
echo_local "All error are also directed to $errlog"
echo_local "All output is directed to $outlog" 

initEnv

# boot parameters
#debug=$(getParm ${bootparms} 1)
#stepmode=$(getParm ${bootparms} 2)

welcome $distribution

# Print a text banner.
if [ -e "$build_file" ]; then
  cat ${build_file}
fi

${predir}/linuxrc.generic.sh -S $*

echo "Returned from linuxrc.generic.sh."

error_code=0
[ -e $error_code_file ] && error_code=$(cat $error_code_file)
exit $error_code
