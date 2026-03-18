@echo off
title Sven Coop ChatSounds - Setup
color 0A
echo.
echo  ============================================
echo   Sven Coop ChatSounds - Setup
echo  ============================================
echo.

:: Check if running as admin (not required but nice to know)
net session >nul 2>&1
if %errorLevel% == 0 (
    echo  [OK] Running with admin rights
) else (
    echo  [OK] Running as normal user
)

:: Check if FFmpeg is installed
echo.
echo  Checking for FFmpeg...
where ffmpeg >nul 2>&1
if %errorLevel% == 0 (
    echo  [OK] FFmpeg found in PATH
    set FFMPEG_PATH=ffmpeg
) else if exist "C:\ffmpeg\bin\ffmpeg.exe" (
    echo  [OK] FFmpeg found at C:\ffmpeg\bin\ffmpeg.exe
    set FFMPEG_PATH=C:\ffmpeg\bin\ffmpeg.exe
) else (
    echo  [MISSING] FFmpeg not found!
    echo.
    echo  Please download FFmpeg and install it:
    echo  https://ffmpeg.org/download.html
    echo.
    echo  Recommended: extract to C:\ffmpeg so the exe is at C:\ffmpeg\bin\ffmpeg.exe
    echo.
    pause
    exit /b 1
)

:: Set PowerShell execution policy
echo.
echo  Setting PowerShell execution policy...
powershell -Command "Set-ExecutionPolicy -Scope CurrentUser Unrestricted -Force"
if %errorLevel% == 0 (
    echo  [OK] Execution policy set
) else (
    echo  [WARN] Could not set execution policy, you may need to do this manually
)

:: Unblock the script
echo.
echo  Unblocking Add-MemeSounds.ps1...
powershell -Command "Unblock-File '.\Add-MemeSounds.ps1'"
if %errorLevel% == 0 (
    echo  [OK] Script unblocked
) else (
    echo  [WARN] Could not unblock script
)

:: Ask for server path
echo.
echo  ============================================
echo   Configuration
echo  ============================================
echo.
echo  Where is your Sven Coop server installed?
echo  (Press Enter for default: C:\svencoop_server)
echo.
set /p SERVER_ROOT="  Server path: "
if "%SERVER_ROOT%"=="" set SERVER_ROOT=C:\svencoop_server

:: Validate server path
if not exist "%SERVER_ROOT%\svencoop" (
    echo.
    echo  [WARN] '%SERVER_ROOT%\svencoop' not found - are you sure this is the right path?
    echo  You can edit config.txt later to fix this.
)

:: Ask for FFmpeg path
echo.
echo  Where is ffmpeg.exe?
echo  (Press Enter for default: C:\ffmpeg\bin\ffmpeg.exe)
echo.
set /p FFMPEG_INPUT="  FFmpeg path: "
if "%FFMPEG_INPUT%"=="" set FFMPEG_INPUT=C:\ffmpeg\bin\ffmpeg.exe

:: Write config file
echo.
echo  Writing config.txt...
(
    echo # Sven Coop ChatSounds - Config
    echo # Edit these paths to match your setup
    echo.
    echo ServerRoot=%SERVER_ROOT%
    echo FFmpegPath=%FFMPEG_INPUT%
) > config.txt
echo  [OK] config.txt created

:: Done
echo.
echo  ============================================
echo   Setup complete!
echo  ============================================
echo.
echo  To add sounds:
echo    1. Download an mp3 or wav file
echo    2. Double-click Run.bat  (or run Add-MemeSounds.ps1 in PowerShell)
echo    3. Follow the prompts
echo    4. Restart your Sven Coop server
echo.
pause
