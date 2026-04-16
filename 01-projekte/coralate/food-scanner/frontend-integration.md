---
typ: aufgabe
name: "Food Scanner Frontend Integration für Jann"
projekt: "[[food-scanner]]"
status: in_arbeit
benoetigte_kapazitaet: hoch
kontext: ["desktop"]
kontakte: ["[[jann-allenberger]]"]
quelle: notion_migration
vertrauen: extrahiert
erstellt: 2026-04-16
---

Frontend-Integration-Spec für Jann (React Native). Backend-Contract ist stabil - Backend-Optimierungen ändern NICHTS an Event-Shape. Details der Backend-Architektur siehe [[architektur-v8]].

## Endpoint

```
POST https://vviutyisqtimicpfqbmi.supabase.co/functions/v1/food-scanner
Content-Type: application/json
Authorization: Bearer <USER_JWT>
apikey: sb_publishable_Lp2zW-Np-SQksog8D5yz2A_yG5E48EW
Accept: text/event-stream

Request: { "storage_path": "f440d7e4-.../1776084050861_6c15f841.jpg" }
          oder { "barcode": "4003239123456" }
```

Bild vor Upload auf **800px Long-Edge + JPEG q0.85** resizen (`expo-image-manipulator`). Größter clientseitiger Latenz-Hebel (~40% Vision-Reduktion).

## SSE Event-Types (in Reihenfolge)

| Event | Wann | Payload | UI-Aktion |
|---|---|---|---|
| `start` | sofort | `{ts, model, cached?}` | Skeleton anzeigen |
| `dish` | ~0.5-1s | `{dish_name, ts}` | Titel setzen |
| `ingredient` | ~1-3s, N-mal | `{index, ingredient, ts}` | Zutat einzeln einfaden |
| `vision_done` | ~2-4s | `{dish_name, ingredient_count, ts}` | Finale Liste-Länge |
| `embed_done` | ~3-5s | `{cache_hits, ts}` | optional |
| `match_done` | ~4-6s | `{ts}` | Makros einträufeln |
| `final` | ~5-7s | full object | Loading aus, Store updaten |
| `error` | irgendwann | `{message, ts}` | Fehler-UI + Retry |

## Ingredient-Shape

```ts
type Ingredient = {
  name: string;                        // english generic, z.B. "chicken breast"
  grams: number;                       // geschätzte Portion
  preparation: string;                 // "grilled" | "raw" | "fried"
  visibility: "visible" | "inferred";  // inferred = erschlossen, nicht im Bild
  matches?: NutritionMatch[];          // kommt erst mit `final`
};

type NutritionMatch = {
  id: number;
  name_en: string;
  source: "USDA_FND" | "USDA_SR" | "BLS" | "COFID" | "OFF";
  similarity: number;
  full_row: {
    enerc_kcal, procnt_g, fat_g, choavl_g, fibtg_g,
    ca_mg, fe_mg, mg_mg, k_mg, na_mg, zn_mg,
    vitc_mg, vitd_ug, vite_mg, vita_rae_ug,
    thia_mg, ribf_mg, nia_mg, vitb6_mg, foldfe_ug
  };
};
```

## ScanResultScreen State Machine

1. `UPLOADING` - Spinner + "Wird hochgeladen..."
2. `SCANNING` - Skeleton-Cards + "Bild wird analysiert..."
3. `DISH_DETECTED` - Header zeigt dish_name (animiert)
4. `INGREDIENTS_LIVE` - Cards poppen einzeln rein wie SSE-Events ankommen
5. `MATCHED` - Cards bekommen kcal-Werte (nach `match_done` Event)
6. `REVIEW` - Buttons: [Bestätigen] [Bearbeiten]
7. `EDITING` - Inline-Editor pro Card (Grams ändern, löschen, hinzufügen)
8. `CONFIRMED` - Success-Animation, zurück zu Food Tab mit aktualisierten Daily Macros

## Komponenten

**ScanResultScreen:**
- Top: Bild-Vorschau (klein, Tap-to-Expand)
- Mitte: Dish-Name (groß, editierbar im Edit-Mode)
- Liste: IngredientCard × N
- Footer: MacrosFooter (sticky)
- Buttons: [Bestätigen] [Bearbeiten] / im Edit [Speichern] [Abbrechen]

