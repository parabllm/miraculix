# Eingang-Verarbeiten Skill (Digest)

**Trigger:** "eingang verarbeiten", "digest", "inbox sortieren", "sortier das ein"

---

## Ablauf

### Schritt 1 — Inbox lesen
Alle Files in `00-eingang/` mit `status: unverarbeitet`.

### Schritt 2 — Pro Item klassifizieren

**a) Termin mit Uhrzeit?** → Google Calendar Event. Kontakte matchen. Projekt zuordnen.

**b) Aufgabe ohne Uhrzeit?** → Task im Vault (Checkbox oder File je nach Komplexität). Projekt zuordnen.

**c) Meeting-Transkript?** → Meeting-File im Projekt. Offene Punkte extrahieren als Tasks. Zusammenfassung schreiben.

**d) Info die Kontext updatet?** → Bestehendes Projekt-File updaten. NICHT neues File wenn schon eins da. Edit vorschlagen mit old_str → new_str.

**e) Dokument (PDF, Datei)?** → In `_anhaenge/{bereich}/` ablegen. Companion-Markdown-File. Fragen: "Welches Projekt?"

**f) Unklar?** → In `00-eingang/unverarbeitet/` mit Flag lassen. Fragen.

### Schritt 3 — Entity-Matching
Für jeden Namen / Projektbezug:
1. `03-kontakte/*.md` Aliase prüfen
2. `01-projekte/**/_projekt.md` Aliase prüfen
3. Bei Match → Wikilink + Frontmatter-Relation
4. Bei Unsicherheit → fragen

### Schritt 4 — Plan zeigen

```
**Item 1:** "Morgen Paddle mit Maddox 10:00"
→ Google Calendar Event, morgen 10:00-11:30, [[maddox]]

**Item 2:** "Maddox Call wegen BellaVie SEO"
→ Aufgabe in [[bellavie-website]], Kontakt [[maddox]], kein Datum
```

### Schritt 5 — Ausführen (nach OK)
- Vault-Files erstellen/updaten
- Calendar Events
- Google Tasks
- Inbox-Items auf `verarbeitet` setzen

---

## Regeln

- **Nie automatisch.** Erst Plan, dann OK.
- **Ein Voice-Dump = viele Fragmente.** Zerlegen, einzeln klassifizieren.
- **Duplikat-Check.** Bevor neues File, prüfe ob existiert.
- **Kontext-Updates statt neue Files.** "SAP ist durch" → existierendes File finden, Edit vorschlagen.
- **Transkripte:** `ist_transkript: true`. Extrahieren: Teilnehmer, offene Punkte, Entscheidungen.
- **Unbekannte Personen:** fragen, nicht raten.
