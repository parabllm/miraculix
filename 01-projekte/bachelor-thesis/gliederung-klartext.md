---
typ: aufgabe
name: "Gliederung Bachelor-Thesis (Klartext)"
projekt: "[[bachelor-thesis]]"
status: bestaetigt
benoetigte_kapazitaet: hoch
kontext: ["desktop"]
faellig: 2026-04-23
kontakte: ["[[christoph-sandbrink]]"]
quelle: chat_session
vertrauen: bestaetigt
erstellt: 2026-04-23
zuletzt_aktualisiert: 2026-04-23
---

# Gliederung Bachelor-Thesis

**KI-Compliance als Erfolgsfaktor: Strategische Gestaltung von Recruiting-Prozessen bei deutschen Personaldienstleistern unter dem EU AI Act**

Pipeline-konforme Gliederung für die qualitativ-empirische Bachelor-Thesis. Klartext-Fassung oben, 1:1 übertragbarer YAML-Block unten (Sektion 6).

Strukturentscheidung: **Option A der Pipeline-Sondierung** (23.04.2026). Klassisch-lineares Schema mit kategorienbasierter Theorie-Struktur in Kapitel 2 und 3. Kapitel 5 (Empirie) und Kapitel 6 (Diskussion) sind handgeführt.

---

## 1. Gesamtstruktur

Sieben Hauptkapitel, klassisch-linear, maximal drei Gliederungsebenen. Zielumfang 11000 Wörter +/- 10 Prozent.

| Kapitel | Titel | Anteil | Wörter | Pipeline-Rolle |
|---|---|---|---|---|
| 1 | Einleitung | 10 % | 1100 | Handgeführt |
| 2 | KI-Systeme und regulatorisches Umfeld im Recruiting | 25 % | 2750 | Pipeline-Kern |
| 3 | Strategische Gestaltung und AI-Governance | 15 % | 1650 | Pipeline-Kern |
| 4 | Methodik der qualitativen Untersuchung | 15 bis 20 % | 2000 | Handgeführt |
| 5 | Empirische Ergebnisse entlang des Kategoriensystems | 15 bis 20 % | 2000 | Handgeführt (Mayring-Vault) |
| 6 | Diskussion und Implikationen | 15 bis 20 % | 2000 | Handgeführt plus counter_argument |
| 7 | Fazit und Ausblick | 5 % | 550 | Handgeführt |

**Theorie-Block (Kapitel 2 und 3) zusammen 40 Prozent.** Dort liegt der Großteil der Literatur-Arbeit (Sandbrink-Vorgabe). Die Pipeline befüllt automatisch die Unterkapitel von 2 und 3 über das Kategorien-Routing. Alle übrigen Kapitel werden beim Schreiben manuell mit Literatur aus dem Pool bestückt (via `/pool-query`) oder mit Interview-Zitaten aus dem separaten Mayring-Vault.

---

## 2. Kategorien-zu-Abschnitt-Mapping

Jede Kategorie K1 bis K6 hat genau einen Haupt-Empfänger-Abschnitt im Theorie-Block (Kapitel 2 und 3). Das vermeidet das Routing-Kollisionsproblem (Passage geht immer an die kleinste Kapitelnummer bei mehrfach gleicher Primär-Kategorie).

| Kategorie | Haupt-Empfänger | Sekundär in |
|---|---|---|
| K1 EU AI Act | 2.2 | 1.1 (Einleitung) |
| K2 KI-Technologien | 2.1 | 2.3 (XAI) |
| K3 Effizienz | 3.1 | |
| K4 AI Governance | 3.2 | 2.3 (XAI) |
| K5 Implementierung | 3.3 | 1.1 (Einleitung) |
| K6 Daten und Fairness | 2.4 | |

**Zwei Zwischenkapitel ohne primäre Zuordnung:**
- **2.3 Explainable AI und Black-Box-Problematik** hat keine primäre Kategorie, weil XAI sowohl K2 (Technologie) als auch K4 (Governance-Aspekte) bedient. Passagen werden per source-review manuell in 2.3 verschoben, wenn sie inhaltlich zu XAI gehören.
- **3.4 Ableitung des analytischen Bezugsrahmens** ist ein synthetisches Unterkapitel (selbstgeschrieben, ohne Zitate).

