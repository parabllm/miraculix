param(
    [Parameter(Mandatory=$true)][string]$Phase,
    [string]$TestFile = "C:\Users\deniz\Documents\miraculix\_claude\scripts\forensik-2026-04-26\test-files\test-watchdog-T0.md",
    [int]$Seconds = 60,
    [int]$IntervalSec = 10
)

$forensikDir = "C:\Users\deniz\Documents\miraculix\_claude\scripts\forensik-2026-04-26"
$logFile = "$forensikDir\03-$Phase-watch.log"

$baselineHash = (Get-FileHash $TestFile -Algorithm SHA256).Hash
$baselineMtime = (Get-Item $TestFile).LastWriteTime
$endTime = (Get-Date).AddSeconds($Seconds)
$changes = 0

"=== $Phase started $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') for $Seconds sec, interval $IntervalSec sec ===" | Out-File $logFile -Encoding utf8 -Force
"baseline_hash=$baselineHash" | Add-Content $logFile
"baseline_mtime=$baselineMtime" | Add-Content $logFile

while ((Get-Date) -lt $endTime) {
    Start-Sleep -Seconds $IntervalSec
    $current = Get-Item $TestFile -ErrorAction SilentlyContinue
    if (-not $current) {
        "$(Get-Date -Format 'HH:mm:ss') - FILE DISAPPEARED" | Add-Content $logFile
        break
    }
    $currentHash = (Get-FileHash $TestFile -Algorithm SHA256).Hash
    $now = Get-Date -Format 'HH:mm:ss'
    if ($currentHash -ne $baselineHash) {
        $changes++
        "$now - CHANGED hash=$currentHash mtime=$($current.LastWriteTime) size=$($current.Length)" | Add-Content $logFile
        $safeName = $now.Replace(':', '_')
        Copy-Item $TestFile "$forensikDir\test-files\test-watchdog-$Phase-changed-$changes-$safeName.md" -Force
        $baselineHash = $currentHash
    } else {
        "$now - unchanged" | Add-Content $logFile
    }
}

"$(Get-Date -Format 'HH:mm:ss') - $Phase ENDED. Total changes: $changes" | Add-Content $logFile
Write-Host "$Phase done. Changes: $changes"
