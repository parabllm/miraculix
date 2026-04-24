---
typ: aufgabe
name: "Codebook Bachelor-Thesis (Klartext)"
projekt: "[[bachelor-thesis]]"
status: bestaetigt
benoetigte_kapazitaet: hoch
kontext: ["desktop"]
faellig: 2026-04-23
kontakte: ["[[christoph-sandbrink]]"]
quelle: chat_session
vertrauen: bestätigt
erstellt: 2026-04-23
zuletzt_aktualisiert: 2026-04-23
---

# Codebook Bachelor-Thesis

**KI-Compliance als Erfolgsfaktor: Strategische Gestaltung von Recruiting-Prozessen bei deutschen Personaldienstleistern unter dem EU AI Act**

Kategorien-Handbuch für die deduktive Klassifikation von Literatur-Passagen. Pro Kategorie K1 bis K6: Definition, thematische Abgrenzung, zwei bis drei prototypische Ankerbeispiele, Kodierregeln für Zweifelsfälle.

**Methodische Grundlage:** Qualitative Inhaltsanalyse nach Mayring. Deduktiv-induktiver Ansatz. Die sechs Hauptkategorien sind aus Forschungsfrage, Unterthesen T1 bis T5 und fokussierten KI-Methoden abgeleitet. Induktive Unterkategorien werden bei Bedarf während der Materialauswertung (Interview-Transkripte im separaten Mayring-Vault) am Material gebildet.

**Geltungsbereich dieses Codebooks:**
- Literatur-Klassifikation im Bachelor-Thesis-Research-Vault (Primärzweck)
- Referenz für LLM-Klassifikations-Prompts beim Passage-Extract
- Referenz für manuelle Umklassifikation im `source-review`-Flow
- Basis für das erweiterte Codebook im separaten Mayring-Vault (Interview-Analyse)

**Ankerbeispiele sind konstruiert** (Option A der Scope-Besprechung), nicht aus realen Quellen. Sie dienen der LLM-Orientierung bei der ersten Klassifikations-Runde und werden nach den ersten 5 bis 10 realen Quellen durch belegte Formulierungen ersetzt.

---

## K1: EU AI Act und regulatorisches Umfeld

**Definition**
K1 umfasst alle Textstellen, die sich mit dem EU AI Act (Verordnung 2024/1689) und seinen flankierenden regulatorischen Rahmenwerken im Kontext des Recruiting-Einsatzes von KI-Systemen befassen. Im Fokus stehen die Hochrisiko-Einstufung von Recruiting-Systemen (Art. 6 in Verbindung mit Annex III Nr. 4), die daraus resultierenden Compliance-Pflichten (Dokumentation, Transparenz gegenüber Betroffenen, menschliche Aufsicht, konformitätsbewertung), die Schnittstellen zur DSGVO (insbesondere Art. 22 zum Verbot automatisierter Einzelentscheidungen), der Enforcement-Zeitplan sowie die nationale Umsetzung in Deutschland.

**Thematische Abgrenzung (gehört nach K1)**
- Konkrete rechtliche Anforderungen aus dem AI Act an Recruiting-Systeme
- Hochrisiko-Klassifikation und ihre Konsequenzen
- DSGVO-Schnittstellen mit unmittelbarem Bezug zum AI Act
- Nationale Umsetzungsgesetze, Aufsichtsbehörden-Zuständigkeiten
- Historische Entwicklung der KI-Regulierung in der EU
- Kritik am regulatorischen Ansatz, regulatorische Debatten

**Thematische Abgrenzung (gehört NICHT nach K1)**
- Interne Governance-Strukturen in Unternehmen zur Umsetzung der Compliance (das ist K4)
- Praktische Implementierungsherausforderungen (das ist K5)
- Datenschutz-Fragen ohne AI-Act-Bezug und ohne Recruiting-Kontext (off_scope)
- Detaillierte technische Beschreibungen von Transparenz-Mechanismen wie SHAP oder LIME (das ist K2)

**Ankerbeispiele**

1. "Rekrutierungs- und Personalauswahlsysteme, die auf künstlicher Intelligenz basieren, werden in Annex III Nr. 4 des EU AI Act als Hochrisiko-Anwendung eingestuft. Anbieter und Betreiber unterliegen damit den Pflichten der Artikel 8 bis 15, insbesondere dem Aufbau eines Risikomanagementsystems und der Dokumentationspflicht."
2. "Art. 22 DSGVO verbietet Entscheidungen, die ausschließlich auf automatisierter Verarbeitung beruhen und rechtliche Wirkung entfalten, sofern keine Ausnahme nach Abs. 2 greift. Im Recruiting bedeutet dies eine funktionale Kopplung mit den Transparenzpflichten des AI Acts, insbesondere dem Informationsrecht der betroffenen Person."
3. "Der stufenweise Enforcement-Zeitplan des AI Acts sieht die volle Anwendung der Hochrisiko-Bestimmungen ab August 2026 vor. Personaldienstleister haben damit eine begrenzte Umsetzungsfrist, in der sowohl technische als auch organisatorische Anpassungen erfolgen müssen."

