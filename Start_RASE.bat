@echo off
setlocal EnableExtensions
title RASE Launcher

:: ===================================================================
::  RASE Launcher
::
::  Elevates once, then starts RASE in THIS console window.
::
::  Everything here is plain ASCII on purpose. cmd.exe uses the OEM
::  code page (866 on a Russian Windows), so any Cyrillic written in
::  a UTF-8 .bat would display as garbage unless the code page were
::  switched first. English text avoids the problem entirely.
:: ===================================================================

:: Change this one line if the script is renamed or moved.
set "RASE_SCRIPT=RASE_v73.6.9.ps1"


:: ---------- 1. Administrator check ----------
:: fltmc is present on every supported Windows and fails for a standard
:: user, which makes it a reliable and fast privilege probe.
fltmc >nul 2>&1
if %errorlevel% equ 0 goto :gotAdmin


:: ---------- 2. Elevate ----------
:: Re-launch THIS file elevated, then exit the unprivileged instance, so
:: only one console remains. Note %~f0 (full path) rather than %~s0 (short
:: 8.3 path): short-name generation is disabled on many systems - RASE
:: itself reports that setting - and %~s0 then silently returns the long
:: path anyway, breaking on any folder containing spaces.
echo.
echo  RASE requires Administrator privileges.
echo  Requesting elevation...
echo.
powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs" 2>nul
if %errorlevel% neq 0 (
    echo.
    echo  [ERROR] Elevation was refused or failed.
    echo          Right-click this file and choose "Run as administrator".
    echo.
    pause
)
exit /b


:gotAdmin
cd /d "%~dp0"


:: ---------- 3. Make sure the script is actually here ----------
if not exist "%RASE_SCRIPT%" (
    echo.
    echo  [ERROR] "%RASE_SCRIPT%" was not found in:
    echo          %~dp0
    echo.
    echo          Put this launcher in the same folder as the script,
    echo          or edit the RASE_SCRIPT line at the top of this file.
    echo.
    pause
    exit /b 3
)


:: ---------- 4. Menu ----------
:menu
cls
echo ============================================================
echo   ROMAN ADAPTIVE STORAGE ENGINE - Launcher
echo   Script : %RASE_SCRIPT%
echo   Folder : %~dp0
echo ============================================================
echo.
echo   [1]  Quick scan            - read-only, a few seconds
echo        Diagnostics and report only. Changes nothing.
echo.
echo   [2]  Full - dry run        - read-only, full pipeline
echo        Runs every phase but performs no write actions.
echo        Use this first on a machine you care about.
echo.
echo   [3]  Full maintenance      - no reboot
echo        Restore point, CHKDSK, DISM, SFC, cleanup, TRIM,
echo        defrag. Will not reboot under any circumstances.
echo.
echo   [4]  Full maintenance      - with reboot dialog
echo        Same as [3], but offers to restart at the end.
echo.
echo   [0]  Exit
echo.
set "CHOICE="
set /p "CHOICE=  Select and press Enter: "

if "%CHOICE%"=="1" set "RASE_ARGS=-Mode QuickScan" & goto :run
if "%CHOICE%"=="2" set "RASE_ARGS=-Mode Full -DryRun -NoReboot" & goto :run
if "%CHOICE%"=="3" set "RASE_ARGS=-Mode Full -NoReboot" & goto :run
if "%CHOICE%"=="4" set "RASE_ARGS=-Mode Full" & goto :run
if "%CHOICE%"=="0" exit /b 0

echo.
echo  Please enter 0, 1, 2, 3 or 4.
timeout /t 2 >nul
goto :menu


:: ---------- 5. Run ----------
:run
cls
echo.
echo  Starting: %RASE_SCRIPT% %RASE_ARGS%
echo.

:: -NoProfile keeps a user's PowerShell profile from interfering.
:: -ExecutionPolicy Bypass applies to this process only and changes
:: nothing system-wide - the script is not code-signed.
powershell -NoProfile -ExecutionPolicy Bypass -File ".\%RASE_SCRIPT%" %RASE_ARGS%
set "RC=%errorlevel%"

echo.
echo ============================================================
if "%RC%"=="0" echo   Exit code 0 - completed, nothing to report.
if "%RC%"=="1" echo   Exit code 1 - completed, findings to review in the report.
if "%RC%"=="2" echo   Exit code 2 - a phase or operation FAILED. Read the report.
if "%RC%"=="3" echo   Exit code 3 - fatal error. Check the error log.
if "%RC%" GEQ "4" echo   Exit code %RC% - unexpected. PowerShell may not have started.
echo ============================================================
echo.

:: RASE already waits for Enter on its own interactive path. This second
:: pause exists for the case where PowerShell never got that far - without
:: it, a startup failure would flash by and close the window.
pause
exit /b %RC%
