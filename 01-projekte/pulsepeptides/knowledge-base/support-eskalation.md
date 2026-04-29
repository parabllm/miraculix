---
typ: wissen
projekt: "[[pulsepeptides]]"
thema: support-eskalation
status: aktiv
erstellt: 2026-04-17
zuletzt_aktualisiert: 2026-04-27
vertrauen: bestätigt
quelle: slack_logs + kalani_call_2026-04-23 + kalani_call_2026-04-24
---

# Support-Eskalation Christian an Deniz

**Schreibstil für alle Slack-Antworten an Christian/Kai/Kalani:** verbindlich geregelt im Skill `pulse-slack-schreibstil` (Projekt-Skill, im Claude Project Knowledge). Kein @-Tag, kein Bindestrich nach "Hey", "Thanks!" als Closing, kompakt und professionell-umgangssprachlich.

## Autonomie Christian

Was Christian selbst beantwortet und entscheidet (kein Deniz noetig):
- Standard-Kundenanfragen (Versand, Lieferzeit, Produktinfos)
- Failed Shipments / defekte Vials - Kai und Christian regeln direkt, kein Deniz noetig
- Compensation bei defekten Vials (extra Vials oder Coupon Code) - Christian entscheidet selbst
- **Affiliate-Anfragen ab 2026-04-23:** Christian kann Affiliates eigenständig accepten oder rejecten basierend auf 1.000 Follower Mindestcap (siehe unten)
- **Norway Express Shipping ab 2026-04-23:** Standardantwort UPS Express ab 49,15 EUR, keine separate Quote mehr nötig (siehe unten)

## Eskalations-Trigger (an Deniz)

- Custom Orders (Produkte nicht im Shop)
- Bulk-Pricing-Anfragen (B2B, Wholesale, Private-Label)
- Lab-Test-Anfragen mit Transitionsbezug (PulsePeptides → Axonpeptides)
- US-Shipment-Anfragen
- Alles was Supplier-Kommunikation erfordert

## Antwortwege

- Deniz antwortet direkt im Thread in Slack
- Schreibstil: siehe Skill `pulse-slack-schreibstil`

---

## Eskalationstypen

### Custom Orders (SOP ab 2026-04-23)

Christian meldet Kundenwunsch in #custom-order-requests wenn Produkt nicht im Shop.

**Prozess (aktualisiert 2026-04-23 nach Call mit Kalani):**

1. Christian postet in #custom-order-requests
2. **Deniz fragt zurück nach Identifier vom Kunden (in dieser Priorität):**
   - **CAS-Nummer** (primär)
   - **PubChem-CID** oder **PubMed-ID** (Fallback wenn CAS nicht existiert, z.B. bei Khavinson-Peptiden)
   - **Sequenz** (immer sinnvoll mitzugeben)
3. Mit Identifier: Prüfung ob Peptid im regulären Supplier-Sortiment (zuerst [[lab-peptides]] Preisliste checken, dann ZY, dann Testing-Badge-Supplier)
4. Wenn nicht findbar: beim Supplier direkt anfragen
5. Menge mit Kalani klären, dann Order auslösen
6. Christian informieren mit Status

**Wichtig:** Viele vermeintliche "Custom" Orders sind in Wahrheit im Lab-Peptides-Sortiment (Beispiel Prostamax = Y63). Deshalb IMMER zuerst in [[lab-peptides]] nachschauen.

**Bekannte Custom-/Standard-Produkte:**
- KPV Capsules (wechselt aktuell auf Testing-Badge-Supplier)
- Tirzepatide (Standard bei Lab Peptides, Code Q2)
- Retatrutide (Standard bei Lab Peptides, Code Q36)
- Prostamax (Standard bei Lab Peptides, Code Y63, nicht Custom)

**Offene Cases:** siehe `custom-orders/` Ordner im Projekt.

---

### Bulk-Pricing / B2B-Anfragen (neu 2026-04-23)

**Trigger:** Anfragen von Firmen die als Distributor, Reseller oder Wholesale-Partner auftreten wollen. Beispiele: Pepspan Ltd, potentielle zukünftige B2B-Partner.

