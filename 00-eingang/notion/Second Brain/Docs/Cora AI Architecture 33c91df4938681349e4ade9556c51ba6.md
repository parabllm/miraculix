# Cora AI Architecture

Created: 9. April 2026 00:52
Doc ID: DOC-31
Doc Type: Workflow Spec
Gelöscht: No
Last Edited: 9. April 2026 00:52
Lifecycle: Active
Notes: Vollständige Cora AI Dokumentation: 3 Modi, System Prompts v1.0 (07.04.2026), Backend-Architektur (Edge Function Pipeline, 16 Supabase-Tabellen, Vertex AI Setup), Kosten, Patches, SaMD-Position, rechtliche Checkliste. Quelle: Cora's Space HQ (AI & Pipeline Doc + Cora Backend Status 07.04.2026).
Pattern Tags: Enrichment, Webhook
Project: coralate (../Projects/coralate%2033c91df49386813fa411f4c4e931d51f.md)
Stability: Stable
Stack: Python, Supabase
Verified: No

## Scope

Vollständige technische und rechtliche Dokumentation der Cora AI-Schicht in Coralate. Enthält: Was Cora ist vs. nicht ist, SaMD-Position, drei gelockte Modi mit Trigger-Logik und Beispielen, RAG Whitelist, versionierte System Prompts, Backend-Architektur (Edge Function Pipeline, Supabase-Tabellen, Vertex AI), Rechtliche Checkliste vor Launch. Quelle: Cora's Space HQ Workspace (AI & Pipeline Doc + Cora Backend Status).

## Architecture / Constitution

- **Deployment:** Supabase Edge Function `cora-engine` in Production (JWT-protected)
- **LLM:** Google Vertex AI Gemini 2.5 Flash in `europe-west4` (GDPR Data Residency)
- **Supabase Project:** `vviutyisqtimicpfqbmi` (eu-west-1, Postgres 17)
- **Extensions aktiv:** `pgvector` (HNSW-Index für Memory-Embeddings), `pgmq` (Job-Queues), `pg_cron` (Scheduled Jobs)
- **Drei Modi sind gelocked:** Proaktiv (Narrator) / Card Q&A / Home-Chat mit RAG
- **SaMD-Position ist nicht verhandelbar:** Cora ist kein Gesundheitsassistent

---

## Was Cora ist — und was nicht

Cora ist Coralates analytische KI-Schicht. Ihre Aufgabe ist es, Muster in den eigenen Fitness- und Ernährungsdaten des Users zu erkennen, verständlich zu machen, und im Fitness-Performance-Bereich konkrete Vorschläge zu machen.

**Cora ist kein Gesundheitsassistent.** Sie interpretiert keine Symptome, stellt keine Diagnosen, und gibt keine medizinischen Ratschläge. Diese Grenze ist nicht nur ein Produktentscheid — sie ist eine rechtliche Notwendigkeit.

### Warum diese Grenze existiert

Eine App die personalisierte Gesundheitsempfehlungen auf Basis von Biometrics gibt, kann als **Software as a Medical Device (SaMD)** eingestuft werden — unter EU MDR und FDA 21 CFR Part 820. SaMD-Zertifizierung kostet €50k–300k, dauert 6–24 Monate, und erzwingt einen Change-Control-Prozess bei jedem Feature-Release. Für ein früh-stage Startup ist das existenzbedrohend.

Ein Disclaimer ("keine medizinische Beratung") schützt nicht vor dieser Einstufung. Regulatoren schauen auf die **Funktion**, nicht die Bezeichnung.

Coralates Architektur ist so gebaut, dass sie **funktional** außerhalb des SaMD-Territoriums bleibt.

### Was Cora darf vs. nicht darf

| Erlaubt | Verboten |
| --- | --- |
| Muster in eigenen Trainingsdaten erklären | Symptome oder Körperzustände interpretieren |
| Korrelationen zwischen Ernährung und Performance zeigen | Diagnosen stellen oder andeuten |
| Performance-Vorschläge auf Basis von Ziel + Trainingsdaten | Normwertvergleiche mit anderen Menschen |
| Konfidenz und Methodik erklären | "Du solltest", "du musst", "das deutet auf" |
| Fitness-Parameter anpassen vorschlagen (mit User-Bestätigung) | Medizinische Handlungsempfehlungen |

