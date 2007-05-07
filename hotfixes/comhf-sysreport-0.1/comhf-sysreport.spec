%define version 0.1
%define release 02

%define COM_ROOT /opt/atix/comoonics-hf-sysreport

#
# hotfix for com-sysreport spec file
# 
Summary: Comoonics hotfix sysreport 
Name: comhf-sysreport
Version: %{version}
Release: %{release}
License: GPL
Group: System Environment/Base
Source0: %{name}-%{version}.tar.gz 
Buildroot: %{_tmppath}/%{name}-%{version}-buildroot
Provides: comhf-sysreport
BuildPrereq: bash 

ExclusiveArch: noarch

%description
Workaround to get sysreports from comoonics fenceack server

%prep
%setup -q


%build

%install
%define COM_INST_ROOT ${RPM_BUILD_ROOT}/%{COM_ROOT}
%define INIT_PATH /etc/init.d
%define COM_CONFIG_PATH /etc/comoonics/comhf-update_fenced_chroot

rm -rf ${RPM_BUILD_ROOT}
mkdir -p %{COM_INST_ROOT}
mkdir -p ${RPM_BUILD_ROOT}%{INIT_PATH}
mkdir -p ${RPM_BUILD_ROOT}%{COM_CONFIG_PATH}

install -m 744 ./comhf_update_chroot.sh ${RPM_BUILD_ROOT}%{INIT_PATH}/comhf_update_chroot
install -m 744 ./comhf-sysreport.sh %{COM_INST_ROOT}
install -m 777 ./comhf-sysreport %{COM_INST_ROOT}
install -m 744 ./comhf-update_fenced_chroot.sh %{COM_INST_ROOT}
install -m 644 ./files.list ${RPM_BUILD_ROOT}%{COM_CONFIG_PATH}


%pre

%post
chkconfig comhf_update_chroot on

%preun
chkconfig comhf_update_chroot off

%clean


%files
%defattr(-, root, root)
%dir %{COM_ROOT}
%dir %{COM_CONFIG_PATH}
%{INIT_PATH}/comhf_update_chroot
%{COM_ROOT}/comhf-sysreport.sh
%{COM_ROOT}/comhf-sysreport
%{COM_ROOT}/comhf-update_fenced_chroot.sh
%{COM_CONFIG_PATH}/files.list


%changelog
* Thu Apr 26 2007 Mark Hlawatschek <hlawatschek at atix.de> 0.1.02
- modified output
* Thu Apr 19 2007 Mark Hlawatschek <hlawatschek at atix.de> 0.1.01
- First RPM version 
