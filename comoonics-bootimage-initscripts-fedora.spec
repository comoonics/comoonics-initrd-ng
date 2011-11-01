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
%define SBINDIR   /sbin
%define ENVDIR    /etc/profile.d
%define ENVFILE   %{ENVDIR}/%{name}.sh
%define INITDIR   /etc/rc.d/init.d
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
Summary: Initscripts used by the OSR cluster environment.
Version: 1.4
BuildArch: noarch
Requires: comoonics-bootimage >= 1.4-82
# Requires: SysVinit-comoonics
Requires: comoonics-bootimage-listfiles-all
Requires: comoonics-bootimage-listfiles-fedora
#Conflicts: 
Release: 19.fedora
Vendor: ATIX AG
Packager: ATIX AG <http://bugzilla.atix.de>
ExclusiveArch: noarch
URL:     http://www.atix.de/
Source:  http://www.atix.de/software/downloads/comoonics/comoonics-bootimage-initscripts-%{version}.tar.gz
License: GPL
Group:   %{GROUPPARENT}/%{GROUPCHILDBASE}/%{GROUPCHILDFEDORA}
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
install -m600 initscripts/fedora/halt-xtab.patch $RPM_BUILD_ROOT/%{APPDIR}/patches/halt-xtab.patch
#install -m600 initscripts/fedora/halt-local.patch $RPM_BUILD_ROOT/%{APPDIR}/patches/halt-local.patch
install -m600 initscripts/fedora/halt-killall.patch $RPM_BUILD_ROOT/%{APPDIR}/patches/halt-killall.patch
install -m600 initscripts/fedora/halt-comoonics.patch $RPM_BUILD_ROOT/%{APPDIR}/patches/halt-comoonics.patch
install -m600 initscripts/fedora/netfs-xtab.patch $RPM_BUILD_ROOT/%{APPDIR}/patches/netfs-xtab.patch
install -m600 initscripts/fedora/netfs-comoonics.patch $RPM_BUILD_ROOT/%{APPDIR}/patches/netfs-comoonics.patch
install -m600 initscripts/fedora/network-xrootfs.patch $RPM_BUILD_ROOT/%{APPDIR}/patches/network-xrootfs.patch
install -m600 initscripts/fedora/network-comoonics.patch $RPM_BUILD_ROOT/%{APPDIR}/patches/network-comoonics.patch
#install -m600 initscripts/fedora/halt.orig $RPM_BUILD_ROOT/%{APPDIR}/patches/halt.orig
install -m600 initscripts/fedora/network.orig $RPM_BUILD_ROOT/%{APPDIR}/patches/network.orig
install -m600 initscripts/fedora/netfs.orig $RPM_BUILD_ROOT/%{APPDIR}/patches/netfs.orig
install -d $RPM_BUILD_ROOT/%{SBINDIR}
#install -m755 initscripts/fedora/halt.local $RPM_BUILD_ROOT/%{SBINDIR}/halt.local
install -m755 initscripts/halt.local $RPM_BUILD_ROOT/%{SBINDIR}/halt.local

