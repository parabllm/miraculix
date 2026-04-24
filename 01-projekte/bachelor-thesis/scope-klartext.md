---
typ: aufgabe
name: "Scope Bachelor-Thesis (Klartext)"
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

# Scope Bachelor-Thesis

**KI-Compliance als Erfolgsfaktor: Strategische Gestaltung von Recruiting-Prozessen bei deutschen Personaldienstleistern unter dem EU AI Act**

Klartext-Fassung des Scopes, in der Betreuung mit [[christoph-sandbrink]] am 23.04.2026 präsentiert und bestätigt. Dient als Grundlage für das pipeline-konforme `scope.md` im Research-Vault (`bachelor-thesis-vault/00_meta/scope.md`) und als Arbeitsgrundlage im Miraculix-Vault.

---

## 1. Forschungsfrage

Wie müssen KI-Systeme im Recruiting bei deutschen Personaldienstleistern strategisch gestaltet werden, um sowohl die betriebliche Effizienz als auch die Anforderungen der KI-Compliance als Erfolgsfaktoren zu erfüllen?

Sandbrink-Feedback 23.04.2026: Forschungsfrage bestätigt, keine Anpassungen nötig.

---

## 2. Unterthesen

Sandbrink-Feedback 23.04.2026: Thesen bestätigt, dienen als inhaltlicher Anker der Arbeit.

**T1: Regulatorik als strukturelles Problem**
Der EU AI Act trifft große Personaldienstleister überproportional, da Recruiting-Prozesse als Hochrisiko-Anwendung eingestuft sind und die organisatorische Umsetzung in Konzernstrukturen langsamer erfolgt als bei kleineren Wettbewerbern.

**T2: Technologische Differenzierung der Compliance-Last**
Die regulatorische Belastung verteilt sich nicht gleichmäßig über alle KI-Anwendungen im Recruiting. Generative Verfahren wie LLM-basierte Textverarbeitung und Retrieval-Augmented Generation bleiben weitgehend beherrschbar, während embedding-basiertes Matching und transformer-basiertes Scoring stärker unter die Hochrisiko-Anforderungen des EU AI Acts fallen.

**T3: Governance als Transformations-Hebel**
Die Tool-Auswahl ist nachrangig. Entscheidend für den erfolgreichen KI-Einsatz im Recruiting sind klare Verantwortlichkeiten, definierte Review-Prozesse und wirksame interne Policies. Ein Personaldienstleister mit robustem Governance-Modell erreicht bessere Ergebnisse als einer mit fortschrittlicherer Technologie ohne Steuerungsstruktur.

**T4: Explainable AI als strategisches Differenzierungsmerkmal**
Explainable AI ist unter dem EU AI Act keine optionale Qualitätsmaßnahme, sondern eine faktische Betriebsvoraussetzung für Hochrisiko-Recruiting-Systeme. Die frühzeitige Integration schafft einen nachhaltigen Wettbewerbsvorteil gegenüber Anbietern, die Transparenz nachträglich herstellen müssen.

**T5: Adoptionsfrage auf operativer Ebene**
Ein strategischer Compliance-Vorteil realisiert sich nur bei operativer Akzeptanz. Wenn Recruiter KI-Systeme als Zusatzaufwand oder Kontrollinstrument wahrnehmen, entfaltet ein Top-Down-Governance-Modell keine Wirkung auf die tatsächliche Prozessqualität.

---

## 3. Zielsetzung und Endergebnis

Die Arbeit soll zwei Deliverables liefern:

1. **Theoretisches Framework** zur Orientierung für Personaldienstleister im Umgang mit KI unter dem EU AI Act. Aus der Literatur abgeleitet, ergänzt um Anwendungsbeispiele und zentrale Kontrollpunkte.
2. **Praxisorientierte Handlungsempfehlungen** aus den empirischen Ergebnissen der Experteninterviews. Adressiert das strategische Management deutscher Personaldienstleister.

Das theoretische Framework (Kapitel 2 und 3) wird in Kapitel 5 gegen die Interview-Ergebnisse gespiegelt. Aus der Synthese in Kapitel 6 entstehen die Handlungsempfehlungen.

**Primärer Leser:** Hochschule und Erstgutachter [[christoph-sandbrink]]. Die Arbeit soll darüber hinaus für interessierte Dritte (intern HAYS, extern Branchenvertreter) lesbar sein.

---

