# Patches

Patches applied on top of BASE.env. Each entry's `source` is an upstream URL pinned
to a commit, or `armada` if it's original; a URL source with no `notes` is verbatim.
`notes` mean the file was modified.

- `patches/0001-cstdint.patch`
  source: https://src.fedoraproject.org/rpms/gamescope/blob/cc1a9bd6aad3992a1bdaff27219efc1744478d8c/f/0001-cstdint.patch
- `patches/Allow-to-use-system-wlroots.patch`
  source: https://src.fedoraproject.org/rpms/gamescope/blob/5566fcac324cb909fd49a2323816deefc445a5fa/f/Allow-to-use-system-wlroots.patch
- `patches/Use-system-stb-glm.patch`
  source: https://src.fedoraproject.org/rpms/gamescope/blob/b5a75d544d1f314ef0d86c4dc9142b1de62e1b8e/f/Use-system-stb-glm.patch
- `patches/0004-DRMBackend-Add-GAMESCOPE_FAKE_OUTPUT_MM-env-to-set-c.patch`
  source: https://github.com/ROCKNIX/distribution/blob/ff40ff1897fa5687bc0e50103e50acc9cd90d7d3/projects/ROCKNIX/packages/apps/gamescope/patches/0004-DRMBackend-Add-GAMESCOPE_FAKE_OUTPUT_MM-env-to-set-c.patch
- `patches/0005-feature-add-rotation-shader-for-rotating-output.patch`
  source: https://github.com/ROCKNIX/distribution/blob/d5991e155a1941c248c8bcb9b364723eec75fc61/projects/ROCKNIX/packages/apps/gamescope/patches/0005-feature-add-rotation-shader-for-rotating-output.patch
- `patches/0006-steamcompmgr-fix-gamepad-cursor-sprite-frozen-via-XTest.patch`
  source: https://github.com/ROCKNIX/distribution/blob/e108ad2b8971b4e332d7457b75dd21dadb666d19/projects/ROCKNIX/packages/apps/gamescope/patches/0006-steamcompmgr-fix-gamepad-cursor-sprite-frozen-via-XTest.patch
- `patches/0014-drm-add-force-external-orientation.patch`
  source: armada
  notes: Adds `--force-external-orientation` mirroring `--force-orientation`, but
    applied to the external connector in `CDRMConnector::UpdateEffectiveOrientation`.
    With `--use-rotation-shader` (patch 0005) this rotates a portrait-mounted-
    landscape panel (Retroid Dual Screen, EDID 1080x1920 only) and also fixes
    touch mapping, since wlserver transforms touch by the active connector's
    orientation.
- `patches/0015-drm-split-scanout.patch`
  source: armada
  notes: Research prototype of "split-scanout" gated by `GAMESCOPE_SPLIT_SCANOUT`
    (empty/0 = off, 1 = on, or a connector name for the second screen) and
    `GAMESCOPE_SPLIT_SCANOUT_POSITION` (top|bottom, default top). When active,
    gamescope exposes one virtual canvas (max(w1,w2) x h1+h2) to the compositor
    and scans a single full-canvas framebuffer out to two DRM connectors through
    two CRTC/primary-plane pairs, each plane using a different 16.16 SRC rect
    for its half of the canvas. All split code lives behind `drm->split.bActive`
    checks in DRMBackend.cpp; without the env var the single-output path is
    untouched. Limitations: no per-plane rotation (both panels assumed landscape
    orientation 0), VRR and dynamic refresh are disabled while active, HDR/
    colorspace/broadcast props are only set on the primary connector, cursor is
    composited (no hardware cursor plane), and if the partner connector
    disappears the mode falls back to the primary output alone.
- `patches/0016-drm-split-scanout-per-half-rotation.patch`
  source: armada
  notes: Per-half rotation for split-scanout (plan G), configured via
    `GAMESCOPE_SPLIT_SCANOUT_ROT_A` (primary panel) and
    `GAMESCOPE_SPLIT_SCANOUT_ROT_B` (partner panel); values none|right|left|up.
    The compositor now sees a LOGICAL canvas - a horizontal pair of the halves'
    unrotated sizes, (w1+w2) x max(h1,h2), side by side and vertically centered
    - while the KMS framebuffer stays the PHYSICAL stacked canvas
    max(w1,w2) x (h1+h2). `drm_setup_split_scanout` computes per-half physical
    and logical rects plus a rotation (0/1/2/3) and passes them to the Vulkan
    composite through new FrameInfo_t split fields. The blit shader
    (cs_composite_blit.comp + get_split_src_coord in blit_push_data.h) iterates
    the physical framebuffer and maps each pixel back into the logical canvas,
    undoing that half's rotation, so panels mounted in different orientations
    (e.g. RPmini internal DSI portrait + external landscape) both show an
    upright image. Output images are allocated at the physical size and the
    split blit dispatches over them; FSR/NIS/blur and the global rotation
    shader are bypassed while split is active. Without the ROT env vars
    behavior is unchanged from 0015 (which now also allows split on a rotated
    primary when rotations are configured). Follow-ups on top of 0016:
    `GAMESCOPE_SPLIT_SCANOUT_LAYOUT=vertical` stacks the halves as a "T"
    (partner on top of the logical canvas, primary at the bottom) instead of
    side by side; `GAMESCOPE_SPLIT_SCANOUT_CROSS` pins the cross-axis canvas
    size (width in vertical layout, height in horizontal); each panel then
    displays a source BAND spanning the full canvas cross-section, fit into
    the panel via `GAMESCOPE_SPLIT_SCANOUT_FIT` (fit = letterbox default,
    stretch = per-axis, cover = uniform zoom + crop). Touch input follows
    the same band math per half, with a per-half orientation override via
    `GAMESCOPE_SPLIT_SCANOUT_TOUCH_ORIENT_A/B` (0/90/180/270); DRMBackend
    GetConnector(EXTERNAL) now actually returns the external connector so
    USB touchscreens associate with the split partner panel.

- `patches/0018-fix-arm64-steam-night-mode.patch`
  source: armada-os (their gamescope 0009), verbatim
- `patches/0019-main-add-opt-in-force-vulkan-realtime.patch`
  source: armada-os (their gamescope 0010), verbatim
- `patches/0020-color-fall-back-to-app-hdr-metadata-for-tonemapping.patch`
  source: armada-os (their gamescope 0011), verbatim
- `patches/0021-wsi-layer-pass-through-display-surface-swapchains.patch`
  source: armada-os (their gamescope 0013), verbatim
  notes: Their DRM-lease stack (0012/0014/0016/0017 + wlserver 0015) is
    deliberately NOT ported yet - it is one dependent set (drm_lease_send_touch,
    bIgnoreWhileLeased, g_nActiveLeaseClients) that conflicts with our
    dual-desktop wlserver/drm work. Revisit for Thor-class dual-panel devices.
    Verified: 0018-0021 apply clean on top of our full 3.16.24 patch stack.
