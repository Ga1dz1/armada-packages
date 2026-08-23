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
- `patches/0015-wlserver-offset-external-touch-180-with-force-external-orientation.patch`
  source: armada
  notes: When `--force-external-orientation` (patch 0014) is active, offsets the
    touch transform of the EXTERNAL connector by 180 degrees. The udev hwdb
    calibration for portrait-mounted-landscape panels (Retroid Dual Screen,
    USB 222a:0001) aligns the digitizer with the desktop stack (kwin's output
    transform), which sits exactly 180 degrees apart from what gamescope's
    connector-orientation touch transform expects; this makes one hwdb matrix
    serve both game mode and desktop.
