#****h* comoonics-bootimage/Makefile
#  NAME
#    Makefile
#  DESCRIPTION
#    Makefile for the comoonics-bootimage
#*******

# Project: Makefile for projects documentations
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

include Makefile.inc

#****d* Makefile/PREFIX
#  NAME
#    PREFIX
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
PREFIX=/

#************ PREFIX 
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
#****d* Makefile/EXEC_FILES
#  NAME
#    EXEC_FILES
#  MODIFICATION HISTORY
#  IDEAS
#  SOURCE
#
EXEC_FILES=create-gfs-initrd-generic.sh \
  manage_chroot.sh \
  manage_initrd_repository \
  com-chroot \
  com-forcdsls \
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
  boot-scripts/etc/gfs2-lib.sh \
  boot-scripts/etc/glusterfs-lib.sh \
  boot-scripts/etc/hardware-lib.sh \
  boot-scripts/etc/iscsi-lib.sh \
  boot-scripts/etc/lock-lib.sh \
  boot-scripts/etc/network-lib.sh \
  boot-scripts/etc/nfs-lib.sh \
  boot-scripts/etc/ocfs2-lib.sh \
  boot-scripts/etc/osr-lib.sh \
  boot-scripts/etc/plymouth-lib.sh \
  boot-scripts/etc/repository-lib.sh \
  boot-scripts/etc/selinux-lib.sh \
  boot-scripts/etc/stdfs-lib.sh \
  boot-scripts/etc/std-lib.sh \
  boot-scripts/etc/syslog-lib.sh \
  boot-scripts/etc/xen-lib.sh \
  boot-scripts/etc/rhel5/boot-lib.sh \
  boot-scripts/etc/rhel5/gfs-lib.sh \
  boot-scripts/etc/rhel5/hardware-lib.sh \
  boot-scripts/etc/rhel5/network-lib.sh \
  boot-scripts/etc/rhel5/nfs-lib.sh \
  boot-scripts/etc/rhel5/selinux-lib.sh \
  boot-scripts/etc/rhel6/boot-lib.sh \
  boot-scripts/etc/rhel6/gfs-lib.sh \
  boot-scripts/etc/rhel6/gfs2-lib.sh \
  boot-scripts/etc/rhel6/hardware-lib.sh \
  boot-scripts/etc/rhel6/network-lib.sh \
  boot-scripts/etc/rhel6/nfs-lib.sh \
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
    files.initrd.d/base.list \
    files.initrd.d/bonding.list \
    files.initrd.d/comoonics.list \
    files.initrd.d/configs.list \
    files.initrd.d/drbd.list \
    files.initrd.d/ext2.list \
    files.initrd.d/firmware.list \
    files.initrd.d/glusterfs.list \
    files.initrd.d/grub.list \
    files.initrd.d/iscsi.list \
    files.initrd.d/locales.list \
    files.initrd.d/mdadm.list \
    files.initrd.d/network.list \
    files.initrd.d/nfs.list \
    files.initrd.d/ocfs2.list \
    files.initrd.d/rdac_multipath.list \
    files.initrd.d/scsi.list \
    files.initrd.d/sysctl.list \
    files.initrd.d/user_edit.list \
    files.initrd.d/vlan.list \
    files.initrd.d/xen.list \
    files.initrd.d/rhel/base.list \
    files.initrd.d/rhel/configs.list \
	files.initrd.d/rhel/empty.list \
    files.initrd.d/rhel/gfs.list \
    files.initrd.d/rhel/grub.list \
    files.initrd.d/rhel/empty.list \
    files.initrd.d/rhel/network.list \
	files.initrd.d/rhel5/configs.list \
	files.initrd.d/rhel5/empty.list \
    files.initrd.d/rhel5/fence_vmware.list \
    files.initrd.d/rhel5/rhcs.list \
    files.initrd.d/rhel6/base.list \
    files.initrd.d/rhel6/configs.list \
    files.initrd.d/rhel6/dm_multipath.list \
    files.initrd.d/rhel6/network.list \
    files.initrd.d/rhel6/rhcs.list \
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
    rpms.initrd.d/plymouth.list \
    rpms.initrd.d/rsyslogd.list \
    rpms.initrd.d/syslog-ng.list \
    rpms.initrd.d/syslogd.list \
    rpms.initrd.d/rhel/base.list \
    rpms.initrd.d/rhel/comoonics.list \
    rpms.initrd.d/rhel/dm_multipath.list \
	rpms.initrd.d/rhel/empty.list \
    rpms.initrd.d/rhel/hardware.list \
    rpms.initrd.d/rhel/nfs.list \
    rpms.initrd.d/rhel/python.list \
    rpms.initrd.d/rhel/selinux.list \
    rpms.initrd.d/rhel5/base.list \
    rpms.initrd.d/rhel5/comoonics.list \
    rpms.initrd.d/rhel5/comoonics-flexd.list \
	rpms.initrd.d/rhel5/empty.list \
	rpms.initrd.d/rhel5/perl.list \
    rpms.initrd.d/rhel5/gfs1.list \
    rpms.initrd.d/rhel5/gfs2.list \
    rpms.initrd.d/rhel5/hardware.list \
    rpms.initrd.d/rhel5/nfs.list \
    rpms.initrd.d/rhel5/python.list \
    rpms.initrd.d/rhel5/rhcs.list \
    rpms.initrd.d/rhel6/base.list \
    rpms.initrd.d/rhel6/comoonics-flexd.list \
    rpms.initrd.d/rhel6/dm_multipath.list \
    rpms.initrd.d/rhel6/fencedeps.list \
    rpms.initrd.d/rhel6/fence_virt.list \
    rpms.initrd.d/rhel6/fence_xvm.list \
    rpms.initrd.d/rhel6/gfs2.list \
    rpms.initrd.d/rhel6/hardware.list \
    rpms.initrd.d/rhel6/network.list \
    rpms.initrd.d/rhel6/nfs.list \
    rpms.initrd.d/rhel6/python.list \
    rpms.initrd.d/rhel6/rhcs.list \
    rpms.initrd.d/sles/python.list \
    rpms.initrd.d/sles/base.list \
    rpms.initrd.d/sles/hardware.list \
    rpms.initrd.d/sles/comoonics.list \
    rpms.initrd.d/sles/empty.list \
    rpms.initrd.d/sles/dm_multipath.list \
    rpms.initrd.d/sles/network.list \
    rpms.initrd.d/sles/nfs.list \
    rpms.initrd.d/sles/vim.list \
    rpms.initrd.d/sles10/base.list \
    rpms.initrd.d/sles10/python.list \
    rpms.initrd.d/sles11/base.list \
    rpms.initrd.d/sles11/comoonics-flexd.list \
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
    pre.mkinitrd.d/01-clean-repository.sh \
    pre.mkinitrd.d/20-clusterconf-validate.sh \
    pre.mkinitrd.d/30-rootfs-check.sh \
    pre.mkinitrd.d/35-rootdevice-check.sh \
    pre.mkinitrd.d/38-multipath-check.sh \
    pre.mkinitrd.d/50-bootimage-check.sh \
    pre.mkinitrd.d/50-cdsl-check.sh \
    pre.mkinitrd.d/60-osr-repository-generate.sh \
    post.mkinitrd.d/01-create-mapfiles.sh \
    post.mkinitrd.d/02-create-cdsl-repository.sh \
    post.mkinitrd.d/03-nfs-deps.sh \
	post.mkinitrd.d/19-copy-network-configurations.sh \
	post.mkinitrd.d/20-copy-network-configurations.sh \
	post.mkinitrd.d/21-copy-cdsltab-configurations.sh \
	post.mkinitrd.d/98-copy-template-repository.sh \
	post.mkinitrd.d/99-clean-repository.sh
	
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
	rpms.initrd.d/rhel6/fence_virt.list \
	rpms.initrd.d/imsd-plugins.list
	
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
	@if [ -z "$(NOTESTS)" ]; then \
		echo "Testing source \"$(NOTESTS)\"..."; \
		PYTHONPATH=$(PYTHONPATH) \
		ccs_xml_query=$(CCS_XML_QUERY) \
		bash ./$(TEST_DIR)/do_testing.sh; \
	else \
		echo "Skipping tests \"$(NOTESTS)\"."; \
	fi

