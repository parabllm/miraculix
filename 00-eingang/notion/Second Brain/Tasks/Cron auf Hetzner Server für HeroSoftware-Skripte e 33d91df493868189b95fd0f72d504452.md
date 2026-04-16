# Cron auf Hetzner Server für HeroSoftware-Skripte einrichten

Approval Status: Approved
Created: 9. April 2026 11:35
Gelöscht: No
Notes: Die Hetzner-Skripte (daily-sync.mjs, lgm-push.mjs, lgm-status-sync.mjs, wf1-backup.mjs) laufen aktuell lokal bei Deniz, nicht auf dem Hetzner Server. Schritte: (1) Skripte nach /opt/hero/ deployen (rsync oder git pull), (2) npm install ausführen, (3) .env mit den neuen API Keys erstellen (siehe Task: Neue API Keys), (4) Test-Lauf pro Skript manuell, (5) crontab -e und folgende Einträge setzen: daily-sync 0 6   , lgm-push 0 7   2, lgm-status-sync 0 12   , wf1-backup 0 1   0/2. Voraussetzung: API Keys sind bereits getauscht.
Priority: High
Project: HeroSoftware (../Projects/HeroSoftware%2033d91df4938681a8af4cf625b0b2f0cb.md)
Source: Manual
Status: In Progress
Task ID: TK-4
Type: Task