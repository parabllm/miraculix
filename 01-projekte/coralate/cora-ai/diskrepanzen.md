---
typ: aufgabe
name: "Cora Diskrepanzen zwischen Vault, DB und Implementierung"
projekt: "[[cora-ai]]"
status: in_arbeit
benoetigte_kapazitaet: hoch
kontext: ["desktop"]
kontakte: ["[[jann-allenberger]]", "[[lars-blum]]"]
erstellt: 2026-04-18
quelle: db_query
vertrauen: extrahiert
notizen: "Bestandsaufnahme am 2026-04-18. Direkter Abgleich Supabase-Live-Stand gegen Vault-Docs. Basis für Meeting mit Lars und Jann am 2026-04-18."
---

Die Vault-Doku zu Cora (Stand 2026-04-16/17) beschreibt eine Korrelations-Engine mit strenger SaMD-Abgrenzung. Die Supabase-DB (Stand 2026-04-07, unverändert) implementiert einen klassischen Fitness-Coach. Beide Stände wurden nie konsolidiert. Diese Datei listet die Diskrepanzen auf und was angegangen werden muss bevor Cora produktiv gehen kann.

## Zeitlinie des Drifts

- 2026-04-07: Cora-Backend-Build. 5 Coach-Prompts, 19 Action-Types, erste `ai_suggestions` mit Coach-Sprache ("du musst", "kritisch", "um Verletzungen vorzubeugen").
- 2026-04-12: Jann's Scope-Proposal (`cora-scope-jann-proposal.md`). Kernsatz: "app with a conversational interface to its own systems, not an AI assistant that happens to have an app attached". Advisory-Content permanent out of scope.
- 2026-04-16: Vault-Migration aus Notion. `cora-ai-architektur.md` definiert 3 gelockte Modi (Proaktiv Narrator, Card Q&A, Home-Chat RAG) und 4 vordefinierte Action-Button-Typen.
- 2026-04-18: Supabase-Live-Stand widerspricht dem Vault an fast allen strukturellen Punkten.

## Diskrepanzen im Detail

### 1. Positionierung

Vault: "Cora ist kein Gesundheitsassistent. Datenbeobachtung + Zielbezug + offene Möglichkeit, nie Anweisung, nie Diagnose."

DB: Alle 5 aktiven Prompts starten mit "Du bist Cora, ein KI-Fitness-Coach." Der `system_coaching_chat` v1 referenziert explizit Coach-Aufgaben.

### 2. Aktive Prompts

Aktuell aktiv in `prompt_versions`:

| Name | Version | Länge |
|---|---|---|
| system_coaching_chat | v1 | 906 chars |
| system_daily_start | v1 | 579 chars |
| system_daily_summary | v1 | 584 chars |
| system_post_workout | v1 | 943 chars |
| system_pre_workout | v2 | 1938 chars |

Vault-Modi (Narrator, Card Q&A, Home-Chat RAG) existieren als Prompts nicht. `mode` Feld in `ai_suggestions` ist bei allen Einträgen NULL.

### 3. Action-Types

Vault: 4 gelockte Typen (GEWICHT_ANPASSEN, VOLUMEN_ANPASSEN, FOOD_SCREEN_OEFFNEN, VARIATION_VORSCHLAGEN).

DB `action_types`: 19 aktive Typen in 9 Kategorien. Keiner matcht einen der 4 Vault-Typen.

| Kategorie | Typen |
|---|---|
| workout_modification | add_set, adjust_reps, adjust_rest_period, adjust_sets, adjust_tempo, adjust_weight, skip_exercise, swap_exercise |
| session_modification | swap_session |
| periodization | deload, progress_exercise, regress_exercise |
| progression | progressive_overload_suggestion |
| recovery | cooldown_suggestion, recovery_recommendation |
| preparation | warmup_suggestion |
| technique | form_correction |
| motivation | celebration, motivation_message |

`recovery_recommendation`, `form_correction`, `warmup_suggestion`, `cooldown_suggestion` sind Coach-Territorium. Unter der Vault-SaMD-Position nicht haltbar.

### 4. Tatsächliche Output-Sprache verletzt Vault-Regeln

Die 6 Einträge in `ai_suggestions` (7. April) enthalten wörtlich:

- "Fang heute leichter an, ca. 70% deiner letzten Gewichte." (direkte Anweisung)
- "Dein Push/Pull-Verhältnis ist mit 0.45 kritisch." (medizinisches Vokabular)
- "musst du Push-Bewegungen priorisieren" (verbotene Direktive laut Vault)
- "Um Schulterprobleme zu vermeiden" (Verletzungs-Prävention)
- "Achte auf ausreichend Schlaf und Protein" (Recovery-Advice)

Vault-Formulierungsregel: "Datenbeobachtung + Zielbezug + offene Möglichkeit, nie Anweisung, nie Diagnose." Keine der 6 Outputs erfüllt die Regel.

### 5. Schema-Felder

`cora_profiles.coaching_tone` existiert als Spalte. In einem Produkt das laut Vault kein Coach ist, ist ein konfigurierbarer Coach-Tonfall architektonisch inkonsistent.

### 6. Knowledge Chunks

`knowledge_chunks` (6 Einträge, Autor Lars) haben `use_cases` die zu den DB-Prompts passen, nicht zu den Vault-Modi:

- post_workout, pre_workout, coaching_chat, daily_start, daily_summary, post_food_log

Im Vault existieren diese use_cases nicht. Die 3 Vault-Modi (narrator, card_qna, home_chat_rag) existieren in den Chunks nicht.

