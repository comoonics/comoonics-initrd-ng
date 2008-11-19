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

# $Id: comoonics-bootimage-initscripts-el4.spec,v 1.8 2008/02/29 09:10:41 mark Exp $
#
##
##

%define _user root
%define CONFIGDIR /%{_sysconfdir}/comoonics
%define APPDIR    /opt/atix/%{name}
%define ENVDIR    /etc/profile.d
%define ENVFILE   %{ENVDIR}/%{name}.sh
%define INITDIR   /etc/rc.d/init.d
%define SYSCONFIGDIR /%{_sysconfdir}/sysconfig

Name: comoonics-bootimage-initscripts
Summary: Comoonics Bootimage initscripts. Initscripts used by the comoonics shared root cluster environment for Novell SLES10.
Version: 1.3
BuildArch: noarch
Requires: comoonics-bootimage >= 1.3-1
Requires: comoonics-bootimage-listfiles-sles
#Conflicts:
Release: 2.sles10
Vendor: ATIX AG
Packager: Marc Grimme (grimme (at) atix.de)
ExclusiveArch: noarch
URL:     http://www.atix.de/
Source:  http://www.atix.de/software/downloads/comoonics/comoonics-bootimage-%{version}.tar.gz
License: GPL
Group:   Storage/Management
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description
Comoonics Bootimage initscripts. Initscripts used by the comoonics shared root cluster environment.
These are for Novell SLES10.


%prep
%setup -n comoonics-bootimage-%{version}

%build

%install
install -d -m 755 $RPM_BUILD_ROOT/%{INITDIR}
install -m755 initscripts/sles10/bootsr $RPM_BUILD_ROOT/%{INITDIR}/bootsr

%clean
rm -rf %{buildroot}

%postun

if [ "$1" -eq 0 ]; then
  echo "Postuninstalling comoonics-bootimage-initscripts"
  root_fstype=$(mount | grep "/ " | awk '
BEGIN { exit_c=1; }
{ if ($5) {  print $5; exit_c=0; } }
END{ exit exit_c}')
  if [ "$root_fstype" != "gfs" ]; then
	/sbin/chkconfig --del bootsr
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

services="o2cb"
echo "Disabling services ($services)"
for service in $services; do
   /sbin/chkconfig --del $service &> /dev/null
done
/bin/true


%files

%attr(750, root, root) %{INITDIR}/bootsr
%changelog
* Wed Nov 19 2008 Marc Grimme <grimme@atix.de> 1.3-2-sles10
- Merged with upstream
* Fri Sep 18 2008 Marc Grimme <grimme@atix.de> 1.3-1
- first revision
# ------
# $Log: comoonics-bootimage-initscripts-el4.spec,v $
