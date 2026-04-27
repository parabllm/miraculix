---
typ: status-doc
datum: 2026-04-27
zweck: Beobachtungsmodus
status: aktiv
---

# Automations-Status (Beobachtungsmodus)

Stand 2026-04-27 09:55. Alle relevanten Automatisierungen sind aus oder ungenutzt. Wir arbeiten manuell bis V3-Fix abgeschlossen ist und 3-7 Tage stabil.

## Aktuell DISABLED

### Miraculix Vault Auto-Push (Windows Scheduled Task)

- **Skript:** `_migration/auto-push.ps1`
- **Trigger:** alle 6h ab 08:00
- **State:** Disabled (von Deniz gesetzt 2026-04-27 09:35)
- **Pre-Push-Watchdog-Hook:** im Skript eingebaut, aber inaktiv weil Task disabled
- **Last Run:** 2026-04-27 09:35:54
- **Next Run wenn enabled waere:** 14:00:00

**Reaktivieren wenn V3 fertig und 3-7 Tage stabil:**

``powershell
Enable-ScheduledTask -TaskName "Miraculix Vault Auto-Push"
``

## Aktuell PASSIV (laeuft nur on-demand)

### Watchdog-Skript

- **Pfad:** `_claude/scripts/vault-health-check.ps1`
- **Aufruf:** manuell, oder via Skill-Trigger "vault pruefen"
- **Modi:** `-Quick`, `-Full`, `-FailOnBugs`
- **Status:** kein Background-Lauf, keine Cron, keine Scheduled-Task

Aufruf wenn benoetigt:
``powershell
powershell -File _claude/scripts/vault-health-check.ps1 -Full
``

## NICHT angefasst (laeuft, aber irrelevant fuer Vault)

### cowork-svc

- **PID:** wechselt
- **Was:** Anthropic-Internal-Service fuer Claude Desktop
- **Aktion:** NICHT killen, hat nichts mit Vault zu tun

## Was jetzt NICHT laufen soll (waehrend Beobachtungsmodus)

- Kein Auto-Push
- Kein automatischer Watchdog-Run
- Keine Git-Hooks (sind eh nicht installiert)
- Kein automatisches Commit ohne explizite Freigabe von Deniz

Manuelle Pushes sind OK wenn Deniz explizit dazu aufruft. Aber kein Skript darf automatisch pushen.

## Reaktivierungs-Checklist (fuer spaeter)

Schritt fuer Schritt wenn V3 fertig und 3-7 Tage stabil:

1. Watchdog-Vollscan manuell: muss 0 SEVERE zeigen
2. Auto-Push-Task einschalten: `Enable-ScheduledTask -TaskName "Miraculix Vault Auto-Push"`
3. Erster Auto-Push beobachten (im 6h-Fenster, in auto-push.log nachschauen)
4. Bei Bug-Detection: Auto-Push blockiert push, Report in `vault-health-reports/`
5. Optional: monatlichen Verify-Cron neu setzen (war vorher session-bound)

## Geschichte

- 2026-04-26 22:31: V2-Hardening behauptet "0 SEVERE", war falsch
- 2026-04-27 06:30: eingang-verarbeiten.md als Pattern A KAPUTT identifiziert (manuell)
- 2026-04-27 06:45: Daily Note 2026-04-26 als Pattern B identifiziert, von Claude Code repariert
- 2026-04-27 09:35: Auto-Push-Task disabled, Beobachtungsmodus aktiv
- 2026-04-27 09:50: eingang-verarbeiten.md auf Multi-Line-Block migriert (manuell), wissens-destillation.md auch
- 2026-04-27 09:55: V3-Mission-Prompt geschrieben fuer Claude Code (NEXT-CHAT-V3-MULTILINE-MIGRATION.md)
- 2026-04-27 ab 09:55: Claude Code laeuft V3 (Watchdog-Bug-Fix + Multi-Line-Migration aller Skills + Daten-Files)

## Vault-Schreibregeln (Kurz-Reminder)

Geltend in dieser Beobachtungsphase:

- NIE Desktop Commander `write_file` oder `edit_block` fuer .md mit YAML-Frontmatter
- Sichere Tools: PowerShell `[System.IO.File]::WriteAllBytes` mit UTF-8 NoBOM, Filesystem MCP
- Hex-Verify Pflicht nach jedem Write (erste 8 Bytes pruefen)
- Lange String-Werte im Frontmatter (>100 chars): YAML-Block-Syntax `|-` mit 2-Space-Einrueckung
- Master-Quellen: `02-wissen/vault-schreibregeln.md` und `02-wissen/vault-schreibkonventionen.md`