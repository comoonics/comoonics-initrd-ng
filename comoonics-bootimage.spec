#****h* comoonics-bootimage/comoonics-bootimage.spec
#  NAME
#    comoonics-bootimage.spec
#    $id$
#  DESCRIPTION
#    RPM Configurationfile for the Comoonics bootimage
#  AUTHOR
#    Marc Grimme
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

# $Id: comoonics-bootimage.spec,v 1.100.4.2 2009-08-11 11:35:41 marc Exp $
#
##
##

%define _user root
%define CONFIGDIR /%{_sysconfdir}/comoonics
%define APPDIR    /opt/atix/%{name}
%define LIBDIR    /opt/atix/%{name}
%define ENVDIR    /etc/profile.d
%define ENVFILE   %{ENVDIR}/%{name}.sh
%define INITDIR   /etc/rc.d/init.d
%define SYSCONFIGDIR /%{_sysconfdir}/sysconfig

%define FENCEACKSV_SOURCE fencing/fence-ack-server
%define FENCEACKSV_DIR    /opt/atix/comoonics-fenceacksv

%define FENCECLIENTS_SOURCE fencing/
%define FENCECLIENTS_DIR /opt/atix/comoonics-fencing
%define FENCECLIENTS_DOC /usr/share/doc/comoonics-fencing

Name: comoonics-bootimage
Summary: Scripts for creating an initrd in a OSR Cluster environment
Version: 1.4
BuildArch: noarch
Requires: comoonics-cs-py >= 0.1-43 
Requires: comoonics-cluster-py >= 0.1-2 
Requires: comoonics-bootimage-initscripts >= 1.4 
Requires: comoonics-bootimage-listfiles-all
#Conflicts:
Release: 22_1
Vendor: ATIX AG
Packager: ATIX AG <http://bugzilla.atix.de>
ExclusiveArch: noarch
URL:     http://www.atix.de/
Source:  http://www.atix.de/software/downloads/comoonics/comoonics-bootimage-%{version}.tar.gz
License: GPL
Group:   System Environment/Base
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description
Scripts for creating an initrd in a OSR cluster environment

%package extras-network
Version: 0.1
Release: 2
Requires: comoonics-bootimage >= 1.3-1
Summary: Listfiles for special network configurations (vlan)
Group:   System Environment/Base
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description extras-network
Extra listfiles for special network configurations

%package extras-nfs
Version: 0.1
Release: 12_1
Requires: comoonics-bootimage >= 1.4
Summary: Listfiles for nfs sharedroot configurations
Group:   System Environment/Base
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description extras-nfs
Extra listfiles for nfs sharedroot configurations

%package extras-ocfs2
Version: 0.1
Release: 3
Requires: comoonics-bootimage >= 1.4
Summary: Listfiles for ocfs2 sharedroot configurations
Group:   System Environment/Base
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description extras-ocfs2
Extra listfiles for ocfs2 sharedroot configurations

# Overwritten by extras-dm-multipath-rhel so we add deps
%package extras-dm-multipath
Version: 0.1
Release: 3
Requires: comoonics-bootimage >= 1.3-36
Requires: /etc/redhat-release
Requires: comoonics-bootimage-listfiles-rhel
Requires: comoonics-bootimage-extras-dm-multipath-rhel
Summary: Listfiles for device mapper in OSR
Group:   System Environment/Base
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description extras-dm-multipath
Extra listfiles for device mapper multipath OSR configurations

%package extras-md
Version: 0.1
Release: 1
Requires: comoonics-bootimage >= 1.3-46
Summary: Listfiles for md support
Group:   System Environment/Base
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description extras-md
Extra listfiles for md in OSR configurations

%package extras-dm-multipath-rhel
Version: 0.1
Release: 2
Requires: comoonics-bootimage >= 1.3-36
Requires: /etc/redhat-release
Requires: comoonics-bootimage-listfiles-rhel
Summary: Listfiles for device mapper multipath OSR configurations for RHEL
Group:   System Environment/Base
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description extras-dm-multipath-rhel
Extra listfiles for device mapper multipath OSR configurations for RHEL

%package extras-dm-multipath-fedora
Version: 0.1
Release: 2
Requires: comoonics-bootimage >= 1.3-41
Requires: /etc/redhat-release
Requires: comoonics-bootimage-listfiles-fedora
Summary: Listfiles for device mapper multipath OSR configurations for fedora
Group:   System Environment/Base
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description extras-dm-multipath-fedora
Extra listfiles for device mapper multipath OSR configurations for fedora

%package extras-rdac-multipath
Version: 0.1
Release: 3
Requires: comoonics-bootimage >= 1.3-8
Summary: Listfiles for rdac multipath sharedroot configurations
Group:   System Environment/Base
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description extras-rdac-multipath
Extra listfiles for rdac multipath OSR configurations

%package extras-xen
Version: 0.1
Release: 5
Requires: comoonics-bootimage >= 1.3-14
Summary: Listfiles for xen support in the open-sharedroot cluster
Group:   System Environment/Base
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description extras-xen
listfiles for xen support in the OSR cluster

%package extras-iscsi
Version: 0.1
Release: 3
Requires: comoonics-bootimage >= 1.3-33
Summary: Listfiles for iscsi support in the open-sharedroot cluster
Group:   System Environment/Base
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description extras-iscsi
ISCSI support in the OSR cluster

%package extras-drbd
Version: 0.1
Release: 3
Requires: comoonics-bootimage >= 1.3-33
Summary: Listfiles for drbd support in the open-sharedroot cluster
Group:   System Environment/Base
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description extras-drbd
DRBD support in the OSR cluster

%package extras-glusterfs
Version: 0.1
Release: 1
Requires: comoonics-bootimage >= 1.3-44
Summary: Extras for glusterfs support in the open-sharedroot cluster
Group:   System Environment/Base
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description extras-glusterfs
GlusterFS support in the OSR cluster

%package extras-sysctl
Version: 0.1
Release: 1
Requires: comoonics-bootimage >= 1.3-44
Summary: Extras for sysctl support in the open-sharedroot cluster
Group:   System Environment/Base
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description extras-sysctl
Sysctl support in the OSR cluster

%package listfiles-all
Version: 0.1
Release: 5
Requires: comoonics-bootimage >= 1.3-36
Group:   System Environment/Base
Summary: OSR listfilesfiles for all distributions 
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description listfiles-all
OSR Listfiles that are only relevant for all linux distributions

%package listfiles-rhel
Version: 0.1
Release: 3
Requires: comoonics-bootimage >= 1.3-36
Requires: /etc/redhat-release
Requires: comoonics-bootimage-listfiles-all
Group: System Environment/Base
Summary: Extrafiles for RedHat Enterprise Linux 
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description listfiles-rhel
OSR extra files that are only relevant for RHEL Versions

%package listfiles-fedora
Version: 0.1
Release: 5
Requires: comoonics-bootimage >= 1.3-41
Requires: /etc/redhat-release
Requires: comoonics-bootimage-listfiles-all
Group: System Environment/Base
Summary: Extrafiles for Fedora Core 
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description listfiles-fedora
OSR extra files that are only relevant for Fedora Versions

