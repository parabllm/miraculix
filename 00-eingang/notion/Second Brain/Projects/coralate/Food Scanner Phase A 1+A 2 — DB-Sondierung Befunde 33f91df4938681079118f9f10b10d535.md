# Food Scanner Phase A.1+A.2 — DB-Sondierung Befunde + Constraints geklärt

## Was gemacht wurde

**Phase A.1 (Roh-Datensondierung via bash_tool):** Alle 7 hochgeladenen DB-Archive entpackt und Header/Schemas extrahiert. CIQUAL via py7zr (XML statt xlsx), BLS via openpyxl, Frida + USDA via Standard-Extract.

**Phase A.2 (INFOODS-Mapping-Realität):** Pro DB geprüft welche INFOODS-Codes nativ vorhanden sind, welche via Lookup gemappt werden müssen, welche Mikronährstoffe robust verfügbar sind.

**Notion-Kontext:** Master-Doc DOC-47 vollständig gelesen und gegen Roh-Befunde abgeglichen, 6 Diskrepanzen identifiziert.

## Drei harte Befunde (kritisch)

1. **TürKomp ZIP enthält Frida 5.5 (Dänemark)** — 1.385 Foods × 234 Komponenten, dänische Spalten, beste Vit-K-Coverage. Frida bleibt als Bonus-Quelle 8 drin, ist KEIN Türkei-Ersatz. Türkei muss Deniz von [turkomp.gov.tr](http://turkomp.gov.tr) neu runterladen.
2. **STFCJ xlsx ist nur ein Annex** mit 642 wissenschaftlichen Pflanzennamen, keine Nährwerte. Unbrauchbar. Japan muss Deniz von [mext.go.jp](http://mext.go.jp) Standard Tables 8th rev. neu runterladen.
3. **CIQUAL ZIP enthält nur XML**, keine xlsx wie in der Doku beschrieben. Import-Branch nutzt lxml.etree. ~30 Min Mehraufwand, kein Showstopper.

## Hard Constraints final geklärt

- **International Coverage NICHT relaxen** — TürKomp + STFCJ sind Launch-Blocker, Deniz lädt selbst runter
- **Vit K komplett raus aus Phase 1** — 13 statt 14 Pflicht-Mikros, im DB-Schema als nullable für Phase 2 reserviert, kein Frontend-Display, keine Borrow-Logik
- **OFF als reiner Hint-Layer** in eigener `off_barcodes` Tabelle, NICHT in nutrition_db direkt (Mikros fehlen bei OFF zu >95%)
- **Hybrid-Merge bei Hard Match (Cosine ≥0.85):** Makros aus OFF (echte Marken-Werte), Mikros aus FCD-Vector-Match, pro Spalte source-getagged
- **Mengen-Logik beim Barcode-Scan:** Vision schätzt Portion + OFF serving_size Sanity-Check + User-Slider, sum(item_mengen) ≈ total_volume ±20%, sonst proportional skalieren

## INFOODS-Mapping-Realität pro DB

- BLS: ✅ INFOODS-nativ als Spaltenpräfix, 138 Komponenten, trivial
- CIQUAL: ✅ INFOODS via const_xml Lookup, 74 Komponenten
- USDA Foundation/SR: ❌ eigene nutrient_id, 475 Nutrients, Lookup ~60 Zeilen
- CoFID: ❌ englische Namen über 8 Sheets, Sheet-Join via Food Code
- NEVO: ❌ holländisch+englisch, separates Header-CSV
- Frida (DK): ❌ dänische Klartext-Namen, manuelles Lookup

## Mikronährstoff-Verfügbarkeit (13 Pflicht ohne Vit K)

Vit A, Vit D, Vit E (α-Toc), B1, B2, B3, B6, B9 (DFE), B12, Vit C, Eisen, Calcium, Zink — in praktisch allen 6 Phase-1-DBs robust verfügbar. Folat-DFE ist einzige Restproblematik (USDA SR Legacy hat nur Folat-Total) — A.3 Klärung pending: (a) Folat-Total als Fallback / (b) Always Borrow von USDA Foundation.

## Master-Doc gepatcht (3 Edits)

- Status-Block + DB-Sondierung Befunde + OFF-Strategie + Mengen-Logik komplett dokumentiert
- Quellen-Liste 6/7/8: TürKomp PENDING, STFCJ PENDING, Frida als Bonus-8
- Constraint #5: 14 → 13 Pflicht-Mikros

## Drei offene Klärungsfragen für nächsten Turn (BLOCKEN A.3)

1. **Mengen-Logik Interpretation:** Ist Deniz' Punkt (a) Mengen-Plausibilität zwischen Items / (b) Mengen-Schätzung des Barcode-Produkts / (c) beides / (d) was anderes?
2. **Vision-Modell mit Barcode-Hint:** Soll Vision explizit informiert werden "Item X via Barcode identifiziert, identifiziere nur Rest"?
3. **User-Override Pflicht oder optional** wenn Mengen-Sanity-Check failed?

**Plus Folat-DFE Edge-Case** (a/b/c) für USDA SR Legacy.

## Nächster Schritt

Deniz beantwortet die 3+1 Fragen → A.3 Unified SQL Schema starten:

- nutrition_db Tabellen-Schema mit 13 Mikros + Vit-K-Optional + 5 Makros + Provenance-Spalten
- off_barcodes Tabelle
- 6 Mapping-Lookup-Tabellen (USDA, CoFID, NEVO, Frida, OFF, CIQUAL-Helper)
- Konfidenz-Aussage zur Output-Konsistenz

Danach: Türkei + Japan Re-Downloads von Deniz abwarten, dann Build (SQL Migration → Import-Scripts → Edge Function → HTML Test-Tool).