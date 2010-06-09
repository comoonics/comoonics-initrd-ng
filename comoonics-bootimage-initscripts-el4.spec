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

# $Id: comoonics-bootimage-initscripts-el4.spec,v 1.16 2010-06-09 08:23:22 marc Exp $
#
##
##

%define _user root
%define _sysconfdir /etc
%define CONFIGDIR /%{_sysconfdir}/comoonics
%define APPDIR    /opt/atix/%{name}
%define ENVDIR    /etc/profile.d
%define ENVFILE   %{ENVDIR}/%{name}.sh
%define INITDIR   /etc/rc.d/init.d
%define SYSCONFIGDIR /%{_sysconfdir}/sysconfig

Name: comoonics-bootimage-initscripts
Summary: Initscripts used by the OSR cluster environment.
Version: 1.4
BuildArch: noarch
Requires: comoonics-bootimage >= 1.4-36
Requires: SysVinit-comoonics
Requires: comoonics-bootimage-listfiles-all
Requires: comoonics-bootimage-listfiles-rhel
Requires: comoonics-bootimage-listfiles-rhel4
#Conflicts:
Release: 6.rhel4
Vendor: ATIX AG
Packager: ATIX AG <http://bugzilla.atix.de>
ExclusiveArch: noarch
URL:     http://www.atix.de/
Source:  http://www.atix.de/software/downloads/comoonics/comoonics-bootimage-initscripts-%{version}.tar.gz
License: GPL
Group:   System Environment/Base
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description
Initscripts used by the OSR cluster environment.


%prep
%setup -n comoonics-bootimage-%{version}

%build

%install
install -d -m 755 $RPM_BUILD_ROOT/%{INITDIR}
install -d -m 755 $RPM_BUILD_ROOT/%{SYSCONFIGDIR}
install -m755 initscripts/rhel4/bootsr $RPM_BUILD_ROOT/%{INITDIR}/bootsr
install -m755 initscripts/mountcdsls $RPM_BUILD_ROOT/%{INITDIR}/mountcdsls
install -m755 initscripts/rhel4/ccsd-chroot $RPM_BUILD_ROOT/%{INITDIR}/ccsd-chroot
install -m755 initscripts/rhel4/fenced-chroot $RPM_BUILD_ROOT/%{INITDIR}/fenced-chroot
install -m644 initscripts/rhel4/halt-overwrite.sh $RPM_BUILD_ROOT/%{SYSCONFIGDIR}/halt-overwrite

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
	/sbin/chkconfig --del ccsd-chroot
	/sbin/chkconfig --del fenced-chroot
    /sbin/chkconfig --add fenced &>/dev/null
    /sbin/chkconfig --list fenced
    /sbin/chkconfig --add ccsd &>/dev/null
    /sbin/chkconfig --list ccsd
  fi
fi

%post

echo "Starting postinstall.."
services="bootsr ccsd-chroot fenced-chroot mountcdsls"
echo "Resetting services ($services)"
for service in $services; do
   /sbin/chkconfig --del $service &>/dev/null
   /sbin/chkconfig --add $service
   /sbin/chkconfig $service on
   /sbin/chkconfig --list $service
done

services="ccsd fenced"
echo "Disabling services ($services)"
for service in $services; do
   /sbin/chkconfig --del $service &> /dev/null
done

echo "Creating link for halt.local"
if [ -e /sbin/halt.local ]; then
   echo "Could not create link /sbin/halt.local."
   echo "In order to be able to reboot properly with cluster filesystems it is important to link"
   echo "/opt/atix/comoonics-bootimage/boot-scripts/com-halt.sh /sbin/halt.local"
   echo "Please try to fix or validate manually"
else
   ln -sf  /opt/atix/comoonics-bootimage/boot-scripts/com-halt.sh /sbin/halt.local
fi

echo "Configuring halt-overwrite.."
grep "halt-overwrite" /etc/sysconfig/clock || echo ". /etc/sysconfig/halt-overwrite" >> /etc/sysconfig/clock

/bin/true

%preun
chkconfig --del bootsr
chkconfig --del mountcdsls

%files
%attr(755, root, root) %{INITDIR}/bootsr
%attr(755, root, root) %{INITDIR}/mountcdsls
%attr(755, root, root) %{INITDIR}/fenced-chroot
%attr(755, root, root) %{INITDIR}/ccsd-chroot
%attr(644, root, root) %{SYSCONFIGDIR}/halt-overwrite

%changelog
* Thu Jun 08 2010 Marc Grimme <grimme@atix.de> 1.4-6rhel4
- introducted initscript mountcdsls
* Tue Feb 16 2010 Marc Grimme <grimme@atix.de> 1.4-5rhel4
- introduced halt-overwrite to solve the halt_get_remaining problem and one patch less.
* Mon Feb 15 2010 Marc Grimme <grimme@atix.de> 1.4-4rhel4
- clean up check_sharedroot
* Fri Feb 12 2010 Marc Grimme <grimme@atix.de> 1.4-3rhel4
- fixed many bugs in bootsr and diet and upstream.
* Wed Feb 25 2009 Marc Grimme <grimme@atix.de> 1.4-1rhel4
- Backport of important features to rhel4
* Fri Feb 29 2008 Mark Hlawatschek <hlawatschek@atix.de> 1.3.5
- Fixed BZ 203, support FENCE_OPTS from /etc/sysconfig/cluster during boot
* Tue Dec 18 2007 Mark Hlawatschek <hlawatschek@atix.de> 1.3.4
- changed license to GPL
* Wed Nov 28 2007 Mark Hlawatschek <hlawatschek@atix.de> 1.3.3
- Fixed BZ 150
* Thu Oct 11 2007 Mark Hlawatschek <hlawatschek@atix.de> 1.3.2
- Fixed BZ 106
* Wed Sep 12 2007 Mark Hlawatschek <hlawatschek@atix.de> 1.3.1
- first revision
# ------
# $Log: comoonics-bootimage-initscripts-el4.spec,v $
# Revision 1.16  2010-06-09 08:23:22  marc
# new versions
#
# Revision 1.15  2010/02/21 12:08:14  marc
# added halt-overwrite to /etc/sysconfig.
#
# Revision 1.14  2010/02/16 10:07:15  marc
# new versions
#
# Revision 1.13  2010/02/07 20:35:13  marc
# - latest versions
#
# Revision 1.12  2009/02/25 14:25:16  marc
# backport of new features to rhel4
# new version 1.4-1
#
# Revision 1.11  2009/02/04 09:27:15  marc
# changed rpm names.
#
# Revision 1.10  2008/12/05 16:12:58  marc
# First step to go rpmlint compat BUG#230
#
# Revision 1.9  2008/12/01 14:46:24  marc
# changed file attributes (Bug #290)
#
# Revision 1.8  2008/02/29 09:10:41  mark
# increased release number ;-)
#
# Revision 1.7  2008/02/29 08:49:32  mark
# new release 1.3.5
#
# Revision 1.6  2007/12/07 16:39:59  reiner
# Added GPL license and changed ATIX GmbH to AG.
#
# Revision 1.5  2007/11/28 12:41:42  mark
# new release
#
# Revision 1.4  2007/10/11 08:47:50  mark
# new release
#
# Revision 1.3  2007/09/14 15:07:18  mark
# removed sensless comment
#
# Revision 1.2  2007/09/14 13:36:05  marc
# fixed cleaning up
#
# Revision 1.1  2007/09/13 08:35:22  mark
# initital check in
#
