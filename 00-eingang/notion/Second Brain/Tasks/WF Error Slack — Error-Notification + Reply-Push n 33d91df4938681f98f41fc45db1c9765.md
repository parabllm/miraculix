# WF Error Slack — Error-Notification + Reply-Push nach Slack bauen

Approval Status: Approved
Created: 9. April 2026 11:35
Gelöscht: No
Notes: Error-Notification-Workflow bauen der Slack-Messages sendet wenn ein HeroSoftware-Skript oder n8n-Workflow fehlschlägt. Optionen: (a) n8n Workflow der die Hetzner Logs pollt, (b) Slack Webhook direkt aus den Skripten heraus, (c) systemd OnFailure Hook. Sollte mindestens abdecken: WF1 Webhook-Fehler in n8n Cloud, Cron-Job-Fehler auf Hetzner, LGM Reply-Notifications (separat — wenn ein Lead positiv antwortet, soll Robin direkt in Slack einen Ping bekommen).
Priority: Medium
Project: HeroSoftware (../Projects/HeroSoftware%2033d91df4938681a8af4cf625b0b2f0cb.md)
Source: Manual
Status: Done
Task ID: TK-5
Type: Task