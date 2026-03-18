# Add-MemeSounds.ps1
# Sven Coop ChatSounds automation script
# Download a meme sound, run this script, done.
# Scans your Downloads folder for mp3/wav files downloaded today.

param(
    [string]$ServerRoot      = "C:\svencoop_server",
    [string]$FFmpegPath      = "C:\ffmpeg\bin\ffmpeg.exe",
    [string]$DownloadsFolder = "$env:USERPROFILE\Downloads",
    [switch]$DryRun          # Run with -DryRun to preview changes without applying them
)

# ── Derived paths ──────────────────────────────────────────────────────────────
$MemesFolder    = "$ServerRoot\svencoop_addon\sound\memes"
$ChatSoundsFile = "$ServerRoot\svencoop_addon\scripts\plugins\cfg\ChatSounds.txt"

# ── Helper ─────────────────────────────────────────────────────────────────────
function Abort($msg) {
    Write-Host ""
    Write-Host "  ERROR: $msg" -ForegroundColor Red
    Write-Host ""
    Write-Host "Nothing was changed." -ForegroundColor DarkGray
    Write-Host ""
    exit 1
}

# ── Safety: validate all paths before doing anything ──────────────────────────
Write-Host ""
Write-Host "Checking paths..." -ForegroundColor DarkGray

$checks = @(
    @{ Path = $FFmpegPath;      Label = "FFmpeg"           },
    @{ Path = $DownloadsFolder; Label = "Downloads folder" },
    @{ Path = $MemesFolder;     Label = "Memes folder"     },
    @{ Path = $ChatSoundsFile;  Label = "ChatSounds.txt"   }
)

$allGood = $true
foreach ($check in $checks) {
    if (Test-Path $check.Path) {
        Write-Host "  [OK] $($check.Label): $($check.Path)" -ForegroundColor DarkGreen
    } else {
        Write-Host "  [MISSING] $($check.Label): $($check.Path)" -ForegroundColor Red
        $allGood = $false
    }
}

if (-not $allGood) {
    Abort "One or more required paths are missing. Edit the defaults at the top of this script."
}

# ── Safety: confirm ServerRoot looks like a Sven Coop server ──────────────────
$expectedDirs = @(
    "$ServerRoot\svencoop",
    "$ServerRoot\svencoop_addon"
)
foreach ($dir in $expectedDirs) {
    if (-not (Test-Path $dir)) {
        Abort "'$ServerRoot' doesn't look like a Sven Coop server folder (missing: $dir).`nDouble-check your -ServerRoot path."
    }
}

# ── Find input files downloaded today ─────────────────────────────────────────
$Today      = (Get-Date).Date
$InputFiles = Get-ChildItem -Path $DownloadsFolder -File |
              Where-Object { $_.Extension -in ".mp3",".wav" -and $_.LastWriteTime -ge $Today }

if ($InputFiles.Count -eq 0) {
    Write-Host ""
    Write-Host "No mp3 or wav files downloaded today found in:" -ForegroundColor Yellow
    Write-Host "  $DownloadsFolder" -ForegroundColor Yellow
    Write-Host ""
    exit 0
}

# ── Preview what will happen ───────────────────────────────────────────────────
Write-Host ""
if ($DryRun) {
    Write-Host "DRY RUN — no changes will be made" -ForegroundColor Magenta
    Write-Host ""
}
Write-Host "Found $($InputFiles.Count) file(s) downloaded today:" -ForegroundColor Cyan
Write-Host ""

$ToProcess = @()
$Skipped   = @()

