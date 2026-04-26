param(
    [Parameter(Mandatory=$true)][string]$Phase,
    [string[]]$Files,
    [int]$Seconds = 60,
    [int]$IntervalSec = 5
)

$forensikDir = "C:\Users\deniz\Documents\miraculix\_claude\scripts\forensik-2026-04-26"
$logFile = "$forensikDir\03-$Phase-watch.log"

# Initial Hashes erfassen
$baseline = @{}
foreach ($f in $Files) {
    if (Test-Path $f) {
        $hash = (Get-FileHash $f -Algorithm SHA256).Hash
        $mtime = (Get-Item $f).LastWriteTime
        $size = (Get-Item $f).Length
        $baseline[$f] = @{ Hash = $hash; Mtime = $mtime; Size = $size }
    }
}

"=== $Phase started $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') for $Seconds sec, interval $IntervalSec sec ===" | Out-File $logFile -Encoding utf8 -Force
"Watching $($Files.Count) files:" | Add-Content $logFile
foreach ($f in $Files) {
    $b = $baseline[$f]
    "  $f -> hash=$($b.Hash.Substring(0,16))... mtime=$($b.Mtime) size=$($b.Size)" | Add-Content $logFile
}

$endTime = (Get-Date).AddSeconds($Seconds)
$totalChanges = 0

while ((Get-Date) -lt $endTime) {
    Start-Sleep -Seconds $IntervalSec
    $now = Get-Date -Format 'HH:mm:ss'
    $changesThisCheck = 0
    foreach ($f in $Files) {
        if (-not (Test-Path $f)) {
            "$now - $f - DISAPPEARED" | Add-Content $logFile
            $changesThisCheck++
            continue
        }
        $hash = (Get-FileHash $f -Algorithm SHA256).Hash
        if ($hash -ne $baseline[$f].Hash) {
            $totalChanges++
            $changesThisCheck++
            $name = Split-Path $f -Leaf
            $current = Get-Item $f
            "$now - CHANGED: $name new-hash=$($hash.Substring(0,16))... mtime=$($current.LastWriteTime) size=$($current.Length)" | Add-Content $logFile
            # Snapshot
            $safeNow = $now.Replace(':', '_')
            $copyPath = "$forensikDir\test-files\snapshot-$Phase-$($name)-$safeNow"
            Copy-Item $f $copyPath -Force
            # Update baseline so we catch further changes
            $baseline[$f].Hash = $hash
        }
    }
    if ($changesThisCheck -eq 0) {
        "$now - all unchanged" | Add-Content $logFile
    }
}

"$(Get-Date -Format 'HH:mm:ss') - $Phase ENDED. Total changes: $totalChanges" | Add-Content $logFile
Write-Host "$Phase done. Changes: $totalChanges"
