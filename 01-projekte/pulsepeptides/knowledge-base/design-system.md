---
typ: wissen
projekt: "[[pulsepeptides]]"
thema: design-system
status: aktiv
erstellt: 2026-04-27
zuletzt_aktualisiert: 2026-04-27
vertrauen: extrahiert
quelle: html_extract
---

# Design-System pulsepeptides.com

Snapshot des aktuellen Live-Designs von pulsepeptides.com. Quelle: HTML-Extract aus April 2026, Original archiviert unter `_anhaenge/projekte/pulsepeptides/2026-04-27-design-system.html`.

Diese File ist das verbindliche Referenzdokument fuer Farb-, Typografie- und Komponenten-Entscheidungen bei allen Pulse-Assets (Website, Labels, E-Mails, Slack-Embeds, Marketing-Material).

## Primary Colors

Background- und Text-Basis. Fast komplett dunkles Theme.

| Rolle | Hex | Verwendung |
|---|---|---|
| Background Main | `#161616` | Haupt-Seitenhintergrund |
| Background Dark Panel | `#282828` | Sektionspanels, Cards |
| Background Subtle | `#1B1B1B` | Subtile Trennzonen |
| Text Primary | `#FFFFFF` | Headings, primaerer Body-Text |

## Accent Colors

Highlight-, CTA- und Marketing-Farben.

| Rolle | Hex | Verwendung |
|---|---|---|
| Magenta Accent | `#FF157E` | Primary CTA (Add to Cart), Highlight |
| Purple-Pink Links/CTA | `#D104AC` | Sekundaere Links, CTA-Variante |
| Neon Purple (CSS Token) | `#D62BF8` | Astra-Token, vermutlich Heading-Akzent |
| Mint Green Alt BG | `#2EE69A` | Alternativer Section-Hintergrund |
| Neon Green (CSS Token) | `#3DFF21` | Astra-Token, vermutlich Highlight |

## Text Colors

| Rolle | Hex | Verwendung |
|---|---|---|
| Text Primary | `#FFFFFF` | Headings, Body |
| Text Secondary | `#A3A3A3` | Captions, Meta-Info |
| Text Muted | `#999999` | Hints, Hilfstexte |
| Text Disabled | `#808285` | Inaktive Elemente |

## Surface und Overlay

Glass- und Frosted-Effekte, charakteristisch fuer das Pulse-UI.

| Rolle | Wert | Verwendung |
|---|---|---|
| Section Overlay | `rgba(36, 36, 36, 0.2)` | Section-Tints ueber Hintergrund |
| Button Frosted | `rgba(255, 255, 255, 0.1)` | Sekundaere Buttons (frosted glass) |
| Card Glass | `rgba(255, 255, 255, 0.15)` | Card-Hintergrund (glass effect) |
| Warm Cream | `#F0EFE1` | Light-Mode-Bereiche, Kontrast-BG |

## Typography

**Primary Font:** Red Hat Display (alle Texte, Headings und Body)

| Style | Groesse | Weight | Farbe |
|---|---|---|---|
| H1 Hero | 64px | Bold 700 | White |
| H2 Section | 56px | Bold 700 | White |
| H3 Card | 18px | Semi 600 | White |
| Body | 16px | Regular 400 | White oder `#A3A3A3` |
| Button | 18px | Regular 400 | White, Pill 32px |

## Komponenten

### Button Primary (Frosted)

- Text: z.B. "Shop Our Peptides"
- Background: `rgba(255, 255, 255, 0.1)`
- Border: `rgba(255, 255, 255, 0.3)`
- Border-Radius: 32px (pill)
- Padding: 10px 22px
- Font: 14px

### Accent CTA

- Text: z.B. "Add to Cart"
- Background: `#FF157E`
- Color: White
- Border-Radius: 32px (pill)
- Padding: 10px 22px
- Font: 14px, Weight 500

### Card / Surface

- Background: `rgba(255, 255, 255, 0.08)`
- Border: `0.5px solid rgba(255, 255, 255, 0.15)`
- Border-Radius: 10px bis 12px
- Padding: 10px 14px

## CSS Token Mapping

Die Site nutzt das Astra-Theme-Pattern `--ast-global-color-{n}` (abgeleitet aus dem Token-Namen, nicht final bestaetigt, siehe [[#Offene Punkte]]).

| Token | Hex | Bezeichnung |
|---|---|---|
| `--ast-global-color-0` | `#D62BF8` | Neon Purple |
| `--ast-global-color-1` | `#3DFF21` | Neon Green |
| `--ast-global-color-3` | `#334155` | Dark Slate |
| `--ast-global-color-6` | `#F0EFE1` | Warm Cream |
| `--ast-global-color-7` | `#2EE69A` | Mint Green |
| `--ast-global-color-8` | `#A5B893` | Muted Green |

## Offene Punkte

- **Astra-Theme bestaetigen:** Das Token-Pattern `--ast-global-color-*` deutet auf Astra (WordPress-Theme). Falls bestaetigt, in [[pulsepeptides]] `tech_stack` ergaenzen. Aktuell als `vertrauen: abgeleitet` markiert.
- **Fehlende Tokens:** Im Mapping fehlen `--ast-global-color-2`, `--ast-global-color-4`, `--ast-global-color-5`. Bewusst weggelassen oder noch zu extrahieren? Bei naechster Site-Analyse pruefen.
- **Hex-Doppel-Definition Magenta:** `#FF157E` (Magenta Accent) und `#D104AC` (Purple-Pink Links/CTA) ueberlappen funktional. Klaeren wann welcher genutzt wird.
- **Dark Slate `#334155` ohne Use-Case:** Im Mapping enthalten, aber keine zugewiesene Rolle in den Color-Sektionen oben. Wo wird er konkret verwendet?
- **Light-Mode-Logik:** `#F0EFE1` Warm Cream ist als "Light BG" markiert. Hat die Site einen Light-Mode oder ist das nur fuer einzelne Sections?

## Verwandte Files

- Übergeordnetes Projekt: [[pulsepeptides]]
- Tech-Stack-Kontext: [[firmenstruktur]]
- Marketing-Verantwortung Labels und Design: [[lizzi-pulse]]
- Website-Verantwortung WordPress: [[german-pulse]]