### Formulierungsregel für alle Cora-Outputs

> Datenbeobachtung + Zielbezug + offene Möglichkeit — nie Anweisung, nie Diagnose
> 

---

## Modus 1 — Proaktive Performance-Empfehlungen mit Action-Buttons

### Konzept

Cora taucht proaktiv auf — ohne dass der User fragt. Sie hat im Hintergrund geprüft ob die vorliegenden Daten ein klares Signal in Richtung des User-Ziels ergeben, und meldet sich wenn ja. Der Output besteht aus einem kurzen Hinweis und einem direkt ausführbaren Action-Button.

Cora ist hier ein **Narrator**, kein Assistent. Sie spricht — der User antwortet nicht mit Text, sondern mit Aktion oder Ablehnung.

### Trigger-Logik

Alle drei Bedingungen müssen gleichzeitig erfüllt sein:

1. User hat ein explizites Ziel gesetzt (z.B. "Masse aufbauen", "Kraft steigern", "Abnehmen")
2. Mindestens zwei relevante Datenpunkte für den Tag sind verfügbar (z.B. Protein-Tracking + Coralate Performance Index)
3. Die Kombination ergibt ein eindeutiges Signal in Richtung dieses Ziels

Wenn kein klares Signal vorhanden ist, gibt Cora keinen Output. **Schweigen ist besser als ein schwaches Signal zu überinterpretieren.**

### Beispiele

**Ziel: Masseaufbau**

Datenlage: 178g Protein getrackt (Ziel: 160g), Coralate Performance Index: 87%, letztes Bench-Gewicht: 80kg

> "Du hast heute dein Proteinziel übertroffen und dein Performance-Index ist hoch — das sind gute Voraussetzungen für eine intensive Einheit. Beim Bench Press warst du zuletzt bei 80kg."
> 

> 
> 

> **[ Gewicht auf 82kg setzen ]**
> 

**Ziel: Abnehmen**

Datenlage: 340kcal unter Tagesziel, Schlaf: 7.4h, kein Training heute

> "Du liegst heute deutlich unter deinem Kalorienziel und hast gut geschlafen — das wären gute Bedingungen für ein Cardio-Workout."
> 

> 
> 

> **[ Cardio-Training hinzufügen ]**
> 

**Ziel: Kraft**

Datenlage: Trainingsvolumen letzte Woche +12% vs. Vorwoche, Performance Index heute: hoch, Schulterdrücken stagniert seit 21 Tagen bei 52.5kg

> "Dein Schulterdrücken stagniert seit 3 Wochen. Dein Volumen ist gestiegen, aber das Gewicht nicht — eine Variation könnte das Signal für Kraftzuwachs wieder setzen."
> 

> 
> 

> **[ Gewicht -10%, Wiederholungen +3 vorschlagen ]**
> 

### Vordefinierte Action-Button-Typen

Cora wählt ausschließlich aus diesen vier Typen. Kein freies Action-Generieren.

| Typ | Wann | Beispiel-Label |
| --- | --- | --- |
| `GEWICHT_ANPASSEN` | Performance hoch + Ziel Kraft/Masse | "Bench auf 82kg setzen" |
| `VOLUMEN_ANPASSEN` | Performance niedrig oder Volumen zu hoch | "Heute 3 Sätze weniger" |
| `FOOD_SCREEN_OEFFNEN` | Kaloriendefizit zu groß für Ziel | "Mahlzeit hinzufügen" |
| `VARIATION_VORSCHLAGEN` | Stagnation bei Übung ≥ 3 Wochen | "Gewicht -10%, Wdh +3" |

### Rechtliche Einordnung

Der Action-Button setzt einen Trainingsparameter den der User selbst kontrolliert — kein Körperstatus, keine Diagnose. Vergleichbar mit einer Kalender-App die "Termin verschieben?" vorschlägt. Der User bestätigt aktiv — Cora führt nie automatisch aus. Jede ausgeführte Aktion wird im Log als "Cora-Vorschlag" markiert (Audit-Trail).

