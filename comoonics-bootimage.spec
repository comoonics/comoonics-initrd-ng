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

# $Id: comoonics-bootimage.spec,v 1.151 2011/02/28 14:27:29 marc Exp $
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

%define IMSD_SOURCE imsd
%define IMSD_DIR    /opt/atix/comoonics-imsd

%define FENCECLIENTS_SOURCE fencing/
%define FENCECLIENTS_DIR /opt/atix/comoonics-fencing
%define FENCECLIENTS_DOC /usr/share/doc/comoonics-fencing

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

Name: comoonics-bootimage
Summary: Scripts for creating an initrd in a OSR Cluster environment
Version: 1.4
BuildArch: noarch
Requires: comoonics-cluster-py >= 0.1-21
Requires: comoonics-bootimage-initscripts >= 1.4 
Requires: comoonics-bootimage-listfiles-all
Requires: comoonics-tools-py
#Conflicts:
Release: 83
Vendor: ATIX AG
Packager: ATIX AG <http://bugzilla.atix.de>
ExclusiveArch: noarch
URL:     http://www.atix.de/
Source:  http://www.atix.de/software/downloads/comoonics/comoonics-bootimage-%{version}.tar.gz
License: GPL
Group:   %{GROUPPARENT}/%{GROUPCHILDBASE}
Distribution: %{DISTRIBUTIONBASE}
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description
Scripts for creating an initrd in a OSR cluster environment

%package extras-osr
Version: 0.1
Release: 5
Requires: comoonics-bootimage >= 1.3-1
Summary: Extra for cluster configuration via osr
Group:   %{GROUPPARENT}/%{GROUPCHILDEXTRAS}
Distribution: %{DISTRIBUTIONEXTRAS}
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description extras-osr
Extra for cluster configuration via osr.

%package extras-network
Version: 0.1
Release: 3
Requires: comoonics-bootimage >= 1.3-1
Summary: Listfiles for special network configurations (vlan)
Group:   %{GROUPPARENT}/%{GROUPCHILDBASE}
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description extras-network
Extra listfiles for special network configurations

%package extras-nfs
Version: 0.1
Release: 21
Requires: comoonics-bootimage >= 1.4-81
Summary: Listfiles for nfs sharedroot configurations
Group:   %{GROUPPARENT}/%{GROUPCHILDBASE}
Distribution: %{DISTRIBUTIONBASE}
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot
Conflicts: comoonics-bootimage-extras-ocfs2

%description extras-nfs
Extra listfiles for nfs sharedroot configurations

%package extras-ocfs2
Version: 0.1
Release: 10
Requires: comoonics-bootimage >= 1.4
Summary: Listfiles for ocfs2 sharedroot configurations
Group:   %{GROUPPARENT}/%{GROUPCHILDBASE}
Distribution: %{DISTRIBUTIONBASE}
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot
Conflicts: comoonics-bootimage-extras-nfs

%description extras-ocfs2
Extra listfiles for ocfs2 sharedroot configurations

%package extras-md
Version: 0.1
Release: 2
Requires: comoonics-bootimage >= 1.3-46
Summary: Listfiles for md support
Group:   %{GROUPPARENT}/%{GROUPCHILDEXTRAS}
Distribution: %{DISTRIBUTIONEXTRAS}
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description extras-md
Extra listfiles for md in OSR configurations

%package extras-dm-multipath-rhel4
Version: 0.1
Release: 1
Requires: comoonics-bootimage >= 1.4-82
Requires: /etc/redhat-release
Requires: comoonics-bootimage-listfiles-rhel4
Summary: Listfiles for device mapper multipath OSR configurations for RHEL4
Group:   %{GROUPPARENT}/%{GROUPCHILDBASE}/%{GROUPCHILDRHEL4}
Distribution: %{DISTRIBUTIONBASE}
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot
Conflicts: comoonics-bootimage-extras-rdac-multipath
Obsoletes: comoonics-bootimage-extras-dm-multipath
Obsoletes: comoonics-bootimage-extras-dm-multipath-rhel

%description extras-dm-multipath-rhel4
Extra listfiles for device mapper multipath OSR configurations for RHEL4

%package extras-dm-multipath-rhel5
Version: 0.1
Release: 1
Requires: comoonics-bootimage >= 1.4-82
Requires: /etc/redhat-release
Requires: comoonics-bootimage-listfiles-rhel5
Summary: Listfiles for device mapper multipath OSR configurations for RHEL5
Group:   %{GROUPPARENT}/%{GROUPCHILDBASE}/%{GROUPCHILDRHEL5}
Distribution: %{DISTRIBUTIONBASE}
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot
Conflicts: comoonics-bootimage-extras-rdac-multipath
Obsoletes: comoonics-bootimage-extras-dm-multipath
Obsoletes: comoonics-bootimage-extras-dm-multipath-rhel

%description extras-dm-multipath-rhel5
Extra listfiles for device mapper multipath OSR configurations for RHEL5

%package extras-dm-multipath-rhel6
Version: 0.1
Release: 1
Requires: comoonics-bootimage >= 1.4-82
Requires: /etc/redhat-release
Requires: comoonics-bootimage-listfiles-rhel6
Summary: Listfiles for device mapper multipath OSR configurations for RHEL6
Group:   %{GROUPPARENT}/%{GROUPCHILDBASE}/%{GROUPCHILDRHEL6}
Distribution: %{DISTRIBUTIONBASE}
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot
Conflicts: comoonics-bootimage-extras-rdac-multipath
Obsoletes: comoonics-bootimage-extras-dm-multipath

%description extras-dm-multipath-rhel6
Extra listfiles for device mapper multipath OSR configurations for RHEL6

%package extras-dm-multipath-fedora
Version: 0.1
Release: 3
Requires: comoonics-bootimage >= 1.3-41
Requires: /etc/redhat-release
Requires: comoonics-bootimage-listfiles-fedora
Summary: Listfiles for device mapper multipath OSR configurations for fedora
Group:   %{GROUPPARENT}/%{GROUPCHILDBASE}/%{GROUPCHILDFEDORA}
Distribution: %{DISTRIBUTIONBASE}
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot
Conflicts: comoonics-bootimage-extras-rdac-multipath
Obsoletes: comoonics-bootimage-extras-dm-multipath

%description extras-dm-multipath-fedora
Extra listfiles for device mapper multipath OSR configurations for fedora

%package extras-dm-multipath-sles10
Version: 0.1
Release: 1
Requires: comoonics-bootimage >= 1.4
Requires: multipath-tools
Summary: Listfiles for device mapper multipath OSR configurations for SLES
Group:   %{GROUPPARENT}/%{GROUPCHILDBASE}/%{GROUPCHILDSLES10}
Distribution: %{DISTRIBUTIONBASE}
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot
Conflicts: comoonics-bootimage-extras-rdac-multipath
Obsoletes: comoonics-bootimage-extras-dm-multipath
Obsoletes: comoonics-bootimage-extras-dm-multipath-sles

%description extras-dm-multipath-sles10
Extra listfiles for device mapper multipath OSR configurations for SLES

%package extras-dm-multipath-sles11
Version: 0.1
Release: 1
Requires: comoonics-bootimage >= 1.4
Summary: Listfiles for device mapper multipath OSR configurations for SLES11
Group:   %{GROUPPARENT}/%{GROUPCHILDBASE}/%{GROUPCHILDSLES11}
Distribution: %{DISTRIBUTIONBASE}
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot
Conflicts: comoonics-bootimage-extras-rdac-multipath
Obsoletes: comoonics-bootimage-extras-dm-multipath
Obsoletes: comoonics-bootimage-extras-dm-multipath-sles

%description extras-dm-multipath-sles11
Extra listfiles for device mapper multipath OSR configurations for SLES11

