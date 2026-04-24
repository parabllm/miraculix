---
typ: custom-order
projekt: "[[pulsepeptides]]"
peptid: "Prostamax"
status: sourcing-bekannt
kundenanfrage_datum: 2026-04-20
kanal: "#custom-order-requests"
gemeldet_von: "[[christian-pulse]]"
supplier: "[[lab-peptides]]"
erstellt: 2026-04-23
zuletzt_aktualisiert: 2026-04-23
quelle: kalani-call + lab-peptides-pricelist
vertrauen: bestätigt
---

# Custom Order: Prostamax

## Status

**Wichtige Korrektur 2026-04-23:** Prostamax ist KEIN echtes Custom-Item, Lab Peptides hat es im regulären Sortiment unter Y63-5/Y63-10/Y63-20 (siehe [[lab-peptides]]).

**Aktueller Schritt:** Trotzdem beim Kunden Identifikator abfragen (CAS, alternativ PubChem CID, alternativ Sequenz), um sicherzustellen dass es um die KEDP-Tetrapeptid-Form geht und nicht um die pflanzliche Saw-Palmetto-Variante.

## Was ist Prostamax

**Synthetisches Tetrapeptid aus der Khavinson-Bioregulator-Familie**, entwickelt am St. Petersburg Institute of Bioregulation and Gerontology (Prof. Vladimir Khavinson).

| Attribut | Wert |
|---|---|
| Sequenz | Lys-Glu-Asp-Pro (KEDP) |
| Molekülformel | C₂₀H₃₃N₅O₉ |
| Molekulargewicht | 487.5 g/mol |
| PubChem CID | **9848296** |
| CAS-Nummer | **existiert nicht** (nicht in PubChem oder anderen großen Registries hinterlegt) |
| Synonyme | H-KEDP-OH, SCHEMBL6660498 |
| Klasse | Khavinson-Bioregulator, Cytomedin-Familie |
| Form | Lyophilisiert, typisch in 20mg Vials |

**Wirkungsbereich (Research-Only):** Prostata-Tissue-Repair, Chromatin-Decondensation, anti-aging Mechanismen via Heterochromatin-Öffnung. Verwandte Khavinson-Peptide: Epitalon (Pineal), Thymalin (Thymus), Vesugen (Vaskulär), Vilon, Livagen.

quelle: web_search 2026-04-23 (peptidesalpha.com, dosagepeptide.com, peptide-db.com), vertrauen: bestaetigt

## Verfügbarkeit bei Lab Peptides

| Code | Spec | USA | CN <100v | CN 100-2000v | CN 2001+v |
|---|---|---|---|---|---|
| Y63-5 | 5mg | 4.6 | 4.6 | 4.6 | - |
| Y63-10 | 10mg | 7.1 | 7.1 | 7.1 | - |
| Y63-20 | 20mg | 13.8 | 13.8 | 13.8 | - |

Keine Bulk-Discounts in der aktuellen Preisliste, Preis identisch über alle Mengen-Tiers.

## Wichtig: Verwechslungsgefahr

Es gibt einen **kompletten Namensdoppelgänger**: pflanzliche "ProstaMax" Supplements (oft Saw-Palmetto-Blends). Das ist NICHT das gleiche. Beim Kunden präzisieren ob es um die KEDP-Tetrapeptid-Form geht.

## Kundenanfrage (Stand 2026-04-23)

- Christian gemeldet 2026-04-20 in #custom-order-requests
- Reminder von Christian: Di 14:03, Mi (mehrfach)
- Bisher keine Antwort von Deniz an Christian

## Nächste Schritte (aus Call mit Kalani 2026-04-23)

- [ ] Standard-Antwort an Christian formulieren: Kunde nach **CAS-ID** fragen (vermutlich nicht vorhanden), alternativ **PubChem CID 9848296** oder **Sequenz KEDP** zur Bestätigung
- [ ] Wenn Kunde bestätigt = Khavinson KEDP: bei Lab Peptides ordern (Y63-5/Y63-10/Y63-20)
- [ ] Mengenanfrage mit Kalani klären, dann Order auslösen

## SOP-Ableitung Custom Orders

Dieser Fall ist Vorlage für die **Custom-Order-SOP** die im Call mit Kalani definiert wurde:

1. Kunde meldet Custom-Wunsch an Christian
2. Christian eskaliert in #custom-order-requests
3. **Deniz fragt zurück: CAS-ID, alternativ PubChem-CID, alternativ Sequenz** (statt direkt zu sourcen)
4. Mit Identifier in Preisliste der Supplier prüfen ([[lab-peptides]] zuerst)
5. Bei Verfügbarkeit: Mengen mit Kalani, dann Order

Update folgt in [[support-eskalation]] nach Call.
