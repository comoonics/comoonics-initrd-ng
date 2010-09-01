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

# $Id: comoonics-bootimage.spec,v 1.134 2010-09-01 15:33:34 marc Exp $
#
##
##

%define _user root
%define _sysconfdir /etc
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
Requires: comoonics-cluster-py >= 0.1-21
Requires: comoonics-bootimage-initscripts >= 1.4 
Requires: comoonics-bootimage-listfiles-all
Requires: comoonics-tools-py
#Conflicts:
Release: 63
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

%package extras-osr
Version: 0.1
Release: 4
Requires: comoonics-bootimage >= 1.3-1
Summary: Extra for cluster configuration via osr
Group:   System Environment/Base
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description extras-osr
Extra for cluster configuration via osr.

%package extras-network
Version: 0.1
Release: 3
Requires: comoonics-bootimage >= 1.3-1
Summary: Listfiles for special network configurations (vlan)
Group:   System Environment/Base
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description extras-network
Extra listfiles for special network configurations

%package extras-nfs
Version: 0.1
Release: 18
Requires: comoonics-bootimage >= 1.4
Summary: Listfiles for nfs sharedroot configurations
Group:   System Environment/Base
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description extras-nfs
Extra listfiles for nfs sharedroot configurations

%package extras-ocfs2
Version: 0.1
Release: 10
Requires: comoonics-bootimage >= 1.4
Summary: Listfiles for ocfs2 sharedroot configurations
Group:   System Environment/Base
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description extras-ocfs2
Extra listfiles for ocfs2 sharedroot configurations

# Overwritten by extras-dm-multipath-rhel so we add deps
%package extras-dm-multipath
Version: 0.1
Release: 5
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
Release: 2
Requires: comoonics-bootimage >= 1.3-46
Summary: Listfiles for md support
Group:   System Environment/Base
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description extras-md
Extra listfiles for md in OSR configurations

%package extras-dm-multipath-rhel
Version: 0.1
Release: 3
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
Release: 3
Requires: comoonics-bootimage >= 1.3-41
Requires: /etc/redhat-release
Requires: comoonics-bootimage-listfiles-fedora
Summary: Listfiles for device mapper multipath OSR configurations for fedora
Group:   System Environment/Base
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description extras-dm-multipath-fedora
Extra listfiles for device mapper multipath OSR configurations for fedora

%package extras-dm-multipath-sles
Version: 0.1
Release: 2
Requires: comoonics-bootimage >= 1.4
Requires: multipath-tools
Summary: Listfiles for device mapper multipath OSR configurations for SLES
Group:   System Environment/Base
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description extras-dm-multipath-sles
Extra listfiles for device mapper multipath OSR configurations for SLES

%package extras-rdac-multipath
Version: 0.1
Release: 4
Requires: comoonics-bootimage >= 1.3-8
Summary: Listfiles for rdac multipath sharedroot configurations
Group:   System Environment/Base
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description extras-rdac-multipath
Extra listfiles for rdac multipath OSR configurations

%package extras-xen
Version: 0.1
Release: 6
Requires: comoonics-bootimage >= 1.3-14
Summary: Listfiles for xen support in the open-sharedroot cluster
Group:   System Environment/Base
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description extras-xen
listfiles for xen support in the OSR cluster

%package extras-iscsi
Version: 0.1
Release: 11
Requires: comoonics-bootimage >= 1.4-55
Summary: Listfiles for iscsi support in the open-sharedroot cluster
Group:   System Environment/Base
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description extras-iscsi
ISCSI support in the OSR cluster

%package extras-drbd
Version: 0.1
Release: 4
Requires: comoonics-bootimage >= 1.3-33
Summary: Listfiles for drbd support in the open-sharedroot cluster
Group:   System Environment/Base
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description extras-drbd
DRBD support in the OSR cluster

%package extras-glusterfs
Version: 0.1
Release: 4
Requires: comoonics-bootimage >= 1.3-44
Summary: Extras for glusterfs support in the open-sharedroot cluster
Group:   System Environment/Base
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description extras-glusterfs
GlusterFS support in the OSR cluster

%package extras-sysctl
Version: 0.1
Release: 2
Requires: comoonics-bootimage >= 1.3-44
Summary: Extras for sysctl support in the open-sharedroot cluster
Group:   System Environment/Base
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description extras-sysctl
Sysctl support in the OSR cluster

%package extras-syslog
Version: 0.1
Release: 8
Requires: comoonics-bootimage >= 1.4-27
Summary: Syslog implementation for osr
Group:   System Environment/Base

%description extras-syslog
Syslog implementation for osr. Supports syslog classic, syslog-ng, rsyslog (See listfiles-syslog)

%package listfiles-all
Version: 0.1
Release: 15
Requires: comoonics-bootimage >= 1.4-55
Group:   System Environment/Base
Summary: OSR listfilesfiles for all distributions 
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description listfiles-all
OSR Listfiles that are only relevant for all linux distributions

%package listfiles-rhel
Version: 0.1
Release: 7
Requires: comoonics-bootimage >= 1.3-36
Requires: /etc/redhat-release
Requires: comoonics-bootimage-listfiles-all
Requires: comoonics-cluster-tools-py
Group: System Environment/Base
Summary: Extrafiles for RedHat Enterprise Linux 
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description listfiles-rhel
OSR extra files that are only relevant for RHEL Versions

%package listfiles-fedora
Version: 0.1
Release: 10
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
Release: 6
Requires: comoonics-bootimage-listfiles-fedora
Group: System Environment/Base
Summary: Extrafiles for Fedora Core NFS support 
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description listfiles-fedora-nfs
OSR extra files that are only relevant for Fedora Versions and nfs support

%package listfiles-rhel4
Version: 0.1
Release: 3
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
Release: 6
Requires: comoonics-bootimage >= 1.4-55
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
Release: 7
Requires: comoonics-bootimage >= 1.3-37
Requires: /etc/SuSE-release
Requires: comoonics-bootimage-listfiles-all
Group: System Environment/Base
Summary: Extrafiles for Novell SuSE Enterprise Server
Conflicts: comoonics-bootimage-listfiles-rhel 
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description listfiles-sles
OSR extra files that are only relevant for Novell SLES 10

%package listfiles-sles10
Version: 0.1
Release: 4
Requires: comoonics-bootimage >= 1.4-28
Requires: /etc/SuSE-release
Requires: comoonics-bootimage-listfiles-sles
Group: System Environment/Base
Summary: Extrafiles for Novell SuSE Enterprise Server 10
Conflicts: comoonics-bootimage-listfiles-rhel 
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description listfiles-sles10
OSR extra files that are only relevant for Novell SLES 10

