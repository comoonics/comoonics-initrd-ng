#!/bin/sh
DESTDIR=$destpath

OLDREPO=${REPOSITORY_PATH}
REPOSITORY_PATH=$destpath

echo_local -n -N "Storing cdsl environment for rootfilesystem"
repository_store_value cdsl_prefix "$(com-mkcdslinfrastructure --get tree)"  &&
repository_store_value cdsl_local "$(com-mkcdslinfrastructure --get link)" &&
return_code $?
echo_local
REPOSITORY_PATH=${OLDREPO}
