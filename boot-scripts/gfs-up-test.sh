#!/bin/bash
#
# $Id: gfs-up-test.sh,v 1.1 2004-07-31 11:24:43 marc Exp $
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
# Kernelparameter for changing the bootprocess for the comoonics generic hardware detection alpha1
#    gfs-poolsource=... The poolsource possibilities (scsi*, gnbd)
#    gfs-pool=...       The gfs-pool to boot from
#    gfs-poolcca=... The gfs-cidev-pool to be given (defaults to ${gfspool}_cca, applies to 5.2)
#    gfs-poolcidev=... The gfs-cidev-pool to be given (defaults to ${gfspool}_cidev, applies to 5.1.1)
#    gfs-lockmethod=... The gfs-locking method (lock_gulm*, lock_dmep, nolock)
#    gfs-gnbdserver=.. The server serving the gnbd based scsi discs over ip
#    gfs-mountopt=...  The mount options given to the mount command (i.e. noatime,nodiratime)
#    com-stepmode=...      If set it asks for <return> after every step
#    com-debug=...         If set debug info is output


. etc/sysconfig/comoonics
LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/lib/i686:/usr/lib"
PATH=/bin:/sbin:/usr/bin:/usr/sbin
export PATH LD_LIBRARY_PATH

source /etc/boot-lib.sh

date=`/bin/date`

echo_local "*****************************************"
echo_local "Testing for GFS Shared Root for $HOSTNAME"
echo_local "Date: $date"
echo_local "*****************************************"

echo_local_debug "*****************************"
echo_local -n "0.1 Mounting Proc-FS"
exec_local /bin/mount -t proc proc /proc
echo_local_debug "*****************************"
echo_local_debug "0.2 /proc/cmdline"
exec_local_debug cat /proc/cmdline

# getting all bootparams
debug=`getBootParm com-debug`
stepmode=`getBootParm com-stepmode`
poolsource=`getBootParm gfs-poolsource scsi`
pool_name=`getBootParm gfs-pool`
pool_cca_name=`getBootParm gfs-poolcca`
pool_cidev_name=`getBootParm gfs-poolcidev`
gfs_lock_method=`getBootParm gfs-lockmethod`
gnbd_server=`getBootParm gfs-gnbdserver`
mount_opts=`getBootParm gfs-mountopt defaults`

if [ ! -z "$pool_name" ]; then
   GFS_POOL="$pool_name"
fi
if [ -z "$pool_cca_name" ]; then
   if [ -z "${GFS_POOL_CCA}" ]; then
      GFS_POOL_CCA="${GFS_POOL}_cca"
   else
      GFS_POOL_CCA=${GFS_POOL_CCA}
   fi
else
   GFS_POOL_CCA="$pool_cca_name"
fi
if [ -z "$pool_cidev_name" ]; then
   if [ -z "${GFS_POOL_CIDEV}" ]; then
      GFS_POOL_CIDEV="${GFS_POOL}_cidev"
   else
      GFS_POOL_CIDEV="${GFS_POOL_CIDEV}"
   fi
else
   GFS_POOL_CIDEV="$pool_cidev_name"
fi
if [ -z "$gfs_lock_method" ]; then
   gfs_lock_method="${GFS_LOCK_METHOD}"
fi

# getting gfs version
modinfo gfs | grep "description: .*v5.2.*" 1>/dev/null 2>&1
if [ $? -eq 0 ]; then
  gfsversion="5_2"
else
  gfsversion="5_1"
fi

eval tmpmods=\$GFS_MODULES_${gfsversion}
if [ ! -z "$tmpmods" ]; then
   GFS_MODULES=$tmpmods
fi

if [ "$poolsource" = "gnbd" ]; then
   GFS_MODULES="${GFS_MODULES} gnbd"
fi