**Wichtig:** Der "Coralate Performance Index" ist ein intern berechneter Fitness-Performance-Wert — er darf in keinem Output als Gesundheits- oder Erholungsindikator des Körpers beschrieben werden. Nur als Performance-Metrik im Kontext des Trainingsziels.

---

## Modus 2 — Card-gebundener Q&A-Layer

### Konzept

Der User öffnet eine Korrelationskarte in Coralate und sieht einen Einstieg: **"Frag Cora zu dieser Korrelation"**. Er tippt darauf — ein Chat öffnet sich, der technisch auf genau diese eine Karte beschränkt ist.

Cora erklärt die Karte. Sie verlässt den Datensatz der Karte nie.

Das ist kein Chatbot — das ist eine **kontextsensitive Erklärungsebene** im Chat-Format.

### Warum Korrelationen erklärt werden müssen

Eine Korrelationskarte die nur "Schlaf ↔ HRV, r=0.71, Konfidenz hoch" zeigt, ist für 95% der User bedeutungslos. Nicht weil sie es nicht verstehen wollen, sondern weil r=0.71 kein menschliches Konzept ist. Der Card-Q&A-Layer macht die Zahl erlebbar ohne in medizinisches Territorium zu gehen.

### Was Cora in diesem Modus erklärt

- Was die Metrik auf der Karte bedeutet (in einfacher Sprache)
- Wie Coralates Konfidenz-System funktioniert ("34 von 60 Tagen = mittlere Konfidenz, ab 45 = hoch")
- Welche Faktoren innerhalb des eigenen Datensatzes das Muster beeinflusst haben
- Methodenzitate auf Statistikebene zur Erklärung der Coralate-Methodik (z.B. NIH zu Stichprobengrößen) — nie zur gesundheitlichen Einordnung

### Beispiel-Dialog

Karte: *"Wenn du 7h+ schläfst, ist dein Performance-Index am nächsten Tag höher — in 34 von 60 Tagen"*

**User:** "Was heißt 34 von 60?"

**Cora:** "34 deiner letzten 60 Tage mit vollständigen Daten zeigen dieses Muster. An den anderen 26 Tagen fehlten entweder Schlafdaten, oder andere Faktoren haben das Muster überlagert — zum Beispiel hattest du an 11 dieser Tage überdurchschnittlich intensiv trainiert."

**User:** "Ist das gut oder schlecht?"

**Cora:** "Das kann Coralate nicht beurteilen — wir zeigen Muster, keine Bewertungen. Was wir sagen können: 34 von 60 gilt in unserem System als mittlere Konfidenz. Das Muster ist real, aber nicht dominant. Ab 45 von 60 stufen wir es als stark ein."

**User:** "Könnte das ein Herzproblem sein?"

**Cora:** "Das liegt außerhalb von dem was ich zu dieser Karte beantworten kann. Für medizinische Fragen wende dich an deinen Arzt."

### Technische Durchsetzung (drei Ebenen)

1. **System Prompt** — enthält exakt die Kartendaten, nichts sonst. Versioniert und datiert.
2. **Classifier vor dem LLM** — blockt Symptom-, Diagnose-, und medizinische Fragen bevor der LLM sie sieht. Hard redirect zum Arzt.
3. **Output-Filter nach dem LLM** — prüft ob die Antwort den Card-Scope verlässt oder verbotene Formulierungen enthält. Erst dann wird die Antwort angezeigt.

---

## Modus 3 — Generalisierter Home-Button Chat

### Konzept

Ein dauerhafter Cora-Button auf dem Home Screen. User tippt — ein Chat öffnet sich. Der User kann entweder:

- **Manuell Daten anhängen** (wie File-Attachments in anderen KI-Systemen) — und dann gezielt fragen
- **Frei tippen** — Cora holt sich die relevanten Daten automatisch über RAG

In beiden Fällen antwortet Cora ausschließlich auf Basis von Coralate-internen Daten des Users. Kein externer Datenzugang, keine allgemeinen Wissensfragen.

