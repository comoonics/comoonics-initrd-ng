#!/bin/bash
source ${prgdir:-/opt/atix/comoonics-bootimage/boot-scripts}/etc/std-lib.sh
sourceLibs ${prgdir:-/opt/atix/comoonics-bootimage/boot-scripts}

root=$(repository_get_value root)
distribution=$(repository_get_value distribution)

if [ -z "$root" ]; then
	echo_local_debug -n "Trying to guess root device from currently mounted filesystems.."
    root=$(get_filesystem / rootfs | awk '{print $1;}')  # exclude rootfs
    if [ -z "$root" ]; then
    	error "Could not detect rootfilesystem from running system."
    	exit 1
    fi
    echo_local_debug " $root"
    repository_store_value root $root
    if device_mapper_multipath_check $root; then
    	repository_store_value scsi_failover mapper
    else
        repository_store_value scsi_failover driver
    fi
fi
	