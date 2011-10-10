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
%define LIBDIR    /opt/atix/%{name}
%define ENVDIR    /etc/profile.d
%define ENVFILE   %{ENVDIR}/%{name}.sh
%define INITDIR   /etc/init.d
%define SYSCONFIGDIR /%{_sysconfdir}/sysconfig

%define RELEASENAME Gumpn
%define PRODUCTNAME OpenSharedRoot
%define PRODUCTVERSION 5.0 pre
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
Summary: Initscripts used by the OSR cluster environment for Novell SLES10.
Version: 1.4
BuildArch: noarch
Requires: comoonics-bootimage >= 1.4-82
Requires: comoonics-bootimage-listfiles-sles10
#Conflicts:
Release: 13.sles10
Vendor: ATIX AG
Packager: ATIX AG <http://bugzilla.atix.de>
ExclusiveArch: noarch
URL:     http://www.atix.de/
Source:  http://www.atix.de/software/downloads/comoonics/comoonics-bootimage-initscripts-%{version}.tar.gz
License: GPL
Group:   %{GROUPPARENT}/%{GROUPCHILDBASE}/%{GROUPCHILDSLES10}
Distribution: %{DISTRIBUTIONBASE}
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description
Initscripts used by the OSR cluster environment. These are for Novell SLES10.


%prep
%setup -n comoonics-bootimage-%{version}

%build

%install
install -d -m 755 $RPM_BUILD_ROOT/%{INITDIR}
install -m755 initscripts/sles10/bootsr $RPM_BUILD_ROOT/%{INITDIR}/bootsr
install -m755 initscripts/mountcdsls $RPM_BUILD_ROOT/%{INITDIR}/mountcdsls
install -m755 initscripts/halt.local $RPM_BUILD_ROOT/%{INITDIR}/halt.local

%clean
rm -rf %{buildroot}

%postun
if [ -L %{INITDIR}/halt.local ]; then
   rm %{INITDIR}/halt.local
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

services="o2cb"
echo "Disabling services ($services)"
for service in $services; do
   /sbin/chkconfig --del $service &> /dev/null
   /sbin/chkconfig $service off &> /dev/null
done

cat << EOF

EOF
/bin/true

%preun
true

%files
%attr(755, root, root) %{INITDIR}/bootsr
%attr(755, root, root) %{INITDIR}/mountcdsls
%attr(755, root, root) %{INITDIR}/halt.local

%changelog
* Fri Aug 05 2011 Marc Grimme <grimme@atix.de> 1.4-13.sles10
- removed dep to SysVInit-comooics (will be found if the filesystem 
  - comoonics-bootimage-listfiles-<dist>-<filesystem> - rpm).
* Tue Mar 22 2011 Marc Grimme <grimme@atix.de> 1.4-12.sles10
- Rebase
* Mon Feb 28 2011 Marc Grimme <grimme@atix.de> 1.4-11.sles10
- halt.local will now be a file being installed instead of a symbolic link.
* Tue Feb 22 2011 Marc Grimme <grimme@atix.de> 1.4-10sles10
- initscripts/rhel4,rhel5,fedora,sles10,sles11/bootsr
  - would work without cdsl tools being available
* Wed Aug 18 2010 Marc Grimme <grimme@atix.de> 1.4-9sles10
- initscripts/rhel4,rhel5,fedora,sles10,sles11/bootsr
  - fixed bug #382 where the cdsl.local was not remounted in /etc/mtab on locally installed systems
* Thu Jul 08 2010 Marc Grimme <grimme@atix.de> 1.4-8.sles10
- bootsr uses bash as shell
* Thu Jun 08 2010 Marc Grimme <grimme@atix.de> 1.4-7.sles10
- introduced mountcdsls
* Tue Feb 23 2010 Marc Grimme <grimme@atix.de> 1.4-6.sles10
- Backported bootsr from RHEL5
* Tue Feb 23 2010 Marc Grimme <grimme@atix.de> 1.4-5.sles10
- Backported bootsr from RHEL5
* Mon Sep 28 2009 Marc Grimme <grimme@atix.de> 1.4-4.sles10
- Finalized new version
- added /etc/init.d/halt.local link instead of using boot.localfs
* Tue Sep 15 2009 Marc Grimme <grimme@atix.de> 1.4-3.sles10
- Made dependent on listfiles-sles10
- Changed initscript bootsr to be sles compatible
* Wed Nov 19 2008 Marc Grimme <grimme@atix.de> 1.3-2-sles10
- Merged with upstream
* Fri Sep 18 2008 Marc Grimme <grimme@atix.de> 1.3-1
- first revision
# ------
# $Log: comoonics-bootimage-initscripts-el4.spec,v $
