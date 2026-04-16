# Terminbuchungs-App — Konzept & Stand

Created: 9. April 2026 01:22
Doc ID: DOC-35
Doc Type: Briefing
Gelöscht: No
Last Edited: 9. April 2026 01:22
Lifecycle: Draft
Notes: Konzept-Platzhalter für Terminbuchungs-App. Stack überlappt bewusst mit coralate. BellaVie als erster Dogfood-Case. Geparkt bis nach Thesis-Abgabe Mitte Juni 2026. Offen: Feature-Scope MVP, Monetarisierungsmodell, rechtliche Struktur.
Project: Terminbuchungs-App (../Projects/Terminbuchungs-App%2033c91df493868146b437e9746f880385.md)
Stability: Draft
Stack: React Native, Supabase
Verified: No

## Scope

Konzept-Dokument für Deniz' eigene Terminbuchungs-App als Fresha-Alternative. Erfasst alle Infos die aktuell vorhanden sind — bewusst nicht ausgearbeitet, nur als Platzhalter bis das Projekt nach Thesis-Abgabe aktiviert wird.

## Architecture / Constitution

- **Produkt-Typ:** Eigenes SaaS-Produkt (Booking-Plattform)
- **Vision:** Fresha-Alternative für Dienstleistungsbetriebe (Friseure, Beauty, Studios, Pilates, etc.)
- **Status:** Geparkt bis nach Thesis-Abgabe (15. Juni 2026)
- **Erster Framework-Client:** BellaVie (Dogfood-Case)

## Tech Stack (geplant)

| Layer | Technology | Begründung |
| --- | --- | --- |
| Mobile | React Native + Expo | Überlapp mit coralate — gleiche Skills, Tooling |
| Backend | Supabase | Auth + Postgres + Storage + Edge Functions in einem |
| Payments | Stripe (Phase 2) | Industrie-Standard, später |
| Notifications | Expo Push | Mit Expo Stack integriert |
| Web-Dashboard (später) | Framer oder Next.js | noch offen |

### Bewusste Stack-Überlappung mit coralate

Die Tech-Wahl überlappt zu ~80% mit coralate. Das ist Absicht:

- Reduzierter Learning-Overhead (keine zwei Stacks pflegen)
- Gemeinsame Konventionen, gemeinsame Design-Tokens-Philosophie übertragbar
- Gemeinsame Supabase-Erfahrung (RLS, Edge Functions, Storage)
- Apple/Google Store Prozesse bereits bekannt über coralate

**Aber:** Nicht mit coralate vermischen. Coralate = Fitness/Health-Tracking. Terminbuchung = Service-Booking. Komplett unterschiedliche User und Marktlogik.

## Strategische Rationale

Warum eine eigene Plattform statt klassischer Agency-Dienstleistung?

### Problem mit reiner Dienstleistung

- Kunden zahlen für Zeit, nicht für Asset
- Bei Churn ist die ganze Arbeit weg
- Kein Leverage — jede Stunde muss neu verkauft werden

### Vorteil eigener Plattform

- **Technischer Leverage:** Kunde ist in deiner Infrastruktur, nicht nur bei dir als Service-Dienstleister. Lock-in durch Usability, nicht durch Rechnungen.
- **Recurring Revenue:** SaaS-Modell schlägt Stückpreisprojekt langfristig
- **Asset-Aufbau:** Die Plattform bleibt auch ohne aktive Entwicklung wertvoll
- **Fresha-Abhängigkeit lösen:** BellaVie zahlt aktuell an Fresha; eine eigene Lösung könnte dort starten

### Risiko

- Produkt-Entwicklung ist langfristiger und unsicherer als Service
- Apple/Google Store Gatekeeping
- Konkurrenz ist groß (Fresha, Treatwell, Booksy)

## Rahmen (BellaVie als Testcase)

BellaVie ist bereits im Thalor-Ökosystem als Kunde. Nutzt aktuell Fresha. Hat eine bekannte Service-Struktur: **84 Services in 10 Kategorien**. Das ist ein idealer erster Dogfood-Case:

- Migration der bestehenden Service-Struktur als erster Import-Test
- Real-World-Nutzung unter kontrollierten Bedingungen
- Direktes Feedback über Maddox
- Möglichkeit für White-Label oder Co-Branded Lösung

## Open Points (nicht ausgearbeitet)

- **Feature-Scope für MVP:** Was ist das absolute Minimum? Kalender + Buchung + Payments? Notifications? SMS-Reminders?
- **Monetarisierungsmodell:** SaaS-Subscription (fix/Monat) vs. Transaktionsgebühr (×% pro Buchung) vs. Hybrid
- **App Store Strategie:** Unter Thalor veröffentlichen oder separate Entity?
- **Google/Apple Developer Accounts:** Nutzen von coralate-Setup oder separater Account?
- **Rechtliche Struktur:** Bleibt es Freiberufler-Thalor oder wird eine Gesellschaft nötig bei Recurring SaaS?
- **Datenschutz:** Booking-Daten enthalten PII — DSGVO-Anforderungen
- **Wann Unpark:** Frühestens nach Thesis-Abgabe Mitte Juni 2026. Realistisch: Juli/August 2026 wenn HdWM durch ist.

---

*Dieses Doc ist ein Gedanken-Anker. Nichts davon ist final entschieden — es ist der Stand der Überlegung wie sie aktuell existiert.*