---
name: miraculix-vault-mcp-artefakt-erstellen
description: |-
  Triggered wenn Mobile-Claude (oder Claude ohne Filesystem-Zugriff) auf den Miraculix-Vault schreiben soll. Erstellt strukturierte Artefakte in 00-vault-mcp-eingang/ via vault_create_artefakt oder vault_update_artefakt.

  Auch triggern bei "leg im vault ab", "vault note", "schreib das in den vault", "speicher im vault", "ergänze das pulsepeptides projekt", oder allgemein wenn Deniz unterwegs Inhalte in den Vault bringen will.

  Nur relevant wenn vault_*-Tools verfügbar sind und kein nativer Read/Edit-Zugriff existiert (Mobile-Szenario). Auf Desktop oder Claude Code: NICHT triggern, dort wird direkt geschrieben.
---

# Vault-MCP-Artefakt erstellen (Mobile)

Mobile-Claude kann den Vault nicht direkt editieren. Stattdessen erstellt er Artefakte im Eingangs-Drop, die PC-Claude später kontrolliert in den echten Vault merged.

Volle Spec: `02-wissen/vault-mcp-architektur.md`. Diesen Skill als Schnellreferenz nutzen.

## Wann Artefakt anlegen

| Situation | Artefakt? |
|---|---|
| Deniz dump'd Gedanken oder Notizen unterwegs | Ja, Aktion `neue-datei` in passenden Projekt-Ordner ODER 00-eingang/unverarbeitet/ wenn unklar |
| Deniz will Update zu bestehendem Projekt-File | Ja, Aktion `ergaenzung` in passende Sektion |
| Deniz will eine ganze Sektion austauschen | Ja, Aktion `ersetzen-sektion` (mit Bedacht, riskanter) |
| Deniz fragt nach Info aus dem Vault | Nein, nur lesen via `vault_read_file` etc. |
| Deniz will systemweite Änderungen (CLAUDE.md, Schema, Skill-Logik) | Nein. Antwort: "Das muss am PC passieren, nicht über den Vault-MCP." |

## Tools verfügbar

- `vault_create_artefakt(filename, content)` - neues Artefakt
- `vault_update_artefakt(filename, content)` - existierendes überschreiben (selten nötig)
- `vault_list_eingang()` - schauen was schon im Eingang liegt
- Read-Tools (`vault_read_file`, `vault_search` etc.) zum Recherchieren bevor du schreibst

## Filename-Pattern (PFLICHT)

`YYYY-MM-DD-HHMM-{slug}-{aktion}.md`

- Datum + Uhrzeit aus aktuellem Zeitpunkt
- Slug: kebab-case, keine Umlaute, knapp (max 5 Wörter, z.B. `lager-tschechien-phase-2`, `pulse-status-update`)
- Aktion: genau einer von `neue-datei` / `ergaenzung` / `ersetzen-sektion`

Beispiele:
- `2026-04-29-1423-lager-tschechien-phase-2-neue-datei.md`
- `2026-04-29-1530-pulse-status-update-ergaenzung.md`
- `2026-04-29-1612-bellavie-tasks-ersetzen-sektion.md`

## Header-Schema (PFLICHT)

Jedes Artefakt beginnt mit YAML-Frontmatter. **Pflichtfelder für alle Aktionen:**

```yaml
---
typ: vault-mcp-artefakt
erstellt: YYYY-MM-DD HH:MM
quelle_geraet: mobile-handy
quelle_konversation: kurzer-titel-oder-hash
ziel_pfad: relativer/pfad/zur/zieldatei.md
ziel_aktion: neue-datei | ergaenzung | ersetzen-sektion
idempotenz_key: YYYY-MM-DD-HHMM-slug
body_sha256: <sha256 vom Body unter dem Frontmatter, hex-encoded>
status: bereit-zum-mergen
---
```

**Zusätzlich bei `ergaenzung` und `ersetzen-sektion`:**

