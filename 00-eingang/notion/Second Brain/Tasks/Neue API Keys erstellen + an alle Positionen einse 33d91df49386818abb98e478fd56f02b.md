# Neue API Keys erstellen + an alle Positionen einsetzen (Skripte + n8n Workflows + .env)

Approval Status: Approved
Created: 9. April 2026 11:35
Gelöscht: No
Notes: Aktuell genutzte API Keys für Mantle, Attio, LGM und Clay müssen alle ausgetauscht werden, da sie mehrfach in Chat-Verläufen aufgetaucht sind. Schritte: (1) Neue Keys in jedem Provider erstellen (Mantle, Attio, LGM, Clay), (2) Alte Keys deaktivieren, (3) Neue Keys in den lokalen .env-Dateien einsetzen, (4) Neue Keys in den Hetzner /opt/hero/.env einsetzen, (5) Neue Keys im n8n Cloud Workflow WF1 (Credentials) einsetzen, (6) Neue Keys im self-hosted n8n auf http://n8n.thalor.de einsetzen falls dort relevant, (7) Test-Lauf pro Skript (--dry) und WF1 Test-Webhook. Robin muss separat seine eigenen Clay API Keys erstellen — das ist seine Aufgabe und nicht in dieser Task enthalten.
Priority: High
Project: HeroSoftware (../Projects/HeroSoftware%2033d91df4938681a8af4cf625b0b2f0cb.md)
Source: Manual
Status: Done
Task ID: TK-3
Type: Task