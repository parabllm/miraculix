---
typ: aufgabe
name: "Knowledge-Chunks Guide fuer Lars"
projekt: "[[cora-ai]]"
status: entwurf
benoetigte_kapazitaet: mittel
kontext: ["desktop"]
kontakte: ["[[lars-blum]]"]
erstellt: 2026-04-18
quelle: extrahiert
vertrauen: extrahiert
notizen: "Entwurf. Finale use_cases haengen an der Cora-Positionierungsentscheidung (Meeting 2026-04-18). Siehe [[diskrepanzen]]."
---

Guide für Lars zum Schreiben und Verwalten von Cora's Knowledge-Chunks. Single Source of Truth ist Obsidian, die Supabase-Tabelle `knowledge_chunks` wird aus Obsidian gesynct.

## Warum Knowledge-Chunks

Cora hat kein eingebautes Fitness-Wissen. Alles was sie über Training, Recovery oder Ernaehrung weiss, kommt aus Knowledge-Chunks die Lars schreibt. Pro Anfrage zieht der Context-Builder die passenden Chunks aus der DB, packt sie in den Prompt, dann antwortet Gemini.

Heisst: Was nicht als Chunk existiert, weiss Cora nicht. Was schlecht formuliert ist, wird von Cora falsch verwendet.

## Workflow

1. Lars schreibt einen neuen Chunk als `.md` File in `cora-ai/knowledge-chunks/`
2. Lars markiert den Chunk als `is_active: true` im Frontmatter wenn er fertig ist
3. Deniz synct nach Supabase (Script oder manuell)
4. Cora benutzt den Chunk ab dem nächsten Request

Obsidian ist Master. DB ist Mirror. Nie direkt in der DB editieren.

## Ordnerstruktur

```
cora-ai/knowledge-chunks/
├── _template.md                          Vorlage zum Kopieren
├── symmetry_balance_prevention.md
├── progressive_overload_stagnation.md
├── volume_management_frequency.md
├── ...
```

Filename = `id` Feld im Frontmatter. Beide muessen matchen.

## Frontmatter-Felder

| Feld | Pflicht | Beschreibung |
|---|---|---|
| `id` | ja | Snake_case, eindeutig, gleicher Name wie File. Beispiel: `symmetry_balance_prevention` |
| `title` | ja | Kurzer Titel auf Deutsch, max 60 Zeichen |
| `category` | ja | Grobe Kategorie. Aktuell verwendet: `training_principle`, `recovery`, `nutrition`. Lars kann neue vorschlagen. |
| `tags` | ja | Array aus Stichworten. Englisch, snake_case. Beispiel: `["symmetry", "push_pull", "injury_prevention"]` |
| `use_cases` | ja | In welchen Situationen Cora den Chunk nutzen darf. Werte haengen an der Positionierungsentscheidung. Vorerst: `["general"]` als Platzhalter. |
| `priority` | ja | 1 bis 10. Hoch = wichtig. Cora zieht nur Top-N Chunks, Rest wird ignoriert wenn Token-Budget knapp. |
| `author` | ja | `lars` |
| `language` | ja | `de` |
| `version` | ja | Integer. Start bei `1`. Bei größerer Änderung um eins hoch. |
| `is_active` | ja | `true` wenn freigegeben, `false` wenn Draft oder deprecated. Nur aktive werden in Prompts gezogen. |
| `created_at` | ja | Datum ISO. `2026-04-18` |
| `updated_at` | optional | Datum ISO der letzten größeren Änderung |

## Content-Regeln

### Laenge

Ein Chunk ist 50 bis 200 Woerter. Nicht mehr. Lange Chunks fressen Token-Budget und verdraengen andere Chunks aus dem Prompt.

Wenn ein Thema mehr Platz braucht, splitte in zwei Chunks mit unterschiedlichen `id` und `tags`.

### Sprache und Ton

Deutsch. Sachlich, praezise, ohne Ich-Form. Cora zitiert den Chunk nicht woertlich, aber der Ton faerbt ab. Wenn Lars "du musst" schreibt, kommt Cora darauf zurück.

Verboten im Chunk-Content, weil Cora das sonst rausgibt:

- Anweisungen ("du musst", "du solltest")
- Medizinische Diagnostik ("Symptom", "Erkrankung", "Entzuendung")
- Absolute Grenzwerte für Einzelpersonen ("bei unter X Gramm Protein droht Muskelverlust")

