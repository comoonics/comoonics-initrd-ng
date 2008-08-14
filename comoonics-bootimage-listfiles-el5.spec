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

# $Id: comoonics-bootimage-listfiles-el5.spec,v 1.9 2008-08-14 14:41:08 marc Exp $
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

Name: comoonics-bootimage-listfiles
Summary: Comoonics Bootimage listfiles. Listfiles for mkinitrd used by the comoonics shared root cluster environment.
Version: 1.3
BuildArch: noarch
Requires: comoonics-bootimage >= 1.3-1
Requires: comoonics-bootimage-listfiles-rhel
Requires: comoonics-bootimage-listfiles-rhel5
#Conflicts:
Release: 8.el5
Vendor: ATIX AG
Packager: Mark Hlawatschek (hlawatschek (at) atix.de)
ExclusiveArch: noarch
URL:     http://www.atix.de/
Source:  http://www.atix.de/software/downloads/comoonics/comoonics-bootimage-%{version}.tar.gz
License: GPL
Group:   Storage/Management
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description
Comoonics Bootimage listfiles. Listfiles for mkinitrd used by the comoonics shared root cluster environment.

%prep
%setup -n comoonics-bootimage-%{version}

%build

%install
install -d -m 755 $RPM_BUILD_ROOT
#install -d -m 755 $RPM_BUILD_ROOT/%{CONFIGDIR}/bootimage
#install -m644 system-cfg-files/basefiles.list $RPM_BUILD_ROOT/%{CONFIGDIR}/bootimage/basefiles.list
#install -m644 system-cfg-files/rpms.list $RPM_BUILD_ROOT/%{CONFIGDIR}/bootimage/rpms.list
#install -d -m 755 $RPM_BUILD_ROOT/%{CONFIGDIR}/bootimage/files.initrd.d
#install -d -m 755 $RPM_BUILD_ROOT/%{CONFIGDIR}/bootimage/rpms.initrd.d
#install -m644 system-cfg-files/files.initrd.d/base.list $RPM_BUILD_ROOT/%{CONFIGDIR}/bootimage/files.initrd.d/base.list
#install -m644 system-cfg-files/files.initrd.d/bonding.list $RPM_BUILD_ROOT/%{CONFIGDIR}/bootimage/files.initrd.d/bonding.list
#install -m644 system-cfg-files/files.initrd.d/comoonics.list $RPM_BUILD_ROOT/%{CONFIGDIR}/bootimage/files.initrd.d/comoonics.list
#install -m644 system-cfg-files/files.initrd.d/configs.list $RPM_BUILD_ROOT/%{CONFIGDIR}/bootimage/files.initrd.d/configs.list
#install -m644 system-cfg-files/files.initrd.d/ext2.list $RPM_BUILD_ROOT/%{CONFIGDIR}/bootimage/files.initrd.d/ext2.list
#install -m644 system-cfg-files/files.initrd.d/gfs.list $RPM_BUILD_ROOT/%{CONFIGDIR}/bootimage/files.initrd.d/gfs.list
#install -m644 system-cfg-files/files.initrd.d/grub.list $RPM_BUILD_ROOT/%{CONFIGDIR}/bootimage/files.initrd.d/grub.list
#install -m644 system-cfg-files/files.initrd.d/locales.list $RPM_BUILD_ROOT/%{CONFIGDIR}/bootimage/files.initrd.d/locales.list
#install -m644 system-cfg-files/files.initrd.d/network.list $RPM_BUILD_ROOT/%{CONFIGDIR}/bootimage/files.initrd.d/network.list
#install -m644 system-cfg-files/files.initrd.d/rhcs5.list $RPM_BUILD_ROOT/%{CONFIGDIR}/bootimage/files.initrd.d/rhcs5.list
#install -m644 system-cfg-files/files.initrd.d/scsi.list $RPM_BUILD_ROOT/%{CONFIGDIR}/bootimage/files.initrd.d/scsi.list
#install -m644 system-cfg-files/rpms.initrd.d/baselibs.list $RPM_BUILD_ROOT/%{CONFIGDIR}/bootimage/rpms.initrd.d/baselibs.list
#install -m644 system-cfg-files/rpms.initrd.d/comoonics.list $RPM_BUILD_ROOT/%{CONFIGDIR}/bootimage/rpms.initrd.d/comoonics.list
#install -m644 system-cfg-files/rpms.initrd.d/ext2.list $RPM_BUILD_ROOT/%{CONFIGDIR}/bootimage/rpms.initrd.d/ext2.list
#install -m644 system-cfg-files/rpms.initrd.d/gfs1-el5.list $RPM_BUILD_ROOT/%{CONFIGDIR}/bootimage/rpms.initrd.d/gfs1-el5.list
#install -m644 system-cfg-files/rpms.initrd.d/hardware.list $RPM_BUILD_ROOT/%{CONFIGDIR}/bootimage/rpms.initrd.d/hardware.list
#install -m644 system-cfg-files/rpms.initrd.d/python.list $RPM_BUILD_ROOT/%{CONFIGDIR}/bootimage/rpms.initrd.d/python.list
#install -m644 system-cfg-files/rpms.initrd.d/rhcs5.list $RPM_BUILD_ROOT/%{CONFIGDIR}/bootimage/rpms.initrd.d/rhcs5.list

