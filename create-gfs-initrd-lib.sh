#****h* comoonics-bootimage/create-gfs-initrd-lib.sh
#  NAME
#    create-gfs-initrd-lib.sh
#    $id$
#  DESCRIPTION
#    Library for the creating of initrds for sharedroot
#*******
#
# $Id: create-gfs-initrd-lib.sh,v 1.13 2007-12-07 16:39:59 reiner Exp $
#
# @(#)$File$
#
# Copyright (c) 2001 ATIX GmbH, 2007 ATIX AG.
# Einsteinstrasse 10, 85716 Unterschleissheim, Germany
# All rights reserved.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

#

# TODO
# source boot-scripts/etc/chroot-lib.sh
# source boot-scripts/etc/stdfs-lib.sh

#****f* create-gfs-initrd-lib.sh/perlcc_file
#  NAME
#    perlcc_file
#  SYNOPSIS
#    function perlcc_file(perlfile, destfile) {
#  DESCRIPTION
#    Compiles the perlfile to a binary in destfile
#  IDEAS
#    To be used if special perlfiles are needed without puting all
#    perl things into the initrd.
#  SOURCE
#
function perlcc_file() {
  local filename=$1
  local destfile=$2
  [ -z "$destfile" ] && destfile=$filename
  echo "compiling(perlcc) $filename to ${destfile}..." >&2
  olddir=pwd
  cd $(dirname $destfile)
  perlcc $filename && mv a.out $destfile
}
#************ perlcc_file

#****f* create-gfs-initrd-lib.sh/make_initrd
#  NAME
#    make_initrd
#  SYNOPSIS
#    function make_initrd() {
#  DESCRIPTION
#    Creates a new memory filesystem initrd with the given size
#  IDEAS
#  SOURCE
#
function make_initrd() {
  local filename=$1
  local size=$2
  dd if=/dev/zero of=$filename bs=1k count=$size > /dev/null 2>&1 && \
  mkfs.ext2 -F -m 0 -i 2000 $filename > /dev/null 2>&1
}
#************ make_initrd

#****f* create-gfs-initrd-lib.sh/mount_initrd
#  NAME
#    mount_initrd
#  SYNOPSIS
#    function mount_initrd() {
#  DESCRIPTION
#    Mounts the given unpacked filesystem to the given directory
#  IDEAS
#  SOURCE
#
function mount_initrd() {
  local filename=$1
  local mountpoint=$2
  mount -o loop -t ext2 $filename $mountpoint > /dev/null 2>&1
}

#
# Unmounts the given loopback memory filesystem and zips it to the given file
#************ mount_initrd
#****f* create-gfs-initrd-lib.sh/umount_and_zip_initrd
#  NAME
#    umount_and_zip_initrd
#  SYNOPSIS
#    function umount_and_zip_initrd() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function umount_and_zip_initrd() {
  local mountpoint=$1
  local filename=$2
  local force=$3
  local opts=""
  local LODEV=$(mount | grep "^$mountpoint" | tail -1 | cut -f6 -d" " | cut -d"=" -f2)
  LODEV=$(echo ${LODEV/%\)/})
  [ -n "$force" ] && [ $force -gt 0 ] && opts="-f"
  (umount $mountpoint && \
   losetup -d $LODEV && \
   mv $filename ${filename}.tmp && \
   gzip $opts -c -9 ${filename}.tmp > $filename && rm ${filename}.tmp) || (fuser -mv "$mountpoint" && exit 1)
}

#
# Creates an imagefile with cpio and compresses it with zip
#************ umount_and_zip_initrd
#****f* create-gfs-initrd-lib.sh/cpio_and_zip_initrd
#  NAME
#    cpio_and_zip_initrd
#  SYNOPSIS
#    function cpio_and_zip_initrd() {
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
function cpio_and_zip_initrd() {
  local mountpoint=$1
  local filename=$2
  local force=$3
  local opts=""
  [ -n "$force" ] && [ $force -gt 0 ] && opts="-f"
  ((cd $mountpoint; find . | cpio --quiet -c -o) >| ${filename}.tmp && gzip $opts -c -9 ${filename}.tmp > $filename && rm ${filename}.tmp)|| (fuser -mv "$mountpoint" && exit 1)
}
#************ cpio_and_zip_initrd

######################
# $Log: create-gfs-initrd-lib.sh,v $
# Revision 1.13  2007-12-07 16:39:59  reiner
# Added GPL license and changed ATIX GmbH to AG.
#
# Revision 1.12  2007/08/06 16:02:17  mark
# reorganized files
# added rpm filter support
#
# Revision 1.11  2007/03/09 18:04:54  mark
# moved function to boot-lib.sh
#
# Revision 1.10  2007/02/09 11:09:31  marc
# cosmetic changes.
#
# Revision 1.9  2006/08/28 16:01:57  marc
# support for rpm-lists and includes of new lists
#
# Revision 1.8  2006/06/19 15:55:28  marc
# rewriten and debuged parts of generating deps. Added @include tag for depfiles.
#
# Revision 1.7  2006/06/07 09:42:23  marc
# *** empty log message ***
#
# Revision 1.6  2006/05/03 12:46:45  marc
# added documentation
#
