# Abgleich Skill (Reconcile)

**Trigger:** "abgleich [Projekt]", "reconcile [Projekt]", "update [Projekt]"

Zweck: Projekt mit neuen Inputs abgleichen. Zentraler Mechanismus gegen Informations-Drift.

---

## Ablauf

### Schritt 1 — Scope
Welches Projekt? Dann:
- `_projekt.md` lesen
- Alle Sub-Projekt `_projekt.md`
- Letzte 5-10 Logs
- Offene Aufgaben
- Verknüpfte Wissens-Einträge

### Schritt 2 — Neue Inputs
Seit letztem Abgleich:
- Inbox-Items mit `vermutetes_projekt: X`
- Neue Meeting-Notes
- Neue Logs
- Was Deniz gerade im Chat sagt

### Schritt 3 — Widersprüche finden
Pro neuer Info:
- Widerspricht existierender Aussage?
- Ist existierende Aussage veraltet?
- Duplikate?

### Schritt 4 — Update-Plan

```
**Update 1:** _projekt.md Zeile "Cora nutzt Gemini 2.0"
→ "Cora nutzt Gemini 2.5 (Stand 2026-04-16, Quelle: Meeting mit Jann)"
Vertrauen: extrahiert

**Widerspruch:** 02-wissen/react-native/expo-sdk.md sagt "SDK 54"
aber Meeting sagt "Upgrade SDK 55 beschlossen"
→ Welche Version aktuell?
```

### Schritt 5 — Deniz entscheidet
Geht durch: "OK, OK, SDK 55 richtig"

### Schritt 6 — Ausführen
Updates gebündelt. Ein Commit:
`abgleich: coralate (3 updates, 1 widerspruch aufgelöst)`

### Schritt 7 — Metadaten
- `_projekt.md` Frontmatter: `zuletzt_abgeglichen: 2026-04-16`
- Wissens-Einträge: `zuletzt_verifiziert: 2026-04-16`

---

## Regeln

- **Nie automatisch.** Plan, OK, dann schreiben.
- **Jedes Update: Begründung + Quelle.**
- **Vertrauens-Stufe setzen.**
- **Datierung erzwingen.**
- **Wissens-Einträge mit-prüfen.**
- **Kein Schneeballeffekt.** Updates in anderen Projekten nur als Vorschlag.
