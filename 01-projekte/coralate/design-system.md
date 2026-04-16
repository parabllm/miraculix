---
typ: aufgabe
name: "Coralate Design System"
projekt: "[[coralate]]"
status: erledigt
benoetigte_kapazitaet: mittel
kontext: ["desktop"]
kontakte: ["[[jann-allenberger]]"]
quelle: notion_migration
vertrauen: extrahiert
erstellt: 2026-04-16
---

Color Tokens, Typography, Spacing, Animation/Spring Physics, Haptic Feedback, Button System, Border Radius, Bottom Sheet Pattern, Status Token Hierarchy, Nutrient Accent Colors. Stand 2026-04-09.

## Architektur

- **Source of Truth:** `theme/theme.ts`, `theme/typography.ts`, `theme/motion.ts`
- **Niemals hardcoded values anywhere.** Always reference these tokens.
- **Zero emoji policy** - Icon-Library exklusiv
- **Zero TouchableOpacity** - always use Pressable

## Color Philosophy: Earned Color

Color is earned by data, not painted on structure. Strukturelle Elemente (kickers, labels, borders, icons at rest) bleiben neutral. Color erscheint wenn Data it earns - progress filling up, mood selected, score calculated.

### Rules

- Max 2 bright accents visible on any single screen at rest
- Dim variants by default, full saturation only at >50% progress or on interaction
- Kein `#0000FF` als small isolated elements (dots, badges) - nur für filled card backgrounds und CTA buttons
- Kickers bleiben `textSecondary` except Cora AI (`brand.electric`)
- State-based saturation auf all ring/progress indicators
- Violet (`brand.electric`) ist NIE used in nutrient data - reserved exclusively for Cora AI

## Color Tokens

### Brand

| Token | Hex | Usage |
|---|---|---|
| `brand.primary` | `#0000FF` | Royal blue - primary actions, locked rings, active states |
| `brand.primaryGlow` | `#333DDB` | Glow/emphasis variant of primary |
| `brand.secondary` | `#FFFBEE` | Cream - rest states, DayIndicator, background tints |
| `brand.accent` | `#FF6B00` | Orange - **warning/caution only** (narrowed from v2) |
| `brand.electric` | `#7B61FF` | Violet - Cora AI identity, correlation highlights |
| `brand.electricDim` | `#4A3FC4` | Dimmed violet for backgrounds, subtle AI indicators |

### Status

| Token | Hex | Usage |
|---|---|---|
| `status.abyss` | `#A80000` | Heavy destructive swipe-left glow |
| `status.destructive` | `#D84343` | Standard destructive (remove set, delete food) |
| `status.completedWorkout` | `#1A8C5B` | Completed workouts, logged meals |
| `status.warning` | `#FF6B00` | Near-threshold macros, caution zones, rest timer |
| `status.vitality` | `#00C2A0` | Live health data, active vitals, real-time indicators |
| `status.vitalityDim` | `#007A65` | Dimmed vitality for backgrounds |
| `status.amber` | `#FFD166` | Goals, progress, streaks, achievement milestones |
| `status.amberDim` | `#B38B1B` | Dimmed amber for backgrounds |
| `status.info` | `#333DDB` | AI suggestions (legacy - prefer `brand.electric` for new Cora UI) |

**`status.success` ist deprecated.** New code must never reference it.

### Dark Surfaces

| Token | Hex | Usage |
|---|---|---|
| `dark.bg` | `#090A10` | App background |
| `dark.surface1` | `#12141D` | Base card surface |
| `dark.surface2` | `#1B1E2B` | Raised surface |
| `dark.surface3` | `#25293A` | Floating surface |
| `dark.surface4` | `#2E3554` | Deep floating: popovers, elevated modals |
| `dark.textPrimary` | `#FFFBEE` | Primary text (cream) |
| `dark.textSecondary` | `#8A91A8` | Secondary text |
| `dark.textMid` | `#6B738F` | Mid-emphasis |
| `dark.textTertiary` | `#5C637A` | Labels / tertiary |
| `dark.border` | `rgba(255,251,238,0.08)` | Default border |
| `dark.borderStrong` | `rgba(255,251,238,0.15)` | Emphasized border |

