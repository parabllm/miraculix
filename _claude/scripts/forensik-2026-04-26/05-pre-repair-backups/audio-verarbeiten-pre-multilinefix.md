---
name: miraculix-audio-verarbeiten
description: Triggered when Deniz says "audio verarbeiten", "transkribiere die audio", "transkribiere audio aus eingang", or when called from miraculix-eingang-verarbeiten with an audio file. Converts audio (any format) to MP3 via ffmpeg, archives MP3 in _anhaenge/audio-files/, calls transcribe.py to generate transcript via ElevenLabs Scribe v2, places transcript in 00-eingang/transkripte/. After successful transcription, asks if Deniz wants to chain into transkript-verarbeiten.
---

# Audio-Verarbeiten

Audio aus Eingang konvertieren, archivieren und transkribieren.

## Trigger

- Deniz sagt "audio verarbeiten", "transkribiere die audio", "transkribiere audio aus eingang"
- Aufruf aus `miraculix-eingang-verarbeiten` wenn Audio-Files in `00-eingang/audio/` gefunden wurden

## Voraussetzungen

Prüfe vor dem ersten Schritt ob alles bereit ist:

- ffmpeg im PATH: `ffmpeg -version` muss antworten. Falls nicht: `winget install Gyan.FFmpeg` und PowerShell neu starten.
- Python installiert: `python --version` muss 3.x zeigen.
- `ELEVENLABS_API_KEY` in `_api/.env` gesetzt (nicht leer). Prüfe via `_api/env-konfiguration.md`.
- `00-eingang/audio/` existiert.
- `_anhaenge/audio-files/` existiert (hat `.gitkeep`).
- `_claude/scripts/transcribe.py` existiert.

Bei fehlendem Voraussetzung: Meldung an Deniz mit konkretem Fix, kein Weitermachen.

## Schritte

### Schritt 1 - Eingang prüfen

Liste alle Files in `00-eingang/audio/` (ignoriere `.gitkeep`).

Falls leer:
> Keine Audio im Eingang.

Skill beendet.

Falls Files vorhanden: zeige pro File Filename und Dateigröße in MB.

Beispiel:
```
[Eingang Audio]
1. kalani-call.m4a (24.3 MB)
2. meeting-notiz.m4a (8.7 MB)
```

### Schritt 2 - Slug abfragen

Pro File: frage Deniz nach Slug.

Slug-Regeln:
- Nur lowercase Buchstaben, Ziffern, Bindestriche
- Kein Leerzeichen, keine Umlaute, keine Sonderzeichen
- Format: `{kontext}-{datum}` oder `{person}-{kontext}-{datum}`
- Beispiele: `kalani-call-2026-04-25`, `standup-herosoftware-2026-04-25`, `notiz-2026-04-25`

Bei mehreren Files: Slugs für alle abfragen, dann erst ausführen.

### Schritt 3 - Transkription ausführen

Pro File: rufe das Skript auf. Working Directory muss Vault-Root sein.

```
python _claude/scripts/transcribe.py "00-eingang/audio/{filename}" --slug "{slug}"
```

Optional mit Sprache wenn bekannt:
```
python _claude/scripts/transcribe.py "00-eingang/audio/{filename}" --slug "{slug}" --language de
```

Lese stdout: das Skript gibt `[OK]` und `[ERROR]` Zeilen aus.

### Schritt 4 - Ergebnis reporten

Nach erfolgreichem Lauf:

```
[Audio verarbeitet]
- MP3: _anhaenge/audio-files/{slug}.mp3
- Transkript: 00-eingang/transkripte/{slug}.md
- Sprache: de (94%), Sprecher: 2, Dauer: 28:14
```

### Schritt 5 - Chain-Frage

Nach allen Files fragen:

> Transkript direkt verarbeiten und in Meeting-Note einsortieren? (Skill miraculix-transkript-verarbeiten)

Bei Ja: Skill `miraculix-transkript-verarbeiten` aufrufen.
Bei Nein: Skill beendet. Deniz kann später "transkript verarbeiten" sagen.

## Fehler-Handling

| Fehler | Ursache | Fix |
|---|---|---|
| `[ERROR] ffmpeg nicht im PATH` | ffmpeg nicht installiert oder PATH fehlt | `winget install Gyan.FFmpeg`, PowerShell neu |
| `[ERROR] ELEVENLABS_API_KEY nicht gesetzt` | Key fehlt in `_api/.env` | Key eintragen, `_api/env-konfiguration.md` als Referenz |
| `[ERROR] Audio-File nicht gefunden` | Falscher Pfad oder File fehlt | Pfad prüfen, File in `00-eingang/audio/` sicherstellen |
| `[ERROR] Output-File existiert bereits` | Slug schon benutzt | Anderen Slug wählen |
| `[ERROR] ElevenLabs API-Fehler: HTTP 401` | API-Key ungültig oder abgelaufen | Key beim ElevenLabs-Account prüfen und erneuern |
| `[ERROR] ElevenLabs API-Fehler: HTTP 429` | Rate Limit | Warten, dann nochmal versuchen |

Bei jedem Fehler: Meldung an Deniz, Skill stoppt. Kein automatischer Retry.

## Regeln

- Kein Auto-Commit nach Transkription (Deniz hat Auto-Push-Hook, aber nur für committed Files).
- Kein Auto-Chain in `transkript-verarbeiten` ohne Bestätigung von Deniz.
- Bei mehreren Audio-Files: erst alle Slugs abfragen, dann Batch ausführen.
- MP3-Files und Transkript-Files nie manuell editieren oder löschen ohne Deniz-OK.
- Transkripte landen in `00-eingang/transkripte/`, nicht direkt in Projekt-Ordnern.

## Vault-Writes

Vor jedem .md-Write Pflicht-Lektuere:
- [[vault-schreibkonventionen]] - WAS rein (Encoding, Umlaute, Naming, Gedankenstriche)
- [[vault-schreibregeln]] - WIE schreiben (Tools, Rollback, Bug-Patterns)

Kernregeln:
- NIE Desktop Commander `write_file` oder `edit_block` fuer .md mit YAML-Frontmatter
- Hex-Verify Pflicht nach jedem Write (erste 8 Bytes muessen `2D 2D 2D 0A` plus YAML-Key sein)
