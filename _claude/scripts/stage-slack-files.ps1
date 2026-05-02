$ErrorActionPreference = 'Stop'
$VaultRoot = 'C:\Users\deniz\Documents\miraculix'
$Git = 'C:\Program Files\Git\cmd\git.exe'

Set-Location -LiteralPath $VaultRoot

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$env:LC_ALL = 'C.UTF-8'

# Enumerate via wildcard - never type umlaut directly in path
$slackDirs = Get-ChildItem -Path "$VaultRoot\01-projekte\*\kommunikation-referenzen\slack" -Directory
foreach ($dir in $slackDirs) {
    $files = Get-ChildItem -LiteralPath $dir.FullName -Filter '*christian*.md' -File
    foreach ($f in $files) {
        $rel = $f.FullName.Substring($VaultRoot.Length + 1) -replace '\\', '/'
        Write-Host "Adding: $rel"
        & $Git add -- $rel
    }
}
