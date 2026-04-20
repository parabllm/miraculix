---
typ: research-hub
name: "Claude-Support Bachelorarbeit"
projekt: "[[bachelor-thesis]]"
status: aktiv
erstellt: 2026-04-20
zuletzt_aktualisiert: 2026-04-20
quelle: chat_session
vertrauen: bestaetigt
---

# Claude-Support Bachelorarbeit

Zentrale File zur Sammlung und Strukturierung aller Research-Ergebnisse zur Frage: **Wie nutze ich Claude und andere KI-Tools optimal, um meine Bachelorarbeit zu schreiben?**

## Ziel der File

Systematisch dokumentieren:
1. Welche Struktur hat eine Bachelorarbeit (speziell HdWM, qualitativ-empirisch)
2. Welche Claude-Skills, Workflows und Features helfen an welcher Stelle
3. Wie andere Studenten KI für Bachelorarbeiten einsetzen (Best Practices, Pitfalls)
4. Wie der Prozess beschleunigt werden kann ohne Compliance-Risiko (siehe Kaufmann-Vorfall)
5. Konkreter Schreibplan für diese Bachelorarbeit mit Claude-Support-Punkten

## Verknüpfte Files

- [[bachelor-thesis]] - Projekt-File mit Thema, Methodik, Kandidaten
- [[mitarbeiteranfragen]] - Interview-Tracking
- [[2026-04-21-maddox-cafe-session]] - morgige Framework-Session
- [[2026-04-23-sandbrink-betreuung]] - Betreuungsgespräch Donnerstag
- [[email-kaufmann-ki-vorwurf]] - Hintergrund KI-Dokumentation
- `_claude/skills/schreibstil.md` - Vault-Schreibstil (könnte für Thesis-Schreibstil relevant sein)

## Scope 3: Generisches Research-Framework (Kern-Ziel, 2026-04-20 abends)

Wichtig: Nach Phase 3 wurde der Scope nochmal verschoben. Wir bauen kein Thesis-spezifisches System, sondern ein generisches Research-Framework, das via scope-Datei pro Thema konfiguriert wird. Die Bachelorarbeit ist der erste Anwendungsfall, das Framework soll aber für beliebige zukünftige Research-Projekte wiederverwendbar sein.

### Kern-Konzept

Der Vault ist die Maschine. `scope.md` ist der Bauplan. Die Maschine bleibt gleich, der Bauplan wechselt pro Projekt.

Für jedes neue Research-Thema:
1. Ein "Scope-Writer-Agent" kennt die optimale Struktur einer scope.md (weiß welche Felder Sinn ergeben, wie Kategorien aufgebaut sein müssen)
2. Der Agent befragt den Nutzer zum Thema (Bachelor-Thesis, andere Arbeit, eigener Forschungsschwerpunkt)
3. Output: eine thema-spezifische scope.md mit Puzzle-Kategorien, Forschungsfrage, Ein- und Ausschlusskriterien
4. Diese scope.md wird in einen neuen oder bestehenden Vault gelegt
5. Alle Search-, Ingestion- und Extraktions-Skills im Vault sind auf die scope.md abgestimmt und füllen das Puzzle das dort definiert ist

### Vault als Orchestrator

Der Vault orchestriert alle externen Tools. API-Keys leben im Vault (oder in einer sicheren Config-Datei). Claude Code liest die scope.md plus API-Keys und steuert die passenden Tools pro Quellen-Typ an:
- Mistral OCR API für Tabellen-schwere Buchseiten
- OpenAI API für Handschrift und komplexe Layouts
- Anthropic API für alles Text-basierte
- WhisperX lokal für Audio
- Perplexity oder Undermind für Recherche

Der Nutzer installiert einmal die Tools, hinterlegt einmal die Keys, passt die scope.md pro Projekt an. Der Rest läuft über Claude Code.

### Buchbilder-Spezialfall

Für Buchfotos aus Bibliotheken der vorgesehene Workflow:
- Im `_raw/books/` Verzeichnis legt der Nutzer pro Buch einen eigenen Unterordner an
- Ordnername: Kurz-Bezeichnung des Buchs plus Datum
- Im Ordner: alle Fotos der relevanten Seiten, Klappentext, ISBN-Seite, Cover
- Claude Code findet bei `/ingest-book` den Ordner, erkennt Cover und Impressum für Metadaten, OCR die Inhalts-Seiten, erstellt eine zusammenhängende Quellen-File

### Ziel der Phase-3-Neuauflage (heute Abend)

Nur noch ein Research-Prompt für Gemini, weil hier strukturelles Denken gefragt ist. Perplexity hatten wir schon breit, Gemini kann jetzt die Architektur-Fragen tiefer beantworten:
- Wie baut man eine scope.md die für jedes Thema funktioniert
- Wie trennt man generisches Framework von thema-spezifischer Konfiguration
- Wie orchestriert der Vault externe APIs über Config-Files
- Wie funktioniert der Scope-Writer-Agent (meta-Agent der den Nutzer durch die scope.md-Erstellung führt)
- Wie geht man mit langen PDFs in Claude Code um (Chunking, Batch, Context-Management)

Nach Gemini-Output: finaler Framework-Plan, dann ZIP-Bau des Vaults, dann Test mit einer Dummy-scope.md bevor die Thesis-scope.md erstellt wird.

## Kern-Anforderungen (nachträglich ergänzt, 2026-04-20 spät)

Nach der Phase-3-Neuauflage wurde klar dass das System in erster Linie Zitat- und Quellen-Integrität liefern muss. Das ist nicht eine Nebenfunktion sondern die Hauptaufgabe. Alle anderen Komponenten (Ingestion, Klassifikation, Vault-Struktur, Skills) dienen diesem Ziel.

### Das Endprodukt

Am Ende des Research-Prozesses für jedes Projekt (inklusive der Bachelorarbeit):

