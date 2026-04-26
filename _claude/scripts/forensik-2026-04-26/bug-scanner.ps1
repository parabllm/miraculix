# bug-scanner.ps1
# Scannt alle .md Files im Vault auf Korruptions-Patterns A-F.
# Output: CSV plus Zusammenfassung als Markdown.

param(
    [string]$VaultRoot = "C:\Users\deniz\Documents\miraculix",
    [string]$OutputDir = "C:\Users\deniz\Documents\miraculix\_claude\scripts\forensik-2026-04-26"
)

$exclude = @('\.git\\', '\\\.obsidian\\', '\\node_modules\\', '\\forensik-2026-04-26\\', '\\\.trash\\')
$excludeRegex = ($exclude -join '|')

$results = @()
$filesScanned = 0

Get-ChildItem -Path $VaultRoot -Recurse -File -Filter "*.md" -ErrorAction SilentlyContinue | Where-Object {
    $_.FullName -notmatch $excludeRegex
} | ForEach-Object {
    $filesScanned++
    $rel = $_.FullName.Replace("$VaultRoot\", "")
    $bytes = $null
    try {
        $bytes = [System.IO.File]::ReadAllBytes($_.FullName)
    } catch {
        $results += [PSCustomObject]@{
            pfad             = $rel
            pattern_a        = "ERR_LOCKED"
            pattern_b        = "ERR_LOCKED"
            pattern_c_wikilink = "ERR_LOCKED"
            pattern_d_escapes  = "ERR_LOCKED"
            pattern_e_tabellen = "ERR_LOCKED"
            pattern_f_eol_lf   = "ERR_LOCKED"
            file_size_bytes  = 0
            last_modified    = $_.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
            err              = $_.Exception.Message
        }
        return
    }

    if ($bytes.Length -eq 0) { return }

    # Check for UTF-8 BOM, skip if present
    $offset = 0
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        $offset = 3
    }

    $content = [System.Text.Encoding]::UTF8.GetString($bytes, $offset, $bytes.Length - $offset)

    # Pattern A: Frontmatter zu einer Zeile mit ## Prefix
    # ---\n\n## key: value ... (KEIN schliessendes ---)
    $patternA = $false
    if ($content -match '^---\r?\n\r?\n##\s+\w+:') {
        $patternA = $true
    }

    # Pattern B: Frontmatter zu einer Zeile OHNE ##, aber mit schliessendem ---
    # ---\n\nkey: value key: value ... \n\n---
    $patternB = $false
    if (-not $patternA -and $content -match '^---\r?\n\r?\n\w+:\s+[^\n]{200,}\r?\n') {
        # Header line ist verdaechtig lang ohne Newlines
        $patternB = $true
    }

    # Pattern C: Wikilink-Array kaputt
    # Korrekt: ["[[xy]]", "[[zz]]"]
    # Kaputt: \[[xy]]" oder [[xy]]"\] oder [[xy]]"\]
    $patternC = $false
    if ($content -match '\\\[\[\[' -or $content -match '\]\]"\\\]' -or $content -match '\[\[[\w\-]+\]\]"\\\]') {
        $patternC = $true
    }

    # Pattern D: Markdown-Escapes wo keine sein sollten
    # \[, \], \~, \{, \}, \*, \_
    $patternD = 0
    foreach ($pat in @('\\\[', '\\\]', '\\~', '\\\{', '\\\}', '\\\*(?!\*)', '\\_')) {
        $matches = [regex]::Matches($content, $pat)
        $patternD += $matches.Count
    }

    # Pattern E: Pipe-Tabellen kollabiert
    # Korrekt: | A | B |\n| - | - |
    # Kaputt: |X|Y|Z| zu eine Zeile ohne Newlines, oder gar keine | mehr (geslostes Tabellen-Gefuege)
    # Hinweis: typisches Muster nach Korruption ist 4-stelliger Wert + Wert + Wert ohne Trenner
    # Heuristik: Suche nach KapitalbuchstabenSequenz + KapitalbuchstabenSequenz die wie kollabierte Tabelle aussehen
    $patternE = $false
    # Sehr lange Zeile in der ueblicherweise eine Tabelle waere (in Body, nicht Frontmatter)
    if ($content -match '\n[A-Z][a-z]+[A-Z][a-z]+[A-Z][a-z]+[A-Za-z]{20,}\n') {
        $patternE = $true
    }
    # Auch: Block der mit Pipe begann aber keine Newlines mehr hat
    # Konservativer: zaehle Pipes pro Zeile in Body

    # Pattern F: nur LF (kein CRLF)
    $patternF = $false
    if ($bytes.Length -gt 50) {
        $hasCrlf = $content -match "\r\n"
        $hasLf = $content -match "\n"
        $patternF = ($hasLf -and -not $hasCrlf)
    }

    $hasAnyBug = $patternA -or $patternB -or $patternC -or ($patternD -gt 0) -or $patternE

    if ($hasAnyBug -or $patternF) {
        $results += [PSCustomObject]@{
            pfad               = $rel
            pattern_a          = if ($patternA) { 1 } else { 0 }
            pattern_b          = if ($patternB) { 1 } else { 0 }
            pattern_c_wikilink = if ($patternC) { 1 } else { 0 }
            pattern_d_escapes  = $patternD
            pattern_e_tabellen = if ($patternE) { 1 } else { 0 }
            pattern_f_eol_lf   = if ($patternF) { 1 } else { 0 }
            file_size_bytes    = $bytes.Length
            last_modified      = $_.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
        }
    }
}

$results | Export-Csv -Path "$OutputDir\02-bug-scan.csv" -NoTypeInformation -Encoding UTF8

Write-Host "=== Scan abgeschlossen ==="
Write-Host "Files gescannt:    $filesScanned"
Write-Host "Files mit Bugs:    $($results.Count)"
Write-Host "Pattern A (Front-Header): $(($results | Where-Object pattern_a -eq 1).Count)"
Write-Host "Pattern B (Front-flat):   $(($results | Where-Object pattern_b -eq 1).Count)"
Write-Host "Pattern C (Wikilink):     $(($results | Where-Object pattern_c_wikilink -eq 1).Count)"
Write-Host "Pattern D (Escapes):      $(($results | Where-Object pattern_d_escapes -gt 0).Count)"
Write-Host "Pattern E (Tabellen):     $(($results | Where-Object pattern_e_tabellen -eq 1).Count)"
Write-Host "Pattern F (LF-only):      $(($results | Where-Object pattern_f_eol_lf -eq 1).Count)"
Write-Host ""
Write-Host "=== Top 10 schlimmste Files (Pattern D Score) ==="
$results | Sort-Object @{Expression={[int]$_.pattern_a + [int]$_.pattern_b + [int]$_.pattern_c_wikilink + [int]$_.pattern_d_escapes + [int]$_.pattern_e_tabellen}; Descending=$true} | Select-Object -First 10 | Format-Table pfad, pattern_a, pattern_b, pattern_c_wikilink, pattern_d_escapes, pattern_e_tabellen, last_modified -AutoSize | Out-String -Width 280
