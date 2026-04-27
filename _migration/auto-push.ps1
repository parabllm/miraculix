# Miraculix Vault Auto-Push Script
# Runs daily via Windows Task Scheduler
# Commits all changes and pushes to GitHub
#
# Pre-Push Watchdog (seit 2026-04-26):
# Vor jedem Push laeuft vault-health-check.ps1 -Full -FailOnBugs.
# Bei Korruptions-Findings (Pattern A/C/G) wird der Push BLOCKIERT.
# Begruendung und Pattern-Quelle: 02-wissen/vault-schreibregeln.md

$VaultPath = "C:\Users\deniz\Documents\miraculix"
$LogPath = "$VaultPath\_migration\auto-push.log"
$WatchdogScript = "$VaultPath\_claude\scripts\vault-health-check.ps1"
$Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

Set-Location $VaultPath

# Check if there are changes
$Changes = git status --porcelain
if ([string]::IsNullOrWhiteSpace($Changes)) {
    Add-Content -Path $LogPath -Value "$Timestamp : No changes, nothing to push."
    exit 0
}

# === Pre-Push Watchdog ===
if (Test-Path $WatchdogScript) {
    & $WatchdogScript -Full -FailOnBugs > $null 2>&1
    $watchdogExit = $LASTEXITCODE
    if ($watchdogExit -ne 0) {
        Add-Content -Path $LogPath -Value "$Timestamp : BLOCKED by vault-health-check (SEVERE findings). Report in _claude/scripts/vault-health-reports/. Push uebersprungen."
        exit 0
    }
} else {
    Add-Content -Path $LogPath -Value "$Timestamp : WARN watchdog-Skript nicht gefunden ($WatchdogScript). Push laeuft ohne Pre-Check."
}

# File count for commit message
$FileCount = ($Changes | Measure-Object).Count
$CommitMsg = "auto-push $Timestamp ($FileCount files)"

# Commit + Push
try {
    git add -A 2>&1 | Out-Null
    git commit -m $CommitMsg 2>&1 | Out-Null
    git push origin main 2>&1 | Out-Null
    Add-Content -Path $LogPath -Value "$Timestamp : OK $FileCount files pushed"
} catch {
    $ErrMsg = $_.Exception.Message
    Add-Content -Path $LogPath -Value "$Timestamp : ERROR $ErrMsg"
}
