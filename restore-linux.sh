#!/usr/bin/env bash
set -euo pipefail

BACKUP="${1:-backup-slot0-before-x55-sdxc-fix.bin}"
READBACK="slot0-after-restore-readback.bin"

echo "X55 SDXC Fix - Linux restore"
echo "============================"
echo

if ! command -v rkdeveloptool >/dev/null 2>&1; then
    echo "ERROR: rkdeveloptool not found."
    exit 1
fi

if [ ! -f "$BACKUP" ]; then
    echo "ERROR: backup file not found: $BACKUP"
    echo "Usage: ./restore-linux.sh backup-slot0-before-x55-sdxc-fix.bin"
    exit 1
fi

SIZE="$(stat -c '%s' "$BACKUP")"
if [ "$SIZE" != "524288" ]; then
    echo "ERROR: backup must be exactly 524288 bytes. Found: $SIZE"
    exit 1
fi

echo "== Device list =="
sudo rkdeveloptool ld
echo

echo "== Restoring $BACKUP to eMMC LBA 64 =="
sudo rkdeveloptool write 64 "$BACKUP"

echo
echo "== Reading back restored slot =="
sudo rkdeveloptool read 64 524288 "$READBACK"

echo
echo "== Verifying restore =="
sha256sum "$BACKUP" "$READBACK"
cmp "$BACKUP" "$READBACK"

echo
echo "SUCCESS: Restore verified."
echo "Rebooting device..."
sudo rkdeveloptool rd || true
