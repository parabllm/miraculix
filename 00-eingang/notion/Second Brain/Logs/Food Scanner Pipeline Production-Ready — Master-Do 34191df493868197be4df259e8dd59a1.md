# Food Scanner Pipeline Production-Ready — Master-Doc DOC-62 erstellt, 9 alte Docs deprecated, Chat-Übergabe vorbereitet

Areas: coralate
Confidence: User-stated
Created: 13. April 2026 16:02
Date: 13. April 2026
Gelöscht: No
Log ID: LG-13
Project: coralate (../Projects/coralate%2033c91df49386813fa411f4c4e931d51f.md)
Source: Manual
Tools: Notion, Supabase
Type: Milestone

## Zusammenfassung

End-of-Chat-Log nach einem langen Build- und Dokumentations-Chat. Food Scanner Pipeline ist Production-Ready, Master-Doc DOC-62 ist die einzige Quelle, alte Docs sind deprecated, Übergabe-Prompt liegt als Datei bereit.

---

## Was erreicht wurde

### Pipeline vollständig validiert

- Login mit ES256 JWT (Supabase modernes Auth-Setup) funktioniert
- Storage Upload mit User-scoped RLS funktioniert
- Edge Function `food-scanner` v13 (SSE-Streaming, base64-Bugfix für Bilder über 100 KB) deployed
- Edge Function `food-scan-confirm` v5 (User-Korrekturen, Server-Recalc) deployed
- Cache-Strategie implementiert: `food_scan_log` ist sowohl User-Log als auch Cache-Layer, 6-8x Speedup gemessen
- pgvector HNSW Matching gegen 25.558 Einträge in nutrition_db (7 Quellen) funktioniert
- Test-Skript `test-pipeline.mjs` komplett mit SSE-UI-Simulation, interaktiver Korrektur, DB-Check

### Master-Doc DOC-62 erstellt

- **Page ID:** 34191df4-9386-8161-bdb9-ce33655009f7
- **Titel:** Food Scanner — Master Architecture & Flow (v8)
- **14 Sektionen** in korrekter Reihenfolge
- **Saubere Code-Blöcke** (SQL, TypeScript, JSON, Bash)
- **Properties:** Doc Type=Architecture, Lifecycle=Active, Stability=Stable, Stack=[Supabase, React Native], Pattern Tags=[OCR, Enrichment, Auth], Project=coralate, Last Reviewed=2026-04-13
- Inhalt deckt: Executive Summary, End-to-End Flow, Storage, Auth, beide Edge Functions komplett, PG Vector Matching, Cache, food_scan_log Schema, Test-Pipeline, UI-Konzept für Jann, Open Issues, Deployment-Reference, Verwandte Docs
- Erster Replace-Versuch war chaotisch (Notion hat Markdown-Tabellen zerlegt und Sektions-Reihenfolge durcheinandergebracht) → komplett neu mit `replace_content` geschrieben, mit Listen statt Tabellen

### 9 alte Docs auf Deprecated gesetzt

Lifecycle=Deprecated via update_properties:

- DOC-51 Food Scanner Handover — STEP 1+2 Done
- DOC-52 Food Scanner Status — STEP 3 Done
- DOC-53 Food Scanner v2 Architecture
- DOC-54 Edge Function Build — Handover-Prompt
- DOC-55 Food Scanner Pipeline Status — Stand v7
- DOC-56 Food Scanner Pipeline Status v7 — Live, Latenz-Roadmap
- DOC-58 Food Scanner — Frontend Integration Spec für Jann v1
- DOC-59 Food Scanner Backend — Supabase Doku
- DOC-61 Food Scanner — Prompt Version Log

DOC-57 (Deep Research Vision) und DOC-60 (Taxonomy Research) bleiben Active weil Research/Referenz-Material.

### Übergabe-Prompt erstellt

Datei `HANDOVER_NEXT_CHAT.md` liegt bereit zum Kopieren in den nächsten Chat. Enthält:

- Wer ich bin und was coralate ist
- Was im letzten Chat passiert ist (komplette Recap)
- DOC-62 als zentrale Referenz
- Weiterer Notion-Kontext (DOC-57, DOC-60, Projekt-Page, DB-IDs)
- Supabase-Zugang und deployed Edge Functions
- Was als Nächstes ansteht (Prioritäten)
- Arbeitsweise-Reminder
- Startpunkt-Anleitung für nächsten Claude

---

## Kritische Entscheidungen

### verify_jwt=false — MUSS in Zukunft reviewed werden

Beide Edge Functions laufen mit `verify_jwt=false` weil das Supabase Edge-Function-Gateway aktuell ES256-JWTs nicht validieren kann (HTTP 401 "Invalid JWT"). Storage akzeptiert die gleichen JWTs problemlos.

