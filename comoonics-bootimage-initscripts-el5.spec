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

# $Id: comoonics-bootimage-initscripts-el5.spec,v 1.11 2008-10-14 10:57:07 marc Exp $
#
##
##

%define _user root
%define CONFIGDIR /%{_sysconfdir}/comoonics
%define APPDIR    /opt/atix/comoonics-bootimage
%define ENVDIR    /etc/profile.d
%define ENVFILE   %{ENVDIR}/%{name}.sh
%define INITDIR   /etc/rc.d/init.d
%define SYSCONFIGDIR /%{_sysconfdir}/sysconfig

Name: comoonics-bootimage-initscripts
Summary: Comoonics Bootimage initscripts. Initscripts used by the comoonics shared root cluster environment.
Version: 1.3
BuildArch: noarch
Requires: comoonics-bootimage >= 1.3-1 
Requires: SysVinit-comoonics
Requires: comoonics-bootimage-listfiles-all
Requires: comoonics-bootimage-listfiles-rhel
Requires: comoonics-bootimage-listfiles-rhel5
#Conflicts: 
Release: 9.el5
Vendor: ATIX AG
Packager: Mark Hlawatschek (hlawatschek (at) atix.de)
ExclusiveArch: noarch
URL:     http://www.atix.de/
Source:  http://www.atix.de/software/downloads/comoonics/comoonics-bootimage-%{version}.tar.gz
License: GPL
Group:   Storage/Management
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description
Comoonics Bootimage initscripts. Initscripts used by the comoonics shared root cluster environment.
 

%prep
%setup -n comoonics-bootimage-%{version}

%build

%install
# Files for compat
install -d -m 755 $RPM_BUILD_ROOT/%{INITDIR}
install -m755 initscripts/rhel5/bootsr $RPM_BUILD_ROOT/%{INITDIR}/bootsr
install -d -m 755 $RPM_BUILD_ROOT/%{APPDIR}/patches
install -m600 initscripts/rhel5/halt.el5.patch $RPM_BUILD_ROOT/%{APPDIR}/patches/halt.patch
install -m600 initscripts/rhel5/netfs.patch $RPM_BUILD_ROOT/%{APPDIR}/patches/netfs.patch
install -m600 initscripts/rhel5/network.patch $RPM_BUILD_ROOT/%{APPDIR}/patches/network.patch

%preun

if [ "$1" -eq 0 ]; then
  echo "Preuninstalling comoonics-bootimage-initscripts"
# root_fstype=$(awk '{ if ($1 !~ /^rootfs/ && $1 !~ /^[ \t]*#/ && $2 == "/") { print $3; }}' /etc/mtab)
	/sbin/chkconfig --del bootsr
	if grep "comoonics patch " /etc/init.d/halt > /dev/null; then
		echo "Unpatching halt"
		cd /etc/init.d/ && patch -R -f -r /tmp/halt.patch.rej > /dev/null < /opt/atix/comoonics-bootimage/patches/halt.patch
	fi
	if grep "comoonics patch " /etc/init.d/netfs > /dev/null; then
		echo "Unpatching netfs"
		cd /etc/init.d/ && patch -R -f -r /tmp/netfs.patch.rej > /dev/null < /opt/atix/comoonics-bootimage/patches/netfs.patch
	fi
	if grep "comoonics patch " /etc/init.d/network > /dev/null; then
		echo "Unpatching network"
		cd /etc/init.d/ && patch -R -f -r /tmp/network.patch.rej > /dev/null < /opt/atix/comoonics-bootimage/patches/network.patch
	fi
fi


%pre

#if this is an upgrade we need to unpatch all files
if [ "$1" -eq 2 ]; then
	if grep "comoonics patch " /etc/init.d/halt > /dev/null; then
		echo "Unpatching halt"
		cd /etc/init.d/ && patch -R -f -r /tmp/halt.patch.rej > /dev/null < /opt/atix/comoonics-bootimage/patches/halt.patch
	fi
	if grep "comoonics patch " /etc/init.d/netfs > /dev/null; then
		echo "Unpatching netfs"
		cd /etc/init.d/ && patch -R -f -r /tmp/netfs.patch.rej > /dev/null < /opt/atix/comoonics-bootimage/patches/netfs.patch
	fi
	if grep "comoonics patch " /etc/init.d/network > /dev/null; then
		echo "Unpatching network"
		cd /etc/init.d/ && patch -R -f -r /tmp/network.patch.rej > /dev/null < /opt/atix/comoonics-bootimage/patches/network.patch
	fi
fi 

%post

echo "Starting postinstall.."
services="bootsr"
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
/etc/init.d/bootsr patch_files

/bin/true


%files

%attr(750, root, root) %{INITDIR}/bootsr
%attr(600, root, root) %{APPDIR}/patches/halt.patch
%attr(600, root, root) %{APPDIR}/patches/netfs.patch
%attr(600, root, root) %{APPDIR}/patches/network.patch

%clean
rm -rf %{buildroot}

%changelog
* Tue Oct 14 2008 Marc Grimme <grimme@atix.de> 1.3-9
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
# Revision 1.11  2008-10-14 10:57:07  marc
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
