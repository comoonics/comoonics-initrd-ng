#****h* comoonics-bootimage/comoonics-bootimage.spec
#  NAME
#    comoonics-bootimage-initscripts.spec
#    $id$
#  DESCRIPTION
#    initscripts for the Comoonics bootimage
#  AUTHOR
#    Mark Hlawatschek
#
#*******
# @(#)$File:$
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

# $Id: comoonics-bootimage-initscripts-el5.spec,v 1.30 2011-02-28 14:27:42 marc Exp $
#
##
##

%define _user root
%define CONFIGDIR /%{_sysconfdir}/comoonics
%define APPDIR    /opt/atix/comoonics-bootimage
%define SBINDIR   /sbin
%define ENVDIR    /etc/profile.d
%define ENVFILE   %{ENVDIR}/%{name}.sh
%define INITDIR   /etc/rc.d/init.d
%define SYSCONFIGDIR /%{_sysconfdir}/sysconfig
%define KERNEL_SYSCONFIG_FILE %{SYSCONFIGDIR}/kernel
%define COMOONICS_NEW_KERNEL_PKG_UPDATE %{APPDIR}/patches/new-kernel-pkg-update.sh

%define RELEASENAME Gumpn
%define PRODUCTNAME OpenSharedRoot
%define PRODUCTVERSION 5.0
%define DISTRIBUTIONNAME %{PRODUCTNAME} %{PRODUCTVERSION} (%{RELEASENAME})
%define DISTRIBUTIONBASE %{DISTRIBUTIONNAME} Base
%define DISTRIBUTIONEXTRAS %{DISTRIBUTIONNAME} Extras

%define GROUPPARENT System Environment
%define GROUPCHILDEXTRAS Extras
%define GROUPCHILDBASE Base
%define GROUPCHILDSLES SLES
%define GROUPCHILDSLES10 SLES10
%define GROUPCHILDSLES11 SLES11
%define GROUPCHILDRHEL RHEL
%define GROUPCHILDRHEL4 RHEL4
%define GROUPCHILDRHEL5 RHEL5
%define GROUPCHILDRHEL6 RHEL6
%define GROUPCHILDFEDORA Fedora

Name: comoonics-bootimage-initscripts
Summary: Initscripts used by the OSR cluster environment.
Version: 5.0
BuildArch: noarch
Requires: comoonics-bootimage >= 5.0
Requires: comoonics-bootimage-listfiles-all
Requires: comoonics-bootimage-listfiles-rhel5
#Conflicts: 
Release: 3_rhel5
Vendor: ATIX AG
Packager: ATIX AG <http://bugzilla.atix.de>
ExclusiveArch: noarch
URL:     http://www.atix.de/
Source:  http://www.atix.de/software/downloads/comoonics/comoonics-bootimage-initscripts-%{version}.tar.gz
License: GPL
Group:   %{GROUPPARENT}/%{GROUPCHILDBASE}/%{GROUPCHILDRHEL5}
Distribution: %{DISTRIBUTIONBASE}
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description
Initscripts used by the OSR cluster environment.

%prep
%setup -n comoonics-bootimage-%{version}

%build

%install
# Files for compat
install -d -m 755 $RPM_BUILD_ROOT/%{INITDIR}
install -m755 initscripts/bootsr $RPM_BUILD_ROOT/%{INITDIR}/bootsr
install -m755 initscripts/mountcdsls $RPM_BUILD_ROOT/%{INITDIR}/mountcdsls
install -d -m 755 $RPM_BUILD_ROOT/%{APPDIR}/patches
install -m600 initscripts/rhel5/halt-xtab.patch $RPM_BUILD_ROOT/%{APPDIR}/patches/halt-xtab.patch
#install -m600 initscripts/rhel5/halt-local.patch $RPM_BUILD_ROOT/%{APPDIR}/patches/halt-local.patch
install -m600 initscripts/rhel5/halt-killall.patch $RPM_BUILD_ROOT/%{APPDIR}/patches/halt-killall.patch
install -m600 initscripts/rhel5/halt-comoonics.patch $RPM_BUILD_ROOT/%{APPDIR}/patches/halt-comoonics.patch
install -m600 initscripts/rhel5/netfs-xtab.patch $RPM_BUILD_ROOT/%{APPDIR}/patches/netfs-xtab.patch
install -m600 initscripts/rhel5/netfs-comoonics.patch $RPM_BUILD_ROOT/%{APPDIR}/patches/netfs-comoonics.patch
install -m600 initscripts/rhel5/network-xrootfs.patch $RPM_BUILD_ROOT/%{APPDIR}/patches/network-xrootfs.patch
install -m600 initscripts/rhel5/network-comoonics.patch $RPM_BUILD_ROOT/%{APPDIR}/patches/network-comoonics.patch
install -m600 initscripts/rhel5/halt.orig $RPM_BUILD_ROOT/%{APPDIR}/patches/halt.orig
install -m600 initscripts/rhel5/network.orig $RPM_BUILD_ROOT/%{APPDIR}/patches/network.orig
install -m600 initscripts/rhel5/netfs.orig $RPM_BUILD_ROOT/%{APPDIR}/patches/netfs.orig
install -m600 initscripts/rhel5/halt $RPM_BUILD_ROOT/%{APPDIR}/patches/halt
install -m600 initscripts/rhel5/network $RPM_BUILD_ROOT/%{APPDIR}/patches/network
install -m600 initscripts/rhel5/netfs $RPM_BUILD_ROOT/%{APPDIR}/patches/netfs
install -d $RPM_BUILD_ROOT/%{SBINDIR}
install -m755 initscripts/halt.local $RPM_BUILD_ROOT/%{SBINDIR}/halt.local
install -m600 initscripts/rhel5/new-kernel-pkg-update.sh $RPM_BUILD_ROOT/%{APPDIR}/patches/new-kernel-pkg-update.sh

