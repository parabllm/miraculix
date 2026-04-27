# 10-migrate-skill-fm.ps1 - Skill-Frontmatter auf Multi-Line-Block migrieren
#
# Pro Skill:
#   - Backup nach forensik-2026-04-26/05-pre-repair-backups/
#   - Hex-Pre-Check (saubere FM = `2D 2D 2D 0A 6E 61 6D 65`, Pattern A = `2D 2D 2D 0A 0A 23 23`)
#   - Falls Pattern A: Tokenizer-Reparatur, dann Multi-Line-Migration
#   - FM-Body-Boundary line-by-line (NICHT IndexOf, wegen Body-Tabellen ---|---|---|)
#   - description in pre-definierte Absaetze splitten
#   - WriteAllBytes UTF-8 NoBOM
#   - Hex-Post-Check + Body-Length-Diff
#
# Aufruf: . .\10-migrate-skill-fm.ps1 ; Migrate-Skill -Path "..." -DescParas @("...","...","...")

function Get-LinesFromBytes {
    param([byte[]]$bytes, [int]$offset = 0)
    # Returns @{ lines = [string[]]; lineStartByte = [int[]]; lineEndByte = [int[]] }
    # lineEndByte ist exklusiv (Position des \n bzw. EOF)
    $lines = New-Object System.Collections.ArrayList
    $starts = New-Object System.Collections.ArrayList
    $ends = New-Object System.Collections.ArrayList
    $pos = $offset
    $lineStart = $offset
    while ($pos -lt $bytes.Length) {
        if ($bytes[$pos] -eq 0x0A) {
            $lineEndByte = $pos
            $lineEndContent = $pos
            # Strip trailing CR if present
            if ($lineEndContent -gt $lineStart -and $bytes[$lineEndContent - 1] -eq 0x0D) {
                $lineEndContent = $lineEndContent - 1
            }
            $line = if ($lineEndContent -gt $lineStart) {
                [System.Text.Encoding]::UTF8.GetString($bytes, $lineStart, $lineEndContent - $lineStart)
            } else { "" }
            [void]$lines.Add($line)
            [void]$starts.Add($lineStart)
            [void]$ends.Add($pos + 1)  # inkl. \n
            $lineStart = $pos + 1
        }
        $pos++
    }
    if ($lineStart -lt $bytes.Length) {
        $line = [System.Text.Encoding]::UTF8.GetString($bytes, $lineStart, $bytes.Length - $lineStart)
        [void]$lines.Add($line)
        [void]$starts.Add($lineStart)
        [void]$ends.Add($bytes.Length)
    }
    return @{ lines = $lines.ToArray([string]); starts = $starts.ToArray([int]); ends = $ends.ToArray([int]) }
}

