# vault-health-check.ps1 - Watchdog fuer Vault-Frontmatter-Korruption
#
# Prueft alle .md-Files auf bekannte Korruptions-Patterns (A, C, G), leere Files,
# und kaputte Wikilinks. Kann manuell, via Skill-Trigger, oder pre-push aufgerufen werden.
#
# Master-Quelle Pattern-Definitionen: 02-wissen/vault-schreibregeln.md Sektion 3.2
# Forensik-Beweis Bug-Quelle: _claude/scripts/forensik-2026-04-26/REPORT.md
#
# Modi:
#   -Quick        : Nur Pattern A (erste 8 Bytes), schnellste Variante fuer Pre-Push
#   -Full         : Alle Patterns plus leere Files plus kaputte Wikilinks (Default)
#   -FailOnBugs   : Exit-Code 1 wenn Bugs gefunden (fuer Auto-Push-Integration)
#   -NoReport     : Kein Markdown-Report schreiben (nur Console)
#   -ReportDir    : Wo Markdown-Report landet (Default: _claude/scripts/vault-health-reports/)
#   -VaultRoot    : Vault-Wurzel (Default: aktuelles Verzeichnis oder Skript-Eltern)
#
# Exit-Codes:
#   0  alles sauber
#   1  Bugs gefunden (nur mit -FailOnBugs)
#   2  Skript-Fehler (Vault nicht gefunden, etc.)

param(
    [switch]$Quick,
    [switch]$Full,
    [switch]$FailOnBugs,
    [switch]$NoReport,
    [string]$ReportDir = "",
    [string]$VaultRoot = ""
)

# === Vault-Root bestimmen ===
if ([string]::IsNullOrWhiteSpace($VaultRoot)) {
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $VaultRoot = Split-Path -Parent (Split-Path -Parent $scriptDir)
}
if (-not (Test-Path $VaultRoot)) {
    Write-Host "ERROR: Vault-Root nicht gefunden: $VaultRoot" -ForegroundColor Red
    exit 2
}
$VaultRoot = (Resolve-Path $VaultRoot).Path

if ([string]::IsNullOrWhiteSpace($ReportDir)) {
    $ReportDir = Join-Path $VaultRoot "_claude\scripts\vault-health-reports"
}

# Default ist -Full wenn weder Quick noch Full angegeben
if (-not $Quick -and -not $Full) { $Full = $true }

# === Excludes (Verzeichnisse die nicht gescannt werden) ===
$excludes = @(
    '\\\.git\\',
    '\\\.obsidian\\',
    '\\node_modules\\',
    '\\\.claude\\worktrees\\',
    '\\\.trash\\',
    '\\_claude\\scripts\\forensik-2026-04-26\\',
    '\\_claude\\scripts\\vault-health-reports\\'
)
$excludeRegex = ($excludes -join '|')

# === Counter ===
$filesScanned = 0
$findings = @()

Write-Host "=== Vault-Health-Check ===" -ForegroundColor Cyan
Write-Host "Mode: $(if ($Quick) { 'QUICK' } else { 'FULL' })"
Write-Host "Vault: $VaultRoot"
Write-Host ""

$startTime = Get-Date

