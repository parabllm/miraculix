---
typ: log
projekt: "[[food-scanner]]"
datum: 2026-04-13
art: meilenstein
vertrauen: extrahiert
quelle: manuell
werkzeuge: ["supabase"]
---

Food Scanner Backend end-to-end validiert, Pipeline produktionsreif. Dokumentation konsolidiert für Frontend-Integration durch Jann.

## Master-Dokumentation DOC-62

- **Titel:** Food Scanner - Master Architecture & Flow (v8)
- **Page ID:** `34191df4-9386-8161-bdb9-ce33655009f7`
- 14 Sektionen, saubere Code-Blöcke (SQL/TypeScript/JSON/Bash)
- Deckt: Executive Summary, End-to-End Flow, Storage, Auth, beide Edge Functions, pgvector Matching, Cache-Strategie, `food_scan_log` Schema, Test-Pipeline, UI-Konzept für Jann, Roadmap, Migrations

## 9 alte Docs deprecated (Lifecycle=Deprecated)

DOC-51, DOC-52, DOC-53, DOC-54, DOC-55, DOC-56, DOC-58, DOC-59, DOC-61. Active bleiben: DOC-57 (Deep Research Vision), DOC-60 (Taxonomy Research).

## Kritischer Auth-Bug gelöst

**Problem:** Supabase-Projekt nutzt ES256-asymmetric JWT. Storage akzeptiert JWTs (HTTP 200), aber Edge-Function-Gateway lehnt sie mit `verify_jwt=true` als "Invalid JWT" ab (HTTP 401) - Gateway unterstützt ES256 aktuell nicht.

**Lösung:** Beide Edge Functions (`food-scanner` v13, `food-scan-confirm` v5) mit `verify_jwt=false` deployed. JWT-Validierung passiert im Function-Body via `auth.getUser()` als erste Aktion. Security identisch zu `verify_jwt=true`.

**MUSS reviewed werden:** sobald Supabase ES256-Support nachliefert → zurück auf `verify_jwt=true`, Body-Auth als Defense-in-Depth.

## base64-Bugfix (v13)

Bug bis v12: `btoa(String.fromCharCode(...new Uint8Array(bytes)))` crashte bei Bildern ≥100 KB - Spread-Operator erzeugt zu viele Argumente für `String.fromCharCode`. **Fix:** Chunked Encoding mit 8192-Byte-Chunks.

## Cache-Strategie finalisiert

- Alte `food_scan_cache`-Tabelle gedropped (0 Rows, ungenutzt)
- `food_scan_log` ist jetzt Source-of-Truth UND Cache-Layer
- Cache-Lookup via SHA256-Hash vom Bild (`scan_hash`)
- Gemessener Speedup: 6-8× (5158ms cold → 608-903ms cache)

## Wichtige Einsichten aus der Session

- Notion-Tabellen werden intern in XML-Blöcke konvertiert → lieber Listen nutzen bei Doc-Updates
- Bei großen Docs: komplettes `replace_content` in einem Rutsch, nicht inkrementell appenden
- `sb_publishable_*` ist das korrekte Anon-Key-Format für modernes ES256-Setup. Legacy HS256 `eyJ...` funktioniert nicht sauber
- Spread-Operator auf `Uint8Array` bricht bei großen Daten → Chunked Encoding Pflicht
- `thinkingBudget: 0` ist mandatory für Gemini-JSON-Outputs, sonst verbraucht Thinking 50-80% der Tokens

## Offene Must-Fixes

- Multi-Layer-Matching für Avocado-vs-Avocado-Oil (`food_group_normalized` Filter in `match_nutrition` RPC)
- `food_group_normalized` Backfill für alle 25.558 Einträge
- Frontend ScanResultScreen (Jann)
- Frontend Camera/Gallery/Barcode-Picker (Jann)
- Daily-Macros-Aggregation (View über confirmed Scans)
