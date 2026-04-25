---
typ: aufgabe
name: "Cora AI Architektur (3 Modi, SaMD, RAG)"
projekt: "[[cora-ai]]"
status: in_arbeit
benoetigte_kapazitaet: hoch
kontext: ["desktop"]
kontakte: ["[[jann-allenberger]]", "[[lars-blum]]"]
quelle: notion_migration
vertrauen: extrahiert
erstellt: 2026-04-16
---

Vollständige technische + rechtliche Dokumentation der Cora AI-Schicht. Stand 2026-04-09.

## Architektur

- **Deployment:** Supabase Edge Function `cora-engine` in Production (JWT-protected)
- **LLM:** Google Vertex AI Gemini 2.5 Flash in `europe-west4` (GDPR Data Residency)
- **Supabase Project:** `vviutyisqtimicpfqbmi` (eu-west-1, Postgres 17)
- **Extensions aktiv:** `pgvector` (HNSW-Index für Memory-Embeddings), `pgmq` (Job-Queues), `pg_cron` (Scheduled Jobs)
- **Drei Modi gelocked:** Proaktiv (Narrator) / Card Q&A / Home-Chat mit RAG
- **SaMD-Position nicht verhandelbar:** Cora ist kein Gesundheitsassistent

## Was Cora ist und was nicht

Cora ist Coralates analytische KI-Schicht. Erkennt Muster in den eigenen Fitness-/Ernährungsdaten des Users, macht sie verständlich, schlägt im Fitness-Performance-Bereich konkrete Aktionen vor.

**Cora ist kein Gesundheitsassistent.** Keine Symptominterpretation, keine Diagnosen, keine medizinischen Ratschläge.

### Warum diese Grenze existiert

Eine App die personalisierte Gesundheitsempfehlungen auf Basis von Biometrics gibt, kann als **Software as a Medical Device (SaMD)** eingestuft werden - unter EU MDR und FDA 21 CFR Part 820. SaMD-Zertifizierung kostet €50k-300k, dauert 6-24 Monate, erzwingt Change-Control-Prozess bei jedem Feature-Release. Für früh-stage Startup existenzbedrohend.

Ein Disclaimer ("keine medizinische Beratung") schützt nicht vor dieser Einstufung. Regulatoren schauen auf die **Funktion**, nicht die Bezeichnung. Coralates Architektur ist so gebaut dass sie funktional außerhalb des SaMD-Territoriums bleibt.

### Was Cora darf vs. nicht darf

| Erlaubt | Verboten |
|---|---|
| Muster in eigenen Trainingsdaten erklären | Symptome oder Körperzustände interpretieren |
| Korrelationen zwischen Ernährung und Performance zeigen | Diagnosen stellen oder andeuten |
| Performance-Vorschläge auf Basis von Ziel + Trainingsdaten | Normwertvergleiche mit anderen Menschen |
| Konfidenz und Methodik erklären | "Du solltest", "du musst", "das deutet auf" |
| Fitness-Parameter anpassen vorschlagen (mit User-Bestätigung) | Medizinische Handlungsempfehlungen |

### Formulierungsregel für alle Cora-Outputs

> Datenbeobachtung + Zielbezug + offene Möglichkeit - nie Anweisung, nie Diagnose

## Modus 1 - Proaktiver Narrator

Cora taucht proaktiv auf ohne User-Frage. Prüft im Hintergrund ob Daten ein klares Signal in Richtung User-Ziel ergeben, meldet sich wenn ja. Output: kurzer Hinweis + direkt ausführbarer Action-Button.

### Trigger-Logik (alle 3 müssen erfüllt sein)

1. User hat explizites Ziel gesetzt ("Masse aufbauen", "Kraft steigern", "Abnehmen")
2. Mindestens zwei relevante Datenpunkte für den Tag (z.B. Protein-Tracking + Performance Index)
3. Kombination ergibt eindeutiges Signal in Richtung des Ziels

**Schweigen ist besser als ein schwaches Signal zu überinterpretieren.**

### Vordefinierte Action-Button-Typen

