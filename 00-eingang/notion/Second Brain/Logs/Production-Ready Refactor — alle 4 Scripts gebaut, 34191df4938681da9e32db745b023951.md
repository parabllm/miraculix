# Production-Ready Refactor — alle 4 Scripts gebaut, daily-sync + LGM Auth-Checks validiert

Areas: Client Work
Confidence: Confirmed
Created: 14. April 2026 00:43
Date: 13. April 2026
Gelöscht: No
Log ID: LG-15
Project: HeroSoftware (../Projects/HeroSoftware%2033d91df4938681a8af4cf625b0b2f0cb.md)
Source: Manual
Tools: Attio, Hetzner, LGM, Mantle, n8n
Type: Progress

## Ziel

Alle 4 Cron-Scripts (daily-sync, mantle-reconcile, lgm-push, lgm-status-sync) vom Hetzner-Server in ein sauberes, übergabefähiges Repo überführen. HeroSoft Dev-Team zieht die Scripts in ihre eigene Infrastruktur, Projekt soll self-contained abgegeben werden.

## Architektur-Entscheidung

**Single-File Scripts** statt Shared Modules. Jedes Script self-contained mit eigenem Logger, Notify, HTTP-Client, Config-Loader. Code-Duplikation bewusst akzeptiert (Plan-Normalisierung in daily-sync und mantle-reconcile identisch) — mit `// SYNC:`-Kommentaren und [INTERNALS.md](http://INTERNALS.md) als Guardrail.

## Erstellt heute

- Repo-Skelett in `C:\Users\deniz\Documents\hero-software-sync\`
- 5 Doku-Files: README, ARCHITECTURE, DEPLOYMENT, OPERATIONS, INTERNALS
- `.env.example`, `.gitignore`, `package.json` (Node 20+, einzige Dependency: nodemailer)
- Alle 4 Scripts production-ready:
    - `daily-sync.mjs` — 661 Zeilen
    - `mantle-reconcile.mjs` — 928 Zeilen (vorher wf1-backup)
    - `lgm-status-sync.mjs` — 643 Zeilen
    - `lgm-push.mjs` — 708 Zeilen

## Tests gelaufen

- `daily-sync --check`: Mantle + Attio Auth OK
- `daily-sync --dry` (full, 10.489 Matches): **624 updated, 9.865 skipped, 0 errors, 17m 6s**. Plausibel vs. Server-Cron (200 updated, 10.262 skipped) — Differenz erklärbar durch Mantle sliding 30-Tage-Window für `last30Revenue`.
- `mantle-reconcile --check`: OK
- `lgm-status-sync --check`: LGM + Attio OK
- **Notify-System via STRATO SMTP**: bestätigt, Mail kommt an
- **Anti-Spam Lock-Files**: funktionieren (zweiter Crash heute → "Notify übersprungen")
- Config-Bug gefunden: `NOTIFY_EMAIL_FROM` muss zum authentifizierten SMTP-User passen (STRATO 550 bei Fremd-Absender). In `.env` gefixt, `.env.example` braucht klareren Hinweis.

## Offene Punkte für nächste Session

- `lgm-status-sync --dry` (Vergleich gegen Server-Cron 12:00, erwartet ~34 Updates)
- `mantle-reconcile --dry` (erwartet ~0 missing, weil am 8.4. schon 3.320 Backfill gelaufen)
- `lgm-push --dry` (erwartet ~0 pushed, weil alle Personen schon `lgm_sequence` gesetzt haben)
- Danach Single-Record Live-Test pro Script
- Dann Phase 3: GitHub-Repo, Loom-Video, Übergabe-Email

## Design-Entscheidungen

- `.env` mit 3 Kategorien: Secrets, Operative, Domain-Konstanten (letztere hardcoded im Script)
- Notify: Email (nodemailer) + Slack (Webhook) parallel möglich, beide optional, Fallback stdout
- Default Notify-Empfänger: `oezbek@thalor.de` (Übergangsphase, in [OPERATIONS.md](http://OPERATIONS.md) als "bitte umstellen" markiert)
- Node 20 LTS minimum, Server hat aktuell v22/v24
- Alle Scripts: `--help`, `--check`, `--dry` standardisiert
- `mantle-reconcile`: Default ist `--dry`, Live-Lauf nur mit `--execute` (zusätzliche Sicherung wegen CREATE-Operationen)

## Bekannte Bugs (akzeptiert oder in finaler Runde zu fixen)

- Windows Assertion-Bug beim `process.exit()` auf Node 22/24 → in mantle-reconcile, lgm-push, lgm-status-sync mit `await delay(100)` gefixt. daily-sync belassen wie es ist (Deniz' Wunsch).
- `daily-sync --help` validiert ENV vor Hilfe-Ausgabe. In den 3 anderen Scripts gefixt (Flags werden vor ENV-Loading geparst). Für daily-sync irrelevant gelassen.

## Observation

Auf dem Hetzner läuft der produktive Cron weiter und bleibt unverändert. Das neue Repo wird parallel validiert und erst nach Phase 2 mit Live-Tests scharf geschaltet. Keine Änderung am Produktionssystem heute.