%postun

%post

%files
#%attr(640, root, root) %{CONFIGDIR}/bootimage/basefiles.list
#%attr(640, root, root) %{CONFIGDIR}/bootimage/rpms.list
#%attr(640, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/base.list
#%attr(640, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/bonding.list
#%attr(640, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/comoonics.list
#%attr(640, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/configs.list
#%attr(640, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/ext2.list
#%attr(640, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/gfs.list
#%attr(640, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/grub.list
#%attr(640, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/locales.list
#%attr(640, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/network.list
#%attr(640, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/rhcs5.list
#%attr(640, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/scsi.list
#%attr(640, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/baselibs.list
#%attr(640, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/comoonics.list
#%attr(640, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/ext2.list
#%attr(640, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/gfs1-el5.list
#%attr(640, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/hardware.list
#%attr(640, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/python.list
#%attr(640, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/rhcs5.list
#%attr(640, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel5-base.list

%clean
rm -rf %{buildroot}

%changelog
* Wed Aug 06 2008 Marc Grimme <grimme@atix.de> 1.3-8
- removed all files
- obsolete rpm is replaced with comoonics-bootimage-listfiles-rhel and comoonics-bootimage-listfiles-rhel5
* Wed Nov 28 2007 Mark Hlawatschek <hlawatschek@atix.de> 1.3-6
- fixes bz#149
* Fri Oct 12 2007 Marc Grimme <grimme@atix.de> 1.3-5
- added coreutils and procps to base
* Fri Sep 14 2007 Mark Hlawatschek <hlawatschek@atix.de> 1.3.1
- first revision
# ------
# $Log: comoonics-bootimage-listfiles-el5.spec,v $
# Revision 1.9  2008-08-14 14:41:08  marc
# removed listfiles
#
# Revision 1.8  2007/12/07 16:39:59  reiner
# Added GPL license and changed ATIX GmbH to AG.
#
# Revision 1.7  2007/11/28 12:41:42  mark
# new release
#
# Revision 1.6  2007/10/16 09:13:36  marc
# - added iscsi-support
#
# Revision 1.5  2007/10/05 14:52:19  mark
# new release
#
# Revision 1.4  2007/09/26 11:55:51  mark
# new releases
#
# Revision 1.3  2007/09/17 09:37:40  mark
# new release
#
# Revision 1.2  2007/09/17 09:36:20  mark
# fixed typo that prevented pyhton to be installed
#
# Revision 1.1  2007/09/15 14:49:38  mark
# moved listfiles into extra rpms
#