**Kodierregeln für Zweifelsfälle**
- Passage nennt den AI Act UND beschreibt Governance-Umsetzung → K1 wenn regulatorischer Anspruch im Vordergrund, K4 wenn Unternehmens-interne Umsetzung im Vordergrund. Bei echtem Gleichgewicht K1 primär.
- Passage nennt DSGVO ohne AI-Act-Bezug → K1 nur wenn Recruiting-Kontext klar, sonst off_scope.
- Passage beschreibt Bias-Risiken aus Datensätzen → K6, auch wenn Art. 10 AI Act erwähnt wird. K1 nur bei direkten Compliance-Pflichten.

**Bedient Thesen:** T1 (Regulatorik als strukturelles Problem), T4 (Explainable AI als Differenzierung).

---

## K2: KI-Technologien im Recruiting

**Definition**
K2 umfasst alle Textstellen, die die technischen Grundlagen, Funktionsweisen und Anwendungsvarianten der in Recruiting-Kontexten eingesetzten KI-Verfahren beschreiben. Im Fokus stehen die vier fokussierten Methoden: Large Language Models für Textverarbeitung, embedding-basiertes semantisches Matching, transformer-basierte Sortier- und Scoring-Modelle sowie Retrieval-Augmented Generation (RAG). Ebenfalls zu K2 gehören Explainable-AI-Ansätze (SHAP, LIME, Attention-Visualisierung) als technische Erklärbarkeits-Mechanismen sowie die Black-Box-Problematik intransparenter Modelle.

**Thematische Abgrenzung (gehört nach K2)**
- Technische Beschreibung der genannten KI-Verfahren
- Anwendungsfälle und typische Einsatzszenarien im Recruiting
- Technische Vor- und Nachteile einzelner Architekturen
- Transparenz-Technologien als technische Mechanismen (SHAP, LIME, Counterfactuals)
- Black-Box-Problematik, algorithmische Nachvollziehbarkeit auf Modell-Ebene

**Thematische Abgrenzung (gehört NICHT nach K2)**
- Regulatorische Anforderungen an Transparenz (das ist K1)
- Unternehmens-Governance zur Entscheidung für oder gegen bestimmte Technologien (das ist K4)
- Akzeptanz-Probleme bei Recruitern gegenüber der Technologie (das ist K5)
- Datenqualitäts-Fragen auf Trainings-Datensatz-Ebene (das ist K6)

**Ankerbeispiele**

1. "Embedding-basiertes Matching nutzt vortrainierte Sprachmodelle, um Kandidaten-Profile und Stellenanforderungen in einen gemeinsamen Vektorraum zu überführen. Die Ähnlichkeit wird über Kosinus-Distanz bestimmt, wodurch auch semantisch verwandte Kompetenzen erkannt werden, die bei reinem Keyword-Matching verloren gingen."
2. "SHAP-Werte liefern eine lokale Erklärung für einzelne Modellvorhersagen, indem sie den Beitrag jedes Eingabemerkmals zum Endergebnis quantifizieren. Im Recruiting-Kontext erlauben sie Einblick, welche CV-Merkmale das Ranking eines Kandidaten maßgeblich beeinflusst haben."
3. "Transformer-basierte Scoring-Modelle fallen aufgrund ihrer Komplexität unter die Kategorie opaquer Verfahren. Ihre Entscheidungsfindung ist auch für die entwickelnden Data Scientists nur näherungsweise nachvollziehbar, was zentrale Transparenzanforderungen regulatorischer Natur in der Praxis erschwert."

**Kodierregeln für Zweifelsfälle**
- Passage beschreibt eine Technologie und deren regulatorische Behandlung → K2 wenn Technologie-Fokus, K1 wenn Compliance-Fokus.
- Passage zur Explainable AI → K2 wenn Mechanismus beschrieben wird, K1 wenn regulatorische Pflicht im Vordergrund, K4 wenn Governance-Entscheidung für XAI-Einsatz.
- Passage zu Bias in Modellen → K2 wenn Modell-Architektur-Ursache (z.B. Transformer-Bias), K6 wenn Daten-Ursache.

**Bedient Thesen:** T2 (Technologische Differenzierung der Compliance-Last), T4 (Explainable AI als Differenzierung).

---

## K3: Betriebliche Effizienz und Prozessauswirkungen

**Definition**
K3 umfasst alle Textstellen, die sich mit den betriebswirtschaftlichen und prozessualen Auswirkungen des KI-Einsatzes im Recruiting auseinandersetzen. Im Fokus stehen messbare Effekte wie Time-to-Hire, Cost-per-Hire, Qualität der Kandidatenauswahl (Match-Genauigkeit, Retention), Prozessgeschwindigkeit, Durchsatz und Skalierbarkeit. Ebenfalls hierher gehören Grenzen des KI-Einsatzes in operationeller Hinsicht (wo KI keinen messbaren Mehrwert liefert oder sogar negative Effekte hat).

