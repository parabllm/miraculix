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

Wenn du keinen Hash berechnen kannst, lass das Feld leer mit `body_sha256: ""` und füge ein Kommentar im Body ein. PC-Merge wird dann strenger prüfen.

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

1. **Recherche**: `vault_read_file` und `vault_search` nutzen um zu verstehen was schon da ist und welche Wikilinks gültig sind.
2. **Klassifizieren**: Ist das `neue-datei`, `ergaenzung` oder `ersetzen-sektion`?
3. **Header bauen**: Pflichtfelder, plus aktions-spezifische.
4. **Bei ergaenzung/ersetzen-sektion**: Zieldatei lesen, `basis_sha256` und `basis_mtime` notieren, Sektion finden.
5. **Wikilinks prüfen**: Jeder `[[name]]` im Body muss auf existierende Datei zeigen. Wenn unsicher: `vault_read_file` zum Verifizieren.
6. **Body bauen**: Eigentlicher Inhalt nach Schreibstil-Skill (`miraculix-schreibstil`).
7. **Hash berechnen**: SHA-256 vom Body, in `body_sha256`.
8. **Filename**: Pattern bauen, `vault_list_eingang()` checken auf Doppel-Filename.
9. **Schreiben**: `vault_create_artefakt(filename, content)`.
10. **Bestätigen**: Deniz kurz sagen was im Eingang gelandet ist und dass PC-Claude beim nächsten "eingang verarbeiten" merged.

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