```yaml
basis_mtime: <ISO-8601 Timestamp der Zieldatei beim Lesen>
basis_sha256: <sha256 der Zieldatei beim Lesen>
ziel_sektion: "Sektions-Heading ohne Markdown-Hashes"
ziel_heading_ebene: 2 | 3
einfuege_position: ende-der-sektion | anfang-der-sektion   # nur ergaenzung
```

`basis_sha256` ist wichtiger als `basis_mtime`. Mtime kann durch Sync verändert werden, Hash nicht.

## Body-Hash berechnen

Nach dem Frontmatter kommt der Body (alles unter dem zweiten `---`). Davon den SHA-256 Hash bilden und als `body_sha256` ins Frontmatter eintragen.

**Pflicht.** Leeres `body_sha256: ""` ist nicht erlaubt - PC-Merge kann den Body sonst nicht gegen Manipulation prüfen.

Wenn du keine Hash-Funktion ausführen kannst (selten), nutze als Fallback eine Pseudo-Hash-Strategie: erste 16 Zeichen des Bodys (nach Trim) plus Body-Länge als String, z.B. `body_sha256: "FALLBACK:erste-16-zeichen-len-1234"`. Markier im `pc_anweisung`-Feld dass Hash-Berechnung nicht möglich war, damit PC-Claude den Body manuell verifiziert.

## Drei Aktions-Typen

### A) `neue-datei`

Komplett neue Datei. PC-Claude prüft dass der Zielpfad noch nicht existiert.

```yaml
---
typ: vault-mcp-artefakt
erstellt: 2026-04-29 14:23
quelle_geraet: mobile-handy
quelle_konversation: planung-tschechien-phase-2
ziel_pfad: 01-projekte/pulsepeptides/lager-tschechien-phase-2.md
ziel_aktion: neue-datei
idempotenz_key: 2026-04-29-1423-lager-tschechien-phase-2
body_sha256: 7a1f...
verlinkungen_einbauen:
  - in: 01-projekte/pulsepeptides/pulsepeptides.md
    sektion: "Sub-Projekte"
    ziel_heading_ebene: 2
    text: "[[lager-tschechien-phase-2]] Phase 2 mit eigenem Standort"
status: bereit-zum-mergen
---

<!-- ALLES UNTER DIESER ZEILE IST DIE FERTIGE DATEI. -->

---
typ: projekt
projekt: "[[pulsepeptides]]"
status: planung
erstellt: 2026-04-29
zuletzt_aktualisiert: 2026-04-29
vertrauen: extrahiert
quelle: mobile-claude-artefakt-2026-04-29
---

# Lager Tschechien Phase 2

Folgeprojekt zur Maman-3PL-Phase-1.
```

`verlinkungen_einbauen` ist optional und sagt PC-Claude dass die neue Datei zusätzlich von einem oder mehreren bestehenden Files verlinkt werden soll.

### B) `ergaenzung`

Inhalt wird an eine bestehende Sektion angefügt.

```yaml
---
typ: vault-mcp-artefakt
erstellt: 2026-04-29 15:30
quelle_geraet: mobile-handy
quelle_konversation: pulse-status-call
ziel_pfad: 01-projekte/pulsepeptides/pulsepeptides.md
ziel_aktion: ergaenzung
ziel_sektion: "Aktuelle Kommunikation"
ziel_heading_ebene: 2
einfuege_position: ende-der-sektion
basis_mtime: 2026-04-29T15:05:00+02:00
basis_sha256: e3b0...
idempotenz_key: 2026-04-29-1530-pulse-status-update
body_sha256: a7c2...
status: bereit-zum-mergen
---

<!-- ALLES UNTER DIESER ZEILE WIRD AN ZIEL_SEKTION ANGEHAENGT. -->

### 2026-04-29 Mandak Updated Calculation

Mandak meldet sich nach Mail-Versand 28.04. Will Donnerstag Termin
fuer Pricing-Review. Updated Calculation kommt vorher.
```

### C) `ersetzen-sektion`