%package listfiles-fedora-nfs
Version: 0.1
Release: 3
Requires: comoonics-bootimage-listfiles-fedora
Group: System Environment/Base
Summary: Extrafiles for Fedora Core NFS support 
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description listfiles-fedora-nfs
OSR extra files that are only relevant for Fedora Versions and nfs support

%package listfiles-rhel4
Version: 0.1
Release: 2
Requires: comoonics-bootimage >= 1.3-36
Requires: /etc/redhat-release
Requires: comoonics-bootimage-listfiles-rhel
Group: System Environment/Base
Summary: Extrafiles for RedHat Enterprise Linux Version 4 
Conflicts: comoonics-bootimage-listfiles-rhel5 
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description listfiles-rhel4
OSR extra files that are only relevant for RHEL4

%package listfiles-rhel5
Version: 0.1
Release: 3
Requires: comoonics-bootimage >= 1.3-36
Requires: /etc/redhat-release
Requires: comoonics-bootimage-listfiles-rhel
Group: System Environment/Base
Summary: Extrafiles for RedHat Enterprise Linux Version 5
Conflicts: comoonics-bootimage-listfiles-rhel4 
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description listfiles-rhel5
OSR extra files that are only relevant for RHEL4

%package listfiles-sles
Version: 0.1
Release: 3
Requires: comoonics-bootimage >= 1.3-37
Requires: /etc/SuSE-release
Requires: comoonics-bootimage-listfiles-all
Group: System Environment/Base
Summary: Extrafiles for Novell SuSE Enterprise Server
Conflicts: comoonics-bootimage-listfiles-rhel 
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description listfiles-sles
OSR extra files that are only relevant for Novell SLES 10

%package listfiles-fenceacksv-plugins
Version: 0.1
Release: 2
Requires: comoonics-bootimage >= 1.3-20
Requires: comoonics-cs-sysreport-templates
Requires: comoonics-fenceacksv-py
Requires: comoonics-fenceacksv-plugins-py
Summary: Extrafiles for plugins in fenceacksv
Group: System Environment/Server
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description listfiles-fenceacksv-plugins
OSR extrafiles for plugins in fenceacksv.

%package compat
Version: 0.1
Release: 2
Requires: comoonics-bootimage >= 1.3-1
Summary: Files needed for compatibility to 1.2 releases
Group:   System Environment/Base
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description compat
OSR files needed for the compatibility to 1.2 releases

%package fenceacksv
Version: 0.3
Release: 2
Requires: comoonics-cs-py >= 0.1-43
Requires: comoonics-bootimage >= 1.3-1
Summary: The Fenceackserver is a service for last resort actions
Group:   System Environment/Servers
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description fenceacksv
The Fenceackserver is a service for last resort actions

%package fenceclient-ilo
Version: 0.1
Release: 19
Summary: An alternative fence client for ilo cards of HP servers.
Group:   System Environment/Base
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description fenceclient-ilo
An alternative fence client for ilo cards of HP servers.

%package fenceclient-ilomp
Version: 0.1
Release: 2
Summary: A fence client for iloMP cards of HP inegrity servers.
Group:   System Environment/Base
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description fenceclient-ilomp
A fence client for iloMP cards of HP inegrity servers.

#%package fenceclient-vmware
#Version: 0.1
#Release: 5
#Summary: Fencing for vmware
#Group:   System Environment/Base
#BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot
#
#%description fenceclient-vmware
#Fencing for vmware clientschlegel
#
#%package fencemaster-vmware
#Version: 0.1
#Release: 2
#Summary: Fencing for vmware
#Group:   System Environment/Base
#BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot
#AutoReqProv: no
#
#%description fencemaster-vmware
#Fencing for the vmware master server

%prep
%setup -q

%build

%install
make PREFIX=$RPM_BUILD_ROOT INSTALL_DIR=%{APPDIR} install

# Files for compat
install -d -m 755 $RPM_BUILD_ROOT/%{SYSCONFIGDIR}
install -m0644 etc/sysconfig/comoonics-chroot.compat-vg_local $RPM_BUILD_ROOT/%{SYSCONFIGDIR}/comoonics-chroot


# Files for fenceacksv
install -d -m 755 $RPM_BUILD_ROOT/%{FENCEACKSV_DIR}
install -m755 %{FENCEACKSV_SOURCE}/fence_ack_server.py $RPM_BUILD_ROOT/%{FENCEACKSV_DIR}/
install -m644 %{FENCEACKSV_SOURCE}/shell.py $RPM_BUILD_ROOT/%{FENCEACKSV_DIR}/
#install -m644 %{FENCEACKSV_SOURCE}/pexpect.py $RPM_BUILD_ROOT/%{FENCEACKSV_DIR}/
install -m640 %{FENCEACKSV_SOURCE}/server.pkey $RPM_BUILD_ROOT/%{FENCEACKSV_DIR}/
install -m640 %{FENCEACKSV_SOURCE}/server.cert $RPM_BUILD_ROOT/%{FENCEACKSV_DIR}/
install -m640 %{FENCEACKSV_SOURCE}/CA.pkey $RPM_BUILD_ROOT/%{FENCEACKSV_DIR}/
install -m640 %{FENCEACKSV_SOURCE}/CA.cert $RPM_BUILD_ROOT/%{FENCEACKSV_DIR}/

install -d -m 755 $RPM_BUILD_ROOT/%{INITDIR}
install -m755 %{FENCEACKSV_SOURCE}/fenceacksv.sh $RPM_BUILD_ROOT/%{INITDIR}/fenceacksv
install -d -m 755 $RPM_BUILD_ROOT/%{CONFIGDIR}/bootimage-chroot
install -m644 %{FENCEACKSV_SOURCE}/files-fenceacksv.list $RPM_BUILD_ROOT/%{CONFIGDIR}/bootimage-chroot/files.initrd.d/fenceacksv.list
install -m644 %{FENCEACKSV_SOURCE}/rpms-fenceacksv.list $RPM_BUILD_ROOT/%{CONFIGDIR}/bootimage-chroot/rpms.initrd.d/fenceacksv.list
# install -m640 %{FENCEACKSV_SOURCE}/fenceacksv-config.sh $RPM_BUILD_ROOT/%{SYSCONFIGDIR}/fenceacksv

# Files for fence-clients (ilo)
install -d -m 755 $RPM_BUILD_ROOT/%{FENCECLIENTS_DIR}
install -d -m 755 $RPM_BUILD_ROOT/%{FENCECLIENTS_DOC}
install -m755 %{FENCECLIENTS_SOURCE}/fence_ilo.py  $RPM_BUILD_ROOT/%{FENCECLIENTS_DIR}/fence_ilo
install -d -m 755 $RPM_BUILD_ROOT/%{CONFIGDIR}/bootimage/rpms.initrd.d
install -m755 %{FENCECLIENTS_SOURCE}/rpms-fence_ilo.list $RPM_BUILD_ROOT/%{CONFIGDIR}/bootimage/rpms.initrd.d/fence_ilo.list
install -m755 %{FENCECLIENTS_SOURCE}/fence_ilomp.py  $RPM_BUILD_ROOT/%{FENCECLIENTS_DIR}/fence_ilomp
install -m755 %{FENCECLIENTS_SOURCE}/rpms-fence_ilomp.list $RPM_BUILD_ROOT/%{CONFIGDIR}/bootimage/rpms.initrd.d/fence_ilomp.list

