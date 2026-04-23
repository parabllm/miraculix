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

**Sättigungs-Richtwerte werden nach Pipeline-Sondierung finalisiert.** Die aktuellen Zahlen aus früherer Version sind vorläufig und werden nach Rückmeldung zur Pipeline-Logik überarbeitet.

Jede Kategorie wird vor Pipeline-Aktivierung mit Definition, zwei bis drei Ankerbeispielen und Kodierregeln zur Abgrenzung voll spezifiziert (Mayring-Standard).

---

## 10. Quellen-Qualitätsstandards

Wird nach Pipeline-Sondierung finalisiert. Vorläufige Orientierung:
- **Primärquellen:** EU AI Act Originaltext, DSGVO, offizielle Leitlinien der EU-Kommission und nationaler Behörden
- **Peer-Reviewed Literatur:** Wissenschaftliche Artikel aus Fachzeitschriften (Information Systems, HR Management, AI Ethics)
- **Grey Literature (hohe Qualität):** Studien von Bitkom, Fraunhofer, Max-Planck-Institut, anerkannten Think Tanks
- **Grey Literature (breit):** Branchenberichte, Konsultationspapiere, ausgewählte Praxisliteratur

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

## 12. Offene Punkte

- Pipeline-Sondierung im Bachelor-Thesis-Research-Vault läuft (Claude Code)
- Nach Rückmeldung der Pipeline-Sondierung wird entschieden, ob Scope und Gliederung direkt in `scope.md` und `gliederung.md` übertragen werden können
- Gliederung wird nach Pipeline-Sondierung finalisiert und ins Pipeline-konforme Format gebracht
- Separater Mayring-Vault für Interview-Auswertung zu konzipieren (siehe [[mayring-vault-konzeption]])
- Kategorien-Vollspezifikation (Definition, Ankerbeispiele, Kodierregeln je Kategorie) vor Pipeline-Aktivierung
- Sättigungs-Richtwerte nach Pipeline-Sondierung finalisieren
- EU AI Act-Primärquellen und aktuelle Fachliteratur noch zu sichten (startet nach Pipeline-Aktivierung)

---

## 13. Abgeschlossene Deliverables

- ~~Dreiseitiges PDF Briefing für Sandbrink-Gespräch (Thesen, Kategorien, Gliederung)~~ erstellt 23.04.2026, siehe [[bachelor-thesis-briefing-sandbrink]]
- ~~Sandbrink-Gespräch durchgeführt~~ 23.04.2026
- ~~Scope inhaltlich finalisiert~~ 23.04.2026
