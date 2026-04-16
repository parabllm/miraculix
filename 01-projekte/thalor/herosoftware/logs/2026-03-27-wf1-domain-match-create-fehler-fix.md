---
typ: log
projekt: "[[herosoftware]]"
datum: 2026-03-27
art: fehler_fix
vertrauen: extrahiert
quelle: chat_session
werkzeuge: ["n8n", "attio", "mantle"]
---

WF1 Bugfix-Session. Domain-Match und Create-Fehler behoben. WF1 Flow-Diagramm aktualisiert auf ~23 Nodes.

## Matching-Kette final (3-stufig + Create)

1. **Shopify URL Match** - `shopify_url $contains [shopifyDomain]` → direkt Update
2. **Domain Match** - `domains $contains [match_domain]` → Dup-Check → Update + `shopify_url` setzen
3. **Name Match** - `name $contains [match_name]` (≥4 Zeichen, genau 1 Treffer, nicht generisch) → Dup-Check → Update + `shopify_url` setzen
4. **Kein Match** → Create New Company

## Kritische Erkenntnisse

- **Domain bei PATCH mitschreiben** (Shopify-URL-Match + Name-Match)
- `domains: []` bei PATCH = **keine Änderung** (nicht: Domain löschen) - Attio-API-Quirk
- **`.myshopify.com` Domains** aus Match ausschließen (keine echten Custom-Domains)
- **Create-Fallback: nie auf `statusCode` prüfen, IMMER alle 3 Versuche laufen lassen**
- **Wait 15s** (nicht 1.5s), dann Fetch mit Retry 3×5s - Mantle braucht Zeit für Dateneinlauf
- **404 bei Mantle-Fetch auch nach 15s möglich** → Retry-Logic nötig

## Mantle API

- Auth ist **Bearer Token** (nicht App-Id/Api-Key Header)

## Testing-Regeln

- Pin-Data nur bei inaktivem WF
- Nie ab mittlerer Node restarten
- Test-Webhook nur nach "Test Workflow"-Klick

## Activity Notes

WF1 Node 17 schreibt Activity Notes direkt nach Attio. Deshalb kein separater WF6 nötig.

## Quelle

Claude-Chat "WF1 Domain-Match und Create-Fehler beheben", 101 Messages, 282k Zeichen.