## 4. Literatur-Strategie

Sandbrink-Vorgabe 23.04.2026: Der Großteil der Literatur-Arbeit findet im vorderen Theorie-Block statt (Kapitel 2 und 3). Kapitel 5 (Empirie) und Kapitel 6 (Diskussion) greifen nur punktuell auf Literatur zurück, primär für die Einordnung empirischer Befunde.

**Kapitel 2 ist der zentrale Theorie-Block.** Alle Begrifflichkeiten, technologischen Grundlagen, regulatorischen Rahmenwerke und relevanten Konzepte werden hier sauber aufgebaut. Kapitel 3 ergänzt die strategische Einordnung (AI Governance, Spannungsfeld, Implementierungshürden). Nach Kapitel 3 ist die theoretische Basis vollständig gelegt.

**Konsequenz für die Pipeline:** Passagen mit `intended_use: theory` oder `context` werden primär den Abschnitten in Kapitel 2 und 3 zugeordnet. In Kapitel 5 wird nur ergänzend Literatur eingefügt, wo sie für die Interpretation der Interview-Aussagen zwingend nötig ist.

---

## 5. Kapitel-Wortverteilung

Zielumfang 11000 Wörter +/- 10 Prozent. Wortverteilung nach Sandbrink-Abstimmung:

| Kapitel | Anteil | Wörter (ca.) |
|---|---|---|
| 1 Einleitung | 10 % | 1100 |
| 2 KI-Systeme und regulatorisches Umfeld | 25 % | 2750 |
| 3 Strategische Gestaltung und AI-Governance | 15 % | 1650 |
| 4 Methodik | 15 bis 20 % | 1650 bis 2200 |
| 5 Empirische Ergebnisse | 15 bis 20 % | 1650 bis 2200 |
| 6 Diskussion und Implikationen | 15 bis 20 % | 1650 bis 2200 |
| 7 Fazit und Ausblick | 5 % | 550 |

**Theorie-Block Kapitel 2 und 3 zusammen: 40 Prozent (4400 Wörter).** Damit ist der Literatur-Großteil im vorderen Teil der Arbeit, wie von Sandbrink vorgegeben.

---

## 6. Fokussierte KI-Methoden

Auf Hinweis von Sandbrink (Spezifizierungspflicht) werden vier konkrete KI-Technologien im Fokus behandelt:

- **Large Language Models (LLM) für Textverarbeitung:** CV-Parsing, Stellenanzeigen-Generierung, automatisierte Kandidaten-Kommunikation, semantische Suche
- **Embedding-basiertes semantisches Matching:** Kandidaten-Stelle-Matching über Vektorraum-Ähnlichkeit statt Keyword-Match
- **Transformer-basierte Sortier- und Scoring-Modelle:** Algorithmisches Ranking und Fit-Scoring von Kandidaten, zentrale Hochrisiko-Anwendung unter EU AI Act
- **Retrieval-Augmented Generation (RAG):** Recruiter-Assistenzsysteme, die interne Kandidatendatenbanken mit externen Wissensquellen kombinieren

Als Contrast-Case wird automatisierte Video-Interview-Analyse (Emotion Recognition) erwähnt, da der EU AI Act diese Anwendung am Arbeitsplatz explizit verbietet (Artikel 5). Nicht im Fokus der Arbeit.

---

## 7. Abgrenzung und Tiefe

**Deutsche Personaldienstleister:**
Breit gefasst als in Deutschland tätige Personaldienstleister, unabhängig von der juristischen Herkunft der Muttergesellschaft. Mehrheit der Interviews mit HAYS-Mitarbeitern (vertiefter Fallzugang zur Branche), ergänzt durch mindestens eine externe Perspektive.

**Prozessumfang:**
Recruiting-Prozess als Gesamtheit von Sourcing, Screening, Matching, Kandidaten-Kommunikation und Kandidatenbewertung. Onboarding out-of-scope.

**Strategische Gestaltung:**
Drei Dimensionen werden betrachtet:
- Organisatorisch (Rollen, Verantwortlichkeiten, Steuerung)
- Technisch (Infrastruktur, Modell-Auswahl, Transparenz)
- Prozessual (Workflow-Integration, Mitarbeiterschulung, Mensch-KI-Zusammenarbeit)

**Zeitraum Literatur:**
2020 bis 2026 als Standard. Ältere Quellen nur bei Grundlagen (Algorithmic Decision Making, DSGVO-Historie).