**Thematische Abgrenzung (gehört nach K3)**
- Quantitative oder qualitative Wirkungsanalysen des KI-Einsatzes
- Vorher-Nachher-Vergleiche bei Prozess-Kennzahlen
- ROI-Betrachtungen und Cost-Benefit-Analysen
- Skalierbarkeit von KI-gestützten Recruiting-Prozessen
- Auswirkungen auf Bewerberfreude oder Candidate Experience aus Prozess-Perspektive

**Thematische Abgrenzung (gehört NICHT nach K3)**
- Strategische Governance-Entscheidungen über den KI-Einsatz (das ist K4)
- Implementierungshürden bei der Einführung (das ist K5)
- Qualitäts-Probleme durch schlechte Datengrundlage (das ist K6)
- Akzeptanz-Fragen auf Recruiter-Ebene (das ist K5)

**Ankerbeispiele**

1. "Eine Analyse der Recruiting-Prozesse bei einem großen deutschen Personaldienstleister zeigt eine Reduktion der durchschnittlichen Time-to-Fill um 34 Prozent nach Einführung eines embedding-basierten Matching-Systems. Der Effekt war besonders ausgeprägt bei hochspezialisierten technischen Positionen."
2. "Kostensparende Effekte algorithmischer Vor-Sortierung werden in der Literatur häufig überzeichnet. Bei kleinen bis mittleren Personaldienstleistern überwiegen oft die Integrations- und Wartungskosten den operativen Nutzen, sofern kein ausreichendes Bewerbervolumen die Fixkosten amortisiert."
3. "Die Qualität der Kandidatenauswahl im Sinne der 90-Tage-Retention zeigt in mehreren Studien keinen signifikanten Unterschied zwischen rein menschlichen und KI-unterstützten Prozessen. Der Mehrwert algorithmischer Systeme liegt primär in Geschwindigkeit und Durchsatz, nicht in der Passgenauigkeit."

**Kodierregeln für Zweifelsfälle**
- Passage beschreibt Effizienz-Gewinne UND Compliance-Aufwand → K3 wenn Messbarkeit der Gewinne im Fokus, K1 oder K4 wenn Compliance-Fokus.
- Passage mit Ausblick auf Bias-Auswirkungen auf Effizienz → K3 wenn Prozess-Perspektive, K6 wenn Fairness-Perspektive.

**Bedient Thesen:** T2 (Technologische Differenzierung), T5 (Adoptionsfrage auf operativer Ebene).

---

## K4: AI Governance und strategische Steuerung

**Definition**
K4 umfasst alle Textstellen, die sich mit der organisatorischen und strategischen Steuerung des KI-Einsatzes in Unternehmen befassen. Im Fokus stehen Governance-Modelle (zentrale vs. dezentrale Steuerung), Rollen und Verantwortlichkeiten (AI-Officer, Chief Data Officer, Compliance-Funktion), interne Policies und Richtlinien, Review- und Freigabeprozesse für KI-Systeme sowie Risk-Management-Frameworks. Ebenfalls hierher gehören die strukturellen Unterschiede zwischen Konzernen und kleineren Personaldienstleistern in der Governance-Fähigkeit.

**Thematische Abgrenzung (gehört nach K4)**
- Unternehmens-interne Governance-Strukturen zur KI-Steuerung
- Rollen, Verantwortlichkeiten und Entscheidungs-Prozesse
- Interne Richtlinien, Code of Conduct, AI Ethics Frameworks
- Governance-Reifegrad-Modelle und Benchmarks
- Organisatorische Unterschiede zwischen Unternehmensgrößen
- Strategische Entscheidungen über Tool-Auswahl oder Build-vs-Buy

**Thematische Abgrenzung (gehört NICHT nach K4)**
- Regulatorische Anforderungen, die Governance vorschreiben (das ist K1)
- Akzeptanz auf Mitarbeiter-Ebene (das ist K5)
- Technische Implementierung von XAI als Governance-Instrument (das ist K2, XAI als Technologie)
- Quantitative Effizienz-Effekte der Governance (das ist K3)

**Ankerbeispiele**

1. "Ein zentrales AI Governance Board, bestehend aus Data Science, Legal, HR und Ethik-Vertretern, wurde bei mehreren deutschen Großunternehmen als strukturelle Antwort auf die Anforderungen des EU AI Act etabliert. Das Board verantwortet Go-Live-Entscheidungen für neue KI-Systeme und quartalsweise Audits bestehender Anwendungen."
2. "Kleinere Personaldienstleister mit bis zu 500 Mitarbeitern verfügen in der Regel nicht über dedizierte Governance-Strukturen für KI-Einsatz. Die Verantwortung wird typischerweise beim CDO oder in der Geschäftsführung gebündelt, was die Geschwindigkeit der Entscheidungsfindung erhöht, aber die Tiefe der Risikobewertung einschränkt."
3. "Die strategische Steuerung des KI-Einsatzes im Recruiting umfasst nicht nur die technische Auswahl, sondern die kontinuierliche Überwachung der Modell-Performance auf Fairness, Drift und regulatorische Konformität. Diese Steuerungsleistung ist eine organisatorische Daueraufgabe, kein einmaliger Implementierungsakt."