Cora wählt ausschließlich aus diesen vier. Kein freies Action-Generieren.

| Typ | Wann | Beispiel-Label |
|---|---|---|
| `GEWICHT_ANPASSEN` | Performance hoch + Ziel Kraft/Masse | "Bench auf 82kg setzen" |
| `VOLUMEN_ANPASSEN` | Performance niedrig oder Volumen zu hoch | "Heute 3 Sätze weniger" |
| `FOOD_SCREEN_OEFFNEN` | Kaloriendefizit zu groß für Ziel | "Mahlzeit hinzufügen" |
| `VARIATION_VORSCHLAGEN` | Stagnation bei Übung ≥ 3 Wochen | "Gewicht -10%, Wdh +3" |

### Beispiele

**Ziel Masseaufbau, Datenlage:** 178g Protein getrackt (Ziel 160g), Performance Index 87%, letztes Bench 80kg.
> "Du hast heute dein Proteinziel übertroffen und dein Performance-Index ist hoch - das sind gute Voraussetzungen für eine intensive Einheit. Beim Bench Press warst du zuletzt bei 80kg." **[Gewicht auf 82kg setzen]**

**Ziel Abnehmen:** 340kcal unter Tagesziel, Schlaf 7.4h, kein Training heute.
> "Du liegst heute deutlich unter deinem Kalorienziel und hast gut geschlafen - das wären gute Bedingungen für ein Cardio-Workout." **[Cardio-Training hinzufügen]**

**Ziel Kraft:** Schulterdrücken stagniert seit 21 Tagen bei 52.5kg.
> "Dein Schulterdrücken stagniert seit 3 Wochen. Dein Volumen ist gestiegen, aber das Gewicht nicht - eine Variation könnte das Signal für Kraftzuwachs wieder setzen." **[Gewicht -10%, Wdh +3 vorschlagen]**

### Rechtliche Einordnung

Action-Button setzt Trainingsparameter den User selbst kontrolliert - kein Körperstatus, keine Diagnose. Vergleichbar mit Kalender-App die "Termin verschieben?" vorschlägt. User bestätigt aktiv - Cora führt nie automatisch aus. Jede Aktion wird im Log als "Cora-Vorschlag" markiert (Audit-Trail).

**Wichtig:** Der "Coralate Performance Index" ist ein intern berechneter Fitness-Performance-Wert - darf in keinem Output als Gesundheits- oder Erholungsindikator beschrieben werden. Nur als Performance-Metrik im Kontext des Trainingsziels.

## Modus 2 - Card Q&A (kontextsensitiv)

User öffnet eine Korrelationskarte in Coralate. Einstieg: "Frag Cora zu dieser Korrelation". Chat öffnet sich technisch auf genau diese eine Karte beschränkt. Cora erklärt die Karte, verlässt den Datensatz der Karte nie.

Kein Chatbot - eine **kontextsensitive Erklärungsebene** im Chat-Format.

## Modus 3 - Home-Chat mit RAG

Freier Chat mit Auto-Retrieval aus whitelisted Datenkategorien. RAG greift nur auf definierte Daten zu (Workouts, Ernährung, Aktivität, Gewicht etc.). Niemals auf medizinische Daten oder Inferenzen darüber.

## Pipeline (Backend)

- Edge Function `cora-engine` als JWT-protected Endpoint
- Vertex AI Gemini 2.5 Flash in europe-west4 (GDPR Data Residency)
- pgvector HNSW-Index für Memory-Embeddings
- pgmq für Job-Queues (asynchrone Analysen)
- pg_cron für Scheduled Jobs (tägliche Analysen)
- 16 Supabase-Tabellen in der Cora-Architektur

## SaMD-Position - Nicht brechen

- **KEINE** Symptominterpretation / Diagnosen / klinischen Normwertvergleiche
- Proaktive Empfehlungen bleiben im Fitness-Performance-Bereich (ziel-gebunden)
- "Coralate Performance Index" ist IMMER Fitness-Performance-Wert, NIE Gesundheits-/Erholungsindikator
- User bestätigt jede Aktion aktiv
- Disclaimer sichtbar im Interface
