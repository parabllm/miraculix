---
typ: konzept
projekt: "[[heiraten-daenemark]]"
name: "Admin-Hub Konzept"
aliase: ["Admin-Hub", "HiD Admin", "Heiraten Daenemark Dashboard"]
status: in_review_maddox
erstellt: 2026-04-21
geplant_fuer: semesterferien
quelle: maddox-session_2026-04-21
vertrauen: angenommen
---

# Admin-Hub: Konzeptplan

> **Status: Maddox hat das gerade in Review. Er macht sich Gedanken dazu.**
> **Geplanter Start: Semesterferien.**
> Kein aktiver Thalor-Auftrag. Noch keine Eltern-Abstimmung. Alles hier ist Brainstorm-Stand.

---

## Was der Admin-Hub lösen soll

Heiraten in Dänemark hat aktuell drei parallel laufende, unverbundene Kommunikations- und Verwaltungs-Kanäle:

1. **WhatsApp** (Hauptkanal, mehrere private Nummern, kein zentrales Postfach)
2. **E-Mail via GMX** (Igor beantwortet manuell, Qualität schwankt)
3. **Lexware** (Rechnungsstellung, vermutlich manuell, Prozess ungeklärt)

Dazu kommt Datei-Ablage über Dropbox (aktuell) mit möglichem Wechsel auf Google Drive.

Ein Admin-Hub zieht das zusammen: eine Oberfläche, alle Kanäle, KI-gestützte Entwürfe, Kundendatenbank, Rechnungsautomatisierung.

---

## Kernkomponenten

### 1. Nachrichten-Inbox (WhatsApp + E-Mail)

Alle eingehenden Nachrichten landen in einem gemeinsamen Feed. Bearbeiter (Igor, Maddox) sieht alles auf einen Blick, kein Wechsel zwischen WhatsApp-Web und GMX nötig.

**Pro Nachricht:**
- KI-Entwurf wird automatisch generiert (Gemini oder Claude)
- Entwurf kann direkt im Hub bearbeitet und freigegeben werden
- Antwort geht über den gleichen Kanal raus (WhatsApp oder E-Mail)
- Gespräch wird dem richtigen Paar zugeordnet (via Telefonnummer oder E-Mail als Identifier)

### 2. Paar-Pipeline (CRM)

Jedes Paar hat eine eigene Seite im Hub:

- Kontaktdaten (Name, Telefon, E-Mail, Nationalität)
- Status in der Pipeline (Anfrage, Dokumente ausstehend, Antrag gestellt, Termin fix, Hochzeit, Nachbereitung)
- Kommunikationshistorie (alle WhatsApp- und Mail-Nachrichten chronologisch)
- Dokumente (Checkliste welche Dokumente eingegangen sind)
- Rechnungsstatus (offen, bezahlt, via Lexware-Sync)

### 3. Dokumenten-Verwaltung

Paare schicken Dokumente (Pass, Geburtsurkunde, Ledigkeitsbescheinigung etc.) per WhatsApp oder E-Mail als Anhang. Der Hub:

- Empfängt Anhänge automatisch
- Legt sie strukturiert ab (ein Ordner pro Paar)
- Hakt sie in der Checkliste ab

**Offene Frage: Wo werden die Dateien gespeichert? (siehe unten)**

### 4. Rechnungs-Automatisierung (Lexware)

Wenn ein Paar von "Auftrag" auf "Bezahlt" springt, oder manuell ausgelöst:

- Kontakt in Lexware anlegen (oder verknüpfen wenn schon vorhanden)
- Rechnung erstellen via Lexware Public API
- PDF rendern lassen
- PDF per E-Mail oder WhatsApp an Paar schicken
- Zahlungsstatus via Lexware-Webhook in Hub synchronisieren

**Voraussetzung: Lexware Office XL-Tarif nötig. Aktuellen Tarif prüfen.**

---

## Dateispeicherung: Optionen

Das ist die offene Kernfrage. Drei realistische Optionen:

### Option A: Supabase Storage (empfohlen als Primärspeicher)

Supabase hat einen integrierten Object Storage (S3-kompatibel). Dateien landen direkt in Supabase neben der Datenbank.

| Aspekt | Bewertung |
|---|---|
| Integration | perfekt, gleicher Stack wie die DB |
| Kosten | im Free-Tier 1 GB inklusive, Pro-Plan 100 GB für 25 USD/Monat |
| Zugriff | direkt aus dem Admin-Hub, kein Umweg |
| Backup | automatisch via Supabase-Backup-Plan |
| Für Maddox/Igor zugänglich ohne Admin-Hub | nur über Supabase-Dashboard, nicht user-friendly |

### Option B: Google Drive als Primärspeicher

Dateien liegen direkt in Google Drive, strukturiert in Ordnern (ein Ordner pro Paar). Admin-Hub schreibt und liest über Google Drive API.

