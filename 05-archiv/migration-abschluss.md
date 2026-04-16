# MIGRATION.md — Auftrag für Claude Code

Dieses File ist der Migrations-Auftrag. Nur relevant beim einmaligen Initial-Befüllen des Vaults. Nach Abschluss wird dieses File nach `05-archiv/migration-abschluss.md` verschoben.

---

## Deine Aufgabe (in einem Satz)

**Lies zwei Export-Ordner, destilliere deren Inhalt zu einem strukturierten Obsidian-Vault.**

Quellen:
- `C:\Users\deniz\Documents\notion\` — Notion-Export (Markdown + CSV)
- `C:\Users\deniz\Documents\claude\` — Claude Conversations (JSON)

Ziel:
- Dieser Vault (`C:\Users\deniz\Documents\miraculix\`) — vollständig befüllt nach Schema

---

## Master-Regel: Neueste Version gewinnt

Wenn dieselbe Info an zwei Stellen steht (z.B. Projekt-Status in Notion und in Chat), nimm die **chronologisch spätere**.

Claude-Chats haben Timestamps in JSON. Notion-Exports haben `_created_time` / `_last_edited_time` in Frontmatter oder Filename-Metadaten. Nutze die.

Wenn Timestamps fehlen: Chat > Notion (weil Chat typischerweise neuer ist als strukturierte Notion-Pages).

Bei Widerspruch ohne klare Zeitlichkeit: beide Versionen in Frontmatter-Kommentar dokumentieren, `vertrauen: angenommen` setzen, als ambig markieren.

---

## Phasen

### Phase A — Inventur (kein Schreiben in Ziel-Files)
1. Gehe rekursiv durch `C:\Users\deniz\Documents\notion\`. Liste alle Markdown-Files mit Titel und Größe.
2. Gehe durch `C:\Users\deniz\Documents\claude\`. Parse `conversations.json` (Index). Liste alle Conversations mit Titel, Datum, Länge.
3. Erkenne aus Titeln / Inhalten:
   - Welche Projekte existieren? (Über-Projekte, Sub-Projekte)
   - Welche Personen werden erwähnt?
   - Welche Themen / Domains tauchen auf (n8n, Supabase, Attio etc.)?
4. Schreibe Ergebnis nach `_migration/inventory.md` mit Sektionen:
   - **Projekte erkannt** (nach Hierarchie)
   - **Personen erkannt**
   - **Wissens-Domains erkannt**
   - **Nicht zuordenbare Files** (brauchen Deniz' Entscheidung)

**Stop-Point:** Nach Inventar-Abschluss einmal kurz zeigen: "Inventur fertig, X Projekte, Y Personen, Z Domains erkannt, W Files nicht zuordenbar. Soll ich fortfahren?" Wenn Deniz nicht antwortet und Context es erlaubt, **automatisch fortfahren nach 10 Sekunden Logging** — dies ist eine autonome Session.

### Phase B — Kontakte (`03-kontakte/`)
Für jede erkannte Person:
1. Scan alle Quellen nach diesem Namen und allen Varianten (z.B. "Maddox", "Max", "Maddox Y")
2. Extrahiere: Rolle, Verbindung zu Projekten, Email/Telefon falls vorhanden, wie kennengelernt
3. Erstelle `03-kontakte/{name-kebab-case}.md` nach Schema in `_meta/schema.md`
4. Aliases-Feld **sorgfältig befüllen** — das ist die Basis für Entity-Matching später

Commit nach Phase B: `migration: kontakte angelegt (N kontakte)`

### Phase C — Projekt-Hierarchie (`01-projekte/`)
1. Für jedes erkannte Über-Projekt: Ordner anlegen, `_projekt.md` schreiben mit Frontmatter nach Schema
2. Für jedes Sub-Projekt: Unterordner + `_projekt.md`
3. `status:` aus dem neuesten verfügbaren Stand ableiten (`aktiv` / `pausiert` / `archiviert`)
4. `notizen:` 1-2 Sätze Zusammenfassung
5. Im Body des `_projekt.md`:
   - `## Aktueller Stand` (aus neuester Quelle, mit Datum-Markierung)
   - `## Offene Aufgaben` (Checkbox-Liste, nur aktive Tasks)
   - `## Abgeschlossene Meilensteine` (durchgestrichen mit Datum)
   - `## Kontext` (was ist das Projekt überhaupt, für Außenstehende verständlich)

