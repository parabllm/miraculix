---
typ: framework-spec
name: Bachelorarbeit Research Vault
projekt: bachelor-thesis
quelle: Konsolidierung aus Phase 1-3 Research mit Perplexity und Gemini (2026-04-20), Voice-Dumps Deniz, Anforderungen zu Zitat-Integritaet und Harvard-Zitierstil
vertrauen: bestätigt
erstellt: 2026-04-20
status: ready-for-claude-code-deployment
version: 1.0
---

# Bachelorarbeit Research Vault: Framework-Spezifikation

Dieses Dokument ist die vollständige Bauanleitung für den Research-Vault. Claude Code bekommt diese Datei, liest sie komplett, und baut auf Basis dieser Spec den gesamten Vault auf. Nichts was hier steht ist Prosa, alles ist Bauanweisung.

## Teil A: Projekt-Kontext

### A.1 Was gebaut wird

Ein lokaler, Git-versionierter Obsidian-Vault mit Claude-Code-Integration als Research-Arbeitsumgebung für die Bachelorarbeit zu EU AI Act und Recruiting in deutschen Personaldienstleistern. Abgabe 15.06.2026 an der HdWM Mannheim.

### A.2 Warum das System existiert

Zitat- und Quellen-Integritaet ist die oberste Prioritaet. Am Ende des Research-Prozesses muss stehen:
1. Eine saubere Zotero-Library ohne halluzinierte Quellen
2. Pro Quelle eine Markdown-File mit verifizierten Zitaten und exakten Seitenangaben
3. Ein abfragbarer Pool an Passagen kategorisiert nach Thema und Verwendungsart
4. Vollstaendige Nachvollziehbarkeit: jede Aussage verlinkt zurück zur verifizierten Quelle

### A.3 Kern-Anforderungen (absteigend priorisiert)

**A.3.1 Zitat-Integritaet**
Keine Halluzinationen von Autoren, Jahren, Titeln, Seitenzahlen oder Zitaten. Vier Garantien:
- Metadaten werden gegen mindestens eine externe API (Crossref, OpenAlex, DNB, Google Books) verifiziert bevor eine Quelle in den Pool wandert
- Jedes direkte Zitat durchlaeuft Fuzzy-Match-Validation gegen den Original-Text (Threshold 85%)
- Seitenzahlen werden aus Layout-Ankern (page_start, page_end Marker im Chunk) gelesen, nicht geraten
- Zitierstil (Elsevier Harvard with titles) wird durchgaengig von Zotero bis zur finalen PDF erzwungen

**A.3.2 Heterogene Quellen-Ingestion**
PDFs mit Textebene, Scan-PDFs, Foto-Ordner pro Buch (Handy-Fotos aus Bibliothek plus Cover plus Impressum), Screenshots, Web-Artikel, EPUB, DOCX, Google-Books-Snippets. Pro Quellen-Typ der passende Ingestion-Skill automatisch gewaehlt.

**A.3.3 Claude Code als Backbone**
Lokal laufend, Dateisystem-Zugriff, orchestriert externe APIs ueber Skills und Python-Skripte. Umgeht Kontext-Limits der Web-UI.

**A.3.4 Scope-Gesteuertheit**
Alle Skills lesen `00_meta/scope.md` und richten ihre Klassifikation, Relevanz-Prüfung und Kategorisierung nach dieser Datei aus. Keine hartkodierten Kategorien.

**A.3.5 Zotero als bibliographische Ground Truth**
Zotero 8 mit BetterBibTeX-Plugin. Native Citation Keys. Elsevier Harvard with titles CSL-Style. Vault verlinkt auf Zotero via Citation Key.

**A.3.6 Git-Versionierung**
Gesamter Vault unter Git. Audit-Trail für potenzielle Turnitin-Rueckfragen. Rollback-Faehigkeit bei fehlerhaften KI-Operationen.

### A.4 Architektur-Prinzipien

Diese fuenf Leitplanken gelten im gesamten System:

1. **Explizite Statusfelder statt implizite Annahmen**: Jede Quelle traegt `availability`, `processability`, `review_status`, `metadata_conflict`, `citation_verified`, `completeness_level` im Frontmatter. Nie versteckte Zustaende.

2. **Idempotente Pipeline-Schritte**: Jeder Skill darf mehrfach auf dieselbe Quelle angewendet werden ohne Schaden. Wichtig bei Crashs, Retries und nachtraeglichen Scope-Aenderungen.

3. **Human-in-the-Loop an epistemisch kritischen Stellen**: Metadaten-Konflikte, Passage-Klassifikation, Schema-Migrationen werden dem Nutzer vorgelegt. Nie autonome Entscheidung.

4. **Trennung Rohdaten von Interpretation**: `_raw/` ist Original-Input. `_pending/` ist verarbeitet aber nicht verifiziert. `01_sources/` ist der saubere Pool. `02_drafts/` ist die eigene Prosa des Nutzers. Niemals Ebenen mischen.

5. **Gates vor Commit**: Neue Quellen wandern erst nach bestandenem Quality-Gate in den Pool. Zitate wandern erst nach Fuzzy-Validation in die Master-Passagen-Datenbank. Gates sind im System verankert, nicht Disziplin des Nutzers.

### A.5 Was das System NICHT ist

- Kein Plagiats-Tool (das macht Turnitin am Ende)
- Kein Auto-Writer (Nutzer schreibt Prosa, System liefert Bausteine)
- Kein allgemeiner Notiz-App-Ersatz (das ist Miraculix)
- Kein Ersatz für kritisches Denken (System strukturiert, Nutzer urteilt)

## Teil B: Tech Stack

### B.1 Core-Komponenten

- **Claude Code** (CLI, aktuelle Version): primaerer Verarbeitungsmotor, lokal auf Windows
- **Obsidian** (Desktop, aktuelle Version): Vault-UI, Markdown-Rendering
- **Obsidian-Plugins (Pflicht)**: Dataview, Templater
- **Obsidian-Plugins (optional, empfohlen)**: PDF++, ZotLit
- **Git** (2.40+) plus **GitHub** oder **GitLab** für Remote-Backup
- **Zotero 8 Desktop** plus **BetterBibTeX-Plugin**
- **Python 3.11+** (für Ingestion- und Verifikations-Skripte)
- **Docker Desktop** (für GROBID-Container)
- **Node.js 20+** (optional, falls bestimmte Tools es brauchen)

### B.2 Externe APIs die angebunden werden

**Content-Verarbeitung (kostenpflichtig)**:
- **Anthropic Claude API**: Text-PDFs, Passage-Extraktion, LLM-Aufgaben in Python-Skripten
- **OpenAI API**: Vision für Buchfotos und Handschrift, Fallback bei komplexen Layouts
- **Mistral OCR API**: Scan-PDFs mit Tabellen, Batch-Processing (nur Fallback)

**Metadaten-Verifikation (kostenlos, keine Keys)**:
- **Crossref REST API**: DOI-Primary, Autor, Titel, Journal
- **OpenAlex API**: erweitert Crossref, Zitationsgraph, Retraction-Info
- **DNB SRU**: Deutsche Nationalbibliothek, deutsche Buecher
- **Semantic Scholar API**: Citation Intent Analyse
- **DataCite API**: Datasets und Forschungsdaten

**Metadaten-Verifikation (kostenlos, Key noetig)**:
- **Google Books API**: ISBN-Lookup, Cover, Klappentext (1000 Calls/Tag gratis)

**Referenz-Parsing (lokal, Docker)**:
- **GROBID**: PDF-Referenzlisten parsen, Layout-Koordinaten

### B.3 Python-Dependencies

In der Datei `requirements.txt` im Vault-Root:

```
# LLM-SDKs
anthropic>=0.40.0
openai>=1.50.0
mistralai>=1.0.0

# PDF und OCR
pypdf>=5.0.0
pdfplumber>=0.11.0
pillow>=10.0.0

# Metadaten-APIs
requests>=2.31.0
habanero>=1.2.6
pyalex>=0.14
crossref-commons>=0.0.7

# Zotero-Integration
pyzotero>=1.5.18

# Fuzzy-Matching (kritisch fuer Validator)
rapidfuzz>=3.9.0

# GROBID-Client
grobid-client-python>=0.0.9

# Utilities
python-dotenv>=1.0.0
pyyaml>=6.0.0
click>=8.1.0
rich>=13.7.0
```

Installation nach Vault-Aufbau: `pip install -r requirements.txt` im Vault-Root.

### B.4 GROBID-Setup

GROBID läuft als lokaler Docker-Container, spricht per HTTP an.

**Installation**:
```bash
# Docker Desktop muss laufen
docker pull lfoppiano/grobid:0.8.1
docker run -d --name grobid -p 8070:8070 lfoppiano/grobid:0.8.1
```

**Verifikation**:
Browser oeffnen auf `http://localhost:8070` zeigt die GROBID-Weboberflaeche.

**Nutzung in Python-Skripten**:
```python
from grobid_client.grobid_client import GrobidClient
client = GrobidClient(config_path="./config/grobid_config.json")
client.process("processFulltextDocument", "_raw/pdfs/", "_cache/grobid_output/", n=10)
```

**Config-File `config/grobid_config.json`**:
```json
{
  "grobid_server": "http://localhost:8070",
  "batch_size": 1000,
  "sleep_time": 5,
  "timeout": 60,
  "coordinates": ["persName", "figure", "ref", "biblStruct", "formula", "s"]
}
```

**Wichtig**: GROBID-Container muss vor Ingestion-Operationen laufen. Wir bauen einen Check in die Skills ein: wenn GROBID nicht antwortet, Skill bricht sauber ab mit Hinweis "Docker Container starten".

