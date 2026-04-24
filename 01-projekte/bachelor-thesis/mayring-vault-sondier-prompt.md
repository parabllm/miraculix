---
typ: aufgabe
name: "Claude-Code-Sondier-Prompt für Mayring-Vault-Framework"
projekt: "[[bachelor-thesis]]"
status: bereit
benoetigte_kapazitaet: mittel
kontext: ["desktop"]
faellig: 2026-04-23
kontakte: ["[[christoph-sandbrink]]"]
quelle: chat_session
vertrauen: bestätigt
erstellt: 2026-04-23
zuletzt_aktualisiert: 2026-04-23
---

# Claude-Code-Sondier-Prompt: Mayring-Vault-Framework

Dieser Prompt wird an Claude Code im Bachelor-Thesis-Ordner übergeben. Claude Code soll die bestehenden Assets sondieren und eine strukturierte Gap-Analyse plus offene Fragen für die nachfolgende Multi-LLM-Research-Runde (Claude, Perplexity, Gemini) produzieren. Kein Bau, nur Analyse.

## Kontext

Der Research-Vault (Literatur-Pipeline) ist vollständig spezifiziert in `bachelorarbeit-research-vault.md`. Die qualitative Inhaltsanalyse nach Mayring läuft laut Sandbrink-Abstimmung 23.04.2026 in einem separaten Vault. Das Konzept dazu steht als Stub in `mayring-vault-konzeption.md`.

Für die Interview-Analyse fehlt die volle Spec. Diese wird gebaut, sobald die Sondierung plus die Research-Runde abgeschlossen sind. Der hier vorliegende Prompt ist der erste Schritt: existierende Assets verstehen, Lücken identifizieren, gezielte Research-Fragen formulieren.

Drei Dimensionen sind besonders vertieft, weil sie Deniz' Kaufmann-Plagiatsvorwurf-Kontext direkt adressieren: Dimension A (Methodik-Fundament), Dimension E (Integritaet bei Paraphrasen), Dimension G (Declaration of Authorship).

---

## Der Prompt (Copy-Paste an Claude Code im Bachelor-Thesis-Ordner)

````
Du bist Sondierungs-Assistent fuer den Aufbau eines separaten Mayring-Vaults zur qualitativen Inhaltsanalyse von Experteninterviews. Ziel dieser Session ist NICHT der Bau des Vaults, sondern eine strukturierte Gap-Analyse plus konkreter Fragen-Katalog fuer eine nachfolgende Multi-LLM-Research-Runde (Claude, Perplexity, Gemini).

## Schritt 0: Pre-Flight-Check

Bevor du mit der Kontext-Aufnahme startest, pruefe:

1. Pfad-Check: alle acht Input-Dateien (siehe Schritt 1) existieren und sind lesbar.
   - Falls eine fehlt: stoppe, nenne den fehlenden Pfad, erwarte Nutzer-Input.

2. Umfang-Check: rechne in Tokens ob die acht Dateien zusammen in dein Context-Budget passen.
   - Faustregel: wenn Gesamt-Groesse groesser als 80 Prozent Context-Limit, lies die laengsten Dateien (bachelorarbeit-research-vault.md, scope-klartext.md, codebook-klartext.md) in Haelften statt am Stueck und halte strukturierte Notizen pro Haelfte.

3. Klarheit-Check: Verstehst du wirklich den Unterschied zwischen Research-Vault (Literatur) und Mayring-Vault (Interviews)? Falls nein: stoppe, frage nach.

Gib nach Pre-Flight ein einzeiliges OK oder stoppe.

## Schritt 1: Kontext lesen

Lies folgende Dateien in dieser Reihenfolge vollstaendig durch:

1. C:\Users\deniz\Documents\miraculix\01-projekte\bachelor-thesis\bachelor-thesis.md
2. C:\Users\deniz\Documents\miraculix\01-projekte\bachelor-thesis\scope-klartext.md
3. C:\Users\deniz\Documents\miraculix\01-projekte\bachelor-thesis\codebook-klartext.md
4. C:\Users\deniz\Documents\miraculix\01-projekte\bachelor-thesis\gliederung-klartext.md
5. C:\Users\deniz\Documents\miraculix\01-projekte\bachelor-thesis\bachelorarbeit-research-vault.md
6. C:\Users\deniz\Documents\miraculix\01-projekte\bachelor-thesis\mayring-vault-konzeption.md
7. C:\Users\deniz\Documents\miraculix\01-projekte\bachelor-thesis\interviewleitfaden.md
8. C:\Users\deniz\Documents\miraculix\01-projekte\bachelor-thesis\logs\2026-04-23-sandbrink-betreuung.md

