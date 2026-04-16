---
typ: log
projekt: "[[food-scanner]]"
datum: 2026-04-14
art: entscheidung
vertrauen: extrahiert
quelle: voice_dump
werkzeuge: ["supabase"]
---

Deniz bringt zentrale Einsicht via Voice-Dump: **Cross-DB Borrowing und User-Retrieval nutzen dieselbe Matching-Infrastruktur.** Wenn Vector-Similarity für das eine benutzt wird, muss es auch für das andere validiert sein - sonst passiert der zweite DB-Reset (wie beim letzten Borrowing-Crash).

## Decision

- **Matching-System wird zuerst gebaut** - vor Borrowing, vor User-Retrieval-Optimierung
- **Borrowing-Hierarchie:** Cross-DB (Stufe 1) → Median (Stufe 2) → LLM-Imputation optional (Stufe 3) → NULL (Stufe 4)
- **LLM-Imputation ist offene Entscheidung** - bleibt im Doc markiert bis Deniz sie trifft
- **Kategorisch-sichere Borrowing-Policy** ist Pflicht, inkl. Unsafe-Liste (plant_based_alternatives, supplements, fortified cereals, sugar-free Varianten)

## Action

- Master-Plan "Roadmap Nutrient DB" in Docs-DB angelegt
- Reihenfolge korrigiert: Matching-System (Phase 1) vor Borrowing (Phase 3) vor User-Retrieval-Benchmark (Phase 4)
- Offene Entscheidungen mit Deniz klären: LLM-Imputation ja/nein, Similarity-Threshold, Provenance-Granularität
