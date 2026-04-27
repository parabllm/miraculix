---
typ: sub-projekt
name: "Heiraten in Dänemark"
aliase: ["Heiraten in Dänemark", "HiD", "Heiratsagentur Yakymenskyy"]
ueber_projekt: "[[thalor]]"
bereich: kontext
umfang: offen
status: scouting
kapazitaets_last: niedrig
kontakte: ["[[maddox-yakymenskyy]]"]
tech_stack: ["n8n", "gmx-imap", "gmx-smtp", "anthropic-claude", "telegram"]
erstellt: 2026-04-21
notizen: |-
  Zweites Familienunternehmen der Yakymenskyys parallel zu BellaVie. Heiratsagentur für internationale Paare, die in Dänemark heiraten wollen. Maddox ist hier wie bei BellaVie im Management. Aktuell kein Thalor-Auftrag, nur Kontext für spätere Zusammenarbeit.
quelle: gespräch_maddox_2026-04-21
vertrauen: extrahiert
---

## Kontext

Zweites Familienunternehmen der Yakymenskyys, parallel zum [[bellavie]]-Salon. **Heiratsagentur** die internationale und binationale Paare bei der Eheschließung in Dänemark begleitet.

- **Auftraggeber:** keiner, kein Thalor-Auftrag aktuell
- **Rolle Maddox:** Management-Funktion, analog zu BellaVie ([[maddox-yakymenskyy]])
- **Zweck dieses Files:** Kontext-Anker für zukünftige Gespräche und potenzielle Thalor-Zusammenarbeit

## Nische

Heiratsagenturen begleiten ausländische Paare, die in Dänemark standesamtlich heiraten wollen. Rechtlicher Kern: der Antrag läuft beim dänischen **Familieretshuset** (Agentur für Familienrecht). Agenturen übernehmen per Vollmacht (11b-Erklärung) Dokumentenprüfung, Antragstellung und Terminreservierung beim Standesamt.

**USP gegenüber Deutschland:**
- Dänemark verlangt deutlich weniger Dokumente als deutsche Standesämter
- Bearbeitungszeit durch Familieretshuset regulär 5 Arbeitstage, mit Agentur oft 2 bis 10 Tage
- Express-Pakete bringen Trauung ca. 7 bis 14 Tage nach AFL-Genehmigung
- Deutsche Wartezeiten bis 9 Monate in Großstädten

**Zielgruppen:**
- Binationale Paare mit Nicht-EU-Partner (Visa-Thema)
- Paare mit komplizierten Personenstandsnachweisen (Scheidung, Witwer-Status)
- Paare in Großstädten mit langen deutschen Wartelisten
- Gleichgeschlechtliche Paare

**Marktpreise (Recherche 2026-04-21):**
- Full-Service-Begleitung: 1.300 bis 1.650 EUR pro Paar
- Express-Pakete zusätzlich als Upsell

**Wettbewerber (nicht vollständig, nur Marktbild):**
Bossens Heiratsagentur, Heiratsagentur Karina, Konstannta Berlin, GMiD / gettingmarriedindenmark.com, Wedding Planner Denmark, Nordic Adventure Weddings, heiraten.dk. Markt fragmentiert, viele kleine Player mit deutschsprachiger Zielgruppe.

quelle: web_search 2026-04-21, vertrauen: extrahiert

## Aktueller Stand

Stand 2026-04-21, Cafe-Session mit Maddox ([[2026-04-21-maddox-cafe-session]]):

- File-Ablage läuft aktuell über **Dropbox**
- Maddox erwägt Switch auf **Google Drive**
- Entscheidung offen, kein Trigger zum Handeln
- **Kundenmails:** laufen über GMX-Postfach, werden aktuell manuell von **[[igor-puzynya|Igor]]** beantwortet. Qualität schwankt. Bedarf an Automatisierung.
- **MVP entschieden:** n8n-basierter E-Mail-Assistent mit Claude-Entwurf und Telegram-Freigabe (siehe [[email-assistent-konzept]] und [[2026-04-21-maddox-email-assistent]]).