%package extras-rdac-multipath
Version: 0.1
Release: 4
Requires: comoonics-bootimage >= 1.3-8
Summary: Listfiles for rdac multipath sharedroot configurations
Group:   %{GROUPPARENT}/%{GROUPCHILDEXTRAS}
Distribution: %{DISTRIBUTIONEXTRAS}
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description extras-rdac-multipath
Extra listfiles for rdac multipath OSR configurations

%package extras-xen
Version: 0.1
Release: 6
Requires: comoonics-bootimage >= 1.3-14
Summary: Listfiles for xen support in the open-sharedroot cluster
Group:   %{GROUPPARENT}/%{GROUPCHILDBASE}
Distribution: %{DISTRIBUTIONBASE}
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description extras-xen
listfiles for xen support in the OSR cluster

%package extras-iscsi
Version: 0.1
Release: 11
Requires: comoonics-bootimage >= 1.4-55
Summary: Listfiles for iscsi support in the open-sharedroot cluster
Group:   %{GROUPPARENT}/%{GROUPCHILDBASE}
Distribution: %{DISTRIBUTIONBASE}
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description extras-iscsi
ISCSI support in the OSR cluster

%package extras-drbd
Version: 0.1
Release: 4
Requires: comoonics-bootimage >= 1.3-33
Summary: Listfiles for drbd support in the open-sharedroot cluster
Group:   %{GROUPPARENT}/%{GROUPCHILDEXTRAS}
Distribution: %{DISTRIBUTIONEXTRAS}
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description extras-drbd
DRBD support in the OSR cluster

%package extras-glusterfs
Version: 0.1
Release: 4
Requires: comoonics-bootimage >= 1.3-44
Summary: Extras for glusterfs support in the open-sharedroot cluster
Group:   %{GROUPPARENT}/%{GROUPCHILDEXTRAS}
Distribution: %{DISTRIBUTIONEXTRAS}
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description extras-glusterfs
GlusterFS support in the OSR cluster

%package extras-sysctl
Version: 0.1
Release: 2
Requires: comoonics-bootimage >= 1.3-44
Summary: Extras for sysctl support in the open-sharedroot cluster
Group:   %{GROUPPARENT}/%{GROUPCHILDBASE}
Distribution: %{DISTRIBUTIONBASE}
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description extras-sysctl
Sysctl support in the OSR cluster

%package extras-syslog
Version: 0.1
Release: 13
Requires: comoonics-bootimage >= 1.4-27
Summary: Syslog implementation for osr
Group:   %{GROUPPARENT}/%{GROUPCHILDBASE}
Distribution: %{DISTRIBUTIONBASE}

%description extras-syslog
Syslog implementation for osr. Supports syslog classic, syslog-ng, rsyslog (See listfiles-syslog)

%package listfiles-selinux-rhel5
Version: 0.1
Release: 1
Requires: comoonics-bootimage >= 1.4-82
Summary: SELinux implementation for osr
Group:   %{GROUPPARENT}/%{GROUPCHILDBASE}/%{GROUPCHILDRHEL5}
Distribution: %{DISTRIBUTIONBASE}

%description listfiles-selinux-rhel5
SELinux implementation for osr. Supports only local filesystems and distributions supporting SELinux

%package listfiles-selinux-rhel6
Version: 0.1
Release: 1
Requires: comoonics-bootimage >= 1.4-82
Summary: SELinux implementation for osr
Group:   %{GROUPPARENT}/%{GROUPCHILDBASE}/%{GROUPCHILDRHEL6}
Distribution: %{DISTRIBUTIONBASE}

%description listfiles-selinux-rhel6
SELinux implementation for osr. Supports only local filesystems and distributions supporting SELinux

%package listfiles-vi-sles10
Version: 0.1
Release: 1
Requires: comoonics-bootimage >= 1.4
Summary: Vim includes for comoonics-bootimage
Group:   %{GROUPPARENT}/%{GROUPCHILDBASE}/%{GROUPCHILDSLES10}
Distribution: %{DISTRIBUTIONEXTRAS}

%description listfiles-vi-sles10
Vi includes for comoonics-bootimage (takes vim)

%package listfiles-vi-sles11
Version: 0.1
Release: 1
Requires: comoonics-bootimage >= 1.4
Summary: Vim includes for comoonics-bootimage
Group:   %{GROUPPARENT}/%{GROUPCHILDBASE}/%{GROUPCHILDSLES11}
Distribution: %{DISTRIBUTIONEXTRAS}

%description listfiles-vi-sles11
Vi includes for comoonics-bootimage (takes vim)

%package listfiles-all
Version: 0.1
Release: 17
Requires: comoonics-bootimage >= 1.4-81
Group:   %{GROUPPARENT}/%{GROUPCHILDBASE}
Distribution: %{DISTRIBUTIONBASE}
Summary: OSR listfilesfiles for all distributions 
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description listfiles-all
OSR Listfiles that are only relevant for all linux distributions

%package listfiles-rhel4
Version: 0.1
Release: 5
Requires: comoonics-bootimage >= 1.4-81
Requires: /etc/redhat-release
Requires: comoonics-bootimage-listfiles-rhel4
Group:   %{GROUPPARENT}/%{GROUPCHILDBASE}/%{GROUPCHILDRHEL4}
Summary: Extrafiles for RedHat Enterprise Linux Version 4 
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot
Conflicts: comoonics-bootimage-listfiles-rhel5 
Obsoletes: comoonics-bootimage-listfiles-rhel

%description listfiles-rhel4
OSR extra files that are only relevant for RHEL4

%package listfiles-rhel5
Version: 0.1
Release: 10
Requires: comoonics-bootimage >= 1.4-82
Requires: /etc/redhat-release
Requires: comoonics-bootimage-listfiles-all
Requires: comoonics-cluster-tools-py
Group:   %{GROUPPARENT}/%{GROUPCHILDBASE}/%{GROUPCHILDRHEL5}
Summary: Extrafiles for RedHat Enterprise Linux 
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot
Obsoletes: comoonics-bootimage-listfiles-rhel

%description listfiles-rhel5
OSR extra files that are only relevant for RHEL Versions

%package listfiles-rhel6
Version: 0.1
Release: 10
Requires: comoonics-bootimage >= 1.4-82
Requires: /etc/redhat-release
Requires: comoonics-bootimage-listfiles-all
Requires: comoonics-cluster-tools-py
Group:   %{GROUPPARENT}/%{GROUPCHILDBASE}/%{GROUPCHILDRHEL6}
Summary: Extrafiles for RedHat Enterprise Linux 
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot
Obsoletes: comoonics-bootimage-listfiles-rhel

%description listfiles-rhel6
OSR extra files that are only relevant for RHEL Versions

%package listfiles-fedora
Version: 0.1
Release: 10
Requires: comoonics-bootimage >= 1.3-41
Requires: /etc/redhat-release
Requires: comoonics-bootimage-listfiles-all
Group:   %{GROUPPARENT}/%{GROUPCHILDBASE}/%{GROUPCHILDFEDORA}
Summary: Extrafiles for Fedora Core 
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description listfiles-fedora
OSR extra files that are only relevant for Fedora Versions

%package listfiles-sles10
Version: 0.1
Release: 5
Requires: comoonics-bootimage >= 1.4-28
Requires: /etc/SuSE-release
Group:   %{GROUPPARENT}/%{GROUPCHILDBASE}/%{GROUPCHILDSLES10}
Summary: Extrafiles for Novell SuSE Enterprise Server 10
Conflicts: comoonics-bootimage-listfiles-sles11
Conflicts: comoonics-bootimage-listfiles-rhel4 
Conflicts: comoonics-bootimage-listfiles-rhel5 
Conflicts: comoonics-bootimage-listfiles-rhel6 
Conflicts: comoonics-bootimage-listfiles-fedora 
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot
Obsoletes: comoonics-bootimage-listfiles-sles

%description listfiles-sles10
OSR extra files that are only relevant for Novell SLES 10

