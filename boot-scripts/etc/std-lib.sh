#
# $Id: std-lib.sh,v 1.5 2008-11-18 08:43:06 marc Exp $
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
#****h* comoonics-bootimage/stdfs-lib.sh
#  NAME
#    std-lib.sh
#    $id$
#  DESCRIPTION
#    Library for std operations
#*******

#****f* boot-lib.sh/initEnv
#  NAME
#    initEnv
#  SYNOPSIS
#    function initEnv() {
#  DESCRIPTION
#    Initializes basic things
#  IDEAS
#  SOURCE
#
function initEnv {
  # copied from redhat /etc/init.d/functions
  TEXTDOMAIN=initscripts

  # Make sure umask is sane
  umask 022

  # Get a sane screen width
  [ -z "${COLUMNS:-}" ] && COLUMNS=80

  [ -z "${CONSOLETYPE:-}" ] && [ -e "$CONSOLETYPE" ] && CONSOLETYPE="`/sbin/consoletype`"

  if [ -f /etc/sysconfig/i18n -a -z "${NOLOCALE:-}" ] ; then
    . /etc/sysconfig/i18n
    if [ "$CONSOLETYPE" != "pty" ]; then
      case "${LANG:-}" in
        ja_JP*|ko_KR*|zh_CN*|zh_TW*|bn_*|bd_*|pa_*|hi_*|ta_*|gu_*)
          export LC_MESSAGES=en_US
          export LANG
        ;;
      *)
        export LANG
        ;;
      esac
    else
      [ -n "$LC_MESSAGES" ] && export LC_MESSAGES
      export LANG
    fi
  fi

  # Read in our configuration
  if [ -z "${BOOTUP:-}" ]; then
    if [ -f /etc/sysconfig/init-comoonics ]; then
      . /etc/sysconfig/init-comoonics
    else
      # This all seem confusing? Look in /etc/sysconfig/init,
      # or in /usr/doc/initscripts-*/sysconfig.txt
      BOOTUP=color
      RES_COL=60
      MOVE_TO_COL="echo -en \\033[${RES_COL}G"
      SETCOLOR_SUCCESS="echo -en \\033[1;34m"
      SETCOLOR_FAILURE="echo -en \\033[1;31m"
      SETCOLOR_WARNING="echo -en \\033[1;35m"
      SETCOLOR_NORMAL="echo -en \\033[0;39m"
      LOGLEVEL=1
    fi
    if [ "$CONSOLETYPE" = "serial" ]; then
      BOOTUP=serial
      MOVE_TO_COL=
      SETCOLOR_SUCCESS=
      SETCOLOR_FAILURE=
      SETCOLOR_WARNING=
      SETCOLOR_NORMAL=
    fi
  fi

  if [ "${BOOTUP:-}" != "verbose" ]; then
    INITLOG_ARGS="-q"
  else
    INITLOG_ARGS=
  fi
}
#********** initEnv


#****f* boot-lib.sh/return_code
#  NAME
#    return_code
#  SYNOPSIS
#    function return_code() {
#  DESCRIPTION
#    Displays the actual return code. Either from $1 if given or from $?
#  SOURCE
#
function return_code {
  if [ -n "$1" ]; then
    return_c=$1
  fi
  if [ -n "$return_c" ] && [ $return_c -eq 0 ]; then
    success
  else
    failure
  fi
  local code=$return_c
  return $code
}
#************ return_code

#****f* boot-lib.sh/return_code_warning
#  NAME
#    return_code_warning
#  SYNOPSIS
#    function return_code_warning() {
#  DESCRIPTION
#    Displays the actual return code. Warning instead of failed.
#    Either from $1 if given or from $?
#  SOURCE
#
function return_code_warning() {
  if [ -n "$1" ]; then
    return_c=$1
  fi
  if [ -n "$return_c" ] && [ $return_c -eq 0 ]; then
    success
  else
    warning
  fi
}
#************ return_code_warning

#****f* boot-lib.sh/return_code_passed
#  NAME
#    return_code_passed
#  SYNOPSIS
#    function return_code_passed() {
#  DESCRIPTION
#    Displays the actual return code. Warning instead of failed.
#    Either from $1 if given or from $?
#  SOURCE
#
function return_code_passed() {
  if [ -n "$1" ]; then
    return_c=$1
  fi
  if [ -n "$return_c" ] && [ $return_c -eq 0 ]; then
    success
  else
    passed
  fi
}
#************ return_code_passed

#****f* boot-lib.sh/success
#  NAME
#    success
#  SYNOPSIS
#    function success()
#  DESCRIPTION
#    returns formated OK
#  SOURCE
function success {
  [ "$BOOTUP" = "color" ] && $MOVE_TO_COL
  echo -n "[  "
  echo -n "[  " >&3
#  echo -n "[  " >&5
  [ "$BOOTUP" = "color" ] && $SETCOLOR_SUCCESS
  echo -n "OK"
  echo -n "OK" >&3
#  echo -n "OK" >&5
  [ "$BOOTUP" = "color" ] && $SETCOLOR_NORMAL
  echo "  ]"
  echo "  ]" >&3
#  echo "  ]" >&5
  echo -ne "\r"
#  echo -ne "\r" >&3
  return 0
}
#********** success

#****f* boot-lib.sh/failure
#  NAME
#    failure
#  SYNOPSIS
#    function failure()
#  DESCRIPTION
#    returns formated FAILURE
#  SOURCE
function failure {
  [ "$BOOTUP" = "color" ] && $MOVE_TO_COL
  echo -n "["
  echo -n "[" >&3
#  echo -n "[" >&5
  [ "$BOOTUP" = "color" ] && $SETCOLOR_FAILURE
  echo -n "FAILED"
  echo -n "FAILED" >&3
#  echo -n "FAILED" >&5
  [ "$BOOTUP" = "color" ] && $SETCOLOR_NORMAL
  echo "]"
  echo -ne "\r"
  echo "]" >&3
#  echo "]" >&5
#  echo -ne "\r" >&3
  return 1
}
#********** warning

#****f* boot-lib.sh/warning
#  NAME
#    warning
#  SYNOPSIS
#    function warning()
#  DESCRIPTION
#    returns formated WARNING
#  SOURCE
function warning {
  [ "$BOOTUP" = "color" ] && $MOVE_TO_COL
  echo -n "["
  echo -n "[" >&3
#  echo -n "[" >&5
  [ "$BOOTUP" = "color" ] && $SETCOLOR_WARNING
  echo -n "WARNING"
  echo -n "WARNING" >&3
#  echo -n "WARNING" >&5
  [ "$BOOTUP" = "color" ] && $SETCOLOR_NORMAL
  echo "]"
  echo -ne "\r"
  echo "]" >&3
#  echo "]" >&5
#  echo -ne "\r" >&3
  return 1
}
#********** warning

#****f* boot-lib.sh/passed
#  NAME
#    passed
#  SYNOPSIS
#    function passed()
#  DESCRIPTION
#    returns formated PASSED
#  SOURCE
function passed {
  [ "$BOOTUP" = "color" ] && $MOVE_TO_COL
  echo -n "["
  echo -n "[" >&3
#  echo -n "[" >&5
  [ "$BOOTUP" = "color" ] && $SETCOLOR_WARNING
  echo -n "PASSED"
  echo -n "PASSED" >&3
#  echo -n "PASSED" >&5
  [ "$BOOTUP" = "color" ] && $SETCOLOR_NORMAL
  echo "]"
  echo -ne "\r"
  echo "]" >&3
#  echo "]" >&5
#  echo -ne "\r" >&3
  return 1
}
#********** passed