**Kodierregeln für Zweifelsfälle**
- Passage beschreibt einen Review-Prozess → K4 wenn Prozess-Struktur im Fokus, K1 wenn regulatorische Pflicht zum Review im Fokus.
- Passage zu Unternehmensgrößen-Unterschieden → K4 wenn Governance-Unterschiede, K5 wenn Implementierungs-Geschwindigkeit.
- Passage zu Transparenz-Policies → K4 wenn unternehmenseigene Richtlinie, K1 wenn regulatorisch vorgeschrieben.

**Bedient Thesen:** T1 (Regulatorik als strukturelles Problem), T3 (Governance als Transformations-Hebel).

---

## K5: Implementierungshürden und operative Adoption

**Definition**
K5 umfasst alle Textstellen, die die praktischen Hürden der Einführung und operativen Adoption von KI-Systemen im Recruiting beschreiben. Im Fokus stehen organisatorische Widerstände, Wettbewerbsdynamiken zwischen großen und kleinen Personaldienstleistern, Akzeptanz auf Recruiter-Ebene, Schulungs- und Change-Management-Anforderungen sowie Fragen der Mensch-KI-Zusammenarbeit im Arbeitsalltag. K5 ist die Perspektive auf das Ankommen der Technologie bei den Menschen, die sie einsetzen sollen.

**Thematische Abgrenzung (gehört nach K5)**
- Organisatorische Widerstände gegen KI-Einführung
- Wettbewerb um Early-Adopter-Vorteile zwischen PDLs
- Recruiter-Akzeptanz, Vertrauen und Vorbehalte
- Schulung, Weiterbildung, Kompetenzaufbau
- Mensch-KI-Zusammenarbeit in konkreten Arbeitsabläufen
- Rollenveränderungen im Recruiting-Beruf

**Thematische Abgrenzung (gehört NICHT nach K5)**
- Strategische Governance-Entscheidungen (das ist K4)
- Technische Implementierungsdetails von Systemen (das ist K2)
- Messbare Effizienz-Effekte nach Adoption (das ist K3)
- Regulatorische Anforderungen an Schulung (das ist K1)

**Ankerbeispiele**

1. "Recruiter mit langjähriger Erfahrung zeigen in Fallstudien besonders ausgeprägte Vorbehalte gegenüber algorithmischen Vorsortierungen. Die Wahrnehmung eines Autonomieverlusts und die Befürchtung, durch die KI perspektivisch ersetzt zu werden, wirken als zentrale Barrieren für die operative Adoption, unabhängig von der technischen Qualität des Systems."
2. "Kleinere Personaldienstleister mit agiler Entscheidungsstruktur implementieren KI-Systeme oft schneller als etablierte Konzerne. Dieser First-Mover-Vorteil kompensiert partiell den Ressourcen-Nachteil bei der Governance-Ausstattung und kann zu einer temporären Wettbewerbsposition führen."
3. "Die Einführung eines KI-gestützten Matching-Systems ohne begleitendes Change-Management führt in mehreren dokumentierten Fällen zu einer de-facto-Nichtnutzung. Recruiter umgehen das System durch parallele manuelle Suchen, womit die erhofften Effizienz-Gewinne ausbleiben."

**Kodierregeln für Zweifelsfälle**
- Passage zu Widerständen auf Mitarbeiter-Ebene → K5, auch wenn Governance-Versagen genannt wird.
- Passage zum Wettbewerb zwischen Unternehmensgrößen → K5 wenn Einführungsgeschwindigkeit, K4 wenn Governance-Kapazität.
- Passage zu Schulungsaufwand → K5 wenn Akzeptanz-Bezug, K4 wenn Policy-Kontext.

**Bedient Thesen:** T1 (Regulatorik als strukturelles Problem), T3 (Governance als Transformations-Hebel), T5 (Adoptionsfrage auf operativer Ebene).

---

## K6: Daten und algorithmische Fairness

**Definition**
K6 umfasst alle Textstellen, die sich mit Fragen der Datengrundlage, Datenqualität und algorithmischen Fairness von KI-Systemen im Recruiting-Kontext befassen. Im Fokus stehen die Qualität und Repräsentativität von Trainingsdaten, Bias-Risiken in historischen Recruiting-Daten (Gender-Bias, Herkunfts-Bias, Ageism), die Anforderungen aus Art. 10 EU AI Act (Data Governance für Hochrisiko-Systeme), Methoden zur Entwicklung diskriminierungsfreier Modelle sowie das kontinuierliche Monitoring von Entscheidungsverläufen auf Fairness-Metriken.