**Kapitel 6 als counter_argument-Senke:**
Kapitel 6 trägt `primaere_kategorien: [K1, K2, K3, K4, K5, K6]` auf Container-Ebene und die hardcoded Sonder-ID `"diskussion"`. Literatur-Passagen mit `intended_use: counter_argument` werden automatisch dort geroutet. Alle anderen Diskussions-Zitate kommen per `/pool-query` manuell in den Draft.

---

## 3. Detailaufbau je Kapitel

### Kapitel 1 Einleitung (1100 Wörter)

- **1.1 Problemstellung und Relevanz (500 Wörter)**
  Trichter von der gesellschaftlichen Relevanz der Regulierung durch den EU AI Act zum konkreten Problem der Personaldienstleister-Branche. Sekundäre Kategorien K1 (Regulatorik) und K5 (Implementierungshürden).
- **1.2 Zielsetzung, Forschungsfrage und Unterthesen (400 Wörter)**
  Forschungsfrage, die fünf Unterthesen T1 bis T5, Eingrenzung des Scopes.
- **1.3 Aufbau der Arbeit (200 Wörter)**
  Gang der Untersuchung.

### Kapitel 2 KI-Systeme und regulatorisches Umfeld (2750 Wörter)

Zentraler Theorie-Block. Bedient thematisch strukturiert K1, K2, K4 (sekundär), K6.

- **2.1 Begriffliche und technologische Grundlagen (700 Wörter)**
  Primär K2. LLM-Textverarbeitung, embedding-basiertes Matching, transformer-basiertes Scoring, RAG. Funktionsweise und Anwendungsbereiche.
- **2.2 Der EU AI Act und die Hochrisiko-Einstufung des Recruitings (900 Wörter)**
  Primär K1. Art. 6 und Annex III, Compliance-Pflichten (Dokumentation, Transparenz, menschliche Aufsicht), DSGVO-Schnittstellen (Art. 22), Enforcement-Zeitplan.
- **2.3 Explainable AI und die Black-Box-Problematik (600 Wörter)**
  Sekundär K2 und K4. XAI-Methoden, Transparenz-Anforderungen, Wettbewerbsdimension. Per source-review manuell bestückt.
- **2.4 Daten, Bias und algorithmische Fairness (550 Wörter)**
  Primär K6. Datenqualität und Repräsentativität, Bias-Risiken, Art. 10 (Data Governance).

### Kapitel 3 Strategische Gestaltung und AI-Governance (1650 Wörter)

Theorie-Block 2, strategische Einordnung auf Basis der technologisch-regulatorischen Grundlagen aus Kapitel 2.

- **3.1 Spannungsfeld zwischen betrieblicher Effizienz und Compliance (400 Wörter)**
  Primär K3. Time-to-Hire-Gewinne versus Compliance-Aufwand, Trade-offs, messbare Mehrwerte.
- **3.2 AI-Governance-Modelle als strategischer Steuerungsansatz (600 Wörter)**
  Primär K4. Governance-Frameworks, Rollen und Verantwortlichkeiten, Review-Prozesse, Unterschiede zwischen Konzernen und kleineren Firmen.
- **3.3 Implementierungshürden und Wettbewerbsdynamik bei Personaldienstleistern (400 Wörter)**
  Primär K5. Organisatorische Widerstände, Wettbewerb zwischen großen und kleinen PDLs, Recruiter-Akzeptanz.
- **3.4 Ableitung des analytischen Bezugsrahmens (250 Wörter)**
  Synthese aus Kapitel 2 und 3 als Vorbereitung der empirischen Analyse. Keine primäre Kategorie, selbstgeschriebener Text ohne Zitat-Schwerpunkt.


### Kapitel 4 Methodik der qualitativen Untersuchung (2000 Wörter)

Sonder-ID `methodik` (hardcoded im Routing für `method`-Passagen, auf Vorrat gesetzt).

- **4.1 Forschungsdesign und Begründung des qualitativen Ansatzes (400 Wörter)**
- **4.2 Leitfadengestützte Experteninterviews und Sampling (500 Wörter)**
- **4.3 Qualitative Inhaltsanalyse nach Mayring (deduktiv-induktive Kategorienbildung) (700 Wörter)**
- **4.4 Gütekriterien und Reflexion der Forscherrolle (400 Wörter)**

