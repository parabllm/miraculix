# bug-scanner-v3.ps1 - High-Confidence-Detector
# Nur eindeutige Korruptions-Patterns. Keine Heuristiken die viele False-Positives erzeugen.

param(
    [string]$VaultRoot = "C:\Users\deniz\Documents\miraculix",
    [string]$OutputDir = "C:\Users\deniz\Documents\miraculix\_claude\scripts\forensik-2026-04-26"
)

$exclude = @('\\\.git\\', '\\\.obsidian\\', '\\node_modules\\', '\\forensik-2026-04-26\\', '\\\.trash\\')
$excludeRegex = ($exclude -join '|')

$allFiles = @()
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

    # Frontmatter und Body trennen
    $frontmatter = ""
    $body = $content
    if ($content -match '^(?s)---\r?\n(.*?)\r?\n---\r?\n(.*)$') {
        $frontmatter = $matches[1]
        $body = $matches[2]
    }

    # === HIGH-CONFIDENCE Patterns ===

    # A: Frontmatter mit ## Prefix nach ---\n\n
    $A = [int]($content -match '^---\r?\n\r?\n##\s+\w+:')

    # C: Wikilink-Array kaputt (\[[name]]")
    $C = [int]($content -match '\\\[\[\[' -or $content -match '\[\[[\w\-]+\]\]"\\\]')

    # D: Backslash-Escapes auf [, ], ~ ohne legitimen Grund
    # Konservativ: zaehle nur \[ und \] und \~
    $D_brackets = ([regex]::Matches($content, '\\\[(?!\])')).Count + ([regex]::Matches($content, '(?<!\\)\\\](?!\()')).Count
    $D_tilde = ([regex]::Matches($content, '\\~')).Count

    # G: Auto-Link in Frontmatter-Wert  (mailto: oder https://)
    $G = 0
    if ($frontmatter.Length -gt 0) {
        $G = ([regex]::Matches($frontmatter, '\[[^\]]+\]\((?:mailto:|https?://)[^\)]+\)')).Count
    }

    # H: URL self-linked im Body  [http://x](http://x)
    $H = ([regex]::Matches($body, '\[((?:https?://|mailto:)[^\]]+)\]\(\1\)')).Count

    # I: Block-Quote kollabiert (sehr lange `> ` Zeile)
    $I = [int]($body -match '\n>\s+[^\n]{300,}\n')

    # E: Tabellen-Kollaps - nur sehr spezifisches Pattern
    # Erwartung: nach einer Section-Header eine Zeile mit Bezeichnungs-Sequenz statt Tabelle
    # Ein Block der wie "KanalWertEmail+853..." aussieht: Kanal-Header + Wert-Header + 1+ Datensatz ohne |
    $E = 0
    # Match: Wort startet mit Capital, gefolgt von Capital-Wort, mehrfach, ohne Trenner. Sehr lang.
    if ($body -match '\n([A-Z][a-zA-Z]{2,}){4,}[^\n]+\n') {
        $E = 1
    }

    # === Score-Berechnung ===
    # Severe = Strukturschaden: A, C, E, G > 0, H > 0, I
    $severe = ($A -eq 1) -or ($C -eq 1) -or ($E -eq 1) -or ($G -gt 0) -or ($H -gt 0) -or ($I -eq 1)
    # Moderate = nur escapes
    $moderate = -not $severe -and ($D_brackets -gt 0 -or $D_tilde -gt 0)

    if ($severe -or $moderate) {
        $allFiles += [PSCustomObject]@{
            pfad        = $rel
            A           = $A
            C           = $C
            D_brackets  = $D_brackets
            D_tilde     = $D_tilde
            E           = $E
            G_fm_link   = $G
            H_self_link = $H
            I_quote     = $I
            severity    = if ($severe) { "SEVERE" } else { "moderate" }
            mtime       = $_.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
            size        = $bytes.Length
        }
    }
}

$allFiles | Export-Csv -Path "$OutputDir\02-bug-scan-final.csv" -NoTypeInformation -Encoding UTF8

$severe = $allFiles | Where-Object severity -eq "SEVERE"
$moderate = $allFiles | Where-Object severity -eq "moderate"

Write-Host "=== Final Scan ==="
Write-Host "Files gescannt:  $filesScanned"
Write-Host "SEVERE (Strukturschaden):  $($severe.Count)"
Write-Host "moderate (nur Escapes):    $($moderate.Count)"
Write-Host ""
Write-Host "Pro Pattern (in SEVERE):"
Write-Host "  A (Frontmatter ##):       $(($severe | Where-Object A -eq 1).Count)"
Write-Host "  C (Wikilink kaputt):      $(($severe | Where-Object C -eq 1).Count)"
Write-Host "  E (Tabelle kollabiert):   $(($severe | Where-Object E -eq 1).Count)"
Write-Host "  G (Auto-Link FM):         $(($severe | Where-Object {[int]$_.G_fm_link -gt 0}).Count)"
Write-Host "  H (Self-Link Body):       $(($severe | Where-Object {[int]$_.H_self_link -gt 0}).Count)"
Write-Host "  I (Quote kollabiert):     $(($severe | Where-Object I -eq 1).Count)"
Write-Host ""
Write-Host "=== ALLE SEVERE-FILES (sortiert nach mtime) ==="
$severe | Sort-Object mtime | Format-Table pfad, A, C, E, G_fm_link, H_self_link, I, mtime -AutoSize | Out-String -Width 240
Write-Host ""
Write-Host "=== Histogramm SEVERE nach Stunde ==="
$severe | Group-Object { $_.mtime.Substring(0,13) } | Sort-Object Name | Select-Object Count, Name | Format-Table -AutoSize
