#
# $Id: linuxrc.part.gfs.sh,v 1.13 2005-01-03 08:32:59 marc Exp $
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

#
# Includes
# %%include /etc/gfs-lib.sh

source /etc/gfs-lib.sh

getGFSParameters

if [ -n "$iscsi" ]; then
    source /linuxrc.part.iscsi.sh
fi

# getting gfs version
gfs_majorversion=$(getGFSMajorVersion)
gfs_minorversion=$(getGFSMinorVersion)

if [ $? -ne 0 ] || [ -z "$gfs_majorversion" ] || [ -z "$gfs_minorversion" ]; then
    echo_local "Unsupported or no gfs modules for this kernel"
    exit 1
fi

eval tmpmods=\$GFS_MODULES_${gfs_majorversion}_${gfs_minor_version}
[ -z $tmpmods ] && eval tmpmods=\$GFS_MODULES_${gfs_majorversion}
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

echo_local_debug "gfs_lock_method: $gfs_lock_method"
[ -n "$gnbd_server" ] && echo_local_debug "gnbd_server: $gnbd_server"
echo_local_debug "gfsversion: $gfs_majorversion $gfs_minorversion"

if [ "$poolsource" = "scsi" ]; then
    loadSCSI
fi
    
echo_local_debug "*****************************"
echo_local "4. Powering up gfs (modules=${GFS_MODULES} tmpmods=${tmpmods})"
for module in ${GFS_MODULES}; do
    exec_local /sbin/modprobe ${module}
done
echo_local_debug  "4.1 Loaded modules:"
exec_local_debug /sbin/lsmod
step

[ -n "$gnbd_server" ] && [ "$poolsource" = "gnbd" ] && \
    echo_local  "4.2 Importing SCSI-Devices (for gnbd poolsource=$poolsource gnbd_server=${gnbd_server})"
if [ "$poolsource" = "gnbd" -a -n "$gnbd_server" ]; then
    exec_local /sbin/gnbd_import -i $gnbd_server
fi

echo_local "4.3 Assembling pool"
exec_local ${GFS_POOL_ASSEMBLE}

if [ ! -z "$pool_name" ]; then
    GFS_POOL="$pool_name"
fi

if [ -z "$gfs_lock_method" ]; then
    gfs_lock_method="${GFS_LOCK_METHOD}"
fi

echo_local_debug "4.3.1 poolsource: $poolsource"

if [ $gfs_majorversion -eq 5 ] && [ $gfs_minorversion -lt 2 ]; then
    if [ -z "$pool_cidev_name" ]; then
	if [ -z "${GFS_POOL_CIDEV}" ]; then
	    GFS_POOL_CIDEV="${GFS_POOL}_cidev"
	else
	    GFS_POOL_CIDEV="${GFS_POOL_CIDEV}"
	fi
    else
	GFS_POOL_CIDEV="$pool_cidev_name"
    fi
    cdsl_local_dir="/boot.local"
    echo_local_debug "4.3.1 pool_cidev_name: $pool_cidev_name"
    mount_opts="hostdata=`/bin/hostname`:/dev/pool/$GFS_POOL_CIDEV"

else
    [ -z "$pool_cca_name" ] && pool_cca_name=$(gfs_autodetect_cca)
    [ -n "$pool_cca_name" ] && GFS_POOL_CCA=$pool_cca_name
    if [ -z "${GFS_POOL_CCA}" ]; then
	GFS_POOL_CCA="${GFS_POOL}_cca"
    fi
    cdsl_local_dir="/cdsl.local"
    mkdir /tmp  > /dev/null 2>&1
    shortpool="/tmp/"$(basename $GFS_POOL_CCA)"/"
    echo_local_debug "4.4.0 IPConfig: $ipConfig"
    echo_local -n "4.4.1 Extracting Pool-cca $GFS_POOL_CCA to $shortpool: "
    exec_local ccs_tool extract $GFS_POOL_CCA $shortpool
    if [ -e ${GFS_POOL_CCA} ] && [ "$ipConfig" = "cca" ]; then 
	if [ -z "$NETDEV" ]; then NETDEV="eth0"; fi
	
	for NETDEV in $(cca_get_netdevices "$shortpool"); do
	    echo_local_debug "4.4.1.1 Autconfig for this host ($ipConfig $NETDEV $shortpool) ..."
	    n_ipConfig=$(cca_autoconfigure_network "$ipConfig" "$NETDEV" "$shortpool")
	    echo_local_debug "n_ipconfig: $n_ipConfig "
	    step
	    if [ -n "$n_ipConfig" ]; then
		echo_local -n "4.4.2 Configuring network with bootparm-config ($n_ipConfig)"
		exec_local ip2Config $n_ipConfig
		echo_local -n "4.4.3 Powering up the network for interface ($NETDEV)..."
		exec_local my_ifup $NETDEV $n_ipConfig
	    fi
	done
    fi

    if [ -n "$GFS_POOL_CCA" ]; then
      echo_local -n "4.5 Starting ccsd ($GFS_POOL_CCA)"
      exec_local /sbin/ccsd -d $GFS_POOL_CCA
      echo_local -n "4.5.1 Patching host file..."
      if [ -z "$shortpool" ]; then ccs_opts="-c"; fi
      exec_local cca_generate_hosts ${shortpool} /etc/hosts
      echo_local_debug -n "4.5.1 /etc/hosts: "
      exec_local cat /etc/hosts
    fi
    
    echo_local_debug "4.5.2 pool_name: $pool_name"
    [ -z "$pool_name" ] && pool_name=$(cca_get_node_sharedroot)
    echo_local_debug "4.5.2 poolname: $pool_name"
    echo_local_debug "4.5.2 pool_cca_name: $pool_cca_name"
    GFS_POOL=$pool_name
    step
    setHWClock
    step
    if [ -n "$GFS_POOL_CCA" ]; then
      echo_local -n "4.6 Starting lock_gulmd"
      sts=1
      exec_local gfs_start_lockgulmd
      step

    fi
