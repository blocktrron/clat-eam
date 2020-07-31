#
# Copyright (C) 2020 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=clat-eam
PKG_VERSION:=1.0
PKG_RELEASE:=1

PKG_MAINTAINER:=David Bauer <mail@david-bauer.net>
PKG_LICENSE:=GPL-2.0

include $(INCLUDE_DIR)/package.mk

define Package/clat-eam
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  TITLE:=IPv4/IPv6 CLAT-EAM implementation
endef

define Package/clat-eam/description
  This package contains a IPv6 CLAT-EAM implementation.
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/lib/netifd/proto
	$(INSTALL_BIN) ./files/clat-eam.sh $(1)/lib/netifd/proto/
endef

$(eval $(call BuildPackage,clat-eam))
