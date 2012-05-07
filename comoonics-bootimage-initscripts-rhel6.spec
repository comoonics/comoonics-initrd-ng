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

# $Id: comoonics-bootimage-initscripts-el5.spec,v 1.30 2011/02/28 14:27:42 marc Exp $
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
Requires: comoonics-bootimage-listfiles-rhel6
#Conflicts: 
Release: 6_rhel6
Vendor: ATIX AG
Packager: ATIX AG <http://bugzilla.atix.de>
ExclusiveArch: noarch
URL:     http://www.atix.de/
Source:  http://www.atix.de/software/downloads/comoonics/comoonics-bootimage-initscripts-%{version}.tar.gz
License: GPL
Group:   %{GROUPPARENT}/%{GROUPCHILDBASE}/%{GROUPCHILDRHEL6}
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
install -d $RPM_BUILD_ROOT/%{SBINDIR}
install -m755 initscripts/halt.local $RPM_BUILD_ROOT/%{SBINDIR}/halt.local
install -m600 initscripts/rhel6/new-kernel-pkg-update.sh $RPM_BUILD_ROOT/%{APPDIR}/patches/new-kernel-pkg-update.sh
install -m755 initscripts/rhel6/netfs $RPM_BUILD_ROOT/%{APPDIR}/patches/netfs
install -m755 initscripts/rhel6/network $RPM_BUILD_ROOT/%{APPDIR}/patches/network
install -m755 initscripts/rhel6/halt $RPM_BUILD_ROOT/%{APPDIR}/patches/halt
#install -m755 initscripts/rhel6/halt.orig $RPM_BUILD_ROOT/%{APPDIR}/patches/halt.orig
install -m755 initscripts/rhel6/netfs.orig $RPM_BUILD_ROOT/%{APPDIR}/patches/netfs.orig
install -m755 initscripts/rhel6/network.orig $RPM_BUILD_ROOT/%{APPDIR}/patches/network.orig

%preun
if [ "$1" -eq 0 ]; then
  echo "Preuninstalling comoonics-bootimage-initscripts"
  /sbin/chkconfig --del bootsr
fi


%pre

#if this is an upgrade we need to unpatch all files

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

%{APPDIR}/manage_chroot.sh -a patch_files

/bin/true

%postun
if [ -L %{SBINDIR}/halt.local ]; then
   rm %{SBINDIR}/halt.local
fi

%files

%attr(755, root, root) %{INITDIR}/bootsr
%attr(755, root, root) %{INITDIR}/mountcdsls
%attr(755, root, root) %{SBINDIR}/halt.local
%attr(755, root, root) %{APPDIR}/patches/halt
%attr(644, root, root) %{APPDIR}/patches/new-kernel-pkg-update.sh
%attr(755, root, root) %{APPDIR}/patches/netfs
%attr(755, root, root) %{APPDIR}/patches/network
%attr(755, root, root) %{APPDIR}/patches/netfs.orig
%attr(755, root, root) %{APPDIR}/patches/network.orig

%clean
rm -rf %{buildroot}

%changelog
* Mon May 07 2012 Marc Grimme <grimme( at )atix.de> 5.0-6
   - initscripts/rhel5/new-kernel-pkg-update.sh
       would yield an error if grub.conf exists but is not used (NFS Root).
* Tue Mar 08 2012 Marc Grimme <grimme( at )atix.de> 5.0-5
    - netfs added xtab for stop (did not work for nfs)
* Tue Feb 14 2012 Marc Grimme <grimme( at )atix.de> 5.0-4
   - initscripts/bootsr: 
    - changed stop order of bootsr to be stopped later
      (after clvmd has been stoped). 
    - removed clean_start (obsolete) 
    - check_sharedroot now knows of gfs and gfs2 
    - start: calling clusterfs_init and cc_init independently from root 
             filesystem and cluster type (different parameters) 
     - stop: calling clusterfs_init and cc_init independently from
             root filesystem and cluster type (different parameters)
* Tue Nov 29 2011 Marc Grimme <grimme ( at )atix.de> - 5.0-3
  * initscripts/bootsr: moved inclusion of /etc/init.d/functions and
    /etc/rc.status after inclusion of libs. Now all outputs should be seen at
    console.
* Fri Nov 25 2011 Marc Grimme <grimme( at )atix.de> - 5.0-2
  * initscripts/bootsr: - Added call to update the repository from initrd -
    Only remount cdsl environment if it is not only in /etc/mtab existant - other
    handling fixes with chrootneeded
* Tue Nov 01 2011 Marc Grimme <grimme( at )atix.de> - 5.0-1
  * Rebase for Release 5.0
* Wed Oct 26 2011 Marc Grimme <grimme( at )atix.de> - 1.4-4.rhel6
- added netfs and network initscript to be overwritten.
* Tue May 10 2011 Marc Grimme <grimme@atix.de> 1.4-3.rhel6
- introducing updated version to /sbin/new-kernel-pkg-update in order to allow autobuild of initrds 
  (requirement boot is mounted).
* Tue Mar 22 2011 Marc Grimme <grimme@atix.de> 1.4-2.rhel6
- Rebase
* Mon Feb 28 2011 Marc Grimme <grimme@atix.de> 1.4-1.rhel6
- halt.local will now be a file being installed instead of a symbolic link.
# ------
# $Log: comoonics-bootimage-initscripts-el5.spec,v $