Erlaubt:

- Prinzipien mit Bedingungen ("Wenn das Push-Pull-Verhaeltnis im Wochenschnitt unter 0.6 liegt, empfiehlt sich eine Pull-Priorisierung")
- Zahlenraeume statt Punktwerten ("1.6 bis 2.2g Protein pro kg Koerpergewicht für Hypertrophie")
- Wenn-Dann-Logik ("Bei Stagnation über 3 Wochen ist Variation sinnvoller als Volumen-Erhoehung")

### Struktur

Freier Fliesstext ist ok, aber scanbar bleiben. Wenn es 3 oder mehr Kriterien gibt, als Liste.

### Quellen

Wenn Lars eine konkrete Quelle zitiert (Paper, Buch, Studie), als letzte Zeile aufführen:

```
Quelle: Schoenfeld et al. 2023, Volume-Hypertrophy Meta-Analysis
```

Keine Quelle ist auch ok, dann markiert `vertrauen: abgeleitet` im Body. Cora weiss dass der Chunk dann vorsichtiger zu nutzen ist.

## Use-Cases (vorlaeufig)

Vorerst stehen die `use_cases` Werte nicht final fest. Sie haengen an der Cora-Positionierung die heute im Meeting geklaert wird.

Aktuelle Werte in der DB (wahrscheinlich zu ändern):

- `post_workout` nach Workout-Abschluss
- `pre_workout` vor Workout-Start
- `coaching_chat` freier Chat
- `daily_start` Tagesanfang
- `daily_summary` Tagesende
- `post_food_log` nach Mahlzeiten-Eintrag

Nach Positionierungsentscheidung wird das konsolidiert. Bis dahin: Lars schreibt einfach `use_cases: ["general"]` und Deniz mappt später.

## Priority-Guide

| Priority | Wann |
|---|---|
| 10 | Foundational. Ohne diesen Chunk trifft Cora falsche Entscheidungen. Beispiel: Push-Pull-Balance. |
| 8 bis 9 | Kern-Prinzipien. Breite Anwendung. Beispiel: Progressive Overload, Volume Management. |
| 6 bis 7 | Wichtig für Teilgruppen. Beispiel: Nutrition Timing für Kraftsportler. |
| 4 bis 5 | Spezifisch, nur bei passendem Kontext. Beispiel: Deload-Week Indikatoren. |
| 1 bis 3 | Rand-Wissen, Bonus. |

Cora pullt bei jedem Request nur Top-N Chunks nach priority, gefiltert nach `use_cases` und `tags`. Hohe Prio = höhere Wahrscheinlichkeit im Prompt.

## Review-Prozess

Bevor ein Chunk `is_active: true` bekommt:

1. Lars schreibt den Chunk
2. Deniz liest drüber, checkt auf SaMD-Verstoesse (Diagnose-Sprache, absolute medizinische Aussagen)
3. Eval: Testet den Chunk gegen 2 bis 3 typische Cora-Requests, schaut ob Output sauber ist
4. Wenn ok, `is_active: true` setzen, Sync

## Sync nach Supabase

Technisch: Ein Script liest alle `.md` Files im Ordner, parst Frontmatter und Body, schreibt nach `knowledge_chunks`. Upsert auf `id`.

Aktuell noch nicht automatisiert. Vorerst macht Deniz das manuell bei Bedarf. Lars sagt Bescheid wenn ein Chunk Review-reif ist.

## Offene Punkte

- Knowledge-Base-Groesse: Ziel 20 bis 30 Chunks für v1? Mehr? Muss mit Lars abgestimmt werden
- Embedding: Die Tabelle hat keine Vector-Embeddings aktuell, Retrieval laeuft über `use_cases` und `priority`. Wenn Chunks zu viele werden, muessen wir pgvector dranhaengen (MVP-Grenze laut Architektur: etwa 50 Chunks).
- Chunk-Versionierung bei Änderungen: aktuell wird alte Version überschrieben. Wenn wir History brauchen, muessen wir ein `knowledge_chunks_history` Table bauen.
- Migration der 6 bestehenden DB-Chunks in Obsidian: muss einmal initial gemacht werden. Deniz exportiert.

## Links

- Template: `_template.md` im selben Ordner
- Architektur-Kontext: [[cora-ai]]
- Aktueller DB-Stand: [[diskrepanzen]]
