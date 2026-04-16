# Miraculix Vault Auto-Push Script
# Runs daily via Windows Task Scheduler
# Commits all changes and pushes to GitHub

$VaultPath = "C:\Users\deniz\Documents\miraculix"
$LogPath = "$VaultPath\_migration\auto-push.log"
$Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

Set-Location $VaultPath

# Check if there are changes
$Changes = git status --porcelain
if ([string]::IsNullOrWhiteSpace($Changes)) {
    Add-Content -Path $LogPath -Value "$Timestamp : No changes, nothing to push."
    exit 0
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