1. Eine saubere Zotero-Library mit allen genutzten Quellen, keine Halluzinationen, alle bibliographischen Angaben valide und nach definiertem Zitierstil formatiert.
2. Pro Quelle eine Markdown-File im Vault mit: Scope-Kontext (wie passt diese Quelle ins Puzzle), extrahierte direkte Zitate mit exakter Seitenangabe, paraphrasierbare Stellen mit Seitenangabe, Einordnung in die scope.md-Kategorien.
3. Vollständige Verlinkung zwischen Zotero-Einträgen und Vault-Files, damit beim Schreiben jede Passage zurück zur verifizierten Quelle führt.

### Die vier Integritätsgarantien

1. **Autor, Jahr, Titel, Publikationsort müssen korrekt erkannt werden**. Nicht geraten, nicht halluziniert. Quellen bei denen das System unsicher ist bekommen den Flag `metadata_conflict: true` und erscheinen in einem Dashboard das du abarbeiten musst.
2. **Zitate müssen wörtlich korrekt sein und Seitenangaben verifiziert**. Kein Zitat darf in die Master-Passage-Datenbank ohne dass es gegen die Quelle geprüft wurde. Force-Quote-Pattern plus Gate ist Pflicht.
3. **Zitierstil muss durchgängig kohärent sein**. Für die Bachelorarbeit: APA 7 laut HdWM-Leitfaden (korrigiert gegenüber der Harvard-Annahme aus Phase 1). Der Zitierstil ist Teil der scope.md und wird an Zotero via BetterBibTeX durchgesetzt.
4. **Zotero ist die Single Source of Truth für bibliographische Angaben**. Der Vault verlinkt zu Zotero-Einträgen via citation_key, Zotero-Einträge verlinken zu Vault-Files via URI oder Note. Bei Konflikt gewinnt Zotero.

### Was das für die Architektur ändert

Der Fokus verschiebt sich. Bisher war der Build-Plan: zuerst Ingestion-Skills, dann Extraktion, dann Zotero-Sync. Neuer Plan: Zotero-Integration ist nicht nachgelagert sondern im Zentrum. Jede neue Quelle durchläuft einen zweistufigen Verifikations-Flow:

- Stufe 1: automatische Metadaten-Extraktion durch LLM plus DOI/ISBN-Lookup gegen Crossref, OpenAlex, DNB, Google Books API
- Stufe 2: Abgleich zwischen beiden Quellen plus Human-in-the-Loop bei Abweichungen

Erst nach bestandener Stufe 2 wandert die Quelle in Zotero und in das Vault-Verzeichnis 01_sources/. Bis dahin bleibt sie in _raw/_pending/.

Das macht die Research-Prompts dichter: BLOCK 7 kommt dazu, und die bestehenden Blöcke bekommen Zitat-Integrität als Querschnitts-Anforderung.

## Multi-Phasen Research-Plan

Workflow: Jeder Prompt geht parallel an Claude, Perplexity und Gemini. Ergebnisse werden in dieser File konsolidiert.

## Scope 2: Workflow-Beschreibung (Kern-Ziel, 2026-04-20)

Wichtig: Dieses Research-Projekt baut KEIN Thesis-Framework, sondern einen KI-gestützten Research-Workflow. Die inhaltliche Thesis-Arbeit kommt erst danach mit dem fertigen Workflow als Werkzeug.

### Was der Workflow leisten muss

Eine große zentrale Ansammlung von Quellen aufbauen, aus der das Thesis-Puzzle am Ende zusammengesetzt wird. Quellen-Typen sind heterogen: Volltext-PDFs (Bücher, Paper), Bachelorarbeiten und Masterarbeiten, Seminararbeiten, Zeitungsartikel, Reports, Whitepaper. Jede Quelle wird in das System geworfen, die KI verarbeitet sie und extrahiert die für das Thema relevanten Key Takeaways.

Zwei Extraktions-Modi pro Quelle:
1. Kurze Relevanz-Summary: passt die Quelle überhaupt zum Thema, welche Aspekte deckt sie ab, welche Kategorien trifft sie
2. Genaue Passagen mit Seitenzahl plus Klassifikation pro Passage:
   - direktes Zitat (wörtlich übernehmbar)
   - indirektes Zitat (sinngemäß paraphrasierbar)
   - Hintergrund-Abschnitt (selbst durchlesen zur Kontext-Bildung, nicht zitierbar)

### Bachelorarbeiten als spezieller Quellen-Typ

Bachelor- und Masterarbeiten werden doppelt ausgewertet: einmal als Quellen-Mine (welche Primärquellen zitieren sie die für uns relevant sind), einmal nach Zitat-Passung (welche Zitate in diesen Arbeiten passen kontextuell zu unseren Kategorien). Die Originalquellen hinter den Zitaten werden markiert und nachträglich direkt beschafft. Eigene Verwendung erfolgt immer aus der Primärquelle, nie aus der Abschlussarbeit selbst.

### Puzzle-Logik

Das System muss Lücken sichtbar machen. Wenn für eine Kategorie wenig Material vorhanden ist, zeigt der Workflow das an. Gezielte Nach-Recherche in die Lücken-Kategorien. Iterativ wird das Puzzle vollständig, bis der Schreibprozess starten kann. Beim Schreiben ist jedes Argument zu einer Quelle und einem Passagen-Abschnitt rückverfolgbar.

### Erwartete Interaktion (Ende-zu-Ende)

- Deniz findet eine Quelle (PDF, Bachelorarbeit, Artikel)
- Wirft sie in das System (Claude, Claude Code, NotebookLM, was auch immer sich als Tool bewährt)
- System analysiert gegen die Thesis-Kategorien-Definition
- Output: strukturierter Eintrag pro Quelle mit Metadaten, Zitaten klassifiziert nach Typ, Seitenzahlen, Kategorien-Tags, Relevanz-Urteil
- Eintrag landet zentral im Obsidian-Vault
- Queryable: "zeig mir alle direkten Zitate zum Thema X für Kapitel Y"
- Lücken-Anzeige: "Kategorie Z hat nur 2 Quellen, brauche mehr"

### Was dafür noch offen und zu recherchieren ist