## Typography

| Role | Font | Size | Weight | Token |
|---|---|---|---|---|
| Display | Merriweather | 34pt | Black (900) | `type.display` |
| Title 1 | Merriweather | 28pt | Bold (700) | `type.title1` |
| Title 2 | Merriweather | 22pt | Bold (700) | `type.title2` |
| Title 3 | Merriweather | 20pt | SemiBold (600) | `type.title3` |
| Body | SF Pro | 17pt | Regular (400) | `type.body` |
| Callout | SF Pro | 16pt | Regular (400) | `type.callout` |
| Subhead | SF Pro | 15pt | Regular (400) | `type.subhead` |
| Footnote | SF Pro | 13pt | Regular (400) | `type.footnote` |
| Caption 1 | SF Pro | 12pt | Regular (400) | `type.caption1` |
| Caption 2 | SF Pro | 11pt | Regular (400) | `type.caption2` |

### Rules

- Headers (Display to Title 3): always Merriweather
- Body and below: SF Pro (system default)
- All numeric data: `fontVariant: ['tabular-nums']`
- Only header tokens exported from `theme/typography.ts`

## Spacing & Layout

- Base unit: 8pt grid
- `borderCurve: 'continuous'` on ALL iOS cards and surfaces
- Dismiss threshold for overlays: 120pt or velocity > 800
- **Screen-edge horizontal padding:** `HORIZONTAL_PAGE_PADDING = 24`
- **ScrollView top padding:** `LIVING_HEADER_TOP_INSET = 84` (60 Header + 24 shieldBuffer)
- Exception: `DAY_STRIP_HORIZONTAL_INSET = 12` (Food screen day strip only)

## Animation / Spring Physics

Source: `theme/motion.ts`

```
SPRING_CONFIG        = { damping: 18, stiffness: 200, mass: 0.8 }
SPRING_LAYOUT_SNAPPY = { damping: 26, stiffness: 450, mass: 0.45 }
MORPH_SPRING         = { mass: 0.8, damping: 18, stiffness: 160 }
MORPH_ARRIVE_SPRING  = { mass: 0.6, damping: 14, stiffness: 200 }
```

## Haptic Feedback Map

| Interaction | Haptic |
|---|---|
| Tap entity / select | `ImpactFeedbackStyle.Light` |
| Complete set / log meal | `ImpactFeedbackStyle.Medium` |
| Finish workout / achieve goal | `ImpactFeedbackStyle.Heavy` |
| Enter Abyss zone | `NotificationFeedbackType.Warning` |
| Confirm delete (any) | `NotificationFeedbackType.Success` |
| AI suggestion applied | `NotificationFeedbackType.Success` |
| Error / Action Failed | `NotificationFeedbackType.Error` |

## Button System

| Variant | backgroundColor | Text/Icon color | Use case |
|---|---|---|---|
| Primary | `brand.primary` `#0000FF` | `dark.textPrimary` `#FFFBEE` | Primary page actions |
| Inverse / Light | `brand.secondary` `#FFFBEE` | `dark.background` `#090A10` | Secondary page-level CTAs |
| Neutral | `dark.surface2` `#1B1E2B` | `dark.textPrimary` | Tertiary actions inside cards |

### Hard Rules

- **NIE `borderWidth` auf buttons.** Keine outlined, ghost, transparent-background buttons.
- Pressed state: `opacity: 0.75` via Pressable callback
- Action button height: `64pt`, `borderRadius: 24`
- Keine outlined/ghost buttons oder pills - all interactive elements solid surface fill
- Keine transparent-background tags
- Dashed borders nur auf empty/placeholder layout containers

## Border Radius System

| Value | Usage |
|---|---|
| 8 | Icon boxes, small inset chips |
| 12 | Inline content blocks, info banners, macro cards |
| 16 | Option cards in sheets, modal content rows |
| 24 | Main content cards, CTA buttons |
| 32 | Bottom sheet top corners (iOS modal fallback only) |
| 100 | Pills and tags - always fully-rounded |

