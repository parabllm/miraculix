# Food Scanner Master — Stack, DB-Harmonisierung, Build-Plan

Created: 11. April 2026 21:10
Doc ID: DOC-47
Doc Type: Architecture
Gelöscht: No
Last Edited: 11. April 2026 22:44
Last Reviewed: 11. April 2026
Lifecycle: Active
Notes: Aktiver Stand 2026-04-11 Abend. INFOODS-Harmonisierung, EINE nutrition_db Tabelle, 7 DBs hochgeladen, Edamam raus, OFF via API+Stream, neuer Chat für Schema-Extraktion pending.
Pattern Tags: Enrichment
Project: coralate (../Projects/coralate%2033c91df49386813fa411f4c4e931d51f.md)
Stability: Volatile
Stack: Supabase
Verified: Yes

# Status

**Phase:** Roh-Datensondierung 7 DBs abgeschlossen, drei harte Befunde, Hard-Constraint Fragen geklärt, A.3 Unified Schema pending

**Letztes Update:** 2026-04-11 Spätabend (siehe Log Phase A.1+A.2)

# DB-Sondierung Befunde (Phase A.1+A.2 — 2026-04-11)

**Drei harte Befunde aus bash_tool Sondierung:**

1. **TürKomp ZIP enthält Frida 5.5 (Dänemark)**, NICHT TürKomp. 1.385 Foods × 234 Komponenten, dänische Spaltennamen, gute Vit-K-Coverage inkl. MK4-MK10. Frida bleibt als Bonus-Quelle 8 drin, ist aber KEIN Türkei-Ersatz. **Türkei muss Deniz von [turkomp.gov.tr](http://turkomp.gov.tr) neu runterladen.**
2. **STFCJ xlsx ist nur ein Annex-Sheet** mit 642 wissenschaftlichen Pflanzennamen, KEINE Nährwerte. Unbrauchbar als FCD. **Japan muss Deniz von [mext.go.jp](http://mext.go.jp) Standard Tables 8th rev. neu runterladen.**
3. **CIQUAL ZIP enthält nur XML**, keine xlsx wie in der Doku beschrieben. Import-Branch nutzt lxml.etree statt openpyxl, ~30 Min Mehraufwand.

**INFOODS-Verfügbarkeit pro DB (korrigiert):**

- BLS: ✅ INFOODS-nativ als Spaltenpräfix (ENERCJ, PROT625, FAT, CHO, FIBT, RETOL, CARTB, VITD, THIA, TOCPHA…) — 138 Komponenten, trivial zu mappen
- CIQUAL: ✅ INFOODS via const_xml code_INFOODS Lookup — 74 Komponenten
- USDA Foundation/SR: ❌ eigene nutrient_id (1003=Protein…), 475 Nutrients, manuelles Lookup ~60 Zeilen
- CoFID: ❌ englische Klartext-Namen über 8 Sheets verteilt, Sheet-Join über Food Code
- NEVO: ❌ holländisch+englisch, separates Header-CSV als Lookup
- Frida (DK): ❌ dänische Klartext-Namen, manuelles Lookup

**13 statt 14 Pflicht-Mikros — Vit K raus für Phase 1.** Vit K wird im DB-Schema als nullable Optional reserviert für Phase 2, kein Frontend-Display, keine Borrow-Logik. Vit-K-Coverage in den DBs ist zu lückenhaft (CoFID/NEVO/USDA SR oft nur K1 oder gar nichts) — Komplexität für Phase 1 nicht gerechtfertigt.

# OFF-Strategie (final geklärt 2026-04-11)

**Tier 0 Barcode-Flow mit Hard-Match-Threshold:**

- User scannt Barcode → Edge Function ruft OFF Live API
- OFF-Daten als HINT in eigener Tabelle `off_barcodes` (NICHT in nutrition_db direkt — Mikros fehlen bei OFF zu >95%)
- pgvector Match auf nutrition_db mit `product_name + brand` als Query
- Cosine ≥0.85 = Hard Match → **Hybrid-Merge:** Makros aus OFF (echte Marken-Werte, EU 1169/2011 Pflicht), Mikros aus FCD-Match
- 0.70-0.85 = unsicher → OFF-Daten direkt + User-Korrektur-Pflicht
- <0.70 = Vision-Fallback wie ohne Barcode
- Pro Nährstoff-Spalte ein source-Tag für Audit-Trail

# Mengen-Logik (offen — A.3 Klärung pending)

Deniz-Klarstellung 2026-04-11: Beim Barcode-Scan brauchen wir Mengen-Plausibilität — der Barcode liefert nur kcal/100g, nicht die konsumierte Menge. Drei separate Probleme identifiziert:

- **A) Portions-Schätzung des Barcode-Produkts:** Vision schätzt Menge + OFF serving_size Sanity-Check + User-Slider
- **B) Drumherum-Zutaten:** Vision-Modell bekommt Hint "Item X bereits via Barcode identifiziert, identifiziere nur den Rest" → kein Doppel-Counting
- **C) Mengen-Konsistenz Sanity-Check:** sum(item_mengen) ≈ total_volume/mass (±20%), sonst proportional skalieren oder User fragen