# === Scan ===
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

    if ($bytes.Length -eq 0) {
        # EMPTY_FILE ist strukturell verdaechtig aber keine Korruption.
        # Bleibt WARN damit Auto-Push nicht durch alte leere Stubs blockiert wird.
        $findings += [PSCustomObject]@{
            pfad     = $rel
            pattern  = 'EMPTY_FILE'
            severity = 'WARN'
            detail   = '0 Bytes'
            mtime    = $_.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
            size     = 0
        }
        return
    }

    # BOM-Offset
    $offset = 0
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        $offset = 3
    }

    # Erste 8 Bytes (nach BOM) als Hex
    $startBytes = if ($bytes.Length -ge ($offset + 8)) { $bytes[$offset..($offset+7)] } else { $bytes[$offset..($bytes.Length-1)] }
    $first8Hex = ($startBytes | ForEach-Object { '{0:X2}' -f $_ }) -join ' '

    # === PATTERN A + B Detection (beide Modi) ===
    # Saubere FM: 2D 2D 2D 0A <yaml-key>...    bzw  2D 2D 2D 0D 0A <yaml-key>...
    # Korruption: Empty-line nach FM-Open (---\n\n... bzw ---\r\n\r\n...)
    #   Pattern A: Empty-line gefolgt von Markdown-Heading (##) -> "FM zu Heading kollabiert"
    #   Pattern B: Empty-line gefolgt von beliebigem anderen Inhalt (z.B. flat-FM, normaler Text)
    # Beide werden in Quick UND Full erkannt damit Auto-Push-Pre-Check nichts durchlaesst.
    $startsEmptyLine_LF   = $first8Hex.StartsWith('2D 2D 2D 0A 0A')
    $startsEmptyLine_CRLF = $first8Hex.StartsWith('2D 2D 2D 0D 0A 0D 0A')

    # Pattern A LF: nach `---\n\n` kommen 2x `#` (Bytes 5+6). Zeichen danach egal (Space, Newline, Buchstabe).
    $patternA_LF = $startsEmptyLine_LF -and $first8Hex.StartsWith('2D 2D 2D 0A 0A 23 23')
    # Pattern A CRLF: nach `---\r\n\r\n` (7 Bytes) kommt `##` - bytes 7+8. First8Hex zeigt nur Byte 7.
    # Byte 7 muss `#` sein (= im first8Hex). Byte 8 (nicht in first8Hex) muss auch `#` sein.
    $patternA_CRLF = $false
    if ($startsEmptyLine_CRLF -and $first8Hex.StartsWith('2D 2D 2D 0D 0A 0D 0A 23')) {
        if ($bytes.Length -gt ($offset + 8) -and $bytes[$offset + 8] -eq 0x23) {
            $patternA_CRLF = $true
        }
    }

    if ($patternA_LF -or $patternA_CRLF) {
        $findings += [PSCustomObject]@{
            pfad     = $rel
            pattern  = 'A'
            severity = 'SEVERE'
            detail   = "First 8 hex: $first8Hex"
            mtime    = $_.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
            size     = $bytes.Length
        }
    }

    # Pattern B: empty-line-after-FM-open ohne ##-Heading-Pattern
    $patternBHit = $false
    $patternBDetail = ""
    $patternB_LF   = $startsEmptyLine_LF   -and -not $patternA_LF
    $patternB_CRLF = $startsEmptyLine_CRLF -and -not $patternA_CRLF
    if ($patternB_LF -or $patternB_CRLF) {
        $patternBHit = $true
        $patternBDetail = "Empty-line-after-FM-open: $first8Hex"
    }

    if ($patternBHit) {
        $findings += [PSCustomObject]@{
            pfad     = $rel
            pattern  = 'B'
            severity = 'SEVERE'
            detail   = $patternBDetail
            mtime    = $_.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
            size     = $bytes.Length
        }
    }

    # Im Quick-Modus aufhoeren - Pattern C/G/leer/Wikilinks brauchen volle Inhalts-Analyse
    if ($Quick) { return }

    # === FULL-MODE: zusaetzliche Patterns ===

    $content = [System.Text.Encoding]::UTF8.GetString($bytes, $offset, $bytes.Length - $offset)

    # Frontmatter und Body trennen
    # Edge-Case: Body-Markdown-Tabellen wie ---|---|---| nicht mit FM-Schluss verwechseln.
    # Stattdessen line-by-line: erste Zeile ist `---`, suche naechste Zeile die EXAKT `---` ist.
    $frontmatter = ""
    $body = $content
    $lines = $content -split "`r?`n"
    if ($lines.Length -gt 0 -and $lines[0] -eq '---') {
        for ($i = 1; $i -lt $lines.Length; $i++) {
            if ($lines[$i] -eq '---') {
                $frontmatter = ($lines[1..($i-1)] -join "`n")
                if ($i + 1 -lt $lines.Length) {
                    $body = ($lines[($i+1)..($lines.Length-1)] -join "`n")
                } else {
                    $body = ""
                }
                break
            }
        }
    }

    # === Squeezed-FM-Heuristik (Fallback fuer Mischformen die nicht durch Hex-Bytes
    # erkannt wurden, z.B. Pattern B mit Whitespace-Variationen) ===
    if (-not $patternBHit -and -not $patternA_LF -and -not $patternA_CRLF -and $frontmatter.Length -gt 0) {
        $fmLinestartKeys = ([regex]::Matches($frontmatter, '(?m)^[a-zA-Z_][a-zA-Z0-9_]*:\s')).Count
        $fmTotalKeyHits = ([regex]::Matches($frontmatter, '(?<=^|\s)[a-zA-Z_][a-zA-Z0-9_]{2,}:')).Count
        if ($fmLinestartKeys -le 1 -and $fmTotalKeyHits -ge 4) {
            $findings += [PSCustomObject]@{
                pfad     = $rel
                pattern  = 'B'
                severity = 'SEVERE'
                detail   = "Flat-FM-Heuristik: $fmLinestartKeys linestart-keys, $fmTotalKeyHits total-keys"
                mtime    = $_.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
                size     = $bytes.Length
            }
        }
    }

    # === PATTERN C: Wikilink-Array kaputt (\[[ oder ]"\] ===
    $patternC = ($content -match '\\\[\[\[' -or $content -match '\[\[[\w\-]+\]\]"\\\]')
    if ($patternC) {
        $findings += [PSCustomObject]@{
            pfad     = $rel
            pattern  = 'C'
            severity = 'SEVERE'
            detail   = 'Wikilink-Array mit Backslash-Escape oder unvollstaendigem Array-Schluss'
            mtime    = $_.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
            size     = $bytes.Length
        }
    }

    # === PATTERN G: Auto-Link in Frontmatter ===
    if ($frontmatter.Length -gt 0) {
        $patternGCount = ([regex]::Matches($frontmatter, '\[[^\]]+\]\((?:mailto:|https?://)[^\)]+\)')).Count
        if ($patternGCount -gt 0) {
            $findings += [PSCustomObject]@{
                pfad     = $rel
                pattern  = 'G'
                severity = 'SEVERE'
                detail   = "$patternGCount Auto-Link(s) in Frontmatter (mailto: oder URL)"
                mtime    = $_.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
                size     = $bytes.Length
            }
        }
    }

    # === LEERE FILES ===
    # Size < 50 Bytes ODER nur Frontmatter ohne Body
    if ($bytes.Length -lt 50) {
        $findings += [PSCustomObject]@{
            pfad     = $rel
            pattern  = 'EMPTY_FILE'
            severity = 'WARN'
            detail   = "$($bytes.Length) Bytes (< 50 Schwelle)"
            mtime    = $_.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
            size     = $bytes.Length
        }
    } elseif ($body.Trim().Length -eq 0 -and $frontmatter.Length -gt 0) {
        $findings += [PSCustomObject]@{
            pfad     = $rel
            pattern  = 'EMPTY_BODY'
            severity = 'WARN'
            detail   = 'Nur Frontmatter, kein Body-Inhalt'
            mtime    = $_.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
            size     = $bytes.Length
        }
    }

    # === KAPUTTE WIKILINKS ===
    # Vorher: Code-Spans und Code-Blocks aus Content strippen damit Doku-Beispiele
    # wie `[[]]` keine False-Positives ausloesen
    $contentForWikiCheck = $content
    $contentForWikiCheck = [regex]::Replace($contentForWikiCheck, '(?s)```.*?```', '')
    $contentForWikiCheck = [regex]::Replace($contentForWikiCheck, '`[^`]*`', '')

    # Empty: [[]]
    $emptyWikiCount = ([regex]::Matches($contentForWikiCheck, '\[\[\s*\]\]')).Count
    if ($emptyWikiCount -gt 0) {
        $findings += [PSCustomObject]@{
            pfad     = $rel
            pattern  = 'WIKILINK_EMPTY'
            severity = 'WARN'
            detail   = "$emptyWikiCount leere(s) Wikilink(s) [[]] gefunden"
            mtime    = $_.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
            size     = $bytes.Length
        }
    }

    # Unclosed: [[name ohne ]] (heuristisch: Anzahl `[[` != Anzahl `]]`)
    $openCount = ([regex]::Matches($contentForWikiCheck, '\[\[')).Count
    $closeCount = ([regex]::Matches($contentForWikiCheck, '\]\]')).Count
    if ($openCount -ne $closeCount) {
        $findings += [PSCustomObject]@{
            pfad     = $rel
            pattern  = 'WIKILINK_UNBALANCED'
            severity = 'WARN'
            detail   = "[[ count = $openCount, ]] count = $closeCount (sollten gleich sein)"
            mtime    = $_.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
            size     = $bytes.Length
        }
    }
}

