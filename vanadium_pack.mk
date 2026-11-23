#
# SPDX-FileCopyrightText: Myghi63
# SPDX-License-Identifier: Apache-2.0
#
# Vanadium (GrapheneOS) browser pack. Hook from a device mk's optional
# add-on block:
#     $(call inherit-product-if-exists, vendor/vanadium_pack/vanadium_pack.mk)
#
# The vendor/vanadium provider repo must be declared in the manifest (see
# README).

PRODUCT_PACKAGES += \
    VanadiumWebviewOverlay \
    TrichromeWebViewDualArch \
    TrichromeChromeDualArch \
    VanadiumConfig

# 'webview' stays in PRODUCT_PACKAGES through media_product.mk and cannot be
# filtered from here; this repo's Android.bp defines the name as a module that
# installs nothing. See the comment there.
#
# Jelly is dropped by the VanadiumWebviewOverlay module (overrides), see
# overlay/Android.bp.
