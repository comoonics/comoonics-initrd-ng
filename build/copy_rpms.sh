#!/bin/bash
# copies all relevant rpms to the specific channel
CHANNELDISTRIBUTION=${1}
DESTDIR=$2
CHANNELCLASS=${3:-extras}
arch=${4:-noarch}
FILENAMEFILTER=${5:-comoonics-bootimage*}
RPMBUILDDIR=$6

is_newer() {
	local file1=$1
	local mtime1=""
	local file2=$2
	local mtime2=""

	if [ -z "$mtime1" ]; then
		mtime1=$(stat -c "%Y" $file1 2>/dev/null) || mtime1=""
	fi
	if [ -z "$mtime2" ]; then
		mtime2=$(stat -c "%Y" $file2 2>/dev/null) || mtime2=""
	fi

	if [ ! -e "$file1" ] || ( [ -n "$mtime1" ] && [ -n "$mtime2" ] && [ "$mtime1" -lt "$mtime2" ] ); then
		return 0
	else
		return 1
    fi	
}

usage() {
	cat <<EOF
$0 channeldistribution destdir [channelclass=${CHANNELCLASS}] [arch=${ARCH}] [filenamefilter=${FILENAMEFILTER}]
   destdir            : what destinationdirectory to copy to
   channeldistribution: what distribution: rhel4,rhel5,rhel6,sles10,sles11,fedora
   channelclass       : what kind of channel (base/extras), default: $CHANNELCLASS
   arch               : what architecture: noarch,i386,x86_64,SRPMS
   filenamefilter     : what to include: $FILENAMEFILTER
EOF
}

if [ $# -le 2 ] || [ $(echo "$1" | tr A-Z a-z) = "-h" ] || [ $(echo "$1" | tr A-Z a-z) = "--help" ]; then
	usage
	exit 1
fi
if [ ! -d "$DESTDIR" ]; then
	echo "Could not find destdir $DESTDIR."
	usage
	exit 2
fi
if [ "$arch" = "SRPMS" ]; then
  QUERYFORMAT='%{NAME}-%{VERSION}-%{RELEASE}.src.rpm;%{DISTRIBUTION};%{GROUP}\n'
else
  QUERYFORMAT='%{NAME}-%{VERSION}-%{RELEASE}.%{arch}.rpm;%{DISTRIBUTION};%{GROUP}\n'
fi

if [ "$arch" = "SRPMS" ]; then
    ARCH=$arch
    arch="src"
else
    ARCH="RPMS/$arch"
fi
   
RPMBUILDDIR=${RPMBUILDDIR:-$(rpmbuild --showrc | grep ": _topdir" | awk '{print $3}')/${ARCH}}

rpm -qp --queryformat=$QUERYFORMAT $RPMBUILDDIR/${FILENAMEFILTER}*${CHANNELDISTRIBUTION}.${arch}.rpm 2>/dev/null | while IFS=';' read filename distribution group; do
  filename=${RPMBUILDDIR}/$filename
  subgroup=$(echo "$group" | cut -f 3 -d/)
  group=$(echo "$group" | cut -f 2 -d/)
  echo "$group" | grep -i "${CHANNELCLASS}$" &>/dev/null
  if [ $? -eq 0 ] && [ -e "$filename" ]; then
    if is_newer $DESTDIR/$CHANNELDISTRIBUTION/$ARCH/$(basename $filename) $filename; then
      echo "$filename => $DESTDIR/$CHANNELDISTRIBUTION/$ARCH"
      cp $filename $DESTDIR/$CHANNELDISTRIBUTION/$ARCH
    fi
  fi
done