%preun
if [ "$1" -eq 0 ]; then
  echo "Preuninstalling comoonics-bootimage-initscripts"
  /sbin/chkconfig --del bootsr
  # we patch all versions here
fi

%pre

#if this is an upgrade we need to unpatch all files
if [ "$1" -eq 2 ]; then
  # we patch all versions here
  for initscript in halt network netfs; do
	if grep "comoonics patch " /etc/init.d/$initscript > /dev/null; then
		# the old way
		if [ -e /opt/atix/comoonics-bootimage/patches/${initscript}.patch ]; then
		   patchfile="/opt/atix/comoonics-bootimage/patches/${initscript}.patch"
		   echo -n "Unpatching initscript($patchfile)"
		   cd /etc/init.d/ && patch -R -f -r /tmp/$(basename ${patchfile}).patch.rej > /dev/null < $patchfile
		   if [ $? -ne 0 ]; then
		      echo >&2
		      echo >&2
		      echo "FAILURE!!!!" >&2
		      echo "Patching $initscript with patch $patchfile" >&2
		      echo "You might want to consider restoring the original initscript and the patch again by:" >&2
		      echo "cp /opt/atix/comoonics-bootimage/patches/${initscript}.orig /etc/init.d/${initscript}"
		      echo "/opt/atix/comoonics-bootimage/manage_chroot.sh -a patch_files ${initscript}"
		      echo >&2
		   fi
		   echo
		else
		   echo -n "Unpatching $initscript ("
		   for patchfile in $(ls -1 /opt/atix/comoonics-bootimage/patches/${initscript}-*.patch | sort -r); do
			  echo -n $(basename $patchfile)", "
			  cd /etc/init.d/ && patch -R -f -r /tmp/$(basename ${patchfile}).patch.rej > /dev/null < $patchfile
		      if [ $? -ne 0 ]; then
		      echo >&2
		      echo >&2
		      echo "FAILURE!!!!" >&2
		      echo "Patching $initscript with patch $patchfile" >&2
		      echo "You might want to consider restoring the original initscript and the patch again by:" >&2
		      echo "cp /opt/atix/comoonics-bootimage/patches/${initscript}.orig /etc/init.d/${initscript}"
		      echo "/opt/atix/comoonics-bootimage/manage_chroot.sh -a patch_files ${initscript}"
		      echo >&2
		      fi
		   done
		   echo ")"
		fi
	fi
  done
fi 

%post

echo "Starting postinstall.."
services="bootsr mountcdsls"
echo "Resetting services ($services)"
for service in $services; do
   /sbin/chkconfig --del $service &>/dev/null
   /sbin/chkconfig --add $service
   /sbin/chkconfig $service on
   /sbin/chkconfig --list $service
done

services=""
echo "Disabling services ($services)"
for service in $services; do
   /sbin/chkconfig --del $service &> /dev/null
done

if ! grep "source %{COMOONICS_NEW_KERNEL_PKG_UPDATE}" "%{KERNEL_SYSCONFIG_FILE}" &>/dev/null; then
  echo "Adapting  %{KERNEL_SYSCONFIG_FILE} .."
  echo "test -e %{COMOONICS_NEW_KERNEL_PKG_UPDATE} && source %{COMOONICS_NEW_KERNEL_PKG_UPDATE}" >> %{KERNEL_SYSCONFIG_FILE}
fi

/bin/true

%postun
if [ -L %{SBINDIR}/halt.local ]; then
   rm %{SBINDIR}/halt.local
fi

%files

