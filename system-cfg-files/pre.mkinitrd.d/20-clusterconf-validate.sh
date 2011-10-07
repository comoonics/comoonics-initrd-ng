#!/bin/bash
source ${prgdir:-/opt/atix/comoonics-bootimage/boot-scripts}/etc/std-lib.sh
sourceLibs ${prgdir:-/opt/atix/comoonics-bootimage/boot-scripts}

exec_local cc_validate
if [ $? -ne 0 ]; then
   errormsg err_cc_validate
   exit 10
fi
