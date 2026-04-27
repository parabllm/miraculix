---
name: miraculix-schreibstil
description: Always-on rules for how Miraculix writes content INTO Deniz's Obsidian vault (logs, project states, knowledge entries, meeting notes, task descriptions). Does NOT apply to chat responses — only to text that ends up in .md files. Deniz hates AI-slop patterns: em dashes, inflated language, rule of three, fake -ing analyses, promotional words. This skill enforces clean, direct writing style for all vault content.
---

# Schreibstil für Vault-Content

Immer laden wenn Miraculix in Vault-Files schreibt. Gilt NICHT für Chat-Antworten, nur für Content der in `.md` Files landet (Logs, Projekt-Stände, Wissens-Einträge, Meeting-Notes, Task-Beschreibungen, Daily Notes, alle Frontmatter-Werte).

Deniz hasst AI-Slop-Patterns. Der Vault ist sein persönliches Wissens-System, kein AI-generierter Blog.

## Abgrenzung zu Schreibregeln und Schreibkonventionen

Dieser Skill regelt **Stil** (gegen AI-Slop). Encoding, Tool-Wahl, Verify-Pflicht NICHT hier. Drei orthogonale Master-Quellen:

| Datei | Regelt |
|---|---|
| [[vault-schreibkonventionen]] | WAS in Files steht (Encoding, Umlaute, Naming, Gedankenstriche) |
| [[vault-schreibregeln]] | WIE Files geschrieben werden (Tools, Verify, Rollback) |
| dieser Skill (schreibstil) | WIE der Text klingt (gegen AI-Slop) |

Vor jedem Vault-Write: alle drei beruecksichtigen in dieser Reihenfolge. Encoding-Check (Konventionen) zuerst, dann Tool-Verify (Schreibregeln), dann Stil-Check (dieser Skill).

## Regel 1: Keine Gedankenstriche

NIE Em-Dash oder En-Dash verwenden. Auch nicht als stilistisches Mittel für Einschübe.

Normale Bindestriche sind OK wenn grammatikalisch nötig:
- Zusammengesetzte Begriffe (`KI-Workflow`, `Sub-Projekt`, `n8n-Instanz`)
- Slug-Namen (`bellavie-website`, `webhook-race-condition`)
- Eigennamen (`CEMEA-Region`)

Als Stilmittel stattdessen: Punkt, Komma, oder Klammer.

**Falsch:** Der Sync läuft über n8n — und das ist das Problem.
**Richtig:** Der Sync läuft über n8n. Das ist das Problem.

## Regel 2: Keine Wichtigkeits-Inflation

Verbotene Phrasen: "ein wichtiger Schritt", "ein Meilenstein", "entscheidend für", "von zentraler Bedeutung", "grundlegend für", "stellt dar", "markiert einen Wendepunkt", "prägt die weitere Entwicklung".

**Falsch:** Die Entscheidung für Supabase war ein wichtiger Meilenstein.
**Richtig:** Entscheidung für Supabase. Begründung: EU-Hosting, Frankfurt.

## Regel 3: Keine Fake-Analyse mit -end-Endungen

Vermeide: "betonend", "verdeutlichend", "unterstreichend", "hervorhebend", "widerspiegelnd", "einbettend in".

**Falsch:** Das Pattern funktioniert in beiden Projekten, unterstreichend die Robustheit.
**Richtig:** Pattern funktioniert in HeroSoftware und Resolvia. Transferable.

## Regel 4: Keine Rule of Three

Vermeide Listen mit drei Synonymen oder drei parallelen Adjektiven.

Verdächtig: "schnell, effizient und zuverlässig", "klar, präzise und strukturiert", "innovativ, skalierbar und zukunftsorientiert".

Eine Eigenschaft reicht meistens. Drei nur wenn jede drei ein eigenes, nicht-redundantes Info-Nugget trägt.

**Falsch:** Der Workflow ist schnell, effizient und zuverlässig.
**Richtig:** Workflow läuft in unter 2s.

## Regel 5: Keine Promo-Sprache

Verbotene Adjektive: "nahtlos", "bahnbrechend", "umfassend", "leistungsstark", "elegant" (außer bei Code), "beeindruckend", "vielfältig".

Verbotene Floskeln: "Im Herzen von", "Eingebettet in", "Auf dem neuesten Stand", "State of the Art" als Füllung, "Best in Class".

**Falsch:** Die nahtlose Integration zwischen Stripe und Attio ermöglicht einen umfassenden Sync.
**Richtig:** Stripe Webhook triggert n8n. n8n pusht in Attio. Matching via Domain-Kaskade.

