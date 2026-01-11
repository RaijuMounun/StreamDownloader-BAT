<# :
@echo off
setlocal
title Stream Downloader v3.0
color 0b
cls

echo.
echo ========================================================
echo          STREAM DOWNLOADER v3.0
echo ========================================================
echo.

:: Invoke PowerShell from Batch
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& {[ScriptBlock]::Create((Get-Content '%~f0' -Raw)).Invoke()}"
pause
goto :EOF
#>

# --- POWERSHELL SCRIPT START ---

function Main {
    # 1. GET URL
    Write-Host ">> Paste Video Link (m3u8 / URL): " -NoNewline -ForegroundColor Cyan
    $url = Read-Host
    
    if ([string]::IsNullOrWhiteSpace($url)) {
        Write-Host "Error: No URL provided." -ForegroundColor Red
        return
    }

    Write-Host "`nAnalyzing metadata... Please wait..." -ForegroundColor Yellow
    
    # Fetch JSON metadata using yt-dlp
    try {
        $jsonCommand = ".\yt-dlp.exe --dump-json --no-warnings ""$url"""
        $jsonOutput = Invoke-Expression $jsonCommand
        $data = $jsonOutput | ConvertFrom-Json
    }
    catch {
        Write-Host "ERROR: Could not analyze the link. Is 'yt-dlp.exe' in the same folder?" -ForegroundColor Red
        return
    }

    $formats = $data.formats

    # --- 2. VIDEO SELECTION ---
    Write-Host "`n=== [ SELECT VIDEO QUALITY ] ===" -ForegroundColor Green
    
    # Filter only video streams (resolution not null)
    $videos = $formats | Where-Object { $null -ne $_.resolution -and $_.vcodec -ne 'none' } | Sort-Object height -Descending

    $vIndex = 1
    $videoMap = @{}

    foreach ($vid in $videos) {
        $res = $vid.resolution
        $id = $vid.format_id
        $note = $vid.format_note
        $ext = $vid.ext
        
        Write-Host "[$vIndex] $res ($note) - $ext"
        $videoMap[$vIndex] = $id
        $vIndex++
    }

    Write-Host "----------------------------"
    Write-Host "Selection (Number, Enter = Best): " -NoNewline -ForegroundColor Cyan
    $vChoice = Read-Host
    
    if ([string]::IsNullOrWhiteSpace($vChoice) -or -not $videoMap.ContainsKey([int]$vChoice)) {
        $selectedVideoID = "bestvideo"
        Write-Host ">> Default (Best Video) selected." -ForegroundColor DarkGray
    } else {
        $selectedVideoID = $videoMap[[int]$vChoice]
        Write-Host ">> Selected Video ID: $selectedVideoID" -ForegroundColor DarkGray
    }

    # --- 3. AUDIO SELECTION ---
    Write-Host "`n=== [ SELECT AUDIO TRACK ] ===" -ForegroundColor Green
    
    # Filter only audio streams
    $audios = $formats | Where-Object { $_.acodec -ne 'none' -and $_.vcodec -eq 'none' }
    
    $aIndex = 1
    $audioMap = @{}

    foreach ($aud in $audios) {
        $id = $aud.format_id
        $lang = if ($aud.language) { $aud.language } else { "Unknown" }
        $idHint = $id
        
        Write-Host "[$aIndex] Language: $lang (ID: $idHint)"
        $audioMap[$aIndex] = $id
        $aIndex++
    }

    Write-Host "----------------------------"
    Write-Host "Selection (Number, Enter = Best): " -NoNewline -ForegroundColor Cyan
    $aChoice = Read-Host

    if ([string]::IsNullOrWhiteSpace($aChoice) -or -not $audioMap.ContainsKey([int]$aChoice)) {
        $selectedAudioID = "bestaudio"
        Write-Host ">> Default (Best Audio) selected." -ForegroundColor DarkGray
    } else {
        $selectedAudioID = $audioMap[[int]$aChoice]
        Write-Host ">> Selected Audio ID: $selectedAudioID" -ForegroundColor DarkGray
    }

    # --- 4. SUBTITLE SELECTION (AUTO + MANUAL) ---
    Write-Host "`n=== [ SUBTITLES ] ===" -ForegroundColor Green
    
    $subUrl = $null
    $embedSubs = $false
    
    # Check if there are internal subtitles in JSON
    if ($data.subtitles) {
        Write-Host "Found internal subtitles:" -ForegroundColor Yellow
        $data.subtitles | Get-Member -MemberType NoteProperty | ForEach-Object { Write-Host " - $($_.Name)" }
        Write-Host "`nDo you want to embed internal subtitles? (y/n): " -NoNewline -ForegroundColor Cyan
        $wantEmbed = Read-Host
        if ($wantEmbed -eq 'y') {
            $embedSubs = $true
            Write-Host ">> Internal subtitles will be embedded." -ForegroundColor DarkGray
        }
    } else {
        Write-Host "No internal subtitles found in manifest." -ForegroundColor DarkGray
    }

    if (-not $embedSubs) {
        Write-Host "Paste External VTT/SRT Link (or Press Enter to skip): " -NoNewline -ForegroundColor Cyan
        $subUrl = Read-Host
    }

    # --- 5. FILENAME ---
    $cleanTitle = $data.title -replace '[\\/*?:"<>|]', ''
    Write-Host "`n>> Filename? (Default: $cleanTitle)" -NoNewline -ForegroundColor Cyan
    $nameInput = Read-Host
    if ([string]::IsNullOrWhiteSpace($nameInput)) { $nameInput = $cleanTitle }

    # --- 6. DOWNLOAD EXECUTION ---
    Write-Host "`n=== STARTING DOWNLOAD ===`n" -ForegroundColor Yellow
    
    # Base arguments
    $finalArgs = @("--retries", "infinite", "--continue", "--merge-output-format", "mp4", "-f", "$selectedVideoID+$selectedAudioID", "$url", "-o", "$nameInput.%(ext)s")
    
    # Add embed subs argument if selected
    if ($embedSubs) {
        $finalArgs += "--embed-subs"
        $finalArgs += "--all-subs"
    }

    # Execute yt-dlp
    Start-Process -FilePath ".\yt-dlp.exe" -ArgumentList $finalArgs -Wait -NoNewWindow

    # Download External Subtitle if provided
    if (-not [string]::IsNullOrWhiteSpace($subUrl)) {
        Write-Host "`nDownloading external subtitle..."
        try {
            Invoke-WebRequest -Uri $subUrl -OutFile "$nameInput.srt"
            Write-Host "Subtitle saved: $nameInput.srt" -ForegroundColor Green
        } catch {
            Write-Host "Failed to download subtitle." -ForegroundColor Red
        }
    }

    Write-Host "`nOperation Complete!" -ForegroundColor Green
}

# Run Main Function
Main
