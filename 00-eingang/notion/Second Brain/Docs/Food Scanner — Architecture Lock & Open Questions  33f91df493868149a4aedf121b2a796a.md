# Food Scanner — Architecture Lock & Open Questions (V5.1 pending)

Created: 11. April 2026 18:05
Doc ID: DOC-46
Doc Type: Architecture
Gelöscht: No
Last Edited: 11. April 2026 18:05
Last Reviewed: 11. April 2026
Lifecycle: Active
Notes: Continuity-Bridge nach 5 Recherche-Läufen. V5.1 Ergebnisse stehen aus, danach Code-Build. Doc ist bewusst so geschrieben dass ein neuer Chat ohne Vorkontext weiterarbeiten kann.
Pattern Tags: Enrichment
Project: coralate (../Projects/coralate%2033c91df49386813fa411f4c4e931d51f.md)
Stability: Volatile
Stack: Supabase
Verified: No

# Status

**Phase:** Architektur final, Build pending V5.1 Research

**Letztes Update:** 2026-04-11

**Continuity-Bridge:** Ja — dieses Doc ist bewusst so geschrieben dass ein neuer Chat ohne Vorkontext sofort weiterarbeiten kann

# Stack (festgezogen, immutable bis explizite Re-Approval)

| Komponente | Wahl | Begründung |
| --- | --- | --- |
| Vision | GPT-4o (OpenAI direkt) | Einziges Modell mit Strict JSON Schema + logprobs in einer API. January AI Benchmark: 74,11 Score, Macro WMAPE 23,5% (Gemini 2.5 Flash nur 60,65 / 38,5%). Vision-Penalty bei Gemini: 56% Schema-Bruch bei Bild-Inputs. |
| Nutrition DB | pgvector in Supabase mit BLS 4.0 + CIQUAL + USDA + internationale | Open Data, lizenzfrei seit Dez 2025 (BLS), keine externe API-Vertragsbindung, DSGVO sauber, Provider-agnostisch, Cost minimal |
| Orchestrierung | Supabase Edge Function `food-scanner` (Deno) | Co-Location mit DB, Streaming JSON Parsing möglich, gleicher Stack wie cora-engine |
| Quality Gate | Logprob-Score + Cosine-Similarity, deterministisch | Self-Reported Confidence ist Theater (mittlere Differenz korrekt vs falsch nur 5,4%), Logprobs sind mathematisch kalibrierbar |
| Eskalation | Gemini 2.5 Flash (anderes Modell als Stufe 1) | Cost-optimiert, dekorrelierter Failure-Mode, darf NUR Such-Strings reformulieren — NIE Nährwerte erfinden |
| Storage | Supabase Storage Bucket `food-scans` | Frontend lädt hoch, Edge Function holt via Pfad, persistent für Cache + Re-Processing |
| Korrektur-Loop | pgvector Semantic Cache + Few-Shot RAG | Kein Fine-Tuning, sofort skalierbar, User-bestätigte Scans werden Cache-Einträge |

# 4-Stufen-Pipeline

## Stufe 1 — Vision (GPT-4o)

Foto + Geo + Tageszeit + User-History rein. Strict JSON Schema mit Zutaten-Array (`name_de`, `name_en`, `estimated_grams`, `cooking_method`, `region_hint`). `logprobs: true` aktiviert. **KEIN Confidence-Feld im Schema** — das ist Theater. Confidence wird im Backend aus Logprobs berechnet.

## Stufe 2 — pgvector Lookup

Pro Zutat: Embedding via OpenAI text-embedding-3-small → Cosine-Similarity-Suche in `nutrition_db` Tabelle → Top-3 Treffer mit Distanz-Score. Alle DBs (BLS, CIQUAL, USDA, international) liegen im selben Vektorraum mit `source` Metadata-Flag. **Geo wird NICHT als Filter verwendet** — nur als Soft Re-Ranking bei gleichwertigen Treffern.

## Stufe 3 — Quality Gate (deterministisch)

