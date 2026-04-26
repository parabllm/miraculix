# bug-scanner-v2.ps1
# Erweitert: Pattern G (Auto-Link in Frontmatter), bessere Pattern E (kollabierte Tabellen)

param(
    [string]$VaultRoot = "C:\Users\deniz\Documents\miraculix",
    [string]$OutputDir = "C:\Users\deniz\Documents\miraculix\_claude\scripts\forensik-2026-04-26"
)

$exclude = @('\\\.git\\', '\\\.obsidian\\', '\\node_modules\\', '\\forensik-2026-04-26\\', '\\\.trash\\')
$excludeRegex = ($exclude -join '|')

$results = @()
$filesScanned = 0

Get-ChildItem -Path $VaultRoot -Recurse -File -Filter "*.md" -ErrorAction SilentlyContinue | Where-Object {
    $_.FullName -notmatch $excludeRegex
} | ForEach-Object {
    $filesScanned++
    $rel = $_.FullName.Replace("$VaultRoot\", "")
    try {
        $bytes = [System.IO.File]::ReadAllBytes($_.FullName)
    } catch {
        return
    }
    if ($bytes.Length -eq 0) { return }

    $offset = 0
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        $offset = 3
    }
    $content = [System.Text.Encoding]::UTF8.GetString($bytes, $offset, $bytes.Length - $offset)

    # Frontmatter extrahieren
    $frontmatter = ""
    $body = $content
    if ($content -match '^(?s)---\r?\n(.*?)\r?\n---\r?\n(.*)$') {
        $frontmatter = $matches[1]
        $body = $matches[2]
    } elseif ($content -match '^(?s)---\r?\n(.*?)\r?\n---\r?\n?$') {
        $frontmatter = $matches[1]
        $body = ""
    }

    # Pattern A: Frontmatter zerschlagen mit ## Prefix
    $patternA = ($content -match '^---\r?\n\r?\n##\s+\w+:')

    # Pattern B: Frontmatter zu einer Zeile (lange Zeile direkt nach ---)
    $patternB = $false
    if (-not $patternA -and $content -match '^---\r?\n\r?\n([^\n]{200,})\r?\n') {
        $line = $matches[1]
        if ($line -match '\w+:\s+\S+\s+\w+:\s+') {
            $patternB = $true
        }
    }

    # Pattern C: Wikilink-Array kaputt
    $patternC = ($content -match '\\\[\[\[' -or $content -match '\]\]"\\\]' -or $content -match '\[\[[\w\-]+\]\]"\\\]')

    # Pattern D: Markdown-Escapes (Body-relevant)
    $patternD = 0
    foreach ($pat in @('\\\[(?!\])', '\\\](?!\()', '\\~', '\\\{', '\\\}', '(?<!\*)\\\*(?!\*)', '\\_')) {
        $matches = [regex]::Matches($content, $pat)
        $patternD += $matches.Count
    }

    # Pattern E: Pipe-Tabellen kollabiert
    # Heuristik 1: Body hat woerter direkt aneinander wo eine Tabelle gewesen waere
    # z.B. "TestAnalyseHPLCReinheits-" - 3+ Capital-Camel-Worte in Folge ohne Trenner
    # Heuristik 2: Block-Header "Kontakt" gefolgt von "KanalWert" Zeile
    $patternE = $false
    # Suche kollabierte Tabelle: Plain-Text-Zeile die mit Spalten-Header beginnt
    $tableHeaders = @('Kanal', 'Wert', 'Test', 'Analyse', 'Spalte', 'Beschreibung', 'Link', 'URL', 'Datum', 'Stand', 'Status')
    foreach ($h in $tableHeaders) {
        if ($body -match "(?<![\|\s])$h(?:[A-Z][a-z]+){2,}") {
            $patternE = $true
            break
        }
    }
    # Hilfheuristik: 4+ Worte in Camel-Folge ohne Whitespace
    if (-not $patternE -and $body -match '[A-Z][a-z]+(?:[A-Z][a-z]+){4,}') {
        $patternE = $true
    }

    # Pattern F: nur LF
    $patternF = $false
    if ($bytes.Length -gt 50) {
        $hasCrlf = $content -match "\r\n"
        $hasLf = $content -match "\n"
        $patternF = ($hasLf -and -not $hasCrlf)
    }

    # Pattern G (NEU): Auto-Link in Frontmatter-Wert
    # email: "[lily@x.com](mailto:lily@x.com)"
    # url: "[https://...](https://...)"
    $patternG = 0
    if ($frontmatter) {
        $matches = [regex]::Matches($frontmatter, '\[[^\]]+\]\((?:mailto:|https?://)')
        $patternG = $matches.Count
    }

    # Pattern H (NEU): URL ungewollt auto-linked im Body
    # https://example.com -> [https://example.com](https://example.com)
    # Achtung: konservativ, nur das spezifische Pattern wo Link-Text == Link-Target ist
    $patternH = 0
    $matches = [regex]::Matches($body, '\[((?:https?://|mailto:)[^\]]+)\]\((\1)\)')
    $patternH = $matches.Count

    # Pattern I (NEU): Block-Quote auf einer Zeile mit "> Text Text Text..." sehr lang
    $patternI = $false
    if ($body -match '\n>\s+[^\n]{300,}\n') {
        $patternI = $true
    }

    $hasAnyBug = $patternA -or $patternB -or $patternC -or ($patternD -gt 0) -or $patternE -or ($patternG -gt 0) -or ($patternH -gt 0) -or $patternI

    if ($hasAnyBug -or $patternF) {
        $results += [PSCustomObject]@{
            pfad               = $rel
            A_front_hash       = if ($patternA) { 1 } else { 0 }
            B_front_flat       = if ($patternB) { 1 } else { 0 }
            C_wikilink         = if ($patternC) { 1 } else { 0 }
            D_escapes          = $patternD
            E_table_collapse   = if ($patternE) { 1 } else { 0 }
            F_lf_only          = if ($patternF) { 1 } else { 0 }
            G_fm_autolink      = $patternG
            H_body_autolink    = $patternH
            I_quote_collapse   = if ($patternI) { 1 } else { 0 }
            file_size_bytes    = $bytes.Length
            last_modified      = $_.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
        }
    }
}