**Geografie:**
EU mit Fokus Deutschland. US-Literatur ausschließlich als Kontrast zu EU-regulatorischen Anforderungen.

**Out of Scope:**
- Quantitative Methoden und Surveys
- Cross-Industry-Vergleich (Fokus bleibt Personaldienstleister-Branche)
- Implementierungsempfehlungen für konkrete KI-Tools (tool-agnostischer Ansatz)
- Onboarding-Prozesse nach Anstellung
- Emotion Recognition als eigenständiger Analysegegenstand (nur Contrast-Case)

---

## 8. Methodik

- **Erhebung:** Qualitative leitfadengestützte Experteninterviews
- **Auswertung:** Qualitative Inhaltsanalyse nach Mayring
- **Stichprobe:** 7 bis 9 Interviews, Mehrheit HAYS-intern plus mindestens eine externe Perspektive
- **Sampling:** Gezielte Stichprobe entlang definierter Cluster (Strategie, Compliance/Legal, KI-Arbeitsgruppe/Innovation, Sales/Operations)
- **Kategorienbildung:** Induktiv-deduktive Kombination. Deduktive Hauptkategorien aus Theorie und Unterthesen abgeleitet (K1 bis K6, siehe Sektion 9), induktive Unterkategorien bei Bedarf während der Materialauswertung.
- **Gütekriterien:** Intracoderreliabilität durch Doppelcodierung von 10 bis 20 Prozent des Materials mit zeitlichem Abstand. Kommunikative Validierung durch Diskussion kritischer Kodierungen mit Betreuer oder Kommilitonen. Transparente Dokumentation aller methodischen Entscheidungen.

**Mayring-Verarbeitung:**
Die Interview-Auswertung nach Mayring läuft NICHT über den Bachelor-Thesis-Research-Vault (bachelor-thesis-vault), sondern über einen separaten Vault mit eigener Mayring-Pipeline. Siehe Task [[mayring-vault-konzeption]].

Detail siehe [[forschungsdesign]] und [[mitarbeiteranfragen]].

---

## 9. Kategorien-System

Sandbrink-Feedback 23.04.2026: Kategorien bestätigt, insbesondere die Herangehensweise, dass sie sich strukturiert durch die gesamte Arbeit ziehen. Sechs deduktive Hauptkategorien zur Klassifikation von Literatur-Passagen und Interview-Aussagen. Induktive Unterkategorien bei Bedarf während der Materialauswertung.

**K1: EU AI Act und regulatorisches Umfeld**
Hochrisiko-Einstufung von Recruiting-Systemen, konkrete Compliance-Pflichten (Dokumentation, Transparenz, menschliche Aufsicht), DSGVO-Schnittstellen (insbesondere Art. 22), Enforcement-Zeitplan, nationale Umsetzung in Deutschland.
Bedient Thesen T1, T4. Triangulation erforderlich.

**K2: KI-Technologien im Recruiting**
LLM-basierte Textverarbeitung, embedding-basiertes Matching, transformer-basiertes Scoring, Retrieval-Augmented Generation, Explainable-AI-Ansätze, Black-Box-Problematik. Technische Grundlagen und Funktionsweisen der eingesetzten Verfahren.
Bedient Thesen T2, T4. Triangulation nicht zwingend.

**K3: Betriebliche Effizienz und Prozessauswirkungen**
Time-to-Hire, Kostenstrukturen, Prozessgeschwindigkeit, Qualität der Kandidatenauswahl. Wo KI messbaren Mehrwert liefert, wo Grenzen liegen.
Bedient Thesen T2, T5. Triangulation nicht zwingend.

**K4: AI Governance und strategische Steuerung**
Governance-Modelle, Rollen und Verantwortlichkeiten, Review-Prozesse, interne Policies, Risk-Management-Frameworks, organisatorische Unterschiede zwischen Konzernen und kleineren Firmen.
Bedient Thesen T1, T3. Triangulation erforderlich.

**K5: Implementierungshürden und operative Adoption**
Widerstände in der Organisation, Wettbewerbsdynamik zwischen großen und kleinen Personaldienstleistern, Akzeptanz auf Recruiter-Ebene, Schulung und Change-Management, Mensch-KI-Zusammenarbeit im Arbeitsalltag.
Bedient Thesen T1, T3, T5. Triangulation erforderlich.