%package listfiles-sles11
Version: 0.1
Release: 9
Requires: comoonics-bootimage >= 1.4-27
Requires: /etc/SuSE-release
Group:   %{GROUPPARENT}/%{GROUPCHILDBASE}/%{GROUPCHILDSLES11}
Summary: Extrafiles for Novell SuSE Enterprise Server
Conflicts: comoonics-bootimage-listfiles-sles10
Conflicts: comoonics-bootimage-listfiles-rhel4 
Conflicts: comoonics-bootimage-listfiles-rhel5 
Conflicts: comoonics-bootimage-listfiles-rhel6 
Conflicts: comoonics-bootimage-listfiles-fedora 
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot
Obsoletes: comoonics-bootimage-listfiles-sles

%description listfiles-sles11
OSR extra files that are only relevant for Novell SLES 11

%package listfiles-fedora-nfs
Version: 0.1
Release: 8
Requires: comoonics-bootimage-listfiles-fedora
Group:   %{GROUPPARENT}/%{GROUPCHILDBASE}/%{GROUPCHILDFEDORA}
Summary: Extrafiles for Fedora Core NFS support 
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description listfiles-fedora-nfs
OSR extra files that are only relevant for Fedora Versions and nfs support

%package listfiles-rhel5-gfs1
Version: 0.1
Release: 1
Requires: comoonics-bootimage >= 1.4-81
Requires: /etc/redhat-release
Requires: comoonics-bootimage-listfiles-rhel5
Group:   %{GROUPPARENT}/%{GROUPCHILDBASE}/%{GROUPCHILDRHEL5}
Summary: Extrafiles for RedHat Enterprise Linux Version 5 and GFS1
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot
Conflicts: comoonics-bootimage-listfiles-rhel5-nfs
Conflicts: comoonics-bootimage-extras-ocfs2

%description listfiles-rhel5-gfs1
OSR extra files that are only relevant for RHEL5 and GFS1

%package listfiles-rhel5-nfs
Version: 0.1
Release: 2
Requires: comoonics-bootimage-listfiles-rhel5
Requires: comoonics-bootimage-extras-nfs
Group:   %{GROUPPARENT}/%{GROUPCHILDBASE}/%{GROUPCHILDRHEL5}
Summary: Extrafiles for RHEL5 NFS support 
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot
Conflicts: comoonics-bootimage-listfiles-rhel5-gfs1
Conflicts: comoonics-bootimage-extras-ocfs2

%description listfiles-rhel5-nfs
OSR extra files that are only relevant for RHEL5 Versions and nfs support

%package listfiles-rhel4-nfs
Version: 0.1
Release: 2
Requires: comoonics-bootimage-extras-nfs
Requires: comoonics-bootimage-listfiles-rhel4
Group:   %{GROUPPARENT}/%{GROUPCHILDBASE}/%{GROUPCHILDRHEL4}
Summary: Extrafiles for RHEL4 NFS support 
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot
Conflicts: comoonics-bootimage-extras-ocfs2

%description listfiles-rhel4-nfs
OSR extra files that are only relevant for RHEL4 Versions and nfs support

%package listfiles-rhel6-nfs
Version: 0.1
Release: 4
Requires: comoonics-bootimage-listfiles-rhel6
Requires: comoonics-bootimage-extras-nfs
Group:   %{GROUPPARENT}/%{GROUPCHILDBASE}/%{GROUPCHILDRHEL6}
Summary: Extrafiles for RHEL6 NFS support 
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot
Conflicts: comoonics-bootimage-extras-ocfs2

%description listfiles-rhel6-nfs
OSR extra files that are only relevant for RHEL6 Versions and nfs support

%package listfiles-sles10-nfs
Version: 0.1
Release: 2
Requires: comoonics-bootimage-listfiles-sles10
Requires: comoonics-bootimage-extras-nfs
Group:   %{GROUPPARENT}/%{GROUPCHILDBASE}/%{GROUPCHILDSLES10}
Summary: Extrafiles for SLES10 NFS support 
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot
Conflicts: comoonics-bootimage-extras-ocfs2

%description listfiles-sles10-nfs
OSR extra files that are only relevant for SLES10 Versions and nfs support

%package listfiles-sles11-nfs
Version: 0.1
Release: 2
Requires: comoonics-bootimage-extras-nfs
Requires: comoonics-bootimage-listfiles-sles11
Group:   %{GROUPPARENT}/%{GROUPCHILDBASE}/%{GROUPCHILDSLES11}
Summary: Extrafiles for SLES11 NFS support 
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot
Conflicts: comoonics-bootimage-extras-ocfs2

%description listfiles-sles11-nfs
OSR extra files that are only relevant for SLES11 Versions and nfs support

%package listfiles-imsd-plugins
Version: 0.1
Release: 2
Obsoletes: comoonics-bootimage-listfiles-fenceacksv-plugins
Requires: comoonics-bootimage >= 1.4-71
Requires: comoonics-cs-sysreport-templates
Requires: comoonics-imsd-py
Requires: comoonics-imsd-plugins-py
Summary: Extrafiles for plugins in imsd
Group: Group:   %{GROUPPARENT}/%{GROUPCHILDBASE}
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description listfiles-imsd-plugins
OSR extrafiles for plugins in imsd.

%package listfiles-syslogd
Version: 0.1
Release: 4
Requires: comoonics-bootimage-extras-syslog
Summary: Syslog listfiles for syslog classic
Group:   %{GROUPPARENT}/%{GROUPCHILDBASE}
Distribution: %{DISTRIBUTIONBASE}
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot
Conflicts: comoonics-bootimage-listfiles-rsyslogd
Conflicts: comoonics-bootimage-listfiles-syslog-ng

%description listfiles-syslogd
Syslog listfiles for syslog classic

%package listfiles-rsyslogd
Version: 0.1
Release: 4
Requires: comoonics-bootimage-extras-syslog
Summary: Syslog listfiles for the rsyslog daemon
Group:   %{GROUPPARENT}/%{GROUPCHILDBASE}
Distribution: %{DISTRIBUTIONBASE}
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot
Conflicts: comoonics-bootimage-listfiles-syslog
Conflicts: comoonics-bootimage-listfiles-syslog-ng

%description listfiles-rsyslogd
Syslog listfiles for rsyslog daemon

%package listfiles-syslog-ng
Version: 0.1
Release: 2
Requires: comoonics-bootimage-extras-syslog
Summary: Syslog listfiles for the syslog-ng daemon
Group:   %{GROUPPARENT}/%{GROUPCHILDBASE}
Distribution: %{DISTRIBUTIONBASE}
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot
Conflicts: comoonics-bootimage-listfiles-rsyslogd
Conflicts: comoonics-bootimage-listfiles-syslog

%description listfiles-syslog-ng
Syslog listfiles for syslog-ng daemon

%package listfiles-perl-rhel5
Version: 0.1
Release: 1
Requires: comoonics-bootimage
Summary: Listfiles for perl in the chroot for RHEL5
Group:   %{GROUPPARENT}/%{GROUPCHILDEXTRAS}/%{GROUPCHILDRHEL5}
Distribution: %{DISTRIBUTIONEXTRAS}
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description listfiles-perl-rhel5
Listfiles for the perl to be imported in the bootimage.

%package listfiles-fencelib
Version: 0.1
Release: 1
Requires: comoonics-bootimage
Summary: Listfiles for Fencelibs
Group:   %{GROUPPARENT}/%{GROUPCHILDBASE}
Distribution: %{DISTRIBUTIONBASE}
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description listfiles-fencelib
Listfiles for the fencelibs to be imported in the bootimage.

%package listfiles-fencexvm
Version: 0.1
Release: 1
Requires: comoonics-bootimage
Summary: Listfiles for fence_xvm
Group:   %{GROUPPARENT}/%{GROUPCHILDBASE}
Distribution: %{DISTRIBUTIONBASE}
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description listfiles-fencexvm
Listfiles for the fence_xvm agent to be imported in the bootimage.

