# Tech Stack & Conventions

Created: 9. April 2026 00:55
Doc ID: DOC-32
Doc Type: Reference
Gelöscht: No
Last Edited: 9. April 2026 00:55
Lifecycle: Active
Notes: Tech Stack, NOT-Installed-Liste, File Structure, Store Persistence, Auth-Status, Mandatory Rules, Cursor Agent Discipline. Stable weil Stack-Entscheidungen selten ändern. Quelle: Cora HQ Tech Stack + Development Docs.
Project: coralate (../Projects/coralate%2033c91df49386813fa411f4c4e931d51f.md)
Stability: Stable
Stack: React Native, Supabase
Verified: No

## Scope

Tech Stack, Versions, Conventions, NOT-Installed-Liste, Auth-Status, File Structure, Store Persistence Rules, Implementation Methodology und Mandatory Rules für alle künftigen Implementierungen im corelate-v3 Codebase.

## Architecture / Constitution

- **Source of Truth:** `package.json` — Versions sind ground truth
- **Repo:** parabllm/coralate (Folder: corelate-v3)
- **Expo-Token-Strategie:** Dev-Build auf iPhone via Expo Go + Cursor Agent Workflow

## Core Dependencies

| Layer | Technology | Version |
| --- | --- | --- |
| Framework | Expo SDK | 55 preview |
| React Native | react-native | 0.83.1 |
| Router | expo-router | 55 preview |
| GPU Rendering | React Native Skia | 2.4.18 |
| Animation | Reanimated | ~4.2.1 |
| State | Zustand | 5 |
| Backend | Supabase JS | 2.99 |
| Native UI | @expo/ui | preview |
| Haptics | `corelate-haptics` | local native module |

## NOT Installed — Do Not Import

Diese werden in .cursor-Rules und Design-Docs referenziert, sind aber NICHT in `package.json`. **Nie Import-Statements für diese generieren:**

| Library | Status | Note |
| --- | --- | --- |
| `@gorhom/bottom-sheet` | NOT INSTALLED | Nur in .cursor rules referenziert |
| `expo-sqlite` | NOT INSTALLED | Architectural intent only |
| PowerSync | NOT INSTALLED | Architectural intent only |

## Icons

- `@expo/vector-icons` — Ionicons, MaterialCommunityIcons
- **Zero emoji policy** — Icon-Library exklusiv

## Authentication Status

| Provider | Status | Notes |
| --- | --- | --- |
| Email / Password | IMPLEMENTED | Funktioniert mit RLS |
| Google Sign-In | IN PROGRESS | Blocker: Disable nonce check im Supabase Dashboard |
| Apple Sign-In | Next | Pflicht nach Google Launch (Apple Rule) |

### Google Sign-In Setup

- Library: `@react-native-google-signin/google-signin`
- Env var: `EXPO_PUBLIC_GOOGLE_WEB_CLIENT_ID`
- Web Client ID prefix: `163652907471`
- Flow: native `signInWithIdToken` (NOT `signInWithOAuth`)
- Supabase Dashboard: Auth > Providers > Google > Authorized Client IDs: Web, iOS, Android

## File Structure Reference

```
app/
  (auth)/
    sign-in.tsx
    sign-up.tsx
  (tabs)/
    _layout.tsx
    index.tsx        ← Home
    gym.tsx          ← re-exports GymScreen
    food.tsx         ← Food
    analytics.tsx    ← Analytics
    go.tsx           ← (TBD)
  profile.tsx        ← re-exports ProfileScreen
  workout.tsx        ← Stack screen for RoutineExpanded + ExerciseLibrary
  history-detail.tsx ← Stack screen for FluidExpandOverlay
  template-list.tsx  ← Stack screen for TemplateListOverlay
  routine-preview.tsx ← Stack screen for RoutinePreviewOverlay
  food-scanner.tsx   ← Stack screen for FoodScannerOverlay

screens/
  GymScreen.tsx
  ProfileScreen.tsx
  FinishWorkoutScreen.tsx

components/ (see Components Registry in Cora HQ)
store/
  workoutStore.ts          ← ephemeral
  workoutSessionStore.ts   ← ephemeral
  workoutHistoryStore.ts   ← PERSISTED
  restTimerStore.ts        ← ephemeral
  routineTemplateStore.ts  ← PERSISTED
  profileStore.ts          ← Supabase-backed
  settingsStore.ts         ← PERSISTED
  foodDayStore.ts          ← PERSISTED
  foodDayService.ts        ← Supabase service
  dayOverrideStore.ts      ← PERSISTED
  overlayNavStore.ts       ← ephemeral
  savedWorkoutSchema.ts    ← types + serializer
```

## Zustand Store Persistence

Alle User-Daten-Stores nutzen Zustand `persist` middleware mit AsyncStorage:

