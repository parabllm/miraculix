# Skript: lgm-status-sync.mjs (LGM → Attio)

Created: 9. April 2026 11:34
Doc ID: DOC-39
Doc Type: Workflow Spec
Gelöscht: No
Last Edited: 9. April 2026 11:34
Lifecycle: Active
Notes: lgm-status-sync.mjs: täglich 12 Uhr, holt LGM Status global über alle Audiences und synct nach Attio. Ersetzt n8n WF3. Phase 1: Collect (alle Audiences paginiert, dedupliziert nach Email). Phase 2: Sync (Tag-Vorrang, Fallback auf status, Reply→Company-Update + Robin-Task). LGM Audiences API: res.audiences NICHT http://res.data.
Pattern Tags: Sync
Project: HeroSoftware (../Projects/HeroSoftware%2033d91df4938681a8af4cf625b0b2f0cb.md)
Stability: Stable
Stack: Attio, LGM, Python
Verified: No

## Scope

`lgm-status-sync.mjs` ist das Status-Rückkanal-Skript. Es pollt alle LGM Audiences global (auch manuell per CSV importierte Leads), holt den aktuellen Status pro Lead und synchronisiert ihn zurück nach Attio (Person + Company). Ersetzt das frühere n8n WF3.

## Architecture / Constitution

- **Speicherort:** `/opt/hero/lgm-status-sync.mjs` (Hetzner) + lokal bei Deniz
- **Cron:** `0 12 * * *` (täglich 12:00 Uhr Berlin-Zeit)
- **Quelle:** LGM (alle Audiences global, paginiert)
- **Ziel:** Attio People + Companies (Status-Felder)
- **Ersetzt:** n8n WF3 (`6AQLwz2IWIkbOMCd`, noch in n8n Cloud als Backup vorhanden)

## Logik (Zwei-Phasen-Modell)

### Phase 1 — Collect

1. `GET /audiences` — alle Audiences holen (Response-Format: `res.audiences`, NICHT `res.data`)
2. Pro Audience: `GET /flow/audiences/{id}/leads?limit=100&skip=0` paginiert (max `limit=100`, Pagination via `skip`)
3. Alle Leads aus allen Audiences in einer Map sammeln
4. **Dedupliziert nach Email** — wenn ein Lead in mehreren Audiences ist, nehme den jüngsten Status

### Phase 2 — Sync

Pro Lead:

1. **LGM Status holen:** Tag oder Status aus dem Lead-Objekt
2. **Tag hat Vorrang.** Bei Tag `TO_QUALIFY`: Fallback auf das `status`-Feld (Kategorie)
3. **Attio Person finden** via Email-Match
4. **Vergleichen:** wenn Status gleich → Skip (spart Writes)
5. **Update bei Änderung:** PATCH auf Person mit neuem `sequence_status`
6. **`contacted_at` setzen** wenn noch leer und Status >= Contacted
7. **Bei Reply oder Won:** Company `outbound_status_2` updaten + Task für Robin in Attio anlegen

## LGM → Attio Status Mapping

### LGM Tag → Attio `sequence_status`

| LGM tag | → Attio |
| --- | --- |
| NOT_ACTIVATED | Not Activated |
| STARTED | Started |
| ENRICHED | Enriched |
| CONTACTED | Contacted |
| COMPLETED_NO_REPLY | Completed: No Reply |
| OUT_OF_OFFICE | Out of Office |
| TO_QUALIFY | → Fallback auf status-Feld |
| REPLIED | Replied |
| WRONG_TIMING | Wrong Timing |
| INTERESTED | Interested |
| CALL_BOOKED | Call Booked |
| NEGOTIATING | Negotiating |
| READY_TO_BUY | Ready to Buy |
| CONVERTED | Converted |
| NOT_INTERESTED | Not Interested |
| WRONG_TARGET | Wrong Target |
| ALREADY_EQUIPPED | Already Equipped |
| CANNOT_CONTACT | Cannot Contact |

### LGM Status (Kategorie) → Attio Fallback (nur wenn Tag = TO_QUALIFY)

| LGM status | → Attio |
| --- | --- |
| REPLIED | Replied |
| WON | Interested |
| LOST | Not Interested |

## Datenfeld-Konventionen (kritisch)

- **Attio Select-Werte sind Case-sensitive:** "Ready to Buy" nicht "Ready To Buy", "Out of Office" nicht "Out Of Office"
- **`contacted_at`:** wird nur gesetzt wenn vorher leer war UND Status >= Contacted (kein Überschreiben älterer Daten)
- **Email-Match in Attio:** via `email_addresses.$contains` (case-insensitive seitens Attio)

## Retry & Performance

- 3x Retry pro API-Call bei `429`/`500`
- Skip wenn keine Änderung (spart Writes — wichtig wegen Rate-Limit)
- 300ms Pause zwischen Lead-Updates

## Edge Cases

- **Lead nicht in Attio gefunden:** Skip mit Log (kann passieren wenn Robin manuell jemanden in LGM importiert hat der nicht in Attio existiert)
- **Mehrere Attio-Personen mit gleicher Email:** nehme die erste, log Warning
- **LGM Reply ohne Inhalt:** Status wird trotzdem gesynct, kein Note-Eintrag
- **Status hat sich seit letztem Lauf nicht geändert:** Komplett übersprungen (kein Read-Only-PATCH)

## Bekannte LGM API-Bugs (workaround drin)

- `GET /audiences` — Response-Format `{ audiences: [...] }`, NICHT `{ data: [...] }`
- `GET /flow/audiences/{id}/leads` — max `limit=100`, Pagination via `skip`

## Logging

```
0 12 * * * cd /opt/hero && node lgm-status-sync.mjs >> /var/log/hero/lgm-status.log 2>&1
```

Log enthält: Anzahl gepollte Audiences, Anzahl unique Leads, Anzahl gemachte Updates, Anzahl Skips (no change), Anzahl Reply-Notifications.

## Open Questions

- Sollten Replied-Notifications zusätzlich per Slack gepostet werden? (→ separater Task `WF Error Slack` deckt das ab, dort kann auch Reply-Push rein)