%package listfiles-fence_vmware-rhel5
Version: 0.1
Release: 1
Requires: comoonics-bootimage >= 1.4
Requires: comoonics-bootimage-listfiles-perl-rhel5
Summary: Files needed for fence_vmware in the kernel
Group:   %{GROUPPARENT}/%{GROUPCHILDEXTRAS}/%{GROUPCHILDRHEL5}
Distribution: %{DISTRIBUTIONEXTRAS}
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description listfiles-fence_vmware-rhel5
Files needed for fence_vmware in the kernel

%package listfiles-firmware
Version: 0.1
Release: 1
Requires: comoonics-bootimage >= 1.4
Summary: Files needed for firmware in the kernel
Group:   %{GROUPPARENT}/%{GROUPCHILDBASE}
Distribution: %{DISTRIBUTIONBASE}
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description listfiles-firmware
Files needed for firmware in the kernel

%package listfiles-plymouth
Version: 0.1
Release: 2
Requires: comoonics-bootimage >= 1.4-81
Summary: Files needed for plymouth support in the initrd
Group:   %{GROUPPARENT}/%{GROUPCHILDBASE}
Distribution: %{DISTRIBUTIONBASE}
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description listfiles-plymouth
Files needed for plymouth support in the initrd

%package compat
Version: 0.1
Release: 3
Requires: comoonics-bootimage >= 1.3-1
Summary: Files needed for compatibility to 1.2 releases
Group:   %{GROUPPARENT}/%{GROUPCHILDBASE}
Distribution: %{DISTRIBUTIONBASE}
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description compat
OSR files needed for the compatibility to 1.2 releases

%package imsd
Version: 0.1
Release: 2
Obsoletes: comoonics-bootimage-fenceacksv
Requires: comoonics-imsd-py
Requires: comoonics-bootimage >= 1.4-71
Requires: comoonics-tools-py >= 0.1-9
Summary: The Integrated Management Server Device is a service for last resort actions
Group:   Group:   %{GROUPPARENT}/%{GROUPCHILDBASE}
Distribution: %{DISTRIBUTIONBASE}
BuildRoot: %{_tmppath}/%{name}-%{version}-buildroot

%description imsd
The Fenceackserver is a service for last resort actions

%prep
%setup -q

%build

%install
make PREFIX=$RPM_BUILD_ROOT INSTALL_DIR=%{APPDIR} install

# Files for compat
install -d -m 755 $RPM_BUILD_ROOT/%{SYSCONFIGDIR}
install -m0644 etc/sysconfig/comoonics-chroot.compat-vg_local $RPM_BUILD_ROOT/%{SYSCONFIGDIR}/comoonics-chroot


# Files for imsd
install -d -m 755 $RPM_BUILD_ROOT/%{IMSD_DIR}
install -m644 %{IMSD_SOURCE}/shell.py $RPM_BUILD_ROOT/%{IMSD_DIR}/

install -d -m 755 $RPM_BUILD_ROOT/%{INITDIR}
install -m755 %{IMSD_SOURCE}/imsd.sh $RPM_BUILD_ROOT/%{INITDIR}/imsd
install -d -m 755 $RPM_BUILD_ROOT/%{CONFIGDIR}/bootimage-chroot
install -d -m 755 $RPM_BUILD_ROOT/%{CONFIGDIR}/bootimage-chroot/files.initrd.d
install -d -m 755 $RPM_BUILD_ROOT/%{CONFIGDIR}/bootimage-chroot/rpms.initrd.d
install -m644 %{IMSD_SOURCE}/files-imsd.list $RPM_BUILD_ROOT/%{CONFIGDIR}/bootimage-chroot/files.initrd.d/imsd.list
install -m644 %{IMSD_SOURCE}/rpms-imsd.list $RPM_BUILD_ROOT/%{CONFIGDIR}/bootimage-chroot/rpms.initrd.d/imsd.list
# install -m640 %{IMSD_SOURCE}/imsd-config.sh $RPM_BUILD_ROOT/%{SYSCONFIGDIR}/imsd

# Files for fence-clients (ilo)
install -d -m 755 $RPM_BUILD_ROOT/%{FENCECLIENTS_DIR}
install -d -m 755 $RPM_BUILD_ROOT/%{FENCECLIENTS_DOC}
install -d -m 755 $RPM_BUILD_ROOT/%{CONFIGDIR}/bootimage/rpms.initrd.d
install -d -m 755 $RPM_BUILD_ROOT/%{CONFIGDIR}/bootimage/pre.mkinitrd.d
install -d -m 755 $RPM_BUILD_ROOT/%{CONFIGDIR}/bootimage/post.mkinitrd.d

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

if [ -f /etc/redhat-release ] && cat /etc/redhat-release | grep -i "release 5" &> /dev/null; then
	services="cman gfs qdiskd"
elif [ -f /etc/redhat-release ]; then
	services="cman gfs qdiskd"
fi

if [ -n "$services" ]; then
  echo "Disabling services ($services)"
  for service in $services; do
     chkconfig --list $service &>/dev/null && chkconfig --del $service &> /dev/null
  done
  echo "You might want to reenable these services if need be (nfs/ext3 root usage)!"
  /bin/true
fi

echo 'Information:
Cluster services will be started in a chroot environment. Check out latest documentation
on http://www.open-sharedroot.org
'

%post imsd
echo "Setting up imsd"
chkconfig --add imsd &> /dev/null
chkconfig --list imsd
echo "Done"

%preun imsd
if [ "$1" -eq 0 ]; then
  echo "Uninstalling imsd"
  chkconfig --del imsd
fi

# Triggers to be triggered by different other rpms
#%triggerin -n listfiles-rhel5 -- kernel
#comecmkinitrdfile=/etc/comoonics/enterprisecopy/mkinitrd.xml
#mkinitrdcmd=/opt/atix/comoonics-bootimage/mkinitrd
#initrd_name=initrd_sr-$(uname -r).img
#. /etc/sysconfig/comoonics
#
#
#which com-ec >/dev/null 2>&1
# Not yet supported because com-ec does not easily allow overwriting of initrd filename
#if [ $? -eq 0 ] && [ -f $comecmkinitrdfile ]; then
#   echo "Building new initrd through com-ec (this could take some time)...   
#   com-ec $comecmkinitrdfile
#else
#$mkinitrdcmd $initrd_name


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
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/ext4-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/gfs-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/hardware-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/inittab
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/issue
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/lock-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/network-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/plymouth-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/repository-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/xen-lib.sh
#%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/passwd
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/selinux-lib.sh
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
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/rhel6/boot-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/rhel6/gfs-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/rhel6/hardware-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/rhel6/network-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/sles8/hardware-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/sles8/network-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/sles10/boot-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/sles10/hardware-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/sles10/network-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/sles10/ext3-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/sles11/boot-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/sles11/hardware-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/sles11/network-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/sles11/ext3-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/fedora/boot-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/fedora/gfs-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/fedora/hardware-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/fedora/network-lib.sh

%dir %{CONFIGDIR}/bootimage-chroot
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage-chroot/files.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage-chroot/rpms.list
%dir %{CONFIGDIR}/bootimage-chroot/files.initrd.d
%dir %{CONFIGDIR}/bootimage-chroot/rpms.initrd.d
%dir %{CONFIGDIR}/bootimage/pre.mkinitrd.d
%dir %{CONFIGDIR}/bootimage/post.mkinitrd.d
%config %attr(0755, root, root) %{CONFIGDIR}/bootimage/pre.mkinitrd.d/00-bootimage-check.sh
%config %attr(0755, root, root) %{CONFIGDIR}/bootimage/pre.mkinitrd.d/00-cdsl-check.sh
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/post.mkinitrd.d/02-create-cdsl-repository.sh

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
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/rhel6/nfs-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/fedora/nfs-lib.sh
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/sles10/nfs-lib.sh

%files extras-ocfs2
%attr(0644, root, root) %{LIBDIR}/boot-scripts/etc/ocfs2-lib.sh
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/ocfs2.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/ocfs2.list

%files extras-md
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/mdadm.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/mdadm.list