- Welche Kategorien-Definition dient als Filter (muss vor Workflow-Start festgelegt werden)
- Welches Tool verarbeitet zuverlässig (Claude Code, Claude Projects, NotebookLM, Kombination)
- Wie wird der zentrale Pool strukturiert (Obsidian-Markdown, Zotero, Hybrid)
- Wie werden die Extraktions-Klassifikationen (direkt / indirekt / Hintergrund) zuverlässig erzeugt
- Wie sieht die Lücken-Anzeige technisch aus (Dataview-Query, Dashboard, Skill)

## Research-Phasen

### Phase 1: Breiter Überblick (jetzt)

Zwei Prompts die sich gegenseitig abdecken:
- Prompt 1A: Fokus auf die Bachelorarbeit als Produkt und das spezifische Thema
- Prompt 1B: Fokus auf KI-assistierte Workflows und aktuelle Tools

### Phase 2: Struktur-Deep-Dive (später)

**Fokus-Punkte für Phase 2 (aus Voice-Dump 20.04.):**

1. **Quellen aus verwandten Bachelorarbeiten extrahieren**
   - Wo findet man Bachelorarbeiten zu Recruiting, Personaldienstleistern, KI im HR?
   - Workflow: verwandte Arbeit lesen, Zitate und Quellen extrahieren, eigenständig verwenden (Quelle verwenden ist kein Plagiat, Text übernehmen schon)
   - Plattformen: Grin, OPUS, Hochschul-Bibliotheken, Google Scholar, ResearchGate

2. **Quellen-Findungs-Workflow**
   - Ziel: ca. 40 belastbare Quellen für die Thesis
   - Zotero als Literaturmanagement (Harvard-Zitation, schon etabliert aus Seminaren)
   - Multi-LLM-Suche: Perplexity für aktuelle Quellen, Claude für tiefe Analyse, Gemini für breite Synthese

3. **Zitat-Extraktion aus Quellen (Hauptproblem der Vergangenheit)**
   - Problem: KI liest oft nur Abstract, halluziniert Seitenzahlen, gibt falsche Zitate
   - Lösung: PDFs direkt in Claude Project hochladen, dann Zitate extrahieren lassen mit Verifikation
   - Alternative: NotebookLM (Google-Tool speziell für Dokument-basierte Analyse)
   - Jede Zitat-Extraktion wird gegengeprüft: Seite stimmt, Kontext passt, Formulierung ist korrekt

4. **Zitate-Pool mit Tagging**
   - Pro Quelle extrahierte Zitate mit Seite, Kontext, Tag (welches Kapitel, welches Thema)
   - Beim Schreiben: "Für Einleitung zum Thema KI-Hochrisiko, welche Zitate habe ich?" Query über Tags
   - Vermeidet den alten Schmerz: 40 Quellen, manuell mit Strg+F durchsuchen

5. **Vault-Struktur für Thesis (ENTSCHIEDEN 20.04.2026)**
   - Kein zweiter Vault. Second Brain soll als Gesamtsystem wachsen.
   - Innerhalb `01-projekte/bachelor-thesis/` wird ein Unterordner `bachelor-thesis-assistant/` angelegt. Darunter laufen Quellen-Files, Zitate-Pool, Kapitel-Drafts.
   - Fallback-Option (dokumentiert): Falls der Ordner irgendwann zu unübersichtlich wird, lässt er sich jederzeit als eigenständiges Projekt herauslösen (Git-Mv, Skill-Update, Claude-Project-Wechsel).
   - Struktur:
     ```
     01-projekte/bachelor-thesis/
       bachelor-thesis.md (Projekt-File, bleibt)
       mitarbeiteranfragen.md (bleibt)
       claude-support-bachelorarbeit.md (diese File, bleibt)
       logs/ (bleibt, alle Meeting-Notes und Session-Logs)
       bachelor-thesis-assistant/
         quellen/
           {autor-jahr-kurztitel}.md (pro Quelle eine File mit Metadaten, Zitaten, Tags)
         zitate-pool.md (konsolidierte Zitat-Liste, queryable)
         kapitel/
           01-einleitung.md
           02-theorie.md
           03-methodik.md
           04-ergebnisse.md
           05-diskussion.md
           06-fazit.md
     ```
   - Paralleles Claude Project "Bachelorarbeit" (nicht Obsidian-Vault) für aktives Schreiben:
     - Project Knowledge: Verweis auf `bachelor-thesis-assistant/`
     - PDF-Uploads aller Quellen für Zitat-Extraktion ohne Halluzination
     - Artifacts für Kapitel-Draft-Iterationen
     - Eigene Skills für Zitat-Extraktion, Kapitel-Writing, Argumentations-Prüfung

6. **Quellen-Dump-Workflow**
   - Deniz findet eine Quelle (Paper, Buch, Report)
   - Wirft PDF ins Claude Project
   - Claude analysiert: Abstract, Relevanz für Thesis-Themen, Kern-Zitate mit Seitenzahl
   - Ausgabe: `quellen/{autor-jahr-kurztitel}.md` mit strukturierter Extraktion
   - Wenn Quelle gut ist: in Zotero aufnehmen (Harvard-Format)
   - Wenn Quelle nicht gut ist: File löschen, raus

7. **Vorlagen für Zitat-Files**
   - Welche Felder braucht jede Quellen-File? (Autor, Jahr, Titel, Typ, Zotero-Key, Relevanz-Bewertung, extrahierte Zitate mit Seite und Tag, eigene Zusammenfassung, Bezug zu welchem Thesis-Kapitel)

8. **HdWM-spezifische Vorgaben checken**
   - Prüfungsordnung zu Seitenzahlen, Formalia, Declaration of Authorship (nach Kaufmann-Vorfall)
   - Was sind die offiziellen Richtlinien zu KI-Nutzung an der HdWM Stand 2026?

9. **Plagiat-Schutz und Turnitin-Strategie**
   - Wie vermeidet man False Positives bei Turnitin wenn man KI-gestützt schreibt?
   - Eigene Formulierungen, aber auf KI-Recherche basierend, wie deklarieren?
   - Declaration of Authorship sauber aufsetzen