Eine bestehende Sektion wird komplett ersetzt. Riskanter als Ergänzung. Nur nutzen wenn Deniz explizit sagt "die ganze Sektion austauschen" oder Ähnliches.

```yaml
---
typ: vault-mcp-artefakt
erstellt: 2026-04-29 16:12
quelle_geraet: mobile-handy
quelle_konversation: bellavie-task-rebuild
ziel_pfad: 01-projekte/thalor/bellavie/bellavie.md
ziel_aktion: ersetzen-sektion
ziel_sektion: "Tasks"
ziel_heading_ebene: 2
basis_mtime: 2026-04-29T15:55:00+02:00
basis_sha256: c4f1...
idempotenz_key: 2026-04-29-1612-bellavie-tasks
body_sha256: f8d3...
status: bereit-zum-mergen
---

<!-- ALLES UNTER DIESER ZEILE ERSETZT DIE BESTEHENDE SEKTION KOMPLETT. -->

## Tasks

### Hoch

- [ ] SEO-Portal-Registrierung, Frist Freitag
- [ ] Icons von Maddox einsammeln
```

## Workflow

Wenn Deniz dir auf Mobile etwas zum Speichern gibt:

1. **Pfad-Erkundung (PFLICHT, nicht überspringbar)** - siehe Sektion "Pfad finden, nie raten" unten. Mindestens drei Tool-Calls bevor du `ziel_pfad` festlegst.
2. **Klassifizieren**: `neue-datei`, `ergaenzung` oder `ersetzen-sektion`? Antwort ergibt sich aus Schritt 1.
3. **Pre-Write-Checkliste durchgehen** (siehe unten). ALLE Punkte abhaken vor dem Schreiben.
4. **Header bauen**: Pflichtfelder, plus aktions-spezifische. Field-Namen EXAKT wie spezifiziert (`ziel_aktion` nicht `aktion`). Plus `pc_anweisung` Block (siehe "Selbsterklärendes Artefakt") mit Begründung warum dieser Pfad, welche Konvention gilt, welche Referenz-Files PC-Claude beim Merge ansehen soll.
5. **Bei ergaenzung/ersetzen-sektion**: Zieldatei lesen, `basis_sha256` und `basis_mtime` notieren, Sektion finden.
6. **Wikilinks prüfen**: Jeder `[[name]]` im Body muss auf existierende Datei zeigen. `vault_read_file` zum Verifizieren.
7. **Body bauen**: Eigentlicher Inhalt nach Schreibstil-Skill (`miraculix-schreibstil`).
8. **Hash berechnen**: SHA-256 vom Body, in `body_sha256`.
9. **Filename**: Pattern bauen, `vault_list_eingang()` checken auf Doppel-Filename.
10. **Schreiben**: `vault_create_artefakt(filename, content)`.
11. **Bestätigen**: Deniz kurz sagen was im Eingang gelandet ist, mit gewähltem Pfad und Begründung.

## Pfad finden, nie raten (PFLICHT)

Mobile-Claude darf einen Pfad NICHT erfinden. Die häufigsten Fehler bisher: erfundener `logs/`-Ordner, erfundene Top-Level-Folder wie `03-meeting-notes/`. Beide kommen daher dass Mobile nur ein Über-Projekt-Wort hatte und einen Pfad zusammengebaut hat.

Pflicht-Workflow vor jedem `ziel_pfad`:

### Schritt P.1: Über-Projekt identifizieren

Aus dem User-Input das Über-Projekt ableiten (HDWM, Pulsepeptides, Thalor, Coralate, HAYS, Bachelor-Thesis, Miraculix, Persönlich, Terminbuchung-App).

Bei Unsicherheit: `vault_read_file("_claude/skills/vault-system.md")` lesen, dort steht die aktive Über-Projekt-Tabelle.

### Schritt P.2: Über-Projekt-Struktur sondieren

```
vault_list_directory(path="01-projekte/{ueberprojekt}", depth=2)
```

