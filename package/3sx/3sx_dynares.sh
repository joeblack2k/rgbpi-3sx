#!/usr/bin/env bash
set -euo pipefail

PORT_DIR=/media/sd/roms/ports/3sx
CFG_FILE="$PORT_DIR/3sx.conf"
TIMINGS_FILE=/opt/rgbpi/ui/data/timings.dat

if [[ ! -f "$CFG_FILE" ]]; then
  echo "missing config: $CFG_FILE" >&2
  exit 1
fi

# shellcheck disable=SC1090
source "$CFG_FILE"

: "${crt_native_mode:=true}"
: "${crt_mode_width:=320}"
: "${crt_mode_height:=240}"
: "${crt_mode_refresh:=auto}"
: "${timing_240p60:=320 1 20 32 45 240 1 2 3 16 0 0 0 60.000000 0 6514560 1}"
: "${timing_240p50:=}"

mkdir -p "$log_dir" "$save_dir/home/.local/share/CrowdedStreet/3SX/resources"
LOG_FILE="$log_dir/run_$(date +%Y%m%dT%H%M%S).log"
exec >>"$LOG_FILE" 2>&1

echo "== 3SX RGB-Pi launcher =="
date -Is

append_timing_once() {
  local line="$1"
  [[ -n "$line" ]] || return 0
  [[ -f "$TIMINGS_FILE" ]] || return 0
  grep -qF "$line" "$TIMINGS_FILE" || echo "$line" >> "$TIMINGS_FILE"
}

detect_enabled_drm_connector() {
  local path
  for path in /sys/class/drm/card*-*/enabled; do
    [[ -r "$path" ]] || continue
    [[ "$(cat "$path")" == "enabled" ]] || continue
    printf '%s\n' "${path%/enabled}"
    return 0
  done
  return 1
}

probe_crt_refresh() {
  local refresh=0
  local fb_mode=
  local connector=
  local connector_name=

  if [[ -r /sys/class/graphics/fb0/modes ]]; then
    fb_mode=$(head -n 1 /sys/class/graphics/fb0/modes)
    if [[ "$fb_mode" =~ -([0-9]+)$ ]] && [[ "${BASH_REMATCH[1]}" -gt 0 ]]; then
      refresh="${BASH_REMATCH[1]}"
    fi
  fi

  connector=$(detect_enabled_drm_connector || true)
  connector_name="${connector##*/}"

  if [[ "$refresh" -eq 0 ]] && command -v modetest >/dev/null 2>&1 && [[ -n "$connector_name" ]]; then
    local line
    local current_section=0
    while IFS= read -r line; do
      if [[ "$line" == *$'\t'"connected"$'\t'"${connector_name}"* ]]; then
        current_section=1
        continue
      fi
      if [[ "$current_section" -eq 1 && "$line" == "  props:"* ]]; then
        break
      fi
      if [[ "$current_section" -eq 1 && "$line" =~ \#[0-9]+[[:space:]]+${crt_mode_width}x${crt_mode_height}[[:space:]]+([0-9]+\.[0-9]+) ]]; then
        refresh="${BASH_REMATCH[1]%.*}"
        break
      fi
    done < <(modetest -M vc4 -c 2>/dev/null || true)
  fi

  if [[ "$refresh" != "50" && "$refresh" != "60" ]]; then
    refresh=60
  fi

  printf '%s\n' "$refresh"
}

ensure_resources() {
  local dst="$save_dir/home/.local/share/CrowdedStreet/3SX/resources/SF33RD.AFS"
  mkdir -p "$(dirname "$dst")"
  if [[ -f "$dst" ]]; then
    return 0
  fi
  if [[ -f "$resource_path" ]]; then
    cp -f "$resource_path" "$dst"
    return 0
  fi
  if [[ -f "$iso_path" ]]; then
    local tmp
    tmp=$(mktemp -d)
    if 7za e -y -o"$tmp" "$iso_path" THIRD/SF33RD.AFS SF33RD.AFS >/dev/null 2>&1; then
      if [[ -f "$tmp/SF33RD.AFS" ]]; then
        mv "$tmp/SF33RD.AFS" "$dst"
      elif [[ -f "$tmp/THIRD/SF33RD.AFS" ]]; then
        mv "$tmp/THIRD/SF33RD.AFS" "$dst"
      fi
    fi
    rm -rf "$tmp"
  fi
  [[ -f "$dst" ]]
}

write_3sx_config() {
  local resolved_refresh="$1"
  local cfg_dir="$save_dir/home/.local/share/CrowdedStreet/3SX"
  mkdir -p "$cfg_dir"
  cat > "$cfg_dir/config" <<CFG
fullscreen = true
window-width = 640
window-height = 480
scale-mode = ${scale_mode}
crt-native-mode = ${crt_native_mode}
crt-mode-width = ${crt_mode_width}
crt-mode-height = ${crt_mode_height}
crt-mode-refresh = ${resolved_refresh}
draw-players-above-hud = false
CFG
}

append_timing_once "$timing_240p60"
append_timing_once "$timing_240p50"

if [[ "$crt_mode_refresh" == "auto" ]]; then
  crt_mode_refresh=$(probe_crt_refresh)
fi

echo "resolved CRT mode: ${crt_mode_width}x${crt_mode_height}@${crt_mode_refresh}"
write_3sx_config "$crt_mode_refresh"

if ! ensure_resources; then
  echo "missing resources: provide $resource_path or $iso_path" >&2
  exit 1
fi

export HOME="$save_dir/home"
export XDG_DATA_HOME="$save_dir/home/.local/share"
export SDL_VIDEODRIVER="$sdl_videodriver"
export SDL_AUDIODRIVER="$sdl_audiodriver"
export SDL_KMSDRM_DEVICE_INDEX="$sdl_kmsdrm_device_index"
export SDL_HIDAPI_UDEV=0
export SDL_JOYSTICK_DISABLE_UDEV=1
export LD_LIBRARY_PATH="$app_dir/lib:${LD_LIBRARY_PATH:-}"

exec "$app_dir/bin/3sx"
