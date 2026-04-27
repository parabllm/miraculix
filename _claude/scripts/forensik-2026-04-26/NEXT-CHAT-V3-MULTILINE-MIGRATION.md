# MISSION: Vault-Hardening V3 - Multi-Line-Block-Migration plus Watchdog-Bug-Fix

## Lage und Befund

V2-Hardening hat behauptet "0 SEVERE" und Vault als clean gemeldet. Das war FALSCH. Real-Befund von 2026-04-27 06:30:

1. **eingang-verarbeiten.md war Pattern A KAPUTT** trotz Watchdog-OK-Meldung. Hex-Verify: `2D 2D 2D 0A 0A 23 23` (---\n\n##). Das hat der Watchdog uebersehen.

2. **Anzeige-Problem geloest:** Lange `description:`-Felder (>200 chars in einer Zeile) werden in Obsidian als roter Code-Block gerendert was wie Pattern-A-Bug aussieht obwohl strukturell sauber. Loesung: YAML-Block-Syntax `|-` verwenden, dann rendert Obsidian sauber als Multi-Line-Property.

3. **Manueller Fix bereits durchgefuehrt fuer:**
   - eingang-verarbeiten.md (war Pattern A KAPUTT, jetzt Multi-Line-Block)
   - wissens-destillation.md (war hex-sauber aber lange Zeile, jetzt Multi-Line-Block)
   - kalani-ginepri.md (Test-Migration auf `notizen: |-` Syntax - sauber)

4. **Hex-Patterns beider Fixes:** `2D 2D 2D 0A 6E 61 6D 65` (---\nname:)

## Auftrag

Drei Sachen, in dieser Reihenfolge:

### A: Watchdog-Bug fixen (HOECHSTE PRIORITAET)

Aktueller Watchdog `_claude/scripts/vault-health-check.ps1` meldet false-negatives. Konkretes Beispiel: eingang-verarbeiten.md hatte First-7-Bytes `2D 2D 2D 0A 0A 23 23` (Pattern A) und wurde als sauber gemeldet.

1. Lies vault-health-check.ps1 vollstaendig
2. Finde die Pattern-A-Detection-Funktion
3. Identifiziere warum eingang-verarbeiten.md durchgerutscht ist (vermutlich: Detection-Logik prueft nur erste Bytes, aber File hatte einen Edge-Case)
4. Fix den Bug
5. Test mit synthetischem Pattern-A-File
6. Vollscan auf alle Vault-Files plus Sub-Skills mit gefixter Logik. Liste alle gefundenen kaputten Files.

### B: Skill-Files auf Multi-Line-Block-Syntax migrieren (10 verbleibende Skills)

**Pattern fuer jeden Skill:**

Original (problematisch):
```yaml
---
name: miraculix-XXX
description: Triggered when ... [400+ chars in einer Zeile]
---
```

Neu (sauber):
```yaml
---
name: miraculix-XXX
description: |-
  [Erster Absatz: Trigger-Phrasen]
  
  [Zweiter Absatz: Was der Skill tut]
  
  [Dritter Absatz: Besonderheiten/Verarbeitungs-Reihenfolge]
---
```

Die description darf insgesamt gleich lang bleiben (Trigger-Woerter wichtig fuer Skill-Activation), aber muss in 2-4 sinnvolle Absaetze gegliedert sein mit `|-` Block-Syntax und 2-Space-Einrueckung.

**Skills die migriert werden muessen:**

```
_claude/skills/
  abgleich.md
  audio-verarbeiten.md
  drive-eingang-holen.md
  log.md
  schreibstil.md
  tages-start.md
  transkript-verarbeiten.md
  vault-pruefung.md
  vault-system.md
```

Plus ein Schreibstil-Skill der schon korrekt sein koennte (pruefen):
```
  schreibstil.md
```

**Pro Skill:**

1. Backup nach `_claude/scripts/forensik-2026-04-26/05-pre-repair-backups/SKILLNAME-pre-multilinefix.md`
2. Hex-Pre-Check: ist das File Pattern A KAPUTT oder schon hex-sauber?
3. Falls Pattern A: zuerst dekodieren via Tokenizer (Regex `(?:^|(?<=\s))(\w+):\s+`)
4. description in 2-4 sinnvolle Absaetze splitten an Sinngrenzen (Trigger-Liste / Was-tut / Reihenfolge)
5. Frontmatter neu schreiben mit `|-` Block-Syntax
6. Body komplett behalten
7. Hex-Verify nach Write: erste 8 Bytes muessen `2D 2D 2D 0A` plus erstes YAML-Key-Byte sein
8. Diff-Check: Body-Length sollte gleich oder fast gleich bleiben

**Wichtig - Edge-Case der mich vorher gebissen hat:**

Wenn Body Markdown-Tabellen hat wie `---|---|---|`, kann das mit Frontmatter-Schluss-`---` verwechselt werden. Verwende NICHT `IndexOf("---", 4)` sondern Line-by-Line-Parsing: erste Zeile ist `---`, suche naechste Zeile die exakt `---` ist (am Zeilenanfang, ohne Pipes danach).

### C: Vault-Daten-Files mit langem `notizen:` migrieren

Aus dem letzten Audit:
- ~35 Files in `03-kontakte/` mit `notizen:` zwischen 200-425 chars
- Mehrere Meeting-Files mit `zusammenfassung:` zwischen 200-300 chars
- `mitarbeiteranfragen.md` mit `kontakte:` 276 chars
- `2026-04-16-kalani-onboarding-firmenstruktur.md` mit `offene_punkte:` 216 chars

**Migration:**

Alle Frontmatter-Felder mit Wert > 100 chars in einer Zeile auf Multi-Line-Block-Syntax `|-` umstellen. Verfahren:

1. Backup wie bei Skills
2. Pre-Check (sind Files schon migriert?)
3. Pro Feld das matcht: Wert in Block-Syntax umschreiben, Inhalt 1:1 behalten (kein Splitting an Saetzen, einfach den ganzen Wert als Block)
4. Hex-Verify

**Spezial-Fall `notizen:`:** Wenn Inhalt sehr lang (>500 chars), pruefe ob es nicht eigentlich in den Body als `## Notizen` Sektion gehoert. Aber NICHT automatisch verschieben - dokumentiere die Files und frag mich.

## Constraints

- Plan-and-Execute: vor jedem Batch (Skills, Daten-Files) Plan zeigen
- Hex-Verify nach JEDEM Write
- Backups in pre-repair-backups/ vor jeder Aenderung
- Keine Annahmen: wenn ein File komplexer ist (z.B. mehrzeilige notizen schon), dokumentieren statt blind umbauen
- Tool-Wahl: Filesystem MCP edit_file ist nicht ideal weil Whitespace-genau matchen muss. Stattdessen PowerShell `[System.IO.File]::ReadAllBytes` plus String-Parsing plus `WriteAllBytes`. Das ist die bewiesene-sichere Methode.

## Erfolgskriterien

1. Watchdog-Bug ist gefixt und mit synthetischem Pattern-A-File getestet
2. Alle 11 Skills haben Multi-Line-Block-description
3. Alle Vault-Daten-Files mit langem Frontmatter-Wert sind migriert
4. Vollscan zeigt 0 SEVERE inklusive der Edge-Cases die V2 verpasst hatte
5. Im Obsidian rendern alle Files sauber (Properties-Tabelle statt rotes Frontmatter)

## Hinweis-Update fuer vault-schreibkonventionen.md

Am Ende der Mission ergaenze in `02-wissen/vault-schreibkonventionen.md` eine neue Regel:

> **Lange String-Werte im Frontmatter (>100 chars):** Immer YAML-Block-Syntax `|-` mit 2-Space-Einrueckung verwenden. Niemals als einzeilige Zuweisung. Ausnahmen: Felder die strukturierte Werte enthalten (Listen, Wikilink-Arrays, Datum-Strings).
> 
> Beispiel:
> ```yaml
> notizen: |-
>   Erste Zeile mit Inhalt.
>   
>   Zweiter Absatz.
> ```
> 
> Nicht:
> ```yaml
> notizen: Sehr langer Text in einer Zeile der dann als roter Code-Block gerendert wird und falsch wie ein Bug aussieht.
> ```

Plus die gleiche Regel ergaenzen in `02-wissen/vault-schreibregeln.md` Sektion ueber Frontmatter-Format.