%package listfiles-sles11
Version: 0.1
Release: 7
Requires: comoonics-bootimage >= 1.4-27
Requires: /etc/SuSE-release
Requires: comoonics-bootimage-listfiles-sles
Group: System Environment/Base
Summary: Extrafiles for Novell SuSE Enterprise Server
Conflicts: comoonics-bootimage-listfiles-rhel 
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description listfiles-sles11
OSR extra files that are only relevant for Novell SLES 11

%package listfiles-fenceacksv-plugins
Version: 0.1
Release: 4
Requires: comoonics-bootimage >= 1.3-20
Requires: comoonics-cs-sysreport-templates
Requires: comoonics-fenceacksv-py
Requires: comoonics-fenceacksv-plugins-py
Summary: Extrafiles for plugins in fenceacksv
Group: System Environment/Server
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description listfiles-fenceacksv-plugins
OSR extrafiles for plugins in fenceacksv.

%package listfiles-syslogd
Version: 0.1
Release: 3
Requires: comoonics-bootimage-extras-syslog
Summary: Syslog listfiles for syslog classic
Group:   System Environment/Base
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description listfiles-syslogd
Syslog listfiles for syslog classic

%package listfiles-rsyslogd
Version: 0.1
Release: 4
Requires: comoonics-bootimage-extras-syslog
Summary: Syslog listfiles for the rsyslog daemon
Group:   System Environment/Base
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description listfiles-rsyslogd
Syslog listfiles for rsyslog daemon

%package listfiles-syslog-ng
Version: 0.1
Release: 2
Requires: comoonics-bootimage-extras-syslog
Summary: Syslog listfiles for the syslog-ng daemon
Group:   System Environment/Base
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description listfiles-syslog-ng
Syslog listfiles for syslog-ng daemon

%package listfiles-fencelib
Version: 0.1
Release: 1
Requires: comoonics-bootimage
Summary: Listfiles for Fencelibs
Group:   System Environment/Base
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description listfiles-fencelib
Listfiles for the fencelibs to be imported in the bootimage.


%package listfiles-fencexvm
Version: 0.1
Release: 1
Requires: comoonics-bootimage
Summary: Listfiles for fence_xvm
Group:   System Environment/Base
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description listfiles-fencexvm
Listfiles for the fence_xvm agent to be imported in the bootimage.

%package compat
Version: 0.1
Release: 3
Requires: comoonics-bootimage >= 1.3-1
Summary: Files needed for compatibility to 1.2 releases
Group:   System Environment/Base
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description compat
OSR files needed for the compatibility to 1.2 releases

%package fenceacksv
Version: 0.3
Release: 12
Requires: comoonics-fenceacksv-py
Requires: comoonics-bootimage >= 1.4-51
Requires: comoonics-tools-py
Summary: The Fenceackserver is a service for last resort actions
Group:   System Environment/Servers
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description fenceacksv
The Fenceackserver is a service for last resort actions

%package fenceclient-ilo
Version: 0.1
Release: 20
Summary: An alternative fence client for ilo cards of HP servers.
Group:   System Environment/Base
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description fenceclient-ilo
An alternative fence client for ilo cards of HP servers.

%package fenceclient-ilomp
Version: 0.1
Release: 3
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
install -d -m 755 $RPM_BUILD_ROOT/%{CONFIGDIR}/bootimage-chroot/files.initrd.d
install -d -m 755 $RPM_BUILD_ROOT/%{CONFIGDIR}/bootimage-chroot/rpms.initrd.d
install -m644 %{FENCEACKSV_SOURCE}/files-fenceacksv.list $RPM_BUILD_ROOT/%{CONFIGDIR}/bootimage-chroot/files.initrd.d/fenceacksv.list
install -m644 %{FENCEACKSV_SOURCE}/rpms-fenceacksv.list $RPM_BUILD_ROOT/%{CONFIGDIR}/bootimage-chroot/rpms.initrd.d/fenceacksv.list
# install -m640 %{FENCEACKSV_SOURCE}/fenceacksv-config.sh $RPM_BUILD_ROOT/%{SYSCONFIGDIR}/fenceacksv

# Files for fence-clients (ilo)
install -d -m 755 $RPM_BUILD_ROOT/%{FENCECLIENTS_DIR}
install -d -m 755 $RPM_BUILD_ROOT/%{FENCECLIENTS_DOC}
install -m755 %{FENCECLIENTS_SOURCE}/fence_ilo.py  $RPM_BUILD_ROOT/%{FENCECLIENTS_DIR}/fence_ilo
install -d -m 755 $RPM_BUILD_ROOT/%{CONFIGDIR}/bootimage/rpms.initrd.d
install -d -m 755 $RPM_BUILD_ROOT/%{CONFIGDIR}/bootimage/pre.mkinitrd.d
install -d -m 755 $RPM_BUILD_ROOT/%{CONFIGDIR}/bootimage/post.mkinitrd.d
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
	services="cman gfs qdiskd"
else
	services="cman gfs qdiskd"
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
%attr(0755, root, root) %{APPDIR}/com-chroot
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
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/sles11/boot-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/sles11/hardware-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/sles11/network-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/fedora/boot-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/fedora/gfs-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/fedora/hardware-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/fedora/network-lib.sh

%dir %{CONFIGDIR}/bootimage-chroot
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage-chroot/files.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage-chroot/rpms.list
%dir %{CONFIGDIR}/bootimage-chroot/files.initrd.d
%dir %{CONFIGDIR}/bootimage-chroot/rpms.initrd.d

%config(noreplace) %attr(0644, root, root) %{CONFIGDIR}/comoonics-bootimage.cfg
%config(noreplace) %attr(0644, root, root) %{CONFIGDIR}/querymap.cfg

%doc %attr(0644, root, root) CHANGELOG

%files compat
%config(noreplace) %attr(0644, root, root) %{SYSCONFIGDIR}/comoonics-chroot

%files extras-osr
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/osr-lib.sh
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/post.mkinitrd.d/01-create-mapfiles.sh

%files extras-network
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/vlan.list

%files extras-nfs
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/nfs-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/rhel5/nfs-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/fedora/nfs-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/sles10/nfs-lib.sh
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/nfs.list

%files extras-ocfs2
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/ocfs2-lib.sh
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/ocfs2.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/ocfs2.list

%files extras-md
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/mdadm.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/mdadm.list

%files extras-dm-multipath

%files extras-dm-multipath-rhel
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel/dm_multipath.list

%files extras-dm-multipath-sles
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/sles/dm_multipath.list

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