Output ansehen: gibt es Sub-Projekte? Gibt es einen `logs/`-Ordner? Gibt es Semester-/Jahres-Strukturen? Gibt es ein zentrales `{ueberprojekt}.md` File?

### Schritt P.3: Über-Projekt-Hauptfile lesen

```
vault_read_file(path="01-projekte/{ueberprojekt}/{ueberprojekt}.md")
```

Output zeigt häufig die Konvention. Beispiele:
- Pulsepeptides hat `logs/` → projekt-lokale Logs üblich
- HDWM hat `semester-X/{vorlesung}.md` → Vorlesungs-Notes als Sektionen IN dem Vorlesungs-File, nicht als separate Files
- Thalor hat Sub-Projekte mit jeweils eigenen Strukturen → ein Schritt tiefer schauen

### Schritt P.4: Existierende ähnliche Files finden

```
vault_search(query="{themenbegriff}", scope="01-projekte/{ueberprojekt}")
```

Beispiel: bei einem Kalani-Call vorher `vault_search("kalani-call", scope="01-projekte/pulsepeptides")` aufrufen. Wenn Treffer in `01-projekte/pulsepeptides/logs/` landen → Konvention klar.

Bei Vorlesungs-Notes: `vault_search("Heinrich", scope="01-projekte/hdwm")` → siehst Sektionen in `innovationsmanagement.md`, also kein neuer File sondern Ergänzung.

### Schritt P.5: Konvention extrahieren und festhalten

Aus den Tool-Outputs die Konvention zusammenfassen. Drei mögliche Ergebnisse:

| Konvention erkannt | Mobile-Aktion |
|---|---|
| **Sub-Files in einem Ordner** (z.B. `pulsepeptides/logs/YYYY-MM-DD-thema.md`) | `ziel_aktion: neue-datei`, Pfad mit gleichem Pattern bauen |
| **Sektion in einem Hauptfile** (z.B. `hdwm/semester-6/innovationsmanagement.md`) | `ziel_aktion: ergaenzung`, `ziel_sektion` setzen, basis_sha256 berechnen |
| **Keine klare Konvention** | nicht raten - bei Deniz nachfragen oder als Annahme im `pc_anweisung`-Feld vermerken und Deniz beim Bestätigen mitteilen |

### Beispiel: HDWM-Innovationsmanagement (Lessons aus 2026-04-29)

User sagt "leg eine Note für Innovationsmanagement an".

Falsch: direkt `01-projekte/hdwm/logs/2026-04-29-innovationsmanagement.md` annehmen.

Richtig:
1. `vault_list_directory("01-projekte/hdwm", depth=2)` → sieht `semester-5/`, `semester-6/`, `hdwm.md`. KEIN `logs/`.
2. `vault_read_file("01-projekte/hdwm/semester-6/semester-6.md")` → sieht "Vorlesungen: [[innovationsmanagement]]"
3. `vault_read_file("01-projekte/hdwm/semester-6/innovationsmanagement.md")` → sieht Sektion "## Zusammenfassungen" mit existierender Untersektion "### 2026-04-29 - Absprache Prüfungsleistung..."
4. Konvention erkannt: pro Termin eine Untersektion in `## Zusammenfassungen`. → `ziel_aktion: ergaenzung`, `ziel_sektion: "Zusammenfassungen"`, basis_sha256 von der innovationsmanagement.md berechnen.

Nicht raten, immer sondieren.

## Selbsterklärendes Artefakt (für PC-Merge)

PC-Claude sieht beim Merge nur das Artefakt, nicht die Mobile-Konversation. Damit der PC-Merge ohne Rückfrage durchläuft, baut Mobile alle relevanten Findings in den Artefakt-Header ein.

Pflicht-Feld zusätzlich zum Standard-Schema:

```yaml
pc_anweisung: |
  Konvention: <was Mobile beim Sondieren gefunden hat, in 1-3 Sätzen>
  Referenz-Files: <Pfade zu existierenden Files mit derselben Konvention>
  Sondierungs-Tools: <welche Tool-Calls Mobile genutzt hat um die Konvention zu finden>
  Annahmen: <was Mobile angenommen hat und PC-Claude vor dem Merge prüfen soll>
  Risiken: <was schief gehen könnte, z.B. Sektion existiert mehrfach, Wikilink unsicher>
```

