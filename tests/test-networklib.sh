if ! ( runoncerootfs || runonceclutype ); then
  path=$(dirname $0)
  [ -z "$distribution" ] && distribution="rhel5"
  ipconfig='10.0.0.1::1.2.3.4:255.255.255.0::eth0:00-0C-29-3B-XX-XX:::yes:e100:MASTER=no:SLAVE=no:BONDING_OPTS="miimon=100 mode=1"'
  resultfile=${path}/test/${distribution}/ifcfg-eth0
  if [ -e "$resultfile" ]; then
    echo -n "Testing function ip2Config for distribution: $distribution, clutype: $clutype, rootfs: $rootfs"
    networkpath="/tmp"
    ip2Config "$ipconfig"
    out=$(diff ${networkpath}/ifcfg-eth0 ${path}/test/${distribution}/ifcfg-eth0)
    detecterror $? "Generating ipcfg file for distribution $distribution failed. Diff: $out" || echo -n " Failed"
    echo
  else
    echo "Could not find network config file for distribution $distribution. Skipping."
  fi
fi