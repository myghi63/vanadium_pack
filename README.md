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

In the device product mk, AFTER the `vendor/lineage/config/*` inherits (the
Jelly/webview filtering below relies on that order):

```make
$(call inherit-product-if-exists, vendor/vanadium_pack/vanadium_pack.mk)
```

## What it ships

- `TrichromeWebViewDualArch` — the WebView provider (arm64), installed
  directly from `vendor/vanadium` preprocessed (GrapheneOS signature intact);
  brings `VanadiumConfig` and the loader libs via its own `required`.
- `TrichromeChromeDualArch` — the Vanadium browser (arm64-multilib).
- `webview` and Jelly are filtered out of `PRODUCT_PACKAGES`: the `webview`
  name is only `media_product.mk` packaging the vanilla chromium prebuilt
  (re-adding it would need a module, and Soong cannot re-import these apks
  through symlinks/shims — filegroups are variantless, sandboxed copies keep
  symlinks dangling); nothing else references the name.
- `VanadiumWebviewOverlay` — static RRO that makes the framework accept
  `app.vanadium.webview` as the WebView provider (`config_webview_packages.xml`
  lists package names only, no signature attribute is needed).
- Jelly (`org.lineageos.jelly`) is dropped from `PRODUCT_PACKAGES`, but only
  when this pack is inherited, i.e. only when Vanadium is in the build.

## License note

The pack content (mk, Android.bp, RRO) is Apache-2.0. The apks themselves are
GrapheneOS builds signed with their keys and keep their upstream licenses
(Chromium / Apache-2.0); nothing here modifies them.
