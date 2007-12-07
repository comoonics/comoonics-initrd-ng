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

# $Id: comoonics-bootimage-initscripts-el5.spec,v 1.6 2007-12-07 16:39:59 reiner Exp $
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
Requires: comoonics-bootimage >= 1.3-1 SysVinit-comoonics
#Conflicts: 
Release: 5.el5
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

%preun

if [ "$1" -eq 0 ]; then
  echo "Preuninstalling comoonics-bootimage-initscripts"
  root_fstype=$(mount | grep "/ " | awk '
BEGIN { exit_c=1; }
{ if ($5) {  print $5; exit_c=0; } }
END{ exit exit_c}')
  if [ "$root_fstype" != "gfs" ]; then
	/sbin/chkconfig --del bootsr
	if grep "comoonics patch " /etc/init.d/halt > /dev/null; then
		echo "Unpatching halt"
		cd /etc/init.d/ && patch -R -f -r /tmp/halt.patch.rej > /dev/null < /opt/atix/comoonics-bootimage/patches/halt.patch
	fi
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
/bin/true


%files

%attr(750, root, root) %{INITDIR}/bootsr
%attr(600, root, root) %{APPDIR}/patches/halt.patch

%clean
rm -rf %{buildroot}

%changelog
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
# Revision 1.6  2007-12-07 16:39:59  reiner
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
