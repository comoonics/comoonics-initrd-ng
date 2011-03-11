#!/bin/sh

# setup the initrd path.
[ -n "$1" ] && initdir=$1
[ -z "$initdir" ] && initdir=$destpath
echo_local -N -n " nfs-deps "
if [ -n "$initdir" ] && [ -d "$initdir" ]; then
  # Rather than copy the passwd file in, just set a user for rpcbind
  # We'll save the state and restart the daemon from the root anyway
  [ -d "$initdir/etc" ] || mkdir $initdir/etc
  [ -e "$initdir/etc/passwd" ] || touch "$initdir/etc/passwd"
  egrep '^root:' "$initdir/etc/passwd" &>/dev/null || echo  'root:x:0:0::/:/bin/sh' >> "$initdir/etc/passwd"
  egrep '^nobody:' /etc/passwd >> "$initdir/etc/passwd"
  egrep '^nfsnobody:' /etc/passwd >> "$initdir/etc/passwd"
  egrep '^rpc:' /etc/passwd >> "$initdir/etc/passwd"
  egrep '^rpcuser:' /etc/passwd >> "$initdir/etc/passwd"
fi