### Phase 3: KI-Integration (später)

Wo, wann, wie genau Claude einsetzen. Skill-Erstellung. Artifact-Strategien. Transkript-Verarbeitung. Zitier-Management mit Zotero-Integration.

### Phase 4: Konkreter Schreibplan (nach Sandbrink-Gespräch)

Ableitung eines Wochen-für-Woche Plans bis 15.06.2026.

---

## Phase 1A: Breiter Research Prompt (Thema + Bachelorarbeit als Produkt)

```
Ich schreibe meine Bachelorarbeit an der HdWM Mannheim (Hochschule der Wirtschaft für Management, Bachelor Business Management). Abgabedatum 15.06.2026.

Thema: "KI-Compliance als Erfolgsfaktor: Strategische Gestaltung von Recruiting-Prozessen bei deutschen Personaldienstleistern unter dem EU AI Act"

Forschungsfrage: Wie müssen KI-Systeme im Recruiting bei deutschen Personaldienstleistern strategisch gestaltet werden, um sowohl betriebliche Effizienz als auch KI-Compliance-Anforderungen als Erfolgsfaktoren zu erfüllen?

Kernthese: Grosse Personaldienstleister wie HAYS stehen vor einem strukturellen Problem, da sie KI intern weniger fortgeschritten einsetzen als kleinere agile Wettbewerber, gleichzeitig aber durch die Hochrisiko-Einstufung von Recruiting unter dem EU AI Act zusätzliche regulatorische Last tragen. Wer Governance früh aufbaut, kann Compliance zum Wettbewerbsvorteil machen (Explainable AI als strategisches Differenzierungsmerkmal).

Methodik:
- Qualitative leitfadengestützte Experteninterviews (7 bis 9 Teilnehmer)
- Zwei Cluster: Strategie/Director-Level + Compliance/Legal sowie KI-Arbeitsgruppe + Sales/Delivery
- Qualitative Inhaltsanalyse nach Mayring
- Stichprobe: HAYS-interne Experten plus ein externer LinkedIn-Kontakt

Ich bin zum heutigen Stand 20.04.2026 dabei, die Interview-Anfragen rauszuschicken. Ich habe noch keine finale Gliederung, keinen Interviewleitfaden und keine Kapitel-Drafts.

Gib mir bitte einen umfassenden Research-Überblick zu folgenden Aspekten. Liefere konkrete Quellen (Paper, Bücher, Reports) mit Autor, Jahr und kurzer Einordnung, keine Paywalled-Links. Deutsche und englische Quellen.

1. Aktueller Forschungsstand zu KI im Recruiting und EU AI Act (2024 bis 2026)
   - Welche Paper, Whitepaper, Reports sind aktuell zitierfähig?
   - Welche Autoren dominieren das Feld?
   - Gibt es bereits qualitative Studien mit ähnlicher Forschungsfrage, speziell zu deutschen Personaldienstleistern?

2. EU AI Act und Recruiting spezifisch
   - Aktuelle Umsetzungsfrist und Compliance-Anforderungen (Stand April 2026)
   - Einstufung Recruiting als Hochrisiko-Bereich (Annex III)
   - Welche praktischen Compliance-Massnahmen sind State of the Art?
   - DSGVO-Schnittstelle

3. Strategische Gestaltung von KI in Unternehmen
   - Frameworks und Modelle (z.B. RMF NIST, ISO 42001, AI Governance Frameworks)
   - Was sagt die Literatur zu "Compliance als Wettbewerbsvorteil"?
   - Explainable AI als strategisches Differenzierungsmerkmal, gibt es empirische Belege?

4. Methodik qualitative Inhaltsanalyse nach Mayring
   - Aktuelle Version (Mayring 2022 oder neuer)
   - Typische Fallstricke in Bachelorarbeiten
   - Kodierleitfaden-Erstellung
   - Software-Empfehlungen (MAXQDA, Atlas.ti, f4transkript, etc.)

5. Struktur einer empirischen Bachelorarbeit an einer FH/HdW
   - Typische Kapitelstruktur (Einleitung, Theorie, Methodik, Ergebnisse, Diskussion, Fazit)
   - Übliche Seitenzahlen
   - Was gilt als gute qualitative Bachelorarbeit?
   - Welche Gütekriterien (Validität, Reliabilität, Intersubjektivität nach Mayring)?

6. Praktische Tipps aus Erfahrungsberichten
   - Was sind typische Fehler in empirischen Bachelorarbeiten?
   - Zeitplanung für 8 Wochen verbleibende Zeit mit 7 bis 9 Interviews
   - Transkription, Kodierung, Auswertung realistische Zeitschätzung

Gib mir zu jedem Punkt konkrete, zitierbare Quellen und markiere welche besonders relevant für meine Thesis sind.
```

---

## Phase 1B: Breiter Research Prompt (KI-Tools und Workflows)

