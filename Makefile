include $(TOPDIR)/rules.mk

PKG_NAME:=substore
PKG_VERSION:=2.23.2
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/substore
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Sub-Store
  DEPENDS:=+node +wget +unzip
endef

define Package/substore/install
	$(INSTALL_DIR) $(1)/etc/substore
	$(INSTALL_BIN) ./files/etc/init.d/substore $(1)/etc/init.d/

	$(INSTALL_DIR) $(1)/root
    $(INSTALL_BIN) ./scripts/update_substore_backend.sh $(1)/root/
	$(INSTALL_BIN) ./scripts/update_substore_frontend.sh $(1)/root/

	$(CP) ./files/www $(1)/
	$(CP) ./files/usr $(1)/
	$(CP) ./files/root $(1)/
endef

$(eval $(call BuildPackage,substore))
