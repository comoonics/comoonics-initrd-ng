#!/bin/bash

echo_local "*************************"
echo_local "Entering LiveCD"
echo_local "*************************"
sleep 3

depmod -a

loadSCSI

critical=0;

echo "Try to mount the cdrom"
for i in  hda hdb hdc hdd sda sdb sdc sde sdf sdg sdh; do
   echo "Probing /dev/$i ..."
   # SCHRAUBEREI !!!
   cd_dev=/dev/$i
   mount -t iso9660 /dev/$i /cdrom
   if test $? -eq 0; then echo "Found cdrom $cd_dev" && break; fi
done

#echo Mounting /dev/cdrom
#mount -t iso9660 /dev/hdc /cdrom
#mount /dev/hdc /cdrom

step

echo  Mounting ramdisk
cat /cdrom/ramdisk.img > /dev/ram1
mount -o ro /dev/ram1 /mnt/newroot
e2label /dev/ram1 /

step 

echo Mounting Static
modprobe cloop file=/cdrom/static.img
mount -o ro /dev/cloop0 /mnt/newroot/STATIC
e2label /dev/cloop0 STATIC
step 

#mkdir -p /mnt/newroot/mnt/oldroot

#cd /mnt/newroot
pivot_root /mnt/newroot /mnt/newroot/mnt/oldroot

umount /mnt/oldroot/proc

if [ $critical -eq 0 ]; then
	exec /sbin/init < /dev/console 1>/dev/console 2>&1
else
	/rescue.sh
exec /bin/bash
fi

