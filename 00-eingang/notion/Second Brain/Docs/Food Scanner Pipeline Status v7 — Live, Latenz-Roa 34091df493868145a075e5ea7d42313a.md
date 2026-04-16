# Food Scanner Pipeline Status v7 — Live, Latenz-Roadmap

Created: 12. April 2026 17:39
Doc ID: DOC-56
Doc Type: Architecture
Gelöscht: No
Last Edited: 12. April 2026 17:39
Lifecycle: Deprecated
Notes: DEPRECATED 2026-04-13. Beschreibt v7 (GPT-4o, Pattern A image_url) — IST-Stand abweichend: produktiv ist food-scanner-gemini v8 (Gemini 2.5 Flash Lite, Pattern B base64). Wird ersetzt durch Architecture v8 Doc nach Build+Test in Session 2026-04-13.
Pattern Tags: Enrichment
Stability: Volatile
Stack: Supabase
Verified: Yes

# Zweck

Aktueller Produktions-Stand der Food Scanner Edge Function nach Session 2026-04-12. Ersetzt inhaltlich [Food Scanner v2 Architecture](Food%20Scanner%20v2%20Architecture%20%E2%80%94%20Post-Jann%20Adjustmen%2034091df4938681549168f91af273bc0d.md) und [Food Scanner Status](Food%20Scanner%20Status%20%E2%80%94%20STEP%203%20Done,%20Pipeline%20Adjust%2034091df4938681989eaadf7eba915b3e.md) — beide sind auf Stability=Volatile zu setzen, Content bleibt als Historie.

# Deployment

- Edge Function `food-scanner` v7 LIVE auf Projekt `vviutyisqtimicpfqbmi`
- 6 Files: index.ts, types.ts, prompts.ts, tier0_barcode.ts, tier1_vision.ts, recalculate.ts
- Tier 3 Synthesis entfernt — durch Hybrid-Modus ersetzt
- Multi-Match RPC gebaut aber zurückgerollt (Supabase RPC Baseline dominiert, nicht Coordination)
- CHECK-Constraint `food_scan_cache.tier_used` um `tier1_vision_hybrid` erweitert
- Storage-Bucket `food-scans` public, anon Policies gesetzt

# Latenz-Profil

| Phase | Zeit | Client Resize 800px + Upload | ~700ms |
| --- | --- | --- | --- |
| Image fetch + SHA256 + Cache-Check | ~800ms | GPT-4o Vision | ~4500ms (Hard Floor) |
| Batch-Embedding 1 Call | ~300ms | N parallele pgvector RPCs | ~3000ms (PostgREST Baseline ~2s) |
| Response | ~500ms | <b>GESAMT</b> | <b>~9-11s</b> |

# Was optimiert wurde

1. Client-side Resize 800px (97% kleiner, Vision –40%)
2. Batch-Embeddings (1 Call statt N)
3. Prio-Teller-Fokus im Prompt
4. Inferred Ingredients (Öl, Dressing, Salz) mit visibility-Marker
5. Grams-Korrektur ×0.9
6. Token-Tracking + Kosten pro Scan
7. Quality Gate + Hybrid-Modus statt Tier 3

# Kosten

$0.004-0.006 pro Image-Scan. 100 Scans/User/Monat = $0.40-0.60. Target <$1 erfüllt.

# Offene Probleme

- Granularitäts-Problem Salate (Mais/Kürbiskerne unter 'mixed greens' geclustert)
- B6 oft NULL in nutrition_db (Cross-DB-Borrowing läuft)
- OFF-Record 00004800 Bratwurst Einheiten-Bug
- food_scan_cache Schema-Erweiterung (barcode, ingredients, corrected_*) offen

# Latenz-Roadmap — Ziel <5s

Drei Research-Prompts an externe Deep-Research vergeben:

1. Vision-Modell Alternativen April 2026 (Gemini Flash 2.5, Claude Haiku Vision, gpt-4o-mini)
2. Supabase RPC Baseline + pgvector HNSW Tuning + Direct Postgres Pfad
3. Edge-Deployment-Pattern + Konkurrenz-Analyse

Erwartete Hebel:

- Vision-Modell-Wechsel: 4.5s → 2s
- Direct Postgres Client: 3s → 500ms
- Streaming Response: UX first-token ~3s

# Integrations-Contract Jann

```jsx
import * as ImageManipulator from 'expo-image-manipulator';
const resized = await ImageManipulator.manipulateAsync(
  photoUri, [{ resize: { width: 800 } }],
  { compress: 0.85, format: ImageManipulator.SaveFormat.JPEG }
);
// resized.uri → Supabase Storage → Edge Function mit ?detail=high
```

Response: per_ingredient_nutrients (20 Werte) + visibility Marker pro Zutat.

# Session-Log 2026-04-12

- v1: serieller Tier 1→Tier 3 (Architektur-Fehler)
- v2: Hybrid + parallelisiert 37s→11s
- v3: detail=low + Grams + Tokens
- v4: Prio-Teller-Fokus
- v5: Batch-Embeddings
- v6: Multi-Match (rolled back)
- v7: Inferred Ingredients

Stand: produktionsreif, wartet auf Research-Ergebnisse.