### B.5 API-Keys besorgen: Schritt-für-Schritt

Jeden Key in eine `.env`-Datei im Vault-Root schreiben. Die `.env` ist in `.gitignore` gelistet und wird nie committed.

**B.5.1 Anthropic API Key**
1. Gehe auf https://console.anthropic.com
2. Login mit deinem Anthropic-Account (gleicher Account wie Claude Pro)
3. Navigiere zu "API Keys" im linken Menue
4. Klicke "Create Key", Name: "bachelorarbeit-research-vault"
5. Key kopieren (wird nur einmal angezeigt)
6. Budget-Limit setzen: Dashboard -> Plan and Billing -> Set monthly budget, 50 USD zum Start
7. In `.env` einfuegen: `ANTHROPIC_API_KEY=sk-ant-...`

**B.5.2 OpenAI API Key**
1. Gehe auf https://platform.openai.com
2. Account erstellen falls noch nicht vorhanden
3. Navigiere zu "API Keys"
4. "Create new secret key", Name: "bachelorarbeit-vault"
5. Scope: "All"
6. Key kopieren
7. Budget-Limit: Settings -> Billing -> Usage limits, Hard limit 30 USD
8. In `.env`: `OPENAI_API_KEY=sk-...`

**B.5.3 Mistral API Key**
1. Gehe auf https://console.mistral.ai
2. Account erstellen (E-Mail plus Telefonnummer für Verifikation)
3. Navigiere zu "API Keys" oder "Workspace"
4. "Create new key", Name: "bachelorarbeit"
5. Key kopieren
6. In Billing: Kreditkarte hinterlegen, 10 USD Guthaben aufladen (reicht für ca 5000 Seiten OCR)
7. In `.env`: `MISTRAL_API_KEY=...`

**B.5.4 Google Books API Key**
1. Gehe auf https://console.cloud.google.com
2. Google-Account einloggen
3. Neues Projekt erstellen: "bachelorarbeit-research"
4. Im Seitenmenue: APIs und Dienste -> Bibliothek
5. Suche "Books API", aktivieren
6. APIs und Dienste -> Anmeldedaten
7. "Anmeldedaten erstellen" -> "API-Schluessel"
8. Schluessel kopieren
9. Optional: Beschraenkung auf Books API einrichten damit der Key nichts anderes kann
10. In `.env`: `GOOGLE_BOOKS_API_KEY=...`

**B.5.5 Zotero API Key und User ID**
1. Gehe auf https://www.zotero.org und logge ein (oder erstelle Account)
2. Settings -> Security: notiere deine "User ID" (eine Zahl, zum Beispiel 12345678)
3. Settings -> Feeds/API: "Create new private key"
4. Name: "bachelorarbeit-vault-sync"
5. Permissions: "Allow library access" und "Allow write access" aktivieren
6. Default Group: optional
7. Key kopieren
8. In `.env`: 
   - `ZOTERO_USER_ID=12345678`
   - `ZOTERO_API_KEY=...`

**B.5.6 Sicherheits-Check**
Nach Erstellen der `.env`-Datei: pruefe dass `.env` in der `.gitignore` steht. Fuehre `git status` aus, die Datei darf NICHT auftauchen. Wenn doch: sofort `git rm --cached .env` und `.gitignore` korrigieren.

### B.6 Zotero-Setup

**B.6.1 Zotero 8 installieren**
Download von https://www.zotero.org/download. Installation, Account einloggen.

**B.6.2 BetterBibTeX installieren**
1. Download die aktuelle Version von https://github.com/retorquere/zotero-better-bibtex/releases (Datei endet auf `.xpi`)
2. In Zotero: Tools -> Add-ons -> Zahnrad -> Install Add-on From File -> die .xpi-Datei waehlen
3. Zotero neu starten

**B.6.3 BetterBibTeX konfigurieren**
Edit -> Settings -> Better BibTeX:
- Citation Keys Tab: Format auf `auth.lower + year + shorttitle(3,3)` setzen. Beispiel: "mueller2023recr"
- Automatic Export: "When item data changes" aktivieren
- Keep keys unique across: "Library" setzen

**B.6.4 Harvard Elsevier CSL installieren**
1. Gehe auf https://www.zotero.org/styles
2. Suche "Elsevier Harvard"
3. Waehle "Elsevier (author-date/Harvard, with titles)"
4. Klick installiert den Stil in Zotero

**B.6.5 Collection für die Thesis anlegen**
In Zotero: Rechtsklick auf "My Library" -> "New Collection" -> Name: "Bachelorarbeit EU AI Act Recruiting"
Notiere den Collection-Namen, kommt in `scope.md` als Pflichtfeld.

**B.6.6 Auto-Export der Bibliography**
BetterBibTeX: rechte Maustaste auf Collection -> Export Collection -> Format: "Better BibLaTeX" -> "Keep updated" aktivieren -> Ziel: `<vault>/00_meta/bibliography.bib`

Jede Aenderung in Zotero triggert nun ein Update der `.bib`-Datei. Pandoc kann diese Datei direkt zum Rendern der Thesis nutzen.

### B.7 Obsidian-Setup

**B.7.1 Obsidian installieren**
Download von https://obsidian.md. Obsidian muss NICHT vorher vorhanden sein, aber das Tool ist vertraut aus Miraculix.