rpmbuild: archive
	@echo -n "Creating RPM"
	cp ../$(ARCHIVE_FILE) $(RPM_PACKAGE_SOURCE_DIR)/
	rpmbuild -ba --target=noarch --define 'LINUXDISTROSHORT rhel5' ./comoonics-bootimage.spec

rpmbuild-rhel5: archive
	@echo -n "Creating RPM"
	cp ../$(ARCHIVE_FILE) $(RPM_PACKAGE_SOURCE_DIR)/
	rpmbuild -ba --target=noarch --define 'LINUXDISTROSHORT rhel5' ./comoonics-bootimage.spec

rpmbuild-rhel6: archive
	@echo -n "Creating RPM"
	cp ../$(ARCHIVE_FILE) $(RPM_PACKAGE_SOURCE_DIR)/
	rpmbuild -ba --target=noarch --define 'LINUXDISTROSHORT rhel6' ./comoonics-bootimage.spec

rpmbuild-sles10: archive
	@echo -n "Creating RPM"
	cp ../$(ARCHIVE_FILE) $(RPM_PACKAGE_SOURCE_DIR)/
	rpmbuild -ba --target=noarch --define 'SHORTDISTRO sles10' ./comoonics-bootimage.spec

rpmbuild-sles11: archive
	@echo -n "Creating RPM"
	cp ../$(ARCHIVE_FILE) $(RPM_PACKAGE_SOURCE_DIR)/
	rpmbuild -ba --target=noarch --define 'LINUXDISTROSHORT sles11' ./comoonics-bootimage.spec

