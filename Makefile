#****h* comoonics-bootimage/Makefile
#  NAME
#    Makefile
#    $id$
#  DESCRIPTION
#    Makefile for the comoonics-bootimage
#*******

# Project: Makefile for projects documentations
# $Id: Makefile,v 1.71 2011-02-14 16:43:46 marc Exp $
#
# @(#)$file$
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
VERSION=1.4

#************ VERSION 
#****d* Makefile/PACKAGE_NAME
#  NAME
#    PACKAGE_NAME
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
PACKAGE_NAME=comoonics-bootimage

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
  manage_chroot.sh \
  com-chroot \
  boot-scripts/com-halt.sh \
  boot-scripts/com-realhalt.sh \
  boot-scripts/linuxrc \
  boot-scripts/linuxrc.generic.sh \
  boot-scripts/linuxrc.bash \
  boot-scripts/linuxrc.sim.sh \
  boot-scripts/detectHardware.sh \
  boot-scripts/rescue.sh \
  boot-scripts/make_tar.sh \
  boot-scripts/update-from-url.sh
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
  boot-scripts/etc/issue \
  boot-scripts/etc/atix.txt \
  boot-scripts/etc/atix-logo.txt \
  boot-scripts/etc/bashrc \
  boot-scripts/etc/boot-lib.sh \
  boot-scripts/etc/chroot-lib.sh \
  boot-scripts/etc/clusterfs-lib.sh \
  boot-scripts/etc/comoonics-release \
  boot-scripts/etc/drbd-lib.sh \
  boot-scripts/etc/defaults.sh \
  boot-scripts/etc/ext3-lib.sh \
  boot-scripts/etc/ext4-lib.sh \
  boot-scripts/etc/errors.sh \
  boot-scripts/etc/gfs-lib.sh \
  boot-scripts/etc/glusterfs-lib.sh \
  boot-scripts/etc/hardware-lib.sh \
  boot-scripts/etc/iscsi-lib.sh \
  boot-scripts/etc/lock-lib.sh \
  boot-scripts/etc/network-lib.sh \
  boot-scripts/etc/nfs-lib.sh \
  boot-scripts/etc/ocfs2-lib.sh \
  boot-scripts/etc/osr-lib.sh \
  boot-scripts/etc/repository-lib.sh \
  boot-scripts/etc/stdfs-lib.sh \
  boot-scripts/etc/std-lib.sh \
  boot-scripts/etc/syslog-lib.sh \
  boot-scripts/etc/xen-lib.sh \
  boot-scripts/etc/rhel4/boot-lib.sh \
  boot-scripts/etc/rhel4/gfs-lib.sh \
  boot-scripts/etc/rhel4/hardware-lib.sh \
  boot-scripts/etc/rhel4/network-lib.sh \
  boot-scripts/etc/rhel5/boot-lib.sh \
  boot-scripts/etc/rhel5/gfs-lib.sh \
  boot-scripts/etc/rhel5/hardware-lib.sh \
  boot-scripts/etc/rhel5/network-lib.sh \
  boot-scripts/etc/rhel5/nfs-lib.sh \
  boot-scripts/etc/sles8/hardware-lib.sh \
  boot-scripts/etc/sles8/network-lib.sh \
  boot-scripts/etc/sles10/boot-lib.sh \
  boot-scripts/etc/sles10/hardware-lib.sh \
  boot-scripts/etc/sles10/network-lib.sh \
  boot-scripts/etc/sles10/nfs-lib.sh \
  boot-scripts/etc/sles10/ext3-lib.sh \
  boot-scripts/etc/sles11/boot-lib.sh \
  boot-scripts/etc/sles11/hardware-lib.sh \
  boot-scripts/etc/sles11/network-lib.sh \
  boot-scripts/etc/sles11/ext3-lib.sh \
  boot-scripts/etc/fedora/boot-lib.sh \
  boot-scripts/etc/fedora/gfs-lib.sh \
  boot-scripts/etc/fedora/hardware-lib.sh \
  boot-scripts/etc/fedora/network-lib.sh \
  boot-scripts/etc/fedora/nfs-lib.sh \
  boot-scripts/etc/stdlib.py \
  boot-scripts/etc/templates/rsyslogd.conf \
  boot-scripts/etc/templates/syslog-ng.conf \
  boot-scripts/etc/templates/syslog.conf
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
SYSTEM_CFG_FILES=$(PACKAGE_NAME).cfg \
querymap.cfg
# subdirs are all in root
#************ SYSTEM_CFG_FILES 
#****d* Makefile/CFG_DIR
#  NAME
#    CFG_DIR
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
CFG_DIR=$(SYSTEM_CFG_DIR)/bootimage
#************ CFG_DIR 
#****d* Makefile/CFG_FILES
#  NAME
#    CFG_FILES
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
CFG_FILES=basefiles.list \
    files.initrd.d/rdac_multipath.list \
    files.initrd.d/configs.list \
    files.initrd.d/locales.list \
    files.initrd.d/drbd.list \
    files.initrd.d/scsi.list \
    files.initrd.d/base.list \
    files.initrd.d/iscsi.list \
    files.initrd.d/bonding.list \
    files.initrd.d/glusterfs.list \
    files.initrd.d/grub.list \
    files.initrd.d/mdadm.list \
    files.initrd.d/comoonics.list \
    files.initrd.d/firmware.list \
    files.initrd.d/vlan.list \
    files.initrd.d/ext2.list \
    files.initrd.d/xen.list \
    files.initrd.d/rdac_multipath.list \
    files.initrd.d/network.list \
    files.initrd.d/ocfs2.list \
    files.initrd.d/sysctl.list \
    files.initrd.d/user_edit.list \
	files.initrd.d/rhel/empty.list \
    files.initrd.d/rhel/base.list \
    files.initrd.d/rhel/configs.list \
    files.initrd.d/rhel/grub.list \
    files.initrd.d/rhel/gfs.list \
    files.initrd.d/rhel/empty.list \
    files.initrd.d/rhel/network.list \
	files.initrd.d/rhel4/empty.list \
	files.initrd.d/rhel5/empty.list \
    files.initrd.d/rhel5/fence_vmware.list \
    files.initrd.d/rhel5/rhcs.list \
    files.initrd.d/sles/base.list \
    files.initrd.d/sles/empty.list \
    files.initrd.d/sles/network.list \
    files.initrd.d/sles/dm_multipath.list \
    files.initrd.d/sles11/dm_multipath.list \
    files.initrd.d/fedora/base.list \
    files.initrd.d/fedora/configs.list \
    files.initrd.d/fedora/network.list \
    rpms.list \
    rpms.initrd.d/python.list \
    rpms.initrd.d/drbd.list \
    rpms.initrd.d/baselibs.list \
    rpms.initrd.d/iscsi.list \
    rpms.initrd.d/hardware.list \
    rpms.initrd.d/lvm.list \
    rpms.initrd.d/glusterfs.list \
    rpms.initrd.d/comoonics.list \
    rpms.initrd.d/comoonics-compat.list \
    rpms.initrd.d/ext2.list \
    rpms.initrd.d/fencexvm.list \
    rpms.initrd.d/fencedeps.list \
    rpms.initrd.d/xen.list \
    rpms.initrd.d/ocfs2.list \
    rpms.initrd.d/mdadm.list \
    rpms.initrd.d/nfs.list \
    rpms.initrd.d/rsyslogd.list \
    rpms.initrd.d/syslog-ng.list \
    rpms.initrd.d/syslogd.list \
    rpms.initrd.d/ext4.list \
    rpms.initrd.d/rhel/base.list \
    rpms.initrd.d/rhel/dm_multipath.list \
    rpms.initrd.d/rhel/comoonics.list \
	rpms.initrd.d/rhel/empty.list \
    rpms.initrd.d/rhel/dm_multipath.list \
    rpms.initrd.d/rhel/hardware.list \
    rpms.initrd.d/rhel/python.list \
	rpms.initrd.d/rhel4/empty.list \
    rpms.initrd.d/rhel4/rhcs.list \
    rpms.initrd.d/rhel4/gfs1.list \
    rpms.initrd.d/rhel5/base.list \
	rpms.initrd.d/rhel5/empty.list \
	rpms.initrd.d/rhel5/perl.list \
    rpms.initrd.d/rhel5/gfs1.list \
    rpms.initrd.d/rhel5/python.list \
    rpms.initrd.d/rhel5/rhcs.list \
    rpms.initrd.d/sles/python.list \
    rpms.initrd.d/sles/base.list \
    rpms.initrd.d/sles/hardware.list \
    rpms.initrd.d/sles/comoonics.list \
    rpms.initrd.d/sles/empty.list \
    rpms.initrd.d/sles/dm_multipath.list \
    rpms.initrd.d/sles/network.list \
    rpms.initrd.d/sles/vim.list \
    rpms.initrd.d/sles10/base.list \
    rpms.initrd.d/sles10/python.list \
    rpms.initrd.d/sles11/base.list \
    rpms.initrd.d/sles11/dm_multipath.list \
    rpms.initrd.d/sles11/python.list \
    rpms.initrd.d/fedora/base.list \
    rpms.initrd.d/fedora/dm_multipath.list \
    rpms.initrd.d/fedora/hardware.list \
    rpms.initrd.d/fedora/python.list \
    rpms.initrd.d/fedora/network.list \
    rpms.initrd.d/fedora/nfs.list \
    filters.list \
    filters.initrd.d/empty.list \
    filters.initrd.d/kernel.list \
    pre.mkinitrd.d/00-cdsl-check.sh \
    post.mkinitrd.d/01-create-mapfiles.sh \
    post.mkinitrd.d/02-create-cdsl-repository.sh
	