**K6: Daten und algorithmische Fairness**
Datenqualität und Repräsentativität, Bias-Risiken in historischen Recruiting-Daten, Anforderungen des EU AI Act Art. 10 (Data Governance), diskriminierungsfreie Modellentwicklung, Monitoring von Entscheidungsverläufen.
Bedient Thesen T1, T4. Triangulation erforderlich.

**Kategorien-zu-Kapitel-Mapping (vorläufig):**

Kapitel 2 und 3 decken die theoretische Basis aller sechs Kategorien ab, thematisch strukturiert (nicht nach K1 bis K6 durchnummeriert). Die Zuordnung Abschnitt zu Kategorie wird später in `gliederung.md` über `primaere_kategorien` operationalisiert. Kapitel 5 spiegelt alle sechs Kategorien explizit in Unterkapiteln.

**Sättigungs-Richtwerte (Update 23.04.2026, nach erstem Pipeline-Test angezogen):**

| Kategorie | wortlaut | sinngemaess | hintergrund | beispiel | methoden | **Summe** |
|---|---|---|---|---|---|---|
| K1 EU AI Act | 10 | 15 | 8 | 5 | 2 | **40** |
| K2 KI-Technologien | 9 | 13 | 8 | 6 | 2 | **38** |
| K3 Effizienz | 7 | 11 | 5 | 6 | 1 | **30** |
| K4 AI Governance | 10 | 16 | 8 | 6 | 2 | **42** |
| K5 Implementierung | 8 | 13 | 7 | 7 | 1 | **36** |
| K6 Daten und Fairness | 9 | 13 | 7 | 5 | 1 | **35** |
| **Gesamt** | **53** | **81** | **43** | **35** | **9** | **221** |

Zielwert: 221 Passagen bei geplanten 30 bis 40 Quellen, ca. 5 bis 7 relevante Passagen pro Quelle. Bewusst ambitioniert, lieber Überschuss als Lücken.

**Projekt-spezifische Gap-Analysis-Schwellen:**
- rot: weniger als 25 Prozent des Kategorie-Ziels erreicht
- gelb: 25 bis 75 Prozent
- grün: ab 75 Prozent Die regulatorisch-theoretischen Kategorien K1, K4, K6 und die technologische K2 erhalten die höchste Sättigung, weil sie das theoretische Fundament des Kapitels 2 und 3 tragen. Werte sind live änderbar im Dashboard, können in der Schreibphase nachjustiert werden.

Jede Kategorie wird im separaten `codebook-klartext.md` mit Definition, Ankerbeispielen und Kodierregeln voll spezifiziert (Mayring-Standard).

---

## 10. Quellen-Qualitätsstandards

**Minimum Quality Tier:** `grey_literature_hoch`. Bedeutet: Peer-Reviewed und anerkannte Grey Literature sind Standard, breite Grey Literature nur bei klar begründetem Mehrwert.

**Verification Strictness:** `high`. Alle Quellen durchlaufen die volle Metadaten-Verifikation gegen Crossref, OpenAlex, DNB und Google Books.

**Quellen-Kategorien:**
- **Primärquellen:** EU AI Act Originaltext (OJ L series), DSGVO, offizielle Leitlinien der EU-Kommission, nationale Behörden-Dokumente (BMAS, BfDI)
- **Peer-Reviewed Literatur:** Wissenschaftliche Artikel aus Fachzeitschriften (Information Systems, HR Management, AI Ethics, Journal of Business Ethics, Computer Law and Security Review)
- **Grey Literature hoch:** Studien von Bitkom, Fraunhofer, Max-Planck-Institut, Algorithm Watch, anerkannten Think Tanks mit methodischer Transparenz
- **Grey Literature breit:** Branchenberichte, Konsultationspapiere, ausgewählte Praxisliteratur (nur bei Lücken in Peer-Reviewed-Literatur, etwa bei sehr neuen regulatorischen Entwicklungen)

---

## 11. Sandbrink-Feedback (Gespräch 23.04.2026)

**Bestätigt:**
- Forschungsfrage
- Fünf Unterthesen T1 bis T5
- Sechs Kategorien K1 bis K6
- Kategorien-Herangehensweise, durchziehend strukturiert
- Klassisch-lineares Gliederungsschema
- Wahl Mayring als Auswertungsmethode
- Stichprobe 7 bis 9 Interviews