```
Ich schreibe meine Bachelorarbeit an der HdWM Mannheim zu "KI-Compliance als Erfolgsfaktor im Recruiting unter dem EU AI Act", Abgabe 15.06.2026, qualitative empirische Studie mit 7 bis 9 Experteninterviews und Auswertung nach Mayring.

Ich will KI-Tools (primär Claude, aber auch Perplexity, Gemini, NotebookLM, etc.) maximal effizient einsetzen. Wichtig: ich komme aus einem Kontext wo mir gerade ein Plagiatsvorwurf durch Turnitin gemacht wurde weil ich KI-Recherche und KI-Text-Korrektur in der Declaration of Authorship nicht ausreichend getrennt hatte. Das will ich diesmal von Anfang an sauber aufsetzen.

Gib mir einen umfassenden Überblick zu folgenden Aspekten. Konkrete Quellen, Reddit-Threads, YouTube-Videos, Blog-Posts, akademische Papers, alles was 2024 bis 2026 relevant ist.

1. State of the Art KI-assistiertes wissenschaftliches Schreiben 2026
   - Welche Tools nutzen erfolgreiche Studenten aktuell?
   - Welche Workflows haben sich etabliert?
   - Unterschied research assistance vs. text generation, wie klar abgrenzen?

2. Claude-spezifische Features für Bachelorarbeiten
   - Projects (mit Project Knowledge)
   - Artifacts für Gliederungs-Iterationen
   - Custom Skills (claude.ai Skill-System)
   - MCP Server (z.B. Zotero, Google Drive, Filesystem)
   - Welche Features helfen speziell bei qualitativer Forschung (Kodierung, Transkript-Analyse)?

3. Multi-LLM-Workflows
   - Arbeitsteilung Claude vs. Perplexity vs. Gemini vs. NotebookLM
   - Wann welches Tool?
   - Wie konsolidiert man Outputs?

4. Transkript-Verarbeitung und Kodierung mit KI
   - Interview-Transkription: Tools, Genauigkeit, Kosten
   - Kann man Kodierung nach Mayring durch Claude/GPT unterstützen lassen?
   - Gibt es Studien dazu, wie valide KI-gestützte Kodierung ist?
   - Rechtliche Aspekte der KI-Nutzung in qualitativer Forschung (DSGVO bei Interview-Daten)

5. Zitier- und Literaturmanagement mit KI
   - Zotero + KI-Tools
   - Wie kann man mit Claude effizient Paper lesen und annotieren?
   - Generierung von Literatur-Reviews, wo ist die Grenze zur Eigenleistung?

6. Compliance und Deklaration der KI-Nutzung
   - Aktuelle Richtlinien deutscher Hochschulen 2026
   - Wie formuliert man eine saubere Declaration of Authorship bei KI-Einsatz?
   - Was ist bei Turnitin, Ouriginal, etc. zu beachten?
   - Was sagt die HdWM-Prüfungsordnung konkret zu KI?
   - Praxis-Beispiele saubere vs. problematische Deklarationen

7. Schreib-Prompts und Skill-Patterns
   - Welche Prompts/Skills haben andere Studenten entwickelt, die öffentlich geteilt werden?
   - Gibt es GitHub-Repos mit Bachelorarbeit-Claude-Skills?
   - Was sind typische Fehler beim Prompting für akademisches Schreiben?

8. Zeitersparnis-Benchmarks
   - Wie viel schneller schreiben Studenten mit KI-Support im Schnitt?
   - Wo sind die grössten Hebel (Recherche, Strukturierung, Korrekturlesen, Argumentationsketten)?
   - Wo bringt KI nichts oder ist sogar kontraproduktiv?

Gib zu jedem Punkt konkrete Links, Tools, Quellen. Wenn Reddit-Threads oder YouTube-Videos relevant sind nennen. Priorität auf 2025 und 2026 Quellen.
```

---

## Konsolidierungs-Block

### Ergebnisse Prompt 1A (Thema + Bachelorarbeit als Produkt)

Quelle: externer Research-Output 20.04.2026 (vermutlich Perplexity).

**Rechtsrahmen EU AI Act + Recruiting (zitierfähige Grundlage):**

- Verordnung (EU) 2024/1689, Anhang III Kategorie 4: Recruiting, Auswahl, Leistungsüberwachung, Kündigung explizit als Hochrisiko-Systeme klassifiziert
- Geltungsbeginn der einschlägigen Hochrisiko-Abschnitte: August 2026 (fällt in Thesis-Zeitraum, hohe Aktualität)
- Pflichten für Unternehmen: Konformitätsbewertung, Registrierung in EU-Datenbank, Dokumentation, Datenqualität, Monitoring, menschliche Aufsicht
- CE-Kennzeichnung und technische Dokumentation durch Anbieter, einsetzende Unternehmen (wie HAYS) tragen Verantwortung für Implementation, Kontrolle, Schulung
- Schnittstellen: DSGVO Art. 22 (Human-in-the-Loop), BDSG, AGG (Anti-Diskriminierung), BetrVG (Betriebsrat-Mitbestimmung bei technischen Einrichtungen zur Leistungskontrolle, für HAYS-Kontext extrem relevant)

**Forschungsstand:**

- Wissenschaftliche Literatur zu AI Act ist wachsend aber noch dünn, besonders im HR-Kontext
- Dominanter Fokus bisher: Ethik, Datenschutz, generative KI
- "Worker Management" bibliometrisch unterrepräsentiert, deine Arbeit adressiert eine echte Forschungslücke
- Spannungsfeld europäisches Produktsicherheitsrecht vs. Grundrechtsschutz als theoretischer Rahmen nutzbar

**Methodik qualitative Inhaltsanalyse nach Mayring (für Methodik-Kapitel):**

- Standardwerk: Mayring, P. (2022). Qualitative Inhaltsanalyse. Grundlagen und Techniken. Beltz, 13. Auflage
- Drei Grundformen: Zusammenfassung, Explikation, Strukturierung (für deine Thesis voraussichtlich Strukturierung)
- Ablaufmodell: Material > Analyserichtung > Form > Kategorien (induktiv/deduktiv/kombiniert) > Kodierung > Verdichtung > Interpretation
- Für Thesis empfohlen: teildeduktiv aus AI Act + Governance-Modellen plus induktiv aus Interview-Aussagen
- Stichprobe 6-10 halbstrukturierte Experteninterviews gilt als adäquat für Bachelorarbeit
- Gütekriterien: inhaltliche Validität, Reliabilität (Zweitkodierung empfohlen), Intersubjektive Nachvollziehbarkeit, argumentative Interpretationsabsicherung, kommunikative Validierung

**Zitierfähigkeit vs. Zitierwürdigkeit (wichtige Unterscheidung):**

- Zitierfähig = öffentlich zugänglich, nachweisbar (ISBN, DOI, stabile URL)
- Zitierwürdig = wissenschaftlich belastbar (Peer-Review, anerkannte Verlage)
- Andere Bachelorarbeiten sind weder zitierfähig noch zitierwürdig, aber deren Quellen kann man nutzen (siehe Quellen-Strategie in Phase 2)
- Whitepaper von Kanzleien und HR-Dienstleistern: zitierfähig, Zitierwürdigkeit je nach Fall (kritisch auf Marketing-Bias prüfen)