fi

echo_local_debug "*****************************"
echo_local "5.0.1 Pool: ${GFS_POOL}"
echo_local_debug "5.0.2 Cdsl_local_dir: ${cdsl_local_dir}"
    
echo_local "5.2. Mounting newroot ..."
exec_local /bin/mount -t gfs  /dev/pool/${GFS_POOL} /mnt/newroot -o $mount_opts
critical=0
if [ ! $return_c -eq 0 ]; then
    critical=1
fi
step
if [ $gfs_majorversion -eq 5 ] && [ $gfs_minorversion -lt 2 ]; then
    echo_local -n "5.2.1 Starting fenced ($GFS_FENCED)"
    exec_local ${GFS_FENCED}
fi

cd /mnt/newroot
if [ ! -e initrd ]; then
    /bin/mkdir initrd
fi
# if the dhclient is used for dhcp
#if [ -f /var/run/dhclient-eth0.pid ]; then
#   pid=`cat /var/run/dhclient-eth0.pid`
# the dhcpcd is used
#else
#   pid=`cat /etc/dhcpcd/dhcpcd-eth0.pid`
#fi
#step
echo_local -n "5.3 Copying relevant files"
if [ ! -L /mnt/newroot/$cdsl_local_dir ]; then cdsl_local_dir=""; fi
exec_local copy_relevant_files $cdsl_local_dir
cd /mnt/newroot

echo_local -n "5.3.1 Copying logfile to /mnt/newroot/${bootlog}..."
cp ${bootlog} /mnt/newroot/${bootlog} || cp ${bootlog} /mnt/newroot/tmp/$(basename $bootlog)
if [ -f /mnt/newroot/$bootlog ]; then 
  bootlog=/mnt/newroot/$bootlog
else 
  bootlog=/mnt/newroot/$(basename $bootlog)
fi
if [ $? -eq 0 ]; then 
  echo_local "(OK)"
else 
  echo_local "(FAILED)"
fi
# [ ! -d initrd ] && mkdir initrd
# exec_local /sbin/pivot_root . initrd
#echo_local "6.1 Restarting network with new pivot_root..."
#mount -t proc proc /proc
#kill $pid && /sbin/ifup eth0

if [ -n "$chroot" ]; then
  chRoot
else
  pivotRoot
fi

# $Log: linuxrc.part.gfs.sh,v $
# Revision 1.13  2005-01-03 08:32:59  marc
# first offical rpm version
# - added support for syslogd
# - added support for chroot within lock_gulmd
# - added support for chroot bootparm
# - minor changes
#
# Revision 1.12  2004/09/29 14:32:16  marc
# vacation checkin, stable version
#
# Revision 1.11  2004/09/26 15:07:15  marc
# major bug. removed
#
# Revision 1.10  2004/09/26 14:56:00  marc
# better error detection
#
# Revision 1.9  2004/09/26 14:08:53  marc
# moved copying of relevant files to outside
#
# Revision 1.8  2004/09/24 14:25:21  marc
# minor changes in ordering
#
# Revision 1.7  2004/09/24 09:36:03  marc
# added iscsi
#
# Revision 1.6  2004/09/12 11:11:19  marc
# added generation of hostsfile from cca
#
# Revision 1.5  2004/09/08 16:12:33  marc
# first stabel version for autoconfigure from cca
#
# Revision 1.4  2004/08/13 15:53:33  marc
# added support for chroot
#
# Revision 1.3  2004/08/11 16:53:16  marc
# inbetween version
#
# Revision 1.2  2004/08/01 21:00:31  marc
# com-rescan-scsi.sh: made the qla2?00 drivers work without -l option
# linux.part.gfs.sh:  major bugfixes for debugging.
#
# Revision 1.1  2004/07/31 11:24:43  marc
# initial revision
#
