#!/bin/bash

prgdir=${prgdir:-/opt/atix/comoonics-bootimage/boot-scripts}
source ${prgdir}/etc/std-lib.sh
sourceLibs ${prgdir}

cdslinvadm=${cdslinvadm:-"/usr/bin/com-cdslinvadm"}
cdsltree="/"$($cdslinvadm get tree 2>/dev/null)
cdsllink="/"$($cdslinvadm get link 2>/dev/null)
distro=${distro:-$(repository_get_value distribution)}
networkconfigdir=${networkconfigdir:-$(${distro}_get_networkpath)}
networkconfigfilter=${networkconfigfilter:-'ifcfg*'}
CONFDIR=$(repository_get_value confdir)
if [ -d "${networkconfigdir}" ]; then
    [ -d ${DEST_PATH}/${CONFDIR}/network ] || mkdir -p ${DEST_PATH}/${CONFDIR}/network
    for nicconfig in ${networkconfigdir}/${networkconfigfilter}; do
        # If network configuration is cdsl copy all cdsl where they belong
        if cdslinfo=$($cdslinvadm getcdsl $nicconfig 2>/dev/null); then
            for nodeid in $(cc_get_nodeids); do 
                if [ -f "${cdsltree}/${nodeid}/${nicconfig}" ]; then
                    eval $(grep STARTMODE ${cdsltree}/${nodeid}/$nicconfig)
                    eval $(grep HWADDR ${cdsltree}/${nodeid}/$nicconfig)
                    if [ "${STARTMODE}" = "nfsroot" ]; then
                        echo_local_debug "Copying $nicconfig => ${DEST_PATH}/${CONFDIR}/network/${nicconfig}.${nodeid}"
                        (cat ${cdsltree}/${nodeid}/$nicconfig | grep -v "^ONBOOT="; echo "ONBOOT=yes";) > ${DEST_PATH}/${CONFDIR}/network/$(basename ${nicconfig}).${nodeid}
                    fi
                    if [ -n "$HWADDR" ]; then
                        HWADDR=$(echo $HWADDR | tr [A-Z] [a-z])
                        repository_append_value ${nodeid}_hwaddr $HWADDR
                    fi
                    unset STARTMODE HWADDR
                fi
            done
        else
            eval $(grep STARTMODE $nicconfig)
            if [ "${STARTMODE}" = "nfsroot" ]; then
                for nodeid in $(cc_get_nodeids); do 
                    if [ -f "${nicconfig}" ]; then
                        echo_local_debug "Copying $nicconfig => ${DEST_PATH}/${CONFDIR}/network/${nicconfig}.${nodeid}"
                        ( cat $nicconfig  | grep -v "^ONBOOT="; echo "ONBOOT=yes";) > ${DEST_PATH}/${CONFDIR}/network/$(basename ${nicconfig}).${nodeid} 
                    fi
                done
            fi
            unset STARTMODE
        fi
    done
fi
unset networkconfigdir networkconfigfilter
true