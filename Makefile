#****h* comoonics-bootimage/Makefile
#  NAME
#    Makefile
#    $id$
#  DESCRIPTION
#    Makefile for the comoonics-bootimage
#*******

# Project: Makefile for projects documentations
# $Id: Makefile,v 1.20 2006-12-04 17:38:33 marc Exp $
#
# @(#)$file$
#
# Copyright (c) 2001 ATIX GmbH.
# Einsteinstrasse 10, 85716 Unterschleissheim, Germany
# All rights reserved.
#
# This software is the confidential and proprietary information of ATIX
# GmbH. ("Confidential Information").  You shall not
# disclose such Confidential Information and shall use it only in
# accordance with the terms of the license agreement you entered into
# with ATIX.
#
# Makefile for building the documentation

#****d* Makefile/PREFIX
#  NAME
#    PREFIX
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
PREFIX=/

#************ PREFIX 
#****d* Makefile/VERSION
#  NAME
#    VERSION
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
VERSION=1.0

#************ VERSION 
#****d* Makefile/PACKAGE_NAME
#  NAME
#    PACKAGE_NAME
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
PACKAGE_NAME=bootimage

#************ PACKAGE_NAME 
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
#****d* Makefile/EXEC_FILES
#  NAME
#    EXEC_FILES
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
EXEC_FILES=create-gfs-initrd-generic.sh \
  mkservice_for_initrd.sh \
  boot-scripts/linuxrc \
  boot-scripts/linuxrc.generic.sh \
  boot-scripts/linuxrc.bash \
  boot-scripts/exec_part_from_bash.sh \
  boot-scripts/detectHardware.sh \
  boot-scripts/rescue.sh
#************ EXEC_FILES 

#****d* Makefile/LIB_FILES
#  NAME
#    LIB_FILES
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
LIB_FILES=create-gfs-initrd-lib.sh \
  boot-scripts/etc/inittab \
  boot-scripts/etc/passwd \
  boot-scripts/etc/atix.txt \
  boot-scripts/etc/boot-lib.sh \
  boot-scripts/etc/gfs-lib.sh \
  boot-scripts/etc/comoonics-release \
  boot-scripts/etc/iscsi-lib.sh \
  boot-scripts/etc/fenced_mv_files.list \
  boot-scripts/etc/fenced_cp_files.list \
  boot-scripts/etc/fenced_dirs.list \
  boot-scripts/etc/sysconfig/comoonics \
  boot-scripts/etc/clusterfs-lib.sh \
  boot-scripts/etc/hardware-lib.sh \
  boot-scripts/etc/network-lib.sh \
  boot-scripts/etc/rhel4/hardware-lib.sh \
  boot-scripts/etc/rhel4/network-lib.sh \
  boot-scripts/etc/sles8/hardware-lib.sh \
  boot-scripts/etc/sles8/network-lib.sh
#************ LIB_FILES 
#****d* Makefile/SYSTEM_CFG_DIR
#  NAME
#    SYSTEM_CFG_DIR
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
SYSTEM_CFG_DIR=/etc/comoonics
#************ SYSTEM_CFG_DIR 
#****d* Makefile/SYSTEM_CFG_FILES
#  NAME
#    SYSTEM_CFG_FILES
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
SYSTEM_CFG_FILES=comoonics-$(PACKAGE_NAME).cfg
# subdirs are all in root
#************ SYSTEM_CFG_FILES 
#****d* Makefile/CFG_DIR
#  NAME
#    CFG_DIR
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
CFG_DIR=$(SYSTEM_CFG_DIR)/$(PACKAGE_NAME)
#************ CFG_DIR 
#****d* Makefile/CFG_FILES
#  NAME
#    CFG_FILES
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
CFG_FILES=basefiles.list \
	rpms.list \
	files.initrd.d/configs.list \
	files.initrd.d/scsi.list \
	files.initrd.d/gfs.list \
	files.initrd.d/iscsi.list.opt \
	files.initrd.d/lilo.list.opt \
	files.initrd.d/hp_tools.list.opt \
	files.initrd.d/user_edit.list \
	files.initrd.d/perlcc.list.opt \
	files.initrd.d/grub.list \
	files.initrd.d/libs.list.x86_64 \
	files.initrd.d/libs.list.i686 \
	files.initrd.d/fence_vmware.list.opt \
	files.initrd.d/debug.list.opt \
	rpms.initrd.d/comoonics.list \
	rpms.initrd.d/perl.list \
	rpms.initrd.d/python.list