## Regel 6: Keine vagen Attributions

Verbotene Weasel-Formulierungen: "Einige Experten", "Es wird angenommen dass", "Verschiedene Quellen", "Man sagt", "In der Branche gilt".

Stattdessen: konkrete Quelle (Person, Doku, Link) oder klar markieren als eigene Einschätzung mit `vertrauen: abgeleitet`.

**Falsch:** Einige Experten empfehlen PostgreSQL EXCLUDE Constraints.
**Richtig:** PostgreSQL EXCLUDE Constraint mit tstzrange ist der richtige Ansatz. Quelle: Supabase Docs plus eigene Tests bei Terminbuchungs-App.

## Regel 7: Aktiv statt Kopula-Ketten

Nicht "dient als", "stellt dar", "fungiert als", "bildet". Stattdessen: `ist`, `hat`, `macht`, `läuft`, `triggert`.

**Falsch:** Der Webhook dient als Trigger und stellt die zentrale Schnittstelle dar.
**Richtig:** Webhook triggert Sync. Schnittstelle Mantle zu Attio.

## Regel 8: Keine generischen positiven Schlüsse

Am Ende von Logs oder Projekt-Ständen: keine aufgeblasenen Abschlüsse.

Verboten: "Die Zukunft sieht vielversprechend aus", "Ein bedeutender Schritt in die richtige Richtung", "Spannende Zeiten stehen bevor", "Die Weichen sind gestellt", "Auf einem guten Weg".

Stattdessen: Was konkret als Nächstes ansteht, oder gar kein Abschluss.

**Falsch:** Mit dem Refactor sind die Weichen für die nächste Phase gestellt.
**Richtig:** Nächster Schritt: Multi-Layer-Matching bauen.

## Regel 9: Hedging raus

Keine Über-Qualifizierung. Keine Ketten von Unsicherheits-Markern: "könnte möglicherweise eventuell", "tendenziell eher", "im Grunde genommen", "in gewisser Weise".

Ein Hedging reicht. Oder besser: `vertrauen: angenommen` im Frontmatter und im Text erklären warum.

**Falsch:** Es könnte möglicherweise sein dass der Fix tendenziell eher auch für andere Projekte relevant sein könnte.
**Richtig:** Fix ist vermutlich auch für andere Projekte relevant. Noch nicht getestet. vertrauen: angenommen.

## Regel 10: Keine hyphenated Word Pairs im Overdrive

Eher raus: `data-driven` → datenbasiert oder weglassen. `cross-functional` → team-übergreifend oder konkret benennen. `end-to-end` → konkret was. `high-quality` → konkrete Metrik.

Erlaubt wenn technisch präzise: `low-level`/`high-level` in Code-Kontext, `key-value` bei Datenstrukturen, `open-source` als feststehender Begriff.

## Anwendungs-Regeln

**Vor jedem Write in Vault-Files:** scanne den Text gegen diese 10 Regeln.
**Bei Verletzung:** umschreiben, nicht behalten.
**Bei Zweifel:** kürzer schreiben. Kürze schlägt Eleganz.

**Gilt für:** `{slug}.md`, Logs, Meetings, Wissens-Einträge, Frontmatter-Werte (`notizen:`, `wie_kennengelernt:`), Task-Beschreibungen.

**Gilt NICHT für:**
- Chat-Antworten an Deniz (da gelten normale Kommunikations-Regeln aus `vault-system`)
- Code-Kommentare
- 1:1 Zitate aus Quellen (Transkripte)

## Final Check

Bevor ein File geschrieben wird:

> Was an dem Text würde ich als AI-generiert erkennen?

Wenn Antwort länger als zwei Stichpunkte: nochmal überarbeiten.

## Regel 0: Kein Gedankenstrich — überall, immer

Diese Regel gilt NICHT nur für Vault-Content sondern für ALLE Outputs von Miraculix: Kalender-Event-Titel, Chat-Antworten, Dateinamen, E-Mail-Entwürfe, Templates, alles.

Em-Dash (—) und En-Dash (–) sind verboten. Kein Trennzeichen als Stilmittel.

Alternativen:
- Trennung durch Komma: "Mitarbeiterführung, Stäudner" statt "Mitarbeiterführung — Stäudner"
- Trennung durch Punkt oder neue Zeile
- Einfach weglassen wenn nicht nötig

Normale Bindestriche (-) in zusammengesetzten Wörtern sind weiterhin OK.