## Offene Aufgaben

- [x] E-Mail-Assistent MVP-Pilot bauen und validieren (Stand 2026-04-21) ✓
    - [x] GMX IMAP/SMTP freischalten plus anwendungsspezifisches Passwort
    - [x] Telegram Bot plus Chat-ID besorgen
    - [x] Wissensbasis-Text als Platzhalter (echte Inhalte offen, siehe unten)
    - [x] Workflow A (Mail-eingegangen) in n8n gebaut
    - [x] Workflow B (Telegram-Callback) teilweise gebaut, Senden-Zweig bis Parse-Node
    - [x] Funktionale Validierung: Gemini-Entwürfe kommen, Telegram-Buttons funktionieren
    - Details siehe [[email-assistent-konzept]]
- [ ] **Entscheidung Admin-Hub vs. Mail-Bot-Produktion** (siehe unten bei Mögliche Touchpoints). Blockiert alle weiteren Bau-Schritte.
- [ ] Echte Wissensbasis von Maddox und Igor einsammeln, falls Mail-Bot weitergeht #niedrig
    - [ ] Tonalität, Pakete, Standardablauf, No-Gos
    - [ ] Top 10 Kundenfragen aus Igor-Postfach

## Mögliche Touchpoints mit Thalor (hypothetisch)

**Admin-Hub als Gesamtlösung (Brainstorm mit Maddox am 2026-04-21)**

Idee: ein zentrales Web-Dashboard für Heiraten in Dänemark, das die drei täglichen Hauptprozesse zusammenzieht. Entstanden als Überlegung "was wäre wenn wir das alles an einem Ort hätten".

Komponenten (hypothetisch, nicht beauftragt):
- Mail-Review-Interface als Web-UI statt Telegram (Mail kommt rein, KI macht Entwurf, Bearbeiter sieht und klickt)
- Kundendatenbank für die Paar-Pipeline (Anfrage, Dokumentenstand, Termin, Rechnungsstatus)
- Rechnungs-Automatisierung über Lexware Office Public API (Rechnung erzeugen, als PDF generieren, als E-Rechnung versenden)
- Dokumenten-Checklisten und Paar-Onboarding-Flow

Technik hypothetisch: Next.js Frontend, Supabase als Backend und Kundendatenbank, n8n für Workflow-Orchestrierung, LLM (Gemini oder Claude), Lexware Public API, GMX IMAP/SMTP. Grob-Aufwand bei solidem Scope 6 bis 8 Wochen Vollzeit, realistisch 12+ Wochen neben anderen Thalor-Projekten.

**Status:** reiner Brainstorm. Kein Auftrag, kein commit, keine Eltern-Abstimmung. Erst weiterverfolgen wenn Maddox konkret mit Auftragsinteresse kommt. _vertrauen: angenommen, quelle: maddox-session_2026-04-21_

**Kritischer Punkt:** Rechnungsprozess bei Heiraten in Dänemark ist ungeklärt. Möglich dass er über Steuerberater oder anders läuft. Muss vor jeder Architektur-Entscheidung geklärt werden. Bis dahin ist Lexware-Integration nur Platzhalter.

---

**Einzel-Touchpoints (aus früherer Überlegung)**

- Website-Relaunch analog [[bellavie]]
- Lokale oder internationale SEO für "Heiraten in Dänemark" Keywords
- CRM-Aufbau für Paar-Pipeline (Anfrage bis Trauungstermin)
- Automatisierung Dokumenten-Checkliste und Paar-Onboarding
- File-Ablage-Struktur bei Drive-Migration

_Keine Bestätigung durch Maddox, nur eigene Ableitung aus bekannten Patterns (siehe [[bellavie]]). vertrauen: angenommen._

## Out of Scope

- Rechtsberatung Eheschließung
- Familienzusammenführung, Visa-Beratung

## Kontakte

- [[maddox-yakymenskyy]] - Management-Kontakt, analog Rolle bei [[bellavie]]
- [[igor-puzynya]] - aktueller Mail-Bearbeiter, Familienfreund der Yakymenskyys.
