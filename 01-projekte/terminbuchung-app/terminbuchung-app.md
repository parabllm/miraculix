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

**Status: PAUSIERT** bis nach Thesis-Abgabe (15.06.2026). Keine aktive Arbeit. Minimal angelegt, Details kommen erst wenn Projekt aktiviert wird.

## Offene Aufgaben (bei Reaktivierung)

- [ ] Feature-Scope für MVP definieren
- [ ] Monetarisierungsmodell (SaaS-Sub vs. Transaktionsgebühr vs. beides)
- [ ] App-Store + Google-Play Konten (ggf. unter Thalor oder separat)
- [ ] Rechtliche Struktur klären wenn Produkt reif
- [ ] Migration BellaVie-Service-Struktur (84 Services, 10 Kategorien) als Import-Test

## Reaktivierung

Frühestens nach Thesis-Abgabe Mitte Juni 2026.

## Kontakte

_(keine - bei Reaktivierung [[maddox-yakymenskyy]] als Pilot-Kontakt)_