Literatur zu Mayring, Kuckartz, Gläser/Laudel, Theisen wird per `/pool-query` manuell gezogen. Pipeline-seitig bleiben diese Unterkapitel leer, weil keine Methodik-Literatur mit hoher Dichte eingeladen wird.

### Kapitel 5 Empirische Ergebnisse entlang des Kategoriensystems (2000 Wörter)

Sonder-ID `ergebnisse` (hardcoded im Routing für `empirical`-Passagen, auf Vorrat gesetzt). Alle Unterabschnitte haben `primaere_kategorien: []` (Option A der Pipeline-Sondierung). Die Interview-Auswertung läuft im separaten Mayring-Vault, von dort werden Zitate manuell in den Draft übernommen.

- **5.1 Überblick über Stichprobe und Kategoriensystem (300 Wörter)**
- **5.2 Regulatorisches Umfeld und Compliance-Wahrnehmung (K1) (300 Wörter)**
- **5.3 Eingesetzte KI-Technologien und Transparenz (K2) (250 Wörter)**
- **5.4 Betriebliche Effizienz und Prozessauswirkungen (K3) (250 Wörter)**
- **5.5 AI-Governance und strategische Steuerung (K4) (300 Wörter)**
- **5.6 Implementierungshürden und operative Adoption (K5) (300 Wörter)**
- **5.7 Daten und algorithmische Fairness (K6) (300 Wörter)**

### Kapitel 6 Diskussion und Implikationen (2000 Wörter)

Sonder-ID `diskussion`. Container-Kapitel 6 trägt `primaere_kategorien: [K1, K2, K3, K4, K5, K6]` als counter_argument-Senke. Die vier Unterabschnitte tragen leere Kategorien-Listen und `parent: "diskussion"`.

- **6.1 Rückbezug der Ergebnisse auf die Unterthesen T1 bis T5 (500 Wörter)**
- **6.2 Einordnung in den theoretischen Bezugsrahmen (500 Wörter)**
- **6.3 Handlungsempfehlungen für deutsche Personaldienstleister (700 Wörter)**
- **6.4 Limitationen und weiterer Forschungsbedarf (300 Wörter)**

### Kapitel 7 Fazit und Ausblick (550 Wörter)

- **7.1 Beantwortung der Forschungsfrage (300 Wörter)**
- **7.2 Beitrag der Arbeit und praktische Implikationen (250 Wörter)**

---

## 4. Routing-Verhalten (Zusammenfassung)

Für jede Literatur-Passage mit einer Kategorie K1 bis K6 entscheidet die Pipeline automatisch:

- **theory / context Passagen** → landen im Haupt-Empfänger-Abschnitt der Kategorie (kleinste Kapitelnummer bei Mehrfach-Zuordnung). Bedeutet: der gesamte Literatur-Theorie-Block fließt sauber in die Unterkapitel von 2 und 3.
- **counter_argument Passagen** → landen in Kapitel 6 (Container), weil `id: "diskussion"` hardcoded Rank 0 bekommt.
- **method Passagen** → landen in Kapitel 4 (Container), weil `id: "methodik"` hardcoded Rank 0 bekommt. Da aber kaum Methodik-Literatur eingeladen wird, ist das praktisch selten.
- **empirical Passagen** → würden in Kapitel 5 gehen, aber kommen in diesem Vault nicht vor (Interviews sind im separaten Mayring-Vault).

Die Sektions-Sättigungen im YAML sind auf die primären Empfänger-Abschnitte verteilt. Siehe Sektion 5 für die konkreten Zielwerte.

---

## 5. Sättigung pro Abschnitt

Die Sättigungszahlen in den primären Empfänger-Abschnitten entsprechen 1:1 den Scope-Sättigungen. Gesamt-Ziel 221 Passagen bei 30 bis 40 Quellen (Update 23.04.2026 nach erstem Pipeline-Test).

