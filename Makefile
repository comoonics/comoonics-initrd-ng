# Project: Makefile for projects documentations
# $Id: Makefile,v 1.10 2006-04-13 18:46:11 marc Exp $
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

PREFIX=/

VERSION=0.4

PACKAGE_NAME=bootimage

INSTALL_GRP="root"
INSTALL_OWN="root"

INSTALL_DIR=/opt/atix/comoonics_bootimage
EXEC_FILES=create-gfs-initrd-generic.sh \
  boot-scripts/linuxrc \
  boot-scripts/linuxrc.generic.sh \
  boot-scripts/exec_part_from_bash.sh \
  boot-scripts/detectHardware.sh \
  boot-scripts/rescue.sh \
  boot-scripts/myifup.sh
LIB_FILES=create-gfs-initrd-lib.sh \
  boot-scripts/etc/inittab \
  boot-scripts/etc/atix.txt \
  boot-scripts/etc/modules.conf \
  boot-scripts/etc/boot-lib.sh \
  boot-scripts/etc/gfs-lib.sh \
  boot-scripts/etc/comoonics-release \
  boot-scripts/etc/iscsi-lib.sh \
  boot-scripts/etc/lock_gulmd_mv_files.list \
  boot-scripts/etc/lock_gulmd_cp_files.list \
  boot-scripts/etc/lock_gulmd_dirs.list \
  boot-scripts/etc/fence_tool_mv_files.list \
  boot-scripts/etc/fence_tool_cp_files.list \
  boot-scripts/etc/fence_tool_dirs.list \
  boot-scripts/etc/fenced_mv_files.list \
  boot-scripts/etc/fenced_cp_files.list \
  boot-scripts/etc/fenced_dirs.list \
  boot-scripts/etc/syslogd_mv_files.list \
  boot-scripts/etc/syslogd_cp_files.list \
  boot-scripts/etc/syslogd_dirs.list \
  boot-scripts/etc/ccsd_mv_files.list \
  boot-scripts/etc/ccsd_cp_files.list \
  boot-scripts/etc/ccsd_dirs.list \
  boot-scripts/etc/sysconfig/comoonics \
  boot-scripts/linuxrc.bash \
  boot-scripts/linuxrc.part.bash.sh \
  boot-scripts/linuxrc.part.gfs.sh \
  boot-scripts/linuxrc.part.livecd.sh \
  boot-scripts/linuxrc.part.urlsource.sh \
  boot-scripts/linuxrc.part.iscsi.sh \
  boot-scripts/linuxrc.part.install.sh

SYSTEM_CFG_DIR=/etc/comoonics
SYSTEM_CFG_FILES=comoonics-$(PACKAGE_NAME).cfg
# subdirs are all in root
CFG_DIR=$(SYSTEM_CFG_DIR)/$(PACKAGE_NAME)
CFG_FILES=system-cfg-files/gfs6-es30-files.i686.list \
  system-cfg-files/gfs61-es40-files.i686.list \
  system-cfg-files/gfs61-es40-files.x86_64.list

EMPTY_DIRS=boot-scripts/mnt \
 boot-scripts/sys \
 boot-scripts/var/log \
 boot-scripts/var/lib/dhcp \
 boot-scripts/var/run/netreport \
 boot-scripts/proc

INIT_FILES=bootsr \
preccsd \
fenced-chroot

ARCHIVE_FILE=./comoonics-$(PACKAGE_NAME)-$(VERSION).tar.gz
TAR_PATH=comoonics-$(PACKAGE_NAME)-$(VERSION)/*

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
               install -d  -g $(INSTALL_GRP) -o $(INSTALL_OWN) $(PREFIX)/$(SYSTEM_CFG_DIR); \
             fi; \
             install -g $(INSTALL_GRP) -o $(INSTALL_OWN) $$cfgfile $(PREFIX)/$(SYSTEM_CFG_DIR); \
	   done && \
	   echo "DONE") || \
	   echo "FAILED") \
	fi
	@if [ -n "$(CFG_FILES)" ]; then \
	   ((echo -n "Installing cfg-files..." && \
	   for cfgfile in $(CFG_FILES); do \
             if [ ! -e $(PREFIX)/$(CFG_DIR) ]; then \
               install -d  -g $(INSTALL_GRP) -o $(INSTALL_OWN) $(PREFIX)/$(CFG_DIR); \
             fi; \
             install -g $(INSTALL_GRP) -o $(INSTALL_OWN) $$cfgfile $(PREFIX)/$(CFG_DIR); \
	   done && \
	   echo "DONE") || \
	   echo "FAILED") \
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
               install -D -g $(INSTALL_GRP) -o $(INSTALL_OWN) $$file $(PREFIX)/etc/init.d/$$file; \
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
# Revision 1.10  2006-04-13 18:46:11  marc
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
