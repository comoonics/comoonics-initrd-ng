#!/bin/sh
DESTDIR=$destpath/${REPOSITORY_PATH}

OLDREPO=${REPOSITORY_PATH}
REPOSITORY_PATH=$DESTDIR

if ! [ -d ${DESTDIR} ]; then
   mkdir -p ${DESTDIR}
fi

echo_local -n -N " cdsl env "
repository_store_value cdsl_prefix "$(com-mkcdslinfrastructure --get tree)"  &&
repository_store_value cdsl_local_dir "$(com-mkcdslinfrastructure --get link)" &&
REPOSITORY_PATH=${OLDREPO}
