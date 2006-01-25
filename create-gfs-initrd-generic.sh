#!/bin/bash
#
# $Id: create-gfs-initrd-generic.sh,v 1.5 2006-01-25 14:57:42 marc Exp $
#
# @(#)$File$
#
# Copyright (c) 2001 ATIX GmbH.
# Einsteinstrasse 10, 85716 Unterschleissheim, Germany
# All rights reserved.
#
# This software is the confidential and proprietary information of ATIX
# GmbH. ("Confidential Information").  You shall not
# disclose such Confidential Information and shall use it only in
# accordance with the terms of the license agreement you entered into
# with ATIX.
#
. `dirname $0`/create-gfs-initrd-lib.sh

function usage() {
  echo "$0 -d dep_filename [-s initrdsize] [-m mountpoint] [-r rpm-list-file] [-b build-date-file] [-V] [-F] [-R] [-o] [-U] initrdname [kernel-version]"
}

function getoptions() {
    while getopts UoRFVvhm:fd:s:r:b: option ; do
	case "$option" in
	    v) # version
		echo "$0 Version "'$Revision: 1.5 $'
		exit 0
		;;
	    h) # help
		usage
		exit 0
		;;
	    m) # tempmount
		mountpoint="$OPTARG"
		;;
	    f) # force
		force=1
		;;
	    d) # depfile
		dep_filename="$OPTARG"
		;;
	    s) # size
		size="$OPTARG"
		;;
	    r ) # rpm-list
		rpm_list="$OPTARG"
		;;
	    b) # release file
		build_file="$OPTARG"
		;;
            V) # verbose mode
                verbose=1
                ;;
            F) # ignore locks
               Force=1
               ;;
            o) # use old initrd method
               initramfs=0
               ;;
            R) # don't remove temp dirs
               no_remove_tmp=1
	       ;;
            U) # only update
	       update=1
               ;;
	    *)
		echo "Error wrong option."
		exit 1
		;;
	esac
    done
    shift $(($OPTIND - 1))
    initrdname=$(echo $1 | sed s/.gz$//)
    if [ -n "$2" ]; then kernel=$2; fi
}

initramfs=1

if [ -z "$1" ]; then
  usage
  exit
fi

cfg_file=/etc/comoonics/comoonics-bootimage.cfg

cwd=$(pwd)
force=0
TMPDIR=/tmp
mountpoint=$(mktemp -d ${TMPDIR}/initrd.mnt.XXXXXX)
#size=32768
size=120000
kernel=$(uname -r)

if [ ${1:0:1} = "--" ]; then
    echo "detected request for old version of mkinitrd."
    echo "Params: $*"
    /sbin/mkinitrd $*
    exit $?
fi

source ${cfg_file}
getoptions $*

prgdir=$(dirname $0)
lockfile=${prgdir}/.building_initrd

if [ -e $lockfile ] && [ -z "$Force" ]; then
  echo "Lockfile $lockfile exists. Another $0 is running. Please fix.."
  echo "..or start with force mode."
  exit 1
fi
touch $lockfile

kernelmajor=`echo $kernel | cut -d . -f 1,2`

if [ "$kernelmajor" == "2.4" ] || [ "$initramfs" -eq 0 ]; then
    if [ -n "$verbose" ]; then echo "Creating old-style initrd"; fi
    USE_UDEV=
    RCFILE=$MNTIMAGE/linuxrc
else
    if [ -n "$verbose" ]; then echo "Creating initramfs"; fi
    modulefile=/etc/modprobe.conf
    initramfs=1
    RCFILE=$MNTIMAGE/init
fi

#if [ -e $netenv_file ]; then . $netenv_file; fi

if [ -z "$dep_filename" ] || [ ! -e "$dep_filename" ]; then
  echo "No depfile given. A dep_file is required."
  usage
  rm $lockfile
  exit 1
fi

if [ -z "$initramfs" ] || [ $initramfs -eq 0 ]; then
  echo -n "Makeing initrd ..."
  make_initrd $initrdname $size || (echo "(FAILED)" && rm $lockfile && exit $?)
  echo "(OK)"

  echo -n "Mounting initrd ..."
  mount_initrd $initrdname $mountpoint || (echo "(FAILED)" && rm $lockfile && exit $?)
  echo "(OK)"
fi