#%preun
#if [ "$1" -eq 0 ]; then
#  echo "Preuninstalling comoonics-bootimage-initscripts"
#  /sbin/chkconfig --del bootsr
#  # we patch all versions here
#  for initscript in halt network netfs; do
#	if grep "comoonics patch " /etc/init.d/$initscript > /dev/null; then
#		# the old way
#		if [ -e /opt/atix/comoonics-bootimage/patches/${initscript}.patch ]; then
#		   patchfile="/opt/atix/comoonics-bootimage/patches/${initscript}.patch"
#		   echo -n "Unpatching initscript($patchfile)"
#		   cd /etc/init.d/ && patch -R -f -r /tmp/$(basename ${patchfile}).patch.rej > /dev/null < $patchfile
#		   if [ $? -ne 0 ]; then
#		      echo >&2
#		      echo >&2
#		      echo "FAILURE!!!!" >&2
#		      echo "Patching $initscript with patch $patchfile" >&2
#		      echo "You might want to consider restoring the original initscript and the patch again by:" >&2
#		      echo "cp /opt/atix/comoonics-bootimage/patches/${initscript}.orig /etc/init.d/${initscript}"
#		      echo "/opt/atix/comoonics-bootimage/manage_chroot.sh -a patch_files ${initscript}"
#		      echo >&2
#		   fi
#		   echo
#		else
#		   echo -n "Unpatching $initscript ("
#		   for patchfile in $(ls -1 /opt/atix/comoonics-bootimage/patches/${initscript}-*.patch | sort -r); do
#			  echo -n $(basename $patchfile)", "
#			  cd /etc/init.d/ && patch -R -f -r /tmp/$(basename ${patchfile}).patch.rej > /dev/null < $patchfile
#		      if [ $? -ne 0 ]; then
#		      echo >&2
#		      echo >&2
#		      echo "FAILURE!!!!" >&2
#		      echo "Patching $initscript with patch $patchfile" >&2
#		      echo "You might want to consider restoring the original initscript and the patch again by:" >&2
#		      echo "cp /opt/atix/comoonics-bootimage/patches/${initscript}.orig /etc/init.d/${initscript}"
#		      echo "/opt/atix/comoonics-bootimage/manage_chroot.sh -a patch_files ${initscript}"
#		      echo >&2
#		      fi
#		   done
#		   echo ")"
#		fi
#	fi
#  done
#fi


#%pre

#if this is an upgrade we need to unpatch all files
#if [ "$1" -eq 2 ]; then
#  # we patch all versions here
#  for initscript in halt network netfs; do
#	if grep "comoonics patch " /etc/init.d/$initscript > /dev/null; then
#		# the old way
#		if [ -e /opt/atix/comoonics-bootimage/patches/${initscript}.patch ]; then
#		   patchfile="/opt/atix/comoonics-bootimage/patches/${initscript}.patch"
#		   echo -n "Unpatching initscript($patchfile)"
#		   cd /etc/init.d/ && patch -R -f -r /tmp/$(basename ${patchfile}).patch.rej > /dev/null < $patchfile
#		   if [ $? -ne 0 ]; then
#		      echo >&2
#		      echo >&2
#		      echo "FAILURE!!!!" >&2
#		      echo "Patching $initscript with patch $patchfile" >&2
#		      echo "You might want to consider restoring the original initscript and the patch again by:" >&2
#		      echo "cp /opt/atix/comoonics-bootimage/patches/${initscript}.orig /etc/init.d/${initscript}"
#		      echo "/opt/atix/comoonics-bootimage/manage_chroot.sh -a patch_files ${initscript}"
#		      echo >&2
#		   fi
#		   echo
#		else
#		   echo -n "Unpatching $initscript ("
#		   for patchfile in $(ls -1 /opt/atix/comoonics-bootimage/patches/${initscript}-*.patch | sort -r); do
#			  echo -n $(basename $patchfile)", "
#			  cd /etc/init.d/ && patch -R -f -r /tmp/$(basename ${patchfile}).patch.rej > /dev/null < $patchfile
#		      if [ $? -ne 0 ]; then
#		      echo >&2
#		      echo >&2
#		      echo "FAILURE!!!!" >&2
#		      echo "Patching $initscript with patch $patchfile" >&2
#		      echo "You might want to consider restoring the original initscript and the patch again by:" >&2
#		      echo "cp /opt/atix/comoonics-bootimage/patches/${initscript}.orig /etc/init.d/${initscript}"
#		      echo "/opt/atix/comoonics-bootimage/manage_chroot.sh -a patch_files ${initscript}"
#		      echo >&2
#		      fi
#		   done
#		   echo ")"
#		fi
#	fi
#  done
#fi 

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

/bin/true

%postun
if [ -L %{SBINDIR}/halt.local ]; then
   rm %{SBINDIR}/halt.local