Pro Zutat: Logprob-Score über Schwellwert UND Cosine-Similarity > 0.85? → clean. Sonst → Stufe 4. Multi-dimensionales Gate, kein einzelner Trigger.

## Stufe 4 — Eskalation (Gemini 2.5 Flash, nur bei Bedarf)

Bekommt: Original-Foto + unsichere Zutaten + Top-3 DB-Kandidaten pro unsicherer Zutat. Aufgabe: Besseren DB-Kandidaten wählen ODER alternativen Such-String vorschlagen für 2. pgvector-Run. **Erfindet niemals Nährwerte.**

## Aggregation und DB-Insert

`food_entries` Insert mit Layer A (Cora-eligible Makros als Spalten) + Layer B (Storage-only JSONB für Mikros + Provenance + Vision-Metadata).

# Datenbanken (V5.1 klärt Details)

- **BLS 4.0** (Deutschland, MRI) — 7.140 Lebensmittel, 138 Nährstoffe, seit Dez 2025 lizenzfrei — deutsche Mischgerichte, vegetarische Alternativprodukte
- **CIQUAL** (Frankreich, ANSES) — ~3.484 Einträge, Open Data — westeuropäische Konsumgewohnheiten, detaillierte Fettsäurenprofile
- **USDA FoodData Central** (USA) — sehr groß, US-zentriert — Fallback für Roh-Zutaten und international
- **Internationale Erweiterung** — V5.1 klärt was für polnisch, marokkanisch, türkisch, asiatisch, etc.

# Hard Constraints (von Deniz, immutable)

1. **Qualität > Latenz > Cost** — wir bauen den **besten** Scanner für Denizs Profil, nicht den schnellsten oder billigsten
2. **Geo/Time/History als Soft Hints, NIE Hard Filter** — User in Berlin kann Sushi essen, User in Marrakesch Schnitzel
3. **Internationale DB-Coverage Pflicht** — nicht nur EU-zentriert
4. **DSGVO Position 3** — Pre-Launch egal, später härter, Architektur provider-agnostisch für späteren EU-only Switch
5. **Mikronährstoffe Pflicht** — 14 Felder (Vit A/C/B12/D/E/K/B6/Folate, Ca/Fe/K/Mg/Zn/P)
6. **Hauptfokus selbstgekochte + Restaurant-Mischgerichte** — nicht Barcode/verpackt als Primärpfad
7. **Live-Deployment Ziel** — HTML Test-Tool greift auf echte Edge Function zu, kein Mock

# Verworfene Alternativen (mit Begründung)

- **FatSecret Premier Free** — Free-Tier nur US-Datasets, EU-Coverage erst in Enterprise Premier ($500-2000+/Monat). Mein ursprünglicher Vorschlag, durch Denizs Pricing-Page-Screenshot widerlegt.
- **Edamam Standard** — DSGVO unklar, V3 konnte Privacy Policy nicht abrufen, kommerzielle Vertragsbindung nicht nötig wenn pgvector reicht
- **Reines GPT-4o ohne DB** — Macro WMAPE 23,5% ist Consumer-Niveau aber nicht klinisch, plus keine deterministischen Mikros
- **Azure OpenAI** — Microsoft-Access-Wartezeit blockiert Pre-Launch, OpenAI direkt schneller startklar, später migrierbar wenn DSGVO härter wird
- **Self-Reported Confidence im JSON Schema** — mittlere Differenz korrekt vs falsch nur 5,4% (Studie mit 1.900 biomedizinischen Fragen), Logprobs sind mathematisch fundiert
- **Gemini 2.5 Flash für Stufe 1** — 56% Schema-Bruch bei Vision-Inputs, Macro WMAPE 38,5%
- **n8n als Orchestrierung** — 60s Timeout, kein Co-Location mit Supabase

# Offene Fragen V5.1

