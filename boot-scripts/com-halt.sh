#!/bin/bash
#
# $Id: com-halt.sh,v 1.1 2007-10-05 09:08:42 mark Exp $
#
# @(#)$File$
#
# Copyright (c) 2007 ATIX AG.
# Einsteinstrasse 10, 85716 Unterschleissheim, Germany
# All rights reserved.
#
# This software is the confidential and proprietary information of ATIX
# AG. ("Confidential Information").  You shall not
# disclose such Confidential Information and shall use it only in
# accordance with the terms of the license agreement you entered into
# with ATIX.
#
#****h* comoonics-bootimage/com-halt.sh
#  NAME
#    com-halt.sh
#    $Id: com-halt.sh,v 1.1 2007-10-05 09:08:42 mark Exp $
#  DESCRIPTION
#    script called from /etc/init.d/halt
#  USAGE
#    com-halt.sh chrootpath haltcmd
#*******

CHROOT_PATH=$(dirname $0)

cd $CHROOT_PATH
#mkdir -p $CHROOT_PATH/mnt/newroot
/sbin/pivot_root . ./mnt/newroot
chroot . ./com-realhalt.sh -r /mnt/newroot $*


