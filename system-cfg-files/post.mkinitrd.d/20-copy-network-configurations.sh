#!/bin/bash

prgdir=${prgdir:-/opt/atix/comoonics-bootimage/boot-scripts}
source ${prgdir}/etc/std-lib.sh
sourceLibs ${prgdir}

networkconfigdir=${networkconfigdir:-/etc/comoonics/bootimage/network}
networkconfigfilter=${networkconfigfilter:-'ifcfg*'}
CONFDIR=$(repository_get_value confdir)
for nodeid in $(cc_get_nodeids); do 
  if [ -d "${networkconfigdir}/${nodeid}" ]; then
    for nicconfig in ${networkconfigdir}/${nodeid}/${networkconfigfilter}; do
      [ -d ${DEST_PATH}/${CONFDIR}/network ] || mkdir -p ${DEST_PATH}/${CONFDIR}/network
      echo_local_debug "Copying $nicconfig => ${DEST_PATH}/${CONFDIR}/network/${nicconfig}.${nodeid}"
      cp $nicconfig ${DEST_PATH}/${CONFDIR}/network/$(basename ${nicconfig}).${nodeid} 
    done
  fi
done
unset networkconfigdir networkconfigfilter
true
