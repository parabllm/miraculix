# Food Scanner — Frontend Integration Spec fuer Jann (v1)

Created: 12. April 2026 18:48
Doc ID: DOC-58
Doc Type: Integration Guide
Gelöscht: No
Last Edited: 12. April 2026 22:50
Last Reviewed: 12. April 2026
Lifecycle: Deprecated
Notes: Frontend-Integrationsspec fuer Jann. Backend-Contract stabil. Enthaelt SSE-Eventtypen, Expo/RN Code-Beispiele, Zustand-Store-Pattern, UI-States, Error-Handling. Backend-Optimierungen sind transparent fuer das Frontend.
Stability: Stable
Stack: Supabase
Verified: Yes

# Fuer Jann

Backend-Contract ist stabil, du kannst gegen diese API coden. Backend-Optimierungen (Match-Qualitaet, Model-Wechsel, Retention-Faktoren) aendern NICHTS an der Event-Shape.

# 1. Endpoint

```
POST https://vviutyisqtimicpfqbmi.supabase.co/functions/v1/food-scanner-gemini
Content-Type: application/json
Authorization: Bearer <anon_key>
Response: text/event-stream (SSE)
```

**Request:**

```json
{ "image_base64": "...", "mime_type": "image/jpeg" }
```

Bild vor Upload auf **800px Long-Edge + JPEG q80** resizen (`expo-image-manipulator`). Groesster clientseitiger Latenz-Hebel (~40% Vision-Reduktion).

# 2. SSE Event-Types (in Reihenfolge)

Alle Events haben `ts` (ms seit Request-Start).

| Event | Wann | Payload | UI-Aktion |
| --- | --- | --- | --- |
| `start` | sofort | `{ts, model}` | Skeleton anzeigen |
| `dish` | ~0.5-1s | `{dish_name, ts}` | Titel setzen |
| `ingredient` | ~1-3s, N-mal | `{index, ingredient, ts}` | Zutat einzeln einfaden |
| `vision_done` | ~2-4s | `{dish_name, ingredient_count, ts}` | Finale Liste-Laenge |
| `embed_done` | ~3-5s | `{cache_hits, ts}` | optional |
| `match_done` | ~4-6s | `{ts}` | Makros eintraeufeln |
| `final` | ~5-7s | full object | Loading aus, Store updaten |
| `error` | irgendwann | `{message, ts}` | Fehler-UI + Retry |

## Ingredient-Shape

```tsx
type Ingredient = {
  name: string;                        // english generic, z.B. "chicken breast"
  grams: number;                       // geschaetzte Portion
  preparation: string;                 // "grilled" | "raw" | "fried" etc.
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
    thia_mg, ribf_mg, nia_mg, vitb6_mg, foldfe_ug,
    // ...weitere Mikros
  };
};
```

# 3. Expo/React Native

## SSE Client

React Native hat kein natives `EventSource`. `react-native-sse` nutzen:

```bash
npx expo install react-native-sse
```

```tsx
import EventSource from 'react-native-sse';
import * as ImageManipulator from 'expo-image-manipulator';

async function scanFood(imageUri: string, onEvent: (ev: any) => void) {
  const resized = await ImageManipulator.manipulateAsync(
    imageUri,
    [{ resize: { width: 800 } }],
    { compress: 0.8, format: ImageManipulator.SaveFormat.JPEG, base64: true }
  );

  const es = new EventSource(`${SUPABASE_URL}/functions/v1/food-scanner-gemini`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${ANON_KEY}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ image_base64: resized.base64, mime_type: 'image/jpeg' }),
  });

  const events = ['start','dish','ingredient','vision_done','embed_done','match_done','final','error'];
  events.forEach(type => es.addEventListener(type, (e) => {
    onEvent({ type, data: JSON.parse(e.data) });
    if (type === 'final' || type === 'error') es.close();
  }));

  return es;
}
```

## Zustand Store

```tsx
interface FoodScannerState {
  status: 'idle' | 'scanning' | 'done' | 'error';
  dishName: string | null;
  ingredients: Ingredient[];
  matches: Record<number, NutritionMatch[]>;
  totalLatencyMs: number | null;
  firstIngredientMs: number | null;
  error: string | null;
}

const useFoodScannerStore = create<FoodScannerState & Actions>((set) => ({
  status: 'idle', dishName: null, ingredients: [], matches: {},
  totalLatencyMs: null, firstIngredientMs: null, error: null,

  handleSSE: (event) => {
    switch (event.type) {
      case 'start':
        set({ status: 'scanning', ingredients: [], matches: {}, dishName: null, error: null });
        break;
      case 'dish':
        set({ dishName: event.data.dish_name });
        break;
      case 'ingredient':
        set((s) => ({
          ingredients: [...s.ingredients, event.data.ingredient],
          firstIngredientMs: s.firstIngredientMs ?? event.data.ts,
        }));
        break;
      case 'final':
        const matchMap = event.data.ingredients.reduce((acc, ing, i) => {
          acc[i] = ing.matches || []; return acc;
        }, {});
        set({ status: 'done', matches: matchMap, totalLatencyMs: event.data.total_latency_ms });
        break;
      case 'error':
        set({ status: 'error', error: event.data.message });
        break;
    }
  },
}));
```