Commit nach jedem Über-Projekt: `migration: projekt {name}`

### Phase D — Logs & Meetings (`01-projekte/{projekt}/logs/`, `/meetings/`)
Für jede Claude-Conversation die einem Projekt zugeordnet werden kann:
1. Erstelle Log-Entry oder Meeting-Note je nach Inhalt:
   - **Log**: wenn es Arbeits-Session mit Problem+Lösung ist
   - **Meeting**: wenn es Transkript oder Notizen aus Gespräch ist
2. Filename: `{datum}-{kurztitel}.md`
3. Frontmatter nach Schema
4. Body: relevanter Inhalt aus Chat, destilliert (nicht Chat-Rohtext!)

**NIE den kompletten Chat-Rohtext einfügen.** Destilliere: was war das Problem, wie wurde es gelöst, welche Entscheidungen fielen, welche Patterns entstanden.

Rohe Chat-Logs bleiben in `00-eingang/chat-exports/` als Fallback-Referenz — lösche sie NICHT nach der Destillation.

Commit nach jedem Projekt-Ordner: `migration: logs/meetings {projekt}`

### Phase E — Wissens-Destillation (`02-wissen/`)
Scan alle erstellten Logs + Meetings auf Patterns die in 2+ Projekten vorkommen.
Beispiele:
- n8n Webhook-Problem bei HeroSoftware UND Resolvia → `02-wissen/n8n/webhook-pattern.md`
- Stripe-Attio-Matching-Logik → `02-wissen/crm-integration/stripe-attio-match.md`
- Supabase Edge Function Deno-Limits → `02-wissen/supabase/edge-function-limits.md`

Nur destillieren was:
- In **2 oder mehr verschiedenen Projekten** auftaucht
- Als **transferable Pattern** gelesen werden kann (nicht projekt-spezifisch)
- Aus den Quellen **eindeutig extrahierbar** ist

Vertrauen:
- 2× aufgetreten → `abgeleitet`
- 3× aufgetreten → `bestaetigt`
- Von Deniz explizit als Decision-Pattern markiert → `extrahiert`

Commit nach Phase E: `migration: wissen destilliert (N eintraege)`

### Phase F — Tagebuch (`04-tagebuch/`)
Wenn Claude-Chats klare Tages-Strukturen haben (morgens-Start, abends-Log): erstelle Daily Notes für die letzten 14 Tage.
Ansonsten: Phase F überspringen, Tagebuch startet leer ab heute.

### Phase G — Quality Gate
1. Alle Wikilinks prüfen — sind alle `[[references]]` valid?
2. Frontmatter-Schema-Check pro File — alle Pflichtfelder da?
3. Kontakt-Konsistenz — jeder in Projekten erwähnte Kontakt hat `03-kontakte/*.md`?
4. Keine Orphan-Files?

Bei gefundenen Problemen: Liste erstellen in `_migration/issues.md`, dann **beheben wo eindeutig möglich**. Rest in Report dokumentieren.

### Phase H — Abschluss-Report
Erstelle `_migration/report.md` mit:
- Zahlen: X Projekte, Y Kontakte, Z Logs, W Wissens-Einträge angelegt
- Ambiguitäten die Deniz reviewen muss
- Files die nicht zugeordnet werden konnten (liegen dann in `00-eingang/unverarbeitet/`)
- Empfehlungen für nächste Schritte

Final commit: `migration: abgeschlossen (phase A-H)`

---

## Regeln während der gesamten Migration

### 1. Progress Tracking
Schreibe nach **jeder** abgeschlossenen Phase einen kurzen Eintrag in `_migration/progress.md`:
```
## 2026-04-16 15:42 — Phase B abgeschlossen
- 11 Kontakte angelegt
- 2 ambige Matches (siehe issues.md)
- Commit: a3f2c1
```