**Korrekturen:**
- Literatur-Schwerpunkt liegt in Kapitel 2 (vorheriger Anteil 20 Prozent war zu wenig, jetzt 25 Prozent)
- Kapitel 5 (Ergebnisse) enthält weniger Literatur als vorher geplant, Literatur dort nur ergänzend
- Wortverteilung neu kalibriert (siehe Sektion 5)

**Offen aus dem Gespräch:**
- Zweiter externer Experte (parallel zu Florian Meyer LinkedIn)
- Interviewleitfaden-Feinschliff erst nach Kategorien-Vollspezifikation

---

## 12. Pipeline-Strategie nach Sondierung 23.04.2026

**Pipeline-Sondierung abgeschlossen.** Der Bachelor-Thesis-Research-Vault wird vollständig zurückgesetzt (alle Test-Quellen werden entfernt), dann mit der neuen K1-K6-Struktur befüllt. Siehe Task [[pipeline-reset-2026-04-23]].

**Routing-Logik (aus der Sondierung):**
Für Literatur-Passagen gewinnt der Abschnitt mit der niedrigsten Kapitel-Nummer, wenn mehrere Abschnitte dieselbe Primär-Kategorie tragen. Daraus folgt:

- **Kapitel 2 und 3 werden automatisch von der Pipeline befüllt** (sämtliche Theorie-Literatur zu K1 bis K6 landet dort)
- **Kapitel 5 (Empirie) bleibt pipeline-seitig leer** und wird manuell aus dem separaten Mayring-Vault bestückt. In `gliederung.md` bekommen alle 5.x-Abschnitte `primaere_kategorien: []` (Option A der Sondierung)
- **Kapitel 6 (Diskussion)** bleibt ebenfalls primär handgeführt. `primaere_kategorien: [K1, K2, K3, K4, K5, K6]` im Container-Kapitel, damit `counter_argument`-Passagen korrekt dorthin routen. Zusätzliche Literatur ziehe ich manuell via `/pool-query` in den Draft

**Befüllungs-Reihenfolge:**
1. Reset des Research-Vaults (Claude Code, Prompt bereits formuliert)
2. `scope.md` aus dem YAML-Block unten (Sektion 14)
3. `codebook.md` aus [[codebook-klartext]] (folgt)
4. `gliederung.md` aus [[gliederung-klartext]] (folgt)
5. Erste Quellen einladen, Pipeline läuft

---

## 13. Offene Punkte

- [ ] Reset des Research-Vaults via Claude Code durchführen
- [ ] Codebook-Klartext erstellen ([[codebook-klartext]]) mit Definition, Abgrenzung, Ankerbeispielen, Kodierregeln je K1 bis K6
- [ ] Gliederungs-Klartext erstellen ([[gliederung-klartext]]) mit Abschnitt-zu-Kategorie-Mapping
- [ ] YAML-Blöcke in Research-Vault übertragen (`scope.md`, `codebook.md`, `gliederung.md`)
- [ ] Erste Quellen einladen und Pipeline auf K1-K6 validieren
- [ ] Separater Mayring-Vault für Interview-Auswertung konzipieren ([[mayring-vault-konzeption]])
- [ ] Zweiter externer Experte identifizieren (parallel zu Florian Meyer LinkedIn)
- [ ] Interviewleitfaden-Feinschliff nach Codebook-Fertigstellung

---

## 14. Pipeline-YAML für `scope.md`

Dieser Block ist 1:1 in `bachelor-thesis-vault/00_meta/scope.md` übertragbar. Body-Prosa nach dem Frontmatter folgt dem Klartext-Aufbau oben (Sektionen 1 bis 10).