**B.7.2 Den Vault-Ordner oeffnen**
Obsidian -> "Open folder as vault" -> waehle `C:\Users\deniz\Documents\bachelor-thesis-vault\`

**B.7.3 Pflicht-Plugins installieren**
Settings -> Community plugins -> "Browse":
1. **Dataview** (von blacksmithgu): installieren, aktivieren
2. **Templater** (von SilentVoid13): installieren, aktivieren

**B.7.4 Dataview konfigurieren**
Settings -> Dataview:
- Enable JavaScript Queries: ein
- Enable Inline JavaScript Queries: ein
- Refresh Interval: 2500

**B.7.5 Optional: PDF++ Plugin**
Für bessere PDF-Anzeige direkt im Vault:
Community plugins -> "PDF++" (von RyotaUshio) -> installieren

### B.8 Git-Setup

**B.8.1 Git installieren**
Falls nicht vorhanden: https://git-scm.com/download/win

**B.8.2 Im Vault-Ordner initialisieren**
```bash
cd C:\Users\deniz\Documents\bachelor-thesis-vault
git init
git config user.name "Deniz Oezbek"
git config user.email "deine-email@adresse.de"
```

**B.8.3 Remote-Backup (empfohlen)**
Repo auf GitHub oder GitLab anlegen (privat). Vault mit Remote verbinden:
```bash
git remote add origin https://github.com/deindeniz/bachelor-thesis-vault.git
git branch -M main
git push -u origin main
```

## Teil C: Vault-Struktur

Der Vault liegt unter `C:\Users\deniz\Documents\bachelor-thesis-vault\`. Claude Code erstellt die folgende Struktur beim Setup.

### C.1 Vollstaendige Ordnerhierarchie

```
bachelor-thesis-vault/
├── .claude/
│   ├── CLAUDE.md                        # Projekt-Verfassung, siehe Teil J
│   ├── rules/
│   │   ├── source-ingestion.md
│   │   ├── passage-extraction.md
│   │   ├── citation-integrity.md
│   │   └── zotero-sync.md
│   └── skills/
│       ├── ingest-pdf.md
│       ├── ingest-scan-pdf.md
│       ├── ingest-book-folder.md
│       ├── ingest-web.md
│       ├── extract-passages.md
│       ├── verify-metadata.md
│       ├── sync-zotero.md
│       ├── mine-thesis-bibliography.md
│       ├── gap-check.md
│       ├── pool-query.md
│       └── source-review.md
├── .scripts/
│   ├── ingestion/
│   │   ├── run_claude_pdf.py
│   │   ├── run_mistral_ocr.py
│   │   ├── run_openai_vision.py
│   │   ├── run_grobid.py
│   │   └── chunk_pdf_with_anchors.py
│   ├── metadata/
│   │   ├── lookup_crossref.py
│   │   ├── lookup_openalex.py
│   │   ├── lookup_dnb.py
│   │   ├── lookup_googlebooks.py
│   │   └── consensus_validator.py
│   ├── validation/
│   │   └── fuzzy_quote_validator.py
│   └── zotero/
│       └── pyzotero_sync.py
├── config/
│   ├── tools.yaml                       # Tool-Dispatcher: welches Tool fuer welche Aufgabe
│   ├── metadata-apis.yaml               # API-Endpoints, Rate Limits
│   ├── grobid_config.json
│   └── .env.example                     # Template ohne echte Keys, ist committed
├── 00_meta/
│   ├── scope.md                         # DER Bauplan, wird spaeter per Voice-Dump gefuellt
│   ├── codebook.md                      # Kategorien und Tags
│   ├── tag-vocabulary.md                # Controlled Vocabulary
│   ├── ai-usage-card.md                 # KI-Deklaration fuer HdWM, waechst pro Session
│   ├── eigenstaendigkeitserklaerung.md  # Draft fuer Thesis-Anhang
│   ├── mining-log/                      # Eine MD-File pro Recherche-Session
│   ├── decisions.md                     # Architektur-Entscheidungen mit Datum
│   ├── review-dashboard.md              # Dataview-Query auf geflaggte Quellen
│   └── bibliography.bib                 # Auto-Export aus Zotero, ueberschrieben bei Aenderung
├── 01_sources/                          # Der verifizierte Pool
├── _pending/                            # Quarantaene: verarbeitet, nicht verifiziert
├── _raw/                                # Unverarbeitete Inputs
│   ├── pdfs/
│   ├── images/
│   ├── books/                           # Pro Buch ein Unterordner
│   ├── audio/
│   ├── web/
│   └── dumps/
├── _cache/                              # Temporaere Verarbeitungs-Artefakte
│   ├── grobid_output/
│   ├── chunks/                          # Gechunkte PDFs mit Layout-Ankern
│   └── extractions/                     # JSON-Zwischenergebnisse
├── _attachments/                        # Archivierte Original-PDFs
├── 02_drafts/                           # Thesis-Kapitel-Drafts
│   ├── 01-einleitung.md
│   ├── 02-literaturbericht.md
│   ├── 03-methode.md
│   ├── 04-ergebnisse.md
│   └── 05-diskussion.md
├── 03_dashboards/                       # Dataview-Queries
│   ├── pool-overview.md
│   ├── gap-analysis.md
│   ├── classification-conflicts.md
│   ├── metadata-conflicts.md
│   └── citation-quarantine.md
├── .gitignore
├── .env                                 # API-Keys, gitignored
├── requirements.txt
└── README.md
```

### C.2 Erklaerung der zentralen Ordner

**`.claude/`** Claude-Code-Konfiguration. Projekt-Verfassung, Regeln, Skills. Wird bei jeder Claude-Code-Session automatisch geladen.

**`.scripts/`** Python-Skripte die von Skills aufgerufen werden. Jedes Skript hat eine klare Verantwortlichkeit. Nie von Hand aendern waehrend Skills laufen.

**`config/`** Tool-Dispatcher, API-Konfiguration, GROBID-Config. `.env.example` ist Template für andere Nutzer, `.env` ist dein echter.

**`00_meta/`** Projekt-uebergreifende Daten. `scope.md` ist die wichtigste Datei des gesamten Vaults.

**`01_sources/`** Der saubere Pool. Nur verifizierte Quellen. Wenn eine File hier liegt, hat sie alle Gates passiert.

**`_pending/`** Verarbeitet aber Verifikation offen. Hier liegen Quellen mit `metadata_conflict` oder unverifizierten Zitaten. Wird vom `source-review`-Skill regelmaessig abgearbeitet.

**`_raw/`** Eingangsbereich. Nutzer legt hier Quellen ab, Skills lesen von hier. Unterordner nach Format. Nie direkt bearbeiten.

**`_cache/`** Technische Zwischenergebnisse. GROBID-Output, gechunkte PDFs, JSON-Fragmente. Darf geloescht werden, wird neu generiert.

**`_attachments/`** Archivierte Original-PDFs nach erfolgreicher Verarbeitung. Liegt neben den `01_sources/`-Files als physischer Nachweis.

**`02_drafts/`** Deine eigene Prosa. Claude schreibt hier NICHT eigenstaendig, nur auf expliziten Request mit Quellen aus dem Pool.

**`03_dashboards/`** Dataview-Queries. Render live. Keine statischen Listen.

### C.3 Der Buchfoto-Workflow im Detail

Wenn du ein Buch in der Bibliothek fotografierst:

```
_raw/books/mueller-2023-recruiting-ki/
├── cover.jpg
├── impressum.jpg
├── klappentext.jpg
├── inhaltsverzeichnis-01.jpg
├── inhaltsverzeichnis-02.jpg
├── seite-047.jpg
├── seite-048.jpg
├── seite-049.jpg
├── seite-052.jpg
└── metadata-hint.txt          # Optional
```

**Namens-Konvention des Ordners**: `<autor-nachname>-<jahr>-<kurztitel-slug>`. Also `mueller-2023-recruiting-ki`.

**Pflicht-Inhalte**:
- Mindestens ein Foto vom Cover ODER vom Impressum (für Metadaten-Extraktion)
- Mindestens eine Innenseite mit erkennbarer Seitenzahl

**Nice-to-Have**:
- Klappentext (hilft bei Relevanz-Einschaetzung)
- Inhaltsverzeichnis (hilft bei Kapitel-Mapping)
- `metadata-hint.txt` mit manuellen Hinweisen falls Impressum unleserlich (Beispiel: "ISBN 978-3-xxx, Seite 47-52 wichtig, Springer-Verlag")

**Der Skill `ingest-book-folder`** erkennt automatisch was Cover ist, was Impressum, was Innenseiten. Extrahiert Metadaten via GPT-Vision, OCR die Innenseiten, erstellt eine einzige konsolidierte Quellen-File in `01_sources/` (nach Verifikation).

## Teil D: Scope-Konfiguration

### D.1 Die Rolle von scope.md

`scope.md` ist der zentrale Bauplan des Projekts. Alle Skills lesen diese Datei und richten sich nach ihren Vorgaben. Inhaltliches Fuellen passiert spaeter per Voice-Dump von Deniz. Claude Code erstellt nur das Template-Geruest.

### D.2 scope.md Template (Geruest)

```markdown
---
projekt_name: "EU AI Act und Recruiting in deutschen Personaldienstleistern"
projekt_kuerzel: "bt-ai-act-recruiting"
deliverable: "Bachelorarbeit, HdWM Mannheim, Abgabe 2026-06-15"
zitierstil: "Elsevier Harvard with titles"
zitierstil_csl_file: "elsevier-harvard-with-titles.csl"
sprache: "de"
umfang_ziel: "11000 Woerter plus-minus 10 Prozent"
zeitraum_scope: "TBD"
geografie_scope: "TBD"
erstellt: "TBD"
status: "template-pending-voice-dump"
zotero_collection: "Bachelorarbeit EU AI Act Recruiting"
verification_strictness: "high"
minimum_quality_tier: "grey_literature_hoch"
---

# 1. Forschungsfrage

TBD via Voice-Dump

# 2. Unterfragen

TBD

# 3. Scope-Grenzen

## Inklusions-Kriterien
TBD

## Exklusions-Kriterien
- Bachelorarbeiten nicht zitieren, nur als Quellen-Mine fuer Literaturverzeichnisse
TBD weitere

# 4. Kategorien-System (Puzzle)
TBD via Voice-Dump

# 5. Quellen-Qualitaetsstandards
TBD

# 6. Saettigungs-Kriterien
TBD

# 7. Methodik
TBD
```

Claude Code erstellt diese Datei als Geruest. Deniz fuellt sie spaeter per Voice-Dump-Session mit Miraculix.

## Teil E: Die Skills

Jeder Skill ist eine Markdown-Datei in `.claude/skills/` mit YAML-Header und Body. Claude Code laedt die Liste beim Start und zeigt sie als Slash-Kommandos.

### E.1 Skill Allgemein-Struktur

Jede Skill-Datei folgt diesem Muster:

```markdown
---
name: skill-name
description: Kurze Beschreibung was der Skill tut
trigger: /skill-name
requires: [python_env, grobid_running, api_keys]
inputs: Was der User uebergibt
outputs: Was produziert wird
---

# Skill-Name

## Pre-Checks
- Liest scope.md
- Prueft ob noetige APIs/Tools verfuegbar
- Prueft ob Input-Format stimmt

## Ablauf
Schrittfolge als Agent-Anweisung

## Gates
Welche Quality-Gates bevor Output akzeptiert wird