Beispiel (HDWM Innovationsmanagement Ergänzung):

```yaml
pc_anweisung: |
  Konvention: HDWM nutzt keine separaten log-Files. Vorlesungs-Notes sind
    Untersektionen in 01-projekte/hdwm/semester-6/{vorlesung}.md unter der
    Sektion "## Zusammenfassungen". Pro Termin eine "### YYYY-MM-DD - Titel"
    Untersektion.
  Referenz-Files:
    - 01-projekte/hdwm/semester-6/innovationsmanagement.md (existierende Sektion
      "### 2026-04-29 - Absprache Prüfungsleistung mit Heinrich")
  Sondierungs-Tools:
    - vault_list_directory("01-projekte/hdwm", depth=2)
    - vault_read_file("01-projekte/hdwm/semester-6/semester-6.md")
    - vault_read_file("01-projekte/hdwm/semester-6/innovationsmanagement.md")
  Annahmen:
    - Heutiges Datum 2026-04-29, gleiches Datum wie bestehende Heinrich-Sektion -
      mein Eintrag ist ein zweiter Termin am selben Tag (Test-Note vom User,
      kein echter zweiter Termin). PC-Claude sollte vor Merge mit Deniz klaeren
      ob das wirklich gewollt ist oder ob die Test-Note verworfen werden soll.
  Risiken:
    - Sektion "Zusammenfassungen" existiert genau einmal in der Zieldatei (geprueft).
    - Doppeltes Datum 2026-04-29 in Untersektionen kann Wikilink-Targets
      verwirren (kein bestehender Wikilink zeigt darauf, daher unkritisch).
```

PC-Claude liest `pc_anweisung` vor dem Plausibilitäts-Check. Wenn Mobile dort schon "Annahme: ..." als Risiko markiert, fragt PC-Claude Deniz BEVOR der Merge läuft.

Je vollständiger das `pc_anweisung`-Feld, desto wahrscheinlicher läuft der Merge ohne Rückfrage durch.

## Pre-Write-Checkliste (PFLICHT abhaken vor jedem vault_create_artefakt)

Vor dem Aufruf von `vault_create_artefakt` jeden Punkt mental durchgehen:

```
[ ] Pfad-Erkundung gemacht: vault_list_directory + vault_read_file + vault_search auf Über-Projekt (nicht geraten)
[ ] Konvention identifiziert: Sub-Files vs. Sektion-im-Hauptfile vs. unklar
[ ] Bei "Sektion-im-Hauptfile" Konvention: ziel_aktion ist ergaenzung, NICHT neue-datei
[ ] pc_anweisung-Block im Artefakt-Header gefuellt mit Konvention, Referenz-Files, Sondierungs-Tools, Annahmen, Risiken
[ ] Header beginnt mit '---' und enthaelt typ: vault-mcp-artefakt
[ ] Field-Name ist 'ziel_aktion' (NICHT 'aktion'), Wert ist neue-datei | ergaenzung | ersetzen-sektion
[ ] Pflichtfelder: typ, erstellt (mit Uhrzeit), quelle_geraet, quelle_konversation, ziel_pfad, ziel_aktion, idempotenz_key, body_sha256, status, pc_anweisung
[ ] Bei ergaenzung/ersetzen-sektion zusaetzlich: basis_mtime, basis_sha256, ziel_sektion, ziel_heading_ebene
[ ] Header ist ABGESCHLOSSEN mit zweitem '---'
[ ] HTML-Kommentar als Trenner: <!-- ALLES UNTER DIESER ZEILE IST DIE FERTIGE DATEI. -->
[ ] Bei neue-datei: Output-File hat EIGENEN Frontmatter (typ: meeting-note / projekt / wissen / etc.) - getrennt vom Artefakt-Header
[ ] body_sha256 berechnet (nicht leer)
[ ] Filename matcht YYYY-MM-DD-HHMM-{slug}-{aktion}.md
[ ] Wikilinks im Body verifiziert via vault_read_file
[ ] Kein Schreibversuch in Sperrzonen (_meta, _api, _claude/skills, CLAUDE.md, _migration)
```