- `workoutHistoryStore` (key: `corelate-workout-history`)
- `foodDayStore` (key: `corelate-food-day`)
- `dayOverrideStore` (key: `corelate-day-overrides`)
- `routineTemplateStore` (key: `corelate-routine-templates`)

Jeder persistierte Store hat `clearAll()`, wird bei Sign-out und Data Reset aufgerufen.

### Cross-Store Data Flow (Patch 4)

- **Rest timer → Session:** `restTimerStore` subscribes und pushed zu `workoutSessionStore`
- **Workout completion → Day override:** Finishing a workout calls `dayOverrideStore.setOverride(dayKey, 'day_finished')`
- **Template store → UI:** `GymScreen` merged `routineTemplateStore.templates` mit mock routines

## Mandatory Rules für Future Implementation

1. **Jeder persistierte Store braucht `clearAll()`** — wired into sign-out
2. **Jede food mutation muss zu Supabase syncen**
3. **Jedes `onPress` muss etwas Observables tun** oder "Coming soon" zeigen
4. **Stack route screens müssen ihre eigenen Callbacks wiren**
5. **Nie `Date.now()` für Timestamps** die den selected day reflektieren sollen — noon use `Date.UTC(year, month, day, 12, 0, 0)`
6. **Nie weight in lb speichern** — Backend ist immer kg, Konversion an den Boundaries

### Weight Unit System (Patch 5)

- Backend speichert immer `weight_kg`
- Input: lb × 0.453592 → kg
- Display: kg × 2.20462 → lb
- Non-functional settings markiert als "Coming soon"

### Food Date Bug (Patch 2)

- `logged_at_unix` uses noon for past entries, `Date.now()` for today
- `deriveFoodDataState()` accepts `selectedDate` param
- Food streak pill uses food data, not workout data
- Food mutations sync to Supabase (removed `__DEV__` guard)

## Supabase

- JS SDK v2.99
- Authentication: email/password (working), Google (in progress), Apple (next)
- RLS enabled
- Storage: WebP at 1024×1024 and 400×400 (exercise illustrations)
- Env vars: `EXPO_PUBLIC_GOOGLE_WEB_CLIENT_ID`

## Implementation Methodology

### Primary: Cursor Agent Prompts

Claude produziert präzise, copy-paste Prompts für Cursor's AI agent.

**Prompt discipline (mandatory):**

- **Nie hardcoded hex values** — always reference design system tokens
- **Nie unrelated systems** im selben prompt touchen
- **Nie already-resolved architecture** revisiten ohne explicit instruction
- **Always acceptance criteria** specifien
- **Prompts dürfen nie `@gorhom/bottom-sheet` referenzieren** (nicht installed)

### Secondary: Figma Make

UI components designed via Figma Make agent prompts (Gemini-backed).

### Shader Development Loop

Expo Go on device → Claude für code changes → zurück zum device. Canonical versions pasted by Jann werden als new base adopted.

### [CLAUDE.md](http://CLAUDE.md)

Git safety rules und architectural constraints im project root — Claude Code liest automatisch each session.

## Git & Version Control

- **Repo:** parabllm/coralate
- **Folder:** corelate-v3
- **Known conflict files (historical):** `ExerciseBlockIdle.tsx`, `RoutineExpandedOverlay.tsx`, `SmartExerciseBlock.tsx`, `GymScreen.tsx`
- Always use `git pull origin main` until tracking branch is set
- Use `git stash` before pulling when local changes exist

## GymScreen ScrollView Pattern (CONFIRMED WORKING)

```
- ScrollView as direct screen root (no wrapper Views)
- backgroundColor on ScrollView itself
- minHeight: SCREEN_HEIGHT * 1.5 in contentContainerStyle
- All overlays/headers as Fragment siblings rendered AFTER ScrollView
- No Animated.ScrollView with useAnimatedScrollHandler
```

## AnimatedEntrance Pattern

File: `AnimatedEntrance.tsx`

```
useFocusEffect(useCallback(() => {
  opacity.value = 0;
  translateY.value = offsetY;
  opacity.value    = withTiming(1, cfg);
  translateY.value = withTiming(0, cfg);
}, [enabled, duration, offsetY]));

// Constants: duration = 320ms, offsetY = -14px, easing = Easing.out(Easing.cubic)
```

Uses `useFocusEffect` nicht `useEffect` — weil native tabs alle screens at start mounten und nie remounten.

## Overlay Navigation System (v4, 2026-03-31)

Alle overlays sind native Stack screens in `app/` opened via `router.push()`. Data passed via `store/overlayNavStore.ts`.

**Critical rules:**

- Das Transition-System darf NIE modifiziert werden beim Fixen anderer bugs
- **MANDATORY:** Jede neue full-screen page MUSS ein Stack screen in `app/` sein opened via `router.push()`
- Lokale boolean state mit absolutely-positioned overlay ist **verboten**