# Files for fence-vmware
#install -m755 %{FENCECLIENTS_SOURCE}/fence_vmware_client  $RPM_BUILD_ROOT/%{FENCECLIENTS_DIR}
#install -m755 %{FENCECLIENTS_SOURCE}/rpms-fence_vmware_client.list $RPM_BUILD_ROOT/%{CONFIGDIR}/bootimage/rpms.initrd.d/fence_vmware_client.list
#install -m755 %{FENCECLIENTS_SOURCE}/fence_vmware_master  $RPM_BUILD_ROOT/%{FENCECLIENTS_DIR}
#install -m755 %{FENCECLIENTS_SOURCE}/README.fence_vmware  $RPM_BUILD_ROOT/%{FENCECLIENTS_DOC}
#install -m755 %{FENCECLIENTS_SOURCE}/INSTALL.fence_vmware  $RPM_BUILD_ROOT/%{FENCECLIENTS_DOC}

%postun

if [ "$1" -eq 0 ]; then
  echo "Postuninstalling comoonics-bootimage.."
  find /etc/comoonics/bootimage -name "files*.list" -o -name "rpms*.list" -type l -exec rm -f {} \; &>/dev/null
  root_fstype=$(mount | grep "/ " | awk '
BEGIN { exit_c=1; }
{ if ($5) {  print $5; exit_c=0; } }
END{ exit exit_c}')
  if [ "$root_fstype" != "gfs" ]; then
    chkconfig --list cman &>/dev/null && /sbin/chkconfig --add cman &>/dev/null && /sbin/chkconfig --list cman
    chkconfig --list gfs &>/dev/null && /sbin/chkconfig --add gfs &>/dev/null && /sbin/chkconfig --list gfs
  fi
  rm %{APPDIR}/mkinitrd
  rm %{ENVFILE}
fi

%post

echo "Starting postinstall.."
echo "Checking %{ENVFILE}"
if ! $(grep '%{APPDIR}' %{ENVFILE} > /dev/null 2>&1); then
    echo "Patching path.."
    echo 'PATH=%{APPDIR}:${PATH}' >> %{ENVFILE}
fi
echo "Creating mkinitrd link..."
ln -sf %{APPDIR}/create-gfs-initrd-generic.sh %{APPDIR}/mkinitrd

if cat /etc/redhat-release | grep -i "release 5" &> /dev/null; then
	services="cman gfs clvmd qdiskd"
else
	services="cman gfs clvmd qdiskd"
fi

echo "Disabling services ($services)"
for service in $services; do
   chkconfig --list $service &>/dev/null && chkconfig --del $service &> /dev/null
done
/bin/true

echo 'Information:
Cluster services will be started in a chroot environment. Check out latest documentation
on http://www.open-sharedroot.org
'

%post fenceacksv
echo "Setting up fenceacksv"
pushd %{FENCEACKSV_DIR} >/dev/null
ln -sf fence_ack_server.py fenceacksv
popd >/dev/null
chkconfig --add fenceacksv &> /dev/null
chkconfig --list fenceacksv
echo "Done"

%preun fenceacksv
if [ "$1" -eq 0 ]; then
  echo "Uninstalling fenceacksv"
  chkconfig --del fenceacksv
fi

%files
%dir %{LIBDIR}/boot-scripts/sys
%dir %{LIBDIR}/boot-scripts/var/log
%dir %{LIBDIR}/boot-scripts/var/lib/dhcp
%dir %{LIBDIR}/boot-scripts/var/run/netreport
%dir %{LIBDIR}/boot-scripts/proc
%dir %{LIBDIR}/boot-scripts/dev
%attr(0755, root, root) %{APPDIR}/create-gfs-initrd-generic.sh
%attr(0644, root, root) %{APPDIR}/create-gfs-initrd-lib.sh
%attr(0755, root, root) %{APPDIR}/manage_chroot.sh
%attr(0755, root, root) %{LIBDIR}/boot-scripts/com-halt.sh
%attr(0755, root, root) %{LIBDIR}/boot-scripts/com-realhalt.sh
%attr(0755, root, root) %{LIBDIR}/boot-scripts/linuxrc.generic.sh
%attr(0755, root, root) %{LIBDIR}/boot-scripts/linuxrc.sim.sh
%attr(0755, root, root) %{LIBDIR}/boot-scripts/detectHardware.sh
%attr(0755, root, root) %{LIBDIR}/boot-scripts/rescue.sh
%attr(0755, root, root) %{LIBDIR}/boot-scripts/linuxrc
%attr(0755, root, root) %{LIBDIR}/boot-scripts/linuxrc.bash
%attr(0755, root, root) %{LIBDIR}/boot-scripts/make_tar.sh
%attr(0755, root, root) %{LIBDIR}/boot-scripts/update-from-url.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/atix.txt
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/atix-logo.txt
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/bashrc
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/boot-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/chroot-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/clusterfs-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/comoonics-release
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/defaults.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/errors.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/ext3-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/gfs-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/hardware-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/inittab
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/issue
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/network-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/repository-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/xen-lib.sh
#%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/passwd
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/stdfs-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/stdlib.py
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/std-lib.sh
#%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/sysconfig/comoonics
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/rhel4/boot-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/rhel4/gfs-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/rhel4/hardware-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/rhel4/network-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/rhel5/boot-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/rhel5/gfs-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/rhel5/hardware-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/rhel5/network-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/sles8/hardware-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/sles8/network-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/sles10/boot-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/sles10/hardware-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/sles10/network-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/fedora/boot-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/fedora/gfs-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/fedora/hardware-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/fedora/network-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/fedora/nfs-lib.sh

%dir %{CONFIGDIR}/bootimage-chroot
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage-chroot/files.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage-chroot/rpms.list
%dir %{CONFIGDIR}/bootimage-chroot/files.initrd.d
%dir %{CONFIGDIR}/bootimage-chroot/rpms.initrd.d

%config(noreplace) %attr(0644, root, root) %{CONFIGDIR}/comoonics-bootimage.cfg

%doc %attr(0644, root, root) CHANGELOG

%files compat
%config(noreplace) %attr(0644, root, root) %{SYSCONFIGDIR}/comoonics-chroot

%files extras-network
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/vlan.list

%files extras-nfs
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/nfs-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/rhel5/nfs-lib.sh
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/nfs.list

%files extras-ocfs2
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/ocfs2-lib.sh
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/ocfs2.list

%files extras-md
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/mdadm.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/mdadm.list

%files extras-dm-multipath

%files extras-dm-multipath-rhel
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel/dm_multipath.list

%files extras-dm-multipath-fedora
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/fedora/dm_multipath.list

%files extras-rdac-multipath
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/rdac_multipath.list

%files extras-glusterfs
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/glusterfs-lib.sh
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/glusterfs.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/glusterfs.list

%files extras-sysctl
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/sysctl.list

%files extras-xen
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/xen.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/xen.list

%files extras-iscsi
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/iscsi-lib.sh
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/iscsi.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/iscsi.list

%files extras-drbd
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/drbd-lib.sh
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/drbd.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/drbd.list

#%files extras-rhcs-fedora
#%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/rhcs.list
#%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/rhcs.list
#
#%files extras-gfs-fedora
#%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/gfs1.list
#%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/gfs2.list

%files listfiles-all
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/basefiles.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/filters.list
%dir %{CONFIGDIR}/bootimage/files.initrd.d
%dir %{CONFIGDIR}/bootimage/rpms.initrd.d
%dir %{CONFIGDIR}/bootimage/filters.initrd.d
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/base.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/bonding.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/comoonics.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/configs.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/ext2.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/grub.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/locales.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/network.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/scsi.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/baselibs.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/comoonics.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/ext2.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/hardware.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/lvm.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/python.list
%config %attr(0644, root, root)  %{CONFIGDIR}/bootimage/filters.initrd.d/empty.list

%config(noreplace) %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/user_edit.list

%files listfiles-rhel
%dir %{CONFIGDIR}/bootimage/files.initrd.d/rhel
%dir %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/rhel/empty.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/rhel/base.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/rhel/configs.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/rhel/gfs.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/rhel/grub.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/rhel/network.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel/empty.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel/hardware.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel/python.list

%files listfiles-rhel4
%dir %{CONFIGDIR}/bootimage/files.initrd.d/rhel4
%dir %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel4
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/rhel4/empty.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel4/empty.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel4/gfs1.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel4/rhcs.list

%files listfiles-rhel5
%dir %{CONFIGDIR}/bootimage/files.initrd.d/rhel5
%dir %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel5
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/rhel5/empty.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/rhel5/rhcs.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel5/empty.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel5/base.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel5/gfs1.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel5/rhcs.list

%files listfiles-sles
%dir %{CONFIGDIR}/bootimage/files.initrd.d/sles
%dir %{CONFIGDIR}/bootimage/rpms.initrd.d/sles
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/sles/base.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/sles/empty.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/sles/network.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/sles/python.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/sles/base.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/sles/hardware.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/sles/empty.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/sles/dm_multipath.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/sles/network.list

%files listfiles-fedora
%dir %{CONFIGDIR}/bootimage/files.initrd.d/fedora
%dir %{CONFIGDIR}/bootimage/rpms.initrd.d/fedora
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/fedora/base.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/fedora/configs.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/fedora/network.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/fedora/base.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/fedora/hardware.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/fedora/python.list

%files listfiles-fedora-nfs
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/fedora/nfs.list

%files listfiles-fenceacksv-plugins
%config %attr(0644, root, root) %dir %{CONFIGDIR}/bootimage-chroot/rpms.initrd.d/fenceacksv-plugins.list

%files fenceacksv
%attr(0755, root, root) %{FENCEACKSV_DIR}/fence_ack_server.py*
#%attr(0755, root, root) %{FENCEACKSV_DIR}/fence_ack_server.pyc
#%attr(0755, root, root) %{FENCEACKSV_DIR}/fence_ack_server.pyo
%attr(0644, root, root) %{FENCEACKSV_DIR}/shell.py*
#%attr(0644, root, root) %{FENCEACKSV_DIR}/shell.pyc
#%attr(0644, root, root) %{FENCEACKSV_DIR}/shell.pyo
%attr(0644, root, root) %{FENCEACKSV_DIR}/server.pkey
%attr(0644, root, root) %{FENCEACKSV_DIR}/server.cert
%attr(0644, root, root) %{FENCEACKSV_DIR}/CA.pkey
%attr(0644, root, root) %{FENCEACKSV_DIR}/CA.cert
%config %attr(0755, root, root) %{INITDIR}/fenceacksv
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage-chroot/files.initrd.d/fenceacksv.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage-chroot/rpms.initrd.d/fenceacksv.list
#%config(noreplace)     %{SYSCONFIGDIR}/fenceacksv
%doc %attr(0644, root, root) CHANGELOG

%files fenceclient-ilo
%attr(0755, root, root) %{FENCECLIENTS_DIR}/fence_ilo
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/fence_ilo.list
%doc %attr(0644, root, root) CHANGELOG

%files fenceclient-ilomp
%attr(0755, root, root) %{FENCECLIENTS_DIR}/fence_ilomp
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/fence_ilomp.list
%doc %attr(0644, root, root) CHANGELOG

#%files fenceclient-vmware
#%attr(0755, root, root) %{FENCECLIENTS_DIR}/fence_vmware_client
#%doc %attr(0644, root, root) %{FENCECLIENTS_DOC}/INSTALL.fence_vmware
#%doc %attr(0644, root, root) %{FENCECLIENTS_DOC}/README.fence_vmware
#%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/fence_vmware_client.list
#%doc %attr(0644, root, root) CHANGELOG
#
#%files fencemaster-vmware
#%attr(0755, root, root) %{FENCECLIENTS_DIR}/fence_vmware_master
#%doc %attr(0644, root, root) %{FENCECLIENTS_DOC}/INSTALL.fence_vmware
#%doc %attr(0644, root, root) %{FENCECLIENTS_DOC}/README.fence_vmware
#%doc %attr(0644, root, root) CHANGELOG

%clean
rm -rf %{buildroot}


%changelog
* Tue Aug 11 2009 Marc Grimme <grimme@atix.de> 1.4-22_1
- Backport for bug #356 Device changes not applied in chroot environment when chroot on local disk
- Backport for bug #358 Initramfs consumes more and more during runtime. Which can lead to no free memory   
* Fri Jun 05 2009 Marc Grimme <grimme@atix.de> 1.4-22
- fixed bug #345 network init script patch xrootfs not applied correctly in RHEL 5.3
- fixed bug #346 Oracle Enterprise Linux could not be detected as Red Hat Clone
- fixed bug #347 The mkinitrd tool does not accept the -M option for specifying additional modules
* Wed Apr 21 2009 Marc Grimme <grimme@atix.de> 1.4-21
- fixed a bug where nic generation didn't work with FC10
- fixed a bug where nic generation and hw-detection did not work with SLES10
* Mon Apr 20 2009 Marc Grimme <grimme@atix.de> 1.4-20
- RC1
- gfs bugfix
* Tue Apr 16 2009 Marc Grimme <grimme@atix.de> 1.4-19
- fixes in service starting and handling
- fix in hardware-lib.sh
* Tue Apr 14 2009 Marc Grimme <grimme@atix.de> 1.4-18
- Rework on chroot build, nfs4 stabilized, fedora10 stabilized
* Tue Apr 09 2009 Marc Grimme <grimme@atix.de> 1.4-17
- Moved some functions
* Mon Apr 06 2009 Marc Grimme <grimme@atix.de> 1.4-16
- Implemented new concept of initscripts and xtab,xrootfs,xkillall_procs
* Mon Mar 30 2009 Marc Grimme <grimme@atix.de> 1.4-15
- Extended Bug #340 update mode for mkinitrd and adding/removing kernels with iscsi, xen
* Thu Mar 26 2009 Marc Grimme <grimme@atix.de> 1.4-14
- Implemented Bug #340 update mode for mkinitrd and adding/removing kernels
* Wed Mar 25 2009 Marc Grimme <grimme@atix.de> 1.4-13
- Fixed Bug#338 (klogd not being started in initrd)
- Implemented global filters (for lite version)
* Tue Mar 17 2009 Marc Grimme <grimme@atix.de> 1.4-12
- Fence_tool -m bugfix (#335)
* Fri Mar 06 2009 Marc Grimme <grimme@atix.de> 1.4-11
- Udevd will be started implicitly
- Fixed bug in network setup because NICs would be detected multiple times
- Some typos
* Tue Feb 27 2009 Marc Grimme <grimme@atix.de> 1.4-10
- Bugfix in network power up order (vlan/bridges)
* Tue Feb 27 2009 Marc Grimme <grimme@atix.de> 1.4-9
- Bugfix in amount of nics being powered up
* Tue Feb 27 2009 Marc Grimme <grimme@atix.de> 1.4-8
- Bugfix in static hardware detection
* Tue Feb 27 2009 Marc Grimme <grimme@atix.de> 1.4-7
- Backport to RHEL4
* Wed Feb 25 2009 Marc Grimme <grimme@atix.de> 1.4-6
- fixed bug in xen hardwaredetection
- and rootfs and clutype in bootsr
* Tue Feb 24 2009 Marc Grimme <grimme@atix.de> 1.4-5
- first offical 1.4 rc
- Hardwaredetection: restricted hwdetection implemented (@driver)
- Multiple kernelmodules in initrd
* Sun Feb 08 2009 Marc Grimme <grimme@atix.de> 1.3-46
- Hardwaredetection: stable module removement
- RHEL5/gfsjoin: copied joinprocess from initscripts
* Mon Feb 02 2009 Marc Grimme <grimme@atix.de> 1.3-45
- Bugfix in hardwaredetection
- Introduced no load of storage if not needed
* Tue Jan 29 2009 Marc Grimme <grimme@atix.de> 1.3-44
- First version with new hardware detection Bug#325
- First version with Usability review Parent-Bug#323
- Implemented sysctl concept to generally implement the IGMPv2 thing Bug#324
- Many other usability improvements
- Support for nfsv4
* Fri Dec 05 2008 Marc Grimme <grimme@atix.de> 1.3-41
- First version on the way to rpmlint BUG#290
* Tue Nov 18 2008 Marc Grimme <grimme@atix.de> 1.3-40
- Enhancement #289 implemented so that we now have a script linux.sim.sh to be executed within initrd or from outside.
- Cosmetic changes looks much better!
- Pulled all other changes upstream
* Tue Oct 14 2008 Marc Grimme <grimme@atix.de> 1.3-39
- Enhancement #273 and dependencies implemented (flexible boot of local fs systems)
* Wed Sep 24 2008 Marc Grimme <grimme@atix.de> 1.3-38
- Bugfix #272 where static ipaddress will not be set in sles10
* Mon Aug 11 2008 Marc Grimme <grimme@atix.de> 1.3-37
- cleanups for introduced changes
- small bugfixes
- removed xen-lib.sh to extras-xen
- introduced *_getdefaults to be used with getParameter
* Wed Aug 06 2008 Marc Grimme <grimme@atix.de> 1.3-36
- intermediate release to get things upstream
- rewrote bridging no xenbr scripts are directly supported
- rewrote hwdetection (start udev before kudzu) RHEL5
- minor bugfixes 
- added sles10
* Tue Jun 20 2008 Mark Hlawatschek <hlawatschek@atix.de> 1.3-34
- revised default boot option
* Tue Jun 10 2008 Marc Grimme <grimme@atix.de> 1.3-33
- second ocfs2 devel version
- iscsi/drbd/nfs bugfixes
* Tue Jun 10 2008 Marc Grimme <grimme@atix.de> 1.3-32
- first ocfs2 devel version
- rewrote reboot and fs dependencies
* Wed May 28 2008 Mark Hlawatschek <hlawatschekImplemented@atix.de> 1.3-31
- stabilize lvm operations (fix for BZ 193)
- change permissions for chroot path (fix for BZ 210)
* Fri May 16 2008 Marc Grimme <grimme@atix.de> 1.3-30
- changed creation of hostsfile (/etc/hosts) in order to support dhcp better.
  RFE BZ#218
- Fixed bug from RFE#144 because being not implemented for rhel4
* Tue Feb 12 2008 Marc Grimme <grimme@atix.de> 1.3-28
- updated drbd support (optimized) thanks to gordan
* Mon Feb 11 2008 Marc Grimme <grimme@atix.de> 1.3-27
- added drbd support thanks to gordan
* Tue Jan 30 2008 Marc Grimme <grimme@atix.de> 1.3-26
- fixed BUG#192 when xen dom0 would not be detected
* Tue Jan 24 2008 Marc Grimme <grimme@atix.de> 1.3-25
- fixed syntax error in linuxrc.generic.sh
- fixed qdisk order in rhel5/gfs-lib.sh
* Tue Jan 24 2008 Marc Grimme <grimme@atix.de> 1.3-22
- Fixed Bug#170 initrd fails with dm_multipath in RHEL5
- Fixed Bug#178 nousb bootparameter should be available
- Fixed Bug#179 xen guest will not be detected with rhel4
- rewrote iscsilibs to be more generix
- Implemented RFE#144 Mac-Address in configuration files.
* Mon Oct 17 2007 Marc Grimme <grimme@atix.de> Implemented1.3-21
- Fixed Bug 144, where mounoptions where not used
- Added ISCSI Support preview (thanks to Gordan Bobic)
- Fixed Bug 142, where in RHEL4 qdiskd could not be started
* Wed Oct 10 2007 Mark Hlawatschek <hlawatschek@atix.de> 1.3-20
- Fixes BUG 114
- Fixes BUG 139
* Wed Oct 10 2007 Mark Hlawatschek <hlawatschek@atix.de> 1.3-19
- Fixes BUG 138
* Tue Oct 09 2007 Mark Hlawatschek <hlawatschek@atix.de> 1.3-18
- Another fix for BUG 136
- start syslogd in chroot
* Mon Oct 08 2007 Marc Grimme <grimme@atix.de> 1.3-17
- readded usb (hid) Support
- added stabilized for having stabilized files
* Mon Oct 08 2007 Mark Hlawatschek <hlawatschek@atix.de> 1.3-16
- Fixed BUG 136
* Fri Oct 05 2007 Marc Grimme <grimme@atix.de> 1.3-15
- added xensupport
* Tue Oct 02 2007 Marc Grimme <grimme@atix.de> 1.3-14
- Fixed BUG 127, chrootenv and /etc/sysconfig/comoonics-chroot would not work before
- Fixed BUG 128, chroot was not build correctly if oldone existed
- Fixed BUG 130, fenced is hanging because dev-bindmounts do not work
* Thu Sep 27 2007 Marc Grimme <grimme@atix.de> 1.3-13
- Fixed BUG 125 (qdisk was wrongly started)
- Fixed Problem with hardware detection (/etc/passwd) has to be removed
* Wed Sep 26 2007 Mark Hlawatschek <hlawatschek@atix.de> 1.3.12
- modifications and bugfixes for el5
* Tue Sep 18 2007 Mark Hlawatschek <hlawatschek@atix.de> 1.3.11
- modifications for el5, bugfixes
* Tue Sep 18 2007 Mark Hlawatschek <hlawatschek@atix.de> 1.3.10
- bugfixes
* Fri Sep 14 2007 Marc Grimme <grimme@atix.de> - 1.3-8
- added support for rdac multipath
* Wed Aug 08 2007 Mark Hlawatschek <hlawatschek@atix.de> 1.3.4
- moved dm_multipath listfile into extra rpm
* Wed Aug 08 2007 Mark Hlawatschek <hlawatschek@atix.de> 1.3.3
- minor bugfixes
* Tue Aug 07 2007 Mark Hlawatschek <hlawatschek@atix.de> 1.3.2
- minor bugfixes
* Tue Aug 07 2007 Mark Hlawatschek <hlawatschek@atix.de> 1.3.1
- new major bootimage revision
* Tue Jul 24 2007 Mark Hlawatschek <hlawatschek@atix.de> 1.2.03
- added support for fence_ipmilan
* Wed May 23 2007 Mark Hlawatschek <hlawatschek@atix.de> 1.2.02
- added support for RHEL4u5
* Wed Apr 11 2007 Mark Hlawatschek <hlawatschek@atix.de> 1.2.01
- modified switchroot to 2.6 style
- added nfs rootfs support
- added ext3 rootfs supprt
- seperated fs and cluster type
* Fri Feb 09 2007 Mark Hlawatschek <hlawatschek@atix.de> 1.0.81
- added support for dm_multipath partitions
* Fri Feb 09 2007 Marc Grimme <grimme@atix.de> 1.0.81-rc
- added nodeid parameter at boottime (bonding not clear)
- bootsr will only rebuild if needed
- added nsswitch.conf to chroot. Because of ccs_tool update sometime failed.
- better step continue mode
* Mon Jan 22 2007 Mark Hlawatschek <hlawatschek at atix.de> 1.0.73
- added changelog
- added support for vlan devices
- added support for kernel cmdline initlevel
- added dstep-mode kernel parameter -> ask (Y|n|c) with evey exec_local
* Fri May 12 2006  <grimme@atix.de> - 1.0-7
- First stable 1.0 Version is RPM 1.0-7

* Wed Jan 25 2006  <grimme@atix.de> - 0.3-12
- First stable 0.3 version


* Mon Jan  3 2005 Marc Grimme <grimme@atix.de> - 0.1-16
- first offical rpm version

%changelog extras-rdac-multipath
* Fri Dec 05 2008 Marc Grimme <grimme@atix.de> - 0.1-2
- First version on the way to rpmlint BUG#290
* Fri Sep 14 2007 Marc Grimme <grimme@atix.de> - 0.1-1
- first release

%changelog extras-xen
* Fri Dec 05 2008 Marc Grimme <grimme@atix.de> - 0.1-5
- First version on the way to rpmlint BUG#290
* Wed Aug 06 2008 Marc Grimme <grimme@atix.de> - 0.1-4
- removed xen-lib.sh back to comoonics-bootimage as this extras are only needed for dom0 not domu
- bugfixes and removed default bridging to no bridging
* Tue Oct 18 2007 Marc Grimme <grimme@atix.de> - 0.1-2
- added nss rpm for fence_xvm
* Wed Oct 03 2007 Marc Grimme <grimme@atix.de> - 0.1-1
- first release

%changelog extras-iscsi
* Tue Apr 14 2009 Marc Grimme <grimme@atix.de> - 0.1-5
- get_drivers function implemented
* Mon Mar 30 2009 Marc Grimme <grimme@atix.de> - 0.1-4
- Extended Bug #340 update mode for mkinitrd and adding/removing kernels with iscsi
* Fri Dec 05 2008 Marc Grimme <grimme@atix.de> - 0.1-3
- First version on the way to rpmlint BUG#290
* Tue Jun 10 2008 Marc Grimme <grimme@atix.de> - 0.1-2
- added iscsi-lib.sh file
* Fri Oct 12 2007 Marc Grimme <grimme@atix.de> - 0.1-1
- first release

%changelog extras-drbd
* Tue Apr 14 2009 Marc Grimme <grimme@atix.de> - 0.1-5
- get_drivers function implemented
* Mon Mar 30 2009 Marc Grimme <grimme@atix.de> - 0.1-4
- Extended Bug #340 update mode for mkinitrd and adding/removing kernels with drbd
* Fri Dec 05 2008 Marc Grimme <grimme@atix.de> - 0.1-3
- First version on the way to rpmlint BUG#290
* Tue Jun 10 2008 Marc Grimme <grimme@atix.de> - 0.1-2
- added drbd-lib.sh file
* Mon Feb 11 2008 Marc Grimme <grimme@atix.de> - 0.1-1
- first release

%changelog extras-nfs
* Tue Aug 11 2009 Marc Grimme <grimme@atix.de> - 0.1-12_1
- Backport for bug #357 NFS4 OSR Cluster fails to boot on RHEL5 - wrong mount options and no portmap
* Tue Apr 14 2009 Marc Grimme <grimme@atix.de> - 0.1-10
- nfs4 stabilized
* Fri Mar 27 2009 Marc Grimme <grimme@atix.de> 0.1-9
- Added nfs_get_drivers
* Tue Jan 29 2009 Marc Grimme <grimme@atix.de> 0.1-7
- First version with new hardware detection Bug#325
- First version with Usability review Parent-Bug#323
- Implemented sysctl concept to generally implement the IGMPv2 thing Bug#324
- Many other usability improvements
- Support for nfsv4
* Fri Dec 05 2008 Marc Grimme <grimme@atix.de> - 0.1-4
- First version on the way to rpmlint BUG#290
* Wed Aug 06 2008 Marc Grimme <grimme@atix.de> - 0.1-3
- bugfixes upstream
* Tue Jun 10 2008 Marc Grimme <grimme@atix.de> - 0.1-2
- added nfs-lib.sh file

%changelog extras-ocfs2
* Fri Mar 27 2009 Marc Grimme <grimme@atix.de> 0.1-3
- Added ocfs2_get_drivers

%changelog extras-md
* Sun Feb 08 2009 Marc Grimme <grimme@atix.de> - 0.1-1
  initial revision (Thanks to Gordan)
  
%changelog extras-dm-multipath
* Tue Jan 29 2009 Marc Grimme <grimme@atix.de> - 0.1-3
- introduced the changelog

%changelog extras-dm-multipath-rhel
* Tue Jan 29 2009 Marc Grimme <grimme@atix.de> - 0.1-2
- introduced the changelog

%changelog extras-dm-multipath-fedora
* Tue Jan 29 2009 Marc Grimme <grimme@atix.de> - 0.1-2
- introduced the changelog

%changelog extras-glusterfs
* Mon Mar 30 2009 Marc Grimme <grimme@atix.de> - 0.1-3
- Extended Bug #340 update mode for mkinitrd and adding/removing kernels with glusterfs
* Tue Jan 29 2009 Marc Grimme <grimme@atix.de> - 0.1-1
- initial revision (thanks to Gordan)

%changelog extras-sysctl
* Tue Jan 29 2009 Marc Grimme <grimme@atix.de> - 0.1-1
- initial revision

%changelog listfiles-all
* Wed Mar 25 2009 Marc Grimme <grimme@atix.de> - 0.1-5
- Implemented global filters
* Tue Jan 29 2009 Marc Grimme <grimme@atix.de> - 0.1-4
- Updated the listfiles to latest deps
* Fri Dec 05 2008 Marc Grimme <grimme@atix.de> - 0.1-2
- First version on the way to rpmlint BUG#290
* Thu Aug 14 2008 Marc Grimme <grimme@atix.de - 0.1-1
  - initial revision 

%changelog listfiles-rhel
* Fri Dec 05 2008 Marc Grimme <grimme@atix.de> - 0.1-2
- First version on the way to rpmlint BUG#290
* Thu Aug 14 2008 Marc Grimme <grimme@atix.de - 0.1-1
  - initial revision 

%changelog listfiles-rhel4
* Fri Dec 05 2008 Marc Grimme <grimme@atix.de> - 0.1-2
- First version on the way to rpmlint BUG#290
* Thu Aug 14 2008 Marc Grimme <grimme@atix.de - 0.1-1
  - initial revision 

%changelog listfiles-rhel5
* Tue Feb 24 2009 Marc Grimme <grimme@atix.de> - 0.1-4
- removed krb files in configs.list
* Tue Jan 29 2009 Marc Grimme <grimme@atix.de> - 0.1-3
- Removed and added more files
* Fri Dec 05 2008 Marc Grimme <grimme@atix.de> - 0.1-2
- First version on the way to rpmlint BUG#290
* Thu Aug 14 2008 Marc Grimme <grimme@atix.de - 0.1-1
  - initial revision 

%changelog listfiles-sles
* Fri Dec 05 2008 Marc Grimme <grimme@atix.de> - 0.1-3
- First version on the way to rpmlint BUG#290
* Wed Sep 24 2008 Marc Grimme <grimme@atix.de> - 0.1-2
- Replaced dependency listfiles to listfiles-all in listfiles-sles
* Thu Aug 14 2008 Marc Grimme <grimme@atix.de - 0.1-1
  - initial revision 

%changelog listfiles-fedora
* Tue Feb 24 2009 Marc Grimme <grimme@atix.de> - 0.1-5
- removed krb files in configs.list
* Tue Jan 29 2009 Marc Grimme <grimme@atix.de> - 0.1-4
- introduced the changelog

%changelog listfiles-fedora-nfs
* Tue Jan 29 2009 Marc Grimme <grimme@atix.de> - 0.1-3
- introduced the changelog

%changelog fenceacksv
* Fri Dec 05 2008 Marc Grimme <grimme@atix.de> - 0.3-2
- First version on the way to rpmlint BUG#290
* Mon Sep 10 2007 Marc Grimme <grimme@atix.de> - 0.3-1
  - Fixed Bug BZ#107, fixed problems with not installed plugins
  - Fixed Bug BZ#29, output of ackmanual
  - Rewritten
  - Support for plugins (available: sysrq, sysreport)
* Mon Sep 10 2007 Mark Hlawatschek <hlawatschek@atix.de> - 0.2-1
  - first release for 1.3 bootimage
* Wed Feb 07 2007 Marc Grimme <grimme@atix.de> - 0.1-11
- introducted changelog

%changelog fenceclient-ilo
* Fri Dec 05 2008 Marc Grimme <grimme@atix.de> - 0.1-18
- First version on the way to rpmlint BUG#290
* Mon Jul 30 2007 Marc Grimme <grimme@atix.de> - 0.1-17
- added help for -x|--xmlfile (#BZ 39)
* Wed Feb 07 2007 Marc Grimme <grimme@atix.de - 0.1-16
- introducted changelog

#%changelog fenceclient-vmware
#* Fri Dec 05 2008 Marc Grimme <grimme@atix.de> - 0.1-5
#- First version on the way to rpmlint BUG#290
#* Wed Feb 07 2007 Marc Grimme <grimme@atix.de - 0.1-4
#- introducted changelog
#
#%changelog fencemaster-vmware
#* Fri Dec 05 2008 Marc Grimme <grimme@atix.de> - 0.1-2
#- First version on the way to rpmlint BUG#290
#* Wed Feb 07 2007 Marc Grimme <grimme@atix.de - 0.1-1
#- introducted changelog
#
# ------
# $Log: comoonics-bootimage.spec,v $
# Revision 1.100.4.2  2009-08-11 11:35:41  marc
# new versions
#
# Revision 1.100.4.1  2009/08/11 09:49:56  marc
# Backported upstream bugs
#
# Revision 1.100  2009/06/05 07:33:44  marc
# - new version for comoonics-bootimage 1.4-22
#
# Revision 1.99  2009/04/22 11:39:10  marc
# new version 1.4-21
#
# Revision 1.98  2009/04/20 07:42:31  marc
# - new version 20, nfs 11
#
# Revision 1.97  2009/04/14 15:03:41  marc
# *** empty log message ***
#
# Revision 1.96  2009/03/06 13:27:26  marc
# - removed initial start of udev as it should be started implicitly on demand
# - fixed bug in network setup because devices would have been created multiple times
# - some typos
#
# Revision 1.95  2009/02/27 10:35:46  marc
# new version for bootimage (1.4-8)
#
# Revision 1.94  2009/02/27 08:43:52  marc
# new version for bootimage (1.4-7)
#
# Revision 1.93  2009/02/25 10:42:24  marc
# fixed bug with xennet hardware_detection
#
# Revision 1.92  2009/02/25 08:42:13  marc
# changed nfs modules
#
# Revision 1.91  2009/02/24 12:13:49  marc
# new listfiles
#
# Revision 1.90  2009/02/24 12:09:45  marc
# first 1.4 rc
#
# Revision 1.89  2009/02/18 18:10:40  marc
# new version
#
# Revision 1.88  2009/02/08 14:24:50  marc
# typo
#
# Revision 1.87  2009/02/08 14:22:38  marc
# added extras-md
#
# Revision 1.86  2009/02/08 13:17:54  marc
# new version for comoonics-bootimage (1.3-46
#
# Revision 1.85  2009/02/03 16:33:08  marc
# new version
#
# Revision 1.84  2009/01/29 19:48:58  marc
# new versions
#
# Revision 1.83  2008/12/08 15:43:04  marc
# rpmlint Bug#290
#
# Revision 1.82  2008/12/08 15:05:25  marc
# rpmlint Bug#290
#
# Revision 1.81  2008/12/05 16:12:58  marc
# First step to go rpmlint compat BUG#230
#
# Revision 1.80  2008/12/01 14:44:28  marc
# changed file attributes (Bug #290)
#
# Revision 1.79  2008/11/18 14:28:26  marc
# - implemented RFE-BUG 289 (level up/down)
#
# Revision 1.78  2008/10/14 10:57:07  marc
# Enhancement #273 and dependencies implemented (flexible boot of local fs systems)
#
# Revision 1.77  2008/09/24 08:14:25  marc
# - Bugfix #272 where static ipaddress will not be set in sles10
# - Replaced dependency listfiles to listfiles-all in listfiles-sles
#
# Revision 1.76  2008/09/24 08:12:43  marc
# - Bugfix #272 where static ipaddress will not be set in sles10
# - Replaced dependency listfiles to listfiles-all in listfiles-sles
#
# Revision 1.75  2008/09/10 13:12:10  marc
# Fixed bugs #267, #265, #264
#
# Revision 1.74  2008/08/14 14:40:41  marc
# -added channel option which will build channel
# - added new versions
#
# Revision 1.73  2008/07/03 13:04:17  mark
# new release
#
# Revision 1.72  2008/06/23 22:13:42  mark
# new release
#
# Revision 1.71  2008/06/10 10:10:57  marc
# - new versions
#
# Revision 1.70  2008/05/28 14:54:46  mark
# new bootimage revision
#
# Revision 1.69  2008/05/17 08:34:22  marc
# - added new version 1.3-30
#
# Revision 1.68  2008/02/29 09:09:07  mark
# added wildcards to .py files
#
# Revision 1.67  2008/01/24 13:57:15  marc
# - Fixed Bug#170 initrd fails with dm_multipath in RHEL5
# - Fixed Bug#178 nousb bootparameter should be available
# - Fixed Bug#179 xen guest will not be detected with rhel4
# - rewrote iscsilibs to be more generix
# - Implemented RFE#144 Mac-Address in configuration files.
#
# Revision 1.66  2007/12/07 16:39:59  reiner
# Added GPL license and changed ATIX GmbH to AG.
#
# Revision 1.65  2007/11/28 12:41:42  mark
# new release
#
# Revision 1.64  2007/10/18 08:22:37  marc
# - new version of extras-xen 0.1-2
#
# Revision 1.63  2007/10/18 08:15:27  mark
# new build
#
# Revision 1.62  2007/10/16 08:04:33  marc
# - added get_rootsource
# - fixed BUG 142
# - lvm switch support
#
# Revision 1.61  2007/10/11 07:34:37  mark
# new revision
#
# Revision 1.60  2007/10/10 19:50:52  marc
# new version 1.3-20
#
# Revision 1.59  2007/10/10 15:11:07  mark
# new release
#
# Revision 1.58  2007/10/10 12:29:16  mark
# new release
#
# Revision 1.57  2007/10/09 14:25:12  marc
# - new release of comoonics-bootimage 1.3-17
#
# Revision 1.56  2007/10/08 16:15:05  mark
# new release
#
# Revision 1.55  2007/10/05 14:09:53  mark
# new revision
#
# Revision 1.54  2007/10/05 10:10:13  marc
# - new version comoonics-bootimage-1.3-15
#
# Revision 1.53  2007/10/02 12:16:30  marc
# - new release comoonics-bootimage-1.3-14
#
# Revision 1.52  2007/09/27 11:56:14  marc
# new version of comoonics-bootimage-1.3-13
#
# Revision 1.51  2007/09/26 11:55:51  mark
# new releases
#
# Revision 1.50  2007/09/21 15:34:51  mark
# new release
#
# Revision 1.49  2007/09/18 11:21:15  mark
# bootimage-1.3.10
#
# Revision 1.48  2007/09/15 14:49:38  mark
# moved listfiles into extra rpms
#
# Revision 1.47  2007/09/14 13:35:52  marc
# added rdac-rpm and comments
#
# Revision 1.46  2007/09/13 09:06:44  mark
# merged changes
#
# Revision 1.45  2007/09/12 13:48:05  mark
# moved initscripts into another specfile
#
# Revision 1.44  2007/09/10 15:03:18  marc
# - new version of fenceacksv 0.3-1
#
# Revision 1.43  2007/09/10 09:24:01  marc
# -new version of fenceacksv 0.3-1
#
# Revision 1.42  2007/09/07 08:30:25  mark
# merged fixes from 1.2
#
# Revision 1.41  2007/09/07 07:55:42  mark
# removed tmpwatch conflict
# added rhel5 parts
#
# Revision 1.40  2007/08/29 06:46:13  marc
# setting AUTOREQ: NO for vmware agent
#
# Revision 1.39  2007/08/08 14:25:17  mark
# release 1.3.4
#
# Revision 1.38  2007/08/07 12:42:38  mark
# added release 1.3.1
# added extras-nfs
# added extras-network
#
# Revision 1.37  2007/07/30 06:47:12  marc
# added help for -x|--xmlfile (#BZ 39)
#
# Revision 1.36  2007/07/24 17:05:34  mark
# added 1.2.03
#
# Revision 1.35  2007/05/23 15:30:00  mark
# version 1.2.02
#
# Revision 1.34  2007/03/01 10:50:04  marc
# changed getopt
#
# Revision 1.33  2007/02/23 16:44:50  mark
# revision 1.0.81
#
# Revision 1.32  2007/02/09 11:08:17  marc
# new version 81
#
# Revision 1.31  2007/01/23 12:57:14  mark
# new release 1.0.75
#
# Revision 1.30  2006/12/04 17:37:12  marc
# new versions
#
# Revision 1.29  2006/11/10 11:38:29  mark
# release 1.0.73
# added conflicts tmpwatch and tmpwatch warnings
#
# Revision 1.28  2006/10/26 16:13:24  mark
# release got from src.rpm
# added support for ccsd-chroot
#
# Revision 1.27  2006/10/06 08:36:27  marc
# version with quorumack
#
# Revision 1.26  2006/08/28 16:00:27  marc
# very well tested version
#
# Revision 1.25  2006/08/14 17:42:41  marc
# new version with max_drop_count and fenced from local disk
#
# Revision 1.24  2006/07/19 15%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/fedora/base.list
# removed the fence-tool lists for chroot
#
# Revision 1.23  2006/07/19 15:11:36  marc
# fixed fence_bug for x86_64
#
# Revision 1.22  2006/07/13 11:35:16  marc
# new version changing file xtensions
#
# Revision 1.21  2006/07/03 08:33:59  marc
# new version
#
# Revision 1.20  2006/06/19 15:57:40  marc
# added devicemapper support
#
# Revision 1.19  2006/06/09 14:04:05  marc%attr(640, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/configs.list

# new version.
#
# Revision 1.18  2006/06/07 09:42:23  marc
# *** empty log message ***
#
# Revision 1.17  2006/05/12 13:01:56  marc
# First stable 1.0 Version
#
# Revision 1.16  2006/05/07 12:06:56  marc
# version 1.0 stable
#
# Revision 1.15  2006/05/03 12:47:17  marc
# added documentation
#
# Revision 1.14  2006/04/13 18:52:09  marc
# latest versino
#
# Revision 1.13  2006/04/13 18:46:31  marc
# new version
#
# Revision 1.12  2006/04/11 13:42:45  marc
# cvs stable version
#
# Revision 1.11  2006/04/11 13:41:20  marc
# added hostnames and x86_64 support
#
# Revision 1.10  2006/02/16 13:59:06  marc
# stable version 20
#
# Revision 1.9  2006/01/28 15:01:49  marc
# fenced is restarted in the initrd
#
# Revision 1.8  2006/01/25 14:55:51  marc
# first stable 0.3
#
# Revision 1.7  2006/01/23 14:05:30  mark
# added bootsr
#
# Revision 1.6  2005/07/08 13:15:57  mark
# added some files
#
# Revision 1.5  2005/06/27 14:24:20  mark
# added gfs 61, rhel4 support
#
# Revision 1.4  2005/06/08 13:33:22  marc
# new revision
#
# Revision 1.3  2005/01/05 10:57:07  marc
# new release and added the latest files.
#
# Revision 1.2  2005/01/03 08:34:16  marc
# added new subversion for first offical rpm version
#
# Revision 1.1  2005/01/03 08:33:17  marc
# first offical rpm version
# - initial revision
#
#
