---
typ: log
projekt: "[[food-scanner]]"
datum: 2026-04-13
art: meilenstein
vertrauen: extrahiert
quelle: manuell
werkzeuge: ["supabase", "notion"]
---

Food-Scanner-Pipeline **Production-Ready**. Master-Doc DOC-62 ist die einzige Quelle. 9 alte Docs deprecated. Übergabe-Prompt liegt bereit.

## Validierte Pipeline

- Login via ES256 JWT (Supabase modernes Auth-Setup) funktioniert
- Storage-Upload mit User-scoped RLS funktioniert
- Edge Function `food-scanner` v13 (SSE-Streaming, base64-Bugfix) deployed
- Edge Function `food-scan-confirm` v5 (User-Korrekturen, Server-Recalc) deployed
- Cache: `food_scan_log` ist sowohl User-Log als auch Cache-Layer, 6-8× Speedup gemessen
- pgvector HNSW Matching gegen 25.558 Einträge (7 Quellen)
- Test-Script `test-pipeline.mjs` mit SSE-UI-Simulation, interaktiver Korrektur, DB-Check

## Kritische Entscheidungen

**`verify_jwt=false` - MUSS reviewed werden** (siehe auch [[2026-04-13-session-abschluss-doc62-auth-geloest]])
- Lösung: Auth via `auth.getUser()` im Function-Body
- Jede neue Edge Function MUSS dasselbe Pattern nutzen - Code-Review-Checkliste in DOC-62 Sektion 4

**`food_scan_log` als Source-of-Truth UND Cache**
- Keine separate Cache-Tabelle. Eine Tabelle macht beides
- Begründung: Cache-Lifecycle = User-Log-Lifecycle (CASCADE), eine RLS-Policy weniger, Privacy-Plus (keine Cross-User-Sharing)

**base64 Chunked Encoding Pattern**
- Fix in v13: `chunkSize=8192`. Muss bei jeder Edge Function mit großen Buffers angewendet werden

## Ehrliche Bewertung

- Erster Master-Doc-Build-Versuch chaotisch (Notion zerlegte Markdown-Tabellen, Append-Operationen in falscher Reihenfolge, Code-Blöcke mit Backslash-Escapes). **Lösung:** komplett neu mit `replace_content`, Listen statt Tabellen
- Mehrfache Auth-Debug-Runden: ES256 vs Legacy-Key, `verify_jwt` flip-flop. Ergebnis stabil

## Resources

- Master-Doc DOC-62: Notion `34191df4-9386-8161-bdb9-ce33655009f7`
- Test-Script: `~/Desktop/coralate-test/test-pipeline.mjs`
- Supabase-Projekt: `vviutyisqtimicpfqbmi`
- Anon Publishable Key: `sb_publishable_Lp2zW-Np-SQksog8D5yz2A_yG5E48EW`
