param(
    [string]$TestFile = "C:\Users\deniz\Documents\miraculix\_claude\scripts\forensik-2026-04-26\test-files\test-watchdog-T0.md",
    [string]$LogFile = "C:\Users\deniz\Documents\miraculix\_claude\scripts\forensik-2026-04-26\03-T1-watch.log",
    [int]$Minutes = 10
)

$forensikDir = Split-Path $LogFile -Parent
$baselineHash = (Get-FileHash $TestFile -Algorithm SHA256).Hash
$baselineMtime = (Get-Item $TestFile).LastWriteTime
$endTime = (Get-Date).AddMinutes($Minutes)
$changes = 0

"$(Get-Date -Format 'HH:mm:ss') - Watcher started. Baseline hash=$baselineHash mtime=$baselineMtime" | Add-Content $LogFile

while ((Get-Date) -lt $endTime) {
    Start-Sleep -Seconds 60
    $current = Get-Item $TestFile -ErrorAction SilentlyContinue
    if (-not $current) {
        "$(Get-Date -Format 'HH:mm:ss') - FILE DISAPPEARED" | Add-Content $LogFile
        $changes++
        break
    }
    $currentHash = (Get-FileHash $TestFile -Algorithm SHA256).Hash
    $now = Get-Date -Format 'HH:mm:ss'
    if ($currentHash -ne $baselineHash) {
        $changes++
        "$now - CHANGED: hash=$currentHash mtime=$($current.LastWriteTime)" | Add-Content $LogFile
        $safeName = $now.Replace(':', '_')
        Copy-Item $TestFile "$forensikDir\test-files\test-watchdog-T1-changed-$changes-$safeName.md" -Force
    } else {
        "$now - unchanged" | Add-Content $LogFile
    }
}

"$(Get-Date -Format 'HH:mm:ss') - T1 ENDED. Total changes: $changes" | Add-Content $LogFile
Write-Host "T1 done. Changes: $changes"
