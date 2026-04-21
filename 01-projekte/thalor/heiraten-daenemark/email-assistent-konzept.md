---
typ: konzept
projekt: "[[heiraten-daenemark]]"
name: "E-Mail-Assistent MVP"
aliase: ["E-Mail-Assistent", "Mail-Bot Heiraten Dänemark", "HiD-Mailbot"]
status: mvp_validiert_pausiert
erstellt: 2026-04-21
letzte_aenderung: 2026-04-21
tech_stack: ["n8n", "gmx-imap", "gmx-smtp", "gemini-2.5-flash", "telegram-bot"]
quelle: eigenbau_2026-04-21
vertrauen: bestaetigt
---

# E-Mail-Assistent MVP

**Zweck:** Kundenmails aus dem GMX-Postfach von Heiraten in Dänemark automatisch zu Antwortentwürfen verarbeiten, per Telegram zur Review geben, Freigabe mit einem Klick.

**Aktueller Status:** MVP-Pilot gebaut und funktional validiert am 2026-04-21. Bau pausiert. Grund: in der Session mit Maddox entstand die Idee eines umfassenderen Admin-Hubs, der den Mail-Bot als Komponente enthalten könnte. MVP wird nicht weitergebaut in der aktuellen Form, Erkenntnisse aus dem Bau fliessen in die nächste Iteration ein.

**Auftrag:** Nicht beauftragt. Pilotbau lief auf Deniz-Konto zu Demo- und Sparring-Zwecken. Siehe Auftragslage im Hauptprojekt [[heiraten-daenemark]].

Relevante Kontakte: [[maddox-yakymenskyy]] (Entscheider, Management), Igor (aktueller Mail-Bearbeiter, noch kein Kontakt-File).

---

## Validierung des Konzepts

Was der Pilot am 2026-04-21 gezeigt hat:

1. **Mail-Eingang wird korrekt erkannt.** IMAP-Trigger mit Cutoff-Datum filtert Alt-Mails raus, verarbeitet nur neue.
2. **Gemini 2.5 Flash generiert brauchbare Entwürfe.** Ton und Struktur passen mit Minimal-Wissensbasis. Auf Rückfrage bei unklarer Mail reagiert der Bot wie gewünscht (höfliches Nachhaken statt halluzinierter Zusagen).
3. **Telegram-Review-Loop funktioniert.** Entwurf kommt mit drei Buttons (Senden, Bearbeiten, Ablehnen) per Push auf Deniz-Handy.
4. **Human-in-the-Loop ist eingehalten.** Keine Mail geht raus ohne Klick.

**Nicht validiert, aber vorbereitet:**
- SMTP-Versand mit GMX (Credentials geprüft, Send-Zweig bis Parse-Node gebaut, finaler Send nicht getestet)
- Bearbeiten-Iterations-Loop (Switch-Routing gebaut, Zweig noch leer)
- Ablehnen-Zweig (Switch-Routing gebaut, Zweig noch leer)

---

## Aktueller Aufbau in n8n

### Credentials (alle vier angelegt und gegen echte Services getestet)

| Credential | Typ | Zweck |
|---|---|---|
| `GMX IMAP Heiraten` | IMAP | Mail lesen, Host `imap.gmx.net`, Port 993, SSL |
| `GMX SMTP Heiraten` | SMTP | Mail versenden, Host `mail.gmx.net`, Port 587, STARTTLS |
| `Gemini Heiraten` | Google Gemini(PaLM) Api | LLM-Calls |
| `Telegram Heiraten` | Telegram API | Bot-Kommunikation |

### Workflow A: "HiD Mailbot A: Mail eingegangen" (komplett gebaut)

```
[Email Trigger IMAP] → [Config laden] → [Entwurf generieren] → [Entwurf senden]
```

**Node 1, Email Trigger (IMAP)**
- Credential: `GMX IMAP Heiraten`
- Mailbox: `INBOX`
- Action: `Nothing` (Alt-Mails nicht als gelesen markieren)
- Polling: alle 2 Minuten
- Custom Email Rules: `["UNSEEN", ["SINCE", "21-Apr-2026"]]` (nur ungelesene ab Cutoff-Datum)

**Node 2, Config laden (Set Fields)**
- Fields: `knowledge` (String, Platzhalter-Wissensbasis im Markdown), `ABSENDER_MAIL` (String, `daenemark-heiraten@gmx.de`), `TELEGRAM_CHAT_ID` (String, Deniz-Chat-ID)
- Include Other Input Fields: an

**Node 3, Entwurf generieren (Google Gemini Message a Model)**
- Credential: `Gemini Heiraten`
- Model: `gemini-2.5-flash`
- Simplify Output: an
- System-Message: Rolle, Wissensbasis-Injection, Regeln (nur Mailtext, keine Betreffzeile, Deutsch, Unsicherheit = Rückfrage)
- User-Message: Mail-Metadaten plus `textPlain` der Kundenmail

**Node 4, Entwurf senden (Telegram Send Message)**
- Credential: `Telegram Heiraten`
- Chat ID: aus Config laden
- Text: zusammengesetzte Nachricht (Von, Betreff, ORIGINAL, ENTWURF)
- Reply Markup: Inline Keyboard mit 3 Buttons (`send`, `edit`, `reject` als callback_data)