**Thematische Abgrenzung (gehört nach K6)**
- Datenqualitäts-Fragen (Vollständigkeit, Aktualität, Repräsentativität)
- Bias-Ursachen in Trainingsdaten
- Diskriminierungsrisiken durch KI-Recruiting
- Fairness-Metriken (Demographic Parity, Equalized Odds, Disparate Impact)
- Art. 10 EU AI Act Data Governance Anforderungen
- Monitoring- und Auditing-Praktiken für Fairness

**Thematische Abgrenzung (gehört NICHT nach K6)**
- Regulatorische Anforderungen OHNE spezifischen Daten- oder Fairness-Bezug (das ist K1)
- Modell-Architektur-bedingte Bias-Effekte (das ist K2)
- Governance-Strukturen zur Überwachung von Fairness (das ist K4)
- Akzeptanzfragen gegenüber Fairness-Messungen (das ist K5)

**Ankerbeispiele**

1. "Historische Recruiting-Daten spiegeln strukturelle Diskriminierung in der Vergangenheit wider. Ein auf diesen Daten trainiertes Matching-Modell lernt implizit, Bewerber mit Merkmalen unterrepräsentierter Gruppen niedriger zu ranken. Ohne gezielte Rebalancing-Maßnahmen reproduziert das System die historische Ungleichheit in algorithmischer Form."
2. "Art. 10 des EU AI Act verpflichtet Anbieter von Hochrisiko-Systemen zu einer systematischen Data Governance. Trainings-, Validierungs- und Testdatensätze müssen hinreichend relevant, repräsentativ und im Hinblick auf die beabsichtigte Zweckbestimmung frei von Fehlern sein."
3. "Fairness-Metriken wie Demographic Parity und Equalized Odds stehen häufig in Spannung zueinander. Die Optimierung auf eine Metrik kann die Performance auf einer anderen Metrik verschlechtern. Die Wahl der primären Fairness-Definition ist daher eine normative Entscheidung mit direkten Konsequenzen für die Modell-Performance."

**Kodierregeln für Zweifelsfälle**
- Passage zu Bias in Modellen → K6 wenn Daten-Ursache, K2 wenn Modell-Architektur-Ursache.
- Passage zu Art. 10 AI Act → K6 wenn Daten-Anforderungen im Fokus, K1 wenn Compliance-Pflicht allgemein.
- Passage zu Monitoring → K6 wenn Fairness-Monitoring, K4 wenn Governance-Monitoring generell.
- Passage zu Diskriminierungs-Folgen → K6 wenn algorithmische Diskriminierung, K5 wenn organisatorische Diskriminierung.

**Bedient Thesen:** T1 (Regulatorik als strukturelles Problem), T4 (Explainable AI als Differenzierung).

---

## Querschnitts-Kodierregeln

**Prinzip der sparsamsten Zuordnung:**
Jede Passage bekommt genau eine Primärkategorie. Wenn mehrere Kategorien zutreffen könnten, gewinnt die thematisch dichteste. Im Zweifel hilft die Frage: Wozu wird die Passage in der späteren Arbeit zitiert werden? Eine Passage, die einen technischen SHAP-Mechanismus beschreibt, wird in Kapitel 2.3 zitiert (XAI) und gehört damit zu K2, auch wenn sie peripher auf regulatorische Pflichten verweist.

**Unklassifiziert vs. Off-Scope:**
- `kategorie_tag: unklassifiziert` bei Passagen, die inhaltlich zu einer der sechs Kategorien gehören könnten, aber die genaue Zuordnung nicht eindeutig ist. Diese Passagen werden im `source-review`-Flow manuell zugeordnet.
- `kategorie_tag: off_scope` bei Passagen, die außerhalb aller sechs Kategorien liegen (z.B. allgemeine Arbeitsmarkt-Literatur ohne KI-Bezug, HR-Trend-Berichte ohne regulatorische oder Recruiting-KI-Substanz).

**Signalwörter für schnelle Orientierung:**

| Kategorie | Typische Signalwörter |
|---|---|
| K1 | AI Act, DSGVO, Art. 22, Annex III, Hochrisiko, Compliance-Pflicht, Aufsichtsbehörde, Enforcement |
| K2 | LLM, Embedding, Transformer, RAG, SHAP, LIME, Attention, Vektor, neuronales Netz |
| K3 | Time-to-Hire, Cost-per-Hire, Durchsatz, ROI, Skalierbarkeit, Prozess-Kennzahl |
| K4 | Governance, Policy, AI-Officer, Review-Board, Risk-Framework, Steuerung, Richtlinie |
| K5 | Akzeptanz, Widerstand, Change-Management, Schulung, Adoption, Rollenbild, Mensch-KI |
| K6 | Bias, Fairness, Diskriminierung, Repräsentativität, Demographic Parity, Art. 10, Trainingsdaten |