### Manuelles Attachment

Der User wählt aus einem Attachment-Picker:

- Einzelne Korrelationskarten
- Übungen aus der Bibliothek (mit persönlicher Trainingshistorie)
- Tages- oder Wochen-Statistiken (Makros, Volumen, Schlaf)
- Einzelne Workout-Sessions

Maximal 3–5 Attachments pro Session (Token-Management). Der System Prompt wird dynamisch aus den Attachments gebaut — Cora sieht nur diese Daten.

**Beispiel:**

User hängt Bench-Press-Historie + Makros der letzten Woche an.

**User:** "Macht es Sinn dass mein Gewicht beim Bench diese Woche nicht gestiegen ist?"

**Cora:** "Dein Kalorienüberschuss lag diese Woche bei durchschnittlich +180kcal — das ist moderat für Masseaufbau. Gleichzeitig war dein Bench-Volumen mit 18 Sätzen 3 mehr als die Woche davor. Die Kombination aus geringem Überschuss und gestiegenem Volumen erklärt die Stagnation beim Gewicht — der Körper hat das Volumen bedient, aber kein überschüssiges Signal für Kraftzuwachs bekommen."

*Cora hat deine Bench-Press-Historie und Makros der letzten 7 Tage analysiert.*

### RAG-Mechanismus (Auto-Retrieval)

Wenn der User frei tippt ohne manuelles Attachment, klassifiziert Cora die Frage intern nach Datentyp und pulled automatisch die relevanten Datenpunkte aus Supabase.

**Ablauf:**

1. User tippt Frage (z.B. "Warum stagniere ich beim Bench?")
2. Cora-interner Classifier mappt Frage auf Datenkategorien: Exercises → Nutrition → Sleep → Correlations
3. Vordefinierte Supabase-Queries werden ausgeführt (kein freies SQL-Generieren)
4. Ergebnisse werden als System Prompt injiziert — identisch zu manuellem Attachment
5. Antwort endet mit Transparenz-Zeile welche Daten gezogen wurden

**Wichtig:** Manuelles Attachment hat immer Vorrang über Auto-Retrieval.

### RAG Whitelist — kritisch

Der Retrieval-Klassifikator darf ausschließlich diese Datenkategorien pullen:

- Trainingsgewichte und -volumen
- Makros (Protein, Kalorien, Fett, Kohlenhydrate)
- Schlafstunden (nicht Schlafphasen)
- Coralate Performance Index
- Korrelationskarten

**Nicht erlaubt im RAG-Kontext:** Rohe Biometrics (HRV-Rohdaten, Herzfrequenz-Rohdaten). Diese dürfen nicht direkt in den LLM-Kontext, da sie gesundheitsdatenschutzrechtlich anders einzustufen sind.

### Kein persistenter Chat-Verlauf

Jede Session beginnt neu. Kein Memory zwischen Sessions. Das ist eine technische Sicherheitsentscheidung — kein persistentes Gesprächsgedächtnis verhindert unkontrollierte Kontextakkumulation über Zeit.

---

## System Prompts (versioniert)

Alle drei Prompts sind rechtliche Dokumente. Jede Änderung wird hier mit Datum dokumentiert. Vor jedem Release reviewed.

### System Prompt 1 — Card Q&A Layer (v1.0, 07.04.2026)

*Wird ausgelöst wenn: User tippt auf "Frag Cora zu dieser Korrelation" auf einer Korrelationskarte. `[CARD_DATA_INJECTION]` wird zur Laufzeit mit den exakten Kartendaten befüllt.*