1. **Schema-Realität BLS/CIQUAL/USDA** — konkrete Spalten, Mikros-Mapping, Portions-Definitionen, Mehrsprachigkeit
2. **Logprob-Mechanik** bei Strict JSON Schema — Aggregation pro Item, Schwellwert-Kalibrierung, Code-Beispiele
3. **Embedding-Modell** für mehrsprachige Food-Suche — text-embedding-3-small vs Alternativen, Index-Strategie
4. **API-Fallback Notwendigkeit** — reicht pgvector wirklich oder brauchen wir Edamam/OFF für Lifecycle-Coverage
5. **Geo als Soft Hint** — Prompt-Patterns, Bias-Amplifikation Failure-Modes
6. **Internationale DB-Coverage** — polnisch, türkisch, marokkanisch, asiatisch — was existiert als Open Data

# Nächste Schritte

1. V5.1 Research-Ergebnisse abwarten
2. Cross-Check der Reports (wie bei V3 und V4)
3. Konsolidierte Architektur-Empfehlung mit Konfidenz-Levels
4. **Dann erst Build:**
    1. SQL Migration (`food_entries` Erweiterung, `food_scan_cache`, `nutrition_db` mit pgvector)
    2. Daten-Import-Script (Python, einmaliger Lauf für BLS+CIQUAL+USDA+international Embeddings)
    3. Edge Function `food-scanner` (TypeScript/Deno, 4 Stufen, Streaming, Logprobs, pgvector-Lookup)
    4. HTML Test-Tool (single file, mobile-optimiert, Kamera-Zugriff, Multi-Image, Logging-Anzeige, manueller Fallback, Korrektur-Buttons, Bild-Anzeige mit Nährwerten wie in App)
    5. Deployment Guide (Schritt für Schritt, mobile-lesbar)

# Setup-Anforderungen für Deniz (vor Build)

- **OpenAI API Key** — hat Deniz schon, wird als `OPENAI_API_KEY` Secret in Supabase
- **BLS 4.0 Download** von [blsdb.de](http://blsdb.de) (kostenlos seit Dez 2025)
- **CIQUAL Download** von [ciqual.anses.fr](http://ciqual.anses.fr)
- **USDA FDC Download** von [fdc.nal.usda.gov](http://fdc.nal.usda.gov)
- **pgvector Extension** in Supabase aktivieren (Dashboard → Database → Extensions)
- **Storage Bucket** `food-scans` anlegen (Dashboard → Storage)

# Meta-Regeln für Claude in dieser Session

1. **Plan-and-Execute strikt** — nichts ohne explizite Freigabe von Deniz, auch keine Migrations
2. **Qualität schlägt alles** — wenn ein zweiter API-Call die Accuracy hebt, machen wir ihn
3. **Live-Deployment-Ziel** — produktionsreifer Code, kein Throwaway
4. **Proaktive Architektur-Review-Pflicht** — bei Hybrid-Systemen mit Soft Signals immer den Failure-Mode "Kontext widerspricht visueller Realität" durchdenken (Lesson aus dem Geo-als-Hard-Filter Bug)
5. **Reports vollständig lesen, nicht zusammenfassen** — GitHub-Repos und spezialisierte Modelle (FoodyLLM, FoodOntoRAG, SwissFKG) nicht verlieren
6. **Bei Unsicherheit Research statt Raten** — lieber V6 als später Refactor

# Bisherige Recherche-Läufe

- **V1** — Marktanalyse aller Anbieter → Edamam empfohlen (zu breiter Fokus, korrigiert)
- **V2** — Decoupled Stack → GPT-4o + FatSecret + Edge Function (4 Widersprüche zu V1)
- **V3** — Verifizierung der 4 Widersprüche → January AI Benchmark existiert, GPT-4o klar besser, FatSecret EU-Hosting Nein, Edamam DSGVO unklar, Gemini 3.1 Pro existiert
- **V4** — Hybrid Pipeline Validierung → BLS 4.0 lizenzfrei (Game-Changer), Logprobs statt Self-Confidence, pgvector bestätigt, Streaming JSON Parsing, Cost-Empfehlung GPT-4o-mini für Stufe 1
- **V5.1** — Tiefenklärung mit 6 Fragen (läuft, Ergebnisse stehen aus)