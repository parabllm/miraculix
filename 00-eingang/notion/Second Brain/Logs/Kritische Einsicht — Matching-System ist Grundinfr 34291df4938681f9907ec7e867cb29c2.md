# Kritische Einsicht — Matching-System ist Grundinfrastruktur für Backfill, Borrowing und Retrieval

Areas: coralate
Confidence: User-stated
Created: 14. April 2026 15:32
Date: 14. April 2026
Gelöscht: No
Log ID: LG-17
Project: coralate (../Projects/coralate%2033c91df49386813fa411f4c4e931d51f.md)
Source: Voice dump
Summary: Deniz bringt kritische Einsicht: Cross-DB Borrowing und User-Retrieval nutzen dieselbe Matching-Infrastruktur. Konsequenz: Matching-System muss zuerst gebaut werden, bevor Backfill oder Borrowing. Master-Plan in Docs DB angelegt.
Tools: Supabase
Type: Decision

## Voice-Input (woertlich, 14.04.2026)

> Also, was Du aber auch verstehen musst und das ist auch kritisch und wenn Du das verstanden hast, muessen wir es irgendwo mal aufschreiben. Der Backfill fuer die Nutrients ist ja an ein systematisches gebunden. Weil wenn wir zum Beispiel, wie gesagt Avocado Oil nicht mit Micros gefuellt haben, wo kriegen wir beim Backfill die Daten fuer die her? Sagst Du, wir machen fuer alle fehlenden Felder einen AI Call? Weisst Du was ich mein, wenn wir fuer alle fehlenden Felder einen AI Call machen. Dann in Zukunft machen wir auch alle fehlenden Nutrients, wenn sie fehlen, einen AI Call, oder sagst Du, wir nehmen wirklich Cross-Datenbank-Borrowing und holen uns die Daten von echten anderen Datenbanken die wir drin haben. Ist naemlich eine wichtige Frage, weil wenn wir das ueber die AI machen, muessen wir den Backfill zuerst machen, klar. Wenn wir aber Cross-Datenbank-Borrowing machen, muessen wir sichergehen, dass unser Borrowing stimmt. Und das was stimmt, funktioniert hier uebers gleiche System, wie wir die Nutrients auch im First finden. Lass mich bitte verbessern, sobald ich was falsch hab, aber ja.
> 

## Konsequenz fuer den Plan

Deniz bringt die zentrale Einsicht: Das Matching-System fuer Cross-DB Borrowing ist **dieselbe Infrastruktur** wie das User-Retrieval-Matching. Wenn wir Vector-Similarity fuer das eine nutzen, muessen wir es auch fuer das andere validieren — sonst passiert der zweite DB-Reset (wie beim letzten Borrowing-Crash).

## Decision

- **Matching-System wird zuerst gebaut** (bevor Borrowing, bevor User-Retrieval-Optimierung)
- **Borrowing-Hierarchie:** Cross-DB (Stufe 1) in Median (Stufe 2) in LLM-Imputation optional (Stufe 3) in NULL (Stufe 4)
- **LLM-Imputation ist offene Entscheidung** — bleibt im Doc markiert bis Deniz sie trifft
- **Kategorisch-sichere Borrowing-Policy** ist Pflicht, inkl. Unsafe-Liste fuer problematische Kategorien (plant_based_alternatives, supplements, fortified cereals, sugar-free Varianten)

## Action

- Master-Plan in Docs DB angelegt: "Roadmap Nutrient DB"
- Reihenfolge im Plan korrigiert: Matching-System (Phase 1) vor Borrowing (Phase 3) vor User-Retrieval-Benchmark (Phase 4)
- Naechster Schritt: offene Entscheidungen mit Deniz klaeren (LLM-Imputation ja/nein, Similarity-Threshold, Provenance-Granularitaet)