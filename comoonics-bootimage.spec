# @(#)$File:$
#
# Copyright (c) 2001 ATIX GmbH.
# Einsteinstrasse 10, 85716 Unterschleissheim, Germany
# All rights reserved.
#
# This software is the confidential and proprietary information of ATIX
# GmbH. ("Confidential Information").  You shall not
# disclose such Confidential Information and shall use it only in
# accordance with the terms of the license agreement you entered into
# with ATIX.
#
# %define _initrddir /etc/init.d
# $Id: comoonics-bootimage.spec,v 1.1 2005-01-03 08:33:17 marc Exp $
%define _user root
%define         CONFIGDIR       /%{_sysconfdir}/comoonics
%define         APPDIR       /opt/atix/comoonics_bootimage


Name: comoonics-bootimage
Summary: Comoonics Bootimage. Scripts for creating an initrd in a gfs shared root environment
Version: 0.1
Release: 16
Vendor: ATIX GmbH
Packager: Marc Grimme (grimme@atix.de)
ExclusiveArch: noarch
URL:     http://www.atix.de/
Source:  http://www.atix.de/software/downloads/comoonics/comoonics-bootimage-%{version}.tar.gz
License: GPL
Group:   Storage/Management
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description
Comoonics Bootimage. Scripts for creating an initrd in a gfs shared root environment

%prep
%setup -q

%build

%install
make PREFIX=$RPM_BUILD_ROOT install

%post
echo "Starting postinstall.."
if ! $(grep '%{APPDIR}' /etc/profile.d/atix.sh > /dev/null 2>&1); then
    echo "Patching path.."
    echo 'PATH=%{APPDIR}:${PATH}' >> /etc/profile.d/atix.sh
fi
echo "Creating mkinitrd link..."
ln -sf %{APPDIR}/create-gfs-initrd-generic.sh %{APPDIR}/mkinitrd

echo "Analysing config files..."
cfg_files=gfs6-es30-files.i686.list
for cfg_file in $cfg_files; do
  if ! $(grep "%{APPDIR}/boot-scripts" /etc/comoonics/bootimage/$cfg_file >/dev/null 2>&1); then
    (echo "# START: RPM-post install added "$(date); echo "@map %{APPDIR}/boot-scripts /"; echo "# END:RPM-post install added ") >> /etc/comoonics/bootimage/$cfg_file
  else
    echo "Please verify that there is at least a line in your config file /etc/comoonics/bootimage/$cfg_file of the following type:"
    echo "@map %{APPDIR}/boot-scripts /"
  fi
done
if [ ! -e /etc/comoonics/bootimage/files-$(uname -r).list ]; then
  ln -s /etc/comoonics/bootimage/gfs6-es30-files.i686.list /etc/comoonics/bootimage/files-$(uname -r).list
fi
echo "Creating linuxrc link.."
cd %{APPDIR}/boot-scripts/ && ln -sf linuxrc.generic.sh linuxrc
%preun

%changelog

* Mon Jan  3 2005 Marc Grimme <grimme@atix.de> - 0.1-16
- first offical rpm version

%files
%dir %{APPDIR}/boot-scripts/mnt
%dir %{APPDIR}/boot-scripts/cdrom
%dir %{APPDIR}/boot-scripts/var/log
%dir %{APPDIR}/boot-scripts/var/lib/dhcp
%dir %{APPDIR}/boot-scripts/var/run/netreport
%dir %{APPDIR}/boot-scripts/proc
%attr(750, root, root) %{APPDIR}/create-gfs-initrd-generic.sh
%attr(750, root, root) %{APPDIR}/boot-scripts/linuxrc.generic.sh
%attr(750, root, root) %{APPDIR}/boot-scripts/exec_part_from_bash.sh
%attr(750, root, root) %{APPDIR}/boot-scripts/detectHardware.sh
%attr(750, root, root) %{APPDIR}/boot-scripts/rescue.sh
%attr(750, root, root) %{APPDIR}/boot-scripts/myifup.sh
%attr(750, root, root) %{APPDIR}/boot-scripts/linuxrc.bash
%attr(640, root, root) %{APPDIR}/boot-scripts/usr/share/hwdata/pci.ids
%attr(640, root, root) %{APPDIR}/boot-scripts/usr/share/hwdata/MonitorsDB
%attr(640, root, root) %{APPDIR}/boot-scripts/usr/share/hwdata/upgradelist
%attr(640, root, root) %{APPDIR}/boot-scripts/usr/share/hwdata/Cards
%attr(640, root, root) %{APPDIR}/boot-scripts/usr/share/hwdata/pcitable
%attr(640, root, root) %{APPDIR}/boot-scripts/usr/share/hwdata/usb.ids
%attr(640, root, root) %{APPDIR}/boot-scripts/usr/share/hwdata/CardMonitorCombos
%attr(640, root, root) %{APPDIR}/create-gfs-initrd-lib.sh 
%attr(640, root, root) %{APPDIR}/boot-scripts/etc/atix.txt
%attr(640, root, root) %{APPDIR}/boot-scripts/etc/modules.conf
%attr(640, root, root) %{APPDIR}/boot-scripts/etc/boot-lib.sh
%attr(640, root, root) %{APPDIR}/boot-scripts/etc/gfs-lib.sh
%attr(640, root, root) %{APPDIR}/boot-scripts/etc/comoonics-release
%attr(640, root, root) %{APPDIR}/boot-scripts/etc/iscsi-lib.sh
%attr(640, root, root) %{APPDIR}/boot-scripts/etc/lock_gulmd_mv_files.list
%attr(640, root, root) %{APPDIR}/boot-scripts/etc/lock_gulmd_cp_files.list
%attr(640, root, root) %{APPDIR}/boot-scripts/etc/lock_gulmd_dirs.list
%attr(640, root, root) %{APPDIR}/boot-scripts/etc/sysconfig/comoonics
%attr(640, root, root) %{APPDIR}/boot-scripts/linuxrc.part.bash.sh
%attr(640, root, root) %{APPDIR}/boot-scripts/linuxrc.part.gfs.sh
%attr(640, root, root) %{APPDIR}/boot-scripts/linuxrc.part.livecd.sh
%attr(640, root, root) %{APPDIR}/boot-scripts/linuxrc.part.urlsource.sh
%attr(640, root, root) %{APPDIR}/boot-scripts/linuxrc.part.iscsi.sh
%attr(640, root, root) %{APPDIR}/boot-scripts/linuxrc.part.install.sh
%config(noreplace) %{CONFIGDIR}/bootimage/gfs6-es30-files.i686.list
%config(noreplace) %{CONFIGDIR}/comoonics-bootimage.cfg

# ------
# $Log: comoonics-bootimage.spec,v $
# Revision 1.1  2005-01-03 08:33:17  marc
# first offical rpm version
# - initial revision
#
#