**Drei Klärungsfragen offen für nächsten Turn** — siehe Log Phase A.1+A.2.

# Finale Anforderungen Deniz (2026-04-11 Spätabend)

**Qualitäts-Anspruch:** Foodscanner muss saubere evidenzbasierte Antworten liefern, kein Raten. Cross-Validation zwischen mehreren DB-Treffern ist Pflicht: bei geringer Streuung (±10%) gewichteter Median, bei mittlerer (±25%) Geo-Priorisierung, bei hoher (>25%) ambig-Flag + GPT-4o-Synthesis-Eskalation. Vision analysiert Gericht UND einzelne Ingredienzien, beides wird gegen DBs gecheckt.

**Mengen-Doppelcheck Pflicht:** Vision-Schätzung + OFF serving_size Referenz + Volumen-Sanity (Vision schätzt Gefäß-Größe parallel) — sum(item_grams) gegen total_volume, bei >20% Diskrepanz proportional skalieren oder im Tool flaggen.

**HTML Test-Tool = vollständiges Analyse-Webhook (kein simples Test-Frontend):**

Pro Scan sichtbar: Vision-Stage (Items + Mengen + Konfidenz pro Item, Logprobs, Thinking-Tokens, Output/Input-Tokens), Match-Stage (Top-10 DB-Matches mit Cosine-Scores + RRF-Reihenfolge), Provenance pro Nährstoff (welcher Mikro/Makro kam aus welcher Quelle: BLS direct / CIQUAL borrowed / OFF brand / Group-Median / Bognár), Konfidenz-Score aufgeschlüsselt (Vision × Match × Provenance), Performance (Latenz total + pro Stage, Cost-Estimate USD, Token-Breakdown), Final JSON Response. Batch-Modus mit CSV-Export für Offline-Analyse. Korrektur-Buttons feeden user_corrections Tabelle. Mobile-optimiert.

**Logging-Pflicht:** scan_logs + nutrient_provenance Tabellen müssen ALLES tracken — Latenz, Tokens (input/thinking/output), Cost, Provenance pro Nährstoff, Vision-Logprobs, Match-Confidence, User-Korrekturen. Deniz muss jeden Scan im Nachhinein analysieren können.

# Build-Roadmap (4 Sessions)

1. **Session 1 — Supabase Setup:** MCP-Sondierung, pgvector aktivieren, 6 Tabellen via apply_migration, RLS-Policies, Storage Buckets prüfen/anlegen
2. **Session 2 — Import-Pipeline:** Python Scripts für alle 9 Quellen + OFF-Stream, lokal getestet, dann nutrition_db füllen, HNSW Index
3. **Session 3 — Edge Function:** food-scanner Deno deployen, mit echten Test-Bildern gegen DB testen
4. **Session 4 — HTML Analyse-Webhook:** mobile-optimiert, vollständige Debug-Anzeige, Batch-Modus, CSV-Export

# Was Deniz beschaffen muss bevor Session 1 startet