## Fehler-Handling
Was passiert bei Failures
```

### E.2 Skill 1: ingest-pdf (Text-PDFs mit Textebene)

**Trigger**: `/ingest-pdf <pfad-zur-pdf>`
**Zweck**: PDFs mit extrahierbarer Textebene verarbeiten, Metadaten extrahieren, Chunking mit Layout-Ankern.

**Ablauf**:
1. Pre-Check: PDF existiert, Textebene vorhanden (via pypdf pruefen)
2. Chunk-Skript `.scripts/ingestion/chunk_pdf_with_anchors.py` aufrufen: 30-Seiten-Chunks mit 2-Seiten-Overlap, jeder Chunk bekommt `page_start` und `page_end` Marker im Text
3. Ersten Chunk an Claude API senden: extrahiere Metadaten (Autor, Jahr, Titel, Journal, DOI, ISBN falls Buch)
4. Metadaten-Verifikation triggern via `verify-metadata`-Skill
5. Wenn Metadaten OK: Quellen-File in `_pending/` anlegen mit Frontmatter plus Chunks referenziert
6. User informieren: "Quelle X eingelesen, in _pending/. Jetzt `/extract-passages` für Passage-Extraktion"

### E.3 Skill 2: ingest-scan-pdf (PDFs ohne Textebene)

**Trigger**: `/ingest-scan-pdf <pfad>`
**Zweck**: Gescannte PDFs via Mistral OCR in Text ueberfuehren.

**Ablauf**:
1. Pre-Check: PDF ohne Textebene bestaetigen
2. `.scripts/ingestion/run_mistral_ocr.py` aufrufen: PDF an Mistral OCR API, Batch-Mode wenn ueber 50 Seiten
3. Output: strukturiertes Markdown mit Tabellen als HTML, Ueberschriften erkannt, Seitenumbrueche als Marker
4. Chunking wie in E.2
5. Metadaten-Extraktion, Verifikation, Ablage in `_pending/`

**Fallback-Kette**: Mistral primaer, bei Fehler OpenAI Vision, bei weiterem Fehler Claude Vision mit Seiten als Bilder.

### E.4 Skill 3: ingest-book-folder (Buchfoto-Ordner)

**Trigger**: `/ingest-book-folder <pfad-zum-ordner>`
**Zweck**: Kompletten Buchfoto-Ordner verarbeiten (Cover, Impressum, Innenseiten).

**Ablauf**:
1. Pre-Check: Ordner existiert, enthält mindestens ein Foto
2. File-Klassifikation: welches Bild ist Cover, welches Impressum, welche sind Innenseiten (per Dateiname oder per GPT-Vision Check)
3. Metadaten-Extraktion aus Cover plus Impressum via OpenAI Vision (falls Handschrift oder schlechte Qualitaet) oder Claude Vision
4. ISBN erkennen und an Google Books API senden für Metadaten-Konsens
5. Innenseiten durch GPT-Vision oder Mistral OCR (je nach Qualitaet): Text plus erkannte Seitenzahlen extrahieren
6. Seitenzahl-Validierung: stimmt die auf dem Foto sichtbare Seitenzahl mit dem Dateinamen (falls `seite-047.jpg`) ueberein?
7. Optional `metadata-hint.txt` einlesen und Metadaten damit anreichern
8. Konsolidierte Quellen-File erstellen mit allen Innenseiten als Passage-Kandidaten, Cover-Bild im Frontmatter verlinkt

**Wichtig**: Pro Buch EINE Quellen-File, nicht pro Seite.

### E.5 Skill 4: ingest-web (Web-Artikel)

**Trigger**: `/ingest-web <url>` oder `/ingest-web <pfad-zur-html-datei>`
**Zweck**: Web-Artikel, Blog-Posts, Policy-Papers als Quelle aufnehmen.

**Ablauf**:
1. URL fetch mit Archivierung: lokale HTML-Kopie in `_raw/web/<domain>-<datum>.html` speichern
2. Wayback-Machine-Snapshot anfordern (archive.org) und URL notieren
3. HTML zu Markdown konvertieren (readability-lib oder markdownify)
4. Metadaten: Titel aus `<title>`, Autor aus Byline, Datum aus Meta-Tags, URL, Access-Datum
5. Keine DOI-Verifikation (Web-Artikel haben selten DOIs), daher `verification_strictness: medium` für diese Quellen
6. `access_status: ok`, `last_access_check: <heute>`, `archived_url: <wayback-link>` in Frontmatter

### E.6 Skill 5: extract-passages (HERZSTUECK, Force-Quote plus Fuzzy-Validation)

**Trigger**: `/extract-passages <pfad-zur-source-md-in-pending>`
**Zweck**: Passagen extrahieren, klassifizieren, validieren.

**Ablauf**:
1. Source-File in `_pending/` laden, Chunks laden aus `_cache/chunks/`
2. `scope.md` lesen, besonders Kategorien und Einschluss-Kriterien
3. Pro Chunk: Claude API-Call mit Force-Quote-Prompt (siehe Teil G)
4. Output-Format strikt JSON: Liste von Passagen mit `quote`, `page`, `passage_type`, `intended_use`, `kategorie_tag`, `confidence`
5. Fuzzy-Validator `.scripts/validation/fuzzy_quote_validator.py` aufrufen: jede extrahierte `quote` gegen den Chunk-Originaltext pruefen
6. Passagen mit Score unter 85%: verwerfen, Claude um Neuextraktion bitten, bis zu drei Retries
7. Bei drei-fachem Failure: Passage mit `REQUIRES_MANUAL_VERIFICATION` markieren
8. Ergebnisse in Quellen-File anhaengen, Quelle bleibt in `_pending/` bis `source-review`-Skill sie nach `01_sources/` verschiebt
9. User informieren: "X Passagen extrahiert, Y verifiziert, Z manuell zu pruefen"

### E.7 Skill 6: verify-metadata

**Trigger**: `/verify-metadata <pfad-zur-source-md>`
**Zweck**: Konsens-Verifikation der Metadaten gegen externe APIs.

**Ablauf**:
1. Source-File lesen, LLM-extrahierte Metadaten sammeln (Autor, Jahr, Titel, DOI, ISBN)
2. Wenn DOI vorhanden: Crossref und DataCite parallel abfragen. DOI-Primary für Zeitschriftenartikel.
3. Wenn ISBN vorhanden: Google Books API abfragen.
4. Wenn kein DOI/ISBN aber Titel plus Autor plus Jahr: OpenAlex Titelsuche, DNB SRU bei deutschen Buechern.
5. Konsens-Skript `.scripts/metadata/consensus_validator.py`: vergleicht LLM-Extraktion mit API-Antworten. Bei hoher Uebereinstimmung: API-Daten gewinnen (Ground Truth).
6. Bei Konflikt: Frontmatter bekommt `metadata_conflict: true`, Detail-Infos in `metadata_conflict_details:` Feld
7. Quelle landet im Konflikt-Dashboard zur manuellen Klaerung
8. Bei Konsens: `metadata_verified: true`, Zotero-Sync triggern

**Halluzinations-Check**: wenn KEINE der APIs die Quelle kennt, obwohl LLM eine plausible DOI generiert hat, ist das ein starkes Halluzinations-Signal. `metadata_conflict: ghost_citation_suspect: true` setzen, Quelle NICHT in Zotero syncen.

### E.8 Skill 7: sync-zotero

**Trigger**: `/sync-zotero <pfad-zur-source-md>` oder automatisch nach erfolgreicher Metadaten-Verifikation
**Zweck**: Verifizierte Metadaten nach Zotero pushen.

**Ablauf**:
1. Source-File lesen, pruefen dass `metadata_verified: true`
2. `.scripts/zotero/pyzotero_sync.py` aufrufen mit Metadaten plus Collection-Name aus scope.md
3. Pyzotero erzeugt Zotero-Item in der Collection
4. Nach Erfolg: BetterBibTeX generiert Citation Key
5. Citation Key aus Zotero zurueckholen und in Source-File Frontmatter `citation_key:` eintragen
6. `bibliography.bib` wird automatisch durch BetterBibTeX-Auto-Export aktualisiert

### E.9 Skill 8: mine-thesis-bibliography

**Trigger**: `/mine-thesis-bibliography <pfad-zur-fremden-thesis.pdf>`
**Zweck**: Aus einer Bachelor-/Masterarbeit oder Dissertation deren Literaturverzeichnis ausbeuten um neue Quellen-Kandidaten zu identifizieren.

**Wichtig**: Die Fremd-Arbeit selbst wird NICHT zitiert, NICHT als Quelle aufgenommen, NICHT in `01_sources/` kopiert. Nur deren Referenzen.

**Ablauf**:
1. GROBID-Container-Check (läuft er?)
2. `.scripts/ingestion/run_grobid.py` aufrufen: PDF an GROBID, Output ist strukturiertes XML/JSON mit allen parsed Referenzen
3. Referenzen deduplizieren gegen bereits in Zotero vorhandene Quellen (via DOI oder Titel-Fuzzy-Match)
4. Neue Referenzen in `00_meta/mining-log/<datum>-thesis-bibliography-<autor>.md` eintragen mit Status `candidate`
5. Für jede neue Referenz Metadaten-Verifikation gegen Crossref/OpenAlex durchlaufen
6. User bekommt strukturierte Liste: "42 Referenzen gefunden, 12 schon im Pool, 30 neu. Neue priorisiert nach DOI-Verfuegbarkeit."
7. Nach Review loescht User die temporaere Fremd-Thesis-PDF aus `_raw/`

### E.10 Skill 9: gap-check

**Trigger**: `/gap-check` (ohne Parameter)
**Zweck**: Aktuelle Abdeckung der scope.md-Kategorien analysieren.

**Ablauf**:
1. `00_meta/scope.md` lesen, alle Kategorien extrahieren
2. Alle Quellen in `01_sources/` scannen, pro Passage die `kategorie_tag`s zaehlen
3. Tabelle rendern: Kategorie, Anzahl Quellen, Anzahl direkte Zitate, Anzahl Paraphrasen, Anzahl Hintergrund, Status (rot/gelb/gruen basierend auf Saettigungs-Kriterien aus scope.md)
4. Output als Markdown-Tabelle in `03_dashboards/gap-analysis.md`
5. Zusaetzliche Analyse: welche Kategorien triangulieren (haben gegensaetzliche Positionen), welche nur bestaetigend

### E.11 Skill 10: pool-query

**Trigger**: `/pool-query <suchbegriff oder kategorie>`
**Zweck**: Beim Schreiben der Thesis Zitate aus dem Pool finden.

**Ablauf**:
1. Dataview-Abfrage ueber `01_sources/`: alle Passagen die Kategorie, Suchbegriff oder Intent-Tag matchen
2. Output als Tabelle: Zitat (gekuerzt), Autor, Jahr, Seite, Citation Key, passage_type
3. User kann per Klick in die Quellen-File springen oder Citation Key kopieren
4. Beispiel: `/pool-query kategorie=K3 typ=direct_quote` zeigt alle direkten Zitate zur Hochrisiko-Klassifikation

### E.12 Skill 11: source-review (Quality-Gate)

**Trigger**: `/source-review <pfad-zur-pending-source-md>`
**Zweck**: Quality-Gate durchlaufen, nach Bestehen Quelle von `_pending/` nach `01_sources/` verschieben.

**Ablauf**:
1. Source-File laden, Pruefliste abarbeiten:
   - `metadata_verified: true`? Sonst Gate-Fail
   - `citation_key` gesetzt (Zotero-Sync erfolgreich)? Sonst Gate-Fail
   - Alle Passagen entweder `citation_verified: true` oder explizit `REQUIRES_MANUAL_VERIFICATION`? Sonst Gate-Fail
   - Keine offenen `metadata_conflict`? Sonst Gate-Fail
   - Alle Pflicht-Frontmatter-Felder gesetzt? Sonst Gate-Fail
2. Quality-Score berechnen: 100 Punkte Startguthaben, Abzüge für fehlende optionale Felder, unklare Klassifikationen, offene TODOs
3. Score-Gates: unter 80 bleibt Quelle in `_pending/` mit Fehlerliste. 80-89 verschoben nach `01_sources/` mit Flag `needs_polish`. 90+ sauber verschoben und committed.
4. Bei erfolgreichem Commit: `git add 01_sources/<file> && git commit -m "Add source: <title>"`
5. User bekommt Summary: "Quelle X in Pool aufgenommen, Score 92, 3 direkte Zitate, 5 Paraphrasen, 2 Hintergrund."

## Teil F: Pipeline-Stufen im Detail

Die gesamte Ingestion-Pipeline besteht aus acht sequenziellen Stufen. Jede Stufe ist idempotent (mehrfach durchlaufbar ohne Schaden).

### F.1 Capture

**Verantwortlich**: Mensch
**Was passiert**: Nutzer legt Input in `_raw/` ab. PDFs in `_raw/pdfs/`, Buchfotos in `_raw/books/<buch-ordner>/`, Web-HTML in `_raw/web/`, etc.

### F.2 Normalize

**Verantwortlich**: Claude Code plus Python-Skripte
**Was passiert**: Format-Erkennung, OCR wenn noetig, Encoding-Normalisierung. Chunk-Erstellung mit Layout-Ankern (page_start, page_end als Marker im Text). Output wandert nach `_cache/chunks/`.

### F.3 Enrich (Metadaten-Extraktion)

**Verantwortlich**: Claude API
**Was passiert**: Aus Chunk 1 Metadaten herausziehen (Autor, Jahr, Titel, DOI, ISBN, Publisher). Output als JSON im Source-File-Frontmatter initial (`metadata_status: llm_extracted`).

### F.4 Verify (Konsens gegen externe APIs)

**Verantwortlich**: Python-Skripte, Metadaten-APIs
**Was passiert**: Crossref, OpenAlex, DNB, Google Books abfragen. Konsens-Algorithmus. Bei Match: `metadata_verified: true`. Bei Konflikt: `metadata_conflict: true`, landet im Dashboard. Bei Null-Match: `ghost_citation_suspect: true`.

### F.5 Classify (Passage-Extraktion)

**Verantwortlich**: Claude API mit Force-Quote-Pattern plus Fuzzy-Validator
**Was passiert**: Pro Chunk Passagen extrahieren, klassifizieren (typ, intent, kategorie), validieren via rapidfuzz gegen Original-Chunk. Bei Failure Retry-Loop.

### F.6 Gate (Quality-Check vor Pool-Aufnahme)

**Verantwortlich**: `source-review`-Skill
**Was passiert**: Pruefliste abarbeiten, Score berechnen. Unter 80 bleibt in `_pending/`. Ab 80 wandert in `01_sources/` und wird committed.

### F.7 Archive

**Verantwortlich**: `source-review`-Skill
**Was passiert**: Original-PDF oder Foto-Ordner wird in `_attachments/` verschoben als physischer Nachweis. Source-File in `01_sources/` verlinkt darauf.

### F.8 Audit (laufend)

**Verantwortlich**: Git plus Dashboards
**Was passiert**: Jede Aenderung committed. Dashboards zeigen Konflikte, Luecken, offene Quarantaene-Faelle. Nutzer arbeitet diese kontinuierlich ab.

## Teil G: Zitat-Integritaets-Layer (KRITISCHER PFAD)

Dies ist der wichtigste Teil des gesamten Frameworks. Ohne diesen Layer ist die Thesis angreifbar.

### G.1 Force-Quote-Pattern im Extraktions-Prompt

Jeder Passage-Extraction-Prompt an Claude folgt strikt diesem Muster:

```
Du erhaelst einen Text-Chunk aus einer wissenschaftlichen Quelle.
Der Chunk ist mit Layout-Ankern `<page_start:N>` und `<page_end:N>` markiert.

