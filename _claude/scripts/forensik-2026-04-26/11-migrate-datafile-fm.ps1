# 11-migrate-datafile-fm.ps1 - Daten-File-Frontmatter: lange Werte (>Threshold chars) auf Block-Syntax
#
# Pro File:
#   - Backup
#   - Hex-Pre-Check
#   - Line-by-line FM-Parsing (Body-Tabellen-safe)
#   - Pro Key mit Wert > Threshold: outer-Quote-Removal + Escape-Unescape + Block-Syntax
#   - WriteAllBytes UTF-8 NoBOM
#   - Hex-Post-Check + Body-Length-Diff
#
# Inhalt 1:1 erhalten (kein Sinn-Splitting wie bei Skills).

function Get-LinesFromBytesV2 {
    param([byte[]]$bytes, [int]$offset = 0)
    $lines = New-Object System.Collections.ArrayList
    $starts = New-Object System.Collections.ArrayList
    $pos = $offset
    $lineStart = $offset
    while ($pos -lt $bytes.Length) {
        if ($bytes[$pos] -eq 0x0A) {
            $lineEndContent = $pos
            if ($lineEndContent -gt $lineStart -and $bytes[$lineEndContent - 1] -eq 0x0D) {
                $lineEndContent = $lineEndContent - 1
            }
            $line = if ($lineEndContent -gt $lineStart) {
                [System.Text.Encoding]::UTF8.GetString($bytes, $lineStart, $lineEndContent - $lineStart)
            } else { "" }
            [void]$lines.Add($line)
            [void]$starts.Add($lineStart)
            $lineStart = $pos + 1
        }
        $pos++
    }
    if ($lineStart -lt $bytes.Length) {
        $line = [System.Text.Encoding]::UTF8.GetString($bytes, $lineStart, $bytes.Length - $lineStart)
        [void]$lines.Add($line)
        [void]$starts.Add($lineStart)
    }
    return @{ lines = $lines.ToArray([string]); starts = $starts.ToArray([int]) }
}

function Unwrap-YamlString {
    param([string]$value)
    # Outer-Quote-Entfernen wenn beidseitig "
    $v = $value
    if ($v.Length -ge 2 -and $v.StartsWith('"') -and $v.EndsWith('"')) {
        $v = $v.Substring(1, $v.Length - 2)
        # Unescape: \" -> ", \\ -> \, \n -> echtes Newline (selten in single-line FM)
        $v = $v -replace '\\"', '"'
        $v = $v -replace '\\\\', '\'
        return @{ value = $v; wasQuoted = $true }
    }
    if ($v.Length -ge 2 -and $v.StartsWith("'") -and $v.EndsWith("'")) {
        $v = $v.Substring(1, $v.Length - 2)
        $v = $v -replace "''", "'"
        return @{ value = $v; wasQuoted = $true }
    }
    return @{ value = $v; wasQuoted = $false }
}

