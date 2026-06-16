@echo off
setlocal

set BACKUP=%1
if "%BACKUP%"=="" set BACKUP=backup-slot0-before-x55-sdxc-fix.bin
set READBACK=slot0-after-restore-readback.bin

echo X55 SDXC Fix - Windows restore
echo ==============================
echo.
echo Restoring backup: %BACKUP%
echo.

if not exist "%BACKUP%" (
    echo ERROR: backup file not found: %BACKUP%
    echo Usage: restore-windows.bat backup-slot0-before-x55-sdxc-fix.bin
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

echo == Restoring %BACKUP% to eMMC LBA 64 ==
%RKDEV% write 64 "%BACKUP%"
if errorlevel 1 goto fail

echo.
echo == Reading back restored slot ==
%RKDEV% read 64 524288 "%READBACK%"
if errorlevel 1 goto fail

echo.
echo == SHA256 checksums ==
certutil -hashfile "%BACKUP%" SHA256
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
echo ERROR: restore failed.
pause
exit /b 1
