# Powkiddy X55 SDXC Boot Fix Loader

This package contains a fixed loader-slot image for the **Powkiddy X55 / RK3566**.

It is intended to fix a boot issue where some larger SDXC cards, especially 128 GB cards, fail during SPL SD initialization with errors such as:

```text
Card did not respond to voltage select!
mmc_init: -95
```

The fix adds a short delay and retry loop during early SD card initialization before the CMD8 / ACMD41 negotiation path.

## Files

| File | Purpose |
|---|---|
| `x55-loader-SDXC-fix.bin` | Raw 512 KiB RKNS loader-slot image |
| `x55-loader-SDXC-fix.bin.sha256` | SHA256 checksum for the loader image |
| `CHECKSUMS.txt` | SHA256 checksum list |
| `install-linux.sh` | Linux installer using `rkdeveloptool` |
| `restore-linux.sh` | Linux restore script using the backup created by the installer |
| `install-windows.bat` | Windows installer using `rkdeveloptool.exe` |
| `restore-windows.bat` | Windows restore script using the backup created by the installer |
| `x55-sdxc-fix.patch` | Source patch showing the SDXC workaround and boot banner |

## Important warning

This file is **not** a normal Rockchip `LDR` upgrade-loader package.

It is a **raw 512 KiB RKNS loader-slot image** and must be written to:

```text
eMMC LBA 64
```

Do **not** use this file with RKDevTool's normal **Upgrade Loader** button.

## Device compatibility

Tested target:

```text
Powkiddy X55
Rockchip RK3566
1 GB RAM
```

Do not install this on other RK3566 devices unless you are prepared to recover with MaskROM.

## What it changes

This replaces the first eMMC loader slot with a loader using a patched U-Boot SPL.

The patch keeps the original RKNS-style loader-slot structure and valid per-entry SHA256 hashes.

The SDXC workaround is in:

```text
drivers/mmc/mmc.c
```

The visible boot banner is in:

```text
arch/arm/mach-rockchip/spl.c
```

On serial, the fixed loader prints:

```text
U-Boot SPL board init
X55 SDXC fix loader v1
```

## Linux install

You will need rkdeveloptool
```bash
sudo apt update
sudo apt install rkdeveloptool
```

Put the X55 into Rockchip Loader mode:
1. Power off
2. Remove SD cards (important)
3. Push left analog stick to the left
4. Plug in a USB-C data cable
5. Hit the reset button.
6. The screen will remain black*
 then run:

```bash
chmod +x install-linux.sh restore-linux.sh
./install-linux.sh
```

The installer will:

1. Read and save the current slot 0 backup as `backup-slot0-before-x55-sdxc-fix.bin`
2. Write `x55-loader-SDXC-fix.bin` to LBA 64
3. Read back 524288 bytes
4. Compare the readback against the installer image
5. Reboot the device

## Linux restore

To restore the backup made during install:

```bash
./restore-linux.sh backup-slot0-before-x55-sdxc-fix.bin
```

## Windows install

Requirements:

1. Rockchip USB driver installed
2. `rkdeveloptool.exe` in the same folder as this package, or available in PATH
3. X55 in Rockchip Loader mode

Put the X55 into Rockchip Loader mode:
1. Power off
2. Remove SD cards (important)
3. Push left analog stick to the left
4. Plug in a USB-C data cable
5. Hit the reset button.
6. The screen will remain black*
 then run:

```text
install-windows.bat
```

The script will back up the current loader slot before writing the fixed image.

After writing, it prints SHA256 hashes for the source image and readback image. They must match.

## Windows restore

To restore the backup made during install:

```text
restore-windows.bat backup-slot0-before-x55-sdxc-fix.bin
```

## Technical details

The installed file is:

```text
x55-loader-SDXC-fix.bin
size: 524288 bytes
format: raw RKNS loader-slot image
target write offset: LBA 64
readback verification length: 524288 bytes
```

The SD card initialization change adds:

- A 250 ms settle delay after power/clock setup
- Up to 5 attempts through CMD0, CMD8, and ACMD41
- Small delays between early SD commands

## Recovery note

The installer creates a backup before writing:

```text
backup-slot0-before-x55-sdxc-fix.bin
```

Keep that backup. It can be restored with the included restore script.
