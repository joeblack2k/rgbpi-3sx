# rgbpi-3sx

RGB-Pi packaging for 3SX on Raspberry Pi 4.

This repository is the public distribution layer for running 3SX as an RGB-Pi port. It contains the RGB-Pi launcher wrapper, port config, rebuilt ARM64 binary, bundled runtime libraries, and license files needed to drop the port into the RGB-Pi `Ports` menu.

It intentionally does not contain game data or other proprietary assets.

## What this is

- A ready-to-extract RGB-Pi port package
- Built for Raspberry Pi 4 / RGB-Pi OS style deployments
- Meant to live under `/media/sd/roms/ports`
- Packaged so end users only need to:
  1. extract the release into the `ports` folder
  2. add their own dumped game data
  3. launch it from the RGB-Pi `Ports` system

## What this is not

- Not a full RGB-Pi image
- Not a fork of the original 3SX source tree for active development
- Not a source drop for copyrighted PS2/game assets
- Not a repository for BIOS files, ISOs, AFS archives, saves, or memory card images

## Included in this repo

- `package/3sx.sh`
- `package/3sx/3sx_dynares.sh`
- `package/3sx/3sx.conf`
- `package/3sx/app/bin/3sx`
- `package/3sx/app/lib/*`
- `package/3sx/app/share/3sx/licenses/*`
- release metadata and install documentation

## Not included

You must provide your own dumped game data.

Not included:

- `SF33RD.AFS`
- `3sx.iso`
- PS2 disc images
- BIOS files
- saves / memory cards
- any other proprietary game files

## Quick install

1. Open the latest release in this repository.
2. Download:
   - `rgbpi-3sx-v0.1.2-ports.tar.gz`
   - optionally `rgbpi-3sx-v0.1.2-ports.tar.gz.sha256`
3. Copy the tarball to your RGB-Pi system.
4. Extract it directly into:
   - `/media/sd/roms/ports`
5. Add your own dumped game data into:
   - `/media/sd/roms/ports/3sx/`
6. Launch `3sx` from the RGB-Pi `Ports` menu.

## Exact target layout after extraction

After extracting the release into `/media/sd/roms/ports`, you should have:

```text
/media/sd/roms/ports/3sx.sh
/media/sd/roms/ports/3sx/3sx.conf
/media/sd/roms/ports/3sx/3sx_dynares.sh
/media/sd/roms/ports/3sx/app/bin/3sx
/media/sd/roms/ports/3sx/app/lib/...
/media/sd/roms/ports/3sx/app/share/3sx/licenses/...
```

Then place one of these in the same `3sx` folder:

- `/media/sd/roms/ports/3sx/SF33RD.AFS`
- `/media/sd/roms/ports/3sx/3sx.iso`

The wrapper will use `SF33RD.AFS` directly if present. If only `3sx.iso` is present, it will try to extract `SF33RD.AFS` from that ISO into the save/home path.

## Release files

Each GitHub release ships:

- `rgbpi-3sx-vX.Y.Z-ports.tar.gz`
  - the actual RGB-Pi port package to extract into `ports`
- `rgbpi-3sx-vX.Y.Z-ports.tar.gz.sha256`
  - checksum for verifying the download

## Verifying the download

On Linux:

```bash
sha256sum -c rgbpi-3sx-v0.1.2-ports.tar.gz.sha256
```

If you want to compare manually, the current `v0.1.2` archive checksum is:

```text
27cd2f0d3c0e13b52c526ff8b3e6fa0c13ddf0ba087f959b10a8b7dbb9607d20
```

## CRT behavior

This package is set up specifically for low-resolution RGB-Pi CRT output.

Current behavior:

- requests a native `320x240` mode
- does not use the old `2624x224` super-resolution path
- writes a `crt-mode-refresh` hint based on the live DRM/fb state
- prefers `50` or `60` Hz when that information is available
- validated on RGB-Pi VGA output at `320x240 @ 59.85 Hz`

## Display settings menu

The old `Screen adjust` item is replaced with `Display Settings`.

Inside that menu:

- `60hz mode` switches to the RGB-Pi 240p/60 output mode
- `50hz mode` switches to the RGB-Pi 240p/50 output mode
- after switching, 3SX shows a 10-second confirmation prompt
- press `X` to keep the new mode
- if you do nothing, it automatically reverts to the previous CRT mode
- a confirmed refresh is written back to the external 3SX config

### Why this matters

RGB-Pi setups with a real RGB hat are much happier with actual low-resolution modes than with super-resolution tricks. This package is configured around that constraint.

## Current port config

Important defaults in `package/3sx/3sx.conf`:

- `crt_native_mode=true`
- `crt_mode_width=320`
- `crt_mode_height=240`
- `crt_mode_refresh=auto`
- `scale_mode=square-pixels`
- `sdl_videodriver=kmsdrm`
- `sdl_audiodriver=alsa`

## Save and runtime paths

At runtime, the wrapper uses these RGB-Pi paths:

- app path:
  - `/media/sd/roms/ports/3sx/app`
- save/home path:
  - `/media/sd/saves/ports/3sx`
- runtime logs:
  - `/media/sd/roms/ports/3sx/logs`
- generated 3SX config:
  - `/media/sd/saves/ports/3sx/home/.local/share/CrowdedStreet/3SX/config`

## Troubleshooting

### Port does not appear in RGB-Pi

Check that:

- `3sx.sh` exists in `/media/sd/roms/ports`
- `3sx.sh` is executable
- `/media/sd/roms/ports/3sx/3sx_dynares.sh` is executable

### Port starts but exits immediately

Check for:

- missing `SF33RD.AFS`
- missing `3sx.iso`
- broken extraction path
- missing execute bit on `app/bin/3sx`

Then inspect:

- `/media/sd/roms/ports/3sx/logs/`

### No game data found

Put one of the following in `/media/sd/roms/ports/3sx/`:

- `SF33RD.AFS`
- `3sx.iso`

### Wrong display mode

Inspect:

- `/media/sd/roms/ports/3sx/logs/run_*.log`
- `/media/sd/saves/ports/3sx/home/.local/share/CrowdedStreet/3SX/config`

The wrapper logs the resolved CRT mode and SDL logs the actual fullscreen mode it got from KMSDRM.

## Legal

Bring your own disc dump / extracted data.

Do not upload any of the following to this repository or its releases:

- `SF33RD.AFS`
- `3sx.iso`
- PS2 discs / images
- BIOS files
- proprietary assets from the game

## Credits

- upstream 3SX authors and contributors
- SDL / FFmpeg / bundled third-party projects listed in `package/3sx/app/share/3sx/licenses/`

## Repository purpose

This repository exists so people can grab a clean RGB-Pi-ready build from GitHub Releases without touching proprietary files. The release asset is the thing end users should install; the repository contents are there to document and reproduce that package.
