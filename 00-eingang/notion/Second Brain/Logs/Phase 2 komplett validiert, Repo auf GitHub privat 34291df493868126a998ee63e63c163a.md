# Phase 2 komplett validiert, Repo auf GitHub privat gesichert

Areas: Client Work
Confidence: Confirmed
Created: 14. April 2026 14:29
Date: 14. April 2026
Gelöscht: No
Log ID: LG-16
Project: HeroSoftware (../Projects/HeroSoftware%2033d91df4938681a8af4cf625b0b2f0cb.md)
Source: Manual
Tools: Attio, Hetzner, LGM, Mantle, n8n
Type: Progress

## Ziel heute

Phase 2 abschließen (alle DRY-Runs + erster Live-Test) und einen sicheren Backup-Zwischenstand via GitHub anlegen.

## Tests gelaufen

- `daily-sync --check` + `--dry` (full): **624 updated, 9.865 skipped, 0 errors, 17m 6s**
- `mantle-reconcile --check` + `--dry`: **94 Missing-Kunden gefunden** (erwartungsgemäß, Webhook-Lücken)
- `lgm-status-sync --check` + LIVE: sauber durch
- `lgm-push --check` + `--dry` + LIVE: **10 DUPLICATES erkannt, 0 echte Pushes** (alle Personen schon in LGM aus früheren Pushes)

## Neue Erkenntnisse → Code erweitert

- **`splitName()` in lgm-push** deckt jetzt alle 7 Clay-Namensvarianten ab (vorher nur 2). Fall D (first_name enthält vollen Namen, last_name leer) war die Hauptursache von 259 Doppelnamen in alten LGM-Pushes.
- **Phase VERIFY** nach jedem Push: checkt jeden gepushten Lead in LGM und korrigiert Doppelnamen direkt. Greift auch bei DUPLICATE-Leads.
- **DUPLICATE-Sync-Lücke geschlossen:** bei `"duplicate"`-Response von LGM wird Attio's `lgm_sequence` nachgetragen damit beim nächsten Cron kein erneuter Push-Versuch stattfindet. `sequence_status` und `contacted_at` bleiben unberührt (kommen vom Status-Sync).

## Neu erstellt

- **`mantle-reconcile-diag.mjs`:** Diagnose-Script für detaillierte Matching-Analyse. Schreibt CSV mit allen Missing-Kunden und vorgeschlagenen Matches. Noch nicht gelaufen (kein Internet bei Deniz), soll 94 Missing aufklären.

## Doku-Runde

- `ARCHITECTURE.md` raus (überflüssig)
- README, DEPLOYMENT, OPERATIONS, INTERNALS komplett überarbeitet
- Alle neuen Features dokumentiert
- SMTP-Auth-Hinweis in [DEPLOYMENT.md](http://DEPLOYMENT.md)
- Diag-Script Anleitung in [OPERATIONS.md](http://OPERATIONS.md)
- Bug-History in [INTERNALS.md](http://INTERNALS.md) um splitName-Fix und DUPLICATE-Sync-Lücke erweitert

## Repo-Hygiene

- `.gitignore` erweitert um `last-*-result.json`
- `ARCHITECTURE.md` und Runtime-JSONs gelöscht
- Struktur clean: 13 Dateien im Repo

## GitHub privat

- Repo: [https://github.com/parabllm/hero-software-sync](https://github.com/parabllm/hero-software-sync) (PRIVATE)
- Initial commit mit 13 files, 47 KB
- Tokens NICHT im Repo (`.env` durch `.gitignore` geschützt)
- Status: Übergabe-ready, aber noch nicht an HeroSoft geteilt

## Offene Punkte

- Diag-Script auf den 94 Missing laufen lassen (braucht Internet)
- Bug-Fix-Runde (8 Punkte gesammelt):
    - `err.cause` im Fatal-Handler ausgeben
    - Retry für `TypeError: fetch failed` + Cause-Codes
    - Besseres Retry-Logging
    - Exit-Codes differenzieren (0/1/2/3/4)
    - Optional `--verbose` Flag
    - Windows-Assertion-Bug + `--help`-vor-ENV in daily-sync nachziehen
    - DUPLICATE-Logs auch in INFO-Level (nicht nur DEBUG)
- Loom-Video für HeroSoft
- Collaborator-Invite an HeroSoft Backend-Team
- Übergabe-Email

## Design-Entscheidung heute

- Notify-Default `NOTIFY_EMAIL_TO` bleibt `oezbek@thalor.de` während Übergangsphase, klar markiert in [OPERATIONS.md](http://OPERATIONS.md) als "bitte umstellen nach Übernahme"
- Node 20 LTS als minimum, Server hat aktuell v22/v24