%files extras-dm-multipath-rhel4
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel/dm_multipath.list

%files extras-dm-multipath-rhel5
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel/dm_multipath.list

%files extras-dm-multipath-rhel6
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel/dm_multipath.list

%files extras-dm-multipath-sles10
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/sles/dm_multipath.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/sles/dm_multipath.list

%files extras-dm-multipath-sles11
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/sles/dm_multipath.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/sles/dm_multipath.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/sles11/dm_multipath.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/sles11/dm_multipath.list

%files extras-dm-multipath-fedora
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/fedora/dm_multipath.list

%files extras-dm-multipath-rhel6
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel6/dm_multipath.list

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
%config(noreplace) %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/user_edit.list

%files listfiles-rhel4
%dir %{CONFIGDIR}/bootimage/files.initrd.d/rhel
%dir %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/rhel/empty.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/rhel/base.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/rhel/configs.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/rhel/gfs.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/rhel/grub.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/rhel/network.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel/base.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel/empty.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel/hardware.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel/python.list
%dir %{CONFIGDIR}/bootimage/files.initrd.d/rhel4
%dir %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel4
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/rhel4/empty.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/rhel4/configs.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel4/empty.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel4/hardware.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel4/gfs1.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel4/rhcs.list

%files listfiles-rhel5
%dir %{CONFIGDIR}/bootimage/files.initrd.d/rhel
%dir %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/rhel/empty.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/rhel/base.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/rhel/configs.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/rhel/grub.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/rhel/network.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel/base.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel/empty.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel/hardware.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel/python.list
%dir %{CONFIGDIR}/bootimage/files.initrd.d/rhel5
%dir %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel5
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/rhel5/empty.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/rhel5/configs.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel5/empty.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel5/base.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel5/hardware.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel5/python.list

%files listfiles-rhel6
%dir %{CONFIGDIR}/bootimage/files.initrd.d/rhel
%dir %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/rhel/empty.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/rhel/base.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/rhel/configs.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/rhel/gfs.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/rhel/grub.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/rhel/network.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel/base.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel/empty.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel/hardware.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel/python.list
%dir %{CONFIGDIR}/bootimage/files.initrd.d/rhel6
%dir %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel6
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/rhel6/base.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/rhel6/configs.list
#%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/rhel6/comoonics.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/rhel6/network.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel6/base.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel6/hardware.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel6/python.list

%files listfiles-sles10
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
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/sles10/base.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/sles10/python.list

%files listfiles-sles11
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

%files listfiles-rhel5-gfs1
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel/comoonics.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/rhel/gfs.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/rhel5/rhcs.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel5/rhcs.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel5/gfs1.list

%files listfiles-fedora-nfs
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/nfs.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/fedora/nfs.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/fedora/network.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/nfs.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/post.mkinitrd.d/03-nfs-deps.sh

%files listfiles-rhel4-nfs
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/nfs.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel/nfs.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel4/nfs.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/nfs.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/post.mkinitrd.d/03-nfs-deps.sh

%files listfiles-rhel5-nfs
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/nfs.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel/nfs.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel5/nfs.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/nfs.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/post.mkinitrd.d/03-nfs-deps.sh

%files listfiles-rhel6-nfs
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/nfs.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel/nfs.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel6/nfs.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel6/network.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/nfs.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/post.mkinitrd.d/03-nfs-deps.sh

%files listfiles-sles10-nfs
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/nfs.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/sles/nfs.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/nfs.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/post.mkinitrd.d/03-nfs-deps.sh

%files listfiles-sles11-nfs
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/nfs.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/sles/nfs.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/nfs.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/post.mkinitrd.d/03-nfs-deps.sh

%files listfiles-selinux-rhel5
%attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel/selinux.list

%files listfiles-selinux-rhel6
%attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel/selinux.list

%files listfiles-imsd-plugins
%config %attr(0644, root, root) %dir %{CONFIGDIR}/bootimage-chroot/rpms.initrd.d/imsd-plugins.list

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

%files listfiles-perl-rhel5
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/rhel5/perl.list

%files listfiles-fence_vmware-rhel5
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/rhel5/fence_vmware.list

%files listfiles-vi-sles10
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/sles/vim.list

%files listfiles-vi-sles11
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/sles/vim.list

%files listfiles-firmware
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/files.initrd.d/firmware.list

%files listfiles-plymouth
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage/rpms.initrd.d/plymouth.list

%files imsd
%attr(0644, root, root) %{IMSD_DIR}/shell.py*
%config %attr(0755, root, root) %{INITDIR}/imsd
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage-chroot/files.initrd.d/imsd.list
%config %attr(0644, root, root) %{CONFIGDIR}/bootimage-chroot/rpms.initrd.d/imsd.list
#%config(noreplace)     %{SYSCONFIGDIR}/imsd
%doc %attr(0644, root, root) CHANGELOG

%clean
rm -rf %{buildroot}


%changelog
* Mon Apr 18 2011 Marc Grimme <grimme@atix.de> 1.4-83
 2011-04-18  Marc Grimme <grimme@atix.de>
  - system-cfg-files/rpms.initrd.d/rhel4/rhcs.list,
    system-cfg-files/rpms.initrd.d/rhel5/rhcs.list,
    system-cfg-files/rpms.initrd.d/rhel6/rhcs.list: OpenIPMI-tools are set
    optional
  - .../pre.mkinitrd.d/00-bootimage-check.sh: initial revision. Script to check
    if all required rpms are installed.
  - Makefile, comoonics-bootimage.spec: new versions
  - build/gitlog2rpmchangelog.py: initial revision to outcreate changelog for
    rpms.
  - build/gitlog2changelog.py: add params to be given to git command.
  - tests/test/osr-nodeidvalues-1.conf: removed fenceacksv test.
  - fencing/fence-ack-server/CA.cert, fencing/fence-ack-server/CA.pkey,
    fencing/fence-ack-server/client.cert, fencing/fence-ack-server/client.pkey,
    fencing/fence-ack-server/client.py, fencing/fence-ack-server/cluster.conf,
    fencing/fence-ack-server/fence_ack_server.py,
    fencing/fence-ack-server/fenceacksv.sh,
    fencing/fence-ack-server/files-fenceacksv.list,
    fencing/fence-ack-server/rpms-fenceacksv.list,
    fencing/fence-ack-server/server.cert, fencing/fence-ack-server/server.pkey,
    fencing/fence-ack-server/shell.py,
    fencing/fence-ack-server/starttestservice.sh,
    fencing/fence-ack-server/test/__init__.py,
    .../fence-ack-server/test/cluster_fence_scsi.xml,
    .../test/cluster_fence_scsi_devices.xml,
    fencing/fence-ack-server/test/test_FenceScsi.py,
    fencing/fence-ack-server/test_client.py,
    fencing/fence-ack-server/testserver.py,
    fencing/fence-ack-server/testservice.sh, fencing/test/__init__.py,
    fencing/test/cluster_fence_scsi.xml,
    fencing/test/cluster_fence_scsi_devices.xml, fencing/test/test_FenceScsi.py,
    .../rpms.initrd.d/fenceacksv-plugins.list: removed as fenceacksv is obsolete
  - Makefile: moved fenceacksv files to imsd
  - querymap.cfg: removed available fenceacksv queries.
  - .../rpms.initrd.d/imsd-plugins.list: result of renaming fenceacksv to imsd.
  - system-cfg-files/filters.initrd.d/kernel.list: - removed filter out of
    modules needed for bonding.
  - imsd/files-imsd.list, imsd/imsd.sh, imsd/rpms-imsd.list, imsd/shell.py,
    imsd/testserver.py, imsd/testservice.sh: imsd as result of renaming
    fenceacksv.
  - boot-scripts/linuxrc.generic.sh: fixed errmsgstdin usage in combination
    with breakp to break if problems with selinux.
  - boot-scripts/etc/fedora/nfs-lib.sh: - removed nfs_load function
  - boot-scripts/etc/selinux-lib.sh: fixed bug with right detection of
    bootparams and config in /etc/selinux/config
  - boot-scripts/etc/osr-lib.sh: osr_get_cluster_elements: - removed fenceacksv
    from elements to be converted.
  - boot-scripts/etc/nfs-lib.sh: removed dublicated returncode in nfs-lib.sh
  - boot-scripts/etc/rhel6/nfs-lib.sh: nfs_load removed.
  - boot-scripts/etc/bashrc: hide implicit usage of plymouth functions.

 2011-04-07  Marc Grimme <grimme@atix.de>
  - Makefile, build/clean_rpms.sh, build/copy_rpms.sh, build/init_repo.sh,
    comoonics-bootimage-initscripts-el4.spec,
    comoonics-bootimage-initscripts-el5.spec,
    comoonics-bootimage-initscripts-fedora.spec,
    comoonics-bootimage-initscripts-rhel6.spec,
    comoonics-bootimage-initscripts-sles10.spec,
    comoonics-bootimage-initscripts-sles11.spec, comoonics-bootimage.spec,
    manage_chroot.sh: implemented optimized build process.
  - .../rpms.initrd.d/fenceacksv-plugins.list: added more packages to be needed
    for imsd (comoonics-ec-py, comoonics-tools-py, comoonics-ec-base-py).
  - system-cfg-files/rpms.initrd.d/rhel5/base.list: added pam files that are
    required in this place.
  - initscripts/rhel5/bootsr: support for forcefully overwrite of chroot
    requirement
  - fencing/fence-ack-server/rpms-fenceacksv.list: added rpms to be needed for
    sshd support
  - boot-scripts/linuxrc.generic.sh: support for forcefull requirement of
    chroot environment.
  - boot-scripts/com-halt.sh: exit if chroot is not needed.
  - boot-scripts/etc/plymouth-lib.sh: boot-scripts/etc/plymouth-lib.sh: - less
    senseless output in plymouth_setup
  - boot-scripts/etc/ocfs2-lib.sh: boot-scripts/etc/ocfs2-lib.sh: - fixed typo
    in ocfs2_services_start