- TürKomp xlsx von [turkomp.gov.tr](http://turkomp.gov.tr) (alle Food-Groups konsolidiert)
- STFCJ Main Tables 8th rev. von [mext.go.jp](http://mext.go.jp) (Chapter 1-18 zusammen)
- Antworten auf 4 offene Fragen (Mengen-Logik a/b/c/d, Vision-Barcode-Hint ja/nein, User-Override Pflicht/optional, Folat-DFE a/b/c)
- Bestätigung Supabase MCP Service-Role-Zugriff aktiv (Project vviutyisqtimicpfqbmi)

**Continuity-Bridge:** Ja — dieses Doc ist die aktive Referenz, alte Version "Architecture Lock & Open Questions" ist **obsolet**.

# Final Stack (immutable)

- **Vision:** GPT-4o (OpenAI direkt) mit Strict JSON Schema + logprobs + XML-getaggtem Prompt + ThinkFirst-Pattern
- **Nutrition DB:** pgvector in Supabase, EINE harmonisierte Tabelle `nutrition_db` mit allen 7+ DBs + OFF-Subset, INFOODS-Codes als Harmonisierungs-Achse
- **Orchestrierung:** Supabase Edge Function `food-scanner` (Deno, EU)
- **Quality Gate:** Logprob-Score + Cosine-Similarity, RRF (k=60) für Geo/Time/History als Soft Re-Ranking
- **Eskalation:** GPT-4o Synthesis mit Bognár-Faktoren + User Feedback Flywheel (Tier 2 Edamam wurde raus, Open Food Facts übernimmt via Live API + CSV-Stream Import)
- **Storage:** Supabase Storage Bucket `food-scans` (User-Uploads) + `raw-nutrition-data` (FCD-Dumps)

# 3-Tier Architektur

1. **Tier 0 — Barcode via OFF Live API** (kostenlos, kein Key)
2. **Tier 1 — Vision + pgvector** (80-90% Coverage)
3. **Tier 2 — SKIPPED** (Edamam raus, OFF CSV-Import in Tier 1)
4. **Tier 3 — GPT-4o Synthesis + Feedback Flywheel** (Long-Tail)

# INFOODS-Codes als Harmonisierungs-Achse

FAO-Standard für Nährstoff-IDs: ENERC=Energy, PROCNT=Protein, FAT=Fett, CHOAVL=Kohlenhydrate, FIBTG=Ballaststoffe, VITC=Vitamin C, FE=Eisen, NA=Natrium, VITA_RAE=Vitamin A usw. Alle 7 FCDs nutzen intern INFOODS-Codes. Unified Schema basiert darauf statt auf Spaltennamen-Mapping.

# Tabellen-Struktur: EINE nutrition_db

NICHT pro Land getrennt. Spalten:

- source (BLS/CIQUAL/USDA/COFID/NEVO/TURKOMP/STFCJ/OFF)
- source_id, name_original, name_en, origin_country (Metadata NICHT Filter)
- 14 Mikro-Spalten + 5 Makro-Spalten nach INFOODS-Codes, per 100g essbarer Anteil
- confidence_code (A-D, imputiert falls DB kein eigenes hat)
- embedding vector(1536)
- food_group

Begründung: pgvector durchsucht alle Quellen gleichzeitig, RRF re-rankt mit Geo als Soft Hint. Sushi in Berlin findet STFCJ-Eintrag, Tagine findet BLS-Lamm + BLS-Karotten via Recipe-First Decomposition.

# Hochgeladene Daten (Phase 1 komplett)

1. BLS 4.0 (Deutschland) — ZIP
2. CIQUAL 2025 (Frankreich, **Update von 2020!**) — 3.484 Foods × 74 Komponenten, Doku komplett analysiert
3. USDA FDC Foundation 2025-12 + SR Legacy 2018-04 — ZIPs
4. CoFID (UK, 2021) — Excel
5. NEVO 2025 v9.0 (Niederlande) — ZIP
6. **TürKomp (Türkei) — PENDING RE-DOWNLOAD von [turkomp.gov.tr](http://turkomp.gov.tr)** (ZIP 29500682 enthielt Frida 5.5 DK statt TürKomp)
7. **STFCJ (Japan) — PENDING RE-DOWNLOAD von [mext.go.jp](http://mext.go.jp)** (xlsx 1374049_0r10 ist nur Annex mit Pflanzennamen, keine Nährwerte)
8. **Frida 5.5 (Dänemark) — Bonus-Quelle**, 1.385 Foods × 234 Komponenten, beste Vit-K-Coverage (MK4-MK10 separat), nicht-INFOODS Lookup nötig

**OFF** wird nicht hochgeladen — zu groß für Supabase Free (50MB Limit). Wird stattdessen im Import-Script direkt von offstatic per HTTP-Stream gelesen, gefiltert, embeddet, in nutrition_db geschrieben.

# Hard Constraints (von Deniz, immutable)

1. **Qualität > Latenz > Cost** — immer
2. **Geo/Time/History als Soft Hints via RRF, NIE Hard Filter**
3. **Output-Konsistenz garantiert** — Frontend bekommt immer gleiche Struktur, keine Nulls. NULL-Imputation via Cross-DB Borrowing / Recipe-Based / Bognár-Faktoren
4. **Internationale Coverage Pflicht** — polnisch, türkisch, marokkanisch, asiatisch
5. **Mikronährstoffe Pflicht — 13 Felder in Phase 1** (Vit K raus, im Schema als nullable reserviert für Phase 2)
6. **Pre-Launch DSGVO Position 3** — später härter, provider-agnostisch
7. **Live-Deployment-Ziel** — HTML Test-Tool gegen echte Edge Function
8. **Plan-and-Execute strikt** — kein Code ohne Freigabe
9. **Loggen nur auf explizite Anweisung**

# Verworfene Alternativen (mit Begründung)

- **FatSecret** — US-only Free Tier, EU nur Enterprise $500-2000+/Monat
- **Edamam** — keine kostenlose Developer-Stufe mehr, nur $29+ Enterprise mit 10d Trial
- **Pure pgvector ohne API-Fallback** — V5.1 widerlegt für globale Coverage; jetzt ersetzt durch OFF-CSV-Import direkt in Tier 1
- **Separate Tabellen pro Land** — würde Cross-Country-Matching via RRF zerstören
- **Self-Reported Confidence im JSON Schema** — nur 5,4% Unterschied korrekt vs falsch, Theater
- **Gemini 2.5 Flash für Stufe 1** — 56% Schema-Bruch bei Vision-Inputs
- **Azure OpenAI** — Microsoft-Access-Wartezeit blockiert Pre-Launch
- **n8n als Orchestrierung** — 60s Timeout, kein Co-Location mit Supabase

# Einziger Secret den Deniz braucht

`OPENAI_API_KEY` — mehr nicht. OFF kein Key, pgvector kein Key, Supabase Storage über Service Role nur für Import-Script (lokal, nicht in Claude-Umgebung).

# Supabase Setup Status

- pgvector Extension: aktivieren (Deniz TODO)
- Storage Bucket `food-scans`: anlegen (Deniz TODO)
- Storage Bucket `raw-nutrition-data`: **bereits angelegt + Daten drin**
- OPENAI_API_KEY Secret: hinterlegen (Deniz TODO)

# Nächste Schritte

**Neuer Chat mit frischem Token-Budget.** Dort:

1. bash_tool: 7 ZIPs extrahieren, Header + Samples lesen
2. INFOODS-Mapping-Tabelle pro DB erstellen
3. Unified Schema als SQL Migration schreiben
4. Python Import-Script: BLS/CIQUAL/USDA/CoFID/NEVO/TURKOMP/STFCJ + OFF CSV-Stream → normalisieren → embedden → nutrition_db
5. Edge Function `food-scanner` (Deno): 4 Stufen mit Streaming JSON Parsing, Logprobs-Aggregation, RRF Re-Ranking, Conflict Resolution
6. HTML Test-Tool: Foto-Upload, manueller Fallback, Bild + Nährwert-Anzeige, Logging-Anzeige pro Scan, Korrektur-Buttons, Batch-Modus
7. Deployment Guide Schritt für Schritt

# Prompt für neuen Chat

Deniz verwendet diesen Prompt für die Fortsetzung:

> Wir bauen den coralate Food Scanner. Stack final, alle 7 Nutrition-DBs als ZIPs hochgeladen (BLS, CIQUAL 2025, USDA Foundation+SR Legacy, CoFID, NEVO 2025, TürKomp, STFCJ), CIQUAL Doku analysiert. INFOODS-Codes als Harmonisierungs-Achse. Eine einzige nutrition_db Tabelle mit source-Flag und embedding. Notion Doc "Food Scanner Master" Stand 2026-04-11 Abend. Aufgabe jetzt: bash_tool Schema-Extraktion aller 7 ZIPs, INFOODS-Mapping-Tabelle, SQL Migration, Python Import-Script (inkl. OFF CSV-Stream von [static.openfoodfacts.org](http://static.openfoodfacts.org)), Edge Function `food-scanner` mit 4 Stufen, HTML Test-Tool mobile-optimiert. Plan-and-Execute strikt, Loggen nur auf Anweisung, Qualität > Latenz > Cost. Einziger Secret: OPENAI_API_KEY.
> 

# Obsolete Dokumente

Die Vorversion "Food Scanner — Architecture Lock & Open Questions (V5.1 pending)" ist veraltet — veraltete Annahmen über Edamam, API-frei Architektur und Datenbank-Unsicherheiten sind durch diesen Stand ersetzt.