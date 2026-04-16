# Schema - Frontmatter-Spezifikation

Jedes File im Vault (außer `00-eingang/unverarbeitet/`) hat YAML-Frontmatter nach diesem Schema.

---

## Über-Projekt (`{slug}.md` im Über-Projekt-Ordner)

Filename-Konvention: `01-projekte/{slug}/{slug}.md` - der Filename entspricht dem Ordnernamen. Grund: Obsidian-Wikilinks resolven auf Dateinamen, `_projekt.md` würde in allen Projekten denselben Namen haben und Verlinkungen unmöglich machen.

Beispiel: `01-projekte/thalor/thalor.md`, `01-projekte/hays/hays.md`

```yaml
---
typ: ueber-projekt
name: "Maddox"
aliase: ["Maddox", "Max", "Maddox Y"]
bereich: client_work          # client_work | produkt | intern | studium | persoenlich | gesundheit | familie
umfang: offen                 # offen | geschlossen
status: aktiv                 # aktiv | blockiert | ausgeliefert | pausiert | archiviert
kapazitaets_last: mittel      # niedrig | mittel | hoch
hauptkontakt: "[[maddox]]"
tech_stack: []
erstellt: 2026-04-16
notizen: ""
quelle: notion_migration      # notion_migration | claude_chat | manuell | voice_dump
vertrauen: extrahiert
---
```

---

## Sub-Projekt (`{slug}.md` im Sub-Projekt-Ordner)

Filename-Konvention: `01-projekte/{ueber-projekt}/{slug}/{slug}.md`

Beispiel: `01-projekte/thalor/herosoftware/herosoftware.md`

```yaml
---
typ: sub-projekt
name: "BellaVie Website"
aliase: ["BellaVie", "Bella V"]
ueber_projekt: "[[maddox]]"
bereich: client_work
umfang: geschlossen
status: aktiv
lieferdatum: 2026-05-30       # nur bei umfang: geschlossen
kapazitaets_last: mittel
kontakte: ["[[maddox]]"]
tech_stack: ["framer"]
notion_url: ""
erstellt: 2026-04-16
notizen: ""
quelle: notion_migration
vertrauen: extrahiert
---
```

---

## Aufgabe (als eigenes File, für komplexe Tasks)

Pfad: `01-projekte/{projekt}/aufgaben/{aufgabe}.md`

```yaml
---
typ: aufgabe
name: "Preisliste final anpassen"
projekt: "[[bellavie-website]]"
status: offen                  # offen | in_arbeit | erledigt | blockiert
benoetigte_kapazitaet: mittel  # niedrig | mittel | hoch
kontext: ["desktop"]           # desktop | unterwegs | offline | telefonat
geschaetzte_minuten: 30
faellig: 2026-04-18
kontakte: ["[[maddox]]"]
google_tasks_id: ""
quelle: notion_migration
vertrauen: extrahiert
erstellt: 2026-04-16
---
```

### Einfache Aufgaben (Checkbox im Projekt-File)

Für Tasks ohne eigene Datei, Checkliste direkt im `_projekt.md`:

```markdown
## Offene Aufgaben
- [ ] Icons einsammeln #niedrig
- [ ] SEO-Portal registrieren #mittel
- [x] Grundstruktur Homepage ~~2026-04-10~~
```

Regel: Wenn ein Checkbox-Task Logs, Meetings oder Sub-Aufgaben braucht → wird zu eigenem File.

---

## Log-Eintrag

Pfad: `01-projekte/{projekt}/logs/{datum}-{titel}.md`

```yaml
---
typ: log
projekt: "[[bellavie-website]]"
datum: 2026-04-16
art: fortschritt               # fortschritt | entscheidung | meeting | fehler_fix | meilenstein | notiz
vertrauen: extrahiert
quelle: chat_session            # chat_session | voice_dump | meeting | tool_output | manuell
werkzeuge: []
---
```

Logs sind append-only. Nie editieren, nur neue erstellen.

---

## Meeting-Note / Transkript

```yaml
---
typ: meeting
projekt: "[[bellavie-website]]"
datum: 2026-04-16
teilnehmer: ["[[maddox]]"]
ist_transkript: false
zusammenfassung: ""
offene_punkte: []
quelle: transkript
---
```

---

## Wissens-Eintrag

Pfad: `02-wissen/{domain}/{titel}.md`

```yaml
---
typ: wissen
name: "n8n Webhook Race-Condition Pattern"
aliase: ["Race Condition Fix"]
domain: ["n8n", "webhook"]
kategorie: pattern             # pattern | referenz | entscheidung | debug_fix | tool
vertrauen: bestaetigt          # extrahiert | abgeleitet | angenommen | bestaetigt
quellen:
  - "[[01-projekte/thalor/herosoftware/logs/2026-03-12-webhook-fix]]"
projekte: ["[[herosoftware]]", "[[resolvia]]"]
zuletzt_verifiziert: 2026-04-16
widerspricht: null
erstellt: 2026-04-16
---
```

---

## Kontakt

Pfad: `03-kontakte/{name}.md`

```yaml
---
typ: kontakt
name: "Maddox Yakymenskyy"
aliase: ["Maddox", "Max"]
gruppen: ["freelance", "freunde"]   # hays | hdwm | coralate | freelance | freunde | familie
verbindung: ["beruflich", "privat"]
rolle: entscheider                  # entscheider | kollege | stakeholder | mentor | lead
staerke: eng                        # eng | mittel | lose
projekte: ["[[bellavie-website]]"]
email: ""
telefon: ""
wie_kennengelernt: ""
notizen: ""
erstellt: 2026-04-16
vertrauen: extrahiert
quelle: notion_migration
---
```

---

## Daily Note

Pfad: `04-tagebuch/{jahr}/{monat}/{datum}.md`

```yaml
---
typ: tagebuch
datum: 2026-04-16
kapazitaet: 7                  # 1-10
kapazitaets_notiz: ""
fokus_projekte: []
---
```

---

## Eingangs-Item

Pfad: `00-eingang/unverarbeitet/{datum}-{kurztitel}.md`

```yaml
---
typ: eingang
quelle: voice_dump            # voice_dump | telegram | email | chat_export | datei | web_clip
empfangen: 2026-04-16T14:23:00Z
status: unverarbeitet          # unverarbeitet | verarbeitet | verworfen
vermutetes_projekt: ""
roh: true
---
```

---

## Feldtypen-Referenz

| Feld | Erlaubte Werte |
|---|---|
| `typ` | ueber-projekt, sub-projekt, aufgabe, log, meeting, wissen, kontakt, tagebuch, eingang |
| `status` (Projekt) | aktiv, blockiert, ausgeliefert, pausiert, archiviert |
| `status` (Aufgabe) | offen, in_arbeit, erledigt, blockiert |
| `umfang` | offen, geschlossen |
| `bereich` | client_work, produkt, intern, studium, persoenlich, gesundheit, familie |
| `vertrauen` | extrahiert, abgeleitet, angenommen, bestaetigt |
| `kapazitaets_last` / `benoetigte_kapazitaet` | niedrig, mittel, hoch |
| `kapazitaet` (Daily) | integer 1-10 |
