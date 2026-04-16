---
typ: aufgabe
name: "Skript lgm-status-sync.mjs (LGM → Attio)"
projekt: "[[herosoftware]]"
status: erledigt
benoetigte_kapazitaet: mittel
kontext: ["desktop"]
kontakte: []
quelle: notion_migration
vertrauen: extrahiert
erstellt: 2026-04-16
---

Status-Rückkanal. Pollt alle LGM Audiences global (auch manuell per CSV importierte Leads), holt aktuellen Status pro Lead, synchronisiert zurück nach Attio (Person + Company). Ersetzt n8n WF3.

## Architektur

- **Speicherort:** `/opt/hero/lgm-status-sync.mjs` (Hetzner) + lokal bei Deniz
- **Cron:** `0 12 * * *` (täglich 12:00 Berlin)
- **Quelle:** LGM (alle Audiences global, paginiert)
- **Ziel:** Attio People + Companies (Status-Felder)
- **Ersetzt:** n8n WF3 (`6AQLwz2IWIkbOMCd`, noch als Backup in n8n Cloud)

## Zwei-Phasen-Modell

### Phase 1 - Collect

1. `GET /audiences` - alle Audiences holen (Response-Format: `res.audiences`, NICHT `res.data`)
2. Pro Audience: `GET /flow/audiences/{id}/leads?limit=100&skip=0` paginiert (max limit=100, Pagination via skip)
3. Alle Leads aus allen Audiences in Map sammeln
4. **Dedupliziert nach Email** - bei Lead in mehreren Audiences: jüngsten Status

### Phase 2 - Sync

Pro Lead:
1. **LGM Status holen:** Tag oder Status aus Lead-Objekt
2. **Tag hat Vorrang.** Bei Tag `TO_QUALIFY`: Fallback auf `status`-Feld (Kategorie)
3. **Attio Person finden** via Email-Match
4. **Vergleichen:** wenn Status gleich → Skip (spart Writes)
5. **Update bei Änderung:** PATCH auf Person mit neuem `sequence_status`
6. **`contacted_at` setzen** wenn noch leer und Status >= Contacted
7. **Bei Reply oder Won:** Company `outbound_status_2` updaten + Task für Robin in Attio anlegen

## LGM → Attio Status Mapping

### LGM Tag → Attio `sequence_status`

| LGM tag | → Attio |
|---|---|
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

### LGM Status → Attio Fallback (nur wenn Tag = TO_QUALIFY)

| LGM status | → Attio |
|---|---|
| REPLIED | Replied |
| WON | Interested |
| LOST | Not Interested |

## Datenfeld-Konventionen (kritisch)

- **Attio Select-Werte case-sensitive:** "Ready to Buy" nicht "Ready To Buy", "Out of Office" nicht "Out Of Office"
- **`contacted_at`:** wird nur gesetzt wenn vorher leer UND Status >= Contacted (kein Überschreiben älterer Daten)
- **Email-Match in Attio:** via `email_addresses.$contains` (case-insensitive)

## Retry & Performance

- 3x Retry pro API-Call bei `429`/`500`
- Skip wenn keine Änderung (spart Writes, wichtig wegen Rate-Limit)
- 300ms Pause zwischen Lead-Updates

## Edge Cases

- **Lead nicht in Attio gefunden:** Skip mit Log (kann passieren wenn Robin jemanden manuell in LGM importiert der nicht in Attio existiert)
- **Mehrere Attio-Personen mit gleicher Email:** nimm die erste, log Warning
- **LGM Reply ohne Inhalt:** Status wird trotzdem gesynct, kein Note-Eintrag
- **Status seit letztem Lauf nicht geändert:** komplett übersprungen (kein Read-Only-PATCH)

## Bekannte LGM API-Bugs (workaround drin)

- `GET /audiences` - Response-Format `{ audiences: [...] }`, NICHT `{ data: [...] }`
- `GET /flow/audiences/{id}/leads` - max limit=100, Pagination via skip

## Logging

Log enthält: gepollte Audiences, unique Leads, Updates, Skips (no change), Reply-Notifications.
