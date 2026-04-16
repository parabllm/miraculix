---
typ: log
projekt: "[[herosoftware]]"
datum: 2026-04-13
art: fortschritt
vertrauen: bestaetigt
quelle: manuell
werkzeuge: ["attio", "hetzner", "lgm", "mantle", "n8n", "node"]
---

## Ziel

Alle 4 Cron-Scripts (daily-sync, mantle-reconcile, lgm-push, lgm-status-sync) vom Hetzner-Server in ein sauberes, übergabefähiges Repo überführen. HeroSoft-Dev-Team zieht die Scripts in ihre eigene Infrastruktur.

## Architektur-Entscheidung

**Single-File Scripts** statt Shared Modules. Jedes Script self-contained mit eigenem Logger, Notify, HTTP-Client, Config-Loader. Code-Duplikation bewusst akzeptiert (Plan-Normalisierung in daily-sync und mantle-reconcile identisch) - mit `// SYNC:`-Kommentaren und INTERNALS.md als Guardrail.

## Heute erstellt

- Repo-Skelett `C:\Users\deniz\Documents\hero-software-sync\`
- 5 Doku-Files: README, ARCHITECTURE, DEPLOYMENT, OPERATIONS, INTERNALS
- `.env.example`, `.gitignore`, `package.json` (Node 20+, einzige Dep: `nodemailer`)
- Alle 4 Scripts production-ready:
  - `daily-sync.mjs` - 661 Zeilen
  - `mantle-reconcile.mjs` - 928 Zeilen (vorher `wf1-backup`)
  - `lgm-status-sync.mjs` - 643 Zeilen
  - `lgm-push.mjs` - 708 Zeilen

## Tests gelaufen

- `daily-sync --check`: Mantle + Attio Auth OK
- `daily-sync --dry` (full, 10.489 Matches): **624 updated, 9.865 skipped, 0 errors, 17m 6s**. Plausibel vs. Server-Cron (200 updated, 10.262 skipped) - Differenz durch Mantle sliding 30-Tage-Window für `last30Revenue`
- `mantle-reconcile --check`: OK
- `lgm-status-sync --check`: LGM + Attio OK
- **Notify via STRATO SMTP:** bestätigt, Mail kommt an
- **Anti-Spam Lock-Files:** funktionieren (zweiter Crash heute → "Notify übersprungen")
- **Config-Bug gefunden:** `NOTIFY_EMAIL_FROM` muss zum authentifizierten SMTP-User passen (STRATO 550 bei Fremd-Absender). In `.env` gefixt, `.env.example` braucht klareren Hinweis

## Offene Punkte

- `lgm-status-sync --dry` (erwartet ~34 Updates)
- `mantle-reconcile --dry` (erwartet ~0 missing, 3.320 Backfill am 8.4. gelaufen)
- `lgm-push --dry` (erwartet ~0 pushed, alle Personen haben `lgm_sequence` gesetzt)
- Single-Record Live-Test pro Script
- Phase 3: GitHub-Repo, Loom-Video, Übergabe-Email

## Design-Entscheidungen

- `.env` mit 3 Kategorien: Secrets, Operative, Domain-Konstanten (letztere hardcoded im Script)
- Notify: Email (nodemailer) + Slack (Webhook) parallel möglich, beide optional, Fallback stdout
- Default Notify-Empfänger: `oezbek@thalor.de` (Übergangsphase)
- Node 20 LTS minimum (Server hat v22/v24)
- Alle Scripts: `--help`, `--check`, `--dry` standardisiert
- `mantle-reconcile`: Default `--dry`, Live-Lauf nur mit `--execute` (zusätzliche Sicherung wegen CREATE-Ops)

## Bekannte Bugs

- Windows Assertion-Bug beim `process.exit()` auf Node 22/24 → in `mantle-reconcile`, `lgm-push`, `lgm-status-sync` mit `await delay(100)` gefixt. `daily-sync` belassen (Deniz' Wunsch)
- `daily-sync --help` validiert ENV vor Hilfe-Ausgabe. In den 3 anderen Scripts gefixt (Flags vor ENV-Loading geparst)

## Observation

Hetzner-Produktion läuft unverändert weiter. Neues Repo wird parallel validiert, erst nach Phase 2 mit Live-Tests scharf. **Keine Änderung am Produktionssystem heute.**
