@echo off
setlocal

set BIN=x55-loader-SDXC-fix.bin
set BACKUP=backup-slot0-before-x55-sdxc-fix.bin
set READBACK=x55-loader-SDXC-fix-readback.bin

echo X55 SDXC Fix - Windows installer
echo ================================
echo.
echo This writes a raw 512 KiB RKNS loader-slot image to eMMC LBA 64.
echo This is for Powkiddy X55 / RK3566 only.
echo.
echo Requirements:
echo - Rockchip USB driver installed
echo - rkdeveloptool.exe in this folder or in PATH
echo - X55 in Rockchip Loader mode
echo.

if not exist "%BIN%" (
    echo ERROR: %BIN% not found.
    pause
    exit /b 1
)

where rkdeveloptool.exe >nul 2>nul
if errorlevel 1 (
    if not exist "rkdeveloptool.exe" (
        echo ERROR: rkdeveloptool.exe not found in PATH or this folder.
        pause
        exit /b 1
    )
    set RKDEV=.\rkdeveloptool.exe
) else (
    set RKDEV=rkdeveloptool.exe
)

echo == Device list ==
%RKDEV% ld
echo.

echo == Backing up current slot 0 to %BACKUP% ==
%RKDEV% read 64 524288 "%BACKUP%"
if errorlevel 1 goto fail

echo.
echo == Writing %BIN% to eMMC LBA 64 ==
%RKDEV% write 64 "%BIN%"
if errorlevel 1 goto fail

echo.
echo == Reading back written slot ==
%RKDEV% read 64 524288 "%READBACK%"
if errorlevel 1 goto fail

echo.
echo == SHA256 checksums ==
certutil -hashfile "%BIN%" SHA256
certutil -hashfile "%READBACK%" SHA256

echo.
echo IMPORTANT:
echo Compare the two SHA256 values above. They must match.
echo If they match, press any key to reboot the device.
pause

%RKDEV% rd
echo Done.
pause
exit /b 0

:fail
echo.
echo ERROR: install failed.
echo If the backup step succeeded, your backup is: %BACKUP%
pause
exit /b 1