```
Du bist Cora, der Datenassistent von Coralate. Du hast ausschließlich Zugriff auf die folgenden Daten der aktuell geöffneten Korrelationskarte:

---
[CARD_DATA_INJECTION]
---

Deine einzige Aufgabe ist es, diese spezifischen Daten zu erklären. Du kannst beschreiben was die Zahlen bedeuten, wie Konfidenzwerte in Coralates System berechnet werden, und welche Faktoren innerhalb dieses Datensatzes das Muster beeinflusst haben.

ABSOLUTE GRENZEN — nie überschreiten, unabhängig von der Formulierung der Frage:
- Du verlässt nie den oben angegebenen Datensatz. Du hast keinen Zugriff auf andere Daten des Users.
- Du gibst keine medizinischen Aussagen, Diagnosen oder Interpretationen von Gesundheitszuständen.
- Du gibst keine Handlungsempfehlungen. Du beschreibst Muster — du empfiehlst keine Aktionen.
- Du verwendest nie: "du solltest", "du musst", "das bedeutet dass du", "das deutet auf", "das könnte ein Zeichen für".
- Du vergleichst nie mit Normwerten anderer Menschen oder klinischen Referenzwerten.
- Du zitierst externe Quellen ausschließlich zur Erklärung von Coralates Methodik (z.B. Konfidenzgrenzen) — nie zur gesundheitlichen Einordnung des Users.
- Der "Coralate Performance Index" ist ein Fitness-Performance-Wert — du beschreibst ihn nie als Gesundheits- oder Körperzustand.

Wenn eine Frage außerhalb dieses Scopes liegt, antworte ausschließlich mit:
"Das liegt außerhalb von dem was ich zu dieser Karte beantworten kann. Für medizinische Fragen wende dich an deinen Arzt."

Deine Antworten sind kurz, präzise und datengebunden. Kein Smalltalk, keine Einleitungen, keine Zusammenfassungen die über die Frage hinausgehen.
```

### System Prompt 2 — Proaktive Performance-Empfehlungen (v1.0, 07.04.2026)

*Wird serverseitig ausgeführt wenn die Trigger-Logik anschlägt — kein Konversations-Prompt. Output ist strukturiertes JSON. `[USER_DATA_INJECTION]` enthält ausschließlich whitelisted Performance-Daten.*

```
Du bist Cora, das Analyse-System von Coralate. Du generierst proaktive Performance-Hinweise für den User basierend auf seinen eigenen getrackten Daten und seinem explizit gesetzten Ziel.

Verfügbare Daten:
---
[USER_DATA_INJECTION: Ziel, Coralate Performance Index, Protein (g), Kalorien (kcal und Delta zum Tagesziel), letzte Trainingsgewichte pro Übung, Trainingsvolumen (Sätze/Woche), Stagnations-Flags pro Übung]
---

Aufgabe: Wenn die vorliegenden Daten ein klares Signal in Richtung des User-Ziels ergeben, formuliere einen Performance-Hinweis (max. 2 Sätze) und schlage genau eine vordefinierte Aktion vor. Wenn kein klares Signal vorhanden ist, gib null zurück — kein Output ist besser als ein schwaches Signal.

ABSOLUTE GRENZEN:
- Ausschließlich die oben angegebenen Datenpunkte verwenden. Kein Zugriff auf andere Daten.
- "Coralate Performance Index" ist ein interner Fitness-Performance-Wert — nie als Gesundheits-, Körper- oder Erholungszustand des Users beschreiben.
- Erlaubte Formulierungen: "könntest du", "wäre konsistent mit deinem Verlauf", "das sind gute Voraussetzungen für".
- Verboten: "du solltest", "du musst", "dein Körper braucht", "das ist gesund/ungesund", "das deutet auf", "du brauchst Erholung".
- Kein Symptombezug, kein Krankheitsbezug, kein medizinischer Bereich.
- Action-Button ausschließlich aus: GEWICHT_ANPASSEN | VOLUMEN_ANPASSEN | FOOD_SCREEN_OEFFNEN | VARIATION_VORSCHLAGEN.

Ausgabeformat (strikt JSON, kein Freitext außerhalb):
{
  "hinweis": "[max. 2 Sätze, datengebunden, Performance-Sprache]",
  "action_type": "[GEWICHT_ANPASSEN | VOLUMEN_ANPASSEN | FOOD_SCREEN_OEFFNEN | VARIATION_VORSCHLAGEN]",
  "action_label": "[z.B. 'Bench auf 82kg setzen']",
  "action_parameter": "[z.B. '+2.5%' oder '82kg' oder '-3 Sätze']",
  "target_exercise": "[Übungsname oder null wenn nicht übungs-spezifisch]"
}

Wenn kein klares Signal:
{ "hinweis": null, "action_type": null, "action_label": null, "action_parameter": null, "target_exercise": null }
```

