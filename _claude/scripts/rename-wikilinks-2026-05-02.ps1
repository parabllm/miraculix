$ErrorActionPreference = 'Stop'
$VaultRoot = 'C:\Users\deniz\Documents\miraculix'

$files = Get-ChildItem -Path $VaultRoot -Recurse -Include *.md -File |
    Where-Object {
        $_.FullName -notlike '*\.claude\worktrees\*' -and
        $_.FullName -notlike '*\.git\*' -and
        $_.FullName -notlike '*\.stversions\*' -and
        $_.FullName -notlike '*\05-archiv\*'
    }

$updated = @()
foreach ($f in $files) {
    $content = Get-Content -LiteralPath $f.FullName -Raw -Encoding UTF8
    $original = $content
    $content = $content -replace '\[\[christian-pulse\]\]', '[[christian-darmahkasih]]'
    $content = $content -replace '\[\[albin-pulse\]\]', '[[albin-shkreli]]'
    if ($content -ne $original) {
        # write back without BOM
        [System.IO.File]::WriteAllText($f.FullName, $content, (New-Object System.Text.UTF8Encoding($false)))
        $updated += $f.FullName
    }
}

Write-Host "Updated files: $($updated.Count)"
$updated | ForEach-Object { Write-Host "  $_" }