Wenn auch nur einer nicht abgehakt: NICHT schreiben, sondern fixen oder bei Deniz nachfragen.

## Häufige Fehler (Bug-Patterns aus echtem Use)

### Fehler 1: Frontmatter zusammengemischt

**Falsch** (so hat Mobile am 2026-04-29 geschrieben):
```yaml
---
typ: vault-mcp-artefakt
ziel_pfad: 03-meeting-notes/2026/2026-04-29-kalani.md
aktion: create
projekt: "[[pulsepeptides]]"
teilnehmer: ["[[kalani-ginepri]]", "Deniz"]
---

# Inhalt
```

Was hier falsch ist:
- Nur EIN Frontmatter-Block (Artefakt-Meta vermischt mit Output-File-Meta)
- `aktion: create` statt `ziel_aktion: neue-datei`
- Pflichtfelder fehlen (quelle_geraet, body_sha256, status etc.)
- `projekt`, `teilnehmer` gehoeren in den Output-File-Frontmatter, nicht in den Artefakt-Header

**Richtig**:
```yaml
---
typ: vault-mcp-artefakt
erstellt: 2026-04-29 12:10
quelle_geraet: mobile-handy
quelle_konversation: kalani-call-maman-lager
ziel_pfad: 01-projekte/pulsepeptides/logs/2026-04-29-kalani-maman-lager.md
ziel_aktion: neue-datei
idempotenz_key: 2026-04-29-1210-kalani-maman-lager
body_sha256: 7a1f2c...
status: bereit-zum-mergen
---

<!-- ALLES UNTER DIESER ZEILE IST DIE FERTIGE DATEI. -->

---
typ: meeting-note
datum: 2026-04-29
projekt: "[[pulsepeptides]]"
teilnehmer: ["[[kalani-ginepri]]", "Deniz"]
thema: "Maman Euro Logistic + Lager Eppelheim"
status: aktiv
uhrzeit: "12:10"
erstellt: 2026-04-29
quelle: mobile-claude-artefakt-2026-04-29-1210
vertrauen: extrahiert
---

# Inhalt
```

Zwei separate Frontmatter-Bloecke. Erster fuer den Artefakt-Header (wie wird verarbeitet), zweiter fuer die Output-Datei (wie wird sie im Vault verwendet).

### Fehler 2: Pfad erfunden

Mobile schlug `03-meeting-notes/2026/` vor - der Ordner existiert nicht im Vault. Die Konvention fuer Meeting-Notes mit Kalani ist `01-projekte/pulsepeptides/logs/`.

Lehre: VOR der Pfad-Wahl `vault_search("kalani")` oder `vault_list_directory("01-projekte/pulsepeptides")` aufrufen. Dann an existierende Konvention anlehnen.

### Fehler 3: Field-Namen ungenau

`aktion: create` statt `ziel_aktion: neue-datei`. Server validiert exakt nach Schema. Field-Namen sind 1:1 zu uebernehmen, keine Synonyme.

Erlaubte Werte fuer `ziel_aktion`: `neue-datei`, `ergaenzung`, `ersetzen-sektion`. Sonst nichts.

### Fehler 4: Pfad geraten ohne zu sondieren

Beispiel 2026-04-29: User sagte "Innovationsmanagement-Note", Mobile schrieb `01-projekte/hdwm/logs/2026-04-29-innovationsmanagement-test.md`. Der `logs/`-Ordner existiert nicht in HDWM. Konvention im HDWM-Projekt: Vorlesungs-Notes als Sektionen IN `01-projekte/hdwm/semester-6/{vorlesung}.md`, nicht als separate Files.

