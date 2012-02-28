#!/bin/bash
source ${prgdir:-/opt/atix/comoonics-bootimage/boot-scripts}/etc/std-lib.sh
source ${prgdir:-/opt/atix/comoonics-bootimage/boot-scripts}/etc/repository-lib.sh

for param in nodeids clutype rootfs; do
   echo_local_debug "Removing $param from repository."
   repository_del_value $param
done