# Update Shows: edit shows.json and publish it to everyone's SceneBridge.
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
$Host.UI.RawUI.WindowTitle = 'SceneBridge - Update Shows'

function Say($text, $color = 'Gray') { Write-Host $text -ForegroundColor $color }

Say "Getting the latest shows list..." Cyan
git pull --quiet 2>$null

$file = Join-Path $PSScriptRoot 'shows.json'
while ($true) {
    Start-Process notepad.exe -ArgumentList "`"$file`""
    Say ""
    Say "shows.json is open in Notepad." White
    Say "Make your changes, SAVE the file (Ctrl+S), then come back here."
    Read-Host "Press Enter when you're done"
    try {
        $data = Get-Content $file -Raw -Encoding UTF8 | ConvertFrom-Json
        if (-not $data.shows) { throw 'The file has no "shows" list.' }
        break
    } catch {
        Say ""
        Say "There's a mistake in shows.json, so it wasn't published:" Red
        Say "  $($_.Exception.Message)" Red
        Say "Usually a missing comma, quote or bracket. It will reopen so you can fix it." Yellow
    }
}

$changes = git status --porcelain shows.json
if (-not $changes) {
    Say ""
    Say "No changes were saved, so nothing was published." Yellow
    Read-Host "Press Enter to close"
    exit
}

$names = ($data.shows | ForEach-Object { $_.title }) -join ', '
git add shows.json
git commit --quiet -m "Update shows: $names"
Say "Publishing..." Cyan
git push --quiet
if ($LASTEXITCODE -ne 0) {
    Say "Publishing failed. Check your internet connection, then run Update Shows again." Red
} else {
    Say ""
    Say "Done! Everyone's SceneBridge will show the update within about 5 minutes." Green
    Say "Shows in the list: $names" Gray
}
Read-Host "Press Enter to close"