**Aktuelle Pricing-Liste:** [[bulk-pricing]] (Christians v2, Stand 2026-04-27, Überarbeitung durch Deniz pending). NICHT direkt rausschicken, erst nach Review.

**Linie Pulse (Stand Call Kalani 2026-04-23):**

- **Tier-Pricing:** ab 300+ Vials pro SKU, darunter aktuell kein Bulk-Tier
- **Private Label:** NICHT verfügbar beim Startvolumen
- **Unlabeled Vials:** möglich, Cap-Color abhängig von internem Lagerbestand
- **Lead Time:** 5 Tage ODER 21 Tage, je nach Peptid und Lagerbestand
- **BPC-157 oral enteric-coated Capsules (500mcg/cap):** aktuell nicht verfügbar, neuer Batch in 30 Tagen
- **COA:** ja, mit unserem Namen. Wenn B2B-Partner COA unter eigenem Namen will, muss selbst testen lassen
- **Payment:** SEPA OK

**Prozess:**
1. Christian postet B2B-Anfrage in Slack, eskaliert an Deniz
2. Deniz holt aktuelle Bulk-Pricing-Liste von Christian ein bevor irgendwas kommuniziert wird
3. Deniz reviewt Liste und formuliert finale Antwort
4. Deniz oder Christian schickt raus

**Offener Fall Pepspan Ltd (Mikel Gastaminza):** siehe Meeting-Note [[2026-04-23-kalani-coo-call]], Block A. Christians Liste vom 2026-04-27 liegt vor (siehe [[bulk-pricing]]), Deniz muss sie überarbeiten bevor sie rausgeht.

---

### Affiliate-Anfragen (aktualisiert 2026-04-23)

Kanal: #affiliate-programm

**NEU ab 2026-04-23: Christian darf eigenständig entscheiden.**

**Regelung (Stand Call Kalani 2026-04-23):**

- **Mindest-Follower-Cap:** 1.000 Follower
- **Christian kann darunter rejecten, darüber accepten** ohne Deniz-Freigabe
- Nischen-Fit (Fitness/Body) bleibt weiterhin Kriterium

**Keine Test-Kits/Test-Batches an Affiliates (bestätigt im Call Kalani 2026-04-24):**
- Pulse gibt grundsätzlich keine kostenlosen Produktproben an Affiliates raus
- Begründung: schlechte Erfahrung gemacht, nicht alle Affiliates sind ehrlich in ihrem Feedback bzw. mit dem Umgang der Produkte
- Kommunikation nach außen: freundlich ablehnen, Erfahrungsgrund anführen ohne Namen zu nennen

**Deniz macht in der nächsten Zeit einen Affiliate-Review:** bestehende Affiliates durchgehen und neues Framework aufbauen (siehe [[coo-aufgaben]], Affiliate-Regelung mit No-Human-Use-Klausel).

**Bekannte Affiliates:**
- Valko_body: Instagram + TikTok, ~3k Follower, approved 2026-04-20
- Alanzooo6: TikTok, Anfrage 2026-04-20, approved (vor Cap-Entscheidung), wird im Review revidiert

**Zukünftiges Framework:** neue Affiliate-Terms mit expliziter No-Human-Use-Klausel und Research-Use-Only-Disclaimer-Pflicht in Affiliate-Posts. Details siehe [[coo-aufgaben]].

---

### US-Shipment-Anfragen

Kanal: #csupport-shipments

**Stand 2026-04-20:** US-Markt wird geprueft, kein konkreter Versand-Plan. Standardantwort an Kunden: "We are looking into supplying more of the US market. Do you have any specific requests open?"

Anfragen werden an Kalani weitergeleitet zur Entscheidung. Konkrete Schritte mit Kalani stehen aus, verschoben bis Kalani wieder fit ist (Lebensmittelvergiftung Stand 2026-04-23).

---

### Norway Express Shipping (SOP ab 2026-04-23)

Kanal: #csupport-shipments

