# rgbpi-3sx v0.1.1

Display settings update for RGB-Pi CRT output.

Included:
- ARM64 `3sx` binary rebuilt for RGB-Pi
- bundled SDL3/FFmpeg/runtime libraries
- RGB-Pi launcher scripts and config
- CRT-native `320x240` mode request
- auto refresh hint selection for `50`/`60` Hz
- in-game `Display Settings` menu entry
- `60hz mode` / `50hz mode` preview flow with a 10-second accept window
- accepted refresh is persisted into the external 3SX config
- no proprietary game assets

Install by extracting the attached tarball into `/media/sd/roms/ports` and then adding your own `SF33RD.AFS` or `3sx.iso` to `/media/sd/roms/ports/3sx/`.