Wenn die Session abbricht und neu startet, liest du `progress.md` und machst weiter wo du warst.

### 2. Entity-Matching-Aliases
Beim Anlegen eines Kontakts oder Projekts: **alle im Source-Material gefundenen Namensvarianten in `aliase:` Feld** eintragen.
Beispiele:
- `aliase: ["Maddox", "Max", "Maddox Y", "Maddox Yakymenskyy"]`
- `aliase: ["HeroSoftware", "Hero", "Hero Software", "HS"]`

Das ist kritisch — später findet Claude Daten nur wenn Aliases stimmen.

### 3. Commit-Granularität
Nach **jedem kompletten Sub-Projekt** ein Git-Commit. Nach **jeder Phase** ein Marker-Commit.

```bash
git add .
git commit -m "migration: phase B abgeschlossen (11 kontakte)"
```

### 4. Bei echten Ambiguitäten
Wenn du **wirklich nicht entscheiden kannst**:
- File in `00-eingang/unverarbeitet/` mit Prefix `AMBIG_{beschreibung}.md`
- In `_migration/issues.md` dokumentieren
- Weitermachen, nicht stoppen

Deniz wird die AMBIG-Files später selbst auflösen.

### 5. Destillieren, nicht kopieren
Chat-Transkripte sind **roh**. Projekt-Logs sind **destilliert**. Nie das gesamte Chat-Transkript als Log speichern. Sondern: Was war das Problem? Was wurde gelöst? Was sind die Key-Takeaways?

Rohe Chats bleiben in `00-eingang/chat-exports/` unberührt als Beweismittel.

### 6. Provenance-Pflicht
Jedes erstellte File bekommt in Frontmatter:
- `quelle:` — woher kam die Info (`notion_page` / `claude_chat` / `cross_reference`)
- `vertrauen:` — wie sicher (`extrahiert` / `abgeleitet` / `angenommen`)

Bei `angenommen`: kurz im Body erklären warum.

### 7. Keine Halluzinationen
Wenn du etwas nicht in den Quellen findest, **erfinde nichts**. Lass Felder leer oder markiere `angenommen`.

Beispiel: Wenn Maddox' Telefonnummer in keinem Source steht → `telefon: ""` lassen, nicht erfinden.

---

## Output-Qualitäts-Standards

Ein fertiges `_projekt.md` soll so aussehen dass Deniz es in 30 Sekunden scannen kann und **sofort** weiß:
- Was ist das für ein Projekt?
- Was ist der aktuelle Stand?
- Was sind die offenen nächsten Schritte?
- Wer ist involviert?

Wenn dein `_projekt.md` länger als **80 Zeilen** wird: Sub-Content raus in Logs oder Meetings.

Ein Kontakt-File darf **kurz** sein (Frontmatter + 3 Sätze). Tiefe kommt durch Projekt-Verknüpfungen.

Ein Wissens-Eintrag muss als **Referenz-Dokument** nutzbar sein — beim nächsten Auftreten des Problems liest Deniz oder Claude das und weiß was zu tun ist.

---

## Start-Prompt (wird von Deniz gegeben)

Deniz wird dich mit etwa dem folgenden Prompt starten:

> "Starte Migration. Arbeite selbstständig. Zeig nur bei wirklich ambigen Entscheidungen oder Widersprüchen. Commit nach jedem Projekt. Ich schau später rein."

Interpretation: **Autonome Session.** Du fragst nur wenn es wirklich nicht anders geht. Sonst: Progress loggen, committen, weitermachen.

---

## Nach Abschluss

1. Verschiebe diese `MIGRATION.md` nach `05-archiv/migration-abschluss.md`
2. Finaler Commit: `migration: abgeschlossen`
3. Letzter Output an Deniz: Zusammenfassung + Link zu `_migration/report.md`
4. Ab jetzt: Tages-Modus (siehe `CLAUDE.md`)
