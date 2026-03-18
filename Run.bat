@echo off
:: Read config.txt if it exists
if not exist config.txt (
    echo Config not found. Please run Install.bat first.
    pause
    exit /b 1
)

for /f "tokens=1,2 delims==" %%A in (config.txt) do (
    if "%%A"=="ServerRoot" set SERVER_ROOT=%%B
    if "%%A"=="FFmpegPath" set FFMPEG_PATH=%%B
)

powershell -ExecutionPolicy Bypass -File "%~dp0Add-MemeSounds.ps1" -ServerRoot "%SERVER_ROOT%" -FFmpegPath "%FFMPEG_PATH%"
pause
