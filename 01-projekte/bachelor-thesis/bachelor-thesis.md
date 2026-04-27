---
typ: ueber-projekt
name: "Bachelor Thesis"
aliase: ["Bachelor Thesis", "Bachelorarbeit", "Thesis"]
bereich: studium
umfang: geschlossen
status: aktiv
lieferdatum: 2026-06-15
kapazitaets_last: hoch
hauptkontakt: "[[christoph-sandbrink]]"
tech_stack: ["zotero", "sci-hub", "claude-code", "obsidian"]
erstellt: 2026-04-16
zuletzt_aktualisiert: 2026-04-23
notizen: |-
  HdWM Mannheim. Abgabe 15.06.2026 (HARTE Deadline). Qualitative empirische Studie zu KI-Compliance im Recruiting unter EU AI Act. Mayring-Methodik. Scope nach Sandbrink-Gespräch 23.04.2026 finalisiert.
quelle: notion_migration
vertrauen: bestätigt
---

## Kontext

**Titel:** KI-Compliance als Erfolgsfaktor: Strategische Gestaltung von Recruiting-Prozessen bei deutschen Personaldienstleistern unter dem EU AI Act

**Forschungsfrage:** Wie müssen KI-Systeme im Recruiting bei deutschen Personaldienstleistern strategisch gestaltet werden, um sowohl betriebliche Effizienz als auch KI-Compliance-Anforderungen als Erfolgsfaktoren zu erfüllen?

**Kernthese:** Große Personaldienstleister wie HAYS stehen vor strukturellem Problem - KI-Implementierung intern weniger fortgeschritten als bei kleineren agileren Firmen, gleichzeitig unterliegen sie zusätzlich EU AI Act (Hochrisiko-Einstufung Recruiting). **Wer Governance früh aufbaut, macht Compliance zum Wettbewerbsvorteil** - Explainable AI als strategisches Differenzierungsmerkmal.

- **Hochschule:** HdWM Mannheim - Business Management (Bachelor)
- **Betreuer:** [[christoph-sandbrink]]
- **Abgabe:** **15.06.2026 - HARTE Deadline**
- **Methodik Erhebung:** Qualitative leitfadengestützte Experteninterviews
- **Methodik Auswertung:** Qualitative Inhaltsanalyse nach Mayring
- **Stichprobe:** 7-9 HAYS-interne Experten in zwei Clustern
- **Tools:** Zotero für Referenzmanagement, Sci-Hub für Quellen- und Literatursuche (Empfehlung Marc, 2026-04-22)

