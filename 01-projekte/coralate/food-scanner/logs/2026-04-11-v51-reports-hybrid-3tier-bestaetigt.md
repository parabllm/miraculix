---
typ: log
projekt: "[[food-scanner]]"
datum: 2026-04-11
art: entscheidung
vertrauen: bestaetigt
quelle: manuell
werkzeuge: []
---

V5.1-Reports (Perplexity + Gemini PDF) durch. **Architektur-Korrektur:** Pure pgvector reicht NICHT für globale Food-Diversität.

## Neue Architektur: 3-Tier Hybrid

- **Tier 1** - pgvector lokal mit Open-Data-DBs: 80-90% der Scans
- **Tier 2** - Commercial API Fallback (FatSecret/Edamam) für Markenprodukte + Tier-1-Miss
- **Tier 3** - GPT-4o Synthesis + User-Feedback-Flywheel. Long-Tail, User-bestätigte Einträge wandern nach Tier 1

## Geo als Soft Hint - bestätigt

Beide Reports einig: ungefilterte Vektorsuche + Reciprocal Rank Fusion (RRF, k=60) als Soft Re-Ranking. Geo nur Tiebreaker bei semantischem Gleichstand. XML-getaggter Prompt mit ThinkFirst-Pattern (erst Bild verbalisieren, dann Kontext). Studie: 93% Fehlerrate bei Emotion-Recognition wenn MLLMs Kontext über Bildevidenz priorisierten - belegt das Sushi-in-Berlin-Worry empirisch.

## DB-Quellen aus V5.1

BLS 4.0 (DE), CIQUAL (FR), USDA, CoFID (UK), NEVO (NL), FRIDA (DK), Fineli (FI), BEDCA (ES), CREA (IT), STFCJ (JP), IFCT/INDB (IN), Thai FCD (TH), TürKomp (TR), Marokko FCT, Pellett & Shadarevian (Mittlerer Osten).

## Integrations-Kandidaten

- NutrienTrackeR (R): USDA+CIQUAL+BEDCA+CNF+STFCJ bereits harmonisiert
- OpenNutrition (GitHub): 300k Items aggregiert
- Stance4Health Unified FCDB: 2.648 unified foods, 880 Komponenten aus 10 EU-DBs
- Bognár-Faktoren für Kochverluste
- Open Food Facts Smart Aggregation 2026