**Standardantwort für Norwegen (bestätigt im Call Kalani 2026-04-23):**
- UPS Express, ab 49,15 EUR, Lieferzeit 1-2 Tage
- Funktioniert solange Adresse nicht "middle of nowhere"
- Kai bestätigt Adresse im Zweifel
- **Keine separate Quote mehr nötig**, das ist jetzt Standard (früher: manuelle Einzelquote weil Versand teurer als Website-Preis)

Christian kann das eigenständig an Kunden kommunizieren.

---

### Lab-Test-Anfragen (Transitionsbezug PulsePeptides → Axonpeptides)

**Regelung (bestätigt im Call Kalani 2026-04-24):**
- Bestehende Axon-COAs können für Verkäufe unter Axonpeptides genutzt werden, auch wenn der ursprüngliche Lab-Test noch unter PulsePeptides-Namen lief (z.B. Reta)
- In Zukunft werden eigene COAs unter Axonpeptides-Namen erstellt und gepflegt
- Christian kann das Axon-Zertifikat für transitionsbezogene Lab-Test-Anfragen direkt rausgeben

**Aktueller Fall Reta:** Axon-COA verwenden.

---

### Invoice Verification / Drittparteien-Anfragen

**Stand 2026-04-29**

**Trigger:** Externe Drittpartei (z.B. Buchhaltungsfirma, Steuerberater) bittet um Bestätigung einer Rechnung oder Bestelldetails - nicht der Kunde direkt.

**Regelung:**
- Keine Bestätigung ohne Anfrage direkt vom Kunden (registrierte E-Mail-Adresse)
- Vor Antwort prüfen: unter welcher Firma wurde die Invoice ausgestellt? Stimmt das mit der korrekten Legal-Entity überein?
- Christian braucht schriftliche interne Bestätigung vor jeder Antwort an externe Drittparteien
- Solche Anfragen NICHT in #general posten, direkt an Deniz per DM

**Standard-Antwort (bestätigt 2026-04-29, Case Invoice #7347, Buchhalterin von Uno Vita AS):**

> We can confirm that an order exists under the number #7347. However, we are only able to provide specific details once we receive a request directly from the customer's registered email address. At this stage, we can also clarify that the invoice in question does not match the format of our official invoice templates. Additionally, no sales were conducted through our Cyprus entity in November 2025, as this company was established after that date.

**Lernpunkt aus Case #7347:**
- Invoice war unter Cyprus-Entity ausgestellt, aber kein Verkauf lief dort im Nov 2025
- Cyprus-Entity existierte zu dem Zeitpunkt noch nicht
- Invoice-Format stimmte nicht mit offiziellem Template überein
- Kalani-Abstimmung ausstehend für Prozessformalisierung

---

### Defekte Vials / Failed Shipments

**Prozess:**
1. Christian meldet in Slack (oder kommt per E-Mail rein)
2. COO prueft den Fall kurz
3. COO schreibt Christian in Slack mit Empfehlung
4. Christian setzt Compensation um

**Compensation-Optionen:** Extra Vials desselben Peptids oder Coupon Code

**Grundhaltung:** Kunde nicht als Betrüger behandeln. Kann Produktionsfehler sein. Ziel: Kunde muss satisfied sein.

**Stil-Vorlage (COO an Christian):** siehe Skill `pulse-slack-schreibstil`, Beispiel 4.

> "Hey Christian, I just had a little look at some emails and this one caught my eye. If you haven't thought of it yourself already I think it would probably be good to offer him additional compensation considering the reshipment had subpar quality. Either additional vials of the same peptide or maybe a coupon code would sound fair to me for this case. Let me know what you think."

Ton: casual, professionell, konkrete Empfehlung als Vorschlag ("I think it would be good", "Let me know what you think"), keine direkte Anweisung.

---

## Log Call Kalani 2026-04-23

Folgende Regelungen/SOPs wurden im Call bestätigt oder neu definiert:
- Custom-Order-SOP mit CAS/PubChem/Sequenz-Abfrage
- Affiliate 1k Follower Cap, Christian autonom
- Norway Express Shipping Standard-SOP
- Bulk-Pricing-Linie für B2B-Anfragen
- Compensation-Vorlage bleibt wie gehabt

Details siehe Meeting-Note [[2026-04-23-kalani-coo-call]].