%files extras-syslog
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/syslog-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/templates/syslog.conf
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/templates/rsyslogd.conf
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/templates/syslog-ng.conf

%files listfiles-all
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/basefiles.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/filters.list
%dir %{CONFIGDIR}/bootimage/files.initrd.d
%dir %{CONFIGDIR}/bootimage/rpms.initrd.d
%dir %{CONFIGDIR}/bootimage/filters.initrd.d
%dir %{CONFIGDIR}/bootimage/pre.mkinitrd.d
%dir %{CONFIGDIR}/bootimage/post.mkinitrd.d
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
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/filters.initrd.d/empty.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/filters.initrd.d/kernel.list
%config %attr(0755, root, root) %{CONFIGDIR}/bootimage/pre.mkinitrd.d/00-cdsl-check.sh
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/post.mkinitrd.d/02-create-cdsl-repository.sh
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
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel/base.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel/comoonics.list
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
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/sles/base.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/sles/comoonics.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/sles/hardware.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/sles/empty.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/sles/network.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/sles/python.list

%files listfiles-sles10
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/sles10/base.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/sles10/python.list

%files listfiles-sles11
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/sles11/base.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/sles11/python.list

%files listfiles-fedora
%dir %{CONFIGDIR}/bootimage/files.initrd.d/fedora
%dir %{CONFIGDIR}/bootimage/rpms.initrd.d/fedora
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/fedora/base.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/fedora/configs.list
#%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/fedora/comoonics.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/fedora/network.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/fedora/base.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/fedora/hardware.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/fedora/python.list

%files listfiles-fedora-nfs
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/fedora/nfs.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/fedora/network.list

%files listfiles-fenceacksv-plugins
%config %attr(0644, root, root) %dir %{CONFIGDIR}/bootimage-chroot/rpms.initrd.d/fenceacksv-plugins.list

%files listfiles-syslogd
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/syslogd.list

%files listfiles-rsyslogd
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/rsyslogd.list

%files listfiles-syslog-ng
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/syslog-ng.list

%files listfiles-fencelib
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/fencedeps.list

%files listfiles-fencexvm
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/fencexvm.list

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
* Wed Sep 01 2010 Marc Grimme <grimme@atix.de> 1.4-63
- boot-scripts/boot-lib/etc/chroot-lib.sh
  - extract_installed_rpm
    - pass filters raw unquoted
    - copy file only if it does not already exist
  - get_filelist_from_installed_rpm
    - pass filters raw unquoted
  - extract_all_rpms
    - read from file unquoted as raw
    - pass filters raw unquoted
  - get_filelist_from_rpms
    - read from file unquoted as raw
    - pass filters raw unquoted
  - resolve_file
    - read from file unquoted as raw
- boot-scripts/boot-lib/etc/clusterfs-lib.sh
  - clusterfs_auto_syslog
    - changed the default syslogfilter to be clean
- boot-scripts/boot-lib/linuxrc.generic.sh
  - added no_klog option
  - spread copying of logs to two steps
* Wed Sep 01 2010 Marc Grimme <grimme@atix.de> 1.4-62
- boot-scripts/etc/rhel4/gfs-lib.sh:
  -gfs_getdefaults:
    - moved cluster_getdefaults here because for RHEL5 we need localflocks
- boot-scripts/etc/sles10|11/boot-lib.sh
  - sles10|11_PrepareHalt:
    - unset KMSG to get messages on console
- boot-scripts/etc/boot-lib.sh
  - initHaltProcess
    - new function to integrate setup of halt environment before we start with it.
- boot-scripts/etc/gfs-lib.sh
  - gfs_getdefaults
    - added localflocks to standard gfs mountoptions
- boot-scripts/com-realhalt.sh
  - added initHaltProcess instead of initEnv
* Thu Aug 26 2010 Marc Grimme <grimme@atix.de> 1.4-61
- boot-scripts/com-halt.sh
  - be sure that /proc and /sys are mounted
- boot-scripts/com-realhalt.sh
  - also copy /dev/console to chroot
* Wed Aug 18 2010 Marc Grimme <grimme@atix.de> 1.4-60
- boot-scripts/linuxrc.generic.sh
  - remvoed setHWClock
- boot-scripts/etc/gfs-lib.sh  boot-scripts/etc/rhel5/gfs-lib.sh
  - gfs_services_start added setHWClock
- boot-scripts/etc/ext3-lib.sh
  - ext3_fsck_needed bug fixed
- boot-scripts/etc/errors.sh
  - added an errormessage when filesystem cannot be mounted.
* Thu Aug 12 2010 Marc Grimme <grimme@atix.de> 1.4-59
- boot-scripts/etc/hardware-lib.sh lvm_check():
  - fixed bug with error message when there is no lvm device
- boot-scripts/com-realhalt.sh
  - check for the existence of /dev/initctl being what ever it is not a file as before.
- manage_chroot.sh
  - (un)patch_files()
    - removed errormessage when there is either not the initscript searched for or no patches are existent
* Wed Aug 11 2010 Marc Grimme <grimme@atix.de> 1.4-58
- boot-scripts/etc/std-lib.sh
  - exec_ordered_list: added exitonerror. So that this funktion will return with an error if errors occure
- boot-scripts/etc/hardware-lib.sh
  - usb_drivers will be loaded silently
- manage_chroot
  - no errormessage if no patches are available
- create-gfs-initrd-generic.sh
  - honor error caused from exec_ordered_list
* Fri Aug 06 2010 Marc Grimme <grimme@atix.de> 1.4-57
- boot-scripts/etc/gfs-lib.sh
  - force the creation of /var/run/lvm needed since RHEL5.5
- boot-scripts/etc/std-lib.sh
  - removed some unsuccessful experiments in exec_local
- boot-scripts/etc/{distribution}/network-lib.sh
  - fixed bug when detecting network interface properties consisting of "
- boot-scripts/etc/rhel5/gfs-lib.sh
  - stop clvmd and let it be started during init process
- boot-scripts/linuxrc
  - create /dev/fd so in order to remove some warnings
