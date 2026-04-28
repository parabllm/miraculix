---
typ: wissen
projekt: "[[pulsepeptides]]"
thema: lager-eppelheim
status: aktiv
erstellt: 2026-04-28
zuletzt_aktualisiert: 2026-04-28
vertrauen: bestätigt
quelle: lager-besuch + slack_dm_kai
---

# Lager Eppelheim

Aktuelles operatives Lager der PulsePeptides Operations. Standort bei Mannheim, betrieben von [[kai-pulse]] in Teilzeit. Wird mittelfristig (Mai/Juni 2026) nach Tschechien verlagert, siehe [[lager-tschechien]] fuer den geplanten Uebergang.

## Stammdaten

| Feld | Wert |
|---|---|
| Standort | Eppelheim bei Mannheim |
| Betreiber | [[kai-pulse]] |
| Beschaeftigung | Teilzeit |
| Anfahrt aus DE | unter 1h |
| Funktion | Lager plus Picking plus Packing plus Versand plus Labelling |

## Logistik-Daten (Stand 2026-04-28, von Kai bestaetigt via Slack-DM)

### Versendungen

| Metrik | Wert |
|---|---|
| Monatsvolumen | 180-240 Pakete (Mittel ca. 210) |
| GLP-Anteil am Volumen | 20-30% |
| Trend | wachsend mit GLP-Klasse |

Hinweis: in der ersten Maman-Inquiry (2026-03-01) wurde noch von "300+ B2C orders per month" gesprochen. Reale Zahl liegt aktuell darunter und wird in der Maman-Antwort angepasst.

### Versandkartons

| Metrik | Wert |
|---|---|
| Typ | DHL XS Box |
| Aussenmasse | 33,7 x 24,5 x 9,5 cm |
| Inhalt typisch | bis 10 Inner-Boxen mit je 10 Vials (selten ausgereizt) |
| Avg Pieces per Order | 7 Vials (deckt sich mit Maman-Annahme) |
| Real-Gewicht je Versendung | 0,5 bis 1,5 kg |
| Versand-Tarif | DHL Paket 2 kg |
| Boxen pro EUR-Palette | bis 200 (je nach Stapelweise) |

### Warenwert je Versendung

| Metrik | Wert |
|---|---|
| Range | 75 bis 1500 EUR |
| Schnitt typisch | 100 bis 350 EUR |
| Mittelwert grob | ca. 225 EUR |
| Insurance-Value-Empfehlung | 250 EUR pro Paket Standard, 1500 EUR Cap fuer Spitzenlast |

### Versandlaender

| Region | Status |
|---|---|
| EU komplett | Standard |
| Schweiz | mit Zollabwicklung |
| UK / England | mit Zollabwicklung |

Genaue ZIP-Verteilung und exakte Laenderliste muss aus [Metorik](https://app.metorik.com) gezogen werden (Versandberichte mit Country-Filter).

## Lieferanten Verbrauchsmaterial

### Versandkartons

- **Anbieter:** karton.eu
- **Beleg:** Slack-DM Kai 2026-04-28, Rechnung RE-1245241 (im Slack-Anhang)
- **Material:** DHL XS Boxen plus Lupo (Luftpolsterfolie)

### Klarsicht-Tueten

- **Anbieter:** karton.eu (gleicher Anbieter wie Versandkartons)
- **Beleg:** Slack-DM Kai 2026-04-28, Karton.eu Rechnung 26048028 (im Slack-Anhang)

### Konsequenz fuer Druckerei-Sourcing

karton.eu ist nicht Druckerei sondern Verpackungs-Lieferant. Druckerei-Spec laeuft separat (siehe [[2026-04-28-nachgespraech-kalani]]).

## Etiketten und Labelling

- Aktueller Drucker fuer Vial-Labels: etikettendrucken.de
- Format: 6x9mm, mit Pinzette zu kleben
- Bug-Stand 2026-04-28: 100 Stueck Kapsel-Labels mit altem "Hyaluronic Acid"-Text (vor Halal-Wechsel)
- Brother-Label-Demo: noch nicht live gesehen, naechster Lager-Besuch
- Direktdruck-Vorbild: Lab Peptides druckt Batch-Nummer direkt auf Flasche (siehe [[2026-04-28-lager-besuch-kalani]] Korrektur 25:09)

## Inventory

Stand-Bestand wird in Google Sheets (SSOT, 17 Spalten) und in Metorik gefuehrt. Lebt primaer im Kopf von Kai.

### Backorders Stand 2026-04-28

- PT-141 (leer)
- Tesamorelin (3/4 Rolle Reserve)
- Cmax
- Semang
- Kapseln plus Kapsel-Labels
- Tirzepatide (Kalani-Task seit 2026-04-17)

Vollstaendiger Inventar-Stand: Google Sheets + Metorik (Bestaetigung Kai folgt nachgereicht).

## Operative Schritte

1. Bestellung kommt rein (WooCommerce, automatisch nach Metorik)
2. Kai prueft Inventory plus Picking
3. Inner-Boxen gefuellt, Vials dazu, Bac-Water dazu, Klarsicht-Tuete drum
4. Lupo-Folie als Polsterung
5. DHL XS Box, Versandlabel auf 2-kg-Tarif, ab zur Versandstation
6. Bei Custom Orders: vorher Christian-Eskalation (siehe [[support-eskalation]])

## Schwachstellen und Pain-Points

- Etiketten-Format 6x9mm fummelig
- Batch-Nummer wird manuell nachgepflegt (kein Direktdruck)
- Hyaluronic-Acid-Bug bei 100 Kapsel-Labels nicht behebbar ohne Neulabelling
- Geographisch: Versand aus DE rechtlich kritisch (Pulse-aus-DE-Strategie zieht Richtung Tschechien)
- Inventory-Stand lebt teilweise im Kopf, nicht vollstaendig in Sheets gepflegt

## Verlagerung nach Tschechien

Phase 1 entschieden im Lager-Besuch 2026-04-28:
- DE labelt fertig, Tschechen versenden erst nur
- Test mit 20% der Bestellungen
- Spaeter: unbelabelte Vials direkt aus China zu Tschechien, dort labeln
- DDP-Setup mit chinesischer Firma als Origin

Details und Maman-Inquiry: siehe [[lager-tschechien]]
Lager-Besuch-Notiz: siehe [[2026-04-28-lager-besuch-kalani]]

## Cross-Reference

- [[lager-tschechien]] - geplante Verlagerung
- [[2026-04-28-lager-besuch-kalani]] - Lager-Besuch-Notiz
- [[2026-04-28-nachgespraech-kalani]] - Druckerei-Sourcing-Spec
- [[firmenstruktur]] - Team plus Systeme
- [[lieferanten]] - Supplier-Zuordnung
- [[kai-pulse]] - Lager-Verantwortlicher
