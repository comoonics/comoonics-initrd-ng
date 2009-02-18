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

# $Id: comoonics-bootimage-initscripts-el5.spec,v 1.14 2008/12/05 16:12:58 marc Exp $
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
Summary: Initscripts used by the OSR cluster environment.
Version: 1.4
BuildArch: noarch
Requires: comoonics-bootimage >= 1.3-41 
# Requires: SysVinit-comoonics
Requires: comoonics-bootimage-listfiles-all
Requires: comoonics-bootimage-listfiles-fedora
#Conflicts: 
Release: 1.fedora
Vendor: ATIX AG
Packager: ATIX AG <http://bugzilla.atix.de>
ExclusiveArch: noarch
URL:     http://www.atix.de/
Source:  http://www.atix.de/software/downloads/comoonics/comoonics-bootimage-%{version}.tar.gz
License: GPL
Group:   System Environment/Base
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description
Initscripts used by the OSR cluster environment.
 

%prep
%setup -n comoonics-bootimage-%{version}

%build

%install
# Files for compat
install -d -m 755 $RPM_BUILD_ROOT/%{INITDIR}
install -m755 initscripts/fedora/bootsr $RPM_BUILD_ROOT/%{INITDIR}/bootsr
install -d -m 755 $RPM_BUILD_ROOT/%{APPDIR}/patches
install -m600 initscripts/fedora/halt.fedora.patch $RPM_BUILD_ROOT/%{APPDIR}/patches/halt.patch
install -m600 initscripts/fedora/netfs.patch $RPM_BUILD_ROOT/%{APPDIR}/patches/netfs.patch
install -m600 initscripts/fedora/network.patch $RPM_BUILD_ROOT/%{APPDIR}/patches/network.patch

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
	true
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
	true
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

%attr(755, root, root) %{INITDIR}/bootsr
%attr(644, root, root) %{APPDIR}/patches/halt.patch
%attr(644, root, root) %{APPDIR}/patches/netfs.patch
%attr(644, root, root) %{APPDIR}/patches/network.patch

%clean
rm -rf %{buildroot}

%changelog
* Mon Feb 02 2009 Marc Grimme <grimme@atix.de> 1.3-3.fedora
- Bugfix in support for other filesystems
* Tue Jan 29 2009  Marc Grimme <grimme@atix.de> 1.3.2-fedora
- first revision
# ------
# $Log: comoonics-bootimage-initscripts-el5.spec,v $
