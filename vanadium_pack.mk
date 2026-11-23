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

# The 'webview' module shim (name required by media_product.mk) and the Jelly
# drop are both handled in Android.bp: make inheritance freezes per-file
# snapshots, so PRODUCT_PACKAGES cannot be filtered from an inherited child
# mk; the shim module exists only when this pack is in the build.
