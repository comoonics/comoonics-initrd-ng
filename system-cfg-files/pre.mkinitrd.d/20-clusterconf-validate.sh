#!/bin/bash
source ${prgdir:-/opt/atix/comoonics-bootimage/boot-scripts}/etc/std-lib.sh
sourceLibs ${prgdir:-/opt/atix/comoonics-bootimage/boot-scripts}

echo_local -n -N "Validating cluster configuration."
exec_local cc_validate
return_code
if [ $? -ne 0 ]; then
   errormsg err_cc_validate
   exit 10
fi
