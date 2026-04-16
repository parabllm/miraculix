---
typ: log
projekt: "[[herosoftware]]"
datum: 2026-03-26
art: fortschritt
vertrauen: extrahiert
quelle: chat_session
werkzeuge: ["clay", "attio", "apollo"]
---

Clay-Enrichment-Layer gebaut. Chat "Clay Hero" (510 Messages, 1.1M chars). Folge-Chat "Clay Hero 2" (2026-03-30, 169 Messages, 525k chars) adjustiert Details.

## Setup

- **2 Templates live:** Executive Leadership, Churns
- Pro Attio-Liste eigenes Template (gleiche Struktur, andere Source)
- **Clay nur für "Outbound Ready" Leads** (Token-Budget-Restriktion)
- Enrichment via Apollo, BetterContact, Claygent

## LGM-Mapping

LGM-Events (Replies, Clicks, Conversions) schreiben zurück nach Attio als Notes/Tasks. Attio-Liste = LGM-Sequence - Robin sortiert manuell in Listen, Scripts routen in die richtigen LGM-Audiences.

## Kritische Pattern aus Clay Hero 2

- **Attio hatte Duplikate** - 6 verschiedene Quellen erstellten Companies (Email-Sync, Robin, Calvin, Claude, WF1, WF4)
- **Goldene Regel:** 1 Mantle-Profil = 1 Attio-Company
- **Reihenfolge:** Duplikat-Finder → Aufräumen → Name-Matching
- **Matching-Kette 4 Stufen** mit Duplikat-Check bei jeder Stufe

## Quelle

Claude-Chat "Clay Hero" 2026-03-26 + "Clay Hero 2" 2026-03-30.
