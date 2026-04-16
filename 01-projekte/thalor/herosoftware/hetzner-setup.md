---
typ: aufgabe
name: "HeroSoftware Hetzner Server Setup"
projekt: "[[herosoftware]]"
status: in_arbeit
benoetigte_kapazitaet: mittel
kontext: ["desktop"]
kontakte: []
quelle: notion_migration
vertrauen: extrahiert
erstellt: 2026-04-16
---

Hetzner VPS Helsinki Ubuntu 24.04. `n8n.thalor.de` via Docker + Nginx + Let's Encrypt. `/opt/hero/` Skripte. `/var/log/hero/` Logs. Crons sind NICHT eingerichtet - Deployment ist offene Task.

## Architektur

- **Provider:** Hetzner Cloud
- **Standort:** Helsinki
- **OS:** Ubuntu 24.04
- **Domain:** `n8n.thalor.de` (Let's Encrypt SSL)
- **n8n:** self-hosted via Docker + Nginx Reverse Proxy
- **Skript-Verzeichnis:** `/opt/hero/`
- **Log-Verzeichnis:** `/var/log/hero/`

## Was auf dem Server läuft

### Self-hosted n8n

- URL: `n8n.thalor.de`
- Setup: Docker + Nginx Reverse Proxy + Let's Encrypt
- Zweck: Backup zu `herosoftware.app.n8n.cloud`. Aktuell kein Produktiv-Workflow drauf, aber bereit als Failover.

### Sync-Skripte unter `/opt/hero/`

- `daily-sync.mjs` - Attio Billing Sync (täglich) - siehe [[daily-sync]]
- `lgm-push.mjs` - Attio → LGM Push (Dienstags) - siehe [[lgm-push]]
- `lgm-status-sync.mjs` - LGM → Attio Status Sync (täglich) - siehe [[lgm-status-sync]]
- `wf1-backup.mjs` - WF1 Recovery + Backfill (alle 14 Tage) - siehe [[wf1-backup]]

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

**Wichtig:** Crons sind noch NICHT eingerichtet. Skripte laufen aktuell lokal bei Deniz. Deployment auf Hetzner ist offene Task.

## Deployment-Workflow (geplant)

1. SSH auf den Server
2. `cd /opt/hero` + git pull (oder rsync vom lokalen Verzeichnis)
3. `npm install` falls neue Dependencies
4. `crontab -e` + obige Crontab eintragen
5. Test-Lauf manuell pro Skript: `node daily-sync.mjs --dry`
6. Logs prüfen: `tail -f /var/log/hero/daily-sync.log`

## Environment Variables

- `MANTLE_API_KEY`
- `ATTIO_API_KEY`
- `LGM_API_KEY`
- `CLAY_API_KEY` (falls Skripte Clay aufrufen, aktuell noch nicht direkt)

Alle Keys via `.env` Datei im Skript-Verzeichnis geladen (dotenv).

**Sicherheitshinweis:** Aktuell genutzte API Keys müssen alle ausgetauscht werden (mehrfach in Chat-Verläufen aufgetaucht).

## Beziehung zur Entwicklungsumgebung

- **Lokal bei Deniz:** alle Skripte gespiegelt, gleiche Verzeichnisstruktur, eigene `.env`
- **Hetzner:** Produktion, läuft via Cron
- **Sync:** noch manuell (rsync/git), kein CI/CD

## Edge Cases

- Server-Reboot: Cron startet automatisch wieder (systemd cron service)
- Skript-Fehler: schreibt in Log, Cron läuft beim nächsten Slot wieder. Kein Auto-Retry außerhalb der API-Call-Retries.
- Disk voll: Logs sollten via logrotate aufgeräumt werden (noch zu konfigurieren)

## Open Points

- Logrotate Setup für `/var/log/hero/*.log`
- CI/CD von lokalem Repo auf Server (aktuell manuell rsync)
- Monitoring/Alerting wenn Cron-Job fehlschlägt (Task `WF Error Slack` deckt das ab)