$elapsed = ((Get-Date) - $startTime).TotalSeconds

# === Auswertung ===
$severeFindings = $findings | Where-Object severity -eq 'SEVERE'
$warnFindings = $findings | Where-Object severity -eq 'WARN'

$severeCount = if ($severeFindings) { @($severeFindings).Count } else { 0 }
$warnCount = if ($warnFindings) { @($warnFindings).Count } else { 0 }

Write-Host "Files gescannt: $filesScanned"
Write-Host "Dauer: $([math]::Round($elapsed, 2)) Sekunden"
Write-Host ""
if ($severeCount -gt 0) {
    Write-Host "SEVERE (Korruption):  $severeCount" -ForegroundColor Red
} else {
    Write-Host "SEVERE (Korruption):  0" -ForegroundColor Green
}
if ($warnCount -gt 0) {
    Write-Host "WARN (leer/Wikilink): $warnCount" -ForegroundColor Yellow
} else {
    Write-Host "WARN (leer/Wikilink): 0" -ForegroundColor Green
}
Write-Host ""

if ($severeCount -gt 0) {
    Write-Host "=== SEVERE-Findings ===" -ForegroundColor Red
    $severeFindings | Sort-Object pattern, mtime | Format-Table pattern, pfad, mtime, detail -AutoSize | Out-String -Width 240 | Write-Host
}