**Interview-Cluster (aus Christine's Empfehlungen 17.03.2026):**
- **Strategie / Director-Level:** Anna Lüttgen, Christine Kampmann
- **Compliance / Legal Global:** Florian Gönnwein, Francis Davis, Rob Norris
- **KI-Arbeitsgruppe / Innovation:** Rini Kodzadziku, Johannes Leuschner
- **Sales / Delivery Center:** Leon Rädisch, Arda Sener, Lara Lünnemann, Felix Schwarz
- **Extern (LinkedIn):** Florian Meyer

## Research-Arbeitsumgebung

Die eigentliche Quellen-Arbeit (PDF-Ingestion, Zitat-Extraktion, Zotero-Sync) läuft NICHT im Miraculix-Vault, sondern in einem separaten Research-Vault mit Claude Code als Backbone.

- **Pfad separater Vault:** `C:\Users\deniz\Documents\bachelor-thesis-vault\`
- **Framework-Spec (Bauanleitung):** [[bachelorarbeit-research-vault]]
- **Arbeits-Chat:** "Thesis Assistant" Claude Project (Claude Code-Session am separaten Vault)
- **Support-File mit Research-Historie:** [[claude-support-bachelorarbeit]]
- **Entschieden:** 22.04.2026, ersetzt ältere Entscheidung vom 20.04. die einen Unterordner im Miraculix-Vault vorsah.
- **Begründung:** Forensische Trennung für Turnitin-Audit, eigener Git-Audit-Trail, eigener Claude-Code-Kontext, Reset-Fähigkeit ohne Miraculix zu beeinflussen.

Miraculix bleibt SSOT für Projekt-Management (Tasks, Kontakte, Termine, Logs, Meeting-Notes). Der separate Vault ist reiner Research-Arbeitsplatz.

## Aktueller Stand

Stand 2026-04-23 nach Sandbrink-Betreuungsgespräch ([[2026-04-23-sandbrink-betreuung]]):

**Finalisiert:**
- Scope-Klartext ([[scope-klartext]]) inhaltlich bestätigt durch Sandbrink
- Fünf Unterthesen T1 bis T5 stehen
- Sechs Analyse-Kategorien K1 bis K6 stehen
- Briefing-PDF für Präsentation erstellt ([[briefing-sandbrink-2026-04-23]])
- Wortverteilung korrigiert: Kapitel 2 auf 25 Prozent, Kapitel 3 auf 15 Prozent, Kapitel 5 auf 15 bis 20 Prozent

**Sandbrink-Korrektur:**
Großteil der Literatur gehört in Kapitel 2, nicht verteilt über die Arbeit. Kapitel 5 und 6 greifen nur ergänzend auf Literatur zurück.

**Pipeline aktiviert 2026-04-23:**
- Reset des Research-Vaults durchgeführt (alle Test-Quellen entfernt)
- `scope.md` v1.0 aktiv (K1-K6, Sättigungszahlen, Elsevier Harvard Zitierstil)
- `codebook.md` v1.0 mit vollständigen Definitionen, Abgrenzungen, konstruierten Ankerbeispielen, Kodierregeln
- `gliederung.md` mit 29 Abschnitten, Option A umgesetzt (Kapitel 5 leer, Kapitel 6 voll), Sonder-IDs `methodik`/`ergebnisse`/`diskussion` gesetzt
- Alle drei Files im Research-Vault unter `00_meta/` pipeline-ready

**Aktuell offen:**
- Erste Quelle einladen (Empfehlung: EU AI Act Originaltext) und Pipeline-Test laufen lassen
- Ankerbeispiele im Codebook nach 5 bis 10 realen Quellen durch belegte Formulierungen ersetzen
- Separater Mayring-Vault für Interview-Auswertung konzipieren ([[mayring-vault-konzeption]])

Stand 2026-04-22: Research-Vault-Framework-Spec fertig ([[bachelorarbeit-research-vault]], 900 Zeilen, Teile A bis O). Erste zwei Quellen im separaten Vault (Rukadikar 2025, Seppaelae).

## Offene Aufgaben

- [x] Montag 20.04.: Interview-Anschreiben rausschicken (6 von 11 raus, Rest blockiert oder englisch)
- [x] Scope finalisieren und mit Sandbrink abstimmen (23.04.2026 erledigt, siehe [[scope-klartext]])
- [x] Briefing-PDF für Sandbrink erstellen (23.04.2026)
- [x] Pipeline-Sondierung via Claude Code im Bachelor-Thesis-Research-Vault (23.04.2026)
- [x] Reset des Research-Vaults (23.04.2026)
- [x] `scope.md`, `codebook.md`, `gliederung.md` im Research-Vault pipeline-konform befüllt (23.04.2026)
- [ ] Erste Quelle einladen (EU AI Act Originaltext) und Pipeline-Test #hoch
- [ ] Claude-Code-Prüfauftrag: Zitierstil konsistent prüfen (Elsevier Harvard with titles überall in Prompts, Drafts, Dashboards)
- [ ] Antworten der 6 Angeschriebenen abwarten und Termine vereinbaren #hoch
- [ ] Mit Christine im nächsten Call: Anna, Rob Norris, Francis Davis, Florian Meyer durchgehen
- [ ] Zweiter externer Experte identifizieren (parallel zu Florian Meyer LinkedIn) #mittel
- [ ] Ankerbeispiele im Codebook nach 5-10 realen Quellen durch belegte Formulierungen ersetzen
- [ ] Mayring-Vault konzipieren ([[mayring-vault-konzeption]]) #mittel
- [ ] Interviewleitfaden finalisieren pro Cluster #hoch
- [ ] Kapitel-Drafts (Theorie, Methodik, Ergebnisse, Diskussion) #hoch
- [ ] Abgabe 15.06.2026 #hoch

## Verknüpfung

- Research-Vault (separat, nicht Teil von Miraculix): `C:\Users\deniz\Documents\bachelor-thesis-vault\`
- Framework-Spec für Research-Vault: [[bachelorarbeit-research-vault]]
- Research-Historie und Support: [[claude-support-bachelorarbeit]]
- Quelle für Interviews: [[hays]] (alle Kandidaten sind HAYS-intern, außer Florian Meyer über LinkedIn)
- Enablerin: [[christine-kampmann]] (Director-Level + Kontaktanbahnung zu allen Kandidaten)

## Out of Scope

- Quantitative Methoden / Surveys
- Cross-Industry-Vergleich (Fokus: deutsche Personaldienstleister)
- Externe Personaldienstleister als Interview-Quelle
- Implementierungsempfehlungen für konkrete KI-Tools

## Kontakte

- [[christoph-sandbrink]] - Betreuer
- [[christine-kampmann]] - Enablerin, selbst Interview-Kandidatin (Strategie-Cluster)
- [[anna-luettgen]], [[florian-goennenwein]], [[francis-davis]], [[rob-norris]], [[johannes-leuschner]], [[rini-kodzadziku]], [[florian-meyer]], [[arda-sener]], [[lara-luennemann]], [[leon-raedisch]], [[felix-schwarz]] - Interview-Kandidaten

## Interview-Tracking

Status aller Anfragen und Templates: siehe [[mitarbeiteranfragen]].
