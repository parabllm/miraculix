param(
    [Parameter(Mandatory=$true)][string]$Label,
    [string]$TestFile = "C:\Users\deniz\Documents\miraculix\_claude\scripts\forensik-2026-04-26\test-files\test-watchdog-T0.md"
)

$forensikDir = "C:\Users\deniz\Documents\miraculix\_claude\scripts\forensik-2026-04-26"
$baselineFile = "$forensikDir\test-files\test-watchdog-T0-baseline.md"

$current = Get-Item $TestFile -ErrorAction SilentlyContinue
if (-not $current) {
    Write-Host "FILE NOT FOUND: $TestFile"
    return
}

$bytes = [System.IO.File]::ReadAllBytes($TestFile)
$baselineBytes = [System.IO.File]::ReadAllBytes($baselineFile)
$currentHash = (Get-FileHash $TestFile -Algorithm SHA256).Hash
$baselineHash = (Get-FileHash $baselineFile -Algorithm SHA256).Hash

Write-Host "=== $Label ==="
Write-Host "mtime:  $($current.LastWriteTime)"
Write-Host "size:   $($bytes.Length) bytes (baseline: $($baselineBytes.Length))"
Write-Host "SHA256: $currentHash"
Write-Host "match baseline: $($currentHash -eq $baselineHash)"
Write-Host ""

if ($currentHash -ne $baselineHash) {
    Write-Host "DIFFERS FROM BASELINE."
    Copy-Item $TestFile "$forensikDir\test-files\test-watchdog-$Label.md" -Force
    Write-Host "First 100 bytes (current):"
    $end = [math]::Min($bytes.Length, 100)
    ($bytes[0..($end-1)] | ForEach-Object { '{0:X2}' -f $_ }) -join ' '
    Write-Host ""
    Write-Host "First 100 bytes (baseline):"
    $end2 = [math]::Min($baselineBytes.Length, 100)
    ($baselineBytes[0..($end2-1)] | ForEach-Object { '{0:X2}' -f $_ }) -join ' '
} else {
    Write-Host "Identical to baseline."
}
