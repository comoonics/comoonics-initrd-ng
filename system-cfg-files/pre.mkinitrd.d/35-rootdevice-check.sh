#!/bin/bash
source ${prgdir:-/opt/atix/comoonics-bootimage/boot-scripts}/etc/std-lib.sh
sourceLibs ${prgdir:-/opt/atix/comoonics-bootimage/boot-scripts}

root=$(repository_get_value root)
distribution=$(repository_get_value distribution)
fstab=${fstab:-/etc/fstab}

if [ -z "$root" ]; then
    echo_local_debug -n "Trying to guess root device from $fstab.."
    root=$(awk '
$2 == "/" {
    print $1;
}' $fstab)
    if [ -z "$root" ]; then
        echo_local_debug -n "Trying to guess root device from currently mounted filesystems.."
        root=$(get_filesystem / rootfs | awk '{print $1;}')  # exclude rootfs
        if [ -z "$root" ]; then
    	   error "Could not detect rootfilesystem from running system."
    	   exit 1
        fi
    fi
    if [ -z "$root" ]; then
        echo_local "Could not detect root filesystem."
        echo_local "You must specify root= as boot parameter."
    else
        echo_local_debug " $root"
        repository_store_value root $root
    fi
fi
	