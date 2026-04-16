---
typ: ueber-projekt
name: "Terminbuchungs-App"
aliase: ["Terminbuchungs-App", "Terminbuchung", "Booking-App"]
bereich: produkt
umfang: offen
status: pausiert
kapazitaets_last: niedrig
hauptkontakt: ""
tech_stack: ["react-native", "expo", "supabase", "stripe"]
erstellt: 2026-04-16
notizen: "Eigenes SaaS-Produkt, Fresha-Alternative. Geparkt bis nach Thesis-Abgabe (15.06.2026). BellaVie als geplanter erster Framework-Client."
quelle: notion_migration
vertrauen: extrahiert
---

## Kontext

**Eigene Terminbuchungs-App als Fresha-Alternative.** Ziel: moderne, eigenständige Booking-Plattform die als Framework für Dienstleistungsbetriebe (Friseure, Beauty, Studios) dient.

**Strategische Rationale:** Technischer Leverage statt reiner Service-Abhängigkeit. Fresha kann jederzeit Preise anheben oder Features streichen - eine eigene Plattform ist ein Asset.

- **Produkt-Typ:** Eigenes SaaS-Produkt, kein Client-Auftrag
- **Ziel-Plattform:** iOS + Android (initial), Web-Dashboard für Betreiber (später)
- **Erster Framework-Client:** [[bellavie]] (bereits im Thalor-Ökosystem, Dogfood-Case)

**Tech-Stack (geplant):**
- Frontend: React Native + Expo
- Backend: Supabase (Auth, Postgres, Storage, Edge Functions)
- Payments: Stripe (später - nicht Phase 1)
- Notifications: Expo Push

Stack überlappt bewusst mit [[coralate]] - gleiche Skills, gleiche Tooling-Disziplin, reduzierter Learning-Overhead.

**Abgrenzung:** Nicht mit [[coralate]] vermischen - coralate = Fitness, Terminbuchung = Booking.

## Aktueller Stand

**Status: PAUSIERT** bis nach Thesis-Abgabe (15.06.2026). Keine aktive Arbeit. Realistisch: Juli/August 2026 wenn HdWM durch ist. Minimal angelegt, Details kommen erst bei Aktivierung.

## Strategische Rationale

### Problem mit reiner Dienstleistung

- Kunden zahlen für Zeit, nicht für Asset
- Bei Churn ist die ganze Arbeit weg
- Kein Leverage - jede Stunde muss neu verkauft werden

### Vorteil eigener Plattform

- **Technischer Leverage:** Kunde ist in Deniz' Infrastruktur, nicht nur bei ihm als Service-Dienstleister. Lock-in durch Usability, nicht durch Rechnungen.
- **Recurring Revenue:** SaaS-Modell schlägt Stückpreisprojekt langfristig.
- **Asset-Aufbau:** Plattform bleibt auch ohne aktive Entwicklung wertvoll.
- **Fresha-Abhängigkeit lösen:** BellaVie zahlt aktuell an Fresha - eigene Lösung könnte dort starten.

### Risiko

- Produkt-Entwicklung langfristiger und unsicherer als Service
- Apple/Google Store Gatekeeping
- Konkurrenz groß (Fresha, Treatwell, Booksy)

## BellaVie als Dogfood-Case

[[bellavie]] ist bereits im Thalor-Ökosystem, nutzt aktuell Fresha, Service-Struktur bekannt: 84 Services in 10 Kategorien. Idealer erster Dogfood-Case:

- Migration der bestehenden Service-Struktur als erster Import-Test
- Real-World-Nutzung unter kontrollierten Bedingungen
- Direktes Feedback über Maddox
- Möglichkeit für White-Label oder Co-Branded Lösung

## Offene Aufgaben (bei Reaktivierung)

- [ ] Feature-Scope MVP definieren (Minimum: Kalender + Buchung + Payments? Notifications? SMS-Reminders?)
- [ ] Monetarisierungsmodell (SaaS-Sub fix/Monat vs. Transaktionsgebühr ×% pro Buchung vs. Hybrid)
- [ ] App-Store + Google-Play Konten (unter Thalor oder separat?)
- [ ] Rechtliche Struktur: Freiberufler-Thalor reicht oder Gesellschaft bei Recurring SaaS nötig?
- [ ] Datenschutz: Booking-Daten = PII, DSGVO-Anforderungen klären
- [ ] Migration BellaVie-Service-Struktur (84 Services, 10 Kategorien) als Import-Test

## Reaktivierung

Frühestens nach Thesis-Abgabe Mitte Juni 2026.

## Kontakte

_(keine - bei Reaktivierung [[maddox-yakymenskyy]] als Pilot-Kontakt)_