Extrahiere relevante Passagen gemaess scope.md-Kategorien.

ABSOLUTE REGELN:
1. Jedes `quote`-Feld muss WOERTLICH aus dem Chunk stammen. Kein Paraphrasieren in quote-Feldern.
2. Seitenzahl wird aus den Anker-Markern gelesen. Wenn eine Passage Anker `<page_start:47>` folgt aber vor `<page_end:47>`, ist page=47.
3. Wenn du unsicher bist ob ein Zitat exakt aus dem Chunk ist, setze `confidence: low` und den Text trotzdem wortgetreu.
4. Kein Schmuck, keine Zusammenfassung, keine eigenen Worte im quote-Feld.

OUTPUT strikt als JSON:
[
  {
    "quote": "Wortlaut exakt aus Chunk",
    "page": 47,
    "passage_type": "direct_quote|paraphrase|background|method_reference|example",
    "intended_use": "theory|method|empirical|counter_argument|context",
    "kategorie_tag": "K1|K2|...|KN",
    "confidence": "high|medium|low",
    "context_snippet_pre": "Die 2-3 Worte vor dem Zitat (fuer Fuzzy-Match-Anker)",
    "context_snippet_post": "Die 2-3 Worte nach dem Zitat"
  }
]
```

### G.2 Der Fuzzy-Match-Validator

**Datei**: `.scripts/validation/fuzzy_quote_validator.py`
**Verantwortung**: jeder extrahierte Quote wird gegen den Original-Chunk geprueft bevor er in die Source-File wandert.

### G.3 Fuzzy-Validator Pseudocode

```python
# .scripts/validation/fuzzy_quote_validator.py
from rapidfuzz import fuzz
import json

SIMILARITY_THRESHOLD = 85
MAX_RETRIES = 3

def validate_quote(quote_obj, chunk_text):
    """
    Prueft ob quote_obj['quote'] im chunk_text vorkommt.
    Returns: {valid: bool, score: int, matched_span: str|None, suggested_page: int|None}
    """
    quote = quote_obj["quote"]
    claimed_page = quote_obj["page"]
    
    # Schritt 1: exakter Match-Versuch
    if quote in chunk_text:
        return {
            "valid": True,
            "score": 100,
            "matched_span": quote,
            "suggested_page": extract_page_from_anchors(chunk_text, quote)
        }
    
    # Schritt 2: Fuzzy-Match mit Sliding-Window ueber Chunk
    best_score = 0
    best_match = None
    window_size = len(quote)
    for i in range(0, len(chunk_text) - window_size, 10):
        window = chunk_text[i:i+window_size]
        score = fuzz.ratio(quote, window)
        if score > best_score:
            best_score = score
            best_match = window
    
    valid = best_score >= SIMILARITY_THRESHOLD
    return {
        "valid": valid,
        "score": best_score,
        "matched_span": best_match if valid else None,
        "suggested_page": extract_page_from_context(best_match, chunk_text) if valid else None
    }
```

### G.4 Retry-Loop bei Failure

Wenn `validate_quote` ein Zitat als invalid einstuft:

1. Zitat plus Score plus Original-Chunk zurück an Claude schicken
2. Prompt: "Das extrahierte Zitat ist nicht wortwoertlich im Chunk. Score: {score}. Extrahiere die Passage erneut, diesmal strikt woertlich aus dem Chunk."
3. Bis zu MAX_RETRIES (3) Versuche
4. Bei finalem Failure: Zitat wird in Source-File aufgenommen mit `citation_verified: false`, `REQUIRES_MANUAL_VERIFICATION: true`
5. Eintrag landet im `citation-quarantine`-Dashboard

### G.5 Seitenzahl-Verifikation via Layout-Anchoring

Beim Chunking werden Page-Marker in den Text injiziert:

```
<page_start:47>
Lorem ipsum dolor sit amet, consectetur adipiscing elit...
<page_end:47>
<page_start:48>
Sed do eiusmod tempor incididunt ut labore...
```

Der Validator liest die Anker und bestimmt die Seitenzahl deterministisch aus der Position des Matches im Chunk. Kein LLM errechnet Seitenzahlen selbst.

### G.6 Context-Snippet als zweite Sicherung

Jedes extrahierte Zitat kommt mit `context_snippet_pre` und `context_snippet_post` (je 2-3 Worte). Beim Validator:
- Wenn das Zitat selbst fuzzy-matched, prueft der Validator zusaetzlich ob pre und post im Original-Chunk am richtigen Ort stehen
- Verhindert dass ein aehnlich klingendes Zitat an falscher Stelle als Match akzeptiert wird

### G.7 Quarantaene-Flow

Zitate mit `REQUIRES_MANUAL_VERIFICATION` werden im Dashboard `03_dashboards/citation-quarantine.md` gelistet mit Direkt-Link zur Source-File und zum Original-Chunk. Nutzer arbeitet diese periodisch ab, bestaetigt oder verwirft manuell. Bestaetigte Zitate werden auf `citation_verified: true` umgestellt.

## Teil H: Metadaten-Verifikations-Layer

### H.1 Der Konsens-Mechanismus

**Ziel**: verhindern dass vom LLM erfundene oder falsch extrahierte Metadaten in Zotero landen.

**Ablauf** (im `consensus_validator.py`):

1. LLM hat Metadaten extrahiert: Autor, Jahr, Titel, ggf. DOI oder ISBN
2. Je nach verfuegbarer ID:
   - **Mit DOI**: `Crossref.works.get(doi)` → liefert offizielle Metadaten. Wenn erfolgreich, ist das die Ground Truth.
   - **Mit ISBN**: `GoogleBooks.volumes.get(isbn)` plus `DNB.sru(isbn)` für deutsche Bücher.
   - **Ohne ID**: OpenAlex Titel-Suche, erweiterter Fuzzy-Match gegen Crossref.
3. Vergleich LLM-Extraktion vs. API-Ergebnis:
   - Titel-Fuzzy-Match: > 90% identisch
   - Jahr: exakte Gleichheit
   - Autor (erster): Levenshtein-Distanz max 2 Zeichen (für Umlaut-Variationen und Tippfehler)
4. Scoring:
   - 3 von 3 Matches: `metadata_verified: true`, API-Daten ueberschreiben LLM-Daten
   - 2 von 3 Matches: `metadata_conflict: minor`, landet im Review-Dashboard mit auto-Vorschlag
   - 1 oder 0 von 3 Matches: `metadata_conflict: major`, blockierend für Zotero-Sync
   - 0 API-Treffer trotz plausibler LLM-DOI: `ghost_citation_suspect: true`, harte Blockade

### H.2 Was bei Ghost Citations passiert

Wenn ein LLM eine DOI erfindet, findet Crossref die DOI nicht. Dann:

1. Fallback-Check via OpenAlex (grossere Coverage)
2. Fallback-Check via Semantic Scholar
3. Wenn alle drei nicht finden: `ghost_citation_suspect: true`
4. Source-File wird in `_pending/` als ghost-verdaechtig markiert
5. Nutzer bekommt Alarm im Dashboard: "Quelle X hat DOI Y, aber keine Datenbank kennt sie. Vermutlich halluziniert. Manuell pruefen oder verwerfen."
6. NIEMALS automatischer Sync in Zotero für ghost-verdaechtige Quellen

### H.3 API-Priorisierung pro Quellen-Typ

**Für Zeitschriftenartikel**: Crossref primaer, OpenAlex als Ergänzung (Zitationsgraph, OA-Link), DataCite falls Preprint-DOI.

**Für deutsche Buecher**: DNB SRU primaer (beste Coverage), Google Books als Ergänzung (Cover, Klappentext), Crossref falls Buch-DOI vorhanden.

**Für englische Buecher**: Google Books primaer, OpenAlex als Ergänzung.

**Für Preprints**: DataCite primaer, OpenAlex als Ergänzung.

**Für Policy-Papers und graue Literatur**: OpenAlex (falls indexiert), sonst manuelle Metadaten mit hohem Prüf-Flag.

**Für Web-Artikel**: keine API-Verifikation moeglich. `verification_strictness: medium`, dafuer archivierte URL via Wayback-Machine als Integritaets-Nachweis.

### H.4 Retraction-Check

Nach erfolgreicher Metadaten-Verifikation (wenn DOI vorhanden):
1. Crossref-Response pruefen auf `update-to` Feld mit `type: retraction`
2. Falls Retraction erkannt: `retracted: true` in Frontmatter
3. Dashboard-Eintrag "Retracted sources" zeigt alle betroffenen Quellen
4. Bei Zitations-Versuch in `02_drafts/` wird Warning ausgegeben

Zoteros eigene Retraction-Watch-Integration läuft parallel. Doppelte Sicherung.

### H.5 Metadaten-Konflikt-Dashboard

Datei `03_dashboards/metadata-conflicts.md`:

```dataview
TABLE
  title as "Titel",
  author as "Autor (LLM)",
  api_author as "Autor (API)",
  year as "Jahr",
  metadata_conflict_details as "Konflikt"