* Fri Jul 09 2010 Marc Grimme <grimme@atix.de> 1.4-56
- reverted console redirection back to using exec
* Wed Jul 07 2010 Marc Grimme <grimme@atix.de> 1.4-55
- boot-scripts
  - etc/bashrc/issue
    - Added command lasterror, lastcommand, errors
  - etc/boot-lib.sh,chroot-lib.sh
    - moved build_chroot to chroot-lib.sh
  - etc/clusterfs-lib.sh
    - fixed bug in clusterfs_mount where options where added to the mountcmd after each run through 
      mounttimes
  - etc/errors
    - reworked the errors to make use of errors, output and command being stored by exec_local
    - rewrote errors
  - etc/hardware-lib.sh
    - dev_start: moved the creation of fd devices up
  - etc/repository-lib.sh
    - added function repository_store_parameters and repository_del_parameters being used by exec_local
    - removed that the repository_values are stored in the environment (obsolete and not used)
  - etc/stdfs-lib.sh
    - is_same_inode: dropping error messages
  - etc/std-lib.sh
    - exec_local: better output redirection and storage of command outputs to be used later by user
  - linuxrc
    - removed obsolete redirection
    - create /dev/fd in the first place to remove a typo
  - linuxrc.generic.sh
    - errormsg reworked
    - reset nodeid/name if set in breakp shell
    - moved stopping of syslog down
- create-gfs-initrd-generic.sh
  - speed up copy of kernel modules in one run using cpio --pass-through instead of tar and for clause
* Tue Jun 29 2010 Marc Grimme <grimme@atix.de> 1.4-54
- etc/clusterfs-lib.sh
  - getClusterParam: moved the "clutype" query as last without parameter validation so that 
    all parameters are at least queried by the cluster
  - cc_get_valid_params, clusterfs_get_valid_params moved rootfs to cc_get_valid_params
 - etc/std-lib.sh
  - getParameters: changed default from rootfs to cluster query
- linuxrc.generic.sh: moved killing of syslog down
- create-gfs-initrd-generic.sh: long options to tar
* Fri Jun 25 2010 Marc Grimme <grimme@atix.de> 1.4-53
- linuxrc.generic.sh: upstream move. Calling *_get_valid_params for either clusterparams and fsparams.
- std-lib.sh.sourceLibs: taking predefined clutype in repository also into account.
- clusterfs-lib.sh:
  - getCluType: clutype will be requeried if either empty or query returns failure.
  - getClusterParameter: made code better readable and more errors to be detected
  - cc/clusterfs_get_valid_params: new function to return all valid cluster parameters
  - cc/clusterfs_is_valid_param: checks if the given param is valid
- ext3/ocfs2/nfs-lib.sh:
  - added ext3/ocfs2/nfs_get
- querymap.cfg: added clustertype query
* Thu Jun 17 2010 Marc Grimme <grimme@atix.de> 1.4-52
- linuxrc.generic.sh: fixed a bug the a vg is not activated if a fs is 
      additionally mounted.
- hardware-lib.sh: fixed a bug in lvm_check
* Thu Jun 08 2010 Marc Grimme <grimme@atix.de> 1.4-51
- linuxrc.generic.sh: add scsi_failover to restart_scsi_newroot
- boot-lib.sh: check_mtab: upstream with tools
- stdfs-lib.sh: is_mounted: fixed but in is_mounted with untrimmed mountpoints
- manage_chroot.sh: added mount_cdsl, status_cdsl, umount_cdsl
* Thu May 27 2010 Marc Grimme <grimme@atix.de> 1.4-50
- create_initrd_generic.sh: fixed bug that mkinitrd will temporarily aquire much space where initrd should be created. Will now be in /tmp.
- boot-scripts/etc/hardware-lib.sh: added hp_ilo to usb drivers to support Remote Console of HP ILO.
* Tue May 18 2010 Marc Grimme <grimme@atix.de> 1.4-49
- boot-scripts/etc/gfs-lib.sh: lvm activation only for the vg in question, +scsi_restart_newroot
- boot-scripts/etc/hardware-lib.sh: iscsi setup moved here, introduced scsi_restart_newroot, lvm action only for the vg in question
- boot-scripts/linux.generic.sh: removed iscsi setup
- boot-scripts/etc/rhel5/gfs-lib.sh: reviewed restart of clvmd and umount of /proc
- boot-scripts/etc/ocfs2-lib.sh: reviewed umount of /proc
- boot-scripts/etc/nfs-lib.sh: reviewed umount of /proc
* Fri Apr 23 2010 Marc Grimme <grimme@atix.de> 1.4-48
- boot-scripts/etc/ocfs2-lib.sh: Umounting ../proc in restart_newroot
- boot-scripts/etc/hardware-lib.sh: Fixed bug with udevd not being started
- boot-scripts/linuxrc.generic.sh: Fixed bug that xtab was not created.
* Tue Apr 13 2010 Marc Grimme <grimme@atix.de> 1.4-47
- fixed bug with rdac
- added support for scsi_failover, scsi_driver bootparameter
* Mon Mar 29 2010 Marc Grimme <grimme@atix.de> 1.4-46
- gfs-lib.sh: fixed bug in gfs_get_clustername
- stdfs-lib.sh: copy_filelist copies only changed files  
* Mon Mar 08 2010 Marc Grimme <grimme@atix.de> 1.4-45
- first version for comoonics-4.6-rc1 
* Tue Feb 23 2010 Marc Grimme <grimme@atix.de> 1.4-44
- Bugfix with readonly filesystem
* Tue Feb 23 2010 Marc Grimme <grimme@atix.de> 1.4-43
- Fixed bug with rdac multipath
- Fixed bug with parameter detection
- added bonding and vlans for sles
* Sun Feb 21 2010 Marc Grimme <grimme@atix.de> 1.4-42
- Moved the querymap from extras-osr to here
- Fixed bug in copy of kernel modules
- SLES10/SLES11 support for bonding and vlans
* Tue Feb 15 2010 Marc Grimme <grimme@atix.de> 1.4-41
- fixed com-halt.sh to remount / and chroot rw if it was mounted ro
- added cman_tool leave force if cman_tool leave does not work
- Rhel4 devicemapper drivers changed
- com-realhalt.sh removed the fenced -c and fence_tool if needed it should be moved to gfs relevant environment.
* Mon Feb 15 2010 Marc Grimme <grimme@atix.de> 1.4-40
- removed repository_clean in linuxrc in order to allow parts being precreated.
* Fri Feb 12 2010 Marc Grimme <grimme@atix.de> 1.4-39
- fixed bug with cdsl environment not being detected when other then cdls.local and cluster/cdsl.
* Tue Feb 09 2010 Marc Grimme <grimme@atix.de> 1.4-38
- fixed typo in comoonics-bootimage.cfg
* Fri Feb 05 2010 Marc Grimme <grimme@atix.de> 1.4-37
- removed dep to osr-lib in clusterfs-lib
* Fri Feb 05 2010 Marc Grimme <grimme@atix.de> 1.4-36
- More on osr-lib.sh
- Added pre and postscripts for mkinitrd
- RHEL4 Backport
-  review
- Better logging
- NIC Properties
* Thu Oct 08 2009 Marc Grimme <grimme@atix.de> 1.4-35
- Fixed a bug in halt/reboot with sles10
- Removed those annoying help messages when breaking. This will only come when typing help.
* Tue Oct 01 2009 Marc Grimme <grimme@atix.de> 1.4-34
- Added com-chroot
- Fixed Bug #365 where bootprocess hangs when using special kernels.
- Minor bugfixes in halt and detection of halt
* Mon Sep 28 2009 Marc Grimme <grimme@atix.de> 1.4-33
- New finalized version
- Some typos
- Exitrd functions and functionality
* Thu Sep 24 2009 Marc Grimme <grimme@atix.de> 1.4-32
- Added more functions to seperate gfs from clusterfs-lib.
- Prepared deps to integrate osr as second cluster lib.
- Bugfix for calling syslog without - but _ (syslog-ng => syslog_ng)
* Tue Sep 16 2009 Marc Grimme <grimme@atix.de> 1.4-31
- Removed all references to com-queryclusterconf anywhere but gfs-lib.sh
* Tue Sep 15 2009 Marc Grimme <grimme@atix.de> 1.4-30
- Bugfixes in syslog library and clusterfs-lib
* Thu Sep 10 2009 Marc Grimme <grimme@atix.de> 1.4-29
- Fixed is_mounted and implemented get_dep_filesystems
- Changed com-realhalt.sh to umount every fs depending on COM_OLDROOT.
* Thu Sep 10 2009 Marc Grimme <grimme@atix.de> 1.4-28
- Small typos and bugfixes
* Wed Sep 09 2009 Marc Grimme <grimme@atix.de> 1.4-27
- Backports from dracut (repository-lib.sh)
- Prepared generic syslog implementation syslog/rsyslog/syslog-ng 
* Wed Aug 19 2009 Marc Grimme <grimme@atix.de> 1.4-26
- Removed dep comoonics-cs-py that shouldn't be needed. comoonics-cluster-py requires comoonics-cs-py.
* Wed Aug 19 2009 Marc Grimme <grimme@atix.de> 1.4-25
- Fix second occurance of cc_auto_syslog (Bug 358)
* Tue Aug 11 2009 Marc Grimme <grimme@atix.de> 1.4-24
- Fix for bug #356 Device changes not applied in chroot environment when chroot on local disk
- Fix for bug #358 Initramfs consumes more and more during runtime. Which can lead to no free memory   
- Upstream patches for glusterfs-lib.sh /mdadm (Gordan Bobic)
- Other patches
* Mon Jul 06 2009 Marc Grimme <grimme@atix.de> 1.4-23
- added Fedora 11 support
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
- and rootfs and clutype in 
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
-  will only rebuild if needed
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

