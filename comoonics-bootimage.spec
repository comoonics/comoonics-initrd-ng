#****h* comoonics-bootimage/comoonics-bootimage.spec
#  NAME
#    comoonics-bootimage.spec
#    $id$
#  DESCRIPTION
#    RPM Configurationfile for the Comoonics bootimage
#  AUTHOR
#    Marc Grimme
#
#*******
# @(#)$File:$
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
#/initrd_sr-2.6.9-34.ELsmp.img.gz
# %define _initrddir /etc/init.d
# $Id: comoonics-bootimage.spec,v 1.34 2007-03-01 10:50:04 marc Exp $
#
##
# TO DO
# etc/rc.sysinit:
#  #if [ -z "$fastboot" -a "$READONLY" != "yes" -a "X$ROOTFSTYPE" != "Xnfs" -a "X$ROOTFSTYPE" != "Xnfs4" ]; then
#  if [ -z "$fastboot" -a "$READONLY" != "yes" -a "X$ROOTFSTYPE" != "Xnfs" -a "X$ROOTFSTYPE" != "Xnfs4" -a "X$ROOTFSTYPE" != "Xgfs" ]; then
##

%define _user root
%define CONFIGDIR /%{_sysconfdir}/comoonics
%define APPDIR    /opt/atix/%{name}
%define ENVDIR    /etc/profile.d
%define ENVFILE   %{ENVDIR}/%{name}.sh
%define INITDIR   /etc/rc.d/init.d
%define SYSCONFIGDIR /%{_sysconfdir}/sysconfig

%define FENCEACKSV_SOURCE fencing/fence-ack-server
%define FENCEACKSV_DIR    /opt/atix/comoonics-fenceacksv

%define FENCECLIENTS_SOURCE fencing/
%define FENCECLIENTS_DIR /opt/atix/comoonics-fencing
%define FENCECLIENTS_DOC /usr/share/doc/comoonics-fencing

Name: comoonics-bootimage
Summary: Comoonics Bootimage. Scripts for creating an initrd in a gfs shared root environment
Version: 1.0
BuildArch: noarch
Requires: comoonics-cs >= 0.5-17, comoonics-cs-py >= 0.1-15
Conflicts: tmpwatch
Release: 81
Vendor: ATIX GmbH
Packager: Marc Grimme (grimme@atix.de)
ExclusiveArch: noarch
URL:     http://www.atix.de/
Source:  http://www.atix.de/software/downloads/comoonics/comoonics-bootimage-%{version}.tar.gz
License: GPL
Group:   Storage/Management
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description
Comoonics Bootimage. Scripts for creating an initrd in a gfs shared root environment

%package fenceacksv
Version: 0.1
Release: 12
Requires: comoonics-cs-py >= 0.1-23
Requires: comoonics-bootimage >= 1.0-47
Summary: The Fence ackserver is a service running in the fencedchroot and managing manual fenced nodes
Group:   Storage/Management
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description fenceacksv
The Fence ackserver is a service running in the fencedchroot and managing manual fenced nodes

%package fenceclient-ilo
Version: 0.1
Release: 16
Summary: An alternative fence client for ilo cards of HP servers. Written in python.
Group:   Storage/Management
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description fenceclient-ilo
An alternative fence client for ilo cards of HP servers. Written in python.

%package fenceclient-vmware
Version: 0.1
Release: 4
Summary: Fencing for vmware
Group:   Storage/Management
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description fenceclient-vmware
Fencing for vmware client

%package fencemaster-vmware
Version: 0.1
Release: 1
Summary: Fencing for vmware
Group:   Storage/Management
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description fencemaster-vmware
Fencing for the vmware master server

%prep
%setup -q

%build

%install
make PREFIX=$RPM_BUILD_ROOT INSTALL_DIR=%{APPDIR} install

# Files for fenceacksv
install -d -m 755 $RPM_BUILD_ROOT/%{FENCEACKSV_DIR}
install -m755 %{FENCEACKSV_SOURCE}/fence_ack_server.py $RPM_BUILD_ROOT/%{FENCEACKSV_DIR}/
install -m644 %{FENCEACKSV_SOURCE}/shell.py $RPM_BUILD_ROOT/%{FENCEACKSV_DIR}/
install -m644 %{FENCEACKSV_SOURCE}/pexpect.py $RPM_BUILD_ROOT/%{FENCEACKSV_DIR}/
install -m640 %{FENCEACKSV_SOURCE}/server.pkey $RPM_BUILD_ROOT/%{FENCEACKSV_DIR}/
install -m640 %{FENCEACKSV_SOURCE}/server.cert $RPM_BUILD_ROOT/%{FENCEACKSV_DIR}/
install -m640 %{FENCEACKSV_SOURCE}/CA.pkey $RPM_BUILD_ROOT/%{FENCEACKSV_DIR}/
install -m640 %{FENCEACKSV_SOURCE}/CA.cert $RPM_BUILD_ROOT/%{FENCEACKSV_DIR}/

