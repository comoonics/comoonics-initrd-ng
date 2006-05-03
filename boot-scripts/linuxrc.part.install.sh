#!/bin/bash
#****h* comoonics-bootimage/linuxrc.part.install.sh
#  NAME
#    linuxrc.part.install.sh
#    $Id: linuxrc.part.install.sh,v 1.2 2006-05-03 12:45:59 marc Exp $
#  DESCRIPTION
#    The scripts called from linuxrc.generic.sh if bootpart is install.
#*******

#****f* linuxrc.part.install.sh/main
#  NAME
#    main
#  SYNOPSIS
#    function main() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#

echo_local "*************************"
echo_local "Entering Comoonics Installation"
echo_local "*************************"
sleep 3

device=$(getBootParm installdev cdrom)
dryrun=$(getBootParm mode install)

depmod -a

loadSCSI

critical=0;

if [ ! -d "/usr/installation" ]; then
	 mkdir -p "/usr/installation"
fi
if [ $device = "cdrom" ] ; then
	 echo "Try to mount the cdrom"
		  for i in  hda hdb hdc hdd sda sdb sdc sde sdf sdg sdh; do
		  echo "Probing /dev/$i ..."
		  # SCHRAUBEREI !!!
		  cd_dev=/dev/$i
		  mount -t iso9660 /dev/$i /usr/installation
		  if test $? -eq 0; then echo "Found cdrom $cd_dev" && break; fi
	 done
else
  echo -n "Mounting NFS"
  mount -t nfs installfix:/usr/installation /usr/installation
fi

step


if test $? -ne 0; then
on_failure
exit
fi

#rc_reset
#echo "Showing the network-config"
#/sbin/ifconfig
#rc_status -v -r

#rc_reset
#echo "Showing mounted devices:"
#mount
#rc_status -v -r

if [ "x$dryrun" != "xdryrun" ]; then
	 echo "Let's start installation process..."
	 cd root/perl && perl ./install.pl
	 if test $device = "cdrom"; then
		  echo "Ejecting $cd_dev"
		  eject $cd_dev
		  echo reboot
		  reboot -f
	 else
		  echo reboot
		  reboot -f
	 fi
else
	 bash
fi

#********** main

#################
# $Log: linuxrc.part.install.sh,v $
# Revision 1.2  2006-05-03 12:45:59  marc
# added documentation
#