foreach ($File in $InputFiles) {
    $ExistingLines = Get-Content $ChatSoundsFile

    # Check duration via FFmpeg
    $DurationOutput = & $FFmpegPath -i $File.FullName 2>&1
    $DurationLine   = ($DurationOutput | Select-String "Duration") -join " "
    $Duration       = 0
    if ($DurationLine -match "Duration:\s*(\d+):(\d+):(\d+\.?\d*)") {
        if ($Matches -and $Matches.Count -ge 4) {
            $Duration = [int]$Matches[1] * 3600 + [int]$Matches[2] * 60 + [double]$Matches[3]
        }
    }
    $TrimTo = $null
    if ($Duration -gt 15) {
        Write-Host "  Warning: $($File.Name) is $([math]::Round($Duration))s, will be trimmed to 15s." -ForegroundColor Yellow
        $TrimTo = 15
    }

    # Ask user for a keyword
    $DefaultKeyword = $File.BaseName.ToLower() -replace '\s+', '_'

    # String logic: suggest a short keyword
    $FillerWords = @('the','a','an','of','in','and','for','to','with','from','by',
                     'at','on','is','it','its','this','that','was','are','be',
                     'feat','ft','official','video','audio','hd','full','original',
                     'sound','effect','free','prod','mix','remix','version','extended')
    $Words = $File.BaseName.ToLower() -split '[\s\-_\[\]\(\)\.\,]+'
    $Words = $Words | Where-Object { $_ -ne '' -and $_ -notin $FillerWords -and $_ -notmatch '^\d+$' }
    $Suggested = ($Words | Select-Object -First 2) -join '_'
    if ([string]::IsNullOrWhiteSpace($Suggested)) { $Suggested = $DefaultKeyword }

    Write-Host ""
    Write-Host "  File: $($File.Name)" -ForegroundColor Cyan

    if ($DefaultKeyword.Length -gt 10) {
        Write-Host "  Suggested: '$Suggested'" -ForegroundColor Green
        $Input = Read-Host "  Keyword (Enter to accept suggestion, type your own, or S to skip)"
    } else {
        $Input = Read-Host "  Keyword (Enter to use '$DefaultKeyword', S to skip)"
    }

    if ($Input.ToLower() -eq 's') {
        Write-Host "  [SKIP] Skipped." -ForegroundColor Yellow
        $Skipped += $File.Name
        continue
    }

    $Keyword = if ([string]::IsNullOrWhiteSpace($Input)) {
        if ($DefaultKeyword.Length -gt 10) { $Suggested } else { $DefaultKeyword }
    } else {
        $Input.ToLower() -replace '\s+', '_'
    }
    $OutputName = "$Keyword.wav"
    $OutputPath = "$MemesFolder\$OutputName"

    $alreadyWav    = Test-Path $OutputPath
    $alreadyConfig = $ExistingLines -match "^$Keyword\s"

    if ($alreadyWav -or $alreadyConfig) {
        Write-Host "  [SKIP] '$Keyword' already exists in ChatSounds." -ForegroundColor Yellow
        $Skipped += $Keyword
    } else {
        Write-Host "  [PENDING] '$Keyword'  ->  memes/$OutputName" -ForegroundColor White
        $ToProcess += @{ File = $File; Keyword = $Keyword; OutputName = $OutputName; OutputPath = $OutputPath }
    }
}

if ($ToProcess.Count -eq 0) {
    Write-Host ""
    Write-Host "Nothing new to add — all files already exist in ChatSounds." -ForegroundColor Yellow
    Write-Host ""
    exit 0
}

# ── Confirmation prompt ────────────────────────────────────────────────────────
Write-Host ""
if ($DryRun) {
    Write-Host "Dry run complete. Re-run without -DryRun to apply these changes." -ForegroundColor Magenta
    Write-Host ""
    exit 0
}

Write-Host "This will:" -ForegroundColor White
Write-Host "  * Convert and copy $($ToProcess.Count) file(s) to: $MemesFolder" -ForegroundColor White
Write-Host "  * Append $($ToProcess.Count) line(s) to: $ChatSoundsFile" -ForegroundColor White
Write-Host "  * Leave your Downloads folder untouched" -ForegroundColor White
Write-Host ""
$confirm = Read-Host "Proceed? (y/n)"
if ($confirm -notmatch '^y(es)?$') {
    Write-Host ""
    Write-Host "Cancelled. Nothing was changed." -ForegroundColor DarkGray
    Write-Host ""
    exit 0
}

# ── Process files ──────────────────────────────────────────────────────────────
Write-Host ""
$Added  = @()
$Errors = @()

foreach ($item in $ToProcess) {
    $File       = $item.File
    $Keyword    = $item.Keyword
    $OutputName = $item.OutputName
    $OutputPath = $item.OutputPath

    Write-Host "  [CONVERT] $($File.Name) -> $OutputName" -ForegroundColor White

    $FFmpegArgs = @("-y", "-i", $File.FullName)
    if ($TrimTo) { $FFmpegArgs += @("-t", "$TrimTo") }
    $FFmpegArgs += @("-ar", "11025", "-ac", "1", "-acodec", "pcm_u8", $OutputPath)

    $Result = & $FFmpegPath @FFmpegArgs 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  [ERROR]   FFmpeg failed on $($File.Name)" -ForegroundColor Red
        $Errors += $Keyword
        continue
    }

    Add-Content -Path $ChatSoundsFile -Value "$Keyword memes/$OutputName"
    Write-Host "  [DONE]    $Keyword added" -ForegroundColor Green
    $Added += $Keyword
}

# ── Summary ────────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "------------------------------" -ForegroundColor DarkGray

if ($Added.Count -gt 0) {
    Write-Host "Added $($Added.Count) sound(s):" -ForegroundColor Green
    $Added | ForEach-Object { Write-Host "  * $_" -ForegroundColor Green }
}
if ($Skipped.Count -gt 0) {
    Write-Host "Skipped $($Skipped.Count) (already exist):" -ForegroundColor Yellow
    $Skipped | ForEach-Object { Write-Host "  * $_" -ForegroundColor Yellow }
}
if ($Errors.Count -gt 0) {
    Write-Host "Failed $($Errors.Count):" -ForegroundColor Red
    $Errors | ForEach-Object { Write-Host "  * $_" -ForegroundColor Red }
}

Write-Host "------------------------------" -ForegroundColor DarkGray
Write-Host ""

if ($Added.Count -gt 0) {
    Write-Host "Restart your Sven Coop server to load the new sounds." -ForegroundColor Cyan
    Write-Host ""
}