case $gfs_lock_method in
   lock_gulm)
       GFS_MODULES="${GFS_MODULES} lock_gulm"
       ;;
   lock_dmep)
       GFS_MODULES="${GFS_MODULES} lock_dmep"
       ;;
   nolock)
       GFS_MODULES="${GFS_MODULES} lock_nolock"
       ;;
   *)
       GFS_MODULES="${GFS_MODULES} lock_gulm"
       ;;
esac

echo_local_debug "Debug: $debug"
echo_local_debug "Stepmode: $stepmode"
echo_local_debug "poolsource: $poolsource"
echo_local_debug "pool_name: $pool_name"
if [ $gfsversion = "5_2" ]; then
  echo_local_debug "pool_cca_name: $pool_cca_name"
else
  echo_local_debug "pool_cidev_name: $pool_cidev_name"
fi
echo_local_debug "gfs_lock_method: $gfs_lock_method"
echo_local_debug "gnbd_server: $gnbd_server"
echo_local_debug "mount_opts: $mount_opts"
echo_local_debug "gfsversion: $gfsversion"
echo_local_debug "*****************************"
x=`cat /proc/version`; 
KERNEL_VERSION=`expr "$x" : 'Linux version \([^ ]*\)'`
echo_local "0.2 Kernel-verion: ${KERNEL_VERSION}"
echo_local_debug "*****************************"
step

echo_local_debug "*****************************"
echo_local -n "1. Hardware autodetection"
exec_local /usr/sbin/kudzu -t 30 -s -q
echo_local -n "1.1 Module-depency"
exec_local /sbin/depmod -a
echo_local_debug "File /etc/modules.conf: ***"
exec_local_debug cat /etc/modules.conf
step

echo_local_debug "*****************************"
echo_local "2. Setting up the network"

echo_local -n "2.0 Interface lo..."
exec_local /sbin/ifconfig lo 127.0.0.1 up

for dev in $NETCONFIG; do
  eval IFCONFIG=\$IFCONFIG${dev}
  eval NETDEV=\$NETDEV${dev}
  echo_local "2.1 Starting Network on device ${NETDEV}/${IFCONFIG}."
  if [ "$IFCONFIG" = "default" ]; then
    echo_local "2.1.$NETDEV Powering up ${NETDEV}..."
    exec_local /sbin/ifup $NETDEV
  elif [ "$IFCONFIG" = "boot" ]; then
    echo_local "2.1 Network already configured for device ${NETDEV}."
  else
    echo_local "2.1 Autoprobing for network environment..."
    test `/bin/hostname` || /bin/hostname ${HOSTNAME}
    echo_local -n "2.1.1 hostname : ${HOSTNAME}"

    if [ ! -z ${GATEWAY} ]; then
       exec_local /sbin/route add default gw ${GATEWAY} ${DEVICE} 1>>/var/log/boot.log 2>&1
    fi
    echo_local -n "2.1.2 Ip-Address for GFS-Node"
    case $IPADDR_GFS in
      hostname)
         name=`hostname`
         ipaddress_from_name
         ;;
      eth[0-9])
         netdev=$IPADDR_GFS
         ipaddress_from_dev
         ;;
      [0-9]*.[0-9]*.[0-9]*.[0-9]*)
         gfsip=$IPADDR_GFS
         ;;
      *)
         name=$IPADDR_GFS
         ipaddress_from_name
         ;;
    esac
    echo_local "(OK)"
  fi
done
step
echo_local_debug "2.2 Network Configuration: "
echo_local_debug "      1. Interfaces:"
exec_local_debug /sbin/ifconfig
echo_local_debug "      2. Routing:"
exec_local_debug /sbin/route -n
echo_local_debug "      3. Hostname:"
exec_local_debug /bin/hostname
echo_local_debug "      4. GFS-IPAddress: ${gfsip}"
echo_local_debug "*****************************"
step

