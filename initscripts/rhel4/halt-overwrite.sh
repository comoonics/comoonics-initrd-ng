#
# Should overwrite halt_get_remaining needed by RHEL4 and RHEL5. 
# Those are not excluding more filesystems but we need the cdslinfrastructure and the chroot to be excluded. 
CDSL=$(com-mkcdslinfrastructure --get link | sed -e 's!\/!\\\/!g')
CHROOT=$(/opt/atix/comoonics-bootimage/manage_chroot.sh -p | sed -e 's!\/!\\\/!g')
halt_get_remaining() {
        awk '$2 ~ /^\/$|^\/proc|^\/dev/{next}
             $2 ~ /\/'$CDSL'/ { next }
             $2 ~ /\/'$CHROOT'/ { next }
             $3 == "tmpfs" || $3 == "proc" {print $2 ; next}
             /(^#|loopfs|autofs|sysfs|devfs|^none|^\/dev\/ram|^\/dev\/root)/ {next}
             {print $2}' /proc/mounts
}