Nach jedem Read ein Ein-Satz-Status: "Datei X gelesen, Y Woerter, Kernpunkt: ..."


## Schritt 2: Analyse-Dimensionen

Beantworte strukturiert pro Dimension: Was ist vorhanden, was fehlt, was ist unklar. Die drei VERTIEFT-Dimensionen brauchen besonders praezise Ausarbeitung.

### Dimension A (VERTIEFT): Mayring-Methodik-Fundament

Kernfrage: Welche Mayring-Technik wird gewaehlt und wie wird sie operationalisiert? Eine falsche Antwort hier entwertet die gesamte Methodik-Kritik von Sandbrink im Juni. Die Oberflaechen-Antwort "qualitative Inhaltsanalyse nach Mayring" reicht nicht.

Sub-Probes:

A.1 Mayring 2022 unterscheidet drei Grundformen: zusammenfassende, strukturierende, explizierende Inhaltsanalyse. Welche passt zu der Kombination aus deduktivem Kategorienraster (K1-K6 stehen fest) plus induktiver Verfeinerung (Subkategorien am Material)? Begruende mit mindestens zwei Kriterien aus Mayring 2022.

A.2 Falls strukturierende Inhaltsanalyse: welche der vier Unterformen (formal, inhaltlich, typisierend, skalierend) ist richtig? Inhaltliche Strukturierung ist fuer diese Forschungsfrage wahrscheinlich. Aber begruende, nicht raten.

A.3 Paraphrasierung nach Mayring hat konkrete Reduktions-Regeln (Streichung nicht-inhaltstragender Elemente, Generalisierung auf Abstraktionsniveau, Kondensation mehrerer Aussagen zu einer). Welche davon sind automatisierbar durch LLM-Vorschlag mit menschlicher Bestaetigung, welche muessen rein manuell bleiben?

A.4 Kodiereinheit, Kontexteinheit, Auswertungseinheit sind Mayring-Begriffe mit klaren Definitionen. Formuliere fuer dieses Projekt:
- Was ist die kleinste Kodiereinheit (Satz, Absatz, thematischer Abschnitt)?
- Wie gross ist die Kontexteinheit (ein Interview, ein thematischer Bogen)?
- Was ist die Auswertungseinheit (alle 7-9 Interviews, pro Cluster, pro Kategorie)?

A.5 Intracoderreliabilitaet: Sandbrink verlangt Doppelcodierung von 10-20 Prozent mit zeitlichem Abstand. Wie wird das operationalisiert?
- Welche Maszzahl (Cohen's Kappa, Krippendorff's Alpha, prozentuale Uebereinstimmung)?
- Was ist der akzeptable Score-Bereich (ab 0.7, ab 0.8)?
- Wie dokumentiert man Abweichungen und deren Aufloesung?

A.6 Welche Mayring-Alternative oder Ergaenzungs-Autoren (Kuckartz, Schreier, Glaeser/Laudel) sollten zitiert werden, um die Methodik intersubjektiv nachpruefbar zu machen?

### Dimension B: Interview-Leitfaden-Finalisierung

B.1 Mapping-Check: wie sauber mappt jede Frage im bestehenden Leitfaden (siehe interviewleitfaden.md) auf mindestens eine der Kategorien K1-K6? Liefere eine Tabelle: Frage-Nummer zu Kategorie mit Hauptzuordnung und Neben-Zuordnungen.

B.2 Welche Kategorien sind im aktuellen Leitfaden unter-adressiert? Besonders K4 (Governance) und K6 (Fairness) scheinen duenn abgedeckt zu sein. Stimmt das?

B.3 Welche Fragen liefern zu breit (ganze Aufsaetze als Antwort), welche zu eng (Ja/Nein-Antworten)?

B.4 Cluster-Differenzierung: welche Fragen bekommt nur der Legal-Cluster, welche nur der Operativ-Cluster? Oder bekommt jeder Interviewte die volle Fragenliste?

B.5 Heikle Fragen (Wettbewerbsdynamik, interne Probleme HAYS, Aussagen ueber Kollegen): welche sind zu direkt formuliert, wie kann man sie so reframen dass Interviewte sich trotzdem oeffnen?