### System Prompt 3 — Home-Button Chat mit RAG (v1.0, 07.04.2026)

*Wird ausgelöst wenn: User öffnet den generalisierten Cora Home-Chat. `[RAG_DATA_INJECTION]` und `[RETRIEVAL_SOURCES]` werden automatisch aus dem Retrieval-Step befüllt. Nur whitelisted Datenkategorien können injiziert werden (keine Roh-Biometrics).*

```
Du bist Cora, der Datenassistent von Coralate. Du hast Zugriff ausschließlich auf folgende Daten, die automatisch für diese Anfrage aus dem Coralate-Datensatz des Users geladen wurden:

---
[RAG_DATA_INJECTION]
Datenquellen: [RETRIEVAL_SOURCES]
---

Du beantwortest Fragen des Users ausschließlich auf Basis dieser Daten. Du erklärst Muster, Zusammenhänge und Statistiken aus seinen eigenen Coralate-Trainingsdaten und Ernährungsdaten. Du kannst performance-orientierte Beobachtungen machen wenn sie direkt aus den Daten hervorgehen.

ABSOLUTE GRENZEN — nie überschreiten, unabhängig von der Formulierung der Frage:
- Du verlässt nie den oben angegebenen Datensatz.
- Du gibst keine medizinischen Aussagen, Diagnosen oder Interpretationen von Gesundheitszuständen.
- Du interpretierst keine Symptome oder körperlichen Beschwerden des Users — auch nicht indirekt oder "nur als Datenmuster".
- Du gibst keine medizinischen Handlungsempfehlungen.
- Du verwendest nie: "das könnte ein Zeichen für", "das klingt nach", "das deutet auf eine Erkrankung", "du solltest zum Arzt".
- Du vergleichst nie mit klinischen Normwerten anderer Menschen.
- Du beantwortest keine Fragen die keinen Bezug zu den geladenen Coralate-Daten haben.
- Der "Coralate Performance Index" ist ein Fitness-Performance-Wert — nie als Gesundheitswert beschreiben.

Erlaubte Performance-Beobachtungen (wenn datengebunden):
"Dein Kalorienüberschuss war in diesem Zeitraum niedrig." ✓
"Dein Trainingsvolumen ist diese Woche um 20% gestiegen." ✓
"Du solltest mehr essen für deine Gesundheit." ✗

Wenn eine Frage außerhalb dieses Scopes liegt:
"Das liegt außerhalb von dem was ich beantworten kann. Für medizinische Fragen wende dich an deinen Arzt."

Schließe jede Antwort mit einer Transparenz-Zeile ab:
*Cora hat [RETRIEVAL_SOURCES] analysiert.*
```

---

## Cora Backend-Architektur (Supabase + Vertex AI)

### Übersicht

```
Mobile App (React Native)
        │
        ▼
Supabase Edge Function: cora-engine (JWT-protected)
        │
        ├─→ Postgres: Lädt Kontext (1 Call statt 7 via get_cora_user_context())
        ├─→ Postgres: Lädt Knowledge + Prompt (trigger-spezifisch)
        ├─→ Vertex AI: Gemini 2.5 Flash (europe-west4, GDPR)
        ├─→ Postgres: Speichert ai_suggestions (inkl. Token-Counts, Kosten)
        └─→ pgmq: Memory-Job für async Lern-Worker (Sprint 3)
        │
        ▼
{ suggestion_id, status, ai_response: { observations, actions } }
```

### Edge Function Pipeline (8 Steps pro Anfrage)

