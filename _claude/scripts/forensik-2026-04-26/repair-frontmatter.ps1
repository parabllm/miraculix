# repair-frontmatter.ps1
# Repariert Files mit Pattern A (Frontmatter mit ## Prefix in einer Zeile)
# und Pattern G (Auto-Link in Frontmatter-Werten).
#
# Strategie:
# 1. Erkenne Pattern A: ---\n\n## key: value key: value... (kein schliessendes ---)
# 2. Tokenize Frontmatter-Felder via Key-Pattern \w+:
# 3. Repariere Werte:
#    - Backslash-Escapes \[ \] \~ \{ \} \* \_ entfernen
#    - Wikilink-Arrays normalisieren: [[name]] und [[name]]"\] zu ["[[name]]"]
#    - Auto-Links [text](mailto:x) zu x
# 4. Schreibe sauberes Multi-Line-YAML mit UTF-8 ohne BOM, CRLF
# 5. Hex-Verify nach Write
#
# WICHTIG: Skript ist DRY-RUN by default. Mit -Apply um zu schreiben.

param(
    [switch]$Apply = $false,
    [string]$VaultRoot = "C:\Users\deniz\Documents\miraculix"
)

$forensikDir = "$VaultRoot\_claude\scripts\forensik-2026-04-26"
$backupDir = "$forensikDir\05-pre-repair-backups"
$logFile = "$forensikDir\05-repair.log"

if ($Apply -and -not (Test-Path $backupDir)) {
    New-Item -ItemType Directory $backupDir -Force | Out-Null
}

$severeFiles = @(
    "03-kontakte\christian-pulse.md",
    "03-kontakte\kai-pulse.md",
    "03-kontakte\german-pulse.md",
    "03-kontakte\patrick-pulse.md",
    "03-kontakte\lizzi-pulse.md",
    "01-projekte\pulsepeptides\knowledge-base\zy-peptides.md",
    "01-projekte\pulsepeptides\knowledge-base\lab-peptides.md",
    "01-projekte\pulsepeptides\pulsepeptides.md",
    "01-projekte\pulsepeptides\knowledge-base\bestellprozess.md",
    "01-projekte\pulsepeptides\clickup-pulse-entwurf.md"
)

function Repair-FrontmatterValue {
    param([string]$value)
    $v = $value
    # Auto-Link entfernen: [text](mailto:..) oder [text](http..)
    $v = [regex]::Replace($v, '\[([^\]]+)\]\((?:mailto:|https?://)[^\)]+\)', '$1')
    # Backslash-Escapes raus
    $v = $v -replace '\\\[', '['
    $v = $v -replace '\\\]', ']'
    $v = $v -replace '\\~', '~'
    $v = $v -replace '\\\{', '{'
    $v = $v -replace '\\\}', '}'
    $v = $v -replace '\\\*', '*'
    $v = $v -replace '\\_', '_'
    return $v.Trim()
}

function Parse-PatternA-Frontmatter {
    param([string]$singleLine)
    # Input: 'typ: kontakt name: "Christian" aliase: \["Christian", "Christian Pulse"\] gruppen: \["pulsepeptides"\] ...'
    # Output: Hashtable mit key -> value (alles als Strings, multi-line via newline ggf.)

    # De-escape erstmal global
    $cleaned = Repair-FrontmatterValue $singleLine

    # Tokenize via lookahead auf naechsten Key
    # Key-Pattern: \w+: an Wort-Grenze (nicht inside string)
    # Verwende: split bei Key-Boundary

    $result = [ordered]@{}
    $remaining = $cleaned

    # Schleife: finde naechsten "key:" - bis kein mehr da
    while ($remaining -match '^(\w+):\s*(.*?)(?=\s+\w+:\s|$)') {
        $key = $Matches[1]
        $value = $Matches[2].Trim()
        $result[$key] = $value
        # Skip the matched portion
        $matchEnd = $Matches[0].Length
        $remaining = $remaining.Substring($matchEnd).Trim()
    }

    return $result
}

