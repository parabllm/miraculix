# 09-repair-batch3.ps1 - Algo-Repair fuer 3 Files ohne git-history
# zy-peptides, clickup-pulse-entwurf, meeting-2026-04-26-weekly
#
# Strategy: parse flat-FM after `---\n\n## `, reconstruct as proper multi-line YAML

param([switch]$Apply = $false)

$VaultRoot = "C:\Users\deniz\Documents\miraculix"

function Repair-FrontmatterValue {
    param([string]$value)
    $v = $value
    $v = [regex]::Replace($v, '\[([^\]]+)\]\((?:mailto:|https?://)[^\)]+\)', '$1')
    $v = $v -replace '\\\[', '['
    $v = $v -replace '\\\]', ']'
    $v = $v -replace '\\~', '~'
    $v = $v -replace '\\\{', '{'
    $v = $v -replace '\\\}', '}'
    $v = $v -replace '\\\*', '*'
    $v = $v -replace '\\_', '_'
    return $v.Trim()
}

function Parse-FlatFrontmatter {
    param([string]$flatLine)
    # Tokenize: split at "key: " boundaries
    # A key starts with a word boundary, followed by \w+: (no preceeding char)
    $cleaned = Repair-FrontmatterValue $flatLine
    $cleaned = $cleaned.Trim()

    # Split using regex lookahead: split before "(?=\b\w+:\s)"
    # But careful: don't split inside quoted strings
    # Simpler: find all key positions, then extract substrings

    # Find all key-positions: (?<=^|\s)\w+:\s with the position
    $keyMatches = [regex]::Matches($cleaned, '(?<=^|\s)([a-zA-Z_]\w*):\s')
    $result = [ordered]@{}
    for ($i = 0; $i -lt $keyMatches.Count; $i++) {
        $key = $keyMatches[$i].Groups[1].Value
        $valStart = $keyMatches[$i].Index + $keyMatches[$i].Length
        $valEnd = if ($i + 1 -lt $keyMatches.Count) { $keyMatches[$i+1].Index } else { $cleaned.Length }
        $val = $cleaned.Substring($valStart, $valEnd - $valStart).Trim()
        $result[$key] = $val
    }
    return $result
}

function Format-YamlValue {
    param([string]$value)
    $v = $value.Trim()
    if ($v -eq '""' -or $v -eq "''" -or $v.Length -eq 0) {
        return '""'
    }
    # Broken Wikilink-Array fix: starts with [[name]]" -> add [" prefix
    # Korruptions-Fall: `\[[name]]", "..."` wurde zu `[[name]]", "..."` ohne Schluss-Quote vorne
    if ($v -match '^\[\[[\w\-]+\]\]"\s*,') {
        $v = '["[[' + $v.Substring(2)
    }
    # Wikilink-Array (mit oder ohne quotes): keep wie ist
    if ($v -match '^\[.*\]$') { return $v }
    # Quoted string: keep
    if ($v -match '^".*"$' -or $v -match "^'.*'$") { return $v }
    # Date / boolean / plain enum
    if ($v -match '^\d{4}-\d{2}-\d{2}$') { return $v }
    if ($v -match '^(true|false|null)$') { return $v }
    if ($v -match '^[a-zA-Z0-9_\-]+$') { return $v }
    # Else: quote
    $v = $v -replace '"', '\"'
    return "`"$v`""
}

function Format-Yaml {
    param($dict)
    $lines = @()
    foreach ($key in $dict.Keys) {
        $val = Format-YamlValue $dict[$key]
        $lines += "${key}: $val"
    }
    return ($lines -join "`r`n")
}

function Repair-File {
    param([string]$rel)
    $full = Join-Path $VaultRoot $rel
    Write-Host "=== $rel ===" -ForegroundColor Cyan
    $bytes = [System.IO.File]::ReadAllBytes($full)
    $offset = 0
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        $offset = 3
    }
    $content = [System.Text.Encoding]::UTF8.GetString($bytes, $offset, $bytes.Length - $offset)

    # Pattern A: ---\r?\n\r?\n## key: value... [bis Newline]
    $patternA = [regex]::Match($content, '^---\r?\n\r?\n##\s+([^\n]+)\r?\n([\s\S]*)$')
    if (-not $patternA.Success) {
        Write-Host "  Pattern A nicht erkannt!" -ForegroundColor Red
        return $false
    }

    $flatLine = $patternA.Groups[1].Value
    $rest = $patternA.Groups[2].Value

    $dict = Parse-FlatFrontmatter $flatLine
    Write-Host "  Parsed $($dict.Count) keys: $($dict.Keys -join ', ')"

    $newFmContent = Format-Yaml $dict

    # Body: Skip leading empty lines and any leading `---` orphan close
    $body = $rest
    $body = $body -replace '^(?:\s*\r?\n)*', ''
    # Falls erste Zeile `---` (orphan close), entfernen plus folgende Leerzeile
    if ($body -match '^---\r?\n(\r?\n)?') {
        $body = $body -replace '^---\r?\n(\r?\n)?', ''
    }

    $newContent = "---`r`n$newFmContent`r`n---`r`n`r`n$body"

    Write-Host "  Old size: $($bytes.Length), new size: $($newContent.Length)"

    if ($Apply) {
        $newBytes = [System.Text.UTF8Encoding]::new($false).GetBytes($newContent)
        [System.IO.File]::WriteAllBytes($full, $newBytes)

        # Hex-Verify
        $verifyBytes = [System.IO.File]::ReadAllBytes($full)
        $first8 = ($verifyBytes[0..7] | ForEach-Object { '{0:X2}' -f $_ }) -join ' '
        $isPatternA = ($first8 -eq '2D 2D 2D 0A 0A 23 23 20') -or ($first8 -eq '2D 2D 2D 0D 0A 0D 0A 23')
        if ($isPatternA) {
            Write-Host "  ERROR: Pattern A still present after write" -ForegroundColor Red
            return $false
        }
        Write-Host "  OK: written, first 8 hex: $first8" -ForegroundColor Green
        return $true
    } else {
        Write-Host "  DRY-RUN. New first 8 hex would be: 2D 2D 2D 0D 0A ..."
        Write-Host "  --- Reconstructed FM ---"
        Write-Host $newFmContent
        Write-Host "  ---"
        return $true
    }
}

$files = @(
    "01-projekte\pulsepeptides\knowledge-base\zy-peptides.md",
    "01-projekte\pulsepeptides\clickup-pulse-entwurf.md",
    "01-projekte\coralate\cora-ai\meeting-2026-04-26-weekly.md"
)

foreach ($f in $files) {
    Repair-File $f
    Write-Host ""
}

Write-Host "=== Run done. Apply=$Apply ==="