function Migrate-Skill {
    param(
        [string]$Path,
        [string[]]$DescParas,
        [string]$BackupDir = "C:\Users\deniz\Documents\miraculix\_claude\scripts\forensik-2026-04-26\05-pre-repair-backups",
        [switch]$DryRun
    )

    $name = [System.IO.Path]::GetFileNameWithoutExtension($Path)
    Write-Host ""
    Write-Host "=== Migrate: $name ===" -ForegroundColor Cyan

    if (-not (Test-Path $Path)) { Write-Host "  ERROR: File not found" -ForegroundColor Red; return }

    $backupPath = Join-Path $BackupDir "$name-pre-multilinefix.md"
    if (-not $DryRun) {
        Copy-Item -Path $Path -Destination $backupPath -Force
        Write-Host "  Backup: $backupPath"
    }

    $bytes = [System.IO.File]::ReadAllBytes($Path)
    $offset = 0
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        $offset = 3
    }
    $preHex = ($bytes[$offset..($offset+7)] | ForEach-Object { '{0:X2}' -f $_ }) -join ' '
    $isPatternA = $preHex.StartsWith('2D 2D 2D 0A 0A 23 23')
    $isClean    = $preHex.StartsWith('2D 2D 2D 0A 6E 61 6D 65') # ---\nname:
    Write-Host "  Pre-Hex (8B): $preHex"
    Write-Host "  Pre-Status:   $(if ($isPatternA) { 'PATTERN A KAPUTT' } elseif ($isClean) { 'SAUBER' } else { 'UNBEKANNT' })"

    # Lines parsen
    $linedata = Get-LinesFromBytes -bytes $bytes -offset $offset
    $lines = $linedata.lines
    $starts = $linedata.starts

    if ($isPatternA) {
        # Pattern A Reparatur: Erste Zeile ist `---`, zweite Zeile ist leer, dritte Zeile ist
        # `## name: X description: Y` (alles flach in einer Zeile, nach `## `)
        if ($lines.Length -lt 3 -or $lines[0] -ne '---' -or $lines[1] -ne '' -or -not $lines[2].StartsWith('## ')) {
            Write-Host "  ERROR: Pattern A erwartet aber Struktur unklar." -ForegroundColor Red
            return
        }
        # Tokenize flat-FM nach `## ` removen
        $flat = $lines[2].Substring(3)
        # Body-Bytes: alles ab Line 3 (4. Line)
        $bodyStartByte = if ($lines.Length -gt 3) { $starts[3] } else { $bytes.Length }
        $bodyBytes = if ($bodyStartByte -lt $bytes.Length) { $bytes[$bodyStartByte..($bytes.Length-1)] } else { @() }

        # Tokenize: split bei (?<=\s|^)(\w+):\s
        $kv = [ordered]@{}
        $matches = [regex]::Matches($flat, '(?<=^|\s)([a-zA-Z_][a-zA-Z0-9_]*):\s')
        for ($i = 0; $i -lt $matches.Count; $i++) {
            $key = $matches[$i].Groups[1].Value
            $vStart = $matches[$i].Index + $matches[$i].Length
            $vEnd = if ($i + 1 -lt $matches.Count) { $matches[$i+1].Index } else { $flat.Length }
            $val = $flat.Substring($vStart, $vEnd - $vStart).Trim()
            $kv[$key] = $val
        }
        Write-Host "  Pattern A repaired: $($kv.Count) keys: $($kv.Keys -join ', ')"

        # Falls description-Para nicht uebergeben, original aus kv nehmen (single-para fallback)
        if ($null -eq $DescParas -or $DescParas.Count -eq 0) {
            $DescParas = @($kv['description'])
        }
        $kv['description'] = '__BLOCK__'  # placeholder - wird gleich ersetzt

        $fmKeys = $kv
    } else {
        # Saubere FM: parse line-by-line bis zweites `---`
        if ($lines[0] -ne '---') {
            Write-Host "  ERROR: Erste Zeile ist nicht ---" -ForegroundColor Red; return
        }
        $fmCloseIdx = -1
        for ($i = 1; $i -lt $lines.Length; $i++) {
            if ($lines[$i] -eq '---') { $fmCloseIdx = $i; break }
        }
        if ($fmCloseIdx -eq -1) { Write-Host "  ERROR: Kein FM-Schluss gefunden" -ForegroundColor Red; return }

        # Body: alle Bytes ab Line ($fmCloseIdx + 1).start
        $bodyStartByte = if ($lines.Length -gt ($fmCloseIdx + 1)) { $starts[$fmCloseIdx + 1] } else { $bytes.Length }
        $bodyBytes = if ($bodyStartByte -lt $bytes.Length) { $bytes[$bodyStartByte..($bytes.Length-1)] } else { @() }

        # FM-Lines parsen (single-key:value pro Zeile)
        $fmKeys = [ordered]@{}
        $currentKey = $null
        for ($i = 1; $i -lt $fmCloseIdx; $i++) {
            $l = $lines[$i]
            if ($l -match '^([a-zA-Z_][a-zA-Z0-9_]*):\s*(.*)$') {
                $currentKey = $matches[1]
                $fmKeys[$currentKey] = $matches[2]
            } else {
                # Continuation-Line - sollte bei single-line FM nicht vorkommen
                if ($currentKey) {
                    $fmKeys[$currentKey] = ($fmKeys[$currentKey] + "`n" + $l)
                }
            }
        }
        Write-Host "  Sauber-FM parsed: $($fmKeys.Count) keys: $($fmKeys.Keys -join ', ')"

        # Falls description-Para nicht uebergeben, original aus fmKeys
        if ($null -eq $DescParas -or $DescParas.Count -eq 0) {
            $DescParas = @($fmKeys['description'])
        }
    }

    # === Build new FM ===
    $sb = New-Object System.Text.StringBuilder
    [void]$sb.Append("---`n")
    foreach ($k in $fmKeys.Keys) {
        if ($k -eq 'description') {
            [void]$sb.Append("description: |-`n")
            for ($i = 0; $i -lt $DescParas.Count; $i++) {
                $para = $DescParas[$i]
                # Splitte para falls embedded Newlines (wir wollen 2-Space pro Line)
                $paraLines = $para -split "`n"
                foreach ($pl in $paraLines) {
                    [void]$sb.Append("  ").Append($pl).Append("`n")
                }
                if ($i -lt $DescParas.Count - 1) {
                    [void]$sb.Append("  `n")  # Leerzeile zwischen Absaetzen (mit 2-Space Indent damit YAML-konform)
                }
            }
        } else {
            [void]$sb.Append("$($k): $($fmKeys[$k])`n")
        }
    }
    [void]$sb.Append("---`n")
    $newFmString = $sb.ToString()
    $newFmBytes = [System.Text.UTF8Encoding]::new($false).GetBytes($newFmString)

    # Reassemble: newFmBytes + bodyBytes
    $finalBytes = New-Object byte[] ($newFmBytes.Length + $bodyBytes.Length)
    [Array]::Copy($newFmBytes, 0, $finalBytes, 0, $newFmBytes.Length)
    if ($bodyBytes.Length -gt 0) {
        [Array]::Copy($bodyBytes, 0, $finalBytes, $newFmBytes.Length, $bodyBytes.Length)
    }

    if ($DryRun) {
        Write-Host "  DRY-RUN. New FM:"
        Write-Host $newFmString
        Write-Host "  Body bytes preserved: $($bodyBytes.Length)"
        return
    }

    [System.IO.File]::WriteAllBytes($Path, $finalBytes)

    # Post-Hex
    $verify = [System.IO.File]::ReadAllBytes($Path)
    $postHex = ($verify[0..7] | ForEach-Object { '{0:X2}' -f $_ }) -join ' '
    $postIsClean = $postHex.StartsWith('2D 2D 2D 0A 6E 61 6D 65')
    Write-Host "  Post-Hex (8B): $postHex"
    Write-Host "  Post-Status:   $(if ($postIsClean) { 'SAUBER' } else { 'NICHT SAUBER!' })"
    Write-Host "  Pre-Body-Bytes:  $($bodyBytes.Length)"
    Write-Host "  Post-Total-Size: $($verify.Length)"
    Write-Host "  Post-FM-Size:    $($newFmBytes.Length)"
    Write-Host "  Body-Length-Diff (post body bytes vs pre body bytes): $((($verify.Length - $newFmBytes.Length) - $bodyBytes.Length))"

    if (-not $postIsClean) {
        Write-Host "  CRITICAL: Post-Hex nicht sauber!" -ForegroundColor Red
    }
    if (($verify.Length - $newFmBytes.Length) -ne $bodyBytes.Length) {
        Write-Host "  CRITICAL: Body-Length-Diff != 0!" -ForegroundColor Red
    } else {
        Write-Host "  OK: Body 1:1 erhalten." -ForegroundColor Green
    }
    Write-Host "  Description-Absaetze: $($DescParas.Count)"
}
