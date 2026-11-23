#
# SPDX-FileCopyrightText: Myghi63
# SPDX-License-Identifier: Apache-2.0
#
# Vanadium (GrapheneOS) browser pack. Hook from a device mk AFTER the
# vendor/lineage config inherits:
#     $(call inherit-product-if-exists, vendor/vanadium_pack/vanadium_pack.mk)
#
# The 'webview' module itself is defined in this repo's Android.bp; the
# external/vanadium provider repo must be declared in the manifest (see
# README).

PRODUCT_PACKAGES += \
    VanadiumWebviewOverlay \
    TrichromeChromeDualArch \
    VanadiumConfig

# vendor/lineage/config/common.mk packages Jelly; with Vanadium as the browser
# it is dropped. This only happens when this pack (and with it the Vanadium
# repos) is in the build.
PRODUCT_PACKAGES := $(filter-out Jelly,$(PRODUCT_PACKAGES))
