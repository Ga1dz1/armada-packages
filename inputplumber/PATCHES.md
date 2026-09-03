# Patches

Patches applied on top of BASE.env. Each entry's `source` is an upstream URL pinned
to a commit, or `armada` if it's original; a URL source with no `notes` is verbatim.
`notes` mean the file was modified.

- `patches/0001-fix-gamepad-honor-passthrough-config-skip-exclusive-grab.patch`
  source: armada
- `patches/0002-fix-force-feedback-reset-effects-when-replacing-targets.patch`
  source: armada
  notes: resets rumble/force-feedback state when a virtual target is replaced
  or suspended - stops stuck rumble across sleep/resume and target swaps.
- `patches/0003-feat-touchscreen-deck-trackpads-mode.patch`
  source: armada
  notes: adds `mode: deck_trackpads` to TouchscreenConfig; the evdev touchscreen
  source then splits the screen horizontally into two virtual Steam Deck
  trackpads, emitting `Capability::Touchpad(LeftPad/RightPad, ...)` consumed by
  the deck-uhid target instead of `Capability::Touchscreen(...)`. Default mode
  is unchanged.
- `patches/0004-feat-manage-whitelisted-nebel-virtual-touchscreen.patch`
  source: armada
  notes: adds "Nebel Trackpad Screen" (our rotated internal-panel pass-through
  uinput touchscreen node) to VIRT_DEVICE_WHITELIST in src/input/manager.rs so
  the manager stops skipping it as a virtual device and composite configs can
  claim it as a touchscreen source.

- `patches/0005-feat-rp6-paddles-virtual-pad-into-ayn-composite.patch`
  source: armada
  notes: adds "Nebel RP6 Paddles" (the virtual gamepad node created by
  /usr/libexec/nebel/nebel-gpio-keys, vid 0x222A pid 0x0004, BTN_C/BTN_Z
  pass-through) to VIRT_DEVICE_WHITELIST in src/input/manager.rs so the
  manager stops skipping it as a virtual device. The vendored
  02-ayn-controller.yaml in the image adds a matching evdev source
  (vendor_id 222a product_id 0004) that maps BTN_C/BTN_Z via the existing
  ayn_mcu capability map to RightPaddle1/LeftPaddle1 (L4/R4).
- `patches/0006-feat-emulate-real-steam-deck-neptune-ids.patch`
  source: armada
  notes: default SteamDeckConfig emulates the real Neptune controller
  (28DE:1205, "Steam Deck", vendor "Valve") instead of 28DE:12F0 "Generic
  Steam Controller". Steam's client does not recognize 12F0 ("Unrecognized
  controller using V1 HID protocol") and never enables trackpads for it,
  even though the input reports carry valid pad data. (1.3.8 beta.)
