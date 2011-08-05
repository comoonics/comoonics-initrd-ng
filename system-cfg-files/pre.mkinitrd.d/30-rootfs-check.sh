#!/bin/bash
source ${prgdir:-/opt/atix/comoonics-bootimage/boot-scripts}/etc/std-lib.sh
sourceLibs ${prgdir:-/opt/atix/comoonics-bootimage/boot-scripts}

rootfs=$(repository_get_value rootfs)
distribution=$(repository_get_value distribution)

if [ -z "$rootfs" ]; then
	echo_local_debug -n "Trying to guess root filesystem from currently mounted filesystems.."
    rootfs=$(get_filesystem / rootfs | awk '{print $3;}')  # exclude rootfs
    if [ -z "$rootfs" ]; then
    	error "Could not detect rootfilesystem from running system."
    	exit 1
    fi
    echo_local_debug " $rootfs"
    repository_store_value rootfs $rootfs
fi
	