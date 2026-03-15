# rgbpi-3sx

RGB-Pi packaging for 3SX on Raspberry Pi 4.

This repository distributes only the RGB-Pi port wrapper, the rebuilt ARM64 binary, bundled runtime libraries, and license files.
It does not include any game data, disc images, AFS archives, BIOS files, memory cards, saves, or other proprietary assets.

## Install

1. Download the release asset `rgbpi-3sx-v0.1.0-ports.tar.gz` from Releases.
2. Extract it directly into your RGB-Pi ports folder:
   - target folder: `/media/sd/roms/ports`
3. Put your own dumped game data in `/media/sd/roms/ports/3sx/`:
   - `SF33RD.AFS`, or
   - `3sx.iso`
4. Launch `3sx` from the RGB-Pi `Ports` system.

## What the release contains

- `3sx.sh`
- `3sx/3sx_dynares.sh`
- `3sx/3sx.conf`
- `3sx/app/bin/3sx`
- `3sx/app/lib/*`
- `3sx/app/share/3sx/licenses/*`

## CRT behavior

- Requests a native `320x240` RGB-Pi mode.
- Auto-resolves `50` or `60` Hz from the live DRM/fb state when available.
- Validated on RGB-Pi VGA output as `320x240 @ 59.85 Hz`.
- No `2624x224` super-resolution path in this package.

## Legal

Bring your own disc dump / extracted data.
Do not upload proprietary PS2 assets to this repository or its releases.
