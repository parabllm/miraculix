$f = "C:\Users\deniz\Documents\miraculix\_claude\scripts\forensik-2026-04-26\test-self-write.md"
$bytes = [System.IO.File]::ReadAllBytes($f)

Write-Host "=== SELF-TEST RESULT: Claude-Code Write-Tool ==="
Write-Host "SIZE: $($bytes.Length) bytes"
Write-Host "MTIME: $((Get-Item $f).LastWriteTime)"
Write-Host ""

Write-Host "FIRST 60 BYTES (hex):"
($bytes[0..59] | ForEach-Object { '{0:X2}' -f $_ }) -join ' '
Write-Host ""

Write-Host "=== Pattern A check ==="
$first8Hex = ($bytes[0..7] | ForEach-Object { '{0:X2}' -f $_ }) -join ' '
$badPatternLF = "2D 2D 2D 0A 0A 23 23 20"
$badPatternCRLF = "2D 2D 2D 0D 0A 0D 0A 23"
if ($first8Hex -eq $badPatternLF -or $first8Hex -eq $badPatternCRLF) {
    Write-Host "BUG-PATTERN A DETECTED! Erste 8 Bytes: $first8Hex" -ForegroundColor Red
} else {
    Write-Host "OK: Kein Pattern A. Erste 8 Bytes: $first8Hex"
}
Write-Host ""

$content = [System.Text.Encoding]::UTF8.GetString($bytes)

Write-Host "=== Volltext-Pattern-Check ==="
$bracketEsc = ([regex]::Matches($content, '\\\[|\\\]')).Count
$tildeEsc = ([regex]::Matches($content, '\\~')).Count
$bsQuote = ([regex]::Matches($content, '\\"')).Count
Write-Host "  Backslash-Bracket-Escapes: $bracketEsc"
Write-Host "  Backslash-Tilde-Escapes:   $tildeEsc"
Write-Host "  Backslash-Quote (in body): $bsQuote (Hinweis: Eingabe enthielt eines literally)"
Write-Host ""

Write-Host "=== Tabellen-Check ==="
$tableLines = ($content -split "`n" | Where-Object { $_ -match '^\|' }).Count
Write-Host "  Pipe-Zeilen (Erwartet 3): $tableLines"
Write-Host ""

Write-Host "=== Auto-Link-Check ==="
$autoMail = ([regex]::Matches($content, '\[[^\]]*@[^\]]*\]\(mailto:')).Count
Write-Host "  Auto-mailto-Links (Erwartet 0): $autoMail"
$autoUrl = ([regex]::Matches($content, '\[https?://[^\]]+\]\(https?://')).Count
Write-Host "  Auto-URL-Links (Erwartet 0):    $autoUrl"
Write-Host ""

Write-Host "=== Frontmatter-Multiline-Check ==="
$fmMatch = [regex]::Match($content, '(?s)^---(.*?)---')
if ($fmMatch.Success) {
    $fmContent = $fmMatch.Groups[1].Value
    $fmLines = ($fmContent -split "`n" | Where-Object { $_.Trim() -ne "" }).Count
    Write-Host "  Frontmatter-Zeilen: $fmLines (Erwartet 7+)"
    if ($fmLines -ge 6) {
        Write-Host "  OK: Multi-Line erhalten"
    } else {
        Write-Host "  BUG: Multi-Line zu Einzelzeile geworden!"
    }
} else {
    Write-Host "  ERROR: Frontmatter konnte nicht extrahiert werden"
}
Write-Host ""

Write-Host "=== Block-Quote-Check ==="
$quoteLine = [regex]::Match($content, '\n>\s+([^\n]+)\n')
if ($quoteLine.Success) {
    Write-Host "  Quote: '$($quoteLine.Groups[1].Value)'"
    $hasTilde = $quoteLine.Groups[1].Value -match '~Tilde~'
    $hasBracket = $quoteLine.Groups[1].Value -match '\[Brackets\]'
    Write-Host "  ~Tilde~ erhalten: $hasTilde"
    Write-Host "  [Brackets] erhalten: $hasBracket"
}
Write-Host ""

Write-Host "=== Wikilink-Array-Check ==="
$fmWikiMatch = [regex]::Match($content, 'teilnehmer:\s*(\[[^\]]+\])')
if ($fmWikiMatch.Success) {
    Write-Host "  teilnehmer-Wert: $($fmWikiMatch.Groups[1].Value)"
    $expected = '["[[deniz]]", "[[test-person]]", "Externe Person"]'
    $actual = $fmWikiMatch.Groups[1].Value
    Write-Host "  Erwartet: $expected"
    Write-Host "  Match exakt: $($actual -eq $expected)"
}
Write-Host ""

Write-Host "=== EOL-Style ==="
$crlfCount = ([regex]::Matches($content, "`r`n")).Count
$lfOnlyCount = ([regex]::Matches($content, "(?<!`r)`n")).Count
Write-Host "  CRLF-Zeilen: $crlfCount"
Write-Host "  LF-only-Zeilen: $lfOnlyCount"
Write-Host ""

Write-Host "=== BOM-Check ==="
if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
    Write-Host "  HAS BOM (vermutlich nicht ideal, aber nicht der Bug)"
} else {
    Write-Host "  No BOM (gut)"
}
Write-Host ""

Write-Host "=== RAW VOLLTEXT (zur visuellen Pruefung) ==="
Write-Host "---START---"
$content
Write-Host "---END---"
