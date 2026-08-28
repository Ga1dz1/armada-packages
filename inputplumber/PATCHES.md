# Patches

Patches applied on top of BASE.env. Each entry's `source` is an upstream URL pinned
to a commit, or `armada` if it's original; a URL source with no `notes` is verbatim.
`notes` mean the file was modified.

- `patches/0001-fix-CapabilityMap-preserve-signed-axis-button-mappin.patch`
  source: armada
- `patches/0002-fix-gamepad-honor-passthrough-config-skip-exclusive-grab.patch`
  source: armada
- `patches/0003-feat-touchscreen-deck-trackpads-mode.patch`
  source: armada
  notes: adds `mode: deck_trackpads` to TouchscreenConfig; the evdev touchscreen
  source then splits the screen horizontally into two virtual Steam Deck
  trackpads, emitting `Capability::Touchpad(LeftPad/RightPad, ...)` consumed by
  the deck-uhid target instead of `Capability::Touchscreen(...)`. Default mode
  is unchanged.