$results | Export-Csv -Path "$OutputDir\02-bug-scan-v2.csv" -NoTypeInformation -Encoding UTF8

Write-Host "=== Scan v2 abgeschlossen ==="
Write-Host "Files gescannt:    $filesScanned"
Write-Host "Files mit Bugs:    $($results.Count)"
Write-Host "A (Frontmatter ## Prefix):     $(($results | Where-Object A_front_hash -eq 1).Count)"
Write-Host "B (Frontmatter flach):         $(($results | Where-Object B_front_flat -eq 1).Count)"
Write-Host "C (Wikilink-Array kaputt):     $(($results | Where-Object C_wikilink -eq 1).Count)"
Write-Host "D (Markdown-Escapes):          $(($results | Where-Object {[int]$_.D_escapes -gt 0}).Count) Files mit Score-Sum: $(($results | Measure-Object D_escapes -Sum).Sum)"
Write-Host "E (Tabellen kollabiert):       $(($results | Where-Object E_table_collapse -eq 1).Count)"
Write-Host "F (LF-only):                   $(($results | Where-Object F_lf_only -eq 1).Count)"
Write-Host "G (Auto-Link im Frontmatter):  $(($results | Where-Object {[int]$_.G_fm_autolink -gt 0}).Count)"
Write-Host "H (Auto-Link Body):            $(($results | Where-Object {[int]$_.H_body_autolink -gt 0}).Count)"
Write-Host "I (Quote kollabiert):          $(($results | Where-Object I_quote_collapse -eq 1).Count)"
Write-Host ""

# Korruptions-Schwere-Score: A,B,C,E,I sind Struktur-Schaeden, gewichten hoeher
$severe = $results | Where-Object {
    $_.A_front_hash -eq 1 -or $_.B_front_flat -eq 1 -or $_.C_wikilink -eq 1 -or
    $_.E_table_collapse -eq 1 -or [int]$_.G_fm_autolink -gt 0 -or [int]$_.H_body_autolink -gt 0 -or
    $_.I_quote_collapse -eq 1
}

Write-Host "=== KORRUMPIERTE FILES (Struktur-Schaden, $($severe.Count) Files) ==="
$severe | Sort-Object last_modified | Format-Table pfad, A_front_hash, C_wikilink, D_escapes, E_table_collapse, G_fm_autolink, H_body_autolink, I_quote_collapse, last_modified -AutoSize | Out-String -Width 280