Lehre: NIE einen Pfad aus dem Projekt-Namen plus Konvention-Annahme zusammenbauen. Immer den konkreten Workflow aus "Pfad finden, nie raten" durchgehen, mindestens drei Tool-Calls (`vault_list_directory`, `vault_read_file`, `vault_search`) bevor `ziel_pfad` gesetzt wird.

### Fehler 5: pc_anweisung-Feld leer oder fehlt

Wenn Mobile keinen `pc_anweisung`-Block fuellt, muss PC-Claude beim Merge alle Konventionsfragen selbst neu klaeren. Verlangsamt den Merge, fuehrt zu Rueckfragen. Mobile hat schon recherchiert - dieses Wissen gehoert ins Artefakt damit es im Merge nicht verloren geht.

## Wikilink-Regeln

- Wikilinks `[[dateiname]]` nur zu **existierenden** Dateien setzen
- Vor jedem Wikilink: `vault_read_file` oder `vault_search` zum Verifizieren
- Keine Wikilinks zu Dateien in `00-vault-mcp-eingang/` (das sind Artefakte, kein dauerhafter Vault-Inhalt)
- Bei unklarem Target: im Header `offene_fragen:` Liste setzen, im Body Stelle markieren

## Rote Linien

Mobile-Claude macht nicht:

- Dateien löschen oder umbenennen (kein Tool dafür)
- Schreiben außerhalb von `00-vault-mcp-eingang/` (Server blockt)
- Ändern von `_meta/`, `_api/`, `_claude/skills/`, `AGENTS.md`, `CLAUDE.md`, `_migration/`
- API-Keys oder Secrets in Artefakte schreiben
- Große strukturelle Refactors vorbereiten ohne PC-Planung

Wenn Deniz so etwas verlangt: **"Das muss am PC passieren, nicht über den Vault-MCP."**

## Schreibstil im Body

Der Body folgt den normalen Vault-Schreibregeln:
- Echte Umlaute ä ö ü ß
- Keine Gedankenstriche (em-dash —, en-dash –)
- Keine AI-Slop-Patterns (siehe `miraculix-schreibstil` Skill)
- Direkt, scanbar, keine Prosa-Wände

Frontmatter-Werte: ASCII bei enum-Werten (z.B. `bestaetigt`), Umlaute in freien Texten.

## Was passiert nach dem Schreiben

1. Artefakt liegt auf Hetzner unter `/opt/miraculix-vault/00-vault-mcp-eingang/`
2. Syncthing pusht zum PC binnen Sekunden
3. Beim nächsten "eingang verarbeiten" prüft PC-Claude den MCP-Eingang
4. PC-Claude validiert Header, Hashes, Wikilinks, zeigt Dry-Run, fragt Deniz, merged
5. Verarbeitetes Artefakt wandert nach `05-archiv/vault-mcp-eingang-verarbeitet/YYYY-MM/`

Mobile muss sich um den Merge-Schritt nicht kümmern. Nur: sauberer Header, sauberer Body, korrekter Filename.

## Bei Fehler

- `vault_create_artefakt` gibt `ERROR: ...` zurück → Fehlermeldung lesen, Header oder Filename korrigieren, neu versuchen.
- Filename schon vergeben → Suffix anhängen oder Update via `vault_update_artefakt`.
- Scope `vault:write` fehlt → falscher Token im Connector. Deniz informieren: "Read-only Token aktiv, Write-Token nötig."

## Cross-Reference

- Volle Architektur: `02-wissen/vault-mcp-architektur.md`
- Schreibkonventionen: `02-wissen/vault-schreibkonventionen.md`
- AI-Slop-Vermeidung: `_claude/skills/schreibstil.md` (`miraculix-schreibstil`)
- Vault-Grundlagen: `_claude/skills/vault-system.md` (`miraculix-vault-system`)
- Merge-Logik (PC-seitig): `_claude/skills/eingang-verarbeiten.md` (`miraculix-eingang-verarbeiten`), Sektion "MCP-Eingang"
