#!/bin/bash
source ${prgdir:-/opt/atix/comoonics-bootimage/}/etc/std-lib.sh
sourceLibs ${prgdir:-/opt/atix/comoonics-bootimage/}

rootfs=$(repository_get_value rootfs)
distribution=$(repository_get_value distribution)
lock_rpm
if ! rpm -q comoonics-bootimage-listfiles-$distribution-$rootfs >/dev/null 2>&1; then
  error_local -N -e "\nCould not find a software package for your root filesystem.\n
Please install at least the following package: comoonics-bootimage-listfiles-$distribution-$rootfs\n"
  unlock_rpm
  exit 1
fi
unlock_rpm
true