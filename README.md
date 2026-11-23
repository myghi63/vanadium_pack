# Vanadium browser + WebView pack for LineageOS trees (GrapheneOS prebuilts)

Vendor wiring that replaces the vanilla Lineage webview/browser stack with the
hardened GrapheneOS Vanadium prebuilts. Device-independent: any tree can hook
it with one line and one manifest project.

## Requirements

Declare the GrapheneOS tree adapter (the prebuilt provider repo) and this pack:

```xml
<remote name="grapheneos-gl" fetch="https://gitlab.com/grapheneos/" />

<project name="platform_external_vanadium" path="vendor/vanadium"
         remote="grapheneos-gl" revision="17" clone-depth="1" />
<project name="vanadium_pack" path="vendor/vanadium_pack"
         remote="myghi63" revision="main" />
```

Sync the provider repo under `vendor/` (not `external/`): the
`android.ext.adservices` framework module (`packages/modules/AdServices`)
grants visibility to `//vendor:__subpackages__` but not to arbitrary
`external/` paths, so the Trichrome imports work without patching or
forking AdServices.

Pick the provider repo branch matching the Android version (`17` =
Android 17 = lineage-24.0). Pin a tag for reproducibility (e.g. `2026111800`).

Drop the vanilla Chromium webview projects (their `external/chromium-webview`
path is what `media_product.mk` packaging otherwise pulls) with:

```xml
<remove-project name="LineageOS/android_external_chromium-webview_patches" />
<remove-project name="LineageOS/android_external_chromium-webview_prebuilt_arm" />
<remove-project name="LineageOS/android_external_chromium-webview_prebuilt_arm64" />
<remove-project name="LineageOS/android_external_chromium-webview_prebuilt_x86" />
<remove-project name="LineageOS/android_external_chromium-webview_prebuilt_x86_64" />
```

## Hook

In the device product mk (any order among the add-on inherits):

```make
$(call inherit-product-if-exists, vendor/vanadium_pack/vanadium_pack.mk)
```

## What it ships

- `TrichromeWebViewDualArch` — the WebView provider (arm64), installed
  directly from `vendor/vanadium` preprocessed (GrapheneOS signature intact);
  brings `VanadiumConfig` and the loader libs via its own `required`.
- `TrichromeChromeDualArch` — the Vanadium browser (arm64-multilib).
- Jelly (`org.lineageos.jelly`) — dropped by `overrides: ["Jelly"]` on the
  overlay module: make inheritance freezes per-file snapshots, so an
  inherited `PRODUCT_PACKAGES` entry cannot be filtered out by a child mk;
  the Soong overrides mutator is the mechanism that actually removes it, and
  it only applies when this pack is in the build.
- `webview` — the name `media_product.mk` keeps in `PRODUCT_PACKAGES` for the
  dropped chromium prebuilt. It cannot be filtered out of an inherited
  `PRODUCT_PACKAGES`, and it cannot be allow-listed from here either
  (`PRODUCT_ENFORCE_PACKAGES_EXIST_ALLOW_LIST` is not an inherited product var:
  it only exists as a read-only `PRODUCTS.<product mk>` value that
  `vendor/lineage/config/common.mk` already froze). This repo defines the name
  as a module that installs nothing, so the packaging existence check resolves
  it and the Chromium apk stays out of the image. See the comment in
  `Android.bp`.
- `VanadiumWebviewOverlay` — static RRO that makes the framework accept
  `app.vanadium.webview` as the WebView provider (`config_webview_packages.xml`
  lists package names only, no signature attribute is needed).
- Jelly (`org.lineageos.jelly`) is dropped from `PRODUCT_PACKAGES`, but only
  when this pack is inherited, i.e. only when Vanadium is in the build.

## License note

The pack content (mk, Android.bp, RRO) is Apache-2.0. The apks themselves are
GrapheneOS builds signed with their keys and keep their upstream licenses
(Chromium / Apache-2.0); nothing here modifies them.
