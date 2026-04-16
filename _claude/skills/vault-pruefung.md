# Vault-Prüfung Skill (Lint / Audit)

**Trigger:** "vault prüfen", "lint", "konsistenz check", "ist alles aktuell?"

Zweck: Probleme finden. Bericht liefern. Deniz entscheidet was passiert.

---

## Prüf-Kategorien

### 1. Veraltete Informationen
- Files mit `vertrauen: angenommen` älter als 4 Wochen → "Prüfung nötig"
- Wissens-Einträge mit `zuletzt_verifiziert` älter als 8 Wochen
- Projekte ohne Log seit 14+ Tagen → "möglicherweise inaktiv"
- Aufgaben `status: offen` mit `faellig` in Vergangenheit → "überfällig"

### 2. Widersprüche
- Gleiche Fakten, verschiedene Werte
- Projekte `status: aktiv` aber alle Aufgaben `erledigt`
- Kontakte in Projekt-Frontmatter ohne eigenes File

### 3. Struktur
- Files ohne Frontmatter / Pflichtfelder fehlen
- Kaputte Wikilinks
- Verwaiste Files
- Leere Ordner
- Inbox-Items `unverarbeitet` älter als 7 Tage

### 4. Duplikate
- Ähnliche Titel in verschiedenen Ordnern
- Gleiche Info in Projekt-File UND Wissens-File

### 5. Skill-Drift
Entity-Tabellen in `vault-system.md` werden manuell gepflegt, können veralten.

Prüfe:
- Jedes Über-Projekt in Skill-Tabelle auch als Ordner in `01-projekte/`?
- Ordner in `01-projekte/` die nicht in Skill stehen?
- Jede Wissens-Domain in Skill auch als Ordner in `02-wissen/`?
- Ordner in `02-wissen/` die nicht in Skill stehen?

Bei Drift: Diff zeigen. Bei Bestätigung → Skill updaten + erinnern dass neue Version ins Claude Desktop UI hochgeladen werden muss.

---

## Ausgabe

```
## Vault-Prüfung — [Datum]

### Veraltet (X)
- ⚠️ `02-wissen/n8n/webhook-pattern.md` — zuletzt verifiziert vor 9 Wochen

### Widersprüche (X)
- ❌ `coralate/_projekt.md` "SDK 54" vs `02-wissen/react-native/expo-sdk.md` "SDK 55"

### Struktur (X)
- 📋 `01-projekte/thalor/resolvia/` — kein `_projekt.md`
- 🔗 Kaputter Link: `[[robin-kronshagen]]` in herosoftware/_projekt.md

### Duplikate (X)
- 📄 n8n Race-Condition in logs/2026-03-12.md UND 02-wissen/n8n/race-condition.md

### Eingang (X)
- 📥 3 Items seit 5+ Tagen unverarbeitet

### Skill-Drift (X)
- 🔄 `thalor/pulsepeptides/` existiert als Sub-Projekt, steht aber nicht in Skill
```

---

## Regeln

- **Nur berichten, nicht automatisch fixen.** Deniz entscheidet pro Fund.
- **Priorisierung:** Widersprüche > Skill-Drift > Veraltet > Struktur > Duplikate > Eingang
- **Nur bei Trigger** oder als Teil vom Weekly Review.
- **Bei großen Vaults:** Scope. "vault prüfen hays" = nur HAYS.
