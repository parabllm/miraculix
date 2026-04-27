---
typ: meeting
projekt: "[[heiraten-daenemark]]"
datum: 2026-04-21
teilnehmer: ["[[maddox-yakymenskyy]]"]
ist_transkript: false
zusammenfassung: |-
  Im Rahmen der Cafe-Session ist das Thema E-Mail-Bearbeitung bei Heiraten in Dänemark aufgekommen. Aktuell beantwortet Igor die Kundenmails über GMX, die Qualität leidet. Entscheidung: MVP für einen n8n-basierten E-Mail-Assistenten bauen mit Claude-Entwurf plus Telegram-Freigabe.
offene_punkte: ["MVP E-Mail-Assistent umsetzen (Konzept liegt vor)"]
quelle: gespräch_cafe_mannheim
vertrauen: extrahiert
---

## Kontext

Teil der Cafe-Session 12:00 bis 20:00 in Mannheim. Haupt-Themen der Session waren Bachelorarbeit-Framework, Spanien 02. bis 12.08. und Strategie post-Studium. Zusätzlich zu diesen Themen ist der Bedarf an einer besseren E-Mail-Bearbeitung bei Heiraten in Dänemark aufgekommen.

## Ergebnis

- Kundenmails landen aktuell im GMX-Postfach von Heiraten in Dänemark
- [[igor-puzynya|Igor]] beantwortet sie aktuell manuell, Qualität ist nicht konstant
- Entscheidung: Automations-MVP auf n8n bauen mit Human-in-the-Loop via Telegram
- Keine Mail geht raus ohne Freigabe von Deniz per Telegram-Button
- Konzept liegt vor: [[email-assistent-konzept]]

## Next Steps

- Deniz holt Zugänge: GMX IMAP/SMTP freischalten, Anthropic API-Key, Telegram Bot anlegen
- Wissensbasis-Text für Claude vorbereiten (Tonalität, Pakete, Standardablauf, No-Gos)
- n8n-Workflows A (Mail eingegangen) und B (Telegram Callback) bauen
- Testlauf mit Dry-Run (Entwürfe in GMX ablegen, nicht versenden) vor Go-Live

## Offene Fragen an Maddox und Igor

- Wer aus der Familie darf mitlesen und mit-freigeben?
- Sollen Entwürfe stilistisch an Igors bisherige Signatur angelehnt werden oder neu aufgesetzt?
- Gibt es bestehende FAQ-Dokumente oder Mail-Templates die in die Wissensbasis einfliessen?
