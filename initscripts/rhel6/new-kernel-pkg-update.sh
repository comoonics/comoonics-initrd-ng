#!/bin/bash
#
# Invoked upon installation or removal of a kernel package, the following
# tasks are/can be done here:
# creation/removal of initrd
# run of depmod/removal of depmod generated files
# addition/removal of kernel images from grub/lilo configuration (via grubby)
#
# Copyright (C) 2002-2005 Red Hat, Inc.
# Copyright (C) 2011 ATIX AG
# 

PATH=/sbin:/bin:$PATH

lilo=/sbin/lilo

# some defaults that are sane for most arches
kernelName=vmlinuz

if [ -x ./grubby ]; then
    grubby=./grubby
else
    grubby=/sbin/grubby
fi

#predir=$(dirname $(dirname $0))
predir=/opt/atix/comoonics-bootimage
source ${predir}/boot-scripts/etc/std-lib.sh
sourceLibs ${predir}/boot-scripts
sourceRootfsLibs ${predir}/boot-scripts

cfgGrub=""
cfgLilo=""
runLilo=""
grubConfig=""

ARCH=$(uname -m)
liloConfig=/etc/lilo.conf
grubConfig=/boot/grub/grub.conf
bootPrefix=/boot
liloFlag=lilo
isx86="yes"

mode=""
version=""
initrd=""
initrdfile=""
moddep=""
verbose=""
makedefault=""
package=""
mbkernel=""
mbargs=""

usage() {
    echo "Usage: `basename $0` [-v] [--mkinitrd] [--rminitrd] [--dracut]" >&2
    echo "       [--initrdfile=<initrd-image>] [--depmod] [--rmmoddep]" >&2
    echo "       [--kernel-args=<args>] [--remove-args=<args>]" >&2
    echo "       [--banner=<banner>] [--multiboot=multiboot]" >&2
    echo "       [--mbargs=mbargs] [--make-default] [--add-dracut-args]" >&2
    echo "       [--add-plymouth-initrd]" >&2
    echo "       [--host-only]" >&2
    echo "       <--install | --remove | --update | --rpmposttrans> <kernel-version>" >&2
    echo "       (ex: `basename $0` --mkinitrd --depmod --install 2.4.7-2)" >&2
    exit 1
}

install() {
    # XXX kernel should be able to be specified also (or work right on ia64)
    if [ ! -f $bootPrefix/$kernelName-$version ] ; then
	    [ -n "$verbose" ] && echo "[comoonics] kernel for $version does not exist, not running grubby"
	    return
    fi
    
    INITRD=""
    if [ -f $initrdfile ]; then
	    [ -n "$verbose" ] && echo "[comoonics] found $initrdfile and using it with grubby"
	    INITRD="--initrd $initrdfile"
    fi

    # get the root filesystem to use; if it's on a label make sure it's
    # been configured. if not, get the root device from mount
    rootdevice=$(awk '{ if ($1 !~ /^[ \t]*#/ && $2 == "/") { print $1; }}' /etc/fstab)
    [ -z "$rootdevice" ] && rootdevice=$(getParameter root $(clusterfs_getdefaults root))
    short=$(echo $rootdevice | cut -d= -f1)
    if [ "$short" == "LABEL" -o "$short" == "UUID" ]; then
	    device=$(echo resolveDevice "$rootdevice" | /sbin/nash  --forcequiet)
	    if [ -z "$rootdevice" ]; then
	        rootdevice=$(mount | awk '$3 == "/" { print $1 }')
	    fi
    fi

    if [ -n "$cfgGrub" ]; then
	    [ -n "$verbose" ] && echo "[comoonics] adding $version to $grubConfig"

	    if [ -n "$banner" ]; then
            title="$banner ($version)"
	    elif [ -f /etc/comoonics-release ]; then
	        title="$(sed 's/(.*)$/('$version')/' < /etc/comoonics-release)"
	    elif [ -f /etc/osr-release ]; then
	        title="$(sed 's/(.*)$/('$version')/' < /etc/osr-release)"
	    elif [ -f ${predir}/boot-scripts/etc/comoonics-release ]; then
	        title="$(sed 's/(.*)$/('$version')/' < ${predir}/boot-scripts/etc/comoonics-release)"
	    elif [ -f /etc/redhat-release ]; then
	        title="$(sed 's/ release.*$//' < /etc/redhat-release) ($version)"
	    else
	       title="Red Hat Linux ($version)"
	    fi
	    $grubby --add-kernel=$bootPrefix/$kernelName-$version \
	        $INITRD --copy-default $makedefault --title "$title" \
	        ${mbkernel:+--add-multiboot="$mbkernel"} ${mbargs:+--mbargs="$mbargs"} \
	        --args="root=$rootdevice $kernargs" --remove-kernel="TITLE=$title"
    else
	   [ -n "$verbose" ] && echo "[comoonics] $grubConfig does not exist, not running grubby"
    fi
    true
}

rpmposttrans()
{
    local files
    local f
    files="/etc/kernel/postinst.d/*[^~] /etc/kernel/postinst.d/$version/*[^~]"
    for f in $files ; do
        [ -f $f -a -x $f ] || continue
        $f $version $bootPrefix/$kernelName-$version
    done
}

remove() {
    if [ -n "$cfgGrub" ]; then
	    [ -n "$verbose" ] && echo "[comoonics] removing $version from $grubConfig"
	    $grubby --remove-kernel=$bootPrefix/$kernelName-$version
    else
	    [ -n "$verbose" ] && echo "[comoonics] $grubConfig does not exist, not running grubby"
    fi
    true
}

update() {
    if [ -n "$cfgGrub" ]; then
	    [ -n "$verbose" ] && echo "updating $version from $grubConfig"
	    $grubby --update-kernel=$bootPrefix/$kernelName-$version \
	        ${kernargs:+--args="$kernargs"} \
	        ${removeargs:+--remove-args="$removeargs"}	
    else
	    [ -n "$verbose" ] && echo "[comoonics] $grubConfig does not exist, not running grubby"
    fi
    true
}

mkinitrd() {
    [ -n "$verbose" ] && echo "[comoonics] creating initrd $initrdfile using $version"
    ${predir}/mkinitrd -F $initrdfile $version
    rc=$?
    if [ $rc != 0 ]; then
	    echo "[comoonics] mkinitrd failed" >&2
	    exit 1
    fi
}

rminitrd() {
    [ -n "$verbose" ] && echo "[comoonics] removing initrd $initrdfile"
    [ -f $initrdfile ] && rm -f $initrdfile
}

doDepmod() {
    [ -n "$verbose" ] && echo "[comoonics] running depmod for $version"
    depmod -ae -F /boot/System.map-$version $version
}

doRmmoddep() {
    [ -n "$verbose" ] && echo "[comoonics] removing modules.dep info for $version"
    [ -d /lib/modules/$version ] && rm -f /lib/modules/$version/modules.*    
}


while [ $# -gt 0 ]; do
    case $1 in
	    --mkinitrd)
	        initrd="make"
	        ;;

	    --rminitrd)
	        initrd="remove"
	        ;;

            --host-only)
                # nothing in this case
                ;;

	    --initrdfile*)
	        if echo $1 | grep '=' >/dev/null ; then
	    	    initrdfile=`echo $1 | sed 's/^--initrdfile=//'`
	        else
		        initrdfile=$2
		        shift
	        fi		    
	        ;;

	    --kernel-args*)
	        if echo $1 | grep '=' >/dev/null ; then
	    	    kernargs=`echo $1 | sed 's/^--kernel-args=//'`
	        else
		        kernargs=$2
		        shift
	        fi		    
	        ;;

	    --remove-args*)
	        if echo $1 | grep '=' >/dev/null ; then
	    	    removeargs=`echo $1 | sed 's/^--remove-args=//'`
	        else
		        removeargs=$2
		        shift
	        fi		    
	        ;;

	    --banner*)
	        if echo $1 | grep '=' >/dev/null ; then
	    	    banner=`echo $1 | sed 's/^--banner=//'`
	        else
		        banner=$2
		        shift
	        fi		    
	        ;;

	    --multiboot*)
	        if echo $1 |grep '=' >/dev/null; then
		        mbkernel=`echo $1 | sed 's/^--multiboot=//'`
	        else
		        # can't really support having an optional second arg here
		        # sorry!
		        mbkernel="/boot/xen.gz"
	        fi
 	        ;;

	    --mbargs*)
	        if echo $1 |grep '=' >/dev/null; then
		        mbargs=`echo $1 | sed 's/^--mbargs=//'`
	        else
		        mbargs="$2"
		        shift
	        fi
            ;;

	    --depmod)
	        moddep="make"
	        ;;

	    --rmmoddep)
	       moddep="remove"
	       ;;

	    --make-default)
	       makedefault="--make-default"
	       ;;

	    --package)
	       if echo $1 | grep '=' >/dev/null ; then
	    	  package=`echo $1 | sed 's/^--package=//'`
	       else
                  package=$2
	          shift
	       fi		    
	       ;;

            --dracut)
               # skip as we use comoonics
               ;;

            --add-dracut-args)
                adddracutargs=--add-dracut-args
                ;;

            --add-plymouth-initrd)
                addplymouthinitrd=--add-plymouth-initrd
                ;;

	    -v)
	       verbose=-v
	       ;;

	    *)
	       if [ -z "$mode" ]; then
		       mode=$1
	       elif [ -z "$version" ]; then
		       version=$1
	       else
		       usage
		       exit 1
	       fi
	       ;;
    esac

    shift
done

# make sure the mode is valid
if [ "$mode" != "--install" -a "$mode" != "--remove"  -a "$mode" != "--update" -a "$mode" != "--rpmposttrans" ] ; then
    usage
fi

if [ -z "$version" ]; then
    usage
fi

if [ "$mode" != "--install" -a "$makedefault" ]; then
    usage
fi

# set the initrd file based on arch; ia64 is the only currently known oddball
if [ -z "$initrdfile" ]; then
	initrdfile="/boot/initrd_sr-$version.img"
fi
[ -n "$verbose" ] && echo "[comoonics] initrdfile is $initrdfile"

# set this as the default if we have the package and it matches
if [ "$mode" == "--install" -a "$UPDATEDEFAULT" == "yes" -a -n "$package" -a -n "$DEFAULTKERNEL" -a "$package" == "$DEFAULTKERNEL" ]; then
    makedefault="--make-default"
    [ -n "$verbose" ] && echo "[comoonics] making it the default based on config"
fi

if [ "$moddep" == "make" ]; then
    doDepmod
elif [ "$moddep" == "remove" ]; then
    doRmmoddep
fi

if [ "$initrd" == "make" ]; then
    mkinitrd
elif [ "$initrd" == "remove" ]; then
    rminitrd
fi

if [ ! -x $grubby ] ; then
    [ -n "$verbose" ] && echo "$grubby does not exist"
    exit 0
fi


[ -n "$grubConfig" ] && [ -f "$grubConfig" ] && cfgGrub=1 || cfgGrub=0

if [ "$mode" == "--install" ] && [ $cfgGrub -eq 1 ]; then
    install
    exit 0
elif [ "$mode" == "--remove" ] && [ $cfgGrub -eq 1 ]; then
    remove
    exit 0
elif [ "$mode" == "--update" ] && [ $cfgGrub -eq 1 ]; then
    update
    exit 0
elif [ "$mode" == "--rpmposttrans" ]; then
    rpmposttrans
fi