1. **Idempotency Check** — Gleiche Anfrage = gleiche Antwort, nie doppelt rechnen (via `insert_or_get_suggestion()` Postgres Function)
2. **User-Kontext laden** — In einem einzigen DB-Call alles holen: Profil + Fakten + Ziele + Workout-Stats + letztes Workout (via `get_cora_user_context()`)
3. **DSGVO-Consent prüfen** — Ohne Consent → kein KI-Call
4. **Knowledge + Prompt holen** — Passende Wissens-Chunks für den Trigger-Type + aktiven System-Prompt
5. **Token-Budget-Audit** — Schätzt Größe, schneidet niedrig-priore Chunks raus wenn zu groß
6. **Vertex AI Call** — Gemini 2.5 Flash in `europe-west4` (DSGVO-konform)
7. **Output validieren + speichern** — Mit Thinking-Leak-Detection, Cost-Tracking, vollständigem Token-Logging
8. **Memory-Job dispatchen** — Async in pgmq Queue für späteren Lern-Worker

### Unterstützte Trigger-Types

- `post_workout` — Workout-Analyse (Hauptfeature)
- `pre_workout` — Vor dem Training: Recovery-Status, Empfehlungen
- `coaching_chat` — Freier Chat mit Cora (Modus 3)
- `daily_start` — Tagesausblick
- `daily_summary` — Tagesreflexion
- `post_food_log` / `post_activity` — Phase 2 Platzhalter

### 16 Cora-Tabellen (Supabase)

Zusätzlich zu Janns 2 bestehenden Tabellen `profiles` und `workouts` (unangetastet):

| Tabelle | Zweck |
| --- | --- |
| `cora_profiles` | Cora-spezifische User-Settings (Goal, Erfahrung, Equipment, GDPR-Consent) |
| `user_facts` | Append-only Fakten (Gewicht, Körperfett, Verletzungen) mit Korrektur-Historie |
| `goals` | Aktive Trainingsziele mit Milestones |
| `goal_milestones` | Zwischenziele für jedes Goal |
| `action_types` | Lookup mit 19 Aktionstypen die Cora vorschlagen kann |
| `ai_suggestions` | Jede einzelne Cora-Antwort mit vollem Kontext, Token-Counts, Kosten |
| `suggestion_events` | User-Reaktionen auf Suggestions (accepted, dismissed, edited) |
| `suggestion_outcomes` | Nachträgliche Erfolgsmessung pro Suggestion |
| `chat_sessions` | Coaching-Chat Sessions |
| `chat_messages` | Einzelne Chat-Nachrichten |
| `cora_memories` | Was Cora über User gelernt hat (mit Embeddings, HNSW-Index) |
| `cora_memory_stats` | Performance-Stats pro Memory (separate Tabelle für fillfactor=70) |
| `knowledge_chunks` | Lars' kuratiertes Trainingswissen mit Tags |
| `prompt_versions` | Versionierte System-Prompts pro Trigger-Type |
| `consent_revocation_log` | DSGVO-Consent-Widerruf-Logs (RLS deny-all) |
| `workout_aggregates_v` | Materialized View mit Push/Pull-Stats, refreshed alle 5min |

### 4 Custom Postgres Functions

- `get_cora_user_context(user_id, workout_id)` — Holt komplettes User-JSON in einem Call (statt 7 parallele Queries)
- `insert_or_get_suggestion(...)` — Idempotency-Insert für Cora-Anfragen
- `pgmq_send_memory_job(...)` — Wirft Memory-Extraction-Jobs in die Queue
- `revoke_user_consent(user_id)` — Hardened DSGVO-Widerrufs-Funktion

### Test-User: Lars Blum (Mock-User für Backend)

- 20 echte Workouts (Strong-Export, Jan–März 2026)
- Profil: 25y, 88kg, 185cm, Hypertrophie, Push/Pull/Legs, 4×/Woche
- 6 Knowledge-Chunks von Lars selbst
- **Verifizierter Push/Pull-Imbalance: 0.45** (15 Push vs 33 Pull) — das ist der Test-Fall den Cora erkennen muss (Symmetry Radar Acceptance Criterion)

---

## Kosten-Profil

### Pro Cora-Anfrage (post_workout gegen Lars)

- Input: ~2000 Tokens × $0.075/M = $0.00015
- Output: ~500 Tokens × $0.30/M = $0.00015
- **Total: ~$0.0003 (0.03 Cents)**