fi

%files

%attr(755, root, root) %{INITDIR}/bootsr
%attr(755, root, root) %{INITDIR}/mountcdsls
%attr(644, root, root) %{APPDIR}/patches/halt-comoonics.patch
%attr(644, root, root) %{APPDIR}/patches/halt-killall.patch
#%attr(644, root, root) %{APPDIR}/patches/halt-local.patch
%attr(644, root, root) %{APPDIR}/patches/halt-xtab.patch
%attr(644, root, root) %{APPDIR}/patches/netfs-comoonics.patch
%attr(644, root, root) %{APPDIR}/patches/netfs-xtab.patch
%attr(644, root, root) %{APPDIR}/patches/network-comoonics.patch
%attr(644, root, root) %{APPDIR}/patches/network-xrootfs.patch
#%attr(755, root, root) %{APPDIR}/patches/halt.orig
%attr(755, root, root) %{APPDIR}/patches/network.orig
%attr(755, root, root) %{APPDIR}/patches/netfs.orig
%attr(755, root, root) %{SBINDIR}/halt.local

%clean
rm -rf %{buildroot}

%changelog
* Tue Oct 25 2011 Marc Grimme <grimme( at )atix.de> 1.4-19.fedora
- take bootsr from upstream.
* Tue Mar 22 2011 Marc Grimme <grimme@atix.de> 1.4-18.fedora
- Rebase
* Mon Feb 28 2011 Marc Grimme <grimme@atix.de> 1.4-17.fedora
- halt.local will now be a file being installed instead of a symbolic link.
* Tue Feb 22 2011 Marc Grimme <grimme@atix.de> 1.4-16fedora
- initscripts/rhel4,rhel5,fedora,sles10,sles11/bootsr
  - would work without cdsl tools being available
* Wed Aug 18 2010 Marc Grimme <grimme@atix.de> 1.4-15fedora
- initscripts/rhel4,rhel5,fedora,sles10,sles11/bootsr
  - fixed bug #382 where the cdsl.local was not remounted in /etc/mtab on locally installed systems
* Thu Jul 08 2010 Marc Grimme <grimme@atix.de> 1.4-14fedora
- bootsr uses bash as shell
* Thu Jun 08 2010 Marc Grimme <grimme@atix.de> 1.4-13fedora
- introduced mountcdsls
* Fri Oct 09 2009 Marc Grimme <grimme@atix.de> 1.4-12fedora
- removed halt patches as the are not needed with /sbin/halt.local
* Tue Jul 07 2009 Marc Grimme <grimme@atix.de> 1.4-11fedora
- Removed the patches to be applied automatically
* Mon Apr 20 2009 Marc Grimme <grimme@atix.de> 1.4-10fedora
- RC1
* Tue Apr 16 2009 Marc Grimme <grimme@atix.de> 1.4-9.fedora
- Syncronized bootsr and fixed calling of _init
* Wed Apr 15 2009 Marc Grimme <grimme@atix.de> 1.4-8.fedora
- Backport of bugfixes from rhel5
* Tue Apr 14 2009 Marc Grimme <grimme@atix.de> 1.4-7.fedora
- Multipatches and rework on building of chroot
* Wed Apr 08 2009 Marc Grimme <grimme@atix.de> 1.4-4.fedora
- First final of multi-patches and halt.local
* Mon Apr 06 2009 Marc Grimme <grimme@atix.de> 1.4-3.fedora
- New patch concept (only small patches)
* Tue Feb 27 2009 Marc Grimme <grimme@atix.de> 1.4-2.fedora
- Upstream from RHEL5
* Mon Feb 02 2009 Marc Grimme <grimme@atix.de> 1.3-3.fedora
- Bugfix in support for other filesystems
* Tue Jan 29 2009  Marc Grimme <grimme@atix.de> 1.3.2-fedora
- first revision
# ------
# $Log: comoonics-bootimage-initscripts-el5.spec,v $
