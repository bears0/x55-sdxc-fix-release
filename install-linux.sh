#!/usr/bin/env bash
set -euo pipefail

BIN="x55-loader-SDXC-fix.bin"
BACKUP="backup-slot0-before-x55-sdxc-fix.bin"
READBACK="x55-loader-SDXC-fix-readback.bin"

echo "X55 SDXC Fix - Linux installer"
echo "================================"
echo
echo "This writes a raw 512 KiB RKNS loader-slot image to eMMC LBA 64."
echo "This is for Powkiddy X55 / RK3566 only."
echo

if ! command -v rkdeveloptool >/dev/null 2>&1; then
    echo "ERROR: rkdeveloptool not found."
    exit 1
fi

if [ ! -f "$BIN" ]; then
    echo "ERROR: $BIN not found in current folder."
    exit 1
fi

SIZE="$(stat -c '%s' "$BIN")"
if [ "$SIZE" != "524288" ]; then
    echo "ERROR: $BIN must be exactly 524288 bytes. Found: $SIZE"
    exit 1
fi

echo "== Device list =="
sudo rkdeveloptool ld
echo

echo "== Backing up current slot 0 to $BACKUP =="
sudo rkdeveloptool read 64 524288 "$BACKUP"

echo
echo "== Writing $BIN to eMMC LBA 64 =="
sudo rkdeveloptool write 64 "$BIN"

echo
echo "== Reading back written slot =="
sudo rkdeveloptool read 64 524288 "$READBACK"

echo
echo "== Verifying readback =="
sha256sum "$BIN" "$READBACK"
cmp "$BIN" "$READBACK"

echo
echo "SUCCESS: Readback matches."
echo "Backup saved as: $BACKUP"
echo
echo "Rebooting device..."
sudo rkdeveloptool rd || true
