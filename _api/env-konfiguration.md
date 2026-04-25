# Env-Konfiguration

Doku zur `.env` im `_api/` Ordner. Enthält API-Keys für lokale Skripte und Workflows die Claude über Desktop Commander oder Claude Code aufruft.

## Speicherorte

- `.env`: `C:\Users\deniz\Documents\miraculix\_api\.env`. Echte Werte. NICHT committed (über `.gitignore` geblockt, gesamter `_api/` Ordner ignoriert).
- `.env.example`: `C:\Users\deniz\Documents\miraculix\_api\.env.example`. Template ohne Werte. Committed (whitelist).
- Diese Doku: `_api/env-konfiguration.md`. Committed (whitelist für `.md`-Files in `_api/`).

## Variablen-Übersicht

| Variable | Status | Verwendung |
|---|---|---|
| ANTHROPIC_API_KEY | leer | Claude API Direktzugriff (z.B. eigene Wrapper, Skripte) |
| OPENAI_API_KEY | leer | OpenAI API (GPT, Whisper falls genutzt) |
| GEMINI_API_KEY | leer | Google Gemini API (z.B. Coralate Vertex-Alternative) |
| MISTRAL_API_KEY | leer | Mistral API |
| ELEVENLABS_API_KEY | gefüllt | ElevenLabs Scribe Transkription, Voice Generation |

Status-Update-Regel: Nach jedem Eintrag eines neuen Werts in `.env` muss diese Tabelle nachgezogen werden. Spalte Status auf `gefüllt` setzen.

## Format der `.env`

```
ANTHROPIC_API_KEY=
OPENAI_API_KEY=
GEMINI_API_KEY=
MISTRAL_API_KEY=
ELEVENLABS_API_KEY=
```

Werte ohne Anführungszeichen. Keine Spaces um das `=`.

## Sicherheits-Regeln

1. `.env` nie committen. `.gitignore` ignoriert den gesamten `_api/` Ordner mit Whitelist nur für `.env.example` und `.md`-Files.
2. Keys nie im Klartext in Skripten, Logs oder Vault-Dateien außerhalb der `.env`.
3. Bei Verdacht auf Leak: Key beim Provider rotieren, alten Key in `.env` ersetzen, Status-Tabelle hier prüfen.
4. Beim Anlegen eines neuen Keys hier Eintrag ergänzen, in `.env` und `.env.example` Variable anlegen, Status-Tabelle pflegen.

## Nutzung in Skripten

Python (mit `python-dotenv`):

```python
from dotenv import load_dotenv
import os
from pathlib import Path

# .env explizit aus _api/ laden
env_path = Path(__file__).parent.parent / "_api" / ".env"
load_dotenv(dotenv_path=env_path)

api_key = os.getenv("ELEVENLABS_API_KEY")
```

PowerShell:

```powershell
$envPath = Join-Path $PSScriptRoot "..\_api\.env"
Get-Content $envPath | ForEach-Object {
    if ($_ -match '^([^=]+)=(.*)$') {
        [Environment]::SetEnvironmentVariable($matches[1], $matches[2], 'Process')
    }
}
$key = $env:ELEVENLABS_API_KEY
```

Skripte liegen in `_claude/scripts/` und laden die `.env` aus `_api/` (Vault-Root + `_api/`).

## Verwandte Dateien

- `.gitignore` im Vault-Root (Sektion API-Ordner)
- `_claude/skills/vault-system.md` (Skripte und Secrets Sektion)
- `_claude/scripts/` (Skripte die diese Keys nutzen)
- `_api/.env`, `_api/.env.example` (Werte und Template)
