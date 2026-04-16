# Food Scanner — Session-Abschluss 13.04.2026 (Master-Doc erstellt, Auth gelöst, 9 Docs archiviert)

Areas: coralate
Confidence: User-stated
Created: 13. April 2026 15:59
Date: 13. April 2026
Gelöscht: No
Log ID: LG-12
Project: coralate (../Projects/coralate%2033c91df49386813fa411f4c4e931d51f.md)
Source: Manual
Tools: Supabase
Type: Milestone

**Confidence:** User-stated

**Source:** Manual (Session-Ende)

**Type:** Milestone

## Session-Ziel

Food Scanner Backend End-to-End validieren, Pipeline produktions-reif machen, Dokumentation konsolidieren für Frontend-Integration durch Jann.

## Was wurde erreicht

### Master-Dokumentation konsolidiert

- Neues Master-Doc **DOC-62** erstellt: "Food Scanner — Master Architecture & Flow (v8)"
- 14 Sektionen, in sauberer Reihenfolge, saubere Code-Blöcke (SQL/TypeScript/JSON/Bash)
- URL: [Food Scanner — Master Architecture & Flow (v8)](../Docs/Food%20Scanner%20%E2%80%94%20Master%20Architecture%20&%20Flow%20(v8)%2034191df493868161bdb9ce33655009f7.md)
- Page ID: `34191df4-9386-8161-bdb9-ce33655009f7`
- Enthält: Executive Summary, End-to-End Flow, Storage Layer, Auth Pattern, beide Edge Functions, PG Vector Matching, Cache-Strategie, food_scan_log Schema, Test-Pipeline, UI-Konzept für Jann, Roadmap, Migrations, Verwandte Docs

### 9 alte Docs archiviert (Lifecycle = Deprecated)

- DOC-51 Food Scanner Handover — STEP 1+2 Done
- DOC-52 Food Scanner Status — STEP 3 Done
- DOC-53 Food Scanner v2 Architecture
- DOC-54 Edge Function Build — Handover-Prompt
- DOC-55 Food Scanner Pipeline Status v7
- DOC-56 Food Scanner Pipeline Status v7 Live
- DOC-58 Food Scanner Frontend Integration Spec
- DOC-59 Food Scanner Backend — Supabase Doku
- DOC-61 Food Scanner — Prompt Version Log

### 2 Research-Docs bleiben Active

- DOC-57 Food Scanner Deep Research — Vision-Modelle, pgvector, Edge-Pipeline
- DOC-60 Food Scanner Retrieval — Taxonomy Research Findings

### Kritischer Auth-Bug gelöst

**Problem:** Das Supabase-Projekt nutzt ES256 asymmetric JWT-Setup. Storage akzeptiert die User-JWTs (HTTP 200), aber das Edge Function Gateway lehnt sie mit `verify_jwt=true` als "Invalid JWT" ab (HTTP 401). Das Gateway unterstützt das asymmetrische Format aktuell nicht.

**Lösung:** Beide Edge Functions (`food-scanner` v13, `food-scan-confirm` v5) sind mit `verify_jwt=false` deployed. JWT-Validierung passiert im Function-Body via `auth.getUser()` als erste Aktion. Security ist identisch zu `verify_jwt=true`, nur an anderer Stelle validiert.

**MUSS später reviewed werden:** Sobald Supabase ES256-Support im Edge Function Gateway nachliefert, zurück auf `verify_jwt=true` switchen. `auth.getUser()` im Body kann als defense-in-depth bleiben.

### base64-Bugfix deployed (v13)

- Bug bis v12: `btoa(String.fromCharCode(...new Uint8Array(bytes)))` crashte mit "Maximum call stack size exceeded" bei Bildern ≥100 KB
- Ursache: Spread-Operator erzeugt zu viele Funktions-Argumente für `String.fromCharCode`
- Fix: chunked Encoding mit 8192-byte-Chunks in v13

### Cache-Strategie finalisiert

- Alte `food_scan_cache` Tabelle gedropped (war 0 rows, ungenutzt)
- `food_scan_log` ist jetzt Source-of-Truth UND Cache-Layer in einem
- Cache-Lookup über SHA256 Hash vom Bild (`scan_hash` column)
- Gemessener Speedup: 6-8x (5158ms cold → 608-903ms cache)
- 3 Cache-Hits in DB verifiziert mit identischem scan_hash

### End-to-End Tests erfolgreich

