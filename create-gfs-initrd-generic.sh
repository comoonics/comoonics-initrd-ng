#****h* comoonics-bootimage/create-gfs-initrd-generic.sh
#  NAME
#    create-gfs-initrd-generic.sh
#    $id$
#  DESCRIPTION
#*******
#!/bin/bash
#
# $Id: create-gfs-initrd-generic.sh,v 1.12 2007-02-09 11:08:53 marc Exp $
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
. $(dirname $0)/create-gfs-initrd-lib.sh
if [ -e $(dirname $0)/boot-scripts/etc/boot-lib.sh ]; then
  source $(dirname $0)/boot-scripts/etc/boot-lib.sh
  initEnv
fi
exec 3>/dev/null
exec 4>/dev/null 5>/dev/null

PATH=${PATH}:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin

#****f* create-gfs-initrd-generic.sh/usage
#  NAME
#    usage
#  SYNOPSIS
#    function usage() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function usage() {
  echo "$0 -d dep_filename [-s initrdsize] [-m mountpoint] [-r rpm-list-file] [-b build-date-file] [-V] [-F] [-R] [-o] [-U] initrdname [kernel-version]"
}

#************ usage
#****f* create-gfs-initrd-generic.sh/getoptions
#  NAME
#    getoptions
#  SYNOPSIS
#    function getoptions() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function getoptions() {
    while getopts UoRFVvhm:fd:s:r:b: option ; do
	case "$option" in
	    v) # version
		echo "$0 Version "'$Revision: 1.12 $'
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
    initrdname=$1
    if [ -n "$2" ]; then kernel=$2; fi
}
#************ getoptions

#************ main
#****f* create-gfs-initrd-generic.sh/main
#  NAME
#    main
#  SYNOPSIS
#    function main()
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
initramfs=1

if [ -z "$1" ]; then
  usage
  exit
fi

cfg_file=/etc/comoonics/comoonics-bootimage.cfg

pwd=$(pwd)
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
  make_initrd $initrdname $size || (failure && rm $lockfile && exit $?)
  success

  echo -n "Mounting initrd ..."
  mount_initrd $initrdname $mountpoint || (failure && rm $lockfile && exit $?)
  success
fi

# extracting rpms
if [ -n "$rpm_filename" ] && [ -e "$rpm_filename" ]; then
  echo -n "Extracting rpms..."
  extract_all_rpms $rpm_filename $mountpoint $rpm_dir $verbose || echo "(WARNING)"
  success
fi

echo -n "Retreiving dependent files..."
# compiling marked perlfiles in this function
#dep_files=$(get_all_depfiles $dep_filename $verbose)

files=( $(get_all_files_dependent $dep_filename $verbose | sort -u | grep -v "^.$" | grep -v "^..$") )
echo ${files[@]} | tr ' ' '\n' > ${mountpoint}/file-list.txt
echo -n "found ${#files[@]}" && success

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
success

# copying kernel modules
echo -n "Copying kernelmodules ($kernel)..."
if [ ! -d ${mountpoint}/lib/modules/$kernel ]; then
  mkdir -p ${mountpoint}/lib/modules/
fi
cp -a /lib/modules/$kernel ${mountpoint}/lib/modules/$kernel || (failure && rm $lockfile && exit $?)
success

create_builddate_file $build_file && success || failure

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
    cd $pwd
  fi
else
  if [ -e ${mountpoint}/linuxrc ] && [ ! -e ${mountpoint}/init ]; then
    cd $mountpoint && ln -s linuxrc init
    cd $pwd
  fi
fi
success

if [ -z "$initramfs" ] || [ $initramfs -eq 0 ]; then
  cd $pwd
  echo -n "Unmounting and compressing.."
  (chown -R root:root $mountpoint && umount_and_zip_initrd $mountpoint $initrdname $force && \
   rm $lockfile) || (failure && rm $lockfile && exit $?)
else
  echo -n "Cpio and compress.."
  (chown -R root:root $mountpoint && cpio_and_zip_initrd $mountpoint $initrdname $force && \
   rm $lockfile) || (failure && rm $lockfile && exit $?)
fi
success

cd $pwd
if [ -z "$no_remove_tmp" ]; then
  echo -n "Cleaning up ($mountpoint, $no_remove_tmp)..."
  rm -fr $mountpoint
  success
fi
ls -lk $initrdname
#************ main

##########################################
# $Log: create-gfs-initrd-generic.sh,v $
# Revision 1.12  2007-02-09 11:08:53  marc
# creating builddate_file with predefined function
#
# Revision 1.11  2006/08/28 16:01:45  marc
# support for rpm-lists and includes of new lists
#
# Revision 1.10  2006/07/13 11:35:36  marc
# new version changing file xtensions
#
# Revision 1.9  2006/06/19 15:55:28  marc
# rewriten and debuged parts of generating deps. Added @include tag for depfiles.
#
# Revision 1.8  2006/06/07 09:42:23  marc
# *** empty log message ***
#
# Revision 1.7  2006/05/03 12:47:10  marc
# added documentation
#
# Revision 1.6  2006/02/03 12:39:27  marc
# preset includes.
# Changed bug for build initrd with loopfs
#
# Revision 1.5  2006/01/25 14:57:42  marc
# new build process bugfixes
#
