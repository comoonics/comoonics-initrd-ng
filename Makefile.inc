#****h* comoonics-bootimage/Makefile.inc
#  NAME
#    Makefile.inc
#  DESCRIPTION
#    Makefile includes for the comoonics-bootimage
#*******

# Project: Makefile includes for projects documentations
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
#****d* Makefile/INSTALL_GRP
#  NAME
#    INSTALL_GRP
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
INSTALL_GRP="root"
#************ INSTALL_GRP 
#****d* Makefile/INSTALL_OWN
#  NAME
#    INSTALL_OWN
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
INSTALL_OWN="root"

#************ INSTALL_OWN 
#****d* Makefile/INSTALL_DIR
#  NAME
#    INSTALL_DIR
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
INSTALL_DIR=/opt/atix/comoonics_bootimage
#************ INSTALL_DIR 

#****d* Makefile/VERSION
#  NAME
#    VERSION
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
VERSION=5.0

#****d* Makefile/ARCHIVE_FILE
#  NAME
#    ARCHIVE_FILE
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
ARCHIVE_FILE=./$(PACKAGE_NAME)-$(VERSION).tar.gz
ARCHIVE_FILE_INITSCRIPTS=./$(PACKAGE_NAME)-initscripts-$(VERSION).tar.gz
#************ ARCHIVE_FILE 
#****d* Makefile/TAR_PATH
#  NAME
#    TAR_PATH
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
TAR_PATH=$(PACKAGE_NAME)-$(VERSION)/*
TAR_PATH_INITSCRIPTS=$(PACKAGE_NAME)-$(VERSION)/initscripts*
#************ TAR_PATH 

RPM_PACKAGE_DIR=$(shell rpmbuild --showrc | grep ": _topdir" | awk '{print $$3}')
RPM_PACKAGE_BIN_DIR=$(RPM_PACKAGE_DIR)/RPMS/*
RPM_PACKAGE_SRC_DIR=$(RPM_PACKAGE_DIR)/SRPMS
RPM_PACKAGE_SOURCE_DIR=$(RPM_PACKAGE_DIR)/SOURCES

# Which directories are used for installation
CHANNELBASEDIR=/atix/dist-mirrors
DISTROS=rhel5 rhel6 sles10 fedora sles11
SHORTDISTRO=rhel5
PRODUCTNAME=comoonics
PRODUCTVERSION=5.0
CHANNELNAMES=preview:base addons:extras
CHANNELDIR=$(CHANNELBASEDIR)/$(PRODUCTNAME)/$(PRODUCTVERSION)
ARCHITECTURES=i386 x86_64 noarch SRPMS