install -m755 %{FENCEACKSV_SOURCE}/fenceacksv.sh $RPM_BUILD_ROOT/%{INITDIR}/fenceacksv
install -m644 %{FENCEACKSV_SOURCE}/files-fenceacksv.list $RPM_BUILD_ROOT/%{CONFIGDIR}/bootimage/files.initrd.d/fenceacksv.list
install -m644 %{FENCEACKSV_SOURCE}/rpms-fenceacksv.list $RPM_BUILD_ROOT/%{CONFIGDIR}/bootimage/rpms.initrd.d/fenceacksv.list
# install -m640 %{FENCEACKSV_SOURCE}/fenceacksv-config.sh $RPM_BUILD_ROOT/%{SYSCONFIGDIR}/fenceacksv

# Files for fence-clients (ilo)
install -d -m 755 $RPM_BUILD_ROOT/%{FENCECLIENTS_DIR}
install -d -m 755 $RPM_BUILD_ROOT/%{FENCECLIENTS_DOC}
install -m755 %{FENCECLIENTS_SOURCE}/fence_ilo.py  $RPM_BUILD_ROOT/%{FENCECLIENTS_DIR}/fence_ilo
install -m755 %{FENCECLIENTS_SOURCE}/rpms-fence_ilo.list $RPM_BUILD_ROOT/%{CONFIGDIR}/bootimage/rpms.initrd.d/fence_ilo.list

# Files for fence-vmware
install -m755 %{FENCECLIENTS_SOURCE}/fence_vmware_client  $RPM_BUILD_ROOT/%{FENCECLIENTS_DIR}
install -m755 %{FENCECLIENTS_SOURCE}/rpms-fence_vmware_client.list $RPM_BUILD_ROOT/%{CONFIGDIR}/bootimage/rpms.initrd.d/fence_vmware_client.list
install -m755 %{FENCECLIENTS_SOURCE}/fence_vmware_master  $RPM_BUILD_ROOT/%{FENCECLIENTS_DIR}
install -m755 %{FENCECLIENTS_SOURCE}/README.fence_vmware  $RPM_BUILD_ROOT/%{FENCECLIENTS_DOC}
install -m755 %{FENCECLIENTS_SOURCE}/INSTALL.fence_vmware  $RPM_BUILD_ROOT/%{FENCECLIENTS_DOC}

%postun

