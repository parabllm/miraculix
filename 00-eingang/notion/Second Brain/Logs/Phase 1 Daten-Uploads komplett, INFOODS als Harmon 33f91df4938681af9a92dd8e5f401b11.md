# Phase 1 Daten-Uploads komplett, INFOODS als Harmonisierungs-Achse identifiziert

Areas: coralate
Confidence: Confirmed
Created: 11. April 2026 21:09
Date: 11. April 2026
Gelöscht: No
Log ID: LG-4
Project: coralate (../Projects/coralate%2033c91df49386813fa411f4c4e931d51f.md)
Source: Manual
Type: Progress

# Status

Alle 7 DB-Samples sind hochgeladen (BLS, CIQUAL, USDA Foundation+SR Legacy, CoFID, NEVO, TürKomp, STFCJ). CIQUAL 2025 Doku vollständig analysiert (3.484 Foods × 74 Komponenten, per 100g essbarer Anteil, A-D Confidence-Codes, INFOODS-Codes als Standard).

# Durchbruch: INFOODS-Codes

FAO definiert globalen Standard für Nährstoff-Identifier (ENERC=Energy, PROCNT=Protein, VITC=Vitamin C, FE=Iron usw.). Alle seriösen FCDs nutzen intern INFOODS-Codes. Harmonisierung läuft über diese Codes statt über Spaltennamen-Raten.

# Tabellen-Entscheidung: eine einzige nutrition_db

Nicht pro Land getrennt. Eine Tabelle mit source-Flag, source_id, name_original, name_en, origin_country (als Metadata NICHT Filter), 14 Mikro-Spalten + 5 Makro-Spalten nach INFOODS-Codes, confidence_code, embedding vector(1536), food_group. Begründung: pgvector Cosine-Search über alle Quellen gleichzeitig, RRF re-rankt mit Geo als Soft Hint. Separate Tabellen pro Land würden Cross-Country-Matching unmöglich machen.

# Edamam raus, OFF bleibt

Edamam hat nur Enterprise $29+/Monat. Stattdessen: OFF via Live API für Barcodes (kostenlos, kein Key) + OFF CSV-Stream direkt aus Internet in pgvector beim Import (kein Supabase Upload wegen 50MB Free-Plan-Limit).

# Nächste Schritte

Neuer Chat mit frischem Token-Budget. Aufgabe: bash_tool Schema-Extraktion aller 7 ZIPs, INFOODS-Mapping-Tabelle, Unified Schema SQL Migration, Python Import-Script, Edge Function food-scanner, HTML Test-Tool.

# Einziger Secret den Deniz braucht

OPENAI_API_KEY — alles andere (OFF, pgvector, Supabase Storage) braucht keine Keys.