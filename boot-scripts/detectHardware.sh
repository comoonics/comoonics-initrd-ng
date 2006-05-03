#!/bin/bash
#****h* comoonics-bootimage/detectHardware.sh
#  NAME
#    detectHardware.sh
#    $Id: detectHardware.sh,v 1.2 2006-05-03 12:46:40 marc Exp $
#  DESCRIPTION
#    helperskript for testing Hardwaredetection for the 
#    comoonics-bootimage
#*******

#****f* detectHardware.sh/main
#  NAME
#    cpio_and_zip_initrd
#  SYNOPSIS
#    function cpio_and_zip_initrd() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
source ./etc/boot-lib.sh

initBootProcess

detectHardware
#******** main

##########
# $Log: detectHardware.sh,v $
# Revision 1.2  2006-05-03 12:46:40  marc
# added documentation
#