Test-Skript `test-pipeline.mjs` (auf Deniz Desktop) validiert vollständigen Flow:

- Login mit ES256 JWT funktioniert
- Storage Upload mit User-scoped RLS funktioniert
- Image Scan auch mit 133 KB Bildern durchläuft (Open-faced sandwich, 715 kcal, 12 Zutaten, 4.5s)
- SSE Streaming mit allen Events (start, dish, ingredient, vision_done, embed_done, match_done, final)
- User-Correction flow persistiert `user_corrected: true` in DB
- Cache-Hit liefert instant `final` Event
- Barcode-Tier über Open Food Facts API funktioniert

## Offene Must-Fixes für Food Scanner

Dokumentiert in DOC-62 Sektion 12:

- Multi-Layer Matching für Avocado-vs-Avocado-Oil-Problem (food_group_normalized Filter im match_nutrition RPC)
- food_group_normalized Backfill für alle 25.558 Einträge
- Frontend ScanResultScreen in React Native (Jann)
- Frontend Camera/Gallery/Barcode-Picker (Jann)
- Daily Macros Aggregation (View über confirmed Scans)

## Wichtige Einsichten aus der Session

- Notion-Tabellen (Markdown-Tabellen) werden intern in XML-Blöcke konvertiert und lassen sich nicht per `update_content` mit old_str/new_str ansteuern. Bei Doc-Updates deshalb lieber Listen nutzen statt Tabellen.
- Bei großen Docs mit mehreren update_content-Calls können Sektionen in falscher Reihenfolge landen, wenn old_str-Anker nicht eindeutig das Dokumentende sind. Lösung: komplettes `replace_content` in einem Rutsch, nicht inkrementell appenden.
- Publishable-Key (`sb_publishable_*`) ist das korrekte Format für das moderne ES256-Setup. Der Legacy-Anon-Key (HS256, eyJ...) funktioniert nicht mehr sauber.
- Spread-Operator auf Uint8Array bricht bei großen Datenmengen wegen Argumenten-Limit. Immer chunked encoding für Buffer-to-String Konvertierungen.
- `thinkingBudget: 0` ist mandatory für Gemini JSON-Outputs — ohne wird 50-80% der Tokens für Thinking verbraucht, JSON wird abgeschnitten.

## Handover zu Jann

Jann kann heute mit Frontend-Implementation starten:

- API-Contracts sind final (Request/Response Shapes dokumentiert)
- Auth-Pattern ist dokumentiert (apikey + Bearer JWT)
- Streaming-Integration hat vollständigen Code-Snippet (startScan Funktion)
- Confirm-Call hat vollständigen Code-Snippet
- Error-Handling pro HTTP-Code dokumentiert
- UI-State-Machine mit 8 States spezifiziert
- Komponenten-Liste mit Inhalten beschrieben

Was Jann noch braucht (nicht im Doc, bewusst):

- Visual Design (Mockups, Farben, konkrete Animations) — muss Team entscheiden
- State-Management-Pattern (Zustand/Redux/Context) — abhängig von existing coralate-Code
- Navigation-Setup (React Navigation Stack/Modal) — abhängig von App-Aufbau

Empfehlung: 30min Call mit Jann, Screen-Sharing des `test-pipeline.mjs --correct`. Wenn er das Terminal-UI live sieht, hat er sofort die richtige mentale Vorstellung für das App-UI.

## DB-Stabilitäts-Garantie für Jann

- `food_scan_log` Schema ist final, keine Breaking Changes geplant
- `nutrition_db` Schema ist final, geplante Änderungen sind additive (Backfills, neue RPC-Parameter)
- Edge Function Request/Response Shapes bleiben stabil — wenn Breaking Change kommt, wird DOC-62 aktualisiert und Deniz informiert
- Edge Function Versions können sich erhöhen (v14, v15 etc.), das ist transparent für Client

## Session-Ende

Handover-Prompt für nächsten Chat wurde erstellt als `/mnt/user-data/outputs/handover-prompt.md`. Dieser Prompt enthält:

- Projekt-Kontext (coralate, Team, Stack)
- Session-Zusammenfassung
- Master-Doc-Referenz (DOC-62)
- Status aller Komponenten
- Offene Must-Fixes
- Must-Review (verify_jwt=false Entscheidung)
- Arbeitsweise-Reminder
- Erste Aktion für neuen Chat

Nächster Chat startet mit Fetch von DOC-62 und Frage nach heutigem Fokus.