if ($warnCount -gt 0 -and $Full) {
    Write-Host "=== WARN-Findings ===" -ForegroundColor Yellow
    $warnFindings | Sort-Object pattern, pfad | Format-Table pattern, pfad, detail -AutoSize | Out-String -Width 240 | Write-Host
}

# === Markdown-Report schreiben ===
if (-not $NoReport -and ($severeCount -gt 0 -or $warnCount -gt 0)) {
    if (-not (Test-Path $ReportDir)) {
        New-Item -ItemType Directory -Path $ReportDir -Force | Out-Null
    }
    $reportFile = Join-Path $ReportDir ("{0}.md" -f (Get-Date -Format "yyyy-MM-dd-HHmm"))

    $reportLines = @()
    $reportLines += "---"
    $reportLines += "typ: vault-health-report"
    $reportLines += "datum: $(Get-Date -Format 'yyyy-MM-dd')"
    $reportLines += "zeitpunkt: $(Get-Date -Format 'HH:mm')"
    $reportLines += "mode: $(if ($Quick) { 'quick' } else { 'full' })"
    $reportLines += "files_gescannt: $filesScanned"
    $reportLines += "severe: $severeCount"
    $reportLines += "warn: $warnCount"
    $reportLines += "---"
    $reportLines += ""
    $reportLines += "# Vault-Health-Report"
    $reportLines += ""
    $reportLines += "Generiert: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    $reportLines += "Dauer: $([math]::Round($elapsed, 2))s"
    $reportLines += ""
    $reportLines += "Pattern-Quelle: ``02-wissen/vault-schreibregeln.md`` Sektion 3.2"
    $reportLines += ""
    if ($severeCount -gt 0) {
        $reportLines += "## SEVERE (Korruption, sofort fixen)"
        $reportLines += ""
        $reportLines += "| Pattern | Pfad | mtime | Detail |"
        $reportLines += "|---|---|---|---|"
        foreach ($f in ($severeFindings | Sort-Object pattern, mtime)) {
            $reportLines += "| $($f.pattern) | ``$($f.pfad)`` | $($f.mtime) | $($f.detail) |"
        }
        $reportLines += ""
    }
    if ($warnCount -gt 0) {
        $reportLines += "## WARN (Pruefen)"
        $reportLines += ""
        $reportLines += "| Pattern | Pfad | Detail |"
        $reportLines += "|---|---|---|"
        foreach ($f in ($warnFindings | Sort-Object pattern, pfad)) {
            $reportLines += "| $($f.pattern) | ``$($f.pfad)`` | $($f.detail) |"
        }
        $reportLines += ""
    }

    $reportContent = $reportLines -join "`n"
    $reportBytes = [System.Text.UTF8Encoding]::new($false).GetBytes($reportContent)
    [System.IO.File]::WriteAllBytes($reportFile, $reportBytes)

    Write-Host "Report: $reportFile"
}

# === Exit-Code ===
if ($FailOnBugs -and $severeCount -gt 0) {
    Write-Host ""
    Write-Host "EXIT 1: $severeCount SEVERE-Findings, FailOnBugs aktiv." -ForegroundColor Red
    exit 1
}
exit 0
