# svencoop-chatsounds

A PowerShell script that automates adding meme sounds to a self-hosted [Sven Co-op](https://store.steampowered.com/app/225840/Sven_Coop/) server running the [ChatSounds AngelScript plugin](https://github.com/Mikk155/ChatSounds).

Download a sound, run the script, restart server. Done.

---

## What it does

1. Scans your **Downloads folder** for `.mp3` or `.wav` files downloaded **today**
2. Checks the **duration** — anything over 15 seconds gets trimmed automatically
3. **Suggests a short keyword** based on the filename (strips filler words, takes first 2 meaningful words)
4. **Warns you** if the keyword is too long to type comfortably in chat (over 10 chars)
5. Converts each file to **8-bit, 11025 Hz, mono WAV** using FFmpeg (GoldSrc engine format)
6. Copies the converted file to your server's `sound\memes` folder
7. Appends a new trigger line to `ChatSounds.txt`
8. **Deletes the original** from your Downloads folder
9. Prints a summary of what was added

---

## Requirements

- Windows (PowerShell 5.1+)
- [FFmpeg](https://ffmpeg.org/download.html) — recommended path: `C:\ffmpeg\bin\ffmpeg.exe`
- Sven Co-op dedicated server with the [ChatSounds plugin](https://github.com/Mikk155/ChatSounds) installed

---

## Setup

1. Clone or download this repo
2. Double-click **`Install.bat`** — it will:
   - Check if FFmpeg is installed
   - Set the PowerShell execution policy
   - Unblock the script
   - Ask for your server path and save it to `config.txt`

That's it. You're ready to go.

---

## Usage

1. Download a meme sound (mp3 or wav)
2. Double-click **`Run.bat`**
3. Follow the prompts to set a keyword
4. Restart your Sven Co-op server
5. Type the keyword in chat ingame

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

  Warning: AH ITS COMING OUT (Golden Freddy Edition).mp3 is 24s, will be trimmed to 15s.
  Suggested: 'ah_its'
  Keyword (Enter to accept suggestion, type your own, or S to skip): goldenfreddy

This will:
  * Convert and copy 2 file(s) to: C:\svencoop_server\svencoop_addon\sound\memes
  * Append 2 line(s) to: C:\svencoop_server\svencoop_addon\scripts\plugins\cfg\ChatSounds.txt
  * Leave your Downloads folder untouched

Proceed? (y/n): y
  [CONVERT] COD MW2 HILARIOUS KID SCREAMING SUPER LOUD.mp3 -> kidscream.wav
  [DONE]    kidscream added
  [CLEAN]   Original removed from Downloads

  [CONVERT] AH ITS COMING OUT (Golden Freddy Edition).mp3 -> goldenfreddy.wav
  [DONE]    goldenfreddy added
  [CLEAN]   Original removed from Downloads

Added 2 sound(s):
  * kidscream
  * goldenfreddy

Restart your Sven Coop server to load the new sounds.
```

---

## Advanced usage

### Dry run (preview without making any changes)
```powershell
.\Add-MemeSounds.ps1 -DryRun
```

### Override paths at runtime
```powershell
.\Add-MemeSounds.ps1 -ServerRoot "D:\games\svencoop_server" -FFmpegPath "C:\tools\ffmpeg.exe"
```

---

## Audio format

Sounds are converted to **8-bit, 11025 Hz, mono WAV** — the native GoldSrc engine format. Smallest file size, fastest load times, with that classic CS 1.6 voice chat quality that fits right in with Sven Co-op.

---

## Notes

- Files already in the memes folder or already in `ChatSounds.txt` are skipped safely — no duplicates
- Sounds over 15 seconds are automatically trimmed, not rejected
- Keywords are lowercased and spaces replaced with underscores
- Only `.mp3` and `.wav` inputs are supported
- The script only ever writes inside your server folder — nothing else on your PC is touched
