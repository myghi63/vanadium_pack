#
# SPDX-FileCopyrightText: Myghi63
# SPDX-License-Identifier: Apache-2.0
#
# Vanadium (GrapheneOS) browser pack. Hook from a device mk AFTER the
# vendor/lineage config inherits:
#     $(call inherit-product-if-exists, vendor/vanadium_pack/vanadium_pack.mk)
#
# The 'webview' module itself is defined in this repo's Android.bp; the
# vendor/vanadium provider repo must be declared in the manifest (see
# README).

PRODUCT_PACKAGES += \
    VanadiumWebviewOverlay \
    TrichromeWebViewDualArch \
    TrichromeChromeDualArch \
    VanadiumConfig

# media_product.mk packages the 'webview' module (name of the vanilla chromium
# prebuilt, nothing else in the tree references it) and vendor/lineage/config/
# common.mk packages Jelly; both are replaced by Vanadium here. This only
# happens when this pack (and with it the Vanadium repos) is in the build.
PRODUCT_PACKAGES := $(filter-out webview Jelly,$(PRODUCT_PACKAGES))
