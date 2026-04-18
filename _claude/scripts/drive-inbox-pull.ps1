# drive-inbox-pull.ps1
# Zieht alle Files aus Google Drive "Miraculix_Eingang" nach lokalem Vault,
# loescht sie auf Drive. Kein Sync, sondern Move.
#
# Aufruf: powershell -ExecutionPolicy Bypass -File drive-inbox-pull.ps1
# Wird vom Skill `drive-eingang-holen` getriggert.

$ErrorActionPreference = "Stop"

# --- rclone finden ---
$rclone = (Get-Command rclone -ErrorAction SilentlyContinue).Source
if (-not $rclone) {
    $wingetDir = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages"
    if (Test-Path $wingetDir) {
        $found = Get-ChildItem -Path $wingetDir -Filter "rclone.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($found) { $rclone = $found.FullName }
    }
}
if (-not $rclone) {
    Write-Error "rclone nicht gefunden. Install: winget install Rclone.Rclone"
    exit 1
}

# --- Pfade ---
$vaultRoot = "C:\Users\deniz\Documents\miraculix"
$inboxLocal = Join-Path $vaultRoot "00-eingang\unverarbeitet"
$originaleLocal = Join-Path $inboxLocal "_originale"

$remoteRoot = "gdrive:Miraculix_Eingang"
$remoteImages = "gdrive:Miraculix_Eingang/Images"

# --- Zielordner sicherstellen ---
foreach ($p in @($inboxLocal, $originaleLocal)) {
    if (-not (Test-Path $p)) {
        New-Item -ItemType Directory -Path $p -Force | Out-Null
    }
}

Write-Host "== Drive-Eingang holen ==" -ForegroundColor Cyan
Write-Host "rclone:  $rclone"
Write-Host "Ziel:    $inboxLocal"
Write-Host ""

# --- Top-Level Files movern (alles ausser Unterordnern) ---
Write-Host "== Top-Level Files von Drive nach Vault =="
& $rclone move $remoteRoot $inboxLocal --max-depth 1 --progress
if ($LASTEXITCODE -ne 0) {
    Write-Error "rclone move Top-Level fehlgeschlagen (Exit $LASTEXITCODE)"
    exit $LASTEXITCODE
}

# --- Images movern ---
Write-Host ""
Write-Host "== Images von Drive nach Vault/_originale =="
& $rclone move $remoteImages $originaleLocal --progress
if ($LASTEXITCODE -ne 0) {
    Write-Error "rclone move Images fehlgeschlagen (Exit $LASTEXITCODE)"
    exit $LASTEXITCODE
}

# --- Zusammenfassung ---
Write-Host ""
Write-Host "== Zusammenfassung ==" -ForegroundColor Cyan

Write-Host "`nDrive-Seite (sollte leer sein, nur Images-Ordner bleibt):"
& $rclone lsd $remoteRoot
& $rclone ls $remoteRoot --max-depth 1

Write-Host "`nLokal in 00-eingang\unverarbeitet\:"
Get-ChildItem -Path $inboxLocal -File -ErrorAction SilentlyContinue | ForEach-Object {
    Write-Host "  $($_.Name)"
}

Write-Host "`nLokal in 00-eingang\unverarbeitet\_originale\:"
Get-ChildItem -Path $originaleLocal -File -ErrorAction SilentlyContinue | ForEach-Object {
    Write-Host "  $($_.Name)"
}

Write-Host ""
Write-Host "Fertig. Als naechstes: Trigger 'eingang verarbeiten' fuer den Digest-Skill." -ForegroundColor Green
