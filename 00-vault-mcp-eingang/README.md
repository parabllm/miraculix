---
typ: system-marker
erstellt: 2026-04-29
zuletzt_aktualisiert: 2026-04-29
vertrauen: extrahiert
quelle: vault-mcp-architektur-spec
---

# Vault-MCP-Eingang

Drop-Zone fuer Artefakte von Mobile-Claude via Custom Vault-MCP auf Hetzner.

## Wer schreibt hier rein

Nur der Vault-MCP-Server auf `miraculix.thalor.de` darf Dateien in diesen Ordner legen. Mobile-Claude erstellt Artefakte ueber die Tools `vault_create_artefakt` und `vault_update_artefakt`. Die Dateien landen via Syncthing am PC.

## Wer verarbeitet

PC-Claude liest Artefakte hier, prueft Header, Hashes, Pfade und Wikilinks, zeigt Dry-Run plus OK-Frage und merged dann in den fachlichen Vault.

## Filename-Pattern

`YYYY-MM-DD-HHMM-{kurzes-thema}-{aktion}.md`

Aktionen: `neue-datei`, `ergaenzung`, `ersetzen-sektion`.

## Nach dem Merge

Verarbeitete Artefakte wandern nach `05-archiv/vault-mcp-eingang-verarbeitet/YYYY-MM/`.

## Spec

Volle Architektur, Trust-Modell, Header-Schema und Merge-Regeln in [[vault-mcp-architektur]].
