# Glossar

## Projekt-Typen

**Über-Projekt:** Ein thematischer Container. Hat kein festes Ende, wächst organisch. Beispiele: Maddox, HAYS, Persönliches.

**Sub-Projekt:** Eine konkrete Sache innerhalb eines Über-Projekts. Kann geschlossen sein (hat Deadline) oder offen. Beispiele: BellaVie-Website (geschlossen), Terminbuchungs-App (geschlossen).

**Regel:** Maximal zwei Ebenen. Wenn Sub-Projekt eigene Sub-Projekte braucht, wird es zum Über-Projekt.

## Vertrauens-Stufen

| Stufe | Bedeutung | Wann |
|---|---|---|
| `extrahiert` | Direkt aus Quelle | Meeting, Tool-Output, explizit gesagt |
| `abgeleitet` | Logisch geschlossen | Aus mehreren Quellen mit Begründung |
| `angenommen` | KI-Vermutung | Braucht Prüfung durch Deniz |
| `bestaetigt` | Hochgestuft | Nach expliziter Bestätigung |

## Kapazität

Subjektive Einschätzung der verfügbaren mentalen Bandbreite. Skala 1-10.

- **1-3:** Zombie-Modus. Nur Pflicht-Tasks und Quick-Wins.
- **4-6:** Normal. Admin, Meetings, moderate Arbeit.
- **7-9:** Fokus-Modus. Deep Work, komplexe Probleme.
- **10:** Peak. Selten.

Wird morgens gesetzt. Kann im Laufe des Tages geändert werden.

## Operationen

**Tages-Start:** Morning Briefing. Daily Note, Kalender, Tasks, letzte Session, Kapazität.

**Eingang verarbeiten (Digest):** Inbox durchgehen, klassifizieren, einsortieren nach OK.

**Abgleich (Reconcile):** Projekt mit neuen Inputs abgleichen. Veraltetes finden, Updates vorschlagen.

**Vault-Prüfung (Lint):** Konsistenz-Check. Veraltete Infos, Widersprüche, Orphans, fehlende Felder.

**Log:** Session-Erkenntnisse festhalten. In Logs und Projekt-Files schreiben.

**Wissens-Destillation:** Pattern 2× aufgetreten → Wissens-Eintrag vorschlagen.

## Vault-MCP / Mobile-Capture

**Vault-MCP:** Custom MCP-Server auf Hetzner unter `https://miraculix.thalor.de/mcp`. Erlaubt Mobile-Claude den Vault zu lesen (read-only Subset) und strukturierte Schreibvorschläge in `00-vault-mcp-eingang/` abzulegen. Volle Spec siehe [[vault-mcp-architektur]].

**Artefakt:** Eine Datei in `00-vault-mcp-eingang/`, erstellt von Mobile-Claude über `vault_create_artefakt`. Enthält zwei Frontmatter-Blöcke: einen Verarbeitungs-Header (`typ: vault-mcp-artefakt`) und das fertige Output-File. Wird vom PC-Claude beim "eingang verarbeiten" validiert und gemerged.

**MCP-Eingang:** Der Top-Level-Ordner `00-vault-mcp-eingang/` (nicht zu verwechseln mit dem klassischen `00-eingang/`). Eigener Ordner weil eigene Sync-Richtung (Hetzner→PC, Receive-Only auf PC-Seite) und eigenes Trust-Modell.

**Heimatort:** Der dauerhafte Ablageort für einen Vault-Inhalt - eines der Top-Level-Verzeichnisse `01-projekte/`, `02-wissen/`, `03-kontakte/`, `04-tagebuch/`, `05-archiv/`. Im Gegensatz zu Eingängen (`00-eingang/`, `00-vault-mcp-eingang/`) die nur Durchgangs-Stationen sind.

**Capture-Flow:** Der Pfad eines Inputs vom Eingang in seinen Heimatort. Drei aktive Flows: PC-Direkt-Edit, Klassische-Inbox-Triage, Mobile-Artefakt-Merge. Visualisierung siehe [[vault-topologie]].

**Pc_anweisung:** Pflicht-Block im Artefakt-Header in dem Mobile-Claude für PC-Claude beschreibt: gefundene Konvention, Referenz-Files, genutzte Sondierungs-Tools, getroffene Annahmen, identifizierte Risiken. Macht den Merge selbsterklärend.

**Pfad-Erkundung:** Pflicht-Workflow in 5 Schritten (P.1-P.5) den Mobile-Claude vor jeder `ziel_pfad`-Wahl durchgeht. Über-Projekt identifizieren, Struktur sondieren, Hauptfile lesen, ähnliche Files finden, Konvention extrahieren. Verhindert geratene Pfade. Detail siehe [[vault-mcp-artefakt-erstellen]] Sektion "Pfad finden, nie raten".

**Race-Condition (Vault-Kontext):** Mobile liest eine Zieldatei mit Hash X, baut Artefakt mit `basis_sha256: X`. Bevor PC-Claude merged, ändert sich die Zieldatei am PC, neuer Hash Y. PC-Merge stoppt mit Race-Condition-Fehler, fragt Deniz.

**Basis-Hash:** SHA-256 der Zieldatei zum Zeitpunkt als Mobile sie gelesen hat. Im Artefakt-Header als `basis_sha256` festgehalten. PC-Merge prüft gegen aktuellen Hash, um zu erkennen ob die Zieldatei zwischenzeitlich verändert wurde.

**Body-Hash:** SHA-256 des Bodys unter dem Artefakt-Header. Im Header als `body_sha256` festgehalten. PC-Merge prüft Integrität - wenn Hash nicht passt, wurde das Artefakt zwischen Mobile-Schreiben und PC-Lesen manipuliert oder beschädigt.

**Idempotenz-Key:** Eindeutiger Identifier eines Artefakts (Pattern `YYYY-MM-DD-HHMM-slug`). Verhindert dass dasselbe Artefakt zweimal gemerged wird. PC-Merge führt eine Liste verarbeiteter Idempotenz-Keys.

**Sperrzone:** Pfad im Vault auf den Vault-MCP keinen Zugriff erlaubt - weder Read noch Write. Geblockt durch Server-Pfad-Policy: `_api/`, `.git/`, `.claude/`. Konventionell gesperrt (kein Hard-Block, aber Skill-Regel): `_meta/`, `CLAUDE.md`, `_migration/`, `_claude/skills/` (lesbar, schreibend nur PC).

**Mobile-Claude / PC-Claude:** Disambiguation - Mobile-Claude ist die Claude-Instanz auf dem Handy ohne Filesystem-Zugriff, nutzt Vault-MCP. PC-Claude ist die Instanz auf dem Laptop mit nativen Read/Edit/Bash-Tools. Beide lesen dieselbe `CLAUDE.md`, die Tool-Hierarchie regelt automatisch wer was nutzt.