* Fri Mar 11 2011 Marc Grimme <grimme@atix.de> 1.4-82
  * boot-scripts/etc/plymouth-lib.sh, system-cfg-files/files.initrd.d/nfs.list,
  system-cfg-files/post.mkinitrd.d/03-nfs-deps.sh,
  system-cfg-files/rpms.initrd.d/plymouth.list,
  system-cfg-files/rpms.initrd.d/rhel/selinux.list,
  tests/test/error/err_cc_start_service.out: new versions
  * tests/test-errors.sh, tests/test/error/err_cc_restart_service.out: - new tests
  * Makefile: - added new files
  * system-cfg-files/rpms.initrd.d/rhel6/nfs.list: - docs
  * boot-scripts/linuxrc.generic.sh: - added starting on udevdaemon early -
  added plymouth functions if available - added selinux functions if available
  - moved initrd_exit_postsettings to be executed later
  * boot-scripts/linuxrc: - no boot-log any more
  * boot-scripts/etc/std-lib.sh: - sourceLibs: added sourcing of
  plymouth-lib.sh and selinux-lib.sh if available - exec_local: remove
  repository parameters exec_local* - exec_ordered_skripts_in: will now work on
  multiple scripts in the right order.
  * boot-scripts/etc/stdfs-lib.sh: - is_mounted: remove MOUNTS env variable if
    set by this function - get_dep_filesystems: also work on paths with multiple
    // after each other (e.g. //proc)
  * boot-scripts/etc/selinux-lib.sh: - change to status working and tested first stage
  * boot-scripts/etc/passwd: removed empty line
  * boot-scripts/etc/nfs-lib.sh: - nfs_start_rpcpipefs: echo_local ->
  echo_local_debug - nfs_stop_rpc_statd: added function to stop rpc_statd
  * boot-scripts/etc/network-lib.sh: - auto_netconfig: now errormsg if
  /etc/modprobe.conf would not be found
  * boot-scripts/etc/hardware-lib.sh: - udev_daemon_start: new function that
  starts the udevdaemon distribution dependent - dev_start: will mount devtmpfs
  if possible and call create_std_devfs if not - create_std_devfs: creates all
  devices if devfs is not available - scsi_start: will not output error if
  /etc/modprobe.conf would not be found
  * boot-scripts/etc/errors.sh: - new function that reads errordescription from
  stdin - err_cc_restart_service: fixed typo - err_cc_start_service: new
  errormsg
  * boot-scripts/etc/comoonics-release: - changed release to 5.0 (Gumpn)
  * boot-scripts/etc/clusterfs-lib.sh: - copy_relevant_files removed function
  * boot-scripts/etc/boot-lib.sh: - initBootProcess better process of creating
  directories necessary for initrd - start_service executing service via
  exec_local - switchRoot * echo -> echo_local * support for switch_root binary
  if available (experimental) * all dep filesystems on oldroot will be umounted
  (/proc, /sys and deps) * all dep filesystems on newroot will be mounted
  (/proc, /sys) - stop_service * docu * add force option the kill -9 if kill
  -TERM does not work defaults to yes * fixed a bug where the root would not be
  detected on service will not be killed - clean_initrd * cut of stderr/stdout
  of kill for processes - initrd_exit_postsettings * docu * typos
  * boot-scripts/etc/fedora/nfs-lib.sh, boot-scripts/etc/rhel6/nfs-lib.sh:
  removed umounting of /proc (will be done later on)
  * boot-scripts/etc/bashrc: added plymouth support
  * boot-scripts/etc/rhel6/nfs-lib.sh: nfs_services_stop/start: - added
  rpc.statd nfs_services_restart_newroot: - added rpc.statd
  * boot-scripts/etc/rhel6/hardware-lib.sh: implemented rhel6_udev_daemon_start
  and use it.
  * system-cfg-files/rpms.initrd.d/rhel5/perl.list: added perl-libwww-perl
  which is also required.
  * .../files.initrd.d/rhel5/fence_vmware.list: added more files that would not
  be included
  * comoonics-bootimage.spec: added changelogs for listfiles-perl-rhel5 and
  listfiles-fence_vmware-rhel5
  * Makefile, comoonics-bootimage.spec: added rpms
  comoonics-bootimage-listfiles-perl-rhel5 and listfiles-fence_vmware-rhel5
  * .../files.initrd.d/rhel5/fence_vmware.list,
  system-cfg-files/rpms.initrd.d/rhel/perl.list,
  system-cfg-files/rpms.initrd.d/rhel5/perl.list: initial revision
* Wed Mar 02 2011 Marc Grimme <grimme@atix.de> 1.4-81
- boot-scripts/etc/boot-lib.sh: 
    stop_service: now also stops the service if no pid file exists by
      killing the pid of the given service within the given root filesystem.
- boot-scripts/etc/chroot-lib.sh:
    get_filelist_from_installed_rpm/get_filelist_from_rpms: 
       added option parameters to specify a rpm as optional (no warning if missing)
    resolve_file: better output
    get_all_files_dependent: 
       added option parameters to specify a file as optional (no warning if missing)
- boot-scripts/etc/comoonics-release
    release 5.0 pre
- boot-scripts/etc/ext3-lib.sh
    cosmetics
