#!/bin/bash
source ${prgdir:-/opt/atix/comoonics-bootimage/boot-scripts}/etc/std-lib.sh
sourceLibs ${prgdir:-/opt/atix/comoonics-bootimage/boot-scripts}

rootdev=${root:-$(repository_get_value root)}
scsi_failover=$(repository_get_value scsi_failover driver)
if [ -n "$rootdev" ] && [ -e "$rootdev" ]; then
    if lvm_check $rootdev; then
        vgname=$(lvm_get_vg $rootdev)
        if [ -n "$vgname" ]; then
            rootdev=$(pvs -a | awk '$2=="vg_axqad124" { print $1; }')
        fi
    fi
    if device_mapper_multipath_check $rootdev; then
        echo_local_debug "Detected device mapper multipath as root device.."
        repository_store_value scsi_failover mapper
    fi
fi