# 4. UI-Pattern

## Streaming-List

- Zutaten **einzeln** einfaden per `ingredient`-Event
- `Animated.View` + `FadeIn` (react-native-reanimated), ~200ms
- Waehrend Scanning: nur Name + Gramm + Prep. **Keine Makros bis `match_done`**
- Nach `match_done`: Makros einfaerben (zweite Animation)

## Visibility-Indicator

- `visible`: kein Indicator
- `inferred`: dezentes Badge "geschaetzt" oder ✧ — User muss verstehen dass es nicht im Bild war

## Loading-States

- **0-500ms**: Full-Skeleton (Foto + Titel-Platzhalter + 3 Zeilen-Platzhalter)
- **500ms → first-ingredient**: Titel da, Skeleton noch
- **first-ingredient → match_done**: Liste waechst, Makros grau
- **post-final**: finaler State

## Error-Handling

- SSE-Timeout: nach 30s ohne Event abbrechen, Retry-Button
- `error`-Event: message anzeigen, Retry
- `final` ohne `ingredient`-Events: "Keine Zutaten erkannt"

# 5. Was noch nicht final ist (transparent fuer dich)

1. **Match-Qualitaet**: pgvector matcht manchmal falsche Items ("burger bun" → "Tofu burger"). Wird gefixt via food_group-Filter + source_ranking. `full_row`-Shape bleibt identisch.
2. **`confidence_score`** kommt als zusaetzliches Feld pro Ingredient. Wenn <0.7 → unsicher-Badge anzeigen. **Additives Feld, nicht breaking.**
3. **Retention-Faktoren (Bognaer)** reduzieren Grammaturen bei gekochten Zutaten. Nur Werte, nicht Struktur.
4. **Model-Wechsel moeglich** (Qwen3.5-VL, Vertex AI fuer GDPR). Event-Shape bleibt identisch.

# 6. Test

- **HTML-Test-Tool v4** bei Deniz als Referenz-Implementation der SSE-Logic
- **food-scanner (v7)** laeuft parallel als Fallback
- **pg_cron Keepalive** aktiv, Worker ist unter Normallast warm

# 7. Latenz-Erwartung

- **Time-to-first-ingredient**: <2s target, aktuell ~1-1.5s gemessen
- **Time-to-complete**: 3-6s, sinkend
- **Kein Progress-Percentage anzeigen** — zu schnell, verwirrt. Skeleton + fade-in reicht.

# 8. Kontakt

Backend-Issues (falsche Matches, Latenz-Spikes) mit konkretem Scan-Beispiel an Deniz. Frontend-Fragen direkt.

# 9. Zweiter Endpoint — User Confirm (neu)

Nach erfolgreichem Scan zeigst du dem User die Ergebnisse. Er kann Mengen korrigieren, Zutaten loeschen, hinzufuegen. Tippt er "Speichern", rufst du einen zweiten Endpoint:

```
POST https://vviutyisqtimicpfqbmi.supabase.co/functions/v1/food-scan-confirm
Authorization: Bearer <user_jwt>
Content-Type: application/json
```

**Request:**

```json
{
  "image_base64": "...",           // dasselbe komprimierte Bild vom Scan
  "mime_type": "image/jpeg",
  "dish_name": "Burger",
  "ingredients": [...],              // Original aus scanner
  "user_corrections": [...],          // mit User-Aenderungen
  "user_corrected": true,
  "model_version": "v7-inferred-context",  // aus scanner final-event
  "scan_latency_ms": 4432
}
```

**Response:**

```json
{
  "scan_id": "uuid",
  "image_url": "https://.../food-scans/.../file.jpg",
  "totals": { "kcal": 1040, "protein": 52.3, "carbs": 110.1, "fat": 38.4 }
}
```

**Wichtig:**

- JWT muss echter User-JWT sein (nicht anon), Function extrahiert user_id via `auth.getUser(token)`
- Das Bild landet erst HIER in der DB, nicht beim Scan. Privacy: nicht-confirmed Scans hinterlassen keine Spuren.
- Cora AI kann spaeter auf diese History zugreifen fuer Coaching ("du hattest gestern Pizza").
- Latenz ~400-600ms (Storage + Insert).

**Empfohlene UX:**

1. User macht Foto → scanner (SSE, live streaming)
2. User sieht Ergebnisse, bearbeitet ggf.
3. User tippt "In Tagebuch speichern" → confirm
4. Nach Response: scan_id in Zustand-Store, image_url fuer Thumbnail in History-View