rpmbuild-initscripts-el5: archive
	cp ../$(ARCHIVE_FILE_INITSCRIPTS) $(RPM_PACKAGE_SOURCE_DIR)/
	rpmbuild -ba  --target=noarch ./comoonics-bootimage-initscripts-el5.spec
	
rpmbuild-initscripts-rhel6: archive
	cp ../$(ARCHIVE_FILE_INITSCRIPTS) $(RPM_PACKAGE_SOURCE_DIR)/
	rpmbuild -ba  --target=noarch ./comoonics-bootimage-initscripts-rhel6.spec
	
#rpmbuild-initscripts-sles10: archive
#	cp ../$(ARCHIVE_FILE_INITSCRIPTS) $(RPM_PACKAGE_SOURCE_DIR)/
#	rpmbuild -ba  --target=noarch ./comoonics-bootimage-initscripts-sles10.spec
	
rpmbuild-initscripts-sles11: archive
	cp ../$(ARCHIVE_FILE_INITSCRIPTS) $(RPM_PACKAGE_SOURCE_DIR)/
	rpmbuild -ba  --target=noarch ./comoonics-bootimage-initscripts-sles11.spec
	
rpmbuild-initscripts-fedora: archive
	cp ../$(ARCHIVE_FILE_INITSCRIPTS) $(RPM_PACKAGE_SOURCE_DIR)/
	rpmbuild -ba  --target=noarch ./comoonics-bootimage-initscripts-fedora.spec
	
.PHONY:rpmsign
rpmsign:
	@echo "Signing packages"
	$(RPM_SIGN_COMMAND) $(RPM_PACKAGE_BIN_DIR)/$(PACKAGE_NAME)-*.rpm $(RPM_PACKAGE_SRC_DIR)/$(PACKAGE_NAME)-*.src.rpm

.PHONY:rpmchecksig
rpmchecksig:
	@echo "Checking signature of the packages"
	$(RPM_CHECKSIG_COMMAND) $(RPM_PACKAGE_BIN_DIR)/$(PACKAGE_NAME)-*.rpm $(RPM_PACKAGE_SRC_DIR)/$(PACKAGE_NAME)-*.src.rpm

.PHONY: channelcopy
channelcopy:
	# Create an array of all CHANNELDIRS distros (second dir in path) and one without numbers at the end ready to be feeded in find
	@for channel in $(CHANNELNAMES); do \
	   channelname=`echo $$channel | cut -f1 -d:`; \
	   channelalias=`echo $$channel | cut -f2 -d:`; \
       for architecture in $(ARCHITECTURES); do \
	      echo -n "Copying rpms to channel $(CHANNELDIR)/$$channelname/$$distribution/$$architecture.."; \
	      ./build/copy_rpms.sh $(SHORTDISTRO) $(CHANNELDIR)/$$channelname $$channelalias $$architecture; \
	      echo "(DONE)"; \
	   done; \
	done;
	
.PHONY: channelbuild
channelbuild:
	@echo "Rebuilding channels.."
	@for channel in $(CHANNELNAMES); do \
    	channelname=`echo $$channel | cut -f1 -d:`; \
    	$(CHANNELBASEDIR)/updaterepositories -s -r $(PRODUCTNAME)/$(PRODUCTVERSION)/$$channelname/$(SHORTDISTRO); \
		done 

.PHONY:rpm	
rpm: test rpmbuild-$(SHORTDISTRO) rpmbuild-initscripts-el5 rpmbuild-initscripts-rhel6 rpmbuild-initscripts-sles11 rpmsign

.PHONY: rpm-rhel5
rpm-rhel5:
	make SHORTDISTRO=rhel5 rpm

.PHONY: rpm-rhel6
rpm-rhel6:
	make SHORTDISTRO=rhel6 rpm

.PHONY: rpm-sles11
rpm-sles11:
	make SHORTDISTRO=sles11 rpm

.PHONY: channel-rhel5
channel-rhel5: 
	make SHORTDISTRO=rhel5 channelcopy channelbuild

.PHONY: channel-rhel6
channel-rhel6: 
	make SHORTDISTRO=rhel6 channelcopy channelbuild

.PHONY: channel-sles11
channel-sles11:
	make SHORTDISTRO=sles11 channelcopy channelbuild

.PHONY: clean
clean:
	rm -f $(RPM_PACKAGE_BIN_DIR)/$(PACKAGE_NAME)-*.rpm $(RPM_PACKAGE_SRC_DIR)/$(PACKAGE_NAME)-*.src.rpm