%changelog extras-osr
* Wed Jul 07 2010 Marc Grimme <grimme@atix.de> 0.1-4
- added GPL License
* Mon Mar 08 2010 Marc Grimme <grimme@atix.de> 0.1-3
- first version for comoonics-4.6-rc1 
* Sun Feb 21 2010 Marc Grimme <grimme@atix.de> - 0.1-2
- moved querymap from here to main package
- only set osr cluster_conf if the file really exists 
* Thu Sep 24 2009 Marc Grimme <grimme@atix.de> - 0.1-1
- first release

%changelog extras-rdac-multipath
* Mon Mar 08 2010 Marc Grimme <grimme@atix.de> 0.1-3
- first version for comoonics-4.6-rc1 
* Fri Dec 05 2008 Marc Grimme <grimme@atix.de> - 0.1-2
- First version on the way to rpmlint BUG#290
* Fri Sep 14 2007 Marc Grimme <grimme@atix.de> - 0.1-1
- first release

%changelog extras-xen
* Mon Mar 08 2010 Marc Grimme <grimme@atix.de> 0.1-6
- first version for comoonics-4.6-rc1 
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
* Wed Jul 07 2010 Marc Grimme <grimme@atix.de> 0.1-11
- iscsi-lib.sh:
  - removed an obsolete touch
* Thu Jun 08 2010 Marc Grimme <grimme@atix.de> 0.1-10
- iscsi-lib.sh: 
     - start_iscsi: start being able in chroot
     - restart_iscsi_newroot: just restart services. 
* Thu Jun 08 2010 Marc Grimme <grimme@atix.de> 0.1-9
- iscsi-lib.sh: bugfix and listfiles
* Tue May 18 2010 Marc Grimme <grimme@atix.de> 0.1-8
- boot-scripts/etc/iscsi-lib.sh: support for multiple nics in the same network (multipathing), iscsi_restart
* Mon Mar 08 2010 Marc Grimme <grimme@atix.de> 0.1-7
- first version for comoonics-4.6-rc1 
* Tue Aug 11 2009 Marc Grimme <grimme@atix.de> - 0.1-6
- Upstream patches for iscsi owerwriting initiator <rootsource name="iscsi://<target-ip>:<port>/<Initiatorname>"/>
  (Michael Peus)
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
* Mon Mar 08 2010 Marc Grimme <grimme@atix.de> 0.1-6
- first version for comoonics-4.6-rc1 
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
* Wed Aug 11 2010 Marc Grimme <grimme@atix.de> 0.1-17
- boot-image/etc/sles10/nfs-lib.sh
  - initial revision (not start portmap)
- boot-image/etc/nfs-lib.sh
  - mount rpc_pipefs with chroot so that cdsl environment can be resolved.
* Fri Jun 25 2010 Marc Grimme <grimme@atix.de> 0.1-16
- ext3/ocfs2/nfs-lib.sh:
  - added ext3/ocfs2/nfs_get
* Thu Jun 08 2010 Marc Grimme <grimme@atix.de> 0.1-15
- fixed bug #378 function nfs_get_mountopts
* Mon Mar 08 2010 Marc Grimme <grimme@atix.de> 0.1-15
- first version for comoonics-4.6-rc1 
* Tue Sep 29 2009 Marc Grimme <grimme@atix.de> - 0.1-14
- removed deps that are for the distfiles
* Tue Aug 11 2009 Marc Grimme <grimme@atix.de> - 0.1-12
- nfs4 for RHEL5
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
syslog
%changelog extras-ocfs2
* Thu Aug 26 2010 Marc Grimme <grimme@atix.de> 0.1-10
- boot-scripts/etc/ocfs2-lib.sh ocfs2_init be sure to 
     mount /sys/kernel/config only if it is not already mounted.