function Format-MultilineYaml {
    param([System.Collections.IDictionary]$dict)
    $lines = @()
    foreach ($key in $dict.Keys) {
        $val = $dict[$key]
        # Wikilink-Array Spezialfall
        if ($val -match '^\[\[.*\]\]$') {
            # Einzelner Wikilink in Array
            $val = '"' + $val + '"'
            $lines += "$key`: [$val]"
        } elseif ($val -match '\[\[.*\]\]') {
            # Verschachtelte/multiple Wikilinks - heuristisch in Array
            # Konservativ: lass den User pruefen
            $lines += "$key`: $val"
        } elseif ($val -match '^[a-zA-Z0-9_\-]+$') {
            # Plain enum value
            $lines += "$key`: $val"
        } else {
            # Quoted string
            $val = $val -replace '"', '\"'
            $lines += "$key`: `"$val`""
        }
    }
    return $lines -join "`r`n"
}

# === Main Loop ===
"=== Repair Run $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') Apply=$Apply ===" | Out-File $logFile -Append -Encoding utf8

foreach ($rel in $severeFiles) {
    $full = Join-Path $VaultRoot $rel
    "Processing: $rel" | Add-Content $logFile

    if (-not (Test-Path $full)) {
        "  SKIP: file not found" | Add-Content $logFile
        continue
    }

    $bytes = [System.IO.File]::ReadAllBytes($full)
    $offset = 0
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        $offset = 3
    }
    $content = [System.Text.Encoding]::UTF8.GetString($bytes, $offset, $bytes.Length - $offset)

    # Pattern A erkennen: ---\n\n## key: value...
    if ($content -match '^---\r?\n\r?\n##\s+(.*)') {
        $headerLine = $Matches[1]
        # Body-Start finden: nach diesem Header ist erste Leerzeile
        $bodyMatch = [regex]::Match($content, '^---\r?\n\r?\n##\s+[^\n]*\n\r?\n(.*)$', [System.Text.RegularExpressions.RegexOptions]::Singleline)
        $body = if ($bodyMatch.Success) { $bodyMatch.Groups[1].Value } else { "" }

        # Frontmatter parsen
        $fmDict = Parse-PatternA-Frontmatter -singleLine $headerLine
        $fmLines = Format-MultilineYaml -dict $fmDict

        $newContent = "---`r`n$fmLines`r`n---`r`n`r`n$body"

        "  Pattern A detected. $($fmDict.Count) keys parsed." | Add-Content $logFile
        $fmDict.GetEnumerator() | ForEach-Object { "    $($_.Key) = $($_.Value)" | Add-Content $logFile }

        if ($Apply) {
            # Backup
            $backupRel = $rel -replace '\\', '_'
            Copy-Item $full "$backupDir\$backupRel" -Force

            # Write neue Version
            $newBytes = [System.Text.UTF8Encoding]::new($false).GetBytes($newContent)
            [System.IO.File]::WriteAllBytes($full, $newBytes)

            # Verify
            $verifyBytes = [System.IO.File]::ReadAllBytes($full)
            $verifyContent = [System.Text.Encoding]::UTF8.GetString($verifyBytes)
            if ($verifyContent -match '^---\r?\n\r?\n##\s+\w+:') {
                "  ERROR: Pattern A still present after write!" | Add-Content $logFile
            } else {
                "  OK: Pattern A removed. New size: $($verifyBytes.Length) bytes" | Add-Content $logFile
            }
        } else {
            "  DRY-RUN: would write $($newContent.Length) chars" | Add-Content $logFile
        }
    } elseif ($content -match '^---\r?\n([^-][\s\S]*?)\r?\n---\r?\n') {
        # Pattern G - Auto-Link in normaler Frontmatter
        $fmRaw = $Matches[1]
        $fmRepaired = Repair-FrontmatterValue $fmRaw
        if ($fmRepaired -ne $fmRaw) {
            "  Pattern G detected. Cleaning auto-links and escapes." | Add-Content $logFile
            $newContent = $content -replace [regex]::Escape($fmRaw), $fmRepaired

            if ($Apply) {
                $backupRel = $rel -replace '\\', '_'
                Copy-Item $full "$backupDir\$backupRel" -Force
                $newBytes = [System.Text.UTF8Encoding]::new($false).GetBytes($newContent)
                [System.IO.File]::WriteAllBytes($full, $newBytes)
                "  OK: Auto-links cleaned" | Add-Content $logFile
            } else {
                "  DRY-RUN: would clean auto-links" | Add-Content $logFile
            }
        } else {
            "  No Pattern G needed" | Add-Content $logFile
        }
    } else {
        "  No recognized pattern" | Add-Content $logFile
    }
}

"=== Run done $(Get-Date -Format 'HH:mm:ss') ===" | Add-Content $logFile
Write-Host "Repair-Run abgeschlossen. Log: $logFile"