#************ CFG_FILES 

#****d* Makefile/EMPTY_DIRS
#  NAME
#    EMPTY_DIRS
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
EMPTY_DIRS=boot-scripts/mnt \
 boot-scripts/sys \
 boot-scripts/var/log \
 boot-scripts/var/lock \
 boot-scripts/var/lib/dhcp \
 boot-scripts/var/run/netreport \
 boot-scripts/proc \
 boot-scripts/dev

#************ EMPTY_DIRS 
#****d* Makefile/INIT_FILES
#  NAME
#    INIT_FILES
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
INIT_FILES=bootsr \
preccsd \
fenced-chroot \
ccsd-chroot

#************ INIT_FILES 
#****d* Makefile/ARCHIVE_FILE
#  NAME
#    ARCHIVE_FILE
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
ARCHIVE_FILE=./comoonics-$(PACKAGE_NAME)-$(VERSION).tar.gz
#************ ARCHIVE_FILE 
#****d* Makefile/TAR_PATH
#  NAME
#    TAR_PATH
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
TAR_PATH=comoonics-$(PACKAGE_NAME)-$(VERSION)/*
#************ TAR_PATH 

.PHONY: install
install:
	@echo -n "Installing executables..."
	@if [ -n "$(EXEC_FILES)" ]; then \
	  ((install -d $(PREFIX)/$(INSTALL_DIR) && \
	   for file in $(EXEC_FILES); do \
             if [ ! -e $(PREFIX)/$(INSTALL_DIR)/`dirname $$file` ]; then \
               install -d  -g $(INSTALL_GRP) -o $(INSTALL_OWN) $(PREFIX)/$(INSTALL_DIR)/`dirname $$file`; \
             fi; \
	     install -g $(INSTALL_GRP) -o $(INSTALL_OWN) $$file $(PREFIX)/$(INSTALL_DIR)/$$file; \
	   done && \
	   echo "DONE") || echo "(FAILED)") \
	fi
	@if [ -n "$(LIB_FILES)" ]; then \
	   ((echo -n "Installing libs..." && \
	   for lib in $(LIB_FILES); do \
             if [ ! -e $(PREFIX)/$(INSTALL_DIR)/`dirname $$lib` ]; then \
               install -d  -g $(INSTALL_GRP) -o $(INSTALL_OWN) $(PREFIX)/$(INSTALL_DIR)/`dirname $$lib`; \
             fi; \
             install -g $(INSTALL_GRP) -o $(INSTALL_OWN) $$lib $(PREFIX)/$(INSTALL_DIR)/$$lib; \
	   done && \
	   echo "DONE") || \
	   echo "FAILED") \
	fi
	@if [ -n "$(SYSTEM_CFG_FILES)" ]; then \
	   ((echo -n "Installing system cfg-files..." && \
	     for cfgfile in $(SYSTEM_CFG_FILES); do \
               if [ ! -e $(PREFIX)/$(SYSTEM_CFG_DIR) ]; then \
                 install -d -g $(INSTALL_GRP) -o $(INSTALL_OWN) $(PREFIX)/$(SYSTEM_CFG_DIR); \
               fi; \
               install -g $(INSTALL_GRP) -o $(INSTALL_OWN) $$cfgfile $(PREFIX)/$(SYSTEM_CFG_DIR); \
	     done && \
	     echo "DONE") || \
	    echo "FAILED") \
	fi
	@if [ -n "$(CFG_FILES)" ]; then \
	   ((echo -n "Installing cfg-files..." && \
             cd system-cfg-files && \
             if [ ! -e $(PREFIX)/$(CFG_DIR) ]; then \
               install -d  -g $(INSTALL_GRP) -o $(INSTALL_OWN) $(PREFIX)/$(CFG_DIR); \
             fi; \
             if [ ! -e $(PREFIX)/$(CFG_DIR)/files.initrd.d/ ]; then \
               install -d  -g $(INSTALL_GRP) -o $(INSTALL_OWN) $(PREFIX)/$(CFG_DIR)/files.initrd.d/; \
             fi; \
             if [ ! -e $(PREFIX)/$(CFG_DIR)/rpms.initrd.d/ ]; then \
               install -d  -g $(INSTALL_GRP) -o $(INSTALL_OWN) $(PREFIX)/$(CFG_DIR)/rpms.initrd.d/; \
             fi; \
	     for cfgfile in $(CFG_FILES); do \
               install -g $(INSTALL_GRP) -o $(INSTALL_OWN) $$cfgfile $(PREFIX)/$(CFG_DIR)/`dirname $$cfgfile`; \
	     done && \
	     echo "DONE") || \
	     echo "FAILED" && cd ..) \
	fi
	@echo -n "Installing empty directories..."
	@if [ -n "$(EMPTY_DIRS)" ]; then \
	  (for dir in $(EMPTY_DIRS); do \
             if [ ! -e $(PREFIX)/$(INSTALL_DIR)/$$dir ]; then \
               install -d  -g $(INSTALL_GRP) -o $(INSTALL_OWN) $(PREFIX)/$(INSTALL_DIR)/$$dir; \
             fi; \
	   done && \
	   echo "DONE") || echo "(FAILED)"; \
	fi
	@echo -n "Installing init files..."
	@if [ -n "$(INIT_FILES)" ]; then \
	   (for file in $(INIT_FILES); do \
               install -D -g $(INSTALL_GRP) -o $(INSTALL_OWN) $$file $(PREFIX)/etc/rc.d/init.d/$$file; \
	   done && \
	   echo "DONE") || echo "(FAILED)"; \
	fi

archive:
	@echo -n "Creating Archive .. $(ARCHIVE_FILE)..."
	@(cd .. && \
	tar -c -z --exclude="*~" --exclude="*CVS*" -f $(ARCHIVE_FILE) $(TAR_PATH) && \
	echo "(OK)") || echo "(FAILED)"

########################################
# CVS-Log
# $Log: Makefile,v $
# Revision 1.20  2006-12-04 17:38:33  marc
# lockgulm files removed
# only fence_tool
#
# Revision 1.19  2006/10/19 10:08:07  marc
# bootsr: reload add
# ccsd-chroot: initial revision
# Makefile: ccsd-chroot added
# preccsd: support for cluster.conf moval
#
# Revision 1.18  2006/10/06 08:37:44  marc
# minor changes
#
# Revision 1.17  2006/08/28 16:02:33  marc
# very well tested version
#
# Revision 1.16  2006/08/02 12:24:59  marc
# minor change
#
# Revision 1.15  2006/07/13 14:32:57  mark
# added /dev
#
# Revision 1.14  2006/06/19 15:54:34  marc
# added new files
#
# Revision 1.13  2006/06/07 09:42:23  marc
# *** empty log message ***
#
# Revision 1.12  2006/05/07 12:06:56  marc
# version 1.0 stable
#
# Revision 1.11  2006/05/03 12:46:51  marc
# added documentation
#
# Revision 1.10  2006/04/13 18:46:11  marc
# added fencefiles
#
# Revision 1.9  2006/04/11 13:42:58  marc
# added x86_64 config file
#
# Revision 1.8  2006/02/16 13:59:15  marc
# added preccsd
#
# Revision 1.7  2006/01/25 14:57:11  marc
# new version for new files
#
# Revision 1.6  2006/01/23 14:02:49  mark
# added bootsr
#
# Revision 1.5  2005/07/08 13:15:57  mark
# added some files
#
# Revision 1.4  2005/06/27 14:24:20  mark
# added gfs 61, rhel4 support
#
# Revision 1.3  2005/06/08 13:33:22  marc
# new revision
#
# Revision 1.2  2005/01/05 10:54:53  marc
# added the files for ccsd in chroot.
#
# Revision 1.1  2005/01/03 08:33:17  marc
# first offical rpm version
# - initial revision
#
# Revision 1.1  2004/09/29 14:36:46  marc
# initial version
#
# Revision 1.1  2004/09/09 11:35:32  marc
# com-rescan-scsi.sh: major changes
#
#
########################################