**Konkrete Quellen-Leads für Literatur:**

- Primärrecht: Konsolidierter Text VO (EU) 2024/1689, Anhang III, Artikel 6
- EU-FAQs und Orientierungshilfen zum AI Act
- Deutsche Kommentierungen zu DSGVO Art. 22 und BetrVG im HR-Kontext
- Mayring 13. Auflage (aktuellste)
- Kuckartz/Rädiker für alternative QIA-Modelle falls Mayring zu eng wird

### Ergebnisse Prompt 1B (KI-Tools und Workflows)

Quelle: externer Research-Output 20.04.2026 (vermutlich Gemini, längerer akademischer Stil).

WARNUNG: Output referenziert Claude 3.5 Sonnet als aktuelles Modell. Zum Zeitpunkt der Thesis (April 2026) ist Claude Opus 4.7 aktuell. Architektur-Prinzipien gelten weiter, Leistungsdaten sind überholt.

**Flächendeckende KI-Nutzung im Studium:**

- H-DA Studie (395 Hochschulen): 90%+ Studierende nutzen generative KI für akademische Zwecke
- Ambivalenz: KI als Hilfsmittel vs. Angst vor "Lernverlust"
- Zitat-Finding: 44% Hochschulen mit aktiver KI-Diskussion, 47% mit partieller, 29% im Vakuum
- Nutzbar als empirischer Anker im Theoriekapitel

**Claude Projects Features (relevant für Thesis-Setup):**

- 200k Token Kontextfenster pro Projekt (entspricht ca. 500 Seiten)
- Project Knowledge: persistente Dokumente (PDFs, Drafts, Codebooks)
- Custom Instructions pro Projekt
- Artifacts: interaktive Komponenten, direkter Export als .docx, .pptx, .xlsx
- Konsequenz für dich: Projekt "Bachelorarbeit" mit PDF-Uploads aller Quellen plus bachelor-thesis-assistant Ordner als Project Knowledge

**Prompt-Engineering Best Practices:**

- XML-Strukturierung bei multiplen Dokumenten: <document><source>Autor Jahr</source><document_content>...</document_content></document>. Verhindert Context-Bleeding
- Langes Rohmaterial am Anfang, Instruktionen am Ende
- Bei langen Sessions: bewusst schließen, strukturierte Zusammenfassung erzeugen, in neue Session als Seed einspielen. Vermeidet kognitive Degradation
- Positive Formulierungen statt Negationen ("Schreibe in Prosa" statt "nutze kein Markdown")
- Grounding: "Zitiere vor der Analyse die relevanten Passagen aus dem Text" zwingt Claude zur Verankerung

**Transkription (Whisper Large-v3):**

- 128 Mel-Frequenz-Bins, 10-20% Fehlerreduktion vs. Vorgänger
- Lokale Ausführung möglich (Open-Source), wichtig wegen DSGVO bei Interview-Daten
- Derivat "Whisper Large-v3 Turbo German" (CTranslate2) speziell optimiert für Deutsch, läuft auf Standard-GPU
- KRITISCHES PROBLEM (Kaufmann-Fehler): End-to-End-Systeme wie Whisper glätten natürliche Sprach-Artefakte (Stottern, Pausen, Brüche, Unregelmässigkeiten). Das was qualitative Forschung sucht verschwindet. Mayring fordert aber genau diese Phänomene in der Auswertung
- Konsequenz: Whisper-Output immer manuell nachkorrigieren, Pausen und Brüche reintragen, hörende Gegenprüfung Pflicht

**Methodologischer Kaufmann-Fehler (Jean-Claude Kaufmann 1996):**

- Fehler: situative Brüche, Zögern, emotionale Reibungen im Interview als Störvariablen behandeln
- Kaufmann: genau diese Phänomene sind konstitutiv für qualitative Daten
- KI-Risiko: LLMs trainiert auf Fluss und Kohärenz, werden Brüche automatisch glätten
- Methodik-Regel für deine Thesis: KI darf NIEMALS zur narrativen Glättung von Interviews eingesetzt werden. Bei KI-gestützter Kodierung explizite Meta-Tags für Anomalien (<hesitation>, <contradiction>) erzwingen

**Zentaur vs. Cyborg Modus:**

- Cyborg: unstrukturiertes Durchtalken, Verschmelzung mit KI, keine klare Aufgabenteilung (schlecht)
- Zentaur: strikte Aufgabenteilung, Mensch behält Souveränität, KI macht deterministische Teilaufgaben (gut, auch methodisch vertretbar)

**Map-Reduce für grosse Datenmengen:**

- Korpus in kleine Verarbeitungseinheiten zerlegen
- KI analysiert parallel (Map)
- Ergebnisse iterativ verdichten (Reduce)
- Für Thesis: Interviews einzeln kodieren lassen, dann Kategorien konsolidieren

**Praktische Thematische Kodierung mit Claude:**

- Start Small: kleine Stichprobe, Prompt kalibrieren, Spot-Check
- Typisches Problem: KI interpretiert Signalwörter falsch ("besser" wird als positiv gelesen auch in "muss besser werden" als Kritik)
- Wenn Prompt kongruent mit menschlicher Auffassung: Skalieren (Go Big) via Python-Skript oder Batch-Verarbeitung
- Output: strukturiertes CSV mit Themen-Tags pro Segment

**Compliance / Deklaration:**

- Aktuelle Richtlinien 2025/2026 (Regensburg, Bremen, Würzburg, Trier, Leipzig, RWU Ravensburg-Weingarten)
- Eigenständigkeitserklärung mit explizitem KI-Opt-in/Opt-out
- "AI Usage Card" (Wahle et al. 2023) als tabellarischer Anhang Pflicht
- Struktur: Tool, Version, Verortung im Dokument (Kapitel/Seite), Zweck, Eigenleistung/Modifikation
- Unterlassene Deklaration: Arbeit nicht bestanden, bei Wiederholung Exmatrikulation, Titelaberkennung