%attr(755, root, root) %{INITDIR}/bootsr
%attr(755, root, root) %{INITDIR}/mountcdsls
%attr(755, root, root) %{APPDIR}/patches/halt
%attr(755, root, root) %{APPDIR}/patches/halt.orig
%attr(644, root, root) %{APPDIR}/patches/halt-comoonics.patch
%attr(644, root, root) %{APPDIR}/patches/halt-killall.patch
#%attr(644, root, root) %{APPDIR}/patches/halt-local.patch
%attr(644, root, root) %{APPDIR}/patches/halt-xtab.patch
%attr(755, root, root) %{APPDIR}/patches/netfs
%attr(755, root, root) %{APPDIR}/patches/netfs.orig
%attr(644, root, root) %{APPDIR}/patches/netfs-comoonics.patch
%attr(644, root, root) %{APPDIR}/patches/netfs-xtab.patch
%attr(755, root, root) %{APPDIR}/patches/network
%attr(755, root, root) %{APPDIR}/patches/network.orig
%attr(644, root, root) %{APPDIR}/patches/network-comoonics.patch
%attr(644, root, root) %{APPDIR}/patches/network-xrootfs.patch
%attr(644, root, root) %{APPDIR}/patches/new-kernel-pkg-update.sh
%attr(755, root, root) %{SBINDIR}/halt.local

%clean
rm -rf %{buildroot}

%changelog
* Fri Nov 25 2011 Marc Grimme <grimme ( at )atix.de> - 5.0-3_rhel5
  * initscripts/bootsr: - Added call to update the repository from initrd -
    Only remount cdsl environment if it is not only in /etc/mtab existant - other
    handling fixes with chrootneeded
* Thu Nov 03 2011 Marc Grimme <grimme( at )atix.de> - 5.0-2_rhel5
  * If no comoonics killall5 is available fall back to old one and don't issue errors.
* Tue Nov 01 2011 Marc Grimme <grimme( at )atix.de> - 5.0-1_rhel5
  * Rebase for Release 5.0
* Tue Oct 25 2011 Marc Grimme <grimme( at )atix.de> 1.4-26.rhel5
- added RHEL5.7 initscripts (patched and unpatched).
* Fri Aug 05 2011 Marc Grimme <grimme@atix.de> 1.4-25.rhel5
- removed dep to SysVInit-comooics (will be found if the filesystem 
  - comoonics-bootimage-listfiles-<dist>-<filesystem> - rpm).
- Compatible with RHEL5.7 and below
* Thu Jul 28 2011 Marc Grimme <grimme@atix.de> 1.4-24.rhel5
- upstream patches for RHEL5.7
* Tue May 03 2011 Marc Grimme <grimme@atix.de> 1.4-23.rhel5
- added bootsr from generic initscripts
- introducing updated version to /sbin/new-kernel-pkg-update in order to allow autobuild of initrds 
  (requirement boot is mounted).
* Tue Mar 22 2011 Marc Grimme <grimme@atix.de> 1.4-22.rhel5
- Rebase
* Tue Mar 22 2011 Marc Grimme <grimme@atix.de> 1.4-21.rhel5
- Rebase
* Mon Feb 28 2011 Marc Grimme <grimme@atix.de> 1.4-20.rhel5
- halt.local will now be a file being installed instead of a symbolic link.
* Wed Aug 18 2010 Marc Grimme <grimme@atix.de> 1.4-19.rhel5
- initscripts/rhel4,rhel5,fedora,sles10,sles11/bootsr
  - fixed bug #382 where the cdsl.local was not remounted in /etc/mtab on locally installed systems