FROM "_pending"
WHERE metadata_conflict = true
SORT conflict_severity DESC
```

Nutzer arbeitet diese Liste periodisch ab. Pro Konflikt: entweder LLM-Wert manuell bestaetigen, API-Wert manuell bestaetigen, oder Quelle verwerfen.

## Teil I: Zotero-Integration im Detail

### I.1 Architektur-Prinzip

**Zotero ist der Metadaten-Master. Der Vault ist der Synthese- und Analyse-Ort.**

Fliessrichtung:
- Verifizierte Metadaten → Zotero (Schreibrichtung)
- Citation Key → zurück in Vault-Source-File (Lese-Sync)
- Bibliography → auto-exportiert nach `00_meta/bibliography.bib`

Der Vault schreibt nicht direkt in die Zotero-Datenbank mit Ausnahme von neuen Items. Keine Updates an existierenden Items aus dem Vault. Bei Konflikt gewinnt Zotero als Ground Truth.

### I.2 Pyzotero-Setup

`.scripts/zotero/pyzotero_sync.py`:

```python
from pyzotero import zotero
from dotenv import load_dotenv
import os

load_dotenv()

zot = zotero.Zotero(
    library_id=os.getenv("ZOTERO_USER_ID"),
    library_type="user",
    api_key=os.getenv("ZOTERO_API_KEY")
)

def create_item(metadata, collection_key):
    """Legt neues Item in Zotero an und gibt Citation Key zurueck."""
    template = zot.item_template(metadata["item_type"])
    template.update(metadata)
    template["collections"] = [collection_key]
    response = zot.create_items([template])
    if response["success"]:
        item_key = list(response["success"].values())[0]
        # Warte auf BetterBibTeX Citation Key Generation (async)
        time.sleep(2)
        item = zot.item(item_key)
        return item["data"].get("citationKey", item_key)
    raise Exception(f"Zotero-Sync fehlgeschlagen: {response}")
```

### I.3 Collection-Mapping

Die Thesis-Collection hat in Zotero einen `collection_key`. Diesen muss man einmalig holen:

```python
collections = zot.collections()
for c in collections:
    if c["data"]["name"] == "Bachelorarbeit EU AI Act Recruiting":
        print(c["key"])  # z.B. "ABC123XY"
