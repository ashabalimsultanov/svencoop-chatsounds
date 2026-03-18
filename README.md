# svencoop-chatsounds

A PowerShell script that automates adding meme sounds to a self-hosted [Sven Co-op](https://store.steampowered.com/app/225840/Sven_Coop/) server running the [ChatSounds AngelScript plugin](https://github.com/Mikk155/ChatSounds).

Download a sound, run the script, restart server. Done.

---

## What it does

1. Scans your **Downloads folder** for `.mp3` or `.wav` files downloaded **today**
2. Checks the **duration** — anything over 15 seconds gets trimmed automatically
3. **Suggests a short keyword** based on the filename (strips filler words, takes first 2 meaningful words)
4. **Warns you** if the keyword is too long to type comfortably in chat
5. Converts each file to **8-bit, 11025 Hz, mono WAV** using FFmpeg (GoldSrc engine format)
6. Copies the converted file to your server's `sound\memes` folder
7. Appends a new trigger line to `ChatSounds.txt`
8. Prints a summary of what was added

Your Downloads folder is never modified.

---

## Requirements

- Windows (PowerShell 5.1+)
- [FFmpeg](https://ffmpeg.org/download.html) installed at `C:\ffmpeg\bin`
- Sven Co-op dedicated server with the [ChatSounds plugin](https://github.com/Mikk155/ChatSounds) installed

---

## One-time setup

1. Clone or download this repo:
   ```
   git clone https://github.com/YOUR_USERNAME/svencoop-chatsounds.git
   ```

2. Allow PowerShell to run local scripts (run once):
   ```powershell
   Set-ExecutionPolicy -Scope CurrentUser Unrestricted
   ```

3. Unblock the script file:
   ```powershell
   Unblock-File .\Add-MemeSounds.ps1
   ```

4. Open `Add-MemeSounds.ps1` and check the three default paths at the top:
   ```powershell
   param(
       [string]$ServerRoot      = "C:\svencoop_server",
       [string]$FFmpegPath      = "C:\ffmpeg\bin\ffmpeg.exe",
       [string]$DownloadsFolder = "$env:USERPROFILE\Downloads"
   )
   ```
   Edit them if your setup is different.

---

## Usage

```
1. Download a meme sound (mp3 or wav)
2. Run: .\Add-MemeSounds.ps1
3. Follow the prompts to set keywords
4. Restart your Sven Co-op server
5. Type the keyword in chat ingame
```

### Example session

```
Checking paths...
  [OK] FFmpeg: C:\ffmpeg\bin\ffmpeg.exe
  [OK] Downloads folder: C:\Users\you\Downloads
  [OK] Memes folder: C:\svencoop_server\svencoop_addon\sound\memes
  [OK] ChatSounds.txt: C:\svencoop_server\svencoop_addon\scripts\plugins\cfg\ChatSounds.txt

Found 2 file(s) downloaded today:

  File: COD MW2 HILARIOUS KID SCREAMING SUPER LOUD.mp3
  Suggested: 'cod_mw2'
  Keyword (Enter to accept suggestion, type your own, or S to skip): kidscream

  File: vine-boom.mp3
  Keyword (Enter to use 'vine-boom', S to skip):

This will:
  * Convert and copy 2 file(s) to: C:\svencoop_server\svencoop_addon\sound\memes
  * Append 2 line(s) to: C:\svencoop_server\svencoop_addon\scripts\plugins\cfg\ChatSounds.txt
  * Leave your Downloads folder untouched

Proceed? (y/n): y
  [CONVERT] COD MW2 HILARIOUS KID SCREAMING SUPER LOUD.mp3 -> kidscream.wav
  [DONE]    kidscream added
  [CONVERT] vine-boom.mp3 -> vine-boom.wav
  [DONE]    vine-boom added

Added 2 sound(s):
  * kidscream
  * vine-boom

Restart your Sven Coop server to load the new sounds.
```

### Dry run (preview without changes)

```powershell
.\Add-MemeSounds.ps1 -DryRun
```

### Override paths at runtime

```powershell
.\Add-MemeSounds.ps1 -ServerRoot "D:\games\svencoop_server" -DownloadsFolder "D:\MySounds"
```

---

## Audio format

Sounds are converted to **8-bit, 11025 Hz, mono WAV** — the native GoldSrc engine format. This gives the smallest file size and fastest load times, with that classic CS 1.6 voice chat quality that fits right in.

---

## Notes

- Files already in the memes folder or already in `ChatSounds.txt` are skipped safely
- Sounds over 15 seconds are automatically trimmed to 15 seconds
- Keywords are lowercased and spaces replaced with underscores
- Only `.mp3` and `.wav` inputs are supported
