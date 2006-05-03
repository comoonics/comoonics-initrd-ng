#
# $Id: linuxrc.part.urlsource.sh,v 1.2 2006-05-03 12:45:44 marc Exp $
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
# This part linuxrc has the purpose to read an external scripts identified by
# it url. That script and all its dependencies are downloaded from that url
# and sourced.
# Bootparams: urlsource
#
# Dependencies are to be identified by the tag # %%include <filename>
# When such a tag is encountered the filename is read from the urlsource 
# without the scriptname.

#****h* comoonics-bootimage/linuxrc.part.urlsource.sh
#  NAME
#    linuxrc.part.urlsource.sh
#    $Id: linuxrc.part.urlsource.sh,v 1.2 2006-05-03 12:45:44 marc Exp $
#  DESCRIPTION
#    The scripts called from linuxrc.generic.sh if bootpart urlsource is used.
#*******

#****f* linuxrc.part.urlsource.sh/main
#  NAME
#    main
#  SYNOPSIS
#    function main() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#

urlsource=$(getBootParm urlsource)

if [ -z "$urlsource" ]; then
    /rescue.sh
    exec /bin/bash
fi

base=$(dirname $urlsource)
filename="/"$(basename $urlsource)

input="yes"
while [ $input = "yes" ]; do
    echo_local -n "Reading source $urlsource..."
    exec_local wget -O $filename $urlsource >> $boot_log
    step
    if [ $return_c -ne 0 ]; then
	/rescue.sh
	exec /bin/bash
    fi
    
    includes=$(grep '# %%include ' $filename | awk '{ print $3; }')
    for include in $includes; do
	dirname=$(dirname $include)
	if [ -n "$dirname" ] && [ ! -d $dirname ]; then 
	    echo_local -n "Creating dir $dirname..."
	    exec_local mkdir -p $dirname
	fi
	echo_local "Reading include $include..."
	exec_local wget -O $include ${base}"/"${include} >> $boot_log
    done
    step

    source $filename
    echo_local -n "Reread file? [yes/no]"
    read input
done
#*********** main

################
# $Log: linuxrc.part.urlsource.sh,v $
# Revision 1.2  2006-05-03 12:45:44  marc
# added documentation
#