**Induktive Unterkategorien:**
Werden bei Bedarf während der Materialauswertung gebildet, nicht vorab festgelegt. Dokumentation erfolgt im separaten Mayring-Vault (für Interview-Material) beziehungsweise als Ergänzung dieses Codebooks (für Literatur-Material, falls sich ein Muster häuft).

---

## Pipeline-YAML für `codebook.md`

Dieser Block ist 1:1 in `bachelor-thesis-vault/00_meta/codebook.md` übertragbar. Das Codebook ist primär Freitext, das Frontmatter bleibt minimal.

```yaml
---
typ: codebook
status: active
erstellt: "2026-04-23"
version: "v1.0"
basiert_auf_scope_version: "v1.0"
kategorien_abgedeckt: [K1, K2, K3, K4, K5, K6]
induktive_unterkategorien: []
ankerbeispiele_quelle: "konstruiert"
aktualisierungs_trigger: "nach 5-10 realen Quellen Ankerbeispiele durch belegte Formulierungen ersetzen"
---

# Codebook

Kategorien-Handbuch für die deduktive Klassifikation von Literatur-Passagen. Pro K1 bis K6: Definition, thematische Abgrenzung, zwei bis drei Ankerbeispiele, Kodierregeln für Zweifelsfälle.

Methodische Grundlage: Qualitative Inhaltsanalyse nach Mayring, deduktiv-induktiver Ansatz. Die sechs Hauptkategorien sind aus Forschungsfrage, Unterthesen T1 bis T5 und fokussierten KI-Methoden abgeleitet. Induktive Unterkategorien werden bei Bedarf am Material gebildet und hier ergänzt.

Ankerbeispiele sind konstruiert und dienen der LLM-Orientierung. Sie werden nach den ersten 5 bis 10 realen Quellen durch belegte Formulierungen ersetzt.

## K1: EU AI Act und regulatorisches Umfeld

Definition: Textstellen zum EU AI Act (Verordnung 2024/1689) und flankierenden regulatorischen Rahmenwerken im Recruiting-Kontext. Hochrisiko-Einstufung (Art. 6 + Annex III Nr. 4), Compliance-Pflichten (Dokumentation, Transparenz, menschliche Aufsicht), DSGVO-Schnittstellen (Art. 22), Enforcement-Zeitplan, nationale Umsetzung.

Gehört hin: Rechtliche Anforderungen, Hochrisiko-Klassifikation, DSGVO-Schnittstellen mit AI-Act-Bezug, nationale Umsetzungsgesetze, regulatorische Debatten.

Gehört nicht hin: Unternehmens-Governance (K4), Implementierungshürden (K5), Datenschutz ohne AI-Act-Bezug (off_scope), technische XAI-Beschreibungen (K2).

Ankerbeispiele (konstruiert):
1. "Rekrutierungs- und Personalauswahlsysteme, die auf künstlicher Intelligenz basieren, werden in Annex III Nr. 4 des EU AI Act als Hochrisiko-Anwendung eingestuft."
2. "Art. 22 DSGVO verbietet Entscheidungen, die ausschließlich auf automatisierter Verarbeitung beruhen, sofern keine Ausnahme nach Abs. 2 greift."
3. "Der stufenweise Enforcement-Zeitplan des AI Acts sieht die volle Anwendung der Hochrisiko-Bestimmungen ab August 2026 vor."

Zweifelsfall-Regeln:
- AI Act + Governance-Umsetzung: K1 bei regulatorischem Fokus, K4 bei Unternehmens-interner Umsetzung.
- DSGVO ohne AI-Act: K1 nur bei Recruiting-Kontext, sonst off_scope.
- Bias aus Daten: K6, auch bei Art. 10 AI Act Erwähnung. K1 nur bei direkten Compliance-Pflichten.

Bedient: T1, T4. Triangulation erforderlich.

## K2: KI-Technologien im Recruiting

Definition: Technische Grundlagen, Funktionsweisen und Anwendungsvarianten der im Recruiting eingesetzten KI-Verfahren. Fokus: LLM-Textverarbeitung, Embedding-Matching, Transformer-Scoring, RAG, Explainable AI, Black-Box-Problematik.

Gehört hin: Technische Verfahrens-Beschreibungen, Anwendungsfälle, technische Vor-Nachteile, XAI-Mechanismen (SHAP, LIME, Counterfactuals), Black-Box-Problematik auf Modell-Ebene.

Gehört nicht hin: Regulatorische Transparenz-Anforderungen (K1), Governance-Entscheidungen zu Technologien (K4), Akzeptanz-Probleme (K5), Datenqualität (K6).

Ankerbeispiele (konstruiert):
1. "Embedding-basiertes Matching nutzt vortrainierte Sprachmodelle, um Kandidaten-Profile und Stellenanforderungen in einen gemeinsamen Vektorraum zu überführen."
2. "SHAP-Werte liefern eine lokale Erklärung für einzelne Modellvorhersagen, indem sie den Beitrag jedes Eingabemerkmals quantifizieren."
3. "Transformer-basierte Scoring-Modelle fallen aufgrund ihrer Komplexität unter die Kategorie opaquer Verfahren."

Zweifelsfall-Regeln:
- Technologie + regulatorische Behandlung: K2 bei Technologie-Fokus, K1 bei Compliance-Fokus.
- Explainable AI: K2 bei Mechanismus, K1 bei Pflicht, K4 bei Governance-Entscheidung.
- Bias: K2 bei Modell-Architektur-Ursache, K6 bei Daten-Ursache.

Bedient: T2, T4. Triangulation nicht zwingend.

## K3: Betriebliche Effizienz und Prozessauswirkungen

Definition: Betriebswirtschaftliche und prozessuale Auswirkungen des KI-Einsatzes im Recruiting. Fokus: Time-to-Hire, Cost-per-Hire, Qualität der Kandidatenauswahl, Prozessgeschwindigkeit, Durchsatz, Skalierbarkeit. Auch Grenzen des KI-Einsatzes.

Gehört hin: Wirkungsanalysen, Vorher-Nachher-Vergleiche, ROI, Skalierbarkeit, Candidate Experience aus Prozess-Perspektive.

Gehört nicht hin: Governance-Entscheidungen (K4), Implementierungshürden (K5), Datenqualität (K6), Akzeptanz (K5).

Ankerbeispiele (konstruiert):
1. "Eine Analyse der Recruiting-Prozesse bei einem großen deutschen Personaldienstleister zeigt eine Reduktion der durchschnittlichen Time-to-Fill um 34 Prozent nach Einführung eines embedding-basierten Matching-Systems."
2. "Kostensparende Effekte algorithmischer Vor-Sortierung werden in der Literatur häufig überzeichnet. Bei kleinen bis mittleren Personaldienstleistern überwiegen oft die Integrations- und Wartungskosten den operativen Nutzen."
3. "Die Qualität der Kandidatenauswahl im Sinne der 90-Tage-Retention zeigt in mehreren Studien keinen signifikanten Unterschied zwischen rein menschlichen und KI-unterstützten Prozessen."

Zweifelsfall-Regeln:
- Effizienz + Compliance: K3 bei Messbarkeit, K1/K4 bei Compliance-Fokus.
- Bias-Auswirkungen auf Effizienz: K3 bei Prozess-Perspektive, K6 bei Fairness-Perspektive.

Bedient: T2, T5. Triangulation nicht zwingend.

## K4: AI Governance und strategische Steuerung

Definition: Organisatorische und strategische Steuerung des KI-Einsatzes in Unternehmen. Fokus: Governance-Modelle, Rollen und Verantwortlichkeiten, interne Policies, Review-Prozesse, Risk-Management-Frameworks. Unterschiede zwischen Konzernen und kleineren PDLs.

Gehört hin: Governance-Strukturen, Rollen und Prozesse, interne Richtlinien, Reifegrad-Modelle, organisatorische Unterschiede nach Unternehmensgröße, strategische Tool-Auswahl.

Gehört nicht hin: Regulatorische Vorschriften zu Governance (K1), Akzeptanz auf Mitarbeiter-Ebene (K5), XAI als Technologie (K2), Effizienz-Effekte (K3).

Ankerbeispiele (konstruiert):
1. "Ein zentrales AI Governance Board, bestehend aus Data Science, Legal, HR und Ethik-Vertretern, wurde bei mehreren deutschen Großunternehmen als strukturelle Antwort auf die Anforderungen des EU AI Act etabliert."
2. "Kleinere Personaldienstleister mit bis zu 500 Mitarbeitern verfügen in der Regel nicht über dedizierte Governance-Strukturen für KI-Einsatz."
3. "Die strategische Steuerung des KI-Einsatzes im Recruiting umfasst nicht nur die technische Auswahl, sondern die kontinuierliche Überwachung der Modell-Performance auf Fairness, Drift und regulatorische Konformität."

Zweifelsfall-Regeln:
- Review-Prozess: K4 bei Prozess-Struktur, K1 bei regulatorischer Pflicht.
- Unternehmensgrößen-Unterschiede: K4 bei Governance, K5 bei Implementierungs-Geschwindigkeit.
- Transparenz-Policies: K4 bei unternehmenseigener Richtlinie, K1 bei regulatorischer Vorschrift.

Bedient: T1, T3. Triangulation erforderlich.

## K5: Implementierungshürden und operative Adoption

Definition: Praktische Hürden der Einführung und operativen Adoption von KI-Systemen im Recruiting. Fokus: organisatorische Widerstände, Wettbewerbsdynamiken, Recruiter-Akzeptanz, Schulung, Change-Management, Mensch-KI-Zusammenarbeit.

Gehört hin: Widerstände, Wettbewerb um Early-Adopter-Vorteile, Akzeptanz und Vertrauen, Schulung, Rollenveränderungen im Recruiting-Beruf.

Gehört nicht hin: Governance (K4), technische Details (K2), Effizienz-Effekte (K3), regulatorische Schulungspflichten (K1).

Ankerbeispiele (konstruiert):
1. "Recruiter mit langjähriger Erfahrung zeigen in Fallstudien besonders ausgeprägte Vorbehalte gegenüber algorithmischen Vorsortierungen."
2. "Kleinere Personaldienstleister mit agiler Entscheidungsstruktur implementieren KI-Systeme oft schneller als etablierte Konzerne."
3. "Die Einführung eines KI-gestützten Matching-Systems ohne begleitendes Change-Management führt in mehreren dokumentierten Fällen zu einer de-facto-Nichtnutzung."

Zweifelsfall-Regeln:
- Widerstände: K5 auch bei Governance-Versagen.
- Wettbewerb Unternehmensgrößen: K5 bei Einführungsgeschwindigkeit, K4 bei Governance-Kapazität.
- Schulungsaufwand: K5 bei Akzeptanz-Bezug, K4 bei Policy-Kontext.

Bedient: T1, T3, T5. Triangulation erforderlich.

## K6: Daten und algorithmische Fairness

Definition: Datengrundlage, Datenqualität und algorithmische Fairness von KI-Systemen im Recruiting. Fokus: Qualität und Repräsentativität von Trainingsdaten, Bias-Risiken in historischen Recruiting-Daten, Art. 10 EU AI Act (Data Governance), diskriminierungsfreie Modellentwicklung, Monitoring auf Fairness-Metriken.

Gehört hin: Datenqualitäts-Fragen, Bias-Ursachen in Daten, Diskriminierungsrisiken, Fairness-Metriken (Demographic Parity, Equalized Odds), Art. 10 AI Act, Monitoring- und Auditing-Praktiken.

Gehört nicht hin: Regulatorische Vorschriften ohne Daten-Bezug (K1), Modell-Architektur-Bias (K2), Governance-Strukturen für Fairness-Monitoring (K4), Akzeptanz-Fragen (K5).

Ankerbeispiele (konstruiert):
1. "Historische Recruiting-Daten spiegeln strukturelle Diskriminierung in der Vergangenheit wider. Ein auf diesen Daten trainiertes Matching-Modell lernt implizit, Bewerber mit Merkmalen unterrepräsentierter Gruppen niedriger zu ranken."
2. "Art. 10 des EU AI Act verpflichtet Anbieter von Hochrisiko-Systemen zu einer systematischen Data Governance. Trainings-, Validierungs- und Testdatensätze müssen hinreichend relevant, repräsentativ und im Hinblick auf die beabsichtigte Zweckbestimmung frei von Fehlern sein."
3. "Fairness-Metriken wie Demographic Parity und Equalized Odds stehen häufig in Spannung zueinander. Die Wahl der primären Fairness-Definition ist daher eine normative Entscheidung mit direkten Konsequenzen für die Modell-Performance."

Zweifelsfall-Regeln:
- Bias: K6 bei Daten-Ursache, K2 bei Modell-Architektur-Ursache.
- Art. 10 AI Act: K6 bei Daten-Anforderungen, K1 bei Compliance-Pflicht allgemein.
- Monitoring: K6 bei Fairness-Monitoring, K4 bei Governance-Monitoring.
- Diskriminierungs-Folgen: K6 bei algorithmischer Diskriminierung, K5 bei organisatorischer.

Bedient: T1, T4. Triangulation erforderlich.

## Querschnitts-Kodierregeln

**Prinzip der sparsamsten Zuordnung:** Jede Passage bekommt genau eine Primärkategorie. Bei Mehrfach-Treffern gewinnt die thematisch dichteste.

**Unklassifiziert vs. Off-Scope:**
- `kategorie_tag: unklassifiziert`: Gehört potentiell zu einer der sechs Kategorien, genaue Zuordnung unklar. Manuelle Zuordnung im source-review.
- `kategorie_tag: off_scope`: Außerhalb aller sechs Kategorien.

**Signalwörter für schnelle Orientierung:**
- K1: AI Act, DSGVO, Art. 22, Annex III, Hochrisiko, Compliance-Pflicht, Aufsichtsbehörde, Enforcement
- K2: LLM, Embedding, Transformer, RAG, SHAP, LIME, Attention, neuronales Netz
- K3: Time-to-Hire, Cost-per-Hire, Durchsatz, ROI, Skalierbarkeit, Prozess-Kennzahl
- K4: Governance, Policy, AI-Officer, Review-Board, Risk-Framework, Steuerung, Richtlinie
- K5: Akzeptanz, Widerstand, Change-Management, Schulung, Adoption, Rollenbild, Mensch-KI
- K6: Bias, Fairness, Diskriminierung, Repräsentativität, Demographic Parity, Art. 10, Trainingsdaten

**Induktive Unterkategorien:** Bei Bedarf während der Materialauswertung gebildet. Dokumentation im separaten Mayring-Vault (Interview-Material) oder als Ergänzung dieses Codebooks (Literatur-Material).
```