| Aspekt | Bewertung |
|---|---|
| Für Familie zugänglich | ja, alle können Drive öffnen ohne Admin-Hub |
| Integration | Google Drive API, machbar aber ein weiterer Service |
| Backup-Mentalität | Maddox hat das schon so im Kopf (Drive als Ablage) |
| Kosten | Google Workspace oder privater Drive, 15 GB kostenlos |
| Nachtteil | zwei Stellen für Dateien (DB in Supabase, Files in Drive) |

### Option C: Hybrid (Supabase primär, Drive als Backup)

Dateien landen zuerst in Supabase Storage. Ein nächtlicher Job (n8n-Cron) spiegelt alle neuen Dateien nach Google Drive als Backup.

| Aspekt | Bewertung |
|---|---|
| Backup-Sicherheit | hoch, zwei unabhängige Speicher |
| Für Familie als Notfallzugriff | Drive bleibt lesbar auch wenn Admin-Hub down ist |
| Komplexität | etwas mehr Setup, aber wartbar |
| Empfehlung | ja, wenn Maddox Drive-Backup als Sicherheitsnetz will |

**Meine Empfehlung: Option C.** Supabase als operativer Speicher (schnell, im Stack integriert), Google Drive als Backup und Notfall-Lesezugriff für die Familie.

---

## Tech-Stack (Vorschlag)

| Schicht | Technologie | Begründung |
|---|---|---|
| Frontend | Next.js | Deniz kennt React-Ökosystem, gute Admin-UI-Bibliotheken |
| Backend/DB | Supabase | Schon im Thalor-Stack, Auth inklusive, Realtime für Live-Updates |
| Datei-Speicher | Supabase Storage + Google Drive Backup | |
| Workflow-Engine | n8n (Hetzner) | Schon vorhanden, WhatsApp/Mail/Lexware-Integration |
| WhatsApp | 360dialog + Meta Business API | Schon bekannt aus Terminbuchungs-App |
| E-Mail | GMX IMAP/SMTP | Schon eingerichtet aus Mail-Bot-Pilot |
| Rechnungen | Lexware Office Public API | |
| KI | Gemini oder Claude Sonnet | Für Entwurfs-Generierung |
| Hosting | Hetzner VPS | Schon vorhanden |

---

## Aufwand-Schätzung (grob)

| Phase | Inhalt | Wochen |
|---|---|---|
| Phase 1 | Supabase-Schema, Auth, Paar-Datenbank, einfache UI | 2 |
| Phase 2 | WhatsApp-Integration (360dialog + n8n + KI-Entwürfe) | 2 |
| Phase 3 | E-Mail-Integration (bestehender Mail-Bot-Pilot als Basis) | 1 |
| Phase 4 | Lexware-Rechnungs-Automatisierung | 1 bis 2 |
| Phase 5 | Dokumenten-Verwaltung + Drive-Backup | 1 |
| Phase 6 | Testing, Bugfixing, Übergabe an Igor/Maddox | 1 bis 2 |
| **Gesamt** | | **8 bis 10 Wochen** |

Voraussetzung: Vollzeit oder nahezu Vollzeit. Neben anderen Thalor-Projekten realistisch eher 16 bis 20 Wochen.

---

## Offene Fragen vor Start

Diese Punkte müssen vor Baubeginn geklärt sein:

- [ ] Welchen Lexware-Tarif haben die Eltern? (XL nötig für API)
- [ ] Wie läuft Rechnungsstellung aktuell wirklich ab? (Lexware, Steuerberater, manuell?)
- [ ] Welche Nummer soll die WhatsApp-Business-Nummer werden? (bestehende portieren oder neue?)
- [ ] Wer sind die Nutzer des Admin-Hubs? (Maddox, Igor, Eltern, nur einer?)
- [ ] Wie viele aktive Paare gleichzeitig typischerweise? (Dimensionierung)
- [ ] Gibt es schon eine Google-Drive-Ordnerstruktur die wir respektieren sollen?
- [ ] Welches Budget stellen die Eltern bereit? (laufende Kosten ca. 150 bis 250 EUR/Monat: Supabase, 360dialog, Hetzner, LLM)

---

## Monatliche Betriebskosten (Schätzung)

| Service | Kosten |
|---|---|
| 360dialog WhatsApp | ca. 50 EUR plus Nachrichten-Kosten |
| Supabase Pro | 25 USD |
| Hetzner VPS (schon vorhanden) | 0 EUR zusätzlich |
| LLM (Gemini Free oder Claude API) | 5 bis 20 EUR je nach Volumen |
| Domain/SSL (falls eigene) | 1 bis 2 EUR |
| **Gesamt** | **ca. 90 bis 120 EUR pro Monat** |

---

## Referenzen

- Hauptprojekt: [[heiraten-daenemark]]
- Mail-Bot-Pilot (Baustein für E-Mail-Komponente): [[email-assistent-konzept]]
- Lexware API Wissen: [[02-wissen/lexware/api-uebersicht]]