function Migrate-DataFileFM {
    param(
        [string]$Path,
        [int]$Threshold = 200,
        [string]$BackupDir = "C:\Users\deniz\Documents\miraculix\_claude\scripts\forensik-2026-04-26\05-pre-repair-backups",
        [switch]$DryRun
    )

    $name = [System.IO.Path]::GetFileNameWithoutExtension($Path)
    $relName = (Resolve-Path $Path).Path.Replace("C:\Users\deniz\Documents\miraculix\", "").Replace("\", "__")
    Write-Host ""
    Write-Host "=== Migrate-DataFile: $relName ===" -ForegroundColor Cyan

    if (-not (Test-Path $Path)) { Write-Host "  ERROR: File not found" -ForegroundColor Red; return @{ ok = $false } }

    $backupPath = Join-Path $BackupDir "$relName-pre-datafilefix.md"
    if (-not $DryRun) {
        Copy-Item -Path $Path -Destination $backupPath -Force
    }

    $bytes = [System.IO.File]::ReadAllBytes($Path)
    $offset = 0
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) { $offset = 3 }
    $preHex = ($bytes[$offset..($offset+7)] | ForEach-Object { '{0:X2}' -f $_ }) -join ' '
    Write-Host "  Pre-Hex (8B): $preHex"
    if (-not $preHex.StartsWith('2D 2D 2D 0A')) {
        Write-Host "  WARN: File startet nicht mit `---\n` - skip" -ForegroundColor Yellow
        return @{ ok = $false }
    }

    $linedata = Get-LinesFromBytesV2 -bytes $bytes -offset $offset
    $lines = $linedata.lines
    $starts = $linedata.starts

    if ($lines.Length -lt 3 -or $lines[0] -ne '---') { Write-Host "  ERROR: kein FM-Open" -ForegroundColor Red; return @{ ok = $false } }
    $fmCloseIdx = -1
    for ($i = 1; $i -lt $lines.Length; $i++) {
        if ($lines[$i] -eq '---') { $fmCloseIdx = $i; break }
    }
    if ($fmCloseIdx -eq -1) { Write-Host "  ERROR: kein FM-Schluss" -ForegroundColor Red; return @{ ok = $false } }

    $bodyStartByte = if ($lines.Length -gt ($fmCloseIdx + 1)) { $starts[$fmCloseIdx + 1] } else { $bytes.Length }
    $bodyBytes = if ($bodyStartByte -lt $bytes.Length) { $bytes[$bodyStartByte..($bytes.Length-1)] } else { @() }

    # Build new FM line-by-line
    $newFmSb = New-Object System.Text.StringBuilder
    [void]$newFmSb.Append("---`n")
    $migratedKeys = @()
    for ($i = 1; $i -lt $fmCloseIdx; $i++) {
        $l = $lines[$i]
        if ($l -match '^([a-zA-Z_][a-zA-Z0-9_]*):\s+(.+)$') {
            $key = $matches[1]
            $val = $matches[2]
            $skipMigration = $false
            if ($val -eq '|-' -or $val -eq '|' -or $val -eq '>-' -or $val -eq '>') { $skipMigration = $true }
            if ($val.StartsWith('[') -or $val.StartsWith('{')) { $skipMigration = $true }
            if ($val -match '^\d{4}-\d{2}-\d{2}') { $skipMigration = $true }

            if (-not $skipMigration -and $val.Length -gt $Threshold) {
                $unwrap = Unwrap-YamlString -value $val
                $cleanVal = $unwrap.value
                [void]$newFmSb.Append("$($key): |-`n")
                # Single line in Block (kein Splitting)
                # Falls embedded \n: split und je 2-Space-prefix
                $blockLines = $cleanVal -split "`n"
                foreach ($bl in $blockLines) {
                    [void]$newFmSb.Append("  ").Append($bl).Append("`n")
                }
                $migratedKeys += "$key($($val.Length)$(if ($unwrap.wasQuoted) { ',quoted' } else { ',raw' }))"
            } else {
                # Unveraendert
                [void]$newFmSb.Append($l).Append("`n")
            }
        } else {
            # Continuation oder seltene Zeile - 1:1 erhalten
            [void]$newFmSb.Append($l).Append("`n")
        }
    }
    [void]$newFmSb.Append("---`n")

    $newFmString = $newFmSb.ToString()
    $newFmBytes = [System.Text.UTF8Encoding]::new($false).GetBytes($newFmString)

    if ($migratedKeys.Count -eq 0) {
        Write-Host "  Skip: kein Key > $Threshold chars" -ForegroundColor Yellow
        return @{ ok = $true; migrated = 0 }
    }

    Write-Host "  Migrated keys: $($migratedKeys -join ', ')"

    # Reassemble
    $finalBytes = New-Object byte[] ($newFmBytes.Length + $bodyBytes.Length)
    [Array]::Copy($newFmBytes, 0, $finalBytes, 0, $newFmBytes.Length)
    if ($bodyBytes.Length -gt 0) {
        [Array]::Copy($bodyBytes, 0, $finalBytes, $newFmBytes.Length, $bodyBytes.Length)
    }

    if ($DryRun) {
        Write-Host "  DRY-RUN. New FM:"
        Write-Host $newFmString
        Write-Host "  Body bytes preserved: $($bodyBytes.Length)"
        return @{ ok = $true; migrated = $migratedKeys.Count }
    }

    [System.IO.File]::WriteAllBytes($Path, $finalBytes)
    $verify = [System.IO.File]::ReadAllBytes($Path)
    $postHex = ($verify[0..7] | ForEach-Object { '{0:X2}' -f $_ }) -join ' '
    $postClean = $postHex.StartsWith('2D 2D 2D 0A')
    $bodyDiff = ($verify.Length - $newFmBytes.Length) - $bodyBytes.Length
    Write-Host "  Post-Hex (8B): $postHex"
    Write-Host "  Pre-Body-Bytes: $($bodyBytes.Length), Post-Body-Diff: $bodyDiff"
    if ($postClean -and $bodyDiff -eq 0) {
        Write-Host "  OK" -ForegroundColor Green
    } else {
        Write-Host "  CRITICAL: post-clean=$postClean, body-diff=$bodyDiff" -ForegroundColor Red
    }
    return @{ ok = ($postClean -and $bodyDiff -eq 0); migrated = $migratedKeys.Count; bodyDiff = $bodyDiff }
}