| Abschnitt | K | Wortlaut | Sinngemäß | Hintergrund | Beispiel | Methoden |
|---|---|---|---|---|---|---|
| 2.1 Grundlagen | K2 | 9 | 13 | 8 | 6 | 2 |
| 2.2 EU AI Act | K1 | 10 | 15 | 8 | 5 | 2 |
| 2.3 XAI | (sek K2, K4) | 0 | 0 | 0 | 0 | 0 |
| 2.4 Fairness | K6 | 9 | 13 | 7 | 5 | 1 |
| 3.1 Effizienz | K3 | 7 | 11 | 5 | 6 | 1 |
| 3.2 Governance | K4 | 10 | 16 | 8 | 6 | 2 |
| 3.3 Implementierung | K5 | 8 | 13 | 7 | 7 | 1 |
| 3.4 Bezugsrahmen | - | 0 | 0 | 0 | 0 | 0 |
| **Summe Kapitel 2+3** | | **53** | **81** | **43** | **35** | **9** |

Gesamt 221 Passagen Ziel. Alle übrigen Abschnitte (Einleitung, Methodik, Kapitel 5 komplett, Kapitel 6 Subsections, Fazit) haben Sättigung 0, handgeführt bestückt. Werte sind live änderbar in `gliederung.md`.

---

## 6. Pipeline-YAML für `gliederung.md`

Dieser Block ist 1:1 in `bachelor-thesis-vault/00_meta/gliederung.md` übertragbar.

