---
typ: ueber-projekt
name: "coralate"
aliase: ["coralate", "Coralate", "corelate", "corelate-v3", "Cora"]
bereich: produkt
umfang: offen
status: aktiv
kapazitaets_last: hoch
hauptkontakt: "[[jann-allenberger]]"
tech_stack: ["expo", "react-native", "zustand", "skia", "supabase", "postgres", "pgvector", "python"]
erstellt: 2026-04-16
notizen: "iOS-first AI Fitness-Tracking-App mit Cora AI Korrelations-Engine. Deniz = Co-Founder + Frontend/AI-Dev. Strikt kein SaMD."
quelle: notion_migration
vertrauen: extrahiert
---

## Kontext

**iOS-first AI Fitness-Tracking-App** mit Korrelations-Engine. Kernfeature: **Cora AI** verknüpft Workout, Ernährung und Aktivität zu aussagekräftigen Mustern.

`coralate` = App/Company. `corelate-v3` = Repo-Folder (Legacy-Artefakt).

**Repo:** `parabllm/coralate` (GitHub privat) - Folder `corelate-v3`
**Supabase Project:** `vviutyisqtimicpfqbmi` (eu-west-1, Postgres 17)
**Stack:** Expo SDK 55 preview, React Native 0.83.1, Zustand 5, Supabase JS 2.99, React Native Skia 2.4.18, Reanimated 4.2.1
**Target:** iOS-first, Android-fallback
**Bundle ID:** `com.corelate.v3`
**Deep Link Scheme:** `corelate`

**Team-Workspace "Cora's Space HQ" (Notion)** ist SSOT fürs Team (Meeting-Logs, Page-Specs, Launch-Checklist, Team-Tasks, Components Registry). Dieser Vault enthält nur Deniz-relevante AI-Developer-Infos.

## Team

- [[jann-allenberger]] - Co-Founder, Product + Design, hält Apple Developer Account
- [[lars-blum]] - Co-Founder, Product + Analytics, Trainingsexperte, Mock-User für Cora-Backend (20 echte Workouts Jan-März 2026, Push/Pull-Imbalance 0.45)
- Deniz - Co-Founder, Frontend + AI-Integration (Cora-Pipeline, Edge Functions, Mobile App)

## Cora AI - Drei Modi (gelocked)

1. **Proaktiv (Narrator)** - Auto-Erscheinung bei klarem Signal + Ziel. Performance-Hinweis + Action-Button (`GEWICHT_ANPASSEN` | `VOLUMEN_ANPASSEN` | `FOOD_SCREEN_OEFFNEN` | `VARIATION_VORSCHLAGEN`)
2. **Card Q&A** - Chat gebunden an einzelne Korrelationskarte, strikt Scope-limitiert
3. **Home-Chat mit RAG** - Freier Chat mit Auto-Retrieval aus whitelisted Datenkategorien

## SaMD-Position (kritisch, nicht brechen)

Coralate vermeidet Software-as-a-Medical-Device-Einstufung durch:

- **KEINE** Symptominterpretation / Diagnosen / klinischen Normwertvergleiche
- Proaktive Empfehlungen bleiben im Fitness-Performance-Bereich (ziel-gebunden)
- **"Coralate Performance Index" IST IMMER Fitness-Performance-Wert, NIE Gesundheits-/Erholungsindikator**
- User bestätigt jede Aktion aktiv
- Disclaimer sichtbar im Interface

## Aktueller Stand

Stand 2026-04-13 (letzter Log): **Food-Scanner Pipeline Production-Ready** - Master-Doc DOC-62, 9 alte Docs deprecated, Chat-Übergabe vorbereitet. DB-Reset + Clean Re-Import durch. Kritische Einsicht: Matching-System ist Grundinfrastruktur für Backfill, Borrowing und Retrieval.

## Sub-Projekte

- [[food-scanner]] Nährwert-Retrieval-Pipeline (5 DBs + OFF, pgvector Hybrid-3-Tier, Edge Function live)
- [[cora-ai]] AI-Schicht (3 Modi oder 6 Coach-Trigger, Positionierung aktuell in Klärung, siehe [[diskrepanzen]])

## Detail-Docs

- [[design-system]] Color Tokens, Typography, Motion, Haptics, Buttons, Border Radius
- [[tech-stack-conventions]] Core Dependencies, File Structure, Store Persistence, Mandatory Rules

## Offene Aufgaben

_(in Cora HQ, nicht hier - siehe Team-Workspace)_

## Out of Scope (lokal)

- Page-Specs (Home/Gym/Food/Analytics/Profile/Sign-Up) - im Cora HQ
- Meeting-Logs, Launch-Checklist, Team-Tasks von Jann/Lars - im Cora HQ
- Components Registry - im Code
- SaMD-Features (Symptome, Diagnosen, medizinische Ratschläge)
- Automatische KI-Aktionen ohne User-Bestätigung

## Kontakte

- [[jann-allenberger]]
- [[lars-blum]]