**HdWM-Spezifika:**

- HdWM-Richtlinien wurden im Research nicht direkt gefunden, sind in Phase 2 zu recherchieren (eigener Task)

### Konsolidierte Findings

1. **Thesis-Thema trifft eine echte Forschungslücke.** Recruiting als Hochrisiko-Anwendung im AI Act ist zitierbar, wissenschaftliche Literatur dazu ist dünn. Good position.

2. **Methodik-Setup steht:** Mayring 13. Auflage als Referenz, Strukturierung als Grundform, teildeduktives Kategoriensystem aus AI Act + Governance-Modellen, 7-9 halbstrukturierte Interviews (deine Stichprobe passt).

3. **Primäre Literaturquellen sind klar:** Rechtsakte (VO 2024/1689), Mayring, deutschsprachige Kommentierungen DSGVO/BetrVG/AGG, internationale AI-Governance-Literatur. Whitepaper nur ergänzend.

4. **Tooling-Stack für Thesis-Arbeit:**
   - Claude Project "Bachelorarbeit" mit 200k Kontext, PDF-Uploads, Project Knowledge = bachelor-thesis-assistant Ordner
   - Whisper Large-v3 German Turbo lokal für Interview-Transkription (DSGVO-Pflicht bei HAYS-Daten)
   - XML-Strukturierung bei Multi-Dokument-Prompts
   - Zentaur-Modus statt Cyborg: Mensch = Souveränität, KI = Teilaufgaben

5. **Methodologische Kritik-Punkte, die aktiv gemanagt werden müssen:**
   - Kaufmann-Fehler bei Whisper-Output (manuell nachkorrigieren)
   - KI-Kodierung braucht Spot-Check und Meta-Tags für Anomalien
   - Halluzinationen bei Zitaten: nur mit PDF-Upload sicher, Seitenzahlen IMMER gegenprüfen

6. **Deklarations-Setup für Thesis (nach Kaufmann-Vorfall):**
   - Eigenständigkeitserklärung mit Opt-in für KI-Nutzung von Anfang an
   - AI Usage Card als Anhang pflegen, ab Tag 1 mitführen
   - Pro Claude/Perplexity/Gemini/Whisper-Session: Tool, Zweck, Modifikation dokumentieren
   - HdWM-spezifische Vorgaben in Phase 2 recherchieren

### Offene Punkte für Phase 2

Aus den Findings ergeben sich konkrete Recherche-Lücken für Phase 2:

1. HdWM-interne KI-Richtlinien 2026 (Prüfungsordnung, Betreuer-Vorgaben Sandbrink)
2. Konkrete Quellen aus verwandten Bachelorarbeiten (Grin, OPUS, Uni-Repositories)
3. Zitat-Extraktions-Workflow mit Seiten-Verifikation (PDF + Claude Project)
4. Kodier-Workflow nach Mayring mit Claude: konkrete Prompt-Templates
5. Whisper-Setup mit DSGVO-konformer lokaler Verarbeitung
6. AI Usage Card Template als Vorlage für die Thesis
7. Rechtsquellen-Liste konkret zusammenstellen (Paragraphen, Absätze)
8. Mayring 13. Auflage beschaffen (Zotero)

## Phase 2 Konsolidierung (2026-04-20)

Scope-Korrektur während Phase 2: dieses Research-Projekt baut keinen Thesis-Content, sondern einen KI-gestützten Research-Workflow (siehe Scope 2 oben). Phase 2 war offen gefasste Workflow-Research, zwei Runden mit Perplexity und Gemini. Die Konsolidierung hier ist die Grundlage für den späteren Framework-Spec.

### Research-Inputs

- **Perplexity** lieferte die Tool-Landschaft: konkrete PDF-Analyse-Tools mit Preisen und Reliability-Berichten (Humata, SciSpace, Elicit, Readwise Ghostreader, Consensus, Scite), Open-Source-Alternativen (LARS, GroundX, Docling, GROBID), Obsidian-Community-Templates auf GitHub, ZotLit-Plugin, Systematic-Review-Tools (EPPI-Reviewer, ASReview, NestedKnowledge).
- **Gemini** lieferte die Architektur-Synthese: Karpathy-Wiki-Pattern (Markdown plus Git statt Vektordatenbank), funktionale Zerlegung in acht Phasen (Ingestion, Preprocessing, Analyse, Extraktion, Klassifikation, Speicherung, Abfrage, Nutzung), Sättigungs-Differenzierung (Data/Code/Theoretical), Puzzle-Operationalisierung via Information Gain und Betweenness Centrality, Failure-Mode-Katalog, Unterscheidung One-Way-Doors vs. reversible Entscheidungen.

### Systemwahrheiten (Konvergenzen)

Wo beide Quellen unabhängig zum selben Schluss kommen:

1. Speicherformat Markdown plus Git, nicht Datenbank und nicht proprietäre Plattform.
2. Human-in-the-Loop bei Klassifikation ist Pflicht. Kein LLM erreicht akzeptable Reliabilität autonom.
3. Passage-Level Verification (Zitat plus Seite plus Kontext-Snippet) ist die Architektur-Anforderung.
4. Kategoriensystem iterativ-kombiniert entwickeln (deduktiv starten, induktiv anpassen), nicht rein eine Richtung.
5. Batch-Verarbeitung statt synchron wenn das Volumen skaliert.
6. Controlled Vocabulary für Tags, sonst zerfällt der Pool.

### Architektur-Pfeiler (Thesen für Framework-Spec)

Diese Pfeiler sind aus den Konvergenzen abgeleitet und werden im Framework-Spec verbindlich festgelegt:

- Speicher: Markdown plus Git im Obsidian-Vault unter `01-projekte/bachelor-thesis/bachelor-thesis-assistant/`
- Eine Markdown-File pro Quelle mit YAML-Frontmatter plus strukturierten Abschnitten (Summary, Key Takeaways, direkte Zitate, paraphrasierbare Passagen, Hintergrund-Abschnitte)
- Zentraler Zitate-Pool als Dataview-Query über alle Quellen-Files, nicht als physische Master-File
- Codebook als versionierte Datei in `00-meta/`, Änderungen via Git-Historie, Refactoring bei Schema-Änderung durch LLM-Batch-Skript über den Bestand
- Mehrere kleine Claude-Skills pro Verarbeitungsschritt statt einem Mega-Skill
- Gate nach jeder Extraktion: LLM schlägt vor, Mensch bestätigt, erst dann Aufnahme in Pool
- Tool-Stack minimal halten: Claude Desktop plus MCP, Obsidian, Zotero. NotebookLM nur als Verification-Layer bei kritischen Zitaten.

### Tool-Landschaft (nach Reliability-Grad)

- Extrem hoch: NotebookLM (Bounding-Box-Citations, Source-Grounding, als Verification-Layer)
- Sehr hoch: manuelle Text-Extraktion plus Claude (umgeht PDF-Parsing-Fehler)
- Hoch: Claude Projects mit Force-Quote-Pattern und REQUIRES_MANUAL_VERIFICATION Stop-Condition
- Mittel-hoch: Claude API mit nativer Citations-Funktion (programmatischer Zugang)
- Mittel: Elicit für systematische Reviews, SciSpace, Humata (Cloud, US-Server, DSGVO kritisch)
- Spezialisiert Open-Source: GroundX (Line-Level-Zitate), LARS (lokales RAG), Docling und GROBID (Preprocessing)
- Referenz-Management: Zotero plus BetterBibTeX als Single Source of Truth für bibliographische Daten
- Obsidian-Integration: ZotLit oder Obsidian-Zotero-Integration (Entscheidung offen)
- Visualisierung: Dataview als Standard, InfraNodus optional für Structural Gap Analysis

### Failure-Modes mit Gegenmaßnahmen

Was in der Praxis kippt und wie man gegensteuert:

- **Agent Sprawl**: Jedes Mikro-Problem ein neues Tool → radikale Konsolidierung auf einen agnostischen Datenkern (Markdown)
- **Complexity Monster / Tag-Proliferation**: Zu viele Tags, kognitive Ermüdung → Reduktion auf Makro-Dimensionen, Controlled Vocabulary, LLM-Linter-Skript zur Tag-Bereinigung
- **Quellen-Dump / Read-It-Later-Friedhof**: Sammelwut ohne Verarbeitung → Gatekeeping, eine Quelle ist erst "aufgenommen" wenn die Markdown-File validiert ist
- **Ghost Citations / Halluzinierte Referenzen**: LLM erfindet plausible aber nicht-existente Quellen → Passage-Level Verification, Force-Quote-Pattern, Verbot freier KI-Generierung bei Faktensuche
- **Voice Flattening**: Thesis klingt am Ende nach LLM → strikte Aufgabentrennung, Mensch schreibt Komposition, Claude orchestriert nur Zitate

### Strategische Entscheidungen

**Irreversibel (One-Way-Doors, bis zur Thesis gilt was wir jetzt festlegen):**
- Speicherformat der Ground Truth (Markdown plus Git)
- OCR-Qualität der Ingestion (hohe Anforderung, Docling oder VLM-basiert wenn PDF-Qualität schlecht)
- Nachvollziehbarkeits-Architektur (Lineage von Aussage zu Quelle und Seite)

**Reversibel (können im Verlauf emergieren):**
- Feingranularität des Kategorien-Schemas (Start mit wenigen Makro-Kategorien, induktive Verfeinerung)
- Konkretes LLM (Claude heute, Wechsel jederzeit möglich weil Markdown tool-agnostisch)
- Visualisierungen und Dashboards (Dataview erst Basis, InfraNodus später wenn sinnvoll)

### Offene Fragen vor Framework-Spec

Diese Fragen beantwortet Deniz, bevor der Spec gebaut wird:

1. **Zotero-Rolle**: nur bibliographische Metadaten in Zotero und Zitate leben in Markdown-Files, oder Zitate auch in Zotero mit Sync zu Obsidian?
2. **Obsidian-Zotero-Integration**: ZotLit (automatischer Sync) oder manuell gepflegte Markdown-Files pro Quelle (mehr Kontrolle)?
3. **Klassifikations-Achsen**: Deniz' Dreischema (direkt / indirekt / Hintergrund) reicht, oder plus SemanticCite-Vierschema (Supported / Partially Supported / Unsupported / Uncertain) als zweite Achse?
4. **InfraNodus für Gap-Analyse**: ja, nein, oder erst nachträglich testen wenn Pool genug Substanz hat?
5. **Plus: welche Punkte sollen in die dritte Research-Runde** als spezifische offene Fragen?

### Nicht behandelt (explizit ausgelagert)

- Konkreter Vault-Pfad-Entwurf mit Unterordnern und Naming (in Framework-Spec)
- Skill-Implementierungen mit konkreten Prompts und Markdown-Templates (in Framework-Spec)
- Pilot-Test-Plan mit einer echten PDF (nach Framework-Spec)
- Zotero-APA-7-Umstellung (bleibt Sofort-Task, unabhängig vom Workflow)
- Phase-3-Research-Prompts (kommen nach Beantwortung der offenen Fragen)

### Abgeleitete Tasks

- [ ] Claude Project "Bachelorarbeit" anlegen nach Struktur-Entscheidung
- [ ] Mayring 13. Auflage beschaffen und in Zotero
- [ ] AI Usage Card Template anlegen, ab heute pflegen
- [ ] Eigenständigkeitserklärung-Draft mit KI-Opt-in vorbereiten
- [ ] HdWM-Prüfungsordnung auf KI-Richtlinien prüfen (vor Sandbrink-Call Donnerstag)
- [ ] Whisper-Setup lokal einrichten (später, wenn Interviews anstehen)