#************ CFG_FILES 

#****d* Makefile/CFG_DIR_CHROOT
#  NAME
#    CFG_DIR_CHROOT
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
CFG_DIR_CHROOT=$(SYSTEM_CFG_DIR)/bootimage-chroot
#************ CFG_DIR_CHROOT 
#****d* Makefile/CFG_FILES_CHROOT
#  NAME
#    CFG_FILES_CHROOT
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
CFG_FILES_CHROOT=files.list \
	rpms.list \
	rpms.initrd.d/fenceacksv-plugins.list
	
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
 boot-scripts/sys \
 boot-scripts/tmp \
 boot-scripts/dev

#************ EMPTY_DIRS 
#****d* Makefile/INIT_FILES
#  NAME
#    INIT_FILES
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
INIT_FILES=

#************ INIT_FILES 
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


CHANNELBASEDIR=/atix/dist-mirrors
ALL_DISTROS=rhel4 rhel5 sles10 fedora sles11
# Which directories are used for installation
CHANNELDIRS=comoonics/rhel4/preview comoonics/rhel5/preview comoonics/sles10/preview comoonics/fedora/preview comoonics/sles11/preview
CHANNELSUBDIRS=i386 x86_64 noarch SRPMS

TEST_DIR=tests

CLUSTERSUITE_PATH=~/atix/nashead2004/management/comoonics-clustersuite/
PYTHONPATH=$(CLUSTERSUITE_PATH)/python/lib
CCS_XML_QUERY=$(CLUSTERSUITE_PATH)/python/bin/com-queryclusterconf

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
               if [ ! -e $(PREFIX)/$(CFG_DIR)/rpms.initrd.d/`dirname $$cfgfile` ]; then \
                 install -d  -g $(INSTALL_GRP) -o $(INSTALL_OWN) $(PREFIX)/$(CFG_DIR)/`dirname $$cfgfile`; \
               fi; \
               install -g $(INSTALL_GRP) -o $(INSTALL_OWN) $$cfgfile $(PREFIX)/$(CFG_DIR)/`dirname $$cfgfile`; \
	     done && \
	     echo "DONE") || \
	     echo "FAILED" && cd ..) \
	fi
	@if [ -n "$(CFG_FILES_CHROOT)" ]; then \
	   ((echo -n "Installing cfg-files-chroot..." && \
             cd system-cfg-files.chroot && \
             if [ ! -e $(PREFIX)/$(CFG_DIR_CHROOT) ]; then \
               install -d  -g $(INSTALL_GRP) -o $(INSTALL_OWN) $(PREFIX)/$(CFG_DIR_CHROOT); \
             fi; \
             if [ ! -e $(PREFIX)/$(CFG_DIR_CHROOT)/files.initrd.d/ ]; then \
               install -d  -g $(INSTALL_GRP) -o $(INSTALL_OWN) $(PREFIX)/$(CFG_DIR_CHROOT)/files.initrd.d/; \
             fi; \
             if [ ! -e $(PREFIX)/$(CFG_DIR_CHROOT)/rpms.initrd.d/ ]; then \
               install -d  -g $(INSTALL_GRP) -o $(INSTALL_OWN) $(PREFIX)/$(CFG_DIR_CHROOT)/rpms.initrd.d/; \
             fi; \
	     for cfgfile in $(CFG_FILES_CHROOT); do \
               if [ ! -e $(PREFIX)/$(CFG_DIR_CHROOT)/rpms.initrd.d/`dirname $$cfgfile` ]; then \
                 install -d  -g $(INSTALL_GRP) -o $(INSTALL_OWN) $(PREFIX)/$(CFG_DIR_CHROOT)/rpms.initrd.d/`dirname $$cfgfile`; \
               fi; \
               install -g $(INSTALL_GRP) -o $(INSTALL_OWN) $$cfgfile $(PREFIX)/$(CFG_DIR_CHROOT)/`dirname $$cfgfile`; \
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
	@if [ -f docs/CHANGELOG ]; then \
	  (echo -n "Installing CHANGELOG..." && \
	   install -g $(INSTALL_GRP) -o $(INSTALL_OWN) docs/CHANGELOG CHANGELOG && \
	   echo "DONE") || echo "FAILED"; \
	fi

archive:
	@echo -n "Creating Archives .. $(ARCHIVE_FILE)..."
	@(cd .. && \
	tar -c -z --exclude="*~" --exclude="*CVS*" -f $(ARCHIVE_FILE) $(TAR_PATH) && \
	tar -c -z --exclude="*~" --exclude="*CVS*" -f $(ARCHIVE_FILE_INITSCRIPTS) $(TAR_PATH_INITSCRIPTS) && \
	echo "(OK)") || echo "(FAILED)"
	
rpmpackagedir:
	@echo "rpmpackagedir: $(RPM_PACKAGE_DIR)"

test:
	@echo "Testing source..."
	PYTHONPATH=$(PYTHONPATH) \
	ccs_xml_query=$(CCS_XML_QUERY) \
	bash ./$(TEST_DIR)/do_testing.sh

rpmbuild: archive
	@echo -n "Creating RPM"
	cp ../$(ARCHIVE_FILE) $(RPM_PACKAGE_SOURCE_DIR)/
	rpmbuild -ba --target=noarch ./comoonics-bootimage.spec
	
	
rpmbuild-listfiles-el4: archive
	cp ../$(ARCHIVE_FILE) $(RPM_PACKAGE_SOURCE_DIR)/
	rpmbuild -ba  --target=noarch ./comoonics-bootimage-listfiles-el4.spec

rpmbuild-listfiles-el5: archive
	cp ../$(ARCHIVE_FILE) $(RPM_PACKAGE_SOURCE_DIR)/
	rpmbuild -ba  --target=noarch ./comoonics-bootimage-listfiles-el5.spec

rpmbuild-initscripts-el4: archive
	cp ../$(ARCHIVE_FILE_INITSCRIPTS) $(RPM_PACKAGE_SOURCE_DIR)/
	rpmbuild -ba  --target=noarch ./comoonics-bootimage-initscripts-el4.spec

rpmbuild-initscripts-el5: archive
	cp ../$(ARCHIVE_FILE_INITSCRIPTS) $(RPM_PACKAGE_SOURCE_DIR)/
	rpmbuild -ba  --target=noarch ./comoonics-bootimage-initscripts-el5.spec
	
rpmbuild-initscripts-sles10: archive
	cp ../$(ARCHIVE_FILE_INITSCRIPTS) $(RPM_PACKAGE_SOURCE_DIR)/
	rpmbuild -ba  --target=noarch ./comoonics-bootimage-initscripts-sles10.spec
	
rpmbuild-initscripts-sles11: archive
	cp ../$(ARCHIVE_FILE_INITSCRIPTS) $(RPM_PACKAGE_SOURCE_DIR)/
	rpmbuild -ba  --target=noarch ./comoonics-bootimage-initscripts-sles11.spec
	
rpmbuild-initscripts-fedora: archive
	cp ../$(ARCHIVE_FILE_INITSCRIPTS) $(RPM_PACKAGE_SOURCE_DIR)/
	rpmbuild -ba  --target=noarch ./comoonics-bootimage-initscripts-fedora.spec
	
.PHONY:rpmsign
rpmsign:
	@echo "Signing packages"
	rpm --resign $(RPM_PACKAGE_BIN_DIR)/$(PACKAGE_NAME)-*.rpm $(RPM_PACKAGE_SRC_DIR)/$(PACKAGE_NAME)-*.src.rpm

.PHONY: channelcopy
channelcopy:
	# Create an array of all CHANNELDIRS distros (second dir in path) and one without numbers at the end ready to be feeded in find
	@for channeldir in $(CHANNELDIRS); do \
		TMPFILE="$(CHANNELBASEDIR)/$$channeldir/.channelcopy"$$$$; \
		touch $$TMPFILE; \
		sleep 1; \
		echo "Copying rpms to channel $$channeldir..$$TMPFILE"; \
		includeddistros=`echo -n $$channeldir | awk -F/ '{ print "-name \"*"$$2"*\" -or -name \"*"gensub("[0-9]+$$","","",$$2)"-*\" -or "; }'`; \
		excludeddistros=`echo -n $(ALL_DISTROS) | awk -F/ 'BEGIN { RS=" "; } $$0=="'$$includedistro'" { next; } { print "-not -name \"*"$$0"*\" -and -not -name \"*"gensub("[0-9]+$$","","",$$0)"*\" -and "; }'`; \
		for subdir in $(CHANNELSUBDIRS); do \
			if [ $$subdir == "SRPMS" ]; then \
				type="src"; \
				rpmdir=""; \
			else \
				type=$$subdir; \
				rpmdir="/RPMS"; \
			fi; \
			echo 'find $(RPM_PACKAGE_DIR) -name "$(PACKAGE_NAME)*.'$$type'.rpm" -and -not -name "*.el?.*" -and '$$excludeddistros' -true -exec cp -f {} $(CHANNELBASEDIR)/'$$channeldir'/'$${subdir}$${rpmdir}' \;' ;\
			echo 'find $(RPM_PACKAGE_DIR) -name "$(PACKAGE_NAME)*.'$$type'.rpm" -and -not -name "*.el?.*" -and '$$excludeddistros' -true -exec cp -f {} $(CHANNELBASEDIR)/'$$channeldir'/'$${subdir}$${rpmdir}' \;' | bash ;\
			echo 'find $(RPM_PACKAGE_DIR) -name "$(PACKAGE_NAME)*.'$$type'.rpm" -and -not -name "*.el?.*" -and \( '$$includeddistros' -false \) -exec cp -f {} $(CHANNELBASEDIR)/'$$channeldir'/'$${subdir}$${rpmdir}' \;' ;\
			echo 'find $(RPM_PACKAGE_DIR) -name "$(PACKAGE_NAME)*.'$$type'.rpm" -and -not -name "*.el?.*" -and \( '$$includeddistros' -false \) -exec cp -f {} $(CHANNELBASEDIR)/'$$channeldir'/'$${subdir}$${rpmdir}' \;' | bash ;\
		done; \
		echo find $(CHANNELBASEDIR)/$$channeldir -name "$(PACKAGE_NAME)*.rpm" -newer $$TMPFILE; \
		find $(CHANNELBASEDIR)/$$channeldir -name "$(PACKAGE_NAME)*.rpm" -newer $$TMPFILE; \
		rm -f $$TMPFILE; \
	done;
	
.PHONY: channelbuild
channelbuild:
	@echo "Rebuilding channels.."
	@for channeldir in $(CHANNELDIRS); do \
		$(CHANNELBASEDIR)/updaterepositories -r $$channeldir; \
	done 

.PHONY:rpm	
rpm: test rpmbuild rpmbuild-initscripts-el4 rpmbuild-initscripts-el5 rpmbuild-initscripts-sles10 rpmbuild-initscripts-sles11 rpmbuild-initscripts-fedora \
rpmsign

.PHONY: channel
channel: rpm channelcopy channelbuild

########################################
# CVS-Log
# $Log: Makefile,v $
# Revision 1.71  2011-02-14 16:43:46  marc
# *** empty log message ***
#
# Revision 1.70  2011/02/11 11:30:52  marc
# added the new listfiles.
#
# Revision 1.69  2011/01/28 13:01:51  marc
# added lock-lib.sh
#
# Revision 1.68  2011/01/18 09:23:41  marc
# new versions for comoonics-bootimage-listfiles-rhel5
#
# Revision 1.67  2011/01/12 09:34:51  marc
# added to execute tests
#
# Revision 1.66  2010/12/07 13:30:47  marc
# added new files
#
# Revision 1.65  2010/08/12 13:04:05  marc
# added base.list.
#
# Revision 1.64  2010/08/11 09:46:58  marc
# - added files
#
# Revision 1.63  2010/07/08 08:39:37  marc
# new versions
#
# Revision 1.62  2010/06/30 07:04:04  marc
# new version
#
# Revision 1.61  2010/06/17 08:21:30  marc
# replaced fencevirsh with fencedeps
#
# Revision 1.60  2010/06/09 08:23:08  marc
# - initscripts archive introduced
#
# Revision 1.59  2010/02/21 12:10:13  marc
# moved a comment
#
# Revision 1.58  2010/02/16 10:07:15  marc
# new versions
#
# Revision 1.57  2010/02/09 21:45:19  marc
# new versions
#
# Revision 1.56  2010/02/07 20:35:26  marc
# - latest versions
#
# Revision 1.55  2009/10/07 12:08:58  marc
# added com-chroot
#
# Revision 1.54  2009/09/28 14:51:19  marc
# new versions
#
# Revision 1.53  2009/09/28 14:40:45  marc
# new versions
#
# Revision 1.52  2009/08/11 12:17:10  marc
# new versions
#
# Revision 1.51  2009/04/14 15:06:18  marc
# new files
#
# Revision 1.50  2009/02/26 07:12:57  marc
# added a sleep
#
# Revision 1.49  2009/02/25 13:44:16  marc
# added rhel4
#
# Revision 1.48  2009/02/18 18:11:51  marc
# new version of comoonics-bootimage
#
# Revision 1.47  2009/02/08 14:22:48  marc
# added md
#
# Revision 1.46  2009/01/29 19:49:08  marc
# added new files
#
# Revision 1.45  2008/12/01 12:30:41  marc
# implemented test
#
# Revision 1.44  2008/11/18 14:28:36  marc
# - implemented RFE-BUG 289 (level up/down)
#
# Revision 1.43  2008/09/24 08:21:40  marc
# removed rhel4 as upstream
#
# Revision 1.42  2008/09/24 08:13:20  marc
# upstream commit
# - added sles deps
#
# Revision 1.41  2008/09/10 13:12:19  marc
# Fixed bugs #267, #265, #264
#
# Revision 1.40  2008/08/14 14:40:41  marc
# -added channel option which will build channel
# - added new versions
#
# Revision 1.39  2008/07/03 12:47:47  mark
# added repository-lib.sh
#
# Revision 1.38  2008/06/10 10:07:09  marc
# -added ocfs2 files
#
# Revision 1.37  2007/12/07 16:39:59  reiner
# Added GPL license and changed ATIX GmbH to AG.
#
# Revision 1.36  2007/10/16 08:04:13  marc
# - added iscsi-support
#
# Revision 1.35  2007/10/08 16:14:55  mark
# added distrodependent boot-lib.sh
#
# Revision 1.34  2007/10/05 13:38:35  mark
# added com-halt.sh and com-realhalt.sh
#
# Revision 1.33  2007/10/05 10:10:24  marc
# - added xen-support
#
# Revision 1.32  2007/09/27 11:56:29  marc
# removed passwd file
#
# Revision 1.31  2007/09/15 14:49:38  mark
# moved listfiles into extra rpms
#
# Revision 1.30  2007/09/14 13:35:28  marc
# added rdac-files
#
# Revision 1.29  2007/09/14 08:32:40  mark
# added initscripts-el5
#
# Revision 1.28  2007/09/13 09:07:07  mark
# added rule for rpmbuild-initscripts-el4
#
# Revision 1.27  2007/09/10 14:55:48  marc
# added rpmsign to rpm as in comoonics-cs
#
# Revision 1.26  2007/09/07 07:57:29  mark
# added rhel5 libs
#
# Revision 1.25  2007/08/07 12:42:14  mark
# added release 1.3.1
# added extras-nfs
# added extras-network
#
# Revision 1.24  2007/05/23 15:31:24  mark
# set bootimage revision to 1.2
# added multipath support
# added support for ext3 and nfs
#
# Revision 1.23  2007/02/23 16:45:36  mark
# added make rpm
# added rpms.initrd.d/m_multipath.list
#
# Revision 1.22  2007/02/09 11:09:44  marc
# added CHANGELOG
#
# Revision 1.21  2007/01/23 13:05:56  mark
# added vlan.list
#
# Revision 1.20  2006/12/04 17:38:33  marc
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