* Thu Jul 08 2010 Marc Grimme <grimme@atix.de> 1.4-18.rhel5
- bootsr uses bash as shell
* Thu Jun 08 2010 Marc Grimme <grimme@atix.de> 1.4-17.rhel5
- introducted initscript mountcdsls
* Fri Apr 23 2010 Marc Grimme <grimme@atix.de> 1.4-16.rhel5
- netfs-tab.patch: initial revision
- netfs-xtab.patch: removed old data
* Tue Feb 23 2010 Marc Grimme <grimme@atix.de> 1.4-15.rhel5
- Fixes in check_mtab
* Fri Oct 09 2009 Marc Grimme <grimme@atix.de> 1.4-13el5
- removed halt patches as the are not needed with /sbin/halt.local
* Thu Oct 08 2009 Marc Grimme <grimme@atix.de> 1.4-12el5
- halt.local is now a link to /opt/atix/comoonics-bootimage/bootscripts/com-halt.sh
* Mon Apr 20 2009 Marc Grimme <grimme@atix.de> 1.4-10el5
- RC1
* Tue Apr 16 2009 Marc Grimme <grimme@atix.de> 1.4-9el5
- Syncronized bootsr and fixed calling of _init
* Wed Apr 15 2009 Marc Grimme <grimme@atix.de> 1.4-8el5
- Working release with gfs
* Wed Apr 15 2009 Marc Grimme <grimme@atix.de> 1.4-4el5
- XFiles patch and small patches ported to rhel5 first version.
* Fri Mar 27 2009 Marc Grimme <grimme@atix.de> 1.4-3el5
- Fixed a BUG with RHEL5 and gfs as rootfs
* Mon Feb 02 2009 Marc Grimme <grimme@atix.de> 1.3-12el5
- Bugfix in support for other filesystems
* Tue Nov 18 2008 Marc Grimme <grimme@atix.de> 1.3-11el5
- Support for glusterfs
* Tue Nov 18 2008 Marc Grimme <grimme@atix.de> 1.3-10el5
- Clean up of old repository caches (Bug #289)
* Tue Oct 14 2008 Marc Grimme <grimme@atix.de> 1.3-9el5
- Enhancement #273 and dependencies implemented (flexible boot of local fs systems)
* Tue Jun 24 2008 Mark Hlawatschek <hlawatschek@atix.de> 1.3.8
- changed kill level fro bootsr initscript
* Fri Jun 20 2008 Mark Hlawatschek <hlawatschek@atix.de> 1.3.7
- added patch for netfs and network
* Tue Jun 10 2008 Marc Grimme <grimme@atix.de> - 1.3-6
- rewrote reboot concept
* Wed Nov 28 2007 Mark Hlawatschek <hlawatschek@atix.de> 1.3.5
- Fixed BZ 150
* Tue Sep 25 2007 Mark Hlawatschek <hlawatschek@atix.de> 1.3.3
- create symlinks in /var/run
* Wed Sep 19 2007 Mark Hlawatschek <hlawatschek@atix.de> 1.3.2
- added file halt.patch
* Wed Sep 12 2007 Mark Hlawatschek <hlawatschek@atix.de> 1.3.1
- first revision
# ------
# $Log: comoonics-bootimage-initscripts-el5.spec,v $
# Revision 1.30  2011-02-28 14:27:42  marc
# new versions for halt.local as file
#
# Revision 1.29  2010/08/18 11:53:28  marc
# new versions
#
# Revision 1.28  2010/07/08 08:39:37  marc
# new versions
#
# Revision 1.27  2010/06/09 08:23:22  marc
# new versions
#
# Revision 1.26  2010/04/23 10:23:53  marc
# new versions
#
# Revision 1.25  2010/03/08 19:35:14  marc
# comoonics-4.6-rc1
#
# Revision 1.24  2010/02/07 20:35:13  marc
# - latest versions
#
# Revision 1.23  2009/08/11 12:17:10  marc
# new versions
#
# Revision 1.22  2009/04/20 07:21:22  marc
# RC1 version 10
#
# Revision 1.21  2009/04/14 15:03:33  marc
# new version
#
# Revision 1.20  2009/02/27 08:42:26  marc
# fixed bug with halt and localfilesystems
#
# Revision 1.19  2009/02/18 18:06:59  marc
# new version
#
# Revision 1.18  2009/02/04 09:22:18  marc
# changed rpm names.
#
# Revision 1.17  2009/02/04 09:17:43  marc
# added true to pre to make it updateable
#
# Revision 1.16  2009/02/03 16:32:46  marc
# new version
#
# Revision 1.15  2009/01/29 19:48:45  marc
# new version
#
# Revision 1.14  2008/12/05 16:12:58  marc
# First step to go rpmlint compat BUG#230
#
# Revision 1.13  2008/12/01 14:46:24  marc
# changed file attributes (Bug #290)
#
# Revision 1.12  2008/11/18 15:59:37  marc
# - implemented RFE-BUG 289 (level up/down)
#
# Revision 1.11  2008/10/14 10:57:07  marc
# Enhancement #273 and dependencies implemented (flexible boot of local fs systems)
#
# Revision 1.10  2008/08/14 14:41:08  marc
# removed listfiles
#
# Revision 1.9  2008/06/24 12:31:01  mark
# changed kill level fro bootsr initscript
#
# Revision 1.8  2008/06/23 22:13:57  mark
# new release
#
# Revision 1.7  2008/06/10 10:11:03  marc
# - new versions
#
# Revision 1.6  2007/12/07 16:39:59  reiner
# Added GPL license and changed ATIX GmbH to AG.
#
# Revision 1.5  2007/11/28 12:41:42  mark
# new release
#
# Revision 1.4  2007/10/05 14:09:53  mark
# new revision
#
# Revision 1.3  2007/09/26 11:55:51  mark
# new releases
#
# Revision 1.2  2007/09/21 15:34:51  mark
# new release
#
# Revision 1.1  2007/09/14 08:32:58  mark
# initial check in
