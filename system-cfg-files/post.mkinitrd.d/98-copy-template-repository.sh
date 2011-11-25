TEMPLATE_REPOSITORY_DIR=/var/cache/comoonics-bootimage/repository
[ -f /etc/comoonics/comoonics-bootimage.cfg ] && . /etc/comoonics/comoonics-bootimage.cfg

if [ -d $TEMPLATE_REPOSITORY_DIR ] && [ "$(ls -1 $TEMPLATE_REPOSITORY_DIR | wc -l)" -gt 0 ]; then
    echo_local_debug "Copying template repository from $TEMPLATE_REPOSITORY_DIR => $REPOSITORY_PATH.."
    cp $TEMPLATE_REPOSITORY_DIR/* $REPOSITORY_PATH
fi
true