```

Der Key wird in `config/tools.yaml` unter `zotero.collection_key` eingetragen. Von da an verwenden alle Sync-Operationen diesen Key.

### I.4 Pro Quellen-Typ die richtige item_type

Zotero unterscheidet Item-Types. Mapping basierend auf `source_class` in Vault:

- `journal_article` → `journalArticle`
- `book` → `book`
- `chapter` → `bookSection`
- `thesis` → `thesis` (aber wir zitieren keine Theses!)
- `video_talk` → `videoRecording`
- `audio` → `podcast` oder `audioRecording`
- `web_article` → `webpage` oder `blogPost`
- `dataset` → `dataset`
- `physical_book_note` → `book` (mit physical_location-Notiz im extra-Feld)
- `handwritten_note` → `manuscript`

### I.5 BibLaTeX-Auto-Export

BetterBibTeX läuft als Hintergrund-Service. Konfigurierter Auto-Export nach `00_meta/bibliography.bib`:
- Jede Aenderung in der Collection triggert Neu-Export (mit 5s Debounce)
- Format: Better BibLaTeX (nicht Better BibTeX, BibLaTeX ist moderner)
- Datei ist gitignored in `_cache/` wenn es sich um Temporaerversionen handelt, die Haupt-Datei im `00_meta/` ist committed

### I.6 Pandoc-Compilation der Thesis

Für finale PDF-Generation:
```bash
pandoc 02_drafts/*.md \
  --bibliography=00_meta/bibliography.bib \
  --csl=config/elsevier-harvard-with-titles.csl \
  --citeproc \
  -o bachelorarbeit-endfassung.pdf
```

Alle Citation Keys in den Drafts `[@citation_key, p. 47]` werden korrekt in Harvard-Stil aufgeloest.

## Teil J: CLAUDE.md Template (Die Projekt-Verfassung)

Diese Datei liegt unter `.claude/CLAUDE.md` im Vault. Wird bei jeder Claude-Code-Session automatisch geladen. Maximal 150 Zeilen (Claude haelt sich bei kuerzeren Verfassungen zuverlaessiger an Regeln).

```markdown
# CLAUDE.md: Bachelorarbeit Research Vault

Du bist der Claude-Code-Assistent fuer einen wissenschaftlichen Research-Vault.

## Rolle und Haltung

- Praeziser, kritischer Research-Assistent.
- Du halluzinierst nie. Lieber "nicht verifizierbar" als raten.
- Du haelst dich strikt an `00_meta/scope.md`. Sie ist dein Bauplan.
- Du antwortest auf Deutsch. Fachbegriffe auf Englisch wenn Standard.

## Absolute Regeln (Non-Negotiable)

1. **Zitat-Integritaet ist oberste Prioritaet**. Jedes direkte Zitat muss wortwoertlich aus der Quelle stammen. Bei geringster Unsicherheit setze `REQUIRES_MANUAL_VERIFICATION`.

2. **Metadaten werden immer gegen externe APIs verifiziert** bevor eine Quelle nach `01_sources/` geht. Crossref fuer DOIs, OpenAlex fuer Papers, DNB fuer deutsche Buecher, Google Books fuer ISBN. Bei Abweichung: `metadata_conflict: true`.

3. **Gate vor Commit**: Neue Quellen landen erst nach bestandenem Quality-Gate in `01_sources/`. Bis dahin bleiben sie in `_pending/`.

4. **Keine Erfindung von Quellen**: Wenn du eine Quelle zitierst, muss sie DOI-verifiziert, ISBN-verifiziert oder URL-verifiziert sein.

5. **Force-Quote-Pattern bei Passage-Extraktion**: Wörtliches Zitat zuerst, dann Analyse. Nie Analyse ohne Zitat als Grundlage.

6. **Human-in-the-Loop bei Klassifikation**: Du schlaegst vor, der Nutzer bestaetigt. Nie autonom klassifizieren.

7. **Zotero ist Metadaten-Master**: Bei Konflikt Vault vs. Zotero gewinnt Zotero.

8. **Kein Auto-Schreiben in `02_drafts/`**: Nutzer schreibt, du lieferst Zitate aus dem Pool auf Anfrage.
```

```markdown
## Vault-Struktur (Kurz-Orientierung)

- `_raw/`: Unverarbeitete Inputs. Nie direkt bearbeiten, nur lesen.
- `_pending/`: Verarbeitet, Verifikation offen. Bleibt bis Gate bestanden.
- `01_sources/`: Saubere Pool. Schreibe nur hier nach Verifikation.
- `02_drafts/`: Thesis-Drafts. Nutzer schreibt, du lieferst Zitate.
- `00_meta/scope.md`: IMMER zuerst lesen bei neuen Aufgaben.
- `00_meta/codebook.md`: Kategorien-Definitionen.

## Schreibgewohnheiten

- Keine Gedankenstriche oder Halbgeviertstriche. Immer Komma, Punkt, normaler Bindestrich.
- Echte Umlaute: ue, oe, ae, ss sind Notfall-ASCII fuer Frontmatter, im Body Markdown voll ue oe ae.
- Tabellen/Listen nur wo noetig. Prosa wo Zusammenhang gefragt.
- Commit-Messages auf Englisch, kurz, Action-Format ("Add source: mueller-2023", "Fix metadata conflict for kaufmann-2021").

## Zitierstil

Aus scope.md: Elsevier Harvard with titles. CSL-File in `config/`. BetterBibTeX Citation Keys: `auth.lower+year+shorttitle(3,3)`.

## Tool-Dispatching

Alle externen APIs laufen ueber Python-Skripte in `.scripts/`. Du rufst nie direkt APIs auf, immer via Skill-definierte Skripte. `config/tools.yaml` definiert Primary und Fallback pro Aufgabe.

## Was du NICHT tust

- Keine freie Generierung bei Faktensuche.
- Keine Uebernahme von Argumentationsstrukturen aus Bachelorarbeiten (Plagiat-Risiko).
- Keine Aenderung von `00_meta/scope.md` ohne explizite Anweisung.
- Keine Loeschung in `_raw/` oder `_attachments/`.
- Keine Git-Commits wenn Quality-Score unter 80.
- Keine Skills ohne Pre-Check (GROBID laeuft? Keys vorhanden? Input-Format stimmt?)

## Bei Unsicherheit

Frage den Nutzer. Klare Formulierung der Unsicherheit. Keine plausiblen Vermutungen als Fakten.
```

## Teil K: Dataview-Dashboards

Dataview rendert live beim Oeffnen der Datei. Jedes Dashboard liegt in `03_dashboards/` als Markdown-Datei mit Dataview-Query im Code-Block.

### K.1 pool-overview.md

```dataview
TABLE
  file.link as "Quelle",
  authors as "Autor",
  year as "Jahr",
  source_class as "Typ",
  length(passages) as "Passagen",
  relevance_rating as "Relevanz"
FROM "01_sources"
WHERE metadata_verified = true
SORT year DESC
```

### K.2 gap-analysis.md

```dataviewjs
// Liest scope.md-Kategorien, zaehlt pro Kategorie Passagen aus 01_sources
const scope = dv.page("00_meta/scope.md");
const kategorien = scope.file.frontmatter.kategorien || [];
const sources = dv.pages('"01_sources"');

let rows = [];
for (const kat of kategorien) {
  const passagen = sources.file.lists
    .filter(p => p.tags && p.tags.includes(kat))
    .length;
  const status = passagen < 3 ? "🔴" : passagen < 5 ? "🟡" : "🟢";
  rows.push([kat, passagen, status]);
}

dv.table(["Kategorie", "Anzahl Passagen", "Status"], rows);
```

### K.3 metadata-conflicts.md

```dataview
TABLE
  file.link as "Quelle",
  metadata_conflict_details as "Konflikt",
  metadata_llm as "LLM-Extraktion",
  metadata_api as "API-Wert"
FROM "_pending"
WHERE metadata_conflict = true
SORT file.ctime DESC
```

### K.4 citation-quarantine.md

```dataviewjs
const sources = dv.pages('"01_sources" or "_pending"');
let rows = [];
for (const src of sources) {
  const passages = src.file.lists.filter(p => 
    p.REQUIRES_MANUAL_VERIFICATION === true || p.citation_verified === false
  );
  for (const p of passages) {
    rows.push([src.file.link, p.quote?.substring(0, 80) + "...", p.page, p.reason]);
  }
}
dv.table(["Quelle", "Zitat (Auszug)", "Seite", "Grund"], rows);
```

### K.5 classification-conflicts.md

```dataview
TABLE
  file.link as "Quelle",
  passage_id,
  classifications as "Alternative Klassifikationen"
FROM "01_sources" or "_pending"
WHERE classification_conflict = true
```

### K.6 review-dashboard.md (in 00_meta/)

Zentrales Dashboard das alle offenen Aufgaben zusammenzieht:

```dataviewjs
dv.header(2, "Offene Reviews");

dv.header(3, "Metadaten-Konflikte");
const mc = dv.pages('"_pending"').where(p => p.metadata_conflict === true);
dv.paragraph(`${mc.length} offene Konflikte. Siehe [[03_dashboards/metadata-conflicts]].`);

dv.header(3, "Zitat-Quarantaene");
const cq = dv.pages('"01_sources" or "_pending"').where(p => p.has_quarantine === true);
dv.paragraph(`${cq.length} Quellen mit Zitaten in Quarantaene. Siehe [[03_dashboards/citation-quarantine]].`);

dv.header(3, "Ghost-Citation-Verdacht");
const ghosts = dv.pages('"_pending"').where(p => p.ghost_citation_suspect === true);
dv.paragraph(`${ghosts.length} verdaechtige Quellen. ACHTUNG: vor Uebernahme manuell pruefen!`);
```

## Teil L: Deployment-Anleitung für Claude Code

Diese Anleitung sagt Claude Code in welcher Reihenfolge der Vault aufgebaut wird und was wann getestet werden muss.

### L.1 Vorbereitung durch den Nutzer (vor Claude-Code-Start)

1. Zielordner anlegen: `C:\Users\deniz\Documents\bachelor-thesis-vault\`
2. Diese Framework-Datei in den Zielordner kopieren als `FRAMEWORK-SPEC.md`
3. API-Keys gemäß Teil B.5 besorgen und in `.env`-Datei im Zielordner ablegen
4. Python 3.11+ verfuegbar (pruefen mit `python --version`)
5. Docker Desktop installiert und gestartet
6. Git installiert
7. Claude Code installiert (npm install -g @anthropic-ai/claude-code)
8. Im Zielordner Claude Code starten: `cd C:\Users\deniz\Documents\bachelor-thesis-vault && claude`

### L.2 Stufen des Aufbaus durch Claude Code

**Stufe 1: Grundgeruest (Ordnerstruktur, Konfigurationsdateien)**
- Ordnerstruktur aus Teil C.1 komplett anlegen
- `.gitignore`-Datei schreiben (mit `.env`, `_cache/`, `_attachments/original-*` gelistet)
- `.env.example` im config-Ordner mit Platzhaltern für alle APIs
- `requirements.txt` aus Teil B.3 schreiben
- `README.md` schreiben mit Kurzanleitung
- `config/tools.yaml` schreiben mit initialer Tool-Matrix
- `config/metadata-apis.yaml` schreiben mit API-Endpoints
- `config/grobid_config.json` schreiben
- Git initialisieren, ersten Commit "Initial vault structure"

**Stufe 2: Claude-Konfiguration**
- `.claude/CLAUDE.md` schreiben gemäß Teil J
- `.claude/rules/source-ingestion.md`, `passage-extraction.md`, `citation-integrity.md`, `zotero-sync.md` als einzelne Rule-Files schreiben
- Git-Commit "Add Claude configuration"

**Stufe 3: Python-Skripte**
- `.scripts/ingestion/chunk_pdf_with_anchors.py` schreiben (PDF-Chunking mit page_start/page_end Markern)
- `.scripts/ingestion/run_claude_pdf.py` schreiben (Claude API-Call mit PDF)
- `.scripts/ingestion/run_mistral_ocr.py` schreiben
- `.scripts/ingestion/run_openai_vision.py` schreiben
- `.scripts/ingestion/run_grobid.py` schreiben
- `.scripts/metadata/lookup_*.py` für Crossref, OpenAlex, DNB, Google Books
- `.scripts/metadata/consensus_validator.py` schreiben
- `.scripts/validation/fuzzy_quote_validator.py` schreiben (der kritischste!)
- `.scripts/zotero/pyzotero_sync.py` schreiben
- Git-Commit "Add Python scripts"

**Stufe 4: Skills**
Alle 11 Skill-Dateien in `.claude/skills/` gemäß Teil E schreiben. Jede mit vollständiger Spec, Pre-Checks, Ablauf, Gates, Fehler-Handling.
- Git-Commit "Add skills"

**Stufe 5: Templates und Meta-Files**
- `00_meta/scope.md` als Geruest gemäß Teil D.2 schreiben (mit TBD-Platzhaltern)
- `00_meta/codebook.md` leer mit Hinweis "Wird mit scope.md zusammen gefuellt"
- `00_meta/tag-vocabulary.md` Template
- `00_meta/ai-usage-card.md` mit HdWM-konformem Template
- `00_meta/eigenstaendigkeitserklaerung.md` Template
- `00_meta/decisions.md` leer mit Header
- `00_meta/review-dashboard.md` mit Dataview-Query aus Teil K.6
- `03_dashboards/*.md` alle fuenf Dashboards aus Teil K
- `02_drafts/01-einleitung.md` bis `05-diskussion.md` als leere Gerueste
- Git-Commit "Add templates and dashboards"

**Stufe 6: Dependencies installieren**
- `pip install -r requirements.txt` im Vault ausfuehren
- Test: `python .scripts/validation/fuzzy_quote_validator.py --test` (Skript bringt eingebauten Test-Case mit)
- Git-Commit wenn Tests gruen: "Dependencies installed and verified"

**Stufe 7: GROBID-Container**
- `docker pull lfoppiano/grobid:0.8.1`
- `docker run -d --name grobid -p 8070:8070 lfoppiano/grobid:0.8.1`
- Test: `curl http://localhost:8070/api/isalive` muss `true` zuruekgeben

**Stufe 8: End-to-End Smoke Test**
- Eine Test-PDF in `_raw/pdfs/` legen (der Nutzer liefert sie)
- `/ingest-pdf _raw/pdfs/<testfile.pdf>` aufrufen
- Beobachten: wird korrekt gechunked, Metadaten extrahiert, verifiziert, in `_pending/` gelegt?
- `/extract-passages _pending/<testfile>.md` aufrufen
- Beobachten: werden Passagen extrahiert, Fuzzy-validated, korrekt klassifiziert?
- `/source-review _pending/<testfile>.md` aufrufen
- Beobachten: wird die Quelle nach `01_sources/` verschoben?
- `/sync-zotero 01_sources/<testfile>.md` aufrufen
- Beobachten: erscheint der Eintrag in der Zotero-Collection?

**Stufe 9: Übergabe an Nutzer**
Nach erfolgreichem Smoke-Test: Claude Code informiert den Nutzer:
- Summary was gebaut wurde
- Hinweis auf offenen Todo: scope.md muss per Voice-Dump gefuellt werden
- Hinweis auf Dashboard-URL (im Obsidian-UI)

### L.3 Quality-Gates der Deployment-Stufen

Pro Stufe gilt: nur wenn die Gate-Bedingungen erfuellt sind, geht es zur naechsten Stufe.

- **Stufe 1 Gate**: alle Ordner vorhanden, `.gitignore` funktioniert (`.env` taucht nicht in `git status` auf)
- **Stufe 2 Gate**: CLAUDE.md unter 150 Zeilen, alle 4 Rule-Files existieren
- **Stufe 3 Gate**: alle Python-Skripte syntaktisch valid (import-Test erfolgreich)
- **Stufe 4 Gate**: alle 11 Skills lesbar, YAML-Header parseable
- **Stufe 5 Gate**: alle Templates existieren, Dashboard-Queries syntaktisch valid
- **Stufe 6 Gate**: `pip install` erfolgreich, Fuzzy-Validator-Test gruen
- **Stufe 7 Gate**: GROBID antwortet auf `/isalive`
- **Stufe 8 Gate**: End-to-End-Smoke-Test mit einer Test-PDF erfolgreich durchlaufen

### L.4 Fehler-Handling

Bei Fehlern in einer Stufe:
1. Claude Code stoppt, zeigt Fehlerdetails
2. Erwartet Nutzer-Input zur Loesung
3. Kein Auto-Fortschritt bei unbehobenen Fehlern
4. Kein Git-Commit bei kaputten Stufen

Haeufige Stolpersteine:
- Python-Installation fehlt oder falsche Version → Nutzer muss Python 3.11+ installieren
- Docker läuft nicht → Docker Desktop starten
- API-Keys fehlen oder falsch → `.env`-Datei pruefen
- Zotero-Collection existiert nicht → Collection in Zotero manuell anlegen
- BetterBibTeX nicht installiert oder Citation Key Format falsch → Zotero-Setup Teil B.6 nachholen

### L.5 Nach erfolgreichem Deployment

Nutzer ist dran:
1. scope.md per Voice-Dump fuellen (mit Miraculix)
2. Erste echte Quellen in `_raw/` legen
3. Skills testen
4. Dashboards im Obsidian-UI beobachten

Claude Code wechselt in Dialog-Modus: empfaengt Voice-Dumps oder Anweisungen, fuehrt Skills aus, meldet Ergebnisse zurück.

## Teil M: Test-Plan

### M.1 Unit-Tests pro Python-Skript

Jedes Skript kommt mit einem eingebauten Test-Mode:

**`fuzzy_quote_validator.py --test`**
- Test 1: exakt matchendes Zitat → valid=true, score=100
- Test 2: Zitat mit 1 Wort-Differenz → valid=true, score>85
- Test 3: Paraphrase statt Zitat → valid=false, score<70
- Test 4: Komplett anderes Zitat → valid=false, score<30

**`consensus_validator.py --test`**
- Test 1: LLM-DOI matches Crossref-Antwort → verified=true
- Test 2: LLM-DOI matches, aber Autor-Differenz → conflict=minor
- Test 3: LLM-DOI bei Crossref nicht gefunden, auch nicht bei OpenAlex → ghost_suspect=true
- Test 4: Kein DOI, nur Titel-Suche → OpenAlex-Fallback

**`chunk_pdf_with_anchors.py --test`**
- Test mit einer kleinen Test-PDF (5 Seiten): korrekte Anker, Overlap, Chunk-Groessen

### M.2 Integration-Test: End-to-End mit einer Test-Quelle

Nach Stufe 8 des Deployments:

1. Test-PDF des Nutzers in `_raw/pdfs/` legen (idealerweise eine bekannte Quelle mit klarer DOI)
2. Kompletter Workflow durchspielen:
   - ingest-pdf
   - verify-metadata (sollte `verified` sein)
   - extract-passages (sollte 3-5 Passagen extrahieren, alle fuzzy-valid)
   - sync-zotero (Eintrag in Zotero-Collection erscheint)
   - source-review (Score >= 90, wandert nach 01_sources/)
3. Visualisierungs-Check im Obsidian-UI:
   - pool-overview zeigt neue Quelle
   - gap-analysis zeigt Kategorie-Abdeckung aktualisiert
   - keine Eintraege in metadata-conflicts oder citation-quarantine

### M.3 Fehlertest: bewusst kaputte Quelle

Als Stress-Test: eine Quelle mit absichtlich verfaelschten Metadaten einspielen:
- DOI die nicht existiert
- Autor der nicht zum Paper gehoert

Erwartung: System erkennt den Konflikt, landet in metadata-conflicts-Dashboard, blockiert Zotero-Sync. Das zeigt dass der Integritaets-Layer funktioniert.

## Teil N: Übergabe-Prompt an Claude Code

Der folgende Prompt wird in Claude Code im Vault-Ordner als erste Nachricht gegeben. Er weist Claude Code an, diese Framework-Datei zu lesen und den Vault stufenweise aufzubauen.

```
Du bist im leeren Bachelor-Thesis-Research-Vault-Ordner. Lies die Datei FRAMEWORK-SPEC.md komplett durch. Sie enthaelt die vollstaendige Bauanleitung fuer den Research-Vault.

Deine Aufgabe: baue den Vault gemaess der Spec in neun Stufen auf. Nach jeder Stufe stoppst du und fragst den Nutzer nach Freigabe fuer die naechste Stufe. Kein Auto-Fortschritt zwischen Stufen.

Stufen siehe Teil L der Spec:
1. Grundgeruest (Ordner, Config, gitignore, requirements.txt)
2. Claude-Konfiguration (CLAUDE.md, Rules)
3. Python-Skripte
4. Skills
5. Templates und Meta-Files
6. Dependencies installieren und testen
7. GROBID-Container starten
8. End-to-End Smoke-Test (Nutzer liefert Test-PDF)
9. Uebergabe an Nutzer

Absolute Regeln waehrend des Baus:
- Kein Schritt ohne Pre-Check
- Bei Fehlern stoppen und Nutzer informieren, nicht weiterlaufen
- Pro abgeschlossener Stufe einen Git-Commit mit aussagekraeftiger Message
- Keine Abkuerzungen, keine Skills auslassen
- Bei Unsicherheit im Code lieber Platzhalter mit TODO als halluzinierte Implementation

Status-Updates pro Stufe:
- Was wird jetzt gemacht
- Welche Files werden geschrieben oder geaendert
- Welche Tests werden ausgefuehrt
- Gate-Ergebnis

Fang mit Stufe 1 an, frage nach Freigabe fuer Stufe 2.
```

### N.1 Alternative: teil-automatisiertes Deployment

Falls du moechtest dass Claude Code ohne Freigabe-Pausen durchlaeuft: letzten Satz ersetzen mit "Arbeite alle 9 Stufen sequenziell ab, stoppe nur bei Fehlern oder wenn Nutzer-Input objektiv noetig ist (z.B. Test-PDF in Stufe 8)."

### N.2 Hinweise zur Nutzung

- Der Prompt sollte als erste Nachricht in Claude Code gegeben werden
- Claude Code muss im Root des leeren Vault-Ordners gestartet werden (`cd ... && claude`)
- Die FRAMEWORK-SPEC.md muss vor dem Claude-Start im Ordner liegen
- Die `.env` mit API-Keys muss vor dem Claude-Start befuellt sein

## Teil O: Nach dem Deployment

### O.1 Der erste Research-Flow

1. Voice-Dump an Miraculix: Forschungsfrage, Kategorien, Ein-/Ausschlusskriterien, Saettigungs-Kriterien
2. Miraculix formuliert strukturierte scope.md
3. Deniz kopiert Inhalt nach `00_meta/scope.md` im Thesis-Vault
4. Commit: `Complete scope.md with research parameters`
5. Erste echte Quellen in `_raw/` legen, Skills testen
6. Gap-Check laufen lassen, Luecken in der Recherche identifizieren
7. Gezielte Recherche mit Perplexity/Undermind für fehlende Kategorien
8. Iterativ weiterfuellen

### O.2 Wartungs-Aufgaben

- Woechentlich: `/source-review` auf allen `_pending/`-Files laufen lassen
- Woechentlich: metadata-conflicts und citation-quarantine abarbeiten
- Bei neuen Projekten: Vault als Template forken, neue `scope.md` erstellen, alles andere bleibt

## Ende der Spec

Diese Framework-Datei ist vollständig. Claude Code hat alles noetige um den Vault zu bauen.
