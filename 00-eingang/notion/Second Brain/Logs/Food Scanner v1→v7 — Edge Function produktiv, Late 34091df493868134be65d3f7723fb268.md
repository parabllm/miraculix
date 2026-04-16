# Food Scanner v1→v7 — Edge Function produktiv, Latenz 10s, Kosten unter Target

Areas: coralate
Confidence: Confirmed
Created: 12. April 2026 17:42
Date: 12. April 2026
Gelöscht: No
Log ID: LG-8
Related Doc: Food Scanner Pipeline Status — Stand v7 (2026-04-12) (../Docs/Food%20Scanner%20Pipeline%20Status%20%E2%80%94%20Stand%20v7%20(2026-04-1%2034091df493868159b414c987e990ae06.md)
Source: Claude session
Summary: Edge Function food-scanner von v1 auf v7 iteriert. Pipeline läuft end-to-end bei 10s Latenz, $0.004-0.006 pro Scan. Größter Hebel war 800px Client-Downsize. Inferred-Ingredients (Olivenöl etc) behebt Kalorien-Underreporting-Bug. 3 Research-Prompts für weitere Latenz-Reduktion dokumentiert.
Tools: Notion, Supabase
Type: Milestone

Edge Function `food-scanner` von v1 auf **v7** iteriert. Start war fehlerhaft (seqentieller Tier-1 + Tier-3 Fallback bei Gate-Fail), Ende ist ein sauberer Hybrid-Pfad mit 10s Latenz und $0.004-0.006 pro Scan.

## Wichtigste Versionen

- **v2:** Embedding und RPC parallelisiert via Promise.all. Tier-3-Blind-Fallback raus, Hybrid-Modus rein (Vision-Zutaten bleiben, Bognár drauf bei Gate-Fail)
- **v3:** Token-Usage + Kosten im Response, detail=low als default
- **v4:** Prio-Teller-Fokus im Prompt (ignoriert Nebenteller, Getränke, Hintergrund). Erfolgreich getestet
- **v5:** Batch-Embeddings in 1 OpenAI-Call statt N parallele. Embed-Block von ~800ms/call auf 349ms total
- **v6:** Multi-Match RPC via CROSS JOIN LATERAL (wieder rückgängig in v7, weil nur 500ms Ersparnis bei komplexerem Code)
- **v7:** Inferred-Ingredients mit visibility-Marker. Olivenöl, Dressings, Cooking-Oils werden bei Salaten/Pasta/Fertiggerichten automatisch ergänzt. Behebt systematischen Kalorien-Underreporting-Bug

## Client-Side Optimierung

800px-Downsize vor Upload via Canvas-API (HTML-Tool) bzw. expo-image-manipulator (App). Upload-Größe 97 Prozent reduziert, Vision-Latenz 40 Prozent, Input-Tokens 53 Prozent. **Größter einzelner Hebel bisher**.

## Deliverables

- Edge Function v7 live auf vviutyisqtimicpfqbmi
- HTML-Test-Tool v4 mit Resize-Toggle, detail-Toggle, Metrics-Panel
- PDF-Briefing v3 für Jann + Lars mit Expo-Integration-Snippet
- Bucket-Policies (food-scans public + anon insert)
- SQL-Patches: tier_used CHECK constraint um tier1_vision_hybrid erweitert

## Offene Themen

- Latenz weiter senken: 3 Research-Prompts formuliert (Vision-Alternativen, pgvector-Tuning, Architektur-Alternativen)
- Sweet-Corn-Granularität: Vision clustert kleine Items in Bucket-Kategorien
- OFF/00004800 Bratwurst: Einheiten-Bug im Import (360g Natrium statt 360mg)
- B6-NULL-Werte: Cross-DB-Borrowing läuft parallel