* Fri Jun 25 2010 Marc Grimme <grimme@atix.de> 0.1-9
- ext3/ocfs2/nfs-lib.sh:
  - added ext3/ocfs2/nfs_get
* Thu Jun 08 2010 Marc Grimme <grimme@atix.de> 0.1-8
- fixed bug #378 function iscsi_get_mountopts
* Mon Mar 08 2010 Marc Grimme <grimme@atix.de> 0.1-7
- first version for comoonics-4.6-rc1 
* Thu Sep 10 2009 Marc Grimme <grimme@atix.de> 0.1-6
- Reuncomented the generation of /etc/ocfs2/cluster.conf in chroot.
* Thu Sep 10 2009 Marc Grimme <grimme@atix.de> 0.1-5
- Small typos
* Wed Sep 09 2009 Marc Grimme <grimme@atix.de> 0.1-4
- Fixed return code bug when joining cluster.
- Added listfile to be sure to get o2cb_ctl in
* Fri Mar 27 2009 Marc Grimme <grimme@atix.de> 0.1-3
- Added ocfs2_get_drivers

%changelog extras-md
* Mon Mar 08 2010 Marc Grimme <grimme@atix.de> 0.1-2
- first version for comoonics-4.6-rc1 
* Sun Feb 08 2009 Marc Grimme <grimme@atix.de> - 0.1-1
  initial revision (Thanks to Gordan)
  
%changelog extras-dm-multipath
* Mon Mar 08 2010 Marc Grimme <grimme@atix.de> 0.1-4
- first version for comoonics-4.6-rc1 
* Tue Jan 29 2009 Marc Grimme <grimme@atix.de> - 0.1-3
- introduced the changelog

%changelog extras-dm-multipath-rhel
* Mon Mar 08 2010 Marc Grimme <grimme@atix.de> 0.1-3
- first version for comoonics-4.6-rc1 
* Tue Jan 29 2009 Marc Grimme <grimme@atix.de> - 0.1-2
- introduced the changelog

%changelog extras-dm-multipath-sles
* Mon Mar 08 2010 Marc Grimme <grimme@atix.de> 0.1-2
- first version for comoonics-4.6-rc1 
* Tue Jan 29 2009 Marc Grimme <grimme@atix.de> - 0.1-1
- initial revision

%changelog extras-dm-multipath-fedora
* Mon Mar 08 2010 Marc Grimme <grimme@atix.de> 0.1-3
- first version for comoonics-4.6-rc1 
* Tue Jan 29 2009 Marc Grimme <grimme@atix.de> - 0.1-2
- introduced the changelog

%changelog extras-glusterfs
* Fri Jun 25 2010 Marc Grimme <grimme@atix.de> 0.1-6
- glusterfs-lib.sh: added glusterfs_get
* Mon Mar 08 2010 Marc Grimme <grimme@atix.de> 0.1-5
- first version for comoonics-4.6-rc1 
* Tue Aug 11 2009 Marc Grimme <grimme@atix.de> - 0.1-4
- Upstream patches from Gordan Bobic
* Mon Mar 30 2009 Marc Grimme <grimme@atix.de> - 0.1-3
- Extended Bug #340 update mode for mkinitrd and adding/removing kernels with glusterfs
* Tue Jan 29 2009 Marc Grimme <grimme@atix.de> - 0.1-1
- initial revision (thanks to Gordan)

%changelog extras-sysctl
* Mon Mar 08 2010 Marc Grimme <grimme@atix.de> 0.1-2
- first version for comoonics-4.6-rc1 
* Tue Jan 29 2009 Marc Grimme <grimme@atix.de> - 0.1-1
- initial revision

%changelog extras-syslog
* Wed Sep 01 2010 Marc Grimme <grimme@atix.de> 0.1-8
- boot-scripts/boot-lib/etc/syslog-lib.sh
  - syslogd_config
    - no explicit debug filter
  - syslogd_start
    - add parameter no_klog
  - rsyslogd_start
    - add parameter no_klog
* Tue Jun 29 2010 Marc Grimme <grimme@atix.de> 0.1-7
- etc/syslog-lib.sh default_syslogconf: right name of rsyslog.conf
- etc/templates/rsyslogd.conf: moved rsyslog.conf to rsyslogd.conf
* Fri Jun 25 2010 Marc Grimme <grimme@atix.de> 0.1-6
- syslog-lib.sh.*_start: calling exec_local if no chroot given instead of nothing.
* Mon Mar 08 2010 Marc Grimme <grimme@atix.de> 0.1-5
- first version for comoonics-4.6-rc1 
* Thu Sep 24 2009 Marc Grimme <grimme@atix.de> - 0.1-4
- Small bugfixes (syslog-ng => syslog_ng when calling functions)
- Some better errormessages
* Tue Sep 15 2009 Marc Grimme <grimme@atix.de> - 0.1-2
- Added templates
- Fixed severral syslog relevant bugs
* Wed Sep 09 2009 Marc Grimme <grimme@atix.de> - 0.1-1
- initial revision

%changelog listfiles-all
* Wed Aug 10 2010 Marc Grimme <grimme@atix.de> 0.1-15
- pre.mkinitrd.d/00-cdsl-check.sh
  - checks if cdsl environment is working
