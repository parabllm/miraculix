# Hetzner Server Setup (HeroSoftware)

Created: 9. April 2026 11:34
Doc ID: DOC-43
Doc Type: Reference
Gelöscht: No
Last Edited: 9. April 2026 11:34
Lifecycle: Active
Notes: Hetzner VPS Helsinki Ubuntu 24.04. http://n8n.thalor.de via Docker+Nginx+LE. /opt/hero/ Skripte. /var/log/hero/ Logs. Geplante Crontab: daily-sync 6h, lgm-push Di 7h, lgm-status-sync 12h, wf1-backup http://2.So 1h. Crons sind NICHT eingerichtet — Deployment ist offene Task. API Keys müssen ausgetauscht werden.
Project: HeroSoftware (../Projects/HeroSoftware%2033d91df4938681a8af4cf625b0b2f0cb.md)
Stability: Stable
Stack: Hetzner
Verified: No

## Scope

Der Hetzner VPS in Helsinki ist das Rückgrat von HeroSoftware. Er hostet die self-hosted n8n Instanz auf `n8n.thalor.de` (als Backup zur Cloud-Instanz `herosoftware.app.n8n.cloud`) und alle Sync-Skripte unter `/opt/hero/`. Diese Doku beschreibt das Server-Setup, die Crontab und die Skript-Verzeichnisstruktur.

## Architecture / Constitution

- **Provider:** Hetzner Cloud
- **Standort:** Helsinki
- **OS:** Ubuntu 24.04
- **Domain:** `n8n.thalor.de` (mit Let's Encrypt SSL)
- **n8n:** self-hosted via Docker + Nginx Reverse Proxy
- **Skript-Verzeichnis:** `/opt/hero/`
- **Log-Verzeichnis:** `/var/log/hero/`

## Was läuft auf dem Server

### Self-hosted n8n

- **URL:** `n8n.thalor.de`
- **Setup:** Docker + Nginx Reverse Proxy + Let's Encrypt
- **Zweck:** Backup zu `herosoftware.app.n8n.cloud`. Aktuell kein Produktiv-Workflow drauf, aber bereit als Failover.

### Sync-Skripte unter `/opt/hero/`

- `daily-sync.mjs` — Attio Billing Sync (täglich)
- `lgm-push.mjs` — Attio → LGM Push (Dienstags)
- `lgm-status-sync.mjs` — LGM → Attio Status Sync (täglich)
- `wf1-backup.mjs` — WF1 Recovery + Backfill (alle 14 Tage)

## Geplante Crontab

```
# daily-sync: jeden Tag 06:00 Berlin
0 6 * * *      cd /opt/hero && node daily-sync.mjs >> /var/log/hero/daily-sync.log 2>&1

# lgm-push: Dienstag 07:00 Berlin
0 7 * * 2      cd /opt/hero && node lgm-push.mjs >> /var/log/hero/lgm-push.log 2>&1

# lgm-status-sync: jeden Tag 12:00 Berlin
0 12 * * *     cd /opt/hero && node lgm-status-sync.mjs >> /var/log/hero/lgm-status.log 2>&1

# wf1-backup: jeden zweiten Sonntag 01:00 Berlin
0 1 * * 0/2    cd /opt/hero && node wf1-backup.mjs >> /var/log/hero/wf1-backup.log 2>&1
```

**Wichtig:** Crons sind noch NICHT eingerichtet. Skripte laufen aktuell lokal bei Deniz. Deployment auf Hetzner ist eine offene Task (siehe Tasks DB).

## Deployment-Workflow (geplant)

1. SSH auf den Server
2. `cd /opt/hero` und git pull (oder rsync vom lokalen Verzeichnis)
3. `npm install` falls neue Dependencies
4. `crontab -e` und obige Crontab eintragen
5. Test-Lauf manuell pro Skript: `node daily-sync.mjs --dry`
6. Logs prüfen: `tail -f /var/log/hero/daily-sync.log`

## Environment Variables (notwendig)

- `MANTLE_API_KEY` — Mantle API Key
- `ATTIO_API_KEY` — Attio API Key
- `LGM_API_KEY` — LGM API Key
- `CLAY_API_KEY` — Clay API Key (falls Skripte Clay aufrufen, aktuell noch nicht direkt)

Alle Keys werden via `.env` Datei im Skript-Verzeichnis geladen (dotenv).

**Sicherheitshinweis:** Aktuell genutzte API Keys müssen alle ausgetauscht werden, da sie mehrfach in Chat-Verläufen aufgetaucht sind. Siehe Task "Neue API Keys erstellen".

## Beziehung zur Entwicklungsumgebung

- **Lokal bei Deniz:** alle Skripte gespiegelt, gleiche Verzeichnisstruktur, eigene `.env`
- **Hetzner:** Produktion, läuft via Cron
- **Sync:** noch manuell (rsync/git), kein CI/CD

## Edge Cases

- **Server-Reboot:** Cron startet automatisch wieder (systemd cron service)
- **Skript-Fehler:** schreibt in Log, Cron läuft beim nächsten Slot wieder. Kein Auto-Retry außerhalb der API-Call-Retries.
- **Disk Voll:** Logs sollten via logrotate aufgeräumt werden (noch zu konfigurieren)

## Open Questions

- Logrotate Setup für `/var/log/hero/*.log`
- CI/CD von lokalem Repo auf Server (aktuell manuell rsync)
- Monitoring/Alerting wenn ein Cron-Job fehlschlägt (→ Task `WF Error Slack` deckt das ab)