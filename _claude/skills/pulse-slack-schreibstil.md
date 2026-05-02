---
name: pulse-slack-schreibstil
description: Verwende diesen Skill IMMER wenn Deniz eine Slack-Nachricht für PulsePeptides formulieren will, insbesondere an Christian, Kai oder Kalani. Triggert bei "schreib Christian", "schreib eine Nachricht an Christian", "Slack an Christian", "Antwort auf Christian", "schreib Kai", "Antwort an Kalani", "Slack-Nachricht Pulse", "PulsePeptides Slack", "antworte Christian", "Compensation-Nachricht", "Custom-Order-Antwort", "Affiliate-Antwort", "Support-Antwort", "Stock-Status an Kunde", "kommuniziere an Christian", "schreib das im Slack". Enthält den verbindlichen Schreibstil, Empfänger-Taxonomie, Erwartungsmanagement-Patterns und archivierte Beispiele aus echtem Pulse-Verkehr.
---

# Pulse Peptides Slack Schreibstil

Verbindlicher Stil für Slack-Nachrichten innerhalb des PulsePeptides-Teams. Gilt für alle Nachrichten die Deniz an Christian, Kai oder Kalani in Slack schreibt.

## Pflicht-Workflow VOR jeder Nachricht

1. **Erst Kontext aus dem aktuellen Chat sammeln.** Was ist die Anfrage, was wurde schon entschieden, was steht aus.
2. **Sprache des Empfaengers checken.** Siehe `01-projekte/pulsepeptides/knowledge-base/team-koordination.md` Sektion "Sprache pro Empfaenger" oder Mapping-Tabelle unten.
3. **Wenn Kontext fehlt: IMMER zuerst im Vault nachschauen** unter `C:\Users\deniz\Documents\miraculix\01-projekte\pulsepeptides\`. Relevante Files:
   - `knowledge-base/support-eskalation.md` (Eskalations-SOPs, Compensation-Vorlagen, Affiliate-Prozess, Custom-Order-Prozess, US-Shipments, Lab-Test-Transition)
   - `knowledge-base/team-koordination.md` (Sprache pro Empfaenger, Eskalationspfade)
   - `knowledge-base/bestellprozess.md`
   - `knowledge-base/lieferanten.md` (Supplier-Zustaendigkeit, Bestellkonventionen)
   - `knowledge-base/lab-peptides.md` (Lab Peptides Preisliste, alle Codes Y/Q/L)
   - `knowledge-base/lab-workflow-janoshik.md`
   - `knowledge-base/batch-testing-sop.md`
   - `coo-aufgaben.md`
   - `custom-orders/` (offene Custom-Order-Cases)
   - `logs/` (Meeting-Notes mit Kalani, vergangene Entscheidungen)
4. **Bei Slack-Threads optional Slack-Search nutzen** um vorherige Nachrichten und aktuellen Thread-Stand zu pruefen, besonders wenn Deniz auf eine bestehende Anfrage antwortet.
5. **Erst dann Nachricht formulieren.** Nie blind raten.

## Sprache pro Empfaenger

Master-Quelle: `team-koordination.md` Sektion "Sprache pro Empfaenger". Hier als Schnellreferenz:

| Person | Channel | DM | Notiz |
|---|---|---|---|
| Kalani | Englisch | Deutsch (Sparring) | Strategisches Sparring auf Deutsch privat |
| Christian | Englisch | Englisch | Auch DM Englisch |
| Kai | Deutsch | Deutsch | Immer Deutsch, locker |
| Patrick | offen | offen | noch nicht etabliert, im Zweifel fragen |

Englische Nachrichten haben einen anderen Stil als deutsche. Beide Stile sind unten dokumentiert.

## Empfaenger-Taxonomie (Modus-Logik)

Vor dem Formulieren wird der Empfaenger-Modus bestimmt. Vier Modi mit klar unterschiedlichem Stil. Modi gelten unabhaengig von Sprache.

### Modus A: Empfaenger (final)

Christian/Kai/Kalani ist die letzte Station. Sie entscheiden, setzen um, archivieren intern.

Stil: volle Info, Begruendung, Kontext. Empfehlung als Vorschlag, nicht Anweisung.

Englisch-Beispiel:
> Hey, agreed on the 1k follower cap. From now on you can reject or accept affiliates based on that threshold. I'll sit down in the coming days and review the current affiliates as well, since we need to build out a new framework around this. Thanks!

Deutsch-Beispiel (an Kai):
> Hey Kai, wir wollen die naechsten Batches von PT-141 und DSIP an Janoshik schicken fuer HPLC und Endotoxin Tests. Wie habt ihr das bisher gemacht? Gibst du mir einfach nur die Tracking Nummer und ich gebe das an Janoshik weiter und wann wuerdest du es rausschicken koennen? Vielen Dank :smile:

### Modus B: Messenger (Weiterleitung an Dritten)

Empfaenger leitet die Nachricht an einen Kunden, Affiliate oder Supplier weiter, oft als Zitat oder Paraphrase.

Stil: Kurzlinie. Imperativ-Format ("tell him X", "let him know X", "you can tell them X"). Keine interne Begruendung, die landet sonst beim Dritten. Alternative oder Folge-Pfad mitgeben damit Christian nicht mit leeren Haenden dasteht.

Beispiel:
> Hey, tell him we don't ship out free samples. If he still wants to promote, the standard affiliate terms apply. Thanks!

### Modus C: Gemischt (Empfaenger und Messenger)

Christian fragt eine Status-Sache, deine Antwort ist gleichzeitig die Linie fuer Kundenkommunikation. Haeufig bei Stock-Status, Roadmap-Anfragen, Brand-Transitions.

Stil: Saetze so formulieren dass Christian sie kopieren kann. "you can communicate to customers that..." oder "Please feel free to communicate that..." als Schluesselwendung.

Beispiel:
> Hey, you can communicate to customers that credit card payments will be available on the website soon. I'll keep you posted on the exact date.

### Modus D: DM-Sparring mit Kalani

Strategische Vorab-Klaerung in der DM mit Kalani, bevor im oeffentlichen Channel ausgefuehrt wird.

Stil: Deutsch, kurz, Frage-Format. Keine Hyper-Hoeflichkeit, das ist Sparring. Im oeffentlichen Channel danach Englisch und finale Linie.

Beispiel:
> Hallo, was gebe ich Christian bezueglich der KPV Kapseln weiter bzw. was ist unsere Position. Wollen wir KPV in Zukunft einfuehren?

**Entscheidungsregel** fuer die ersten drei Modi:

- Wird die Nachricht spaeter vom Empfaenger an einen Kunden/Affiliate/Supplier zitiert oder paraphrasiert? -> Modus B (Messenger), Kurzlinie
- Ist die Nachricht fuer den Empfaenger selbst (Prozess, Entscheidung, Rueckfrage)? -> Modus A (Empfaenger), volle Info
- Beides gleichzeitig? -> Modus C (Gemischt), Wendungen wie "you can communicate"
- Strategische Klaerung mit Kalani vor oeffentlicher Kommunikation? -> Modus D (DM-Sparring), Deutsch

## Stil-Regeln Englisch

### Form

- **KEINE @-Tags.** Niemals jemanden taggen. Wenn Deniz jemanden taggen will, macht er das selbst.
- **KEIN Bindestrich nach "Hey".** Falsch: "Hey - on the affiliate". Richtig: "Hey, on the affiliate".
- **"Hey" als Eroeffnung ist erlaubt.** Auch "Hey [Name]" wenn Name noetig (selten, da kein Tag).
- **"Thanks!" am Ende ist Standard.** Locker, freundlich, kurzes Closing.
- **Kein "Hey" bei reinen Faktenfragen im laufenden Thread.** Wenn die Vorfrage technisch ist und im Channel klar ist worum es geht, reicht der Direkt-Antwort. Beispiel: "What mg can we go from our supplier?" -> "10mg and 20mg" ohne "Hey,".

### Inhalt

- **Englisch im Channel** fuer Christian und Kalani-Channel-Posts.
- **Kompakt.** Eine Nachricht beantwortet eine Sache. Keine Romane.
- **Nur relevanter Kontext.** Interne SOPs, Standardprozesse, Hintergrund den der Empfaenger eh kennt: NICHT wiederholen.
- **Professionell aber umgangssprachlich.** Keine Steifheit, kein Business-Englisch wie "Per my last email", "Kindly find attached", "Please be advised". Stattdessen: natuerliches, direktes Englisch.
- **Konkret.** Empfehlung oder Entscheidung als Vorschlag formulieren, nicht als Anweisung. "I think it would be good to..." / "Let me know what you think." statt "Do this."
- **Modus-Pattern beruecksichtigen.** Wenn Christian nur weiterleitet: Kurzlinie statt volle Erklaerung.

## Stil-Regeln Deutsch (an Kai oder Kalani-DM)

Deutscher Stil ist anders als englischer. Lockerer, fragender, freundlicher. Emojis erlaubt.

### Form

- **"Hey [Name]" als Eroeffnung.** Mit Komma danach, kein Gedankenstrich.
- **"Vielen Dank" oder "Danke" als Closing**, nicht "Thanks!".
- **Emojis sind OK.** Besonders :smile: am Ende, signalisiert lockere Tonalitaet. Nicht uebertreiben, ein Smiley reicht meist.
- **Echte Umlaute (ae oe ue ss als Ersatz nur in PowerShell oder Skill-Files erlaubt, in Slack immer ae oe ue oder echte Umlaute je nach Tastatur).**
- **KEINE @-Tags.** Niemals jemanden taggen.

### Inhalt

- **"wir" statt "ich"** wo es um Pulse-Entscheidungen geht. "wir wollen" statt "ich will".
- **Direkt fragend.** "Wie habt ihr das bisher gemacht?" "Wann wuerdest du es rausschicken koennen?" Konkrete Frage statt Fuellsatz.
- **Keine Vor-Annahmen aufdraengen.** "Falls es einfacher ist..." oder ueberredende Floskeln raus. Stattdessen direkt fragen wie der andere es sich vorstellt.
- **Locker-professionell.** Pulse-Team ist klein, Tonalitaet bleibt freundlich aber nicht steif. Kein "Bitte teilen Sie mir mit...", stattdessen "Sag Bescheid".
- **Kompakt wie im Englischen.** Eine Sache pro Nachricht.

### Verbotene Floskeln Deutsch

- "Beste Gruesse" / "Mit freundlichen Gruessen" -> zu formell
- "Bitte teilen Sie mir mit" / "Bitte lassen Sie mich wissen" -> zu Sie-formell
- "Falls es einfacher ist" / "Falls moeglich" -> wirkt zoegernd
- "Ich wuerde gerne uebernehmen" -> ueberredende Selbst-Positionierung, raus

### Kontext-Anker-Regel (gilt fuer beide Sprachen)

"on the X inquiry:" oder "wegen X:" nur einbauen wenn der Thread alt ist (>2 Tage Luecke) oder das Thema nach Pause neu reaktiviert wird. Bei laufendem aktiven Austausch direkt zur Sache, sonst wirkt es redundant.

### Erwartungsmanagement bei Verzoegerung

Drei Patterns je nach Situation, bei beiden Sprachen anwendbar.

**Pattern 1: Kurz-Ack vor substanzieller Antwort.** Wenn Antwort jetzt nicht moeglich ist aber Empfaenger wartet, kurze Status-Nachricht senden.

Englisch:
> Hey, syncing with Kalani today, will get back to you right after.

Deutsch:
> Hey Kai, ich klaere das gerade mit Kalani, melde mich gleich wieder.

**Pattern 2: Konkretes Folge-Datum.** Wenn ein Reminder kam oder Pause unvermeidbar ist, Datum nennen statt vage zu bleiben.

**Pattern 3: "Sorry for the delayed response" / "Sorry fuer die spaete Antwort" als Opener.** Wenn Deniz selbst sagt dass er lange nicht geantwortet hat, ODER aus dem Slack-Kontext sichtbar ist dass der Empfaenger gewartet hat.

### Eskalation bei strategischer Unsicherheit

Wenn die Antwort eine strategische Entscheidung von Kalani braucht und Deniz selbst nicht entscheiden kann oder will:

1. Im selben Thread Kalani taggen mit kurzer Frage (Englisch, weil oeffentlich)
2. Parallel an Christian eine Safe-Default-Antwort die er Kunden weitergeben kann

### Stock und Payment

Wenn Christian fragt ob Payment vom Kunden genommen werden kann waehrend Stock unsicher ist: **klare Block-Regel**, kein Kompromiss.

> We are looking to have KPV in stock in two weeks. No payment until the stock is confirmed and in place.

### Reine Faktenfragen

Bei reinen Spec-Fragen im laufenden Thread (z.B. Custom-Order-Detail-Klaerung): reine Faktenantwort, kein Padding.

Frage: "What mg can we go from our supplier?"
Antwort: "10mg and 20mg"

Kein "Hey", kein Smalltalk, kein Closing. Pattern fuer reine Spec-Fragen im Custom-Order-Kanal oder aehnlich.

## Verbotene Inhalte (HARTE Regel, ab 2026-05-02)

Unabhaengig von Sprache und Modus: bestimmte Informationen gehen nie ins Slack, egal an wen.

### Niemals an Christian (oder Kai)

- **EK-Preise.** Einkaufspreise bei Lab Peptides, ZY, XiAN Sheerherb oder anderen Suppliern. Ab 2026-05-02 striktes Embargo, gilt rueckwirkend auch wenn frueher mal Preise geleakt wurden.
- **Margen-Kalkulationen.** Cost-zu-Sale-Spannen, Profit pro Vial, Cost-Floors die nicht offiziell freigegeben sind.
- **Interne Bulk-Pricing-Linien die noch nicht final sind.** Drafts, Christians v2 mit Kalani-Konflikt-Notes, eigene Vorab-Berechnungen. Erst freigegeben durch Kalani plus Deniz wird kommuniziert.
- **Supplier-Lead-Times** wenn diese strategisch relevant sind und nicht freigegeben.

### Wann Christian fragt nach EK oder internen Preisen

Nicht direkt antworten. Optionen:
- Ablenken auf Verkaufsseite: "For B2C/B2B pricing the website rates apply"
- Eskalieren: "Let me sync with Kalani on this"
- Stumm lassen wenn der Kontext es zulaesst

Nie Zahlen rausgeben, auch nicht naeherungsweise oder "ungefaehr".

### Was Christian bekommen darf

- B2C-Verkaufspreise von der Website
- Final freigegebene B2B-Bulk-Pricing-Liste (z.B. v3, signed off durch Kalani plus Deniz)
- Versandkosten und Shipping-Optionen
- Stock-Status (in stock, out, naechster Restock)

### Grund

Christian ist Support, nicht Sourcing. EK-Preise im falschen Kontext (Kunden-Mail, Affiliate-Pitch) leaken externer und schwaechen die Verhandlungsposition mit Suppliern. Compliance-Risiko nicht zu unterschaetzen.

## Anti-Muster (NICHT verwenden, beide Sprachen)

- KEIN "agreed!" mit Ausrufezeichen am Anfang. Stattdessen "agreed on..."
- KEIN "1k isn't a hard cap" oder aehnlich umgangssprachliche Slang-Wendungen die unprofessionell wirken
- KEINE Smileys oder Emojis bei englischen Nachrichten ausser Deniz fragt explizit danach. Bei deutschen Nachrichten an Kai sind Emojis OK.
- KEIN "Best", "Cheers", "Regards" als Closing (zu formell)
- KEIN "FYI", "ASAP", "EOD" Acronym-Spam
- **KEIN Ausschweifen wenn Christian/Kai nur die Kurzlinie zum Weitergeben braucht.**
- **KEIN "on the X inquiry:" wenn der Thread aktiv ist.** Macht den Satz redundant.
- **KEIN falscher Konkretheits-Schein.** Bei offenen Daten lieber "soon" plus "I'll keep you posted" als ein erfundenes Datum.
- **KEINE Begruendung in Messenger-Nachrichten.** Was Christian an einen Affiliate weitergibt, soll keine internen Argumente enthalten ("we've had bad experiences..."). Die Begruendung steht im Vault.
- **KEIN Druck auf Kunden-Payment** wenn Stock unsicher ist.
- **KEINE Selbst-Positionierung** wie "ich wuerde das gerne uebernehmen". Direkt fragen ohne Vor-Story.

## Format-Vorlagen

### Modus A Englisch
```
Hey, [direkt zum Punkt]. [Inhalt: Entscheidung, Empfehlung, oder Frage]. [optional: naechster Schritt]. Thanks!
```

### Modus A Deutsch (an Kai)
```
Hey [Name], [direkt zum Punkt]. [Frage(n) konkret formuliert]. Vielen Dank :smile:
```

### Modus B Englisch
```
Hey, tell him [Kurzlinie]. [optional: Alternative oder Zusatzhinweis]. Thanks!
```

### Modus C Englisch
```
Hey, you can communicate to customers that [Linie]. [optional: Versprechen fuer Follow-Up].
```

### Modus D: DM-Sparring mit Kalani (Deutsch)
```
Hallo, [Frage oder Anliegen]. [optional: Was-tun-Frage]
```

### Bei verzoegerter Antwort Englisch
```
Sorry for the delayed response, [direkt zum Punkt]. [Inhalt]. Thanks!
```

### Bei verzoegerter Antwort Deutsch
```
Sorry fuer die spaete Antwort, [direkt zum Punkt]. [Inhalt]. Danke!
```

### Reine Spec-Antwort
```
[Faktenwert]
```

## Beispiele aus echten Pulse-Nachrichten

### Beispiel 1: Affiliate Follower-Cap bestaetigen, 2026-04-23, Modus A Englisch

> Hey, agreed on the 1k follower cap. From now on you can reject or accept affiliates based on that threshold. I'll sit down in the coming days and review the current affiliates as well, since we need to build out a new framework around this. Thanks!

Warum gut: kompakt, direkt, "agreed on" statt "agreed!", konkrete Handlungsanweisung an Christian, Ausblick auf eigene naechste Schritte, freundliches Closing.

### Beispiel 2: Custom-Order-Anfrage Update, 2026-04-23, Modus A Englisch

> Hey, I've reached out to one of our suppliers to confirm availability and pricing on Prostamax. While we wait for their reply, can you ask the customer how many vials they're looking to order? That way we can move quickly once we hear back. Thanks!

### Beispiel 3: Bulk-Pricing intern abstimmen, 2026-04-23, Modus A mit Kontext-Anker

> Hey, on the Pepspan inquiry: can you send me our current bulk pricing list? I'd like to review it before we send anything out. Thanks!

### Beispiel 4: Pepspan Liste freigeben, 2026-04-28, Modus B im aktiven Thread

> Here is the updated bulk pricing list, you can send it over to them. Thanks!

### Beispiel 5: Compensation-Empfehlung, Modus A

> Hey Christian, I just had a little look at some emails and this one caught my eye. If you haven't thought of it yourself already I think it would probably be good to offer him additional compensation considering the reshipment had subpar quality. Either additional vials of the same peptide or maybe a coupon code would sound fair to me for this case. Let me know what you think.

### Beispiel 6: Affiliate Test-Batch ablehnen, 2026-04-24, Modus B

> Hey, tell him we don't ship out free samples. If he still wants to promote, the standard affiliate terms apply. Thanks!

### Beispiel 7: Reta Lab-Test Transition, 2026-04-24, Modus B mit Verzoegerungs-Opener

> Sorry for the delayed response, on the Reta lab test: you can use the Axon COA and send it over, that's fine for the transition period. Going forward we'll have dedicated Axon COAs for new batches. Thanks!

### Beispiel 8: KPV Stock Status, 2026-04-20, Modus C

> We currently do not have KPV in stock, but we are planning to include it in our next order. Please feel free to communicate that KPV capsules will be available soon.

### Beispiel 9: Credit Card Processor Status, 2026-04-27, Modus C

> Hey, you can communicate to customers that credit card payments will be available on the website soon. I'll keep you posted on the exact date.

### Beispiel 10: US-Shipment Eskalation, 2026-04-20

Tag an Kalani im Thread:
> @senseikalani What is our current take on US shippments?

Parallel an Christian:
> We are looking into supplying more of the US market. Do you have any specific requests open?

### Beispiel 11: Reine Spec-Antwort, 2026-04-27

Frage: "What mg can we go from our supplier?"
Antwort:
> 10mg and 20mg

### Beispiel 12: DM-Sparring mit Kalani, 2026-04-20, Modus D auf Deutsch

> Hallo, was gebe ich Christian bezueglich der KPV Kapseln weiter bzw. was ist unsere Position. Wollen wir KPV in Zukunft einfuehren?

### Beispiel 13: Telefonnummer-Austausch in DM, 2026-04-17

> Hi Christian, yeah of course I will text you now so you have my number.

### Beispiel 14: Zwei-Stufen-Antwort bei Kapazitaetsproblem, 2026-04-23

Erste Stufe (Kurz-Ack):
> Hey, syncing with Kalani today, will get back to you right after.

Zweite Stufe (substantiell, spaeter am Tag):
> I've reached out to one of our suppliers to confirm availability and pricing on Prostamax. While we wait for their reply, can you ask the customer how many vials they're looking to order? Thanks!

### Beispiel 15: Erstkontakt an Kai zu Janoshik-Tests, 2026-04-30, Modus A Deutsch

> Hey Kai, wir wollen die naechsten Batches von PT-141 und DSIP an Janoshik schicken fuer HPLC und Endotoxin Tests. Wie habt ihr das bisher gemacht? Gibst du mir einfach nur die Tracking Nummer und ich gebe das an Janoshik weiter und wann wuerdest du es rausschicken koennen? Vielen Dank :smile:

Warum gut: deutsch weil Kai immer auf Deutsch angesprochen wird. "Hey Kai," als Opener mit Komma. "wir wollen" statt "ich will". Direkt fragend "Wie habt ihr das bisher gemacht?" anstatt Vor-Annahmen ("Falls es einfacher ist"). Konkrete zweite Frage zum Versand-Zeitpunkt. "Vielen Dank :smile:" als Closing, lockerer Ton.

## Wenn Deniz dir den Inhalt diktiert

Wenn Deniz dir sagt "schreib das so und so", dann:
1. **Inhalt uebernehmen, Form anpassen.** Deniz' Punkte bleiben drin, du polierst nur Sprache und Stil.
2. **Nicht kuenstlich verkuerzen.** Wenn Deniz drei Punkte ansprechen will, kommen drei Punkte rein.
3. **Nicht kuenstlich verlaengern.** Wenn Deniz nur einen Punkt will, halt es kurz.
4. **Kein zusaetzlicher Kontext den Deniz nicht erwaehnt hat.** Auch wenn du im Vault was Relevantes findest: nur einbauen wenn Deniz es will oder es absolut zur Klarheit gehoert.
5. **Modus-Check.** Wenn Deniz eine Entscheidung diktiert die an einen Dritten gerichtet ist (Kunde, Affiliate): default Modus B (Messenger), nicht interne Begruendung mitschicken.
6. **Sprach-Check.** Empfaenger checken: an Kai immer Deutsch, an Christian Englisch, an Kalani je nach Channel/DM.
7. **Kontext-Anker-Check.** Wenn Thread aktiv ist und Empfaenger gerade selbst gefragt hat: kein "on the X inquiry:" / "wegen X:" einbauen.

## Sprache und Tonalitaet an Empfaenger und Kanal anpassen

| Konstellation | Sprache | Tonalitaet |
|---|---|---|
| Channel-Post an Christian (Empfaenger oder Messenger) | Englisch | locker-professionell |
| Channel-Post mit Kalani-Tag (oeffentliche Eskalation) | Englisch | knapp, fragend |
| Channel- oder DM-Post an Kai | Deutsch | locker-freundlich, Emojis OK |
| DM Christian | Englisch, leicht entspannter | freundlich-direkt |
| DM Kalani | Deutsch | sparring, kurz |
| Reine Spec-Antwort im Thread | Sprache wie Frage | Fakten only |

## Ausgabe-Format

Nutze IMMER das `message_compose_v1` Tool fuer Slack-Nachrichten an Pulse-Team. `kind: "other"`, `summary_title` mit "Slack an [Name]: [Thema]". Eine Variante reicht in der Regel, nur mehrere Varianten anbieten wenn es echte strategische Alternativen gibt (z.B. "rip the bandaid" vs "soften the landing").

## Cross-Reference

- Sprache pro Empfaenger: `01-projekte/pulsepeptides/knowledge-base/team-koordination.md` Sektion "Sprache pro Empfaenger" (SSOT)
- Eskalations-SOPs: `01-projekte/pulsepeptides/knowledge-base/support-eskalation.md`

Beispiele aus echtem Pulse-Verkehr archiviert in:
`01-projekte/persoenlich/kommunikation-referenzen/slack/`