**IngredientCard:**
- Icon für visible vs inferred
- Name (groß, editierbar im Edit-Mode)
- Preparation (klein darunter)
- Grams (rechts, editierbar)
- kcal (klein, recalced live)
- Match-Source (ganz klein, Debug)
- Löschen-Button (nur im Edit-Mode)

**MacrosFooter:** sticky am unteren Bildschirmrand, Live-Update bei Grams-Änderung.

## Streaming-Integration

```ts
import { fetch } from 'expo/fetch'; // unterstützt ReadableStream

async function startScan(
  storagePath: string,
  jwt: string,
  onEvent: (e: { type: string; data: any }) => void
) {
  const response = await fetch(
    'https://vviutyisqtimicpfqbmi.supabase.co/functions/v1/food-scanner',
    {
      method: 'POST',
      headers: {
        'apikey': 'sb_publishable_Lp2zW-Np-SQksog8D5yz2A_yG5E48EW',
        'Authorization': `Bearer ${jwt}`,
        'Content-Type': 'application/json',
        'Accept': 'text/event-stream'
      },
      body: JSON.stringify({ storage_path: storagePath })
    }
  );

  const reader = response.body.getReader();
  const decoder = new TextDecoder();
  let buf = '', currentEvent = null;

  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    buf += decoder.decode(value, { stream: true });
    const lines = buf.split('\n');
    buf = lines.pop() ?? '';
    for (const line of lines) {
      if (line.startsWith('event: ')) {
        currentEvent = line.slice(7).trim();
      } else if (line.startsWith('data: ') && currentEvent) {
        try {
          const data = JSON.parse(line.slice(6));
          onEvent({ type: currentEvent, data });
        } catch {}
        currentEvent = null;
      }
    }
  }
}
```

## Confirm-Call

```ts
async function confirmScan(
  scanId: string,
  jwt: string,
  corrections: EnrichedIngredient[] | null
) {
  const response = await fetch(
    'https://vviutyisqtimicpfqbmi.supabase.co/functions/v1/food-scan-confirm',
    {
      method: 'POST',
      headers: {
        'apikey': 'sb_publishable_...',
        'Authorization': `Bearer ${jwt}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        scan_id: scanId,
        user_corrected: corrections !== null,
        user_corrections: corrections
      })
    }
  );
  return response.json();
}
```

## Recalc bei Grams-Änderung (MUSS Frontend machen)

```ts
function recalcNutrients(ing: EnrichedIngredient, newGrams: number): EnrichedIngredient {
  if (!ing.matches?.[0]?.per_100g) return ing;
  const factor = newGrams / 100;
  const newNutrients: Record<string, number> = {};
  for (const [k, v] of Object.entries(ing.matches[0].per_100g)) {
    newNutrients[k] = Number((Number(v) * factor).toFixed(3));
  }
  return {
    ...ing,
    grams: newGrams,
    per_ingredient_nutrients: newNutrients
  };
}
```

## Error Handling

| Code | Ursache | Aktion |
|---|---|---|
| 401 | JWT expired | Refresh Token, retry |
| 403 | Storage Path enthält andere User-ID | Bug, an Backend melden |
| 404 | Scan nicht gefunden beim Confirm | Cache stale, neu scannen |
| 409 | Scan ist bereits failed | User-Hinweis "Scan fehlgeschlagen, bitte neu scannen" |
| SSE event=error | Vision Pipeline failed | Error UI mit Retry-Button |
| Network Loss mid-stream | Stream-Reader wirft Error | Polling-Fallback auf `/rest/v1/food_scan_log?id=eq.X&select=*` bis Status nicht mehr `processing` |

## Screens und Flow

Food Tab → Plus Button → Action Sheet:
- Foto aufnehmen → Camera → ScanResultScreen (Live-Streaming)
- Aus Galerie → ImagePicker → ScanResultScreen (Live-Streaming)
- Barcode scannen → BarcodeScanner → ScanResultScreen (instant)
- Manuell → ManualEntryScreen (out of scope hier)