if [ "$1" -eq 0 ]; then
  echo "Postuninstalling comoonics-bootimage.."
  find /etc/comoonics/bootimage -name "files*.list" -o -name "rpms*.list" -type l -exec rm -f {} \; &>/dev/null
  root_fstype=$(mount | grep "/ " | awk '
BEGIN { exit_c=1; }
{ if ($5) {  print $5; exit_c=0; } }
END{ exit exit_c}')/usr/src/redhat/RPMS/noarch/comoonics-bootimage-1.0-41.noarch.rpm
  if [ "$root_fstype" != "gfs" ]; then
#    /sbin/chkconfig --del bootsr &>/dev/null
#    /sbin/chkconfig bootsr off
#    /sbin/chkconfig --list bootsr
#    /sbin/chkconfig --del fenced-chroot &>/dev/null
#    /sbin/chkconfig fenced-chroot off
#    /sbin/chkconfig --list fenced-chroot
    /sbin/chkconfig --add fenced &>/dev/null
    /sbin/chkconfig --list fenced
    /sbin/chkconfig --add cman &>/dev/null
    /sbin/chkconfig --list cman
    /sbin/chkconfig --add gfs &>/dev/null
    /sbin/chkconfig --list gfs
    /sbin/chkconfig --add ccsd &>/dev/null
    /sbin/chkconfig --list ccsd
  fi
  rm %{APPDIR}/mkinitrd
  rm %{ENVFILE}
fi

%post

echo "Starting postinstall.."
echo "Checking %{ENVFILE}"
if ! $(grep '%{APPDIR}' %{ENVFILE} > /dev/null 2>&1); then
    echo "Patching path.."
    echo 'PATH=%{APPDIR}:${PATH}' >> %{ENVFILE}
fi
echo "Creating mkinitrd link..."
ln -sf %{APPDIR}/create-gfs-initrd-generic.sh %{APPDIR}/mkinitrd

/sbin/chkconfig --add bootsr &>/dev/null
/sbin/chkconfig bootsr on
/sbin/chkconfig --list bootsr
/sbin/chkconfig --add preccsd &>/dev/null
/sbin/chkconfig preccsd on
/sbin/chkconfig --list preccsd
/sbin/chkconfig --add ccsd-chroot &>/dev/null
/sbin/chkconfig --list ccsd-chroot
/sbin/chkconfig ccsd off
/sbin/chkconfig --list ccsd
/sbin/chkconfig --add fenced-chroot &>/dev/null
/sbin/chkconfig fenced-chroot on
/sbin/chkconfig --list fenced-chroot
/sbin/chkconfig fenced off
/sbin/chkconfig --del fenced &>/dev/null
/sbin/chkconfig gfs off
/sbin/chkconfig --del gfs
grep "^FENCE_CHROOT=" %{SYSCONFIGDIR}/cluster &>/dev/null
[ $? -ne 0 ] && echo "FENCE_CHROOT=/var/lib/fence_tool" >> %{SYSCONFIGDIR}/cluster
/bin/true
grep "^FENCE_CHROOT_SOURCE=" %{SYSCONFIGDIR}/cluster &>/dev/null
[ $? -ne 0 ] && echo "FENCE_CHROOT_SOURCE=/var/lib/fence_tool.tmp" >> %{SYSCONFIGDIR}/cluster
/bin/true

echo 'Information:
You can now setup fenced on running on a localfilesystem which is not a cluster filesystem.
You just need to setup up the %{SYSCONFIGDIR}/cluster configuration file apropriate.
Example:
Say /tmp would reside on "ext3" and you would like fenced to be running on /tmp/fence_tool then
%{SYSCONFIGDIR}/cluster looks as follows:
FENCE_CHROOT=/tmp/fence_tool

Then fenced will be started on root /tmp/fence_tool
If you want syslog to log fence messages you should add ${FENCE_CHROOT}/dev/log to the syslog deamon as
additional logdevice (command switch syslogd -a ${FENCE_CHROOT}/dev/log)

CONFLICTS:
- tmpwatch:
tmpwatch can remove all files in /tmp/fence_chroot. If tmpwatch is installed, you need to modify
/etc/cron.daily/tmpwatch to fit your needs.
'

%post fenceacksv
echo "Setting up fenceacksv"
pushd %{FENCEACKSV_DIR} >/dev/null
ln -sf fence_ack_server.py fenceacksv
popd >/dev/null
chkconfig --add fenceacksv &> /dev/null
chkconfig --list fenceacksv
echo "Done"

%preun fenceacksv
if [ "$1" -eq 0 ]; then
  echo "Uninstalling fenceacksv"
  chkconfig --del fenceacksv
fi

%files

%dir %{APPDIR}/boot-scripts/sys
%dir %{APPDIR}/boot-scripts/var/log
%dir %{APPDIR}/boot-scripts/var/lib/dhcp
%dir %{APPDIR}/boot-scripts/var/run/netreport
%dir %{APPDIR}/boot-scripts/proc
%dir %{APPDIR}/boot-scripts/dev
%attr(750, root, root) %{INITDIR}/bootsr
%attr(750, root, root) %{INITDIR}/preccsd
%attr(750, root, root) %{INITDIR}/fenced-chroot
%attr(750, root, root) %{INITDIR}/ccsd-chroot
%attr(750, root, root) %{APPDIR}/create-gfs-initrd-generic.sh
%attr(750, root, root) %{APPDIR}/mkservice_for_initrd.sh
%attr(750, root, root) %{APPDIR}/boot-scripts/linuxrc.generic.sh
%attr(750, root, root) %{APPDIR}/boot-scripts/exec_part_from_bash.sh
%attr(750, root, root) %{APPDIR}/boot-scripts/detectHardware.sh
%attr(750, root, root) %{APPDIR}/boot-scripts/rescue.sh
%attr(750, root, root) %{APPDIR}/boot-scripts/linuxrc
%attr(750, root, root) %{APPDIR}/boot-scripts/linuxrc.bash
%attr(640, root, root) %{APPDIR}/create-gfs-initrd-lib.sh
%attr(640, root, root) %{APPDIR}/boot-scripts/etc/atix.txt
%attr(640, root, root) %{APPDIR}/boot-scripts/etc/passwd
%attr(640, root, root) %{APPDIR}/boot-scripts/etc/boot-lib.sh
%attr(640, root, root) %{APPDIR}/boot-scripts/etc/gfs-lib.sh
%attr(640, root, root) %{APPDIR}/boot-scripts/etc/comoonics-release
%attr(640, root, root) %{APPDIR}/boot-scripts/etc/iscsi-lib.sh
%attr(640, root, root) %{APPDIR}/boot-scripts/etc/fenced_mv_files.list
%attr(640, root, root) %{APPDIR}/boot-scripts/etc/fenced_cp_files.list
%attr(640, root, root) %{APPDIR}/boot-scripts/etc/fenced_dirs.list
%attr(640, root, root) %{APPDIR}/boot-scripts/etc/sysconfig/comoonics
%attr(640, root, root) %{APPDIR}/boot-scripts/etc/inittab
%attr(640, root, root) %{APPDIR}/boot-scripts/etc/clusterfs-lib.sh
%attr(640, root, root) %{APPDIR}/boot-scripts/etc/hardware-lib.sh
%attr(640, root, root) %{APPDIR}/boot-scripts/etc/network-lib.sh
%attr(640, root, root) %{APPDIR}/boot-scripts/etc/rhel4/hardware-lib.sh
%attr(640, root, root) %{APPDIR}/boot-scripts/etc/rhel4/network-lib.sh
%attr(640, root, root) %{APPDIR}/boot-scripts/etc/sles8/hardware-lib.sh
%attr(640, root, root) %{APPDIR}/boot-scripts/etc/sles8/network-lib.sh
%attr(640, root, root) %{CONFIGDIR}/bootimage/basefiles.list
%attr(640, root, root) %{CONFIGDIR}/bootimage/rpms.list
%attr(640, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/configs.list
%attr(640, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/vlan.list
%attr(640, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/scsi.list
%attr(640, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/gfs.list
%attr(640, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/iscsi.list.opt
%attr(640, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/lilo.list.opt
%attr(640, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/hp_tools.list.opt
%attr(640, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/perlcc.list.opt
%attr(640, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/grub.list
%attr(640, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/libs.list.x86_64
%attr(640, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/libs.list.i686
%attr(640, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/fence_vmware.list.opt
%attr(640, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/debug.list.opt
%attr(640, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/comoonics.list
%attr(640, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/python.list
%attr(640, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/perl.list
%attr(640, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/dm_multipath.list

%config(noreplace) %{CONFIGDIR}/comoonics-bootimage.cfg
%config(noreplace) %{CONFIGDIR}/bootimage/files.initrd.d/user_edit.list

%doc CHANGELOG

%files fenceacksv
%attr(755, root, root) %{FENCEACKSV_DIR}/fence_ack_server.py
%attr(644, root, root) %{FENCEACKSV_DIR}/shell.py
%attr(644, root, root) %{FENCEACKSV_DIR}/pexpect.py
%attr(640, root, root) %{FENCEACKSV_DIR}/server.pkey
%attr(640, root, root) %{FENCEACKSV_DIR}/server.cert
%attr(640, root, root) %{FENCEACKSV_DIR}/CA.pkey
%attr(640, root, root) %{FENCEACKSV_DIR}/CA.cert
%attr(755, root, root) %{INITDIR}/fenceacksv
%attr(644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/fenceacksv.list
%attr(644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/fenceacksv.list
# %config(noreplace)     %{SYSCONFIGDIR}/fenceacksv
%doc CHANGELOG

%files fenceclient-ilo
%attr(755, root, root) %{FENCECLIENTS_DIR}/fence_ilo
%attr(640, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/fence_ilo.list
%doc CHANGELOG

%files fenceclient-vmware
%attr(755, root, root) %{FENCECLIENTS_DIR}/fence_vmware_client
%doc %{FENCECLIENTS_DOC}/INSTALL.fence_vmware
%doc %{FENCECLIENTS_DOC}/README.fence_vmware
%attr(640, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/fence_vmware_client.list
%doc CHANGELOG

%files fencemaster-vmware
%attr(755, root, root) %{FENCECLIENTS_DIR}/fence_vmware_master
%doc %{FENCECLIENTS_DOC}/INSTALL.fence_vmware
%doc %{FENCECLIENTS_DOC}/README.fence_vmware
%doc CHANGELOG

%changelog
* Fri Feb 09 2007 Mark Hlawatschek <hlawatschek@atix.de> 1.0.81
- added support for dm_multipath partitions
* Fri Feb 09 2007 Marc Grimme <grimme@atix.de> 1.0.81-rc
- added nodeid parameter at boottime (bonding not clear)
- bootsr will only rebuild if needed
- added nsswitch.conf to chroot. Because of ccs_tool update sometime failed.
- better step continue mode
* Mon Jan 22 2007 Mark Hlawatschek <hlawatschek at atix.de> 1.0.73
- added changelog
- added support for vlan devices
- added support for kernel cmdline initlevel
- added dstep-mode kernel parameter -> ask (Y|n|c) with evey exec_local
* Fri May 12 2006  <grimme@atix.de> - 1.0-7
- First stable 1.0 Version is RPM 1.0-7

* Wed Jan 25 2006  <grimme@atix.de> - 0.3-12
- First stable 0.3 version


* Mon Jan  3 2005 Marc Grimme <grimme@atix.de> - 0.1-16
- first offical rpm version

%changelog fenceacksv
* Wed Feb 07 2007 Marc Grimme <grimme@atix.de - 0.1-11
- introducted changelog

%changelog fenceclient-ilo
* Wed Feb 07 2007 Marc Grimme <grimme@atix.de - 0.1-16
- introducted changelog

%changelog fenceclient-vmware
* Wed Feb 07 2007 Marc Grimme <grimme@atix.de - 0.1-4
- introducted changelog

%changelog fencemaster-vmware
* Wed Feb 07 2007 Marc Grimme <grimme@atix.de - 0.1-1
- introducted changelog

# ------
# $Log: comoonics-bootimage.spec,v $
# Revision 1.34  2007-03-01 10:50:04  marc
# changed getopt
#
# Revision 1.33  2007/02/23 16:44:50  mark
# revision 1.0.81
#
# Revision 1.32  2007/02/09 11:08:17  marc
# new version 81
#
# Revision 1.31  2007/01/23 12:57:14  mark
# new release 1.0.75
#
# Revision 1.30  2006/12/04 17:37:12  marc
# new versions
#
# Revision 1.29  2006/11/10 11:38:29  mark
# release 1.0.73
# added conflicts tmpwatch and tmpwatch warnings
#
# Revision 1.28  2006/10/26 16:13:24  mark
# release got from src.rpm
# added support for ccsd-chroot
#
# Revision 1.27  2006/10/06 08:36:27  marc
# version with quorumack
#
# Revision 1.26  2006/08/28 16:00:27  marc
# very well tested version
#
# Revision 1.25  2006/08/14 17:42:41  marc
# new version with max_drop_count and fenced from local disk
#
# Revision 1.24  2006/07/19 15:14:39  marc
# removed the fence-tool lists for chroot
#
# Revision 1.23  2006/07/19 15:11:36  marc
# fixed fence_bug for x86_64
#
# Revision 1.22  2006/07/13 11:35:16  marc
# new version changing file xtensions
#
# Revision 1.21  2006/07/03 08:33:59  marc
# new version
#
# Revision 1.20  2006/06/19 15:57:40  marc
# added devicemapper support
#
# Revision 1.19  2006/06/09 14:04:05  marc%attr(640, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/configs.list

# new version.
#
# Revision 1.18  2006/06/07 09:42:23  marc
# *** empty log message ***
#
# Revision 1.17  2006/05/12 13:01:56  marc
# First stable 1.0 Version
#
# Revision 1.16  2006/05/07 12:06:56  marc
# version 1.0 stable
#
# Revision 1.15  2006/05/03 12:47:17  marc
# added documentation
#
# Revision 1.14  2006/04/13 18:52:09  marc
# latest versino
#
# Revision 1.13  2006/04/13 18:46:31  marc
# new version
#
# Revision 1.12  2006/04/11 13:42:45  marc
# cvs stable version
#
# Revision 1.11  2006/04/11 13:41:20  marc
# added hostnames and x86_64 support
#
# Revision 1.10  2006/02/16 13:59:06  marc
# stable version 20
#
# Revision 1.9  2006/01/28 15:01:49  marc
# fenced is restarted in the initrd
#
# Revision 1.8  2006/01/25 14:55:51  marc
# first stable 0.3
#
# Revision 1.7  2006/01/23 14:05:30  mark
# added bootsr
#
# Revision 1.6  2005/07/08 13:15:57  mark
# added some files
#
# Revision 1.5  2005/06/27 14:24:20  mark
# added gfs 61, rhel4 support
#
# Revision 1.4  2005/06/08 13:33:22  marc
# new revision
#
# Revision 1.3  2005/01/05 10:57:07  marc
# new release and added the latest files.
#
# Revision 1.2  2005/01/03 08:34:16  marc
# added new subversion for first offical rpm version
#
# Revision 1.1  2005/01/03 08:33:17  marc
# first offical rpm version
# - initial revision
#
#
