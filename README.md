# Stream Downloader - BAT

A robust, interactive command-line tool to analyze and download HLS streams (`.m3u8`) with precision. Built as a **Hybrid Batch/PowerShell** script, it leverages the power of `yt-dlp` and `FFmpeg` to offer a seamless downloading experience, even on unstable connections.

## Features

* **Smart Analysis:** Parses the manifest JSON to display available video resolutions and audio tracks in a readable menu.
* **Audio Selection:** Allows you to specifically choose the audio language (e.g., English vs. Turkish dub) before downloading.
* **Subtitle Support:** Detects internal subtitles or allows you to provide an external VTT/SRT URL to be downloaded alongside the video.
* **Resumable Downloads:** configured with `infinite retries` to handle network interruptions or slow connections without failure.
* **Hybrid Architecture:** Runs as a simple `.bat` file but executes advanced logic using a PowerShell wrapper.
* **Auto-Merge:** Automatically merges video and audio streams into a clean `.mp4` container.

## Prerequisites

This tool relies on two powerful binaries to function. You **must** place them in the same directory as the script.

1.  **[yt-dlp](https://github.com/yt-dlp/yt-dlp/releases):** The engine that handles the downloading and stream parsing.
2.  **[FFmpeg](https://ffmpeg.org/download.html):** The tool used to merge separate video and audio streams into a single file.

## 📥 Installation

1.  Clone this repository or download the `StreamDownloaderPro.bat` file.
2.  Download the latest `yt-dlp.exe` release.
3.  Download `ffmpeg.exe` (from a static build).
4.  **Important:** Ensure your folder structure looks exactly like this:

```text
MyDownloaderFolder/
│
├── StreamDownloaderPro.bat
├── yt-dlp.exe
└── ffmpeg.exe
```

## How to Use

1. Double-click StreamDownloaderPro.bat.

2. Paste the m3u8 link (Master Playlist) when prompted.

   - Tip: You can find this link using the Developer Tools (F12) -> Network Tab in your browser.
   - F12 -> Network Tab -> Filter for `m3u8` -> Get the link.
   - If video has separate subtitles, Filter for `vtt` -> Get the link for preferred language.

3. Wait for the analysis to complete.

4. Select your desired Video Quality (Input the number from the list).

5. Select your desired Audio Track (Input the number).

6. (Optional) Paste an external subtitle URL if needed.

7. The script will download and merge the files automatically.


## Technical Details

This script uses a polyglot technique to embed PowerShell code within a Batch file. This ensures maximum compatibility (just double-click to run) while allowing for complex JSON parsing and string manipulation that Batch cannot handle efficiently.

Key yt-dlp arguments used:

- `--retries infinite --fragment-retries infinite`: Ensures the download never fails due to network drops.

- `--dump-json`: Extracts metadata for the interactive menu.

- `--merge-output-format mp4`: Standardizes the output.

⚠️ Disclaimer

This tool is intended for educational purposes and personal archiving only. Please respect copyright laws and the terms of service of the websites you visit. Do not use this tool for piracy.
📄 License

This project is licensed under the MIT License.