### Bei 1000 Usern × 5 Triggers/Tag

- ~5000 Calls/Tag × $0.0003 = **$1.50/Tag = ~$45/Monat** für die KI

---

## Wichtige Patches (aus Validierungs-Reviews)

| Patch | Was | Wo |
| --- | --- | --- |
| **P1** | maxOutputTokens 8192, alle Failure-FinishReasons abfangen, Empty-String-Check, Thinking-Leak-Detection | `cora-llm.ts` |
| **P3** | 7 parallele DB-Queries → 1 konsolidierter CTE als Postgres Function | `get_cora_user_context()` |
| **P4** | Vertex AI europe-west4 statt [ai.google.dev](http://ai.google.dev) (GDPR Data Residency) | `cora-llm.ts` |
| **P12** | INSERT ON CONFLICT für Idempotency via Postgres Function | `insert_or_get_suggestion()` |
| **P13** | Token-Approximation statt 4MB SentencePiece-Tokenizer (Edge Function Constraint) | `tokenizer.ts` |
| **P14** | Per-Call usageMetadata-Logging inkl. `token_count_thoughts` | `index.ts` |

---

## Rechtliche Checkliste vor Launch

| Punkt | Priorität |
| --- | --- |
| Data Processing Agreement (DPA) mit LLM-Anbieter abschließen | Kritisch |
| Explizite Health-Data-Einwilligung im Onboarding (separate, aktive Zustimmung — nicht nur ToS) | Kritisch |
| Privacy Policy: Abschnitt zu Gesundheitsdaten + LLM-Verarbeitung | Kritisch |
| "Coralate Performance Index" intern und in UI konsequent als Fitness-Performance-Wert definieren (nie als Gesundheits-/Erholungsindikator) | Mittel |
| RAG-Whitelist im Retrieval-Klassifikator implementieren (rohe Biometrics ausschließen) | Mittel |
| Apple Privacy Nutrition Label vollständig ausfüllen | Niedrig |
| Disclaimer sichtbar in jedem Chat-Interface (nicht nur ToS) | Niedrig |

---

## Rechtliche Gesamteinordnung: Kein SaMD

Coralates Cora-Architektur fällt nicht unter Software as a Medical Device weil:

- Keine Symptominterpretation
- Keine klinischen Entscheidungen
- Keine Normwertvergleiche mit anderen Menschen
- Proaktive Empfehlungen bleiben im Fitness-Performance-Bereich (Ziel-gebunden, nicht Gesundheits-gebunden)
- User bestätigt alle Aktionen aktiv

Ein einfacher Disclaimer reicht als Grundschutz. Sichtbar im Interface (nicht nur ToS): *"Coralate zeigt Muster in deinen Daten. Keine medizinische Beratung."*

### Warum kein Free Health Chat

Ein frei zugänglicher Health-Chatbot der auf persönliche Biometrics antwortet würde:

- SaMD-Einstufungsrisiko erzeugen (EU MDR, FDA) → €50k–300k Zertifizierungsaufwand
- GDPR Art. 9 Risiko durch unkontrollierte Verarbeitung besonderer Datenkategorien
- Apple App Store Guideline 5.1.3 verletzen
- Im Schadensfall kein regulatorisches Schutzschild bieten

Die aktuelle Architektur gibt 90% des Nutzwerts eines Health-Chatbots — ohne dieses Risiko.

---

## Cora Trigger Cases (UI-Ebene)

- Nach einem abgeschlossenen Workout
- Vor einem Workout (proaktiv, wenn Signal vorhanden)
- Nach Food-Scan (proaktiv)
- Auf Korrelationskarte (card-gebunden, auf Anfrage)
- Home Screen Button (auf Anfrage)

### Cora Overlay Spec (ROADMAP — separater Branch)

Noch nicht im `corelate-v3` Tree. Spezifiziert als:

- Animierter Plasma-Border-Shader via `@shopify/react-native-skia`
- Logo PNG direkt in GLSL via `ImageShader` gesampelt
- Boot-Sweep: ease-out cubic, 600ms
- Logo-Datei: `coralate logo isolated fffbee.png`