if [ "$poolsource" = "scsi" ]; then
  if [ -z "${FC_MODULES}"]; then
    FC_MODULES="scsi_hostadapter"
  fi
  echo_local "3 Loading scsi-driver..."
  
  echo_local -n "3.1 Loading scsi_disk Module..."
  exec_local /sbin/modprobe sd_mod

  echo_local -n "3.2 Loading $FC_MODULES"
  exec_local /sbin/modprobe ${FC_MODULES}

  step
  echo_local_debug "3.1 Configured SCSI-Devices:"
  exec_local_debug /bin/cat /proc/scsi/scsi
  step
fi

echo_local_debug "*****************************"
echo_local "4. Powering up gfs (modules=${GFS_MODULES} tmpmods=${tmpmods})"
for module in ${GFS_MODULES}; do
   exec_local /sbin/modprobe ${module}
done
echo_local  "4.1 Loading gfs drivers (${GFS_MODULES})"
exec_local_debug /sbin/lsmod
step

echo_local  "4.2 Importing SCSI-Devices (for gnbd poolsource=$poolsource gnbd_server=${gnbd_server})"
if [ "$poolsource" = "gnbd" -a -n "$gnbd_server" ]; then
  exec_local /sbin/gnbd_import -i $gnbd_server
else
  echo_local "***SKIPPED"
fi

echo_local "4.3 Assembling pool"
exec_local ${GFS_POOL_ASSEMBLE}

if [ "$gfsversion" = "5_2" ]; then
  echo_local -n "4.4 Getting cca ($GFS_POOL_CCA)"
  exec_local /sbin/ccsd -d /dev/pool/$GFS_POOL_CCA
  step
else
  mount_opts="hostdata=`/bin/hostname`:/dev/pool/$GFS_POOL_CIDEV"
fi

echo_local_debug "*****************************"
echo_local "5. Pivot-Root..."
echo_local "5.0.1 Pool: ${GFS_POOL}"
if [ "$gfsversion" != "5_2" ]; then
  echo_local "5.0.2 Pool_cidev: ${GFS_POOL_CIDEV}"
else
  echo_local "5.0.2 Pool_cca: ${GFS_POOL_CCA}"
fi
step
#echo_local "5.1. Mounting newroot ..."
#if [ ! -e /mnt/newroot ]; then
#  mkdir -p /mnt/newroot
#fi
#exec_local /bin/mount -t gfs  /dev/pool/${GFS_POOL} /mnt/newroot -o $mount_opts
#critical=0
#if [ ! $return_c -eq 0 ]; then
#  critical=1
#fi
#step
#if [ "$gfsversion" != "5_2" ]; then
#  echo_local -n "5.2 Starting fenced ($GFS_FENCED)"
#  exec_local ${GFS_FENCED}
#fi
#
#cd /mnt/newroot
#if [ ! -e initrd ]; then
#   /bin/mkdir initrd
#fi
# if the dhclient is used for dhcp
#if [ -f /var/run/dhclient-eth0.pid ]; then
#   pid=`cat /var/run/dhclient-eth0.pid`
# the dhcpcd is used
#else
#   pid=`cat /etc/dhcpcd/dhcpcd-eth0.pid`
#fi
#step
#echo_local -n "5.3 Killing dhcp ($pid)"
#kill $pid
#echo_local -n "5.4 Pivot-Rooting..."
#exec_local cp ${bootlog} /mnt/newroot/${bootlog}
#exec_local /sbin/pivot_root . initrd
#echo_local_debug "**********************************************************************"
#echo_local "6.1 Restarting network with new pivot_root..."
#mount -t proc proc /proc
#kill $pid && /sbin/ifup eth0
#echo_local "6.2 Cleaning up initrd ."
#echo_local -n "6.2.1 Umounting procfs"
#exec_local /bin/umount /initrd/proc
#echo_local -n "6.2.2 Umounting /initrd"
#exec_local /bin/umount /initrd
#echo_local -n "6.2.3 Freeing memory"
#exec_local /sbin/blockdev --flushbufs /dev/ram0
#echo_local_debug "**********************************************************************"

/rescue.sh
exec /bin/bash