### FORBIDDEN VALUES

**10, 14, 18, 20, 28 - NIE verwenden.**

## Bottom Sheet - Unified Implementation Pattern

### Sheet Wrapper
- `visible: boolean` prop, always rendered (never mount/unmount)
- Internal `isSheetPresented` + `isRendered` (450ms delay after dismiss)

### iOS
- SwiftUI BottomSheet from `@expo/ui/swift-ui`
- `presentationDetents: [0.65, 0.87]`

### Android
- React Native Modal with `animationType: "slide"`

### Sheet Inner Content
- Uses `ExerciseDetailHeader` (NOT `LivingPageHeader`)
- `DETAIL_HEADER_HEIGHT = 76`
- No backgroundColor on inner container

## Status Token Hierarchy

| State | Token | Value |
|---|---|---|
| Primary action confirmed | `brand.primary` | `#0000FF` |
| Workout completed | `status.completedWorkout` | `#1A8C5B` |
| Warning / rest day | `brand.accent` | `#FF6B00` |
| Destructive / delete | `status.destructive` | `#D84343` |
| Cora AI / correlation highlights | `brand.electric` | `#7B61FF` |
| Live health / vitality | `status.vitality` | `#00C2A0` |
| Goals / streaks / progress | `status.amber` | `#FFD166` |

## Nutrient Accent Hierarchy

Source: `constants/nutrientColors.ts`

### Big Two (bright)
- Calories = `status.amber`
- Protein = `brand.primaryGlow` (softer blue)

### Macro Support (muted)
- Carbs/Water = `vitalityDim`
- Fat = `textSecondary`
- Fiber = `completedWorkout`

### Watch (grey → warning at threshold)
- Sugar/Sodium/Cholesterol = `textMid`

### Vitamins
- Fat-soluble (A, E) = `amberDim`
- Water-soluble (C, Folate) = `vitalityDim`
- B12 = `textMid`

### Minerals
- Iron = `amberDim`
- Electrolytes (K, Mg) = `vitalityDim`
- Structural (Ca, Zn) = `textSecondary` / `textMid`

### Nutrient Ring Thresholds

- 0-49% fill: accent color at 40% opacity (earning attention)
- 50-89% fill: accent color at full opacity
- 90-119% fill: `brand.accent` orange (caution)
- 120%+ fill: `status.destructive` red (true overdose)

**Overdose thresholds:** Macro nutrients only. Vitamins/Minerals/Fiber/Water zeigen nie rot.

## Exercise Component Colors

- Compound exercise dot/badge: `status.amber` (important lift)
- Isolation exercise dot: `textMid`
- Tip number badges: `surface3` (structural, not branded)
- Primary muscle chips: amber tint bg/border `rgba(255, 209, 102, 0.15)`

## DayStatusButton Pill Fills

| data_state | backgroundColor |
|---|---|
| `locked_normal` / `locked_variance` | `brand.primary` |
| `fasting_day` / `day_finished` | `brand.primary` |
| `open_in_progress` | `dark.surface2` |
| `gap_unaddressed` / `locked_recalled` | `dark.surface2` |
| `auto_closed` | `brand.accent` |
| `rest_day` | `brand.accent` |

## Glass UI - Header Pill (iOS 26+ mit Fallback)

Calendar toggle icon + profile avatar in `LivingPageHeader` werden in shared `GlassContainer` gewrapped als pill-shaped glass cluster auf iOS 26.

### Three-tier fallback (AdaptiveGlassPill)

```
Tier 1 - iOS 26+: GlassView, glassEffectStyle: 'regular', borderRadius: 100
Tier 2 - iOS < 26: BlurView (expo-blur), intensity: 40, tint: 'dark', borderRadius: 100
Tier 3 - Android: Plain View, backgroundColor: rgba(60,60,67,0.30), borderRadius: 100
```

### Critical constraints

- NIE opacity < 1 on GlassView oder any parent
- Always call `isGlassEffectAPIAvailable()` at runtime before rendering GlassView
- Check `AccessibilityInfo.isReduceTransparencyEnabled()` und skip glass wenn reduced transparency aktiv