- boot-scripts/etc/std-lib.sh
    listBreakpoints will now return all breakpoints with leading filename and step name in
       order that have been found not sorted by name (see bz #400).
- boot-scripts/etc/selinux-lib.sh,ext4-lib.sh:
    new versions
- boot-scritps/etc/rhel6/*: new versions
* Wed Mar 02 2011 Marc Grimme <grimme@atix.de> 1.4-80
- first version for com.oonics-5.0 pre
- boot-scripts/etc/rhel6/*: added support for RHEL6
- boot-scripts/etc/ext4-libs.sh: added support for RHEL6
* Mon Feb 28 2011 Marc Grimme <grimme@atix.de> 1.4-79
- boot-scripts/error-lib.sh
  - Fixed syntax errors in errormessages.
* Mon Feb 21 2011 Marc Grimme <grimme@atix.de> 1.4-78
- boot-scripts/linuxrc.generic.sh
  - if only one nodeid is present this one will be used if in question
* Fri Feb 18 2011 Marc Grimme <grimme@atix.de> 1.4-77
- querymap.cfg:
  - added nodeids query that would return the amount of nodeids in float (1.0, 2.0, ..)
- linuxrc.generic.sh
  - if no nodeid is given an only one nodeid is found this is one is used as nodeid => you don't need to specify the nodeid if single node
* Wed Feb 16 2011 Marc Grimme <grimme@atix.de> 1.4-76
- boot-scripts/etc/chroot-lib.sh
  - implemented that it might also work without existent cdsl environment.
- linuxrc.generic.sh
  - implemented that it might also work without existent cdsl environment.
* Fri Feb 11 2011 Marc Grimme <grimme@atix.de> 1.4-75
- boot-scripts/etc/gfs-lib.sh
  - added missing gfs_qdiskd_stop
- boot-scripts/etc/rhel5/gfs-lib.sh
  - added qdiskd to services being stopped.
* Thu Feb 10 2011 Marc Grimme <grimme@atix.de> 1.4-74
- boot-scripts/etc/repository-lib.sh
  - repository_normalize_value: fixed a cosmetic bug
- create-gfs-initrd-generic.sh:
  - fixed a bug that updateinitrd would not work with using relative paths.
* Tue Feb 08 2011 Marc Grimme <grimme@atix.de> 1.4-73
- boot-scripts/linuxrc.generic.sh
  - fixed a bug with creation of syslog configuration
- boot-scripts/etc/syslog-lib.sh
  - syslog_ng_config:
    - rewrote the whole configuration generation for the filters to be working as expected.
  -  syslog_ng_start:
    - added support for no_klog parameter
- boot-scripts/etc/templates/syslog-ng.conf
  - better general options
  - removed proc/kmsg for syslog in chroot
* Fri Feb 04 2011 Marc Grimme <grimme@atix.de> 1.4-72
- boot-scripts/etc/syslog-lib.sh
  - fixed another syslog-ng bug
- boot-scripts/linuxrc.generic.sh
  - restart syslog without log file bug with logging to localhost. 
* Thu Feb 03 2011 Marc Grimme <grimme@atix.de> 1.4-71
- boot-scripts/linuxrc.generic.sh
  - fixed bug that affects all NFS Sharedroot having a syslog specified.
     - now syslog is only started in the chroot after booting if it is needed. But then it's started in any case.
* Mon Jan 31 2011 Marc Grimme <grimme@atix.de> 1.4-70
- boot-scripts/etc/syslog-lib.sh
  - added queueing of messages in all generated rsyslog configuration files.
- boot-scripts/etc/clusterfs-lib.sh
  - added a parameter to cc_auto_syslog_config to take overwrite the syslog server from outside
- boot-scripts/linuxrc.generic.sh
  - restarting syslog if set instead of stopping it.
- fencing/fence-ack-sv/fenceacksv.sh
  - fixed a bug in the initscript the fenceacksv will fail to stop during shutdown.
* Thu Jan 27 2011 Marc Grimme <grimme@atix.de> 1.4-69
- bootimage/boot-scripts/etc/lock-lib.sh
  - implemented a simple global lock implementation based on lockfile
- bootimage/boot-scripts/chroot-lib.sh (Bug#396) Parallel booting of two nodes would not work.
  - protected each rpm call with a global lock (lock_rpm and unlock_rpm).
- bootimage/boot-scripts/etc/chroot-lib.sh
- bootimage/boot-scripts/linuxrc.generic.sh (Bug#399):
  - adding /var/run to /etc/xtab to exclude it from being umounted before com-halt is started. 
    So the reboot command can be detected as expected (only for RHEL5).
* Tue Jan 11 2011 Marc Grimme <grimme@atix.de> 1.4-68
- bootimage/boot-scripts/etc/rhel5/network-lib.sh:
  - autocreate /etc/sysconfig if it does not exist
- tests - upstream
* Tue Jan 11 2011 Marc Grimme <grimme@atix.de> 1.4-67
- comoonics-bootimage
  - etc/clusterfs-lib.sh: 
    - Fixed bug in calling of ${syslogtype}_config so that external destination would work
    - typo in errorhandling for filesystems that could not be mounted
* Mon Dec 07 2010 Marc Grimme <grimme@atix.de> 1.4-66
- comoonics-bootimage
  - added function [sles10/sles11]_initrd_exit_postsettings (just for sles first) to set the environment variable ROOTFS_BLKDEV
* Mon Dec 06 2010 Marc Grimme <grimme@atix.de> 1.4-65
- comoonics-bootimage-listfiles-firmware:
  - added /lib/firmware to default listfiles
- comoonics-bootimage-listfiles-vi-sles
  - added vim support to sles
- comoonics-bootimage-listfiles-dm-multipath-sles
  - added /etc/multipath.conf which is not included by default
* Wed Sep 06 2010 Marc Grimme <grimme@atix.de> 1.4-64
- boot-scripts/boot-lib/etc/rhel5/network-lib.sh:rhel5_ip2Config
  - fixed bug with wrong hostname in /etc/sysconfig/network
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
* Mon Apr 18 2011 Marc Grimme <grimme@atix.de> 0.1-21
- removed nfs_load whereever possible
* Fri Mar 11 2011 Marc Grimme <grimme@atix.de> 0.1-20
- added rpc_stop..
* Fri Mar 11 2011 Marc Grimme <grimme@atix.de> 0.1-19
- no
* Wed Mar 02 2011 Marc Grimme <grimme@atix.de> 0.1-18
- rpms.initrd.d/nfs.list: moved portmap to distros
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

%changelog extras-dm-multipath-rhel4
* Fri Mar 11 2011 Marc Grimme <grimme@atix.de> 0.1-1
- introduced instead of rhel

%changelog extras-dm-multipath-rhel5
* Fri Mar 11 2011 Marc Grimme <grimme@atix.de> 0.1-1
- introduced instead of rhel

%changelog extras-dm-multipath-rhel6
* Fri Mar 11 2011 Marc Grimme <grimme@atix.de> 0.1-1
- introduced instead of rhel

%changelog extras-dm-multipath-sles10
* Fri Mar 11 2011 Marc Grimme <grimme@atix.de> 0.1-1
- initial revision

%changelog extras-dm-multipath-sles11
* Tue Feb 09 2011 Marc Grimme <grimme@atix.de> - 0.1-1
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
* Tue Jan 11 2011 Marc Grimme <grimme@atix.de> 0.1-10
- bootimage/boot-scripts/etc/syslog-lib.sh:
  - detect syslog servers also in /usr/sbin
* Tue Jan 11 2011 Marc Grimme <grimme@atix.de> 0.1-9
- boot-scripts/boot-lib/etc/syslog-lib.sh
  - fixed bug in syslogd_config/rsyslogd_config because with only syslogserver the resulting syslogconfiguration would be wrong.
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

%changelog listfiles-selinux-rhel5
* Fri Mar 11 2011 Marc Grimme <grimme@atix.de> 0.1-1
  - initial revision

%changelog listfiles-selinux-rhel6
* Fri Mar 11 2011 Marc Grimme <grimme@atix.de> 0.1-1
  - initial revision

%changelog listfiles-all
* Wed Mar 02 2011 Marc Grimme <grimme@atix.de> 0.1-17
- files.initrd.d/configs.list/base.list/locales.list: added optionals and removed distro dependencies
- filters.initrd.d/kernel.list: added more modules that are not needed
* Wed Feb 16 2011 Marc Grimme <grimme@atix.de> 0.1-16
- pre.mkinitrd.d/00-cdsl-check.sh post.mkinitrd.d/02-create-cdsl-repository.sh
  - checks if cdsl environment is working
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

%changelog listfiles-rhel4
* Fri Mar 11 2011 Marc Grimme <grimme@atix.de> 0.1-5
  - moved files from rhel here
* Wed Mar 02 2011 Marc Grimme <grimme@atix.de> 0.1-4
- files.initrd.d/rhel5/configs.list: added configs.list as file for kudzu in here
- files.initrd.d/rhel5/hardware.list: added kudzu here
* Mon Mar 08 2010 Marc Grimme <grimme@atix.de> 0.1-3
- first version for comoonics-4.6-rc1 
* Fri Dec 05 2008 Marc Grimme <grimme@atix.de> - 0.1-2
- First version on the way to rpmlint BUG#290
* Thu Aug 14 2008 Marc Grimme <grimme@atix.de> - 0.1-1
  - initial revision 

%changelog listfiles-rhel5
* Fri Mar 11 2011 Marc Grimme <grimme@atix.de> 0.1-10
  - moved files from rhel here
  - moved rhcs-files to listfiles-gfs1-rhel5
* Wed Mar 02 2011 Marc Grimme <grimme@atix.de> 0.1-9
- files.initrd.d/rhel5/configs.list: added configs.list as file for kudzu in here
- files.initrd.d/rhel5/hardware.list: added kudzu here
* Tue Feb 22 2011 Marc Grimme <grimme@atix.de> 0.1-8
- added python-list in rpms.initrd.d/rhel5/python.list to be RHEL5.6 compatible
- added excludefilter to pam (rhcs.list) rpm to not include /var/Log files
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

%changelog listfiles-rhel6
* Wed Mar 02 2011 Marc Grimme <grimme@atix.de> 0.1-2
- added optionals
* Mon Feb 28 2011 Marc Grimme <grimme@atix.de> 0.1-1
- first version for comoonics-5.0-pre

%changelog listfiles-sles10
* Fri Mar 11 2011 Marc Grimme <grimme@atix.de> 0.1-5
  - moved files from sles here
* Mon Mar 08 2010 Marc Grimme <grimme@atix.de> 0.1-4
- first version for comoonics-4.6-rc1 
* Thu Oct 08 2009 Marc Grimme <grimme@atix.de> - 0.1-3
- removed python-devel dep.
* Mon Sep 28 2009 Marc Grimme <grimme@atix.de> - 0.1-2
- Finalized version with all changes
* Wed Sep 16 2009 Marc Grimme <grimme@atix.de> - 0.1-1
- initial revision

%changelog listfiles-sles11
* Fri Mar 11 2011 Marc Grimme <grimme@atix.de> 0.1-9
  - moved files from sles here
* Fri Feb 11 2011 Marc Grimme <grimme@atix.de> 0.1-8
- added new deps for sles11
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

%changelog listfiles-rhel5-gfs1
* Mon Feb 28 2011 Marc Grimme <grimme@atix.de> 0.1-1
- first version for comoonics-5.0-pre

%changelog listfiles-fedora-nfs
* Fri Mar 11 2011 Marc Grimme <grimme@atix.de> 0.1-8
- new version for comoonics-5.0-pre with post script
* Tue Mar 08 2011 Marc Grimme <grimme@atix.de> 0.1-7
- first version for comoonics-5.0-pre
- added post.mkinitrd.d/03-nfs-deps.sh (setup of /etc/passwd for nfs if need be)
- added files.mkinitrd.d/nfs.list (/etc/rpc)
* Mon Mar 08 2010 Marc Grimme <grimme@atix.de> 0.1-6
- first version for comoonics-4.6-rc1 
* Mon Sep 28 2009 Marc Grimme <grimme@atix.de> - 0.1-5
- Finalized version with all changes
* Tue Aug 11 2009 Marc Grimme <grimme@atix.de> - 0.1-4
- Added a network list file for fedora (libidn)
* Tue Jan 29 2009 Marc Grimme <grimme@atix.de> - 0.1-3
- introduced the changelog

%changelog listfiles-rhel4-nfs
* Fri Mar 11 2011 Marc Grimme <grimme@atix.de> 0.1-3
- new version for comoonics-5.0-pre with post script
* Tue Mar 08 2011 Marc Grimme <grimme@atix.de> 0.1-2
- first version for comoonics-5.0-pre
- added post.mkinitrd.d/03-nfs-deps.sh (setup of /etc/passwd for nfs if need be)
- added files.mkinitrd.d/nfs.list (/etc/rpc)
* Mon Feb 28 2011 Marc Grimme <grimme@atix.de> 0.1-1
- first version for comoonics-5.0-pre

%changelog listfiles-rhel5-nfs
* Fri Mar 11 2011 Marc Grimme <grimme@atix.de> 0.1-3
- new version for comoonics-5.0-pre with post script
* Tue Mar 08 2011 Marc Grimme <grimme@atix.de> 0.1-2
- first version for comoonics-5.0-pre
- added post.mkinitrd.d/03-nfs-deps.sh (setup of /etc/passwd for nfs if need be)
- added files.mkinitrd.d/nfs.list (/etc/rpc)
* Mon Feb 28 2011 Marc Grimme <grimme@atix.de> 0.1-1
- first version for comoonics-5.0-pre

%changelog listfiles-rhel6-nfs
* Fri Mar 11 2011 Marc Grimme <grimme@atix.de> 0.1-4
- new version for comoonics-5.0-pre with post script
* Tue Mar 08 2011 Marc Grimme <grimme@atix.de> 0.1-3
- added post.mkinitrd.d/03-nfs-deps.sh (setup of /etc/passwd for nfs if need be)
- added files.mkinitrd.d/nfs.list (/etc/rpc)
* Wed Mar 02 2011 Marc Grimme <grimme@atix.de> 0.1-2
- added optionals
* Mon Feb 28 2011 Marc Grimme <grimme@atix.de> 0.1-1
- first version for comoonics-5.0-pre

%changelog listfiles-sles10-nfs
* Fri Mar 11 2011 Marc Grimme <grimme@atix.de> 0.1-2
- new version for comoonics-5.0-pre with post script
* Mon Feb 28 2011 Marc Grimme <grimme@atix.de> 0.1-1
- first version for comoonics-5.0-pre

%changelog listfiles-sles11-nfs
* Fri Mar 11 2011 Marc Grimme <grimme@atix.de> 0.1-2
- new version for comoonics-5.0-pre with post script
* Mon Feb 28 2011 Marc Grimme <grimme@atix.de> 0.1-1
- first version for comoonics-5.0-pre

%changelog listfiles-syslogd
* Mon Feb 14 2011 Marc Grimme <grimme@atix.de> 0.1-4
- fixed regexp in listfile.
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

%changelog listfiles-imsd-plugins
* Mon Apr 18 2011 Marc Grimme <grimme@atix.de> 0.1-2
- more deps for imsd (comoonics-base-py, comoonics-storage-py, ..)
* Tue Apr 07 2011 Marc Grimme <grimme@atix.de> 0.1-1
- renamed from listfiles-fenceacksv-plugins

%changelog listfiles-fencelib
* Wed Jul 07 2010 Marc Grimme <grimme@atix.de> 0.1-1
- initial version 

%changelog listfiles-fencexvm
* Wed Jul 07 2010 Marc Grimme <grimme@atix.de> 0.1-1
- initial version 

%changelog listfiles-perl-rhel5
* Mon Mar 07 2011 Marc Grimme <grimme@atix.de> 0.1-1
- initial revision

%changelog listfiles-fence_vmware-rhel5
* Mon Mar 07 2011 Marc Grimme <grimme@atix.de> 0.1-1
- initial revision

%changelog listfiles-firmware
* Mon Mar 07 2011 Marc Grimme <grimme@atix.de> 0.1-1
- initial revision

%changelog listfiles-plymouth
* Mon Mar 07 2011 Marc Grimme <grimme@atix.de> 0.1-1
- initial revision

%changelog imsd
* Tue Apr 07 2011 Marc Grimme <grimme@atix.de> 0.1-1
- renamed from fenceacksv