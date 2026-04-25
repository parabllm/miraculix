---
typ: aufgabe
name: "Cora Scope Proposal, Reactive/Proactive/Hard Limits (Jann)"
aliase: ["Cora Scope Proposal", "Jann Cora Proposal", "iMessage Bridge Idee"]
projekt: "[[cora-ai]]"
bereich: produkt
umfang: offen
status: pausiert
kapazitaets_last: niedrig
kontakte: ["[[jann-allenberger]]", "[[lars-blum]]"]
erstellt: 2026-04-17
notizen: "Roadmap-Idee von Jann. Deniz skeptisch gegenüber Chatbot-Richtung. Nicht für aktuelle Implementierung vorgesehen, future scope."
quelle: extrahiert
vertrauen: extrahiert
---

# Cora Scope Proposal - Jann (Roadmap, nicht aktiv)

> [!info] Status
> Von **Jann** vorgeschlagen, für Team-Review. **Deniz ist skeptisch** gegenüber der Chatbot-Ausrichtung - insbesondere dem iMessage/SMS-Bridge-Konzept. Hier gespeichert als Future-Scope-Referenz, nicht als aktive Entscheidung.
>
> Stand: 2026-04-17. Empfänger laut Original: Lars, Deniz.

---

## Leitprinzip (Janns Kern-Argument)

> "Coralate is an app with a conversational interface to its own systems - not an AI assistant that happens to have an app attached."

Chat = leichte Schicht für schnelle Inputs. App = primärer Arbeitsbereich.
Cora übernimmt: einzelne Logs, einfache Fragen, schnelle Terminänderungen.
Alles Komplexe (Workout-Programmierung, Zieländerungen, Datenexploration) → Weiterleitung in die App per Deep Link.

---

## Reactive: Was Cora auf Anfrage tut

### 1a - Read-Operationen (bereits specced, keine Änderung)
Cora erklärt dem User seine eigenen Daten, Korrelationsmethodik, Konfidenz-Levels.

### 1b - Logging Writes *(NEU - für v1 vorgeschlagen)*
Cora nimmt Text/Voice-Input und schreibt strukturierte Logs. User hat bereits entschieden - Cora ist nur schnellerer Input-Kanal.
- Soft-Confirmation vor Commit bei nicht-trivialen Einträgen
- One-tap Undo jederzeit
- Ambiguous input → Rückfrage, nicht Vermutung

### 1c - Scheduling Writes *(für v1.1 - nach Launch)*
Cora erstellt Workout-Einträge, Pausentage, Erinnerungen auf explizite Anweisung.
**Kritische Regel:** Cora bucht nur was der User explizit sagt. Niemals: "Cora erkennt Muster → bucht Session proaktiv." Das wäre Coaching → SaMD-Territorium.

### 1d - Hard Limit (permanent, kein v2, kein Premium-Tier)
**Kein Advisory-Content. Jemals.**
Keine Ernährungsempfehlungen, kein Training-Advice, keine Recovery-Guidance, keine Supplementation.

Redirect-Pattern statt Ablehnung:
> User: "Was soll ich zum Frühstück essen?"
> Cora: "Das kann ich nicht empfehlen - aber ich kann dir zeigen was du an deinen besten Morgen gegessen hast. Soll ich?"

### 1e - App-Redirect-Pattern *(für v1)*
Komplexe Tasks → Cora leitet warm in die App weiter mit Deep Link (kein "Nein", sondern "besser dort").

---

## Proactive: Was Cora von sich aus tut

### 2a - iMessage/SMS Bridge "Cora-as-Contact" *(für v1.1 - hier Deniz skeptisch)*

**Die Idee:** Cora bekommt eine eigene Telefonnummer (Twilio/Linq), User speichert sie als Kontakt. Cora schreibt *nur wenn Signal-Dichte es rechtfertigt* - kein Notification-Spam.

**Technisch:** Twilio-Webhook → Cora API → Response → Twilio-Delivery. Kein Apple Business Account nötig. Android = automatisch SMS-Fallback.

**Jann's Pitch:**
- Coralate kämpft nicht um App-Icon-Klicks, sondern lebt als Kontakt im meistgenutzten App
- Validiertes Modell: Poke (~$300M Valuation), Sidekicks, BodyBuddy
- Logging-Friction kollabiert: "2 Eier, schwarzer Kaffee" per iMessage

**Was Cora nie aktiv schreibt:**
- Streak-Save-Notifications
- "Wir vermissen dich!"
- Generische Engagement-Nudges
- Marketing-Content
- Prescriptive Content

**Cons (Janns eigene Einschätzung):**
- Onboarding-Friction (Nummer speichern)
- GDPR-Surface erweitert sich auf Messaging-Kanal
- Latenz-Erwartungen brutal: Sekunden, nicht Minuten
- Kein verified-business Badge in iMessage
- Twilio-Kosten (~$1-5/Monat pro Nummer + $0.0075/SMS)
- Mehr Backend-Aufwand für Deniz in bereits engem Zeitplan

> [!warning] Deniz' Einschätzung
> Die Chatbot-/iMessage-Idee spricht Deniz nicht direkt an. Future-Scope, keine aktive Priorisierung.

### 2b - Post-Workout / Post-Scan Reflections (bereits specced)
Keine Änderung.

### 2c - New Correlation Events *(für v1)*
Wenn Korrelation Konfidenz-Schwelle überschreitet → Product Event (Push, In-App Badge, optional iMessage-Ping).

### 2d - Weekly Brief *(für v1)*
1x/Woche (Sonntag oder Montag, User-Wahl): 3-Bullet Summary was korreliert hat, was nicht, was sich bildet.
Mental Model: Spotify Release Radar - vorhersehbar, niedrige Frequenz.

### 2e - Monthly Review *(v1.1/v2 - Spotify Wrapped-Mechanic)*
Selten, teilbar, überraschend → organisches Wachstum via Screenshot.

---

## Implementation-Phasen (Janns Vorschlag)

| Phase | Inhalt |
|---|---|
| **v1** | Read-Ops (bereits), Logging Writes, New-Correlation Events, Weekly Brief, Redirect-Pattern |
| **v1.1** | iMessage/SMS Bridge, Scheduling Writes, Voice-Logging-Verbesserungen |
| **v2** | Monthly Review, WhatsApp Business API für nicht-EU-Märkte |
| **Permanent Out** | Advisory Content, proaktive Aktionen ohne User-Anfrage, externe App-Writes (iOS Calendar, HealthKit) |

---

## Offene Fragen von Jann ans Team

| An | Frage |
|---|---|
| Lars | Twilio-Nummer in DE/EU: Sender-ID-Registrierung, Kosten bei Scale, ein oder mehrere Nummern? |
| **Deniz** | **Realistische Engine-Cadence: Tag der ersten Korrelation für Median-User? Ø Tage zwischen Korrelationen?** Diese Zahl ist die eigentliche Retention-Decke. |
| Alle | Team-Commitment: Cora produziert niemals Advisory-Content - als Team-Entscheidung, nicht Design-Entscheidung. |

---

## Verbindung zu bestehender Architektur

Bestehende Cora-Architektur-Entscheidungen → [[cora-ai-architektur]]
