#!/bin/bash

prgdir=${prgdir:-/opt/atix/comoonics-bootimage/boot-scripts}
source ${prgdir}/etc/std-lib.sh
sourceLibs ${prgdir}

cdsltabfile=${cdsltabfile:-/etc/cdsltab}

if [ -f "$cdsltabfile" ]; then
    repository_store_value cdsltabfile "$cdsltabfile"
    echo_local_debug "Copying $cdsltabfile => ${DEST_PATH}/etc/$cdsltabfile"
    cp $cdsltabfile ${DEST_PATH}/$cdsltabfile
fi
