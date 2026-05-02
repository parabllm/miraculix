---
typ: wissen
projekt: "[[pulsepeptides]]"
thema: coo-automations
status: in_arbeit
erstellt: 2026-04-18
zuletzt_aktualisiert: 2026-04-18
vertrauen: extrahiert
quelle: voice_dump
---

# COO-Automations

Automations die Deniz' COO-Arbeit bei Pulse abnehmen sollen. Getrennt von den bestehenden Pulse-Automations (PulseBot, n8n Order-Sync, Janoshik OCR). Hier nur was Deniz selbst als COO produktiver macht.

Zweck: COO-Verlängerung über die Transition hinaus absichern.

---

## Slack-Notification-Automation

- **Status:** Konzept
- **Problem:** Deniz checkt Slack regelmäßig, aber Nachrichten von [[christian-darmahkasih]] fallen nicht sofort auf.
- **Ziel:** Trigger auf relevante Pulse-Slack-Nachrichten (insbesondere von Christian). Separate Push per Telegram oder WhatsApp an Deniz.
- **Bonus:** Antwort-Vorschlag mitschicken, den Deniz direkt weiterleiten kann.
- **Stack-Optionen:**
  - n8n Slack-Trigger (Event) → Telegram Bot API oder WhatsApp Business API
  - Antwort-Vorschlag via Claude über n8n HTTP-Request

## Meeting-Transkriptions-Tool

- **Status:** Recherche offen
- **Problem:** Viele Calls (Kalani, Christian, Team). Strukturierter Mitschnitt plus Auswertung fehlen.
- **Anforderungen:**
  - Auto-Transkription
  - Speaker-Erkennung
  - Integration mit Notion oder Vault
  - DSGVO-konform ([[kalani-ginepri]] EU)
- **Kandidaten:**
  - Fathom
  - Fireflies
  - Otter
  - Granola
  - tl;dv
- **Nächster Schritt:** Shortlist nach DSGVO-Filter.

## Persönliches Task-Tool

- **Status:** Vermutung, `vertrauen: angenommen`
- **Frage:** Wo landen Deniz' COO-Tasks damit er sieht was ansteht ohne Slack-Scroll?
- **Optionen:**
  - Eigene Notion-DB
  - Direkt im Vault (existierende `aufgaben/`-Konvention pro Projekt)
  - Todoist oder TickTick mit Slack-Integration
- **Vermutung:** Vault-basiert mit Miraculix-Sync. Integriert sich in den Rest, doppelte Pflege vermieden.

---

## Abgrenzung

Reine COO-Operationen (Banking, Krypto-Pipeline, Label-Pipeline, etc.) gehören nicht hier rein, sondern in [[coo-aufgaben]]. Hier nur Tools und Automatisierungen die Deniz' Arbeit verstärken.