* Wed Jul 07 2010 Marc Grimme <grimme@atix.de> 0.1-14
- filters.initrd.d/kernel.list: filter out /lib/modules/*/source and build
* Mon Mar 08 2010 Marc Grimme <grimme@atix.de> 0.1-13
- first version for comoonics-4.6-rc1 
* Sun Feb 21 2010 Marc Grimme <grimme@atix.de> - 0.1-12
- Moved the querymap into files.initrd.d/comoonics.list
* Mon Feb 15 2010 Marc Grimme <grimme@atix.de> - 0.1-11
- removed bug in 02-create-cdsl-repository.sh where file where created at the wrong destination.
* Tue Feb 09 2010 Marc Grimme <grimme@atix.de> - 0.1-10
- added 02-create-cdsl-repository.sh in the post.mkinitrd.d section to fix bug #370 
  and support rootfilesystems with different cdsl environments  
* Mon Sep 28 2009 Marc Grimme <grimme@atix.de> - 0.1-9
- Finalized version with all changes
* Thu Sep 24 2009 Marc Grimme <grimme@atix.de> - 0.1-8
- Removed the /etc/rc.d/init.d dep.
* Thu Sep 10 2009 Marc Grimme <grimme@atix.de> - 0.1-7
- Moved dep to other files in order to have less warnings
* Wed Mar 25 2009 Marc Grimme <grimme@atix.de> - 0.1-5
- Implemented global filters
* Tue Jan 29 2009 Marc Grimme <grimme@atix.de> - 0.1-4
- Updated the listfiles to latest deps
* Fri Dec 05 2008 Marc Grimme <grimme@atix.de> - 0.1-2
- First version on the way to rpmlint BUG#290
* Thu Aug 14 2008 Marc Grimme <grimme@atix.de - 0.1-1
  - initial revision 

%changelog listfiles-rhel
* Mon Mar 08 2010 Marc Grimme <grimme@atix.de> 0.1-5
- first version for comoonics-4.6-rc1 
* Mon Sep 28 2009 Marc Grimme <grimme@atix.de> - 0.1-4
- Finalized version with all changes
* Thu Sep 10 2009 Marc Grimme <grimme@atix.de> - 0.1-3
- Moved dep to other files in order to have less warnings
* Fri Dec 05 2008 Marc Grimme <grimme@atix.de> - 0.1-2
- First version on the way to rpmlint BUG#290
* Thu Aug 14 2008 Marc Grimme <grimme@atix.de> - 0.1-1
  - initial revision 

%changelog listfiles-rhel4
* Mon Mar 08 2010 Marc Grimme <grimme@atix.de> 0.1-3
- first version for comoonics-4.6-rc1 
* Fri Dec 05 2008 Marc Grimme <grimme@atix.de> - 0.1-2
- First version on the way to rpmlint BUG#290
* Thu Aug 14 2008 Marc Grimme <grimme@atix.de> - 0.1-1
  - initial revision 

%changelog listfiles-rhel5
* Wed Jul 07 2010 Marc Grimme <grimme@atix.de> 0.1-7
- added MAKEDEV to base.list
* Mon Mar 08 2010 Marc Grimme <grimme@atix.de> 0.1-6
- first version for comoonics-4.6-rc1 
* Mon Sep 28 2009 Marc Grimme <grimme@atix.de> - 0.1-5
- Finalized version with all changes
* Tue Feb 24 2009 Marc Grimme <grimme@atix.de> - 0.1-4
- removed krb files in configs.list
* Tue Jan 29 2009 Marc Grimme <grimme@atix.de> - 0.1-3
- Removed and added more files
* Fri Dec 05 2008 Marc Grimme <grimme@atix.de> - 0.1-2
- First version on the way to rpmlint BUG#290
* Thu Aug 14 2008 Marc Grimme <grimme@atix.de> - 0.1-1
  - initial revision 

%changelog listfiles-sles
* Wed Aug 11 2010 Marc Grimme <grimme@atix.de> 0.1-8
- removed bootimage/rpms.initrd.d/sles/dm_multipath.list
* Mon Mar 08 2010 Marc Grimme <grimme@atix.de> 0.1-7
- first version for comoonics-4.6-rc1 
* Mon Sep 28 2009 Marc Grimme <grimme@atix.de> - 0.1-6
- Finalized version with all changes
* Thu Sep 10 2009 Marc Grimme <grimme@atix.de> - 0.1-5
- Additional deps
* Thu Sep 10 2009 Marc Grimme <grimme@atix.de> - 0.1-4
- Moved dep to other files in order to have less warnings
* Fri Dec 05 2008 Marc Grimme <grimme@atix.de> - 0.1-3
- First version on the way to rpmlint BUG#290
* Wed Sep 24 2008 Marc Grimme <grimme@atix.de> - 0.1-2
- Replaced dependency listfiles to listfiles-all in listfiles-sles
* Thu Aug 14 2008 Marc Grimme <grimme@atix.de - 0.1-1
  - initial revision 

%changelog listfiles-sles10
* Mon Mar 08 2010 Marc Grimme <grimme@atix.de> 0.1-4
- first version for comoonics-4.6-rc1 
* Thu Oct 08 2009 Marc Grimme <grimme@atix.de> - 0.1-3
- removed python-devel dep.
* Mon Sep 28 2009 Marc Grimme <grimme@atix.de> - 0.1-2
- Finalized version with all changes
* Wed Sep 16 2009 Marc Grimme <grimme@atix.de> - 0.1-1
- initial revision

%changelog listfiles-sles11
* Thu Aug 13 2010 Marc Grimme <grimme@atix.de> 0.1-7
- added libuuid1
* Thu Aug 12 2010 Marc Grimme <grimme@atix.de> 0.1-6
- added libblkid1
* Thu Aug 12 2010 Marc Grimme <grimme@atix.de> 0.1-5
- added rpms.initrd.d/base.list
* Mon Mar 08 2010 Marc Grimme <grimme@atix.de> 0.1-4
- first version for comoonics-4.6-rc1 
* Mon Feb 22 2010 Marc Grimme <grimme@atix.de> - 0.1-3
- added dep comoonics-bootimage-listfiles-sles.
* Mon Sep 28 2009 Marc Grimme <grimme@atix.de> - 0.1-2
- Finalized version with all changes
* Wed Sep 09 2009 Marc Grimme <grimme@atix.de> - 0.1-1
- initial revision

%changelog listfiles-fedora
* Mon Mar 08 2010 Marc Grimme <grimme@atix.de> 0.1-10
- first version for comoonics-4.6-rc1 
* Mon Sep 28 2009 Marc Grimme <grimme@atix.de> - 0.1-9
- Finalized version with all changes
* Thu Sep 10 2009 Marc Grimme <grimme@atix.de> - 0.1-8
- Moved dep to other files in order to have less warnings
* Wed Sep 09 2009 Marc Grimme <grimme@atix.de> - 0.1-7
- added comoonics listfile
* Mon Jul 06 2009 Marc Grimme <grimme@atix.de> - 0.1-6
- Fedora 11 Support
* Tue Feb 24 2009 Marc Grimme <grimme@atix.de> - 0.1-5
- removed krb files in configs.list
* Tue Jan 29 2009 Marc Grimme <grimme@atix.de> - 0.1-4
- introduced the changelog

%changelog listfiles-fedora-nfs
* Mon Mar 08 2010 Marc Grimme <grimme@atix.de> 0.1-6
- first version for comoonics-4.6-rc1 
* Mon Sep 28 2009 Marc Grimme <grimme@atix.de> - 0.1-5
- Finalized version with all changes
* Tue Aug 11 2009 Marc Grimme <grimme@atix.de> - 0.1-4
- Added a network list file for fedora (libidn)
* Tue Jan 29 2009 Marc Grimme <grimme@atix.de> - 0.1-3
- introduced the changelog

%changelog listfiles-syslogd
* Tue Jun 29 2010 Marc Grimme <grimme@atix.de> 0.1-3
- added a newline in the end to listfile
* Mon Mar 08 2010 Marc Grimme <grimme@atix.de> 0.1-2
- first version for comoonics-4.6-rc1 
* Wed Sep 09 2009 Marc Grimme <grimme@atix.de> - 0.1-1
- initial revision

%changelog listfiles-rsyslogd
* Wed Sep 01 2010 Marc Grimme <grimme@atix.de> 0.1-4
- system-cfs-files/rpms.initrd.d/rsyslog.list
  - only add binaries and libs nothing else
* Tue Jun 29 2010 Marc Grimme <grimme@atix.de> 0.1-3
- added a newline in the end to listfile
- right rpm rsyslog.
* Mon Mar 08 2010 Marc Grimme <grimme@atix.de> 0.1-2
- first version for comoonics-4.6-rc1 
* Wed Sep 09 2009 Marc Grimme <grimme@atix.de> - 0.1-1
- initial revision

%changelog listfiles-syslog-ng
* Mon Mar 08 2010 Marc Grimme <grimme@atix.de> 0.1-2
- first version for comoonics-4.6-rc1 
* Wed Sep 09 2009 Marc Grimme <grimme@atix.de> - 0.1-1
- initial revision

%changelog listfiles-fenceacksv-plugins
* Mon Mar 08 2010 Marc Grimme <grimme@atix.de> 0.1-5
- first version for comoonics-4.6-rc1 
* Fri Feb 12 2010 Marc Grimme <grimme@atix.de> - 0.1-4
- Removed comoonics-cs-py dep.

%changelog listfiles-fencelib
* Wed Jul 07 2010 Marc Grimme <grimme@atix.de> 0.1-1
- initial version 

%changelog listfiles-fencexvm
* Wed Jul 07 2010 Marc Grimme <grimme@atix.de> 0.1-1
- initial version 

%changelog fenceacksv
* Fri Aug 06 2010 Marc Grimme <grimme@atix.de> 0.3-12
- fenceacksv.sh:
  - status works also with ssh
- rpms-fenceacksv.list:
  - added RHEL4 deps for ssh
* Wed Jul 07 2010 Marc Grimme <grimme@atix.de> 0.3-11
- for ssh mode: using ssh keys found in /etc/ssh not its own ones
* Fri Jun 25 2010 Marc Grimme <grimme@atix.de> 0.3-10
- fenceacksv.sh: make the fenceackshell executable
* Wed Jun 16 2010 Marc Grimme <grimme@atix.de> - 0.3-9
- added support for running fenceacksv over sshd
* Mon Mar 08 2010 Marc Grimme <grimme@atix.de> - 0.3-8
- first version for comoonics-4.6-rc1 
* Mon Feb 15 2010 Marc Grimme <grimme@atix.de> - 0.3-7
- Upstream fixes.
* Fri Feb 12 2010 Marc Grimme <grimme@atix.de> - 0.3-6
- Fixed imports and errors during starting
- Added dep to comoonics-tools-py
* Fri Feb 12 2010 Marc Grimme <grimme@atix.de> - 0.3-5
- Removed deps to GetOpts. Imports.
* Tue Sep 29 2009 Marc Grimme <grimme@atix.de> - 0.3-4
- Removed deps and added comoonics-fenceacksv-py
* Tue Jul 01 2009 Marc Grimme <grimme@atix.de> - 0.3-3
- Fixed bug where logger was pathdependent
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
* Mon Mar 08 2010 Marc Grimme <grimme@atix.de> 0.1-19
- first version for comoonics-4.6-rc1 
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
# Revision 1.134  2010-09-01 15:33:34  marc
# - new version
#
# Revision 1.133  2010/09/01 15:24:19  marc
# new version
#
# Revision 1.132  2010/09/01 09:50:32  marc
# - new version
#
# Revision 1.131  2010/08/26 12:26:48  marc
# new version
#
# Revision 1.130  2010/08/19 09:24:34  marc
# new version for comoonics-bootimage-sles11-0.1-7
#
# Revision 1.129  2010/08/19 07:42:46  marc
# new versions
#
# Revision 1.128  2010/08/18 11:51:07  marc
# new version
#
# Revision 1.127  2010/08/12 13:04:17  marc
# added base.list.
#
# Revision 1.126  2010/08/12 07:42:04  marc
# new version of comoonics-bootimage
#
# Revision 1.125  2010/08/11 09:47:13  marc
# - new versions
#
# Revision 1.124  2010/08/06 13:33:14  marc
# new versions
#
# Revision 1.123  2010/08/06 13:29:13  marc
# - don't touch service clvmd
#
# Revision 1.122  2010/07/09 13:34:42  marc
# - reverted redirection back to using exec
#
# Revision 1.121  2010/07/08 08:39:37  marc
# new versions
#
# Revision 1.120  2010/06/30 07:04:04  marc
# new version
#
# Revision 1.119  2010/06/25 12:54:09  marc
# new versions for comooncis-bootimage, -extras-nfs/ocfs2/glusterfs/syslog, -fenceacksv
#
# Revision 1.118  2010/06/17 08:21:59  marc
# new versions
#
# Revision 1.117  2010/06/09 08:23:22  marc
# new versions
#
# Revision 1.116  2010/05/27 09:57:35  marc
# new versions 1.4-49, 1.4-50
#
# Revision 1.115  2010/04/23 10:23:53  marc
# new versions
#
# Revision 1.114  2010/03/11 10:31:23  marc
# comoonics-4.6-rc1
#
# Revision 1.113  2010/03/08 19:35:14  marc
# comoonics-4.6-rc1
#
# Revision 1.112  2010/02/16 10:07:15  marc
# new versions
#
# Revision 1.111  2010/02/09 21:45:19  marc
# new versions
#
# Revision 1.110  2010/02/07 20:35:13  marc
# - latest versions
#
# Revision 1.109  2009/10/08 07:59:23  marc
# - new version
#
# Revision 1.108  2009/10/07 12:08:30  marc
# new version
#
# Revision 1.107  2009/09/29 12:50:23  marc
# fenceacksv updates in order to obsolete comoonics-cs-py
#
# Revision 1.106  2009/09/28 14:51:19  marc
# new versions
#
# Revision 1.105  2009/09/28 14:40:37  marc
# new versions
#
# Revision 1.104  2009/08/25 12:38:33  marc
# new version
#
# Revision 1.103  2009/08/19 16:10:44  marc
# another fix for bug358
#
# Revision 1.102  2009/08/11 12:17:10  marc
# new versions
#
# Revision 1.101  2009/07/01 09:35:10  marc
# - fixed fenceacksv bug. new rpmversion 0.3-3
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
# added 
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