### 7. Engine-Nutzung

Backend-Framework existiert, ist aber Prototyp-Stand:

| Tabelle | Zeilen |
|---|---|
| ai_suggestions | 6 (alle 7. April) |
| suggestion_events | 0 |
| suggestion_outcomes | 0 |
| cora_memories | 0 |
| cora_memory_stats | 0 |
| chat_sessions | 0 |
| chat_messages | 0 |

Heißt: Engine wurde einmalig getestet, nie produktiv genutzt. Keine User-Interaction-Tracks. Keine Memory. Kein Chat. Die Re-Positionierung kann auf Prompt- und Schema-Ebene sauber passieren ohne Daten zu verlieren.

## Stand Food-Scanner

Läuft konsistent. 4 Edge Functions aktiv (`food-scanner` v15, `food-scanner-gemini` v10, `food-scan-confirm` v6, `nutrition-backfill` v2). `nutrition_db` mit 23.305 Einträgen. `food_scan_log` mit 6 Einträgen. Kein Diskrepanz-Problem hier.

## Was angegangen werden muss

### Grundsatz-Entscheidung zuerst

Welcher Stand gilt. Drei Optionen:

**A. Vault-Weg (Korrelations-Engine ohne Coach)**
Konsequenzen: 5 Prompts neu schreiben, 15 der 19 Action-Types deaktivieren, `coaching_tone` raus, Coach-Sprache in Prompt-Regeln hart verbieten, neue Modi (narrator, card_qna, home_chat_rag) als `mode` enum einführen, `trigger_type` auf den neuen Modi umstellen, knowledge_chunks `use_cases` umschreiben.

**B. DB-Weg (Fitness-Coach mit 19 Actions)**
Konsequenzen: Vault komplett umschreiben, Jann's Scope-Proposal verwerfen, SaMD-Analyse durch Rechtsberatung (DACH-Fokus, EU MDR), Disclaimer-Strategie härten, wissen dass Coach-Features teuer zu zertifizieren sind.

**C. Mittelweg**
Konsequenzen: Scope-Workshop mit Team, harte Liste welche Actions bleiben und welche raus, Positionierung neu formulieren, Vault und DB zusammen neu aufsetzen.

### Wenn Option A gewählt wird (empfohlen)

Reihenfolge:

1. `prompt_versions`: 5 neue Prompts schreiben nach Vault-Formulierungsregel, alte auf `is_active = false` setzen. Keine Wörter "du musst", "du solltest", "kritisch", "um X zu vermeiden".
2. `action_types`: 15 Typen auf `is_active = false` setzen. Nur 4 Vault-Typen oder äquivalente IDs aktiv lassen. Alternative: neue IDs mit den 4 Vault-Typen anlegen, alte deprecaten.
3. `ai_suggestions.mode`: enum einführen (narrator, card_qna, home_chat_rag). Pflichtfeld machen.
4. `cora_profiles`: `coaching_tone` entfernen oder zu `communication_tone` umbenennen mit Werten die kein Coach-Vokabular enthalten.
5. `knowledge_chunks.use_cases`: auf die 3 Modi umstellen.
6. Bestehende 6 `ai_suggestions` als Test-Artefakte markieren oder löschen. Neue Outputs mit neuen Prompts gegen Vault-Regel validieren.
7. Frontend-Integration: Jann muss wissen welche `mode` er pro Screen sendet. Aktuell schickt er `trigger_type`.

### Wenn Option B gewählt wird

1. Vault-Docs (`cora-ai-architektur.md`, `coralate.md`, `cora-scope-jann-proposal.md`) anpassen.
2. Rechtsberatung zu SaMD-Risiko beauftragen.
3. Disclaimer-Text in der App verstärken.
4. Entscheiden ob alle 19 Actions bleiben oder Teil-Set.

### Wenn Option C gewählt wird

1. Workshop mit Lars und Jann: Liste aller möglichen Cora-Outputs durchgehen und pro Typ entscheiden ob drin oder draußen.
2. Neue Positionierung formulieren die nicht "Coach" ist aber mehr erlaubt als die strenge Vault-Version.
3. SaMD-Hardlimit-Liste als Team-Entscheidung (Jann's Frage aus Scope-Proposal: "Team-Commitment: Cora produziert niemals Advisory-Content").

## Offene Fragen ans Team

1. War die Repositionierung im Vault (16./17. April) eine bewusste Team-Entscheidung oder ein einseitiger Vault-Update von Deniz?
2. Kennt Jann den Unterschied zwischen den 19 DB-Actions und den 4 Vault-Actions? Was erwartet das Frontend?
3. Ist die SaMD-Position aus dem Vault wirklich nicht-verhandelbar oder ein worst-case-Hardening?
4. Lars als Knowledge-Autor: Welche seiner 6 Chunks bleiben unter welcher Positionierung verwendbar?
5. Was ist Cora's Mindest-Feature-Set für Launch? Scope-Proposal von Jann sagt: Read-Ops + Logging Writes + Weekly Brief. Vault sagt: 3 Modi. DB sagt: 6 Trigger.

## Empfehlung

Option A oder C. Option B bedeutet ernsthafte Rechtskosten die für ein Early-Stage-Produkt schwer tragbar sind. Jann's Proposal vom 12. April und die Vault-Position vom 16./17. April zeigen dass das Team schon mehrheitlich in Richtung "kein Coach" denkt. Die DB ist einfach nicht nachgezogen.

Nächster Schritt: Meeting 2026-04-18 mit Lars und Jann. Siehe [[meeting-2026-04-18-cora-ausrichtung]].
