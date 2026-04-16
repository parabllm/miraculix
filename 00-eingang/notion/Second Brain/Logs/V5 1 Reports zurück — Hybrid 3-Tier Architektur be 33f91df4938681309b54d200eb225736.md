# V5.1 Reports zurück — Hybrid 3-Tier Architektur bestätigt, Geo via RRF

Areas: coralate
Confidence: Confirmed
Created: 11. April 2026 18:16
Date: 11. April 2026
Gelöscht: No
Log ID: LG-3
Project: coralate (../Projects/coralate%2033c91df49386813fa411f4c4e931d51f.md)
Source: Manual
Type: Decision

Beide Reports (Perplexity Text + Gemini PDF) sind durch. Kernergebnis ist eindeutig und korrigiert unseren Stack an einer Stelle.

## Frage 5 (Geo als Soft Hint)

Beide Reports einig: ungefilterte Vektorsuche + Reciprocal Rank Fusion (RRF, k=60) als Soft Re-Ranking. Geo nur Tiebreaker bei semantischem Gleichstand. XML-getaggter Prompt mit ThinkFirst-Pattern (erst Bild verbalisieren, dann Kontext). Studie: 93% Fehlerrate bei Emotion-Recognition wenn MLLMs Kontext über Bildevidenz priorisierten — genau das Sushi-in-Berlin Worry empirisch belegt.

## Frage 6 (Internationale Coverage) — ARCHITEKTUR-KORREKTUR

Unser bisheriger Plan war "API-frei via pure pgvector". Beide V5.1 Reports sagen eindeutig: **reicht nicht** für globale Food-Diversität. 

**Neue Architektur: 3-Tier Hybrid (Gemini-Modell):**

- Tier 1 (pgvector lokal mit Open-Data DBs): 80-90% der Scans
- Tier 2 (Commercial API Fallback): FatSecret/Edamam für Markenprodukte und Lookups bei Tier 1 Miss
- Tier 3 (GPT-4o Synthesis + User Feedback Flywheel): Long-Tail, User-bestätigte Einträge wandern in Tier 1 zurück

## Neue DB-Quellen aus V5.1

BLS 4.0 (DE), CIQUAL (FR), USDA, CoFID (UK), NEVO (NL), FRIDA (DK), Fineli (FI), BEDCA (ES), CREA (IT), STFCJ (JP), IFCT/INDB (IN), Thai FCD (TH), TürKomp (TR), Marokko FCT, Pellett & Shadarevian (Mittlerer Osten). EU FCDB von EFSA Mitte 2026 — später integrieren.

## Tools die in unsere Pipeline müssen

- NutrienTrackeR (R-Package): USDA+CIQUAL+BEDCA+CNF+STFCJ bereits harmonisiert — Import-Vorlage
- OpenNutrition (GitHub): 300k Items aggregiert
- Stance4Health Unified FCDB: 2.648 unified foods, 880 Komponenten aus 10 EU-DBs
- Bognár-Faktoren für Kochverluste/Yield bei synthetischer Rezeptberechnung
- Open Food Facts Smart Aggregation (2026 Update): trennt Hersteller-Daten von Schätzungen

## Status

Stack final mit Korrektur. Doc wird jetzt erweitert. Danach Build-Phase startet (Migration, Daten-Import, Edge Function, HTML Test-Tool).