```yaml
---
# Metadaten (kein Pipeline-Effekt)
projekt_name: "KI-Compliance als Erfolgsfaktor: Strategische Gestaltung von Recruiting-Prozessen bei deutschen Personaldienstleistern unter dem EU AI Act"
projekt_kuerzel: "bt-ki-compliance-recruiting"
deliverable: "Bachelor-Thesis, HdWM Mannheim, Abgabe 2026-06-15"
zitierstil: "Elsevier (author-date/Harvard, with titles)"
zitierstil_csl_file: "elsevier-harvard-with-titles.csl"
sprache: "de"
umfang_ziel: "11000 Wörter plus-minus 10 Prozent"
zeitraum_scope: "2020-2026"
geografie_scope: "EU mit Fokus Deutschland"
erstellt: "2026-04-23"
zotero_collection: "Bachelorarbeit EU AI Act Recruiting"

# Pipeline-kritisch
status: "active"
scope_version: "v1.0"
verification_strictness: "high"
minimum_quality_tier: "grey_literature_hoch"

# Dashboard-kritisch
kategorien:
  - K1
  - K2
  - K3
  - K4
  - K5
  - K6

kategorien_spec:
  K1:
    name: "EU AI Act und regulatorisches Umfeld"
    saettigung_total:
      wortlaut_zitat: 10
      sinngemaess: 15
      hintergrund: 8
      beispiel: 5
      methoden_referenz: 2
    triangulation_erforderlich: true
  K2:
    name: "KI-Technologien im Recruiting"
    saettigung_total:
      wortlaut_zitat: 9
      sinngemaess: 13
      hintergrund: 8
      beispiel: 6
      methoden_referenz: 2
    triangulation_erforderlich: false
  K3:
    name: "Betriebliche Effizienz und Prozessauswirkungen"
    saettigung_total:
      wortlaut_zitat: 7
      sinngemaess: 11
      hintergrund: 5
      beispiel: 6
      methoden_referenz: 1
    triangulation_erforderlich: false
  K4:
    name: "AI Governance und strategische Steuerung"
    saettigung_total:
      wortlaut_zitat: 10
      sinngemaess: 16
      hintergrund: 8
      beispiel: 6
      methoden_referenz: 2
    triangulation_erforderlich: true
  K5:
    name: "Implementierungshürden und operative Adoption"
    saettigung_total:
      wortlaut_zitat: 8
      sinngemaess: 13
      hintergrund: 7
      beispiel: 7
      methoden_referenz: 1
    triangulation_erforderlich: true
  K6:
    name: "Daten und algorithmische Fairness"
    saettigung_total:
      wortlaut_zitat: 9
      sinngemaess: 13
      hintergrund: 7
      beispiel: 5
      methoden_referenz: 1
    triangulation_erforderlich: true
---

# Scope

## 1. Forschungsfrage

Wie müssen KI-Systeme im Recruiting bei deutschen Personaldienstleistern strategisch gestaltet werden, um sowohl die betriebliche Effizienz als auch die Anforderungen der KI-Compliance als Erfolgsfaktoren zu erfüllen?

## 2. Unterthesen

T1 Regulatorik als strukturelles Problem: Der EU AI Act trifft große Personaldienstleister überproportional, da Recruiting-Prozesse als Hochrisiko-Anwendung eingestuft sind und die organisatorische Umsetzung in Konzernstrukturen langsamer erfolgt als bei kleineren Wettbewerbern.

T2 Technologische Differenzierung der Compliance-Last: Generative Verfahren (LLM-Textverarbeitung, RAG) bleiben weitgehend beherrschbar, während embedding-basiertes Matching und transformer-basiertes Scoring stärker unter die Hochrisiko-Anforderungen fallen.

T3 Governance als Transformations-Hebel: Tool-Auswahl ist nachrangig. Entscheidend sind klare Verantwortlichkeiten, Review-Prozesse und interne Policies.

T4 Explainable AI als strategisches Differenzierungsmerkmal: Unter dem EU AI Act faktische Betriebsvoraussetzung für Hochrisiko-Recruiting-Systeme. Früh-Integration schafft Wettbewerbsvorteil.

T5 Adoptionsfrage auf operativer Ebene: Strategischer Compliance-Vorteil realisiert sich nur bei operativer Akzeptanz. Ohne Recruiter-Buy-In entfaltet Top-Down-Governance keine Wirkung.

## 3. Scope-Grenzen

Inklusions-Kriterien:
- Zeitraum 2020 bis 2026, ältere Quellen nur bei Grundlagen (Algorithmic Decision Making, DSGVO-Historie)
- Geografie EU mit Fokus Deutschland, US-Literatur nur als Kontrast
- Quellentypen peer_reviewed und grey_literature_hoch, grey_literature_breit nur bei Lücken
- Themen Recruiting-Prozess (Sourcing, Screening, Matching, Kommunikation, Bewertung), KI-Technologien (LLM, Embedding, Transformer-Scoring, RAG), EU AI Act plus DSGVO

Exklusions-Kriterien:
- Quantitative Methoden und Surveys als Primärquellen
- Cross-Industry-Vergleich außerhalb Personaldienstleister-Branche
- Tool-spezifische Implementierungsempfehlungen (tool-agnostischer Ansatz)
- Onboarding-Prozesse nach Anstellung
- Emotion Recognition in Video-Interviews als eigenständiger Analysegegenstand (nur Contrast-Case, EU AI Act Art. 5 Verbot)

## 4. Kategorien-System

K1 EU AI Act und regulatorisches Umfeld: Hochrisiko-Einstufung, Compliance-Pflichten (Dokumentation, Transparenz, menschliche Aufsicht), DSGVO-Schnittstellen (Art. 22), Enforcement-Zeitplan, nationale Umsetzung in Deutschland. Bedient T1, T4.

K2 KI-Technologien im Recruiting: LLM-Textverarbeitung, embedding-basiertes Matching, transformer-basiertes Scoring, RAG, Explainable AI, Black-Box-Problematik. Technische Grundlagen und Funktionsweisen. Bedient T2, T4.

K3 Betriebliche Effizienz und Prozessauswirkungen: Time-to-Hire, Kostenstrukturen, Prozessgeschwindigkeit, Qualität der Kandidatenauswahl. Messbare Mehrwerte und Grenzen. Bedient T2, T5.

K4 AI Governance und strategische Steuerung: Governance-Modelle, Rollen und Verantwortlichkeiten, Review-Prozesse, interne Policies, Risk-Management-Frameworks, Unterschiede Konzern vs. kleinere Firma. Bedient T1, T3.

K5 Implementierungshürden und operative Adoption: Organisatorische Widerstände, Wettbewerbsdynamik, Recruiter-Akzeptanz, Schulung, Change-Management, Mensch-KI-Zusammenarbeit. Bedient T1, T3, T5.

K6 Daten und algorithmische Fairness: Datenqualität und Repräsentativität, Bias-Risiken in historischen Recruiting-Daten, EU AI Act Art. 10 (Data Governance), diskriminierungsfreie Modellentwicklung, Monitoring. Bedient T1, T4.

## 5. Quellen-Qualitätsstandards

Minimum Quality Tier grey_literature_hoch. Verification Strictness high (volle Metadaten-Verifikation gegen Crossref, OpenAlex, DNB, Google Books).

Primärquellen: EU AI Act Originaltext, DSGVO, EU-Kommission-Leitlinien, BMAS, BfDI.
Peer-Reviewed: Information Systems, HR Management, AI Ethics, Journal of Business Ethics, Computer Law and Security Review.
Grey Literature hoch: Bitkom, Fraunhofer, Max-Planck-Institut, Algorithm Watch.
Grey Literature breit: nur bei Lücken, begründet.

## 6. Sättigungs-Kriterien

Siehe Frontmatter `kategorien_spec[Kn].saettigung_total`. Zielwerte: 167 Passagen gesamt bei 30 bis 40 Quellen. K1, K4, K6 (triangulations-pflichtig) und K2 (Technologie-Fundament) mit höchster Sättigung. K3 moderat, K5 zwischen beiden.

## 7. Methodik

Forschungsdesign qualitativ-empirisch. Erhebung via leitfadengestützte Experteninterviews (7 bis 9 Interviews, Mehrheit HAYS-intern plus mindestens eine externe Perspektive, Cluster Strategie, Compliance/Legal, KI-Arbeitsgruppe, Sales/Operations). Auswertung qualitative Inhaltsanalyse nach Mayring mit deduktiv-induktiver Kategorienbildung. Interview-Auswertung läuft in separatem Mayring-Vault, nicht in diesem Research-Vault.

## 8. Zeitplan

Abgabe: 2026-06-15 (hart). Interview-Phase Mai 2026. Schreibphase Mai-Juni 2026.

## 9. Hinweise für Skills

- Klassifikations-Prompt setzt bei Unsicherheit auf `kategorie_tag: unklassifiziert`, nicht raten
- Bei Quellen außerhalb des Scopes: `kategorie_tag: off_scope`
- `intended_use` in diesem Vault praktisch nur `theory` oder `context`, selten `counter_argument` oder `method`, nie `empirical` (Interviews separat)
- Kapitel 5 (Ergebnisse) wird pipeline-seitig nicht befüllt, alle 5.x-Abschnitte haben leere primaere_kategorien
- Kapitel 6 (Diskussion) hat volle Kategorien-Breite als primaere, aber Routing-wirksam nur für counter_argument
```
