#!/bin/bash
# $Id: linuxrc.part.bash.sh,v 1.4 2006-05-03 12:46:08 marc Exp $
#****h* comoonics-bootimage/linuxrc.part.bash.sh
#  NAME
#    linuxrc
#    $Id: linuxrc.part.bash.sh,v 1.4 2006-05-03 12:46:08 marc Exp $
#  DESCRIPTION
#    The the script called if bootpart is bash
#*******

#****f* linuxrc.part.bash.sh/main
#  NAME
#    main
#  SYNOPSIS
#    function main() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#

exit_linuxrc 0 "/bin/bash"
#********* main

######################
# $Log: linuxrc.part.bash.sh,v $
# Revision 1.4  2006-05-03 12:46:08  marc
# added documentation
#
# Revision 1.3  2006/01/28 15:12:55  marc
# added cvs tags
# changed to new bootconcept
#
