---
typ: log
projekt: "[[herosoftware]]"
datum: 2026-04-14
art: fortschritt
vertrauen: bestätigt
quelle: manuell
werkzeuge: ["attio", "hetzner", "lgm", "mantle", "n8n", "github"]
---

Phase 2 abgeschlossen: alle DRY-Runs + erster Live-Test. Repo auf GitHub privat gesichert.

## Tests

- `daily-sync --check` + `--dry` (full): **624 updated, 9.865 skipped, 0 errors, 17m 6s**
- `mantle-reconcile --check` + `--dry`: **94 Missing-Kunden** (erwartungsgemäß, Webhook-Lücken)
- `lgm-status-sync --check` + LIVE: sauber durch
- `lgm-push --check` + `--dry` + LIVE: **10 DUPLICATES erkannt, 0 echte Pushes** (alle schon in LGM)

## Code-Erweiterungen aus Tests

- **`splitName()` in `lgm-push`** deckt jetzt alle 7 Clay-Namensvarianten ab (vorher 2). Fall D (first_name enthält vollen Namen, last_name leer) war Hauptursache von 259 Doppelnamen in alten LGM-Pushes
- **Phase VERIFY** nach jedem Push: checkt gepushten Lead in LGM und korrigiert Doppelnamen direkt. Greift auch bei DUPLICATE-Leads
- **DUPLICATE-Sync-Lücke geschlossen:** bei `"duplicate"`-Response von LGM wird Attios `lgm_sequence` nachgetragen damit beim nächsten Cron kein erneuter Push-Versuch. `sequence_status` und `contacted_at` bleiben unberührt (kommen vom Status-Sync)

## Neu erstellt

- **`mantle-reconcile-diag.mjs`** - Diagnose-Script für detaillierte Matching-Analyse. CSV-Output mit allen Missing-Kunden + vorgeschlagenen Matches. Noch nicht gelaufen (kein Internet bei Deniz), soll 94 Missing aufklären

## Doku überarbeitet

- `ARCHITECTURE.md` raus (überflüssig)
- README, DEPLOYMENT, OPERATIONS, INTERNALS komplett überarbeitet
- SMTP-Auth-Hinweis in DEPLOYMENT.md
- Diag-Script-Anleitung in OPERATIONS.md
- Bug-History in INTERNALS.md um `splitName`-Fix und DUPLICATE-Sync-Lücke erweitert

## Repo-Hygiene

- `.gitignore` erweitert um `last-*-result.json`
- `ARCHITECTURE.md` + Runtime-JSONs gelöscht
- Struktur clean: 13 Dateien

## GitHub privat

- **Repo:** `https://github.com/parabllm/hero-software-sync` (PRIVATE)
- Initial commit mit 13 files, 47 KB
- Tokens NICHT im Repo (`.env` durch `.gitignore` geschützt)
- Status: Übergabe-ready, noch nicht an HeroSoft geteilt

## Offene Punkte

- Diag-Script auf 94 Missing laufen lassen (braucht Internet)
- Bug-Fix-Runde (8 Punkte): `err.cause` im Fatal-Handler, Retry für `TypeError: fetch failed`, Exit-Codes differenzieren, `--verbose` optional, Windows-Assertion-Bug + `--help`-vor-ENV in `daily-sync`, DUPLICATE-Logs auch in INFO-Level
- Loom-Video für HeroSoft
- Collaborator-Invite an HeroSoft-Backend-Team
- Übergabe-Email