```yaml
---
typ: gliederung
status: active
erstellt: "2026-04-23"
gliederung:
  # KAPITEL 1 - EINLEITUNG (1100 Wörter)
  - id: "einleitung"
    nummer: "1"
    titel: "Einleitung"
    parent: null
    primaere_kategorien: []
    sekundaere_kategorien: []
    ziel_woerter: 1100
    saettigung:
      wortlaut_zitat: 0
      sinngemaess: 0
      hintergrund: 0
      beispiel: 0
      methoden_referenz: 0
    status: "offen"
    beschreibung: "Container-Kapitel, handgeführt"

  - id: "problemstellung"
    nummer: "1.1"
    titel: "Problemstellung und Relevanz"
    parent: "einleitung"
    primaere_kategorien: []
    sekundaere_kategorien: [K1, K5]
    ziel_woerter: 500
    saettigung:
      wortlaut_zitat: 0
      sinngemaess: 0
      hintergrund: 0
      beispiel: 0
      methoden_referenz: 0
    status: "offen"
    beschreibung: "Trichter gesellschaftliche Relevanz zur Branchenspezifik"

  - id: "zielsetzung"
    nummer: "1.2"
    titel: "Zielsetzung, Forschungsfrage und Unterthesen"
    parent: "einleitung"
    primaere_kategorien: []
    sekundaere_kategorien: []
    ziel_woerter: 400
    saettigung:
      wortlaut_zitat: 0
      sinngemaess: 0
      hintergrund: 0
      beispiel: 0
      methoden_referenz: 0
    status: "offen"
    beschreibung: "Forschungsfrage, T1-T5, Scope-Eingrenzung"

  - id: "aufbau"
    nummer: "1.3"
    titel: "Aufbau der Arbeit"
    parent: "einleitung"
    primaere_kategorien: []
    sekundaere_kategorien: []
    ziel_woerter: 200
    saettigung:
      wortlaut_zitat: 0
      sinngemaess: 0
      hintergrund: 0
      beispiel: 0
      methoden_referenz: 0
    status: "offen"
    beschreibung: "Gang der Untersuchung"

  # KAPITEL 2 - KI-SYSTEME UND REGULATORISCHES UMFELD (2750 Wörter)
  - id: "grundlagen"
    nummer: "2"
    titel: "KI-Systeme und regulatorisches Umfeld im Recruiting"
    parent: null
    primaere_kategorien: []
    sekundaere_kategorien: []
    ziel_woerter: 2750
    saettigung:
      wortlaut_zitat: 0
      sinngemaess: 0
      hintergrund: 0
      beispiel: 0
      methoden_referenz: 0
    status: "offen"
    beschreibung: "Zentraler Theorie-Block, thematisch strukturiert"

  - id: "grundlagen-begriffe"
    nummer: "2.1"
    titel: "Begriffliche und technologische Grundlagen"
    parent: "grundlagen"
    primaere_kategorien: [K2]
    sekundaere_kategorien: []
    ziel_woerter: 700
    saettigung:
      wortlaut_zitat: 9
      sinngemaess: 13
      hintergrund: 8
      beispiel: 6
      methoden_referenz: 2
    status: "offen"
    beschreibung: "LLM, Embedding, Transformer-Scoring, RAG"

  - id: "grundlagen-ai-act"
    nummer: "2.2"
    titel: "Der EU AI Act und die Hochrisiko-Einstufung des Recruitings"
    parent: "grundlagen"
    primaere_kategorien: [K1]
    sekundaere_kategorien: []
    ziel_woerter: 900
    saettigung:
      wortlaut_zitat: 10
      sinngemaess: 15
      hintergrund: 8
      beispiel: 5
      methoden_referenz: 2
    status: "offen"
    beschreibung: "Art. 6, Annex III, Compliance-Pflichten, DSGVO-Schnittstellen"

  - id: "grundlagen-xai"
    nummer: "2.3"
    titel: "Explainable AI und die Black-Box-Problematik"
    parent: "grundlagen"
    primaere_kategorien: []
    sekundaere_kategorien: [K2, K4]
    ziel_woerter: 600
    saettigung:
      wortlaut_zitat: 0
      sinngemaess: 0
      hintergrund: 0
      beispiel: 0
      methoden_referenz: 0
    status: "offen"
    beschreibung: "XAI-Methoden, Transparenz-Anforderungen, Black-Box-Risiken. Per source-review manuell zuordnen."

  - id: "grundlagen-fairness"
    nummer: "2.4"
    titel: "Daten, Bias und algorithmische Fairness"
    parent: "grundlagen"
    primaere_kategorien: [K6]
    sekundaere_kategorien: []
    ziel_woerter: 550
    saettigung:
      wortlaut_zitat: 9
      sinngemaess: 13
      hintergrund: 7
      beispiel: 5
      methoden_referenz: 1
    status: "offen"
    beschreibung: "Datenqualität, Bias-Risiken, Art. 10 Data Governance"

  # KAPITEL 3 - STRATEGISCHE GESTALTUNG UND AI-GOVERNANCE (1650 Wörter)
  - id: "strategie"
    nummer: "3"
    titel: "Strategische Gestaltung und AI-Governance"
    parent: null
    primaere_kategorien: []
    sekundaere_kategorien: []
    ziel_woerter: 1650
    saettigung:
      wortlaut_zitat: 0
      sinngemaess: 0
      hintergrund: 0
      beispiel: 0
      methoden_referenz: 0
    status: "offen"
    beschreibung: "Theorie-Block 2, strategische Einordnung"

  - id: "strategie-spannungsfeld"
    nummer: "3.1"
    titel: "Spannungsfeld zwischen betrieblicher Effizienz und Compliance"
    parent: "strategie"
    primaere_kategorien: [K3]
    sekundaere_kategorien: []
    ziel_woerter: 400
    saettigung:
      wortlaut_zitat: 7
      sinngemaess: 11
      hintergrund: 5
      beispiel: 6
      methoden_referenz: 1
    status: "offen"
    beschreibung: "Time-to-Hire, Trade-offs, messbare Mehrwerte und Grenzen"

  - id: "strategie-governance"
    nummer: "3.2"
    titel: "AI-Governance-Modelle als strategischer Steuerungsansatz"
    parent: "strategie"
    primaere_kategorien: [K4]
    sekundaere_kategorien: []
    ziel_woerter: 600
    saettigung:
      wortlaut_zitat: 10
      sinngemaess: 16
      hintergrund: 8
      beispiel: 6
      methoden_referenz: 2
    status: "offen"
    beschreibung: "Governance-Modelle, Rollen, Review-Prozesse, Konzern vs. kleinere Firmen"

  - id: "strategie-implementierung"
    nummer: "3.3"
    titel: "Implementierungshürden und Wettbewerbsdynamik bei Personaldienstleistern"
    parent: "strategie"
    primaere_kategorien: [K5]
    sekundaere_kategorien: []
    ziel_woerter: 400
    saettigung:
      wortlaut_zitat: 8
      sinngemaess: 13
      hintergrund: 7
      beispiel: 7
      methoden_referenz: 1
    status: "offen"
    beschreibung: "Organisatorische Widerstände, Wettbewerb, Recruiter-Akzeptanz"

  - id: "strategie-bezugsrahmen"
    nummer: "3.4"
    titel: "Ableitung des analytischen Bezugsrahmens"
    parent: "strategie"
    primaere_kategorien: []
    sekundaere_kategorien: []
    ziel_woerter: 250
    saettigung:
      wortlaut_zitat: 0
      sinngemaess: 0
      hintergrund: 0
      beispiel: 0
      methoden_referenz: 0
    status: "offen"
    beschreibung: "Synthese Kapitel 2+3, selbstgeschrieben"

  # KAPITEL 4 - METHODIK (2000 Wörter, Sonder-ID "methodik")
  - id: "methodik"
    nummer: "4"
    titel: "Methodik der qualitativen Untersuchung"
    parent: null
    primaere_kategorien: []
    sekundaere_kategorien: []
    ziel_woerter: 2000
    saettigung:
      wortlaut_zitat: 0
      sinngemaess: 0
      hintergrund: 0
      beispiel: 0
      methoden_referenz: 0
    status: "offen"
    beschreibung: "Methodik-Kapitel, Sonder-ID für method-Passagen-Routing"

  - id: "methodik-design"
    nummer: "4.1"
    titel: "Forschungsdesign und Begründung des qualitativen Ansatzes"
    parent: "methodik"
    primaere_kategorien: []
    sekundaere_kategorien: []
    ziel_woerter: 400
    saettigung:
      wortlaut_zitat: 0
      sinngemaess: 0
      hintergrund: 0
      beispiel: 0
      methoden_referenz: 0
    status: "offen"
    beschreibung: "Qualitativ-empirischer Ansatz, Begründung"

  - id: "methodik-interviews"
    nummer: "4.2"
    titel: "Leitfadengestützte Experteninterviews und Sampling"
    parent: "methodik"
    primaere_kategorien: []
    sekundaere_kategorien: []
    ziel_woerter: 500
    saettigung:
      wortlaut_zitat: 0
      sinngemaess: 0
      hintergrund: 0
      beispiel: 0
      methoden_referenz: 0
    status: "offen"
    beschreibung: "Sampling 7-9 Interviews, Cluster, Leitfaden-Konstruktion"

  - id: "methodik-mayring"
    nummer: "4.3"
    titel: "Qualitative Inhaltsanalyse nach Mayring"
    parent: "methodik"
    primaere_kategorien: []
    sekundaere_kategorien: []
    ziel_woerter: 700
    saettigung:
      wortlaut_zitat: 0
      sinngemaess: 0
      hintergrund: 0
      beispiel: 0
      methoden_referenz: 0
    status: "offen"
    beschreibung: "Deduktiv-induktive Kategorienbildung, Kodiereinheiten, separater Mayring-Vault"

  - id: "methodik-guete"
    nummer: "4.4"
    titel: "Gütekriterien und Reflexion der Forscherrolle"
    parent: "methodik"
    primaere_kategorien: []
    sekundaere_kategorien: []
    ziel_woerter: 400
    saettigung:
      wortlaut_zitat: 0
      sinngemaess: 0
      hintergrund: 0
      beispiel: 0
      methoden_referenz: 0
    status: "offen"
    beschreibung: "Intracoderreliabilität, kommunikative Validierung"

  # KAPITEL 5 - ERGEBNISSE (2000 Wörter, Sonder-ID "ergebnisse", Option A: alle leer)
  - id: "ergebnisse"
    nummer: "5"
    titel: "Empirische Ergebnisse entlang des Kategoriensystems"
    parent: null
    primaere_kategorien: []
    sekundaere_kategorien: []
    ziel_woerter: 2000
    saettigung:
      wortlaut_zitat: 0
      sinngemaess: 0
      hintergrund: 0
      beispiel: 0
      methoden_referenz: 0
    status: "offen"
    beschreibung: "Interview-Ergebnisse, manuell aus Mayring-Vault"

  - id: "ergebnisse-ueberblick"
    nummer: "5.1"
    titel: "Überblick über Stichprobe und Kategoriensystem"
    parent: "ergebnisse"
    primaere_kategorien: []
    sekundaere_kategorien: []
    ziel_woerter: 300
    saettigung:
      wortlaut_zitat: 0
      sinngemaess: 0
      hintergrund: 0
      beispiel: 0
      methoden_referenz: 0
    status: "offen"
    beschreibung: "Anonymisierte Tabelle der Interviewten, Kategorien-Übersicht"

  - id: "ergebnisse-k1"
    nummer: "5.2"
    titel: "Regulatorisches Umfeld und Compliance-Wahrnehmung"
    parent: "ergebnisse"
    primaere_kategorien: []
    sekundaere_kategorien: []
    ziel_woerter: 300
    saettigung:
      wortlaut_zitat: 0
      sinngemaess: 0
      hintergrund: 0
      beispiel: 0
      methoden_referenz: 0
    status: "offen"
    beschreibung: "K1-Empirie aus Interviews, handgeführt"

  - id: "ergebnisse-k2"
    nummer: "5.3"
    titel: "Eingesetzte KI-Technologien und Transparenz"
    parent: "ergebnisse"
    primaere_kategorien: []
    sekundaere_kategorien: []
    ziel_woerter: 250
    saettigung:
      wortlaut_zitat: 0
      sinngemaess: 0
      hintergrund: 0
      beispiel: 0
      methoden_referenz: 0
    status: "offen"
    beschreibung: "K2-Empirie aus Interviews, handgeführt"

  - id: "ergebnisse-k3"
    nummer: "5.4"
    titel: "Betriebliche Effizienz und Prozessauswirkungen"
    parent: "ergebnisse"
    primaere_kategorien: []
    sekundaere_kategorien: []
    ziel_woerter: 250
    saettigung:
      wortlaut_zitat: 0
      sinngemaess: 0
      hintergrund: 0
      beispiel: 0
      methoden_referenz: 0
    status: "offen"
    beschreibung: "K3-Empirie aus Interviews, handgeführt"

  - id: "ergebnisse-k4"
    nummer: "5.5"
    titel: "AI-Governance und strategische Steuerung"
    parent: "ergebnisse"
    primaere_kategorien: []
    sekundaere_kategorien: []
    ziel_woerter: 300
    saettigung:
      wortlaut_zitat: 0
      sinngemaess: 0
      hintergrund: 0
      beispiel: 0
      methoden_referenz: 0
    status: "offen"
    beschreibung: "K4-Empirie aus Interviews, handgeführt"

  - id: "ergebnisse-k5"
    nummer: "5.6"
    titel: "Implementierungshürden und operative Adoption"
    parent: "ergebnisse"
    primaere_kategorien: []
    sekundaere_kategorien: []
    ziel_woerter: 300
    saettigung:
      wortlaut_zitat: 0
      sinngemaess: 0
      hintergrund: 0
      beispiel: 0
      methoden_referenz: 0
    status: "offen"
    beschreibung: "K5-Empirie aus Interviews, handgeführt"

  - id: "ergebnisse-k6"
    nummer: "5.7"
    titel: "Daten und algorithmische Fairness"
    parent: "ergebnisse"
    primaere_kategorien: []
    sekundaere_kategorien: []
    ziel_woerter: 300
    saettigung:
      wortlaut_zitat: 0
      sinngemaess: 0
      hintergrund: 0
      beispiel: 0
      methoden_referenz: 0
    status: "offen"
    beschreibung: "K6-Empirie aus Interviews, handgeführt"

  # KAPITEL 6 - DISKUSSION (2000 Wörter, Sonder-ID "diskussion", volle Kategorien-Breite)
  - id: "diskussion"
    nummer: "6"
    titel: "Diskussion und Implikationen"
    parent: null
    primaere_kategorien: [K1, K2, K3, K4, K5, K6]
    sekundaere_kategorien: []
    ziel_woerter: 2000
    saettigung:
      wortlaut_zitat: 2
      sinngemaess: 3
      hintergrund: 1
      beispiel: 0
      methoden_referenz: 0
    status: "offen"
    beschreibung: "counter_argument-Senke, ansonsten handgeführt via pool-query"

  - id: "diskussion-thesen"
    nummer: "6.1"
    titel: "Rückbezug der Ergebnisse auf die Unterthesen T1 bis T5"
    parent: "diskussion"
    primaere_kategorien: []
    sekundaere_kategorien: []
    ziel_woerter: 500
    saettigung:
      wortlaut_zitat: 0
      sinngemaess: 0
      hintergrund: 0
      beispiel: 0
      methoden_referenz: 0
    status: "offen"
    beschreibung: "Interview-Befunde gegen T1-T5 spiegeln"

  - id: "diskussion-einordnung"
    nummer: "6.2"
    titel: "Einordnung in den theoretischen Bezugsrahmen"
    parent: "diskussion"
    primaere_kategorien: []
    sekundaere_kategorien: []
    ziel_woerter: 500
    saettigung:
      wortlaut_zitat: 0
      sinngemaess: 0
      hintergrund: 0
      beispiel: 0
      methoden_referenz: 0
    status: "offen"
    beschreibung: "Abgleich Empirie mit Kapitel 2+3"

  - id: "diskussion-handlungsempfehlungen"
    nummer: "6.3"
    titel: "Handlungsempfehlungen für deutsche Personaldienstleister"
    parent: "diskussion"
    primaere_kategorien: []
    sekundaere_kategorien: []
    ziel_woerter: 700
    saettigung:
      wortlaut_zitat: 0
      sinngemaess: 0
      hintergrund: 0
      beispiel: 0
      methoden_referenz: 0
    status: "offen"
    beschreibung: "Strategische Management Implikationen"

  - id: "diskussion-limitationen"
    nummer: "6.4"
    titel: "Limitationen und weiterer Forschungsbedarf"
    parent: "diskussion"
    primaere_kategorien: []
    sekundaere_kategorien: []
    ziel_woerter: 300
    saettigung:
      wortlaut_zitat: 0
      sinngemaess: 0
      hintergrund: 0
      beispiel: 0
      methoden_referenz: 0
    status: "offen"
    beschreibung: "Methodische Grenzen, offene Forschungsfragen"

  # KAPITEL 7 - FAZIT (550 Wörter)
  - id: "fazit"
    nummer: "7"
    titel: "Fazit und Ausblick"
    parent: null
    primaere_kategorien: []
    sekundaere_kategorien: []
    ziel_woerter: 550
    saettigung:
      wortlaut_zitat: 0
      sinngemaess: 0
      hintergrund: 0
      beispiel: 0
      methoden_referenz: 0
    status: "offen"
    beschreibung: "Container-Kapitel, handgeführt, keine neuen Zitate"

  - id: "fazit-beantwortung"
    nummer: "7.1"
    titel: "Beantwortung der Forschungsfrage"
    parent: "fazit"
    primaere_kategorien: []
    sekundaere_kategorien: []
    ziel_woerter: 300
    saettigung:
      wortlaut_zitat: 0
      sinngemaess: 0
      hintergrund: 0
      beispiel: 0
      methoden_referenz: 0
    status: "offen"
    beschreibung: "Zusammenfassung der Kernbefunde"

  - id: "fazit-beitrag"
    nummer: "7.2"
    titel: "Beitrag der Arbeit und praktische Implikationen"
    parent: "fazit"
    primaere_kategorien: []
    sekundaere_kategorien: []
    ziel_woerter: 250
    saettigung:
      wortlaut_zitat: 0
      sinngemaess: 0
      hintergrund: 0
      beispiel: 0
      methoden_referenz: 0
    status: "offen"
    beschreibung: "Wissenschaftlicher und praktischer Mehrwert, Ausblick"
---

# Gliederung

Diese Gliederung folgt dem klassisch-linearen Schema für empirisch-qualitative Wirtschafts-Bachelorarbeiten mit Mayring-Methodik. Die thematische Strukturierung von Kapitel 2 und 3 erlaubt einen kategorienübergreifenden Aufbau der theoretischen Basis. Die Interview-Ergebnisse in Kapitel 5 spiegeln die sechs Kategorien K1 bis K6 eins zu eins in Unterkapiteln, werden aber handgeführt aus dem separaten Mayring-Vault gezogen. Kapitel 6 kulminiert in den praxisorientierten Handlungsempfehlungen (wirtschaftswissenschaftlicher Pflicht-Deliverable).
```