### Workflow B: "HiD Mailbot B: Telegram Callback" (teilweise gebaut)

```
[Telegram Trigger] → [Route Callback] ┬─ senden → [Entwurf parsen] → (offen)
                                      ├─ bearbeiten (leer)
                                      ├─ ablehnen (leer)
                                      └─ iteration_text (leer)
```

**Node 1, Telegram Trigger**
- Credential: `Telegram Heiraten`
- Updates: alle
- Restrict to Chat IDs: Deniz-Chat-ID

**Node 2, Route Callback (Switch)**
- Mode: Rules
- Regel 1: `callback_query.data == "send"` → Output `senden`
- Regel 2: `callback_query.data == "edit"` → Output `bearbeiten`
- Regel 3: `callback_query.data == "reject"` → Output `ablehnen`
- Regel 4: `callback_query is empty` → Output `iteration_text`
- Fallback: `unknown`

**Senden-Zweig (angefangen, nicht vollendet):**
- Node: Entwurf parsen (Code, extrahiert To, Subject, Body, Callback-Metadaten aus `callback_query.message.text`)
- Geplant: SMTP Send → Bestätigung Telegram

---

## Wichtige Designentscheidungen

**Cutoff-Datum statt Ordner-Umzug.** Urspünglich angedacht war ein eigener `workflow`-Ordner in GMX. GMX-IMAP-Pfad-Erkennung scheiterte an Mailbox-Name-Varianten. Cutoff via `SINCE` in Custom Email Rules ist robuster und spart Igor den manuellen Verschiebe-Aufwand.

**Config als Set-Node statt n8n Variables.** n8n Cloud Community-Tarif sperrt globale Variables hinter Paywall. Lokaler Set-Node pro Workflow ist funktional identisch und export-sicher.

**Gemini statt Claude für diesen Workflow.** Anthropic-Credential liess sich nicht aufladen in der Session, Gemini Free Tier war sofort nutzbar. Qualität der deutschen Mail-Entwürfe mit `gemini-2.5-flash` ist gut genug für MVP. Ob das für Produktion reicht, ist offen. Sollte in einer späteren Iteration mit Claude Sonnet 4.6 gegengetestet werden.

**API-Keys in Credentials, Plain-Config in Set-Node.** Keys (GMX-Passwort, API-Keys, Bot-Token) nur in verschlüsselten n8n-Credentials. Plain-Werte (Chat-ID, Absender-Adresse, Wissensbasis) im Set-Node, damit Workflow-Export portabel bleibt.

**Callback-Data als simple Strings, nicht verkettete IDs.** Original-Konzept hatte `send|<message_id>`. Im Pilot vereinfacht zu `send`, `edit`, `reject`. Message-ID kommt beim Klick sowieso im Telegram-Payload mit, eigene ID-Verkettung war überflüssig.

---

## Was beim Bau gelernt wurde

**Positiv:**
- Die Architektur aus dem ursprünglichen Plan war tragfähig. Kein grundlegendes Redesign nötig gewesen.
- Gemini 2.5 Flash reicht qualitativ für deutsche Mail-Entwürfe mit strukturierter Wissensbasis.
- Inline-Keyboard-Buttons in Telegram sind unkompliziert und mobil gut bedienbar.

**Fallstricke:**
- IMAP-Pfade bei GMX sind nicht gleich zur Web-UI. Ordner-basierter Ansatz wurde verworfen.
- IMAP-Trigger holt per Default alle ungelesenen Mails auf einmal beim ersten Run. Ohne Cutoff-Datum wäre der Bot bei einem bestehenden Postfach mit hunderten Legacy-Mails sofort explodiert.
- Encoding-Fehler sichtbar geworden: GMX liefert Umlaute teilweise als Latin-1-interpretierte UTF-8 (`mÃ¶chte` statt `möchte`). Muss in Produktionsversion vor dem LLM-Call gefixt werden.
- n8n-Expressions sind strikt: Node-Namen müssen exakt stimmen, sonst `Referenced node doesn't exist`.

**Offene technische Fragen:**
- Wie wird die Wissensbasis produktiv gepflegt, wenn Maddox oder Igor sie ohne Zugriff auf n8n aktualisieren sollen? (File auf Hetzner, Google Doc, Notion, eigenes UI)
- Wie werden mehrere parallel wartende Entwürfe sauber routingtechnisch auseinandergehalten? (Message-ID-Tracking oder State-Store)
- Wie wird der Thread-Kontext bei Folge-Mails mit an das LLM gegeben?

---

## Wiederverwendbare Bausteine für nächste Iteration

Wenn der Auftrag kommt, wird die Funktionalität vermutlich in einen Admin-Hub integriert (Dashboard mit Mail-Review-UI statt reiner Telegram-Loop). Folgende Bausteine aus diesem Pilot bleiben nutzbar:

- IMAP-Trigger-Konfiguration und Cutoff-Logik
- LLM-System-Prompt-Struktur mit Wissensbasis-Injection
- Callback-Routing-Pattern
- Parse-Logik für strukturierte Mail-Inhalte aus Telegram-Nachrichten

---

## Referenzen

- Hauptprojekt: [[heiraten-daenemark]]
- Meeting-Notiz zum Bau-Kick-Off: [[2026-04-21-maddox-email-assistent]]