**Lösung:** Auth im Function-Body via `auth.getUser()` als erste Aktion. Sicherheit ist identisch zu `verify_jwt=true` weil `auth.getUser()` den JWT kryptografisch gegen den JWKS-Endpoint validiert.

**Was in Zukunft zu tun ist:**

1. **Wenn Supabase ES256-Support im Gateway nachliefert** → zurück auf `verify_jwt=true` switchen. Body-Auth kann als Defense-in-Depth bleiben.
2. **Jede NEUE Edge Function MUSS das gleiche Pattern nutzen** — `auth.getUser()` als erste Aktion. Code-Review-Checkliste ist in DOC-62 Sektion 4 dokumentiert.
3. **Periodisch prüfen** ob Supabase das Gateway-Verhalten geändert hat.

### food_scan_log als Source-of-Truth UND Cache

Keine separate Cache-Tabelle. `food_scan_log` macht beides. Alte `food_scan_cache` Tabelle wurde gedropped via Migration `drop_unused_food_scan_cache`.

**Begründung:** Cache-Lifecycle = User-Log-Lifecycle (CASCADE beim Account-Delete), eine RLS-Policy weniger, Cache-Hits sind immer User-eigene Scans (kein Cross-User-Sharing, Privacy-Plus).

### base64 Chunked Encoding

Bug bis v12: `btoa(String.fromCharCode(...new Uint8Array(bytes)))` crashte bei Bildern ab 100 KB mit "Maximum call stack size exceeded" wegen Spread-Operator.

Fix in v13: Chunked Encoding mit `chunkSize=8192`. Pattern ist in DOC-62 Sektion 5 dokumentiert, soll bei jeder zukünftigen Edge Function die große Buffers verarbeitet angewendet werden.

---

## Was als Nächstes ansteht

### High Priority

- Jann implementiert Frontend auf Basis DOC-62 Sektion 11. Vorschlag: 30min Call mit Screen-Share vom Test-Skript `test-pipeline.mjs --correct` damit er die UX-Intention sieht
- `food_group_normalized` Backfill für alle 25.558 nutrition_db Einträge (aktuell nullable)
- Multi-Layer Matching mit food_group_filter im match_nutrition RPC (Avocado-vs-Avocado-Oil-Problem)
- Daily Macros Aggregation (View über food_scan_log)

### Mittelfristig

- Manuell-Eingabe-Modus
- Edit bereits confirmed Scans
- Re-Scan failed Scans per Klick
- Bognár-Faktoren für Kochverlust
- OFF-Daten Translation-Pipeline (2000 Einträge ohne name_en)
- Vision-Prompt v2 (inferred ingredients sind zu konservativ)

### Watch-List

- `verify_jwt=false` periodisch reviewen
- Edge Function Cold Start Mitigation über keepalive-Endpoint
- OFF-Daten haben keine name_en (2000 Einträge semantisch schwer findbar)

---

## Ehrliche Bewertung des Chat-Verlaufs

Der Chat lief lang und an zwei Stellen nicht optimal:

1. **Erster Master-Doc-Build-Versuch war chaotisch** — Notion hat Markdown-Tabellen zerlegt, Append-Operationen haben Sektionen in falscher Reihenfolge eingefügt, Code-Blöcke wurden als `javascript`-fences mit Backslash-Escapes gerendert. **Lösung:** komplett neu mit `replace_content` in einem Rutsch, mit Listen statt Tabellen, saubere Code-Fences.
2. **Mehrfache Auth-Debug-Runden** haben Zeit gekostet — ES256 vs Legacy-Key, verify_jwt true/false flip-flop. **Ergebnis ist stabil:** `sb_publishable_*` ist der richtige Anon-Key (nicht Legacy-HS256), `verify_jwt=false` + Body-Auth ist die aktuell richtige Entscheidung.

Das Master-Doc ist jetzt sauber und nützlich. Jann kann auf Basis davon Frontend bauen. DB-Schema ist stabil, geplante Änderungen sind alle additive (Backfills, optionale RPC-Parameter), keine Breaking Changes.

---

## Files & Resources

- Master-Doc DOC-62: [Food Scanner — Master Architecture & Flow (v8)](../Docs/Food%20Scanner%20%E2%80%94%20Master%20Architecture%20&%20Flow%20(v8)%2034191df493868161bdb9ce33655009f7.md)
- Übergabe-Prompt: `/mnt/user-data/outputs/HANDOVER_NEXT_CHAT.md`
- Test-Skript: `~/Desktop/coralate-test/test-pipeline.mjs`
- Supabase Projekt: vviutyisqtimicpfqbmi
- Anon Publishable Key: `sb_publishable_Lp2zW-Np-SQksog8D5yz2A_yG5E48EW`