# extracting rpms
if [ -n "$rpm_list" ]; then
  echo -n "Extracting rpms..."
  extract_all_rpms $rpm_list $mountpoint || (echo "(FAILED)" && rm $lockfile && exit $?)
  echo "(OK)"
fi

echo -n "Retreiving dependent files..."
# compiling marked perlfiles in this function
files=( $(get_all_files_dependent $dep_filename $verbose | sort -u | grep -v "^.$" | grep -v "^..$") )
echo ${files[@]} | tr ' ' '\n' > ${mountpoint}/file-list.txt
echo "found ${#files[@]} (OK)"

echo -n "Copying files..."
cd $mountpoint
i=0
while [ $i -lt ${#files[@]} ]; do
  file=${files[$i]}
  if [ -d $file ]; then 
#    echo "Directory $file => ${mountpoint}/$file"
    create_dir ${mountpoint}/$file
    copy_file $file ${mountpoint}/$(dirname $file)
  elif [ ! -e "$file" ] && [ "$file" = '@map' ]; then
    i=$(( $i+1 ))
    file=${files[$i]}
    i=$(( $i+1 ))
    todir=${files[$i]}
    if [ -d $file ]; then 
      [ -n "$verbose" ] && echo "Directory mapping $file => ${mountpoint}/$todir"
      create_dir ${mountpoint}/$todir
      for file2 in $(ls -1 $file/*); do 
         copy_file $file/\* ${mountpoint}/$todir/
      done
    else
      dirname=`dirname $file`
      create_dir ${mountpoint}$todir
      copy_file $file ${mountpoint}$todir
    fi
  else
    dirname=`dirname $file`
    create_dir ${mountpoint}$dirname
    copy_file $file ${mountpoint}$dirname
  fi
  i=$(( $i+1 ))
done
echo "(OK)"

# copying kernel modules
echo -n "Copying kernelmodules ($kernel)..."
if [ ! -d ${mountpoint}/lib/modules/$kernel ]; then 
  mkdir -p ${mountpoint}/lib/modules/
fi
cp -a /lib/modules/$kernel ${mountpoint}/lib/modules/$kernel || (echo "(FAILED)" && rm $lockfile && exit $?)
echo "(OK)"

# patching build file
if [ -n "$build_file" ]; then
    echo -n "Patching buildfile \"$build_file\"..."
    (echo "Build Date: "$(date) >> ${mountpoint}/$build_file && echo "(OK)") || echo "(FAILED)"
fi


#for module in $FC_MODULE $FC_MODULES $GFS_MODULES; do
#  dirname=`dirname ${MODULES_DIR}/${module}`
#  create_dir ${mountpoint}$dirname
#  copy_file ${MODULES_DIR}/${module} ${mountpoint}$dirname
#done

#echo "The following files reside on the image:"
#find .
echo -n "Post settings .."
chown -R root:root $mountpoint
if [ -z "$initramfs" ] || [ $initramfs -eq 0 ]; then
  if [ ! -e ${mountpoint}/linuxrc ] && [ -e ${mountpoint}/init ]; then
    cd $mountpoint && ln -s init linuxrc
    cd $cwd
  fi
else
  if [ -e ${mountpoint}/linuxrc ] && [ ! -e ${mountpoint}/init ]; then
    cd $mountpoint && ln -s linuxrc init
    cd $cwd
  fi
fi
echo "(OK)"

if [ -z "$initramfs" ] || [ $initramfs -eq 0 ]; then
  echo -n "Unmounting and compressing.."
  (chown -R root:root $mountpoint && umount_and_zip_initrd $mountpoint $initrdname $force && \
   rm $lockfile) || (echo "(FAILED)" && rm $lockfile && exit $?)
else
  echo -n "Cpio and compress.."
  (chown -R root:root $mountpoint && cpio_and_zip_initrd $mountpoint $initrdname $force && \
   rm $lockfile) || (echo "(FAILED)" && rm $lockfile && exit $?)
fi
echo "(OK)"

cd $cwd
if [ -z "$no_remove_tmp" ]; then
  echo -n "Cleaning up ($mountpoint, $no_remove_tmp)..."
  rm -fr $mountpoint
  echo "(OK)"
fi
ls -lk $initrdname.gz

##########################################
# $Log: create-gfs-initrd-generic.sh,v $
# Revision 1.5  2006-01-25 14:57:42  marc
# new build process bugfixes
#
