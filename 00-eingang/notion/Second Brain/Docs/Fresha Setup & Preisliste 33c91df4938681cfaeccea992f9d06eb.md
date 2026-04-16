# Fresha Setup & Preisliste

Created: 9. April 2026 00:24
Doc ID: DOC-30
Doc Type: Reference
Gelöscht: No
Last Edited: 9. April 2026 00:24
Lifecycle: Active
Notes: Fresha Account-Info + vollständige Preisliste (84 Leistungen, 10 Kategorien) + Script-Architektur für Bulk-Upload. Volatile weil Preisliste sich ändern kann.
Project: BellaVie (../Projects/BellaVie%2033c91df4938681889034d53da9eb6839.md)
Stability: Volatile
Verified: No

## Scope

Fresha Account-Setup, vollständige Preisliste (84 Leistungen in 10 Kategorien) und Script-Architektur für den Bulk-Upload via Browser Console.

## Architecture / Constitution

- **Platform:** [partners.fresha.com](http://partners.fresha.com)
- **Location ID:** 2917295
- **Catalogue URL:** [https://partners.fresha.com/catalogue/services](https://partners.fresha.com/catalogue/services)
- **Upload-Methode:** JavaScript-Automation via Browser Console (React-Input Setter + waitFor-Polling)
- **Gesamt:** 84 Leistungen — 82 via Automation + 2 manuell

## Script-Architektur (React-Input Setter Pattern)

### Helper-Funktionen

- `createSimpleService(category, name, preistyp, preis, dauerMin, einwirkzeitMin)` — einzelne Leistung anlegen
- `createVariantService(category, name, variants[])` — Leistung mit Varianten (z.B. Länge 1/2/3)
- React-Inputs werden per `Object.getOwnPropertyDescriptor(HTMLInputElement.prototype, 'value').set` gesetzt (umgeht React-State-Bindings)
- `saveService()` wartet auf URL-Wechsel weg von `/add/new` (timeout 15s)
- `waitFor()` pollt alle 100–300ms bis Element erscheint

### Ausführung

- **Script-Befehl:** `await runAll()`
- **Bei Fehler / Resume:** `await runAll(N)` mit N = fehlgeschlagenem Index

## Edge Cases — Manuelle Fixes nach Upload (Vollfärbung)

In Fresha manuell korrigieren: Katalog → Vollfärbung → Varianten bearbeiten

| Variante | Aktuell falsch | Korrekt |
| --- | --- | --- |
| Länge 2 | 135€ / 105 min / 30 min EWZ | **135€ / aktiv 60 min / EWZ 30 min = 90 min gesamt** |
| Länge 3 | 165€ / 120 min / 30 min EWZ | **155€ / aktiv 80 min / EWZ 40 min = 120 min gesamt** |

## Vollständige Preisliste

### 1. Haarschnitte & Styling

| Leistung | Variante | Preis | Dauer gesamt | Einwirkzeit |
| --- | --- | --- | --- | --- |
| Damenhaarschnitt | — | manuell | — | — |
| Styling | Länge 1 | 30€ | 20 min | — |
| Styling | Länge 2 | 35€ | 25 min | — |
| Styling | Länge 3 | 40€ | 30 min | — |
| Spitzen schneiden | — | 25€ | 20 min | — |
| Herrenhaarschnitt | — | 30€ | 20 min | — |
| Frisur | — | ab 50€ | 60 min | — |
| Kinderhaarschnitt Mädchen 4–10 J. | — | 25€ | 20 min | — |
| Kinderhaarschnitt Jungen 4–10 J. | — | 18€ | 20 min | — |
| Kinderhaarschnitt 0–4 J. | — | 15€ | 20 min | — |

### 2. Haarfarben

| Leistung | Variante | Preis | Dauer gesamt | Einwirkzeit |
| --- | --- | --- | --- | --- |
| Vollfärbung | Länge 1 | 115€ | 75 min | 30 min |
| Vollfärbung | Länge 2 | 135€ | 90 min | 30 min |
| Vollfärbung | Länge 3 | 155€ | 120 min | 40 min |
| Balayage / Airtouch | Länge 1 | 200€ | 170 min | 45 min |
| Balayage / Airtouch | Länge 2 | 230€ | 200 min | 45 min |
| Balayage / Airtouch | Länge 3 | 240€ | 220 min | 45 min |
| Highlights | Länge 1 | 165€ | 150 min | 45 min |
| Highlights | Länge 2 | 185€ | 180 min | 45 min |
| Highlights | Länge 3 | 200€ | 200 min | 45 min |
| Tönung | Länge 1 | 70€ | 60 min | 20 min |
| Tönung | Länge 2 | 90€ | 80 min | 20 min |
| Tönung | Länge 3 | 110€ | 90 min | 20 min |
| Total Blond | Länge 1 | 300€ | 240 min | 60 min |
| Total Blond | Länge 2 | 330€ | 300 min | 60 min |
| Total Blond | Länge 3 | 360€ | 300 min | 60 min |
| Ansatzfärbung bis 3 cm | — | ab 49€ | 60 min | 30 min |

### 3. Haarpflege & Treatments

| Leistung | Variante | Preis | Dauer gesamt | Einwirkzeit |
| --- | --- | --- | --- | --- |
| Keratin | Länge 1 | 160€ | 90 min | 30 min |
| Keratin | Länge 2 | 180€ | 150 min | 30 min |
| Keratin | Länge 3 | 200€ | 170 min | 30 min |
| Keratin Afro | Länge 1 | 230€ | 200 min | 45 min |
| Keratin Afro | Länge 2 | 260€ | 250 min | 45 min |
| Keratin Afro | Länge 3 | 290€ | 260 min | 45 min |
| Botox | Länge 1 | 160€ | 130 min | 30 min |
| Botox | Länge 2 | 180€ | 150 min | 30 min |
| Botox | Länge 3 | 200€ | 170 min | 30 min |
| Kalter Botox | Länge 1 | 80€ | 60 min | — |
| Kalter Botox | Länge 2 | 90€ | 80 min | — |
| Kalter Botox | Länge 3 | 100€ | 90 min | — |
| Dauerwelle | Länge 1 | 130€ | 90 min | 30 min |
| Dauerwelle | Länge 2 | 145€ | 120 min | 30 min |
| Dauerwelle | Länge 3 | 160€ | 140 min | 30 min |

### 4. Nägel — Maniküre

| Leistung | Variante | Preis | Dauer |
| --- | --- | --- | --- |
| Hygienische Maniküre | — | 33€ | 45 min |
| Hygienische Maniküre + Lack | — | 38€ | 60 min |
| Entfernen - Maniküre - Politur | — | 43€ | 75 min |
| Delux Maniküre | — | 60€ | 90 min |
| Auffüllen | 1–2 Längen | 45€ | 90 min |
| Auffüllen | 3–4 Längen | 51€ | 90 min |
| Auffüllen | Extra Long 5+ | 60€ | 105 min |
| Neumodellage | 1–2 Längen | 50€ | 90 min |
| Neumodellage | 3–4 Längen | 60€ | 105 min |
| Neumodellage | Extra Long 5+ | 65€ | 120 min |

### 5. Nägel — Pediküre

| Leistung | Preis | Dauer |
| --- | --- | --- |
| Hygienische Pediküre | 40€ | 60 min |
| Hygienische Pediküre + Lack | 45€ | 75 min |
| Entfernen - Pediküre - Politur | 50€ | 90 min |
| Delux Pediküre | 68€ | 105 min |

### 6. Lash & Brow

| Leistung | Variante | Preis | Dauer |
| --- | --- | --- | --- |
| Wimpernverlängerung Klassisch | Neu | 80€ | 120 min |
| Wimpernverlängerung Klassisch | Auffüllen | 40€ | 60 min |
| Wimpernverlängerung 2D | Neu | 90€ | 120 min |
| Wimpernverlängerung 2D | Auffüllen | 45€ | 60 min |
| Wimpernverlängerung 3D | Neu | 100€ | 120 min |
| Wimpernverlängerung 3D | Auffüllen | 50€ | 60 min |
| Wimpernverlängerung 4D | Neu | 110€ | 120 min |
| Wimpernverlängerung 4D | Auffüllen | 55€ | 60 min |
| Wimpernverlängerung 5D+ | Neu | 120€ | 120 min |
| Wimpernverlängerung 5D+ | Auffüllen | 60€ | 60 min |
| Wimpernlifting inkl. Färben | — | 50€ | 60 min |
| Wimpern färben | — | 10€ | 15 min |
| Brow Lifting inkl. Färben & Zupfen | — | 50€ | 45 min |
| Augenbrauen zupfen | — | 10€ | 15 min |
| Augenbrauen färben | — | 15€ | 15 min |
| KOMBI Wimpernlifting + Brow Lifting | — | 95€ | 90 min |

### 7. Permanent Makeup — PMU

| Leistung | Preis | Dauer |
| --- | --- | --- |
| Powder Brows | 250€ | 150 min |
| Ombré | 280€ | 150 min |
| Klassischer Lidstrich | 160€ | 120 min |
| Lidstrich mit Schattierung | 180€ | 150 min |
| Wimpernkranzverdichtung | 150€ | 120 min |
| Lippen Aquarell-Technik | 200€ | 150 min |
| Lippenstift-Effekt | 250€ | 180 min |
| Lippenkontur | 220€ | 120 min |

### 8. Sugaring — Für Sie

| Leistung | Preis | Dauer |
| --- | --- | --- |
| Tiefer Bikini | 60€ | 45 min |
| Klassische Bikinizone | 30€ | 30 min |
| Beine vollständig | 65€ | 60 min |
| Schienbeine | 33€ | 30 min |
| Oberschenkel | 40€ | 30 min |
| Arme bis Ellenbogen | 30€ | 30 min |
| Arme vollständig | 44€ | 45 min |
| Arme unter den Armen | 25€ | 20 min |
| Bauchlinie | 15€ | 15 min |
| Unterer Rücken | 25€ | 20 min |
| Oberlippe | 10€ | 15 min |
| Kinn | 15€ | 15 min |
| Wangen | 18€ | 15 min |
| Unterarme | 30€ | 30 min |
| Ohren | 15€ | 15 min |
| Nacken | 20€ | 20 min |
| Rücken + Schultern | 55€ | 45 min |
| Stirn | 12€ | 15 min |
| Nase | 10€ | 15 min |

### 9. Sugaring — Für Ihn

| Leistung | Preis | Dauer |
| --- | --- | --- |
| Bauch | 25€ | 30 min |
| Brust | 35€ | 30 min |
| Rücken komplett | 40€ | 45 min |
| Schultern mit Nacken | 30€ | 30 min |
| Bauch + Brust | 50€ | 45 min |
| Nase | 12€ | 15 min |
| Achseln | 25€ | 20 min |
| Arme komplett | 45€ | 45 min |
| Unterarme | 30€ | 30 min |
| Beine komplett | 65€ | 60 min |
| Beine Unterschenkel | 33€ | 30 min |
| Beine Oberschenkel | 40€ | 30 min |
| Ohren | 15€ | 15 min |
| Nacken | 20€ | 20 min |
| Rücken + Schultergürtel | 55€ | 45 min |

### 10. Weitere Leistungen

| Leistung | Variante | Preis | Dauer |
| --- | --- | --- | --- |
| Zahnbleaching | — | 99€ | 60 min |
| Lymphodrainage | 1 Sitzung | 20€ | 20 min |
| Lymphodrainage | 5er-Paket | 90€ | 20 min |
| Lymphodrainage | 10er-Paket | 170€ | 20 min |