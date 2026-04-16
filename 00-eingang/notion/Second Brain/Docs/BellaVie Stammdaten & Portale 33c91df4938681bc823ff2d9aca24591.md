# BellaVie Stammdaten & Portale

Created: 9. April 2026 00:24
Doc ID: DOC-28
Doc Type: Reference
Gelöscht: No
Last Edited: 9. April 2026 00:24
Lifecycle: Active
Notes: Stammdaten + Beschreibungen + Plattform-Credentials für lokale SEO. Semi-statisch. Dynamische Status-Updates leben in Logs + Tasks.
Project: BellaVie (../Projects/BellaVie%2033c91df4938681889034d53da9eb6839.md)
Stability: Volatile
Verified: No

## Scope

Stammdaten (NAP), Unternehmensbeschreibungen und Plattform-Credentials für alle lokalen SEO-Portale von BellaVie.

## Architecture / Constitution

- **NAP-Konsistenz:** Überall exakt gleiche Schreibweise (Name, Address, Phone) verwenden
- **Passwort-Konvention:** Platzhalter `[BELLAVIE_STANDARD_PW]` in diesem Doc. Echtes Passwort liegt in Bitwarden/1Password.
- **Inhaber-Accounts:** Maddox' persönliche iCloud bzw. geschäftliche Mail-Accounts

## Stammdaten (NAP — überall exakt so verwenden)

| Feld | Wert |
| --- | --- |
| **Unternehmensname** | BellaVie |
| **Kategorie** | Friseursalon |
| **Adresse** | Hüttenbergstraße 29, 66538 Neunkirchen |
| **Telefon** | 06821 3091406 |
| **E-Mail (Geschäft)** | [kontakt@bellavie-nk.de](mailto:kontakt@bellavie-nk.de) |
| **Website** | [https://www.bellavie-nk.de](https://www.bellavie-nk.de) |
| **Buchungs-Link (Fresha)** | [https://www.fresha.com/book-now/bellavie-pi4dfs0f/all-offer?share=true&pId=2820480](https://www.fresha.com/book-now/bellavie-pi4dfs0f/all-offer?share=true&pId=2820480) |
| **Öffnungszeiten Mo–Fr** | 10:00 – 18:00 Uhr |
| **Öffnungszeiten Sa** | 09:00 – 16:00 Uhr |
| **Öffnungszeiten So** | Geschlossen |
| **Instagram** | @bella_v_nk |
| **Gründungsjahr** | 2025 |

## Beschreibungen

### Kurzbeschreibung (für Google, ~230 Zeichen)

Von Haarschnitt & Balayage über Nageldesign, Lash & Brow bis hin zu Permanent Make-up und Sugaring: BellaVie in Neunkirchen vereint alles unter einem Dach. Handwerkskunst auf höchstem Niveau, die deine natürliche Ausstrahlung unterstreicht.

### Langbeschreibung (für Cylex, Verzeichnisse)

BellaVie ist Neunkirchens einziger Full-Service Beauty-Salon mit einem vollständig integrierten Leistungsangebot. Wir bieten professionelle Haarschnitte, Colorationen, Balayage und Haarpflege-Treatments wie Keratin und Botox. Dazu kommen Maniküre, Pediküre und Nageldesign, Wimpernverlängerung, Lash Lifting, Brow Lifting sowie Permanent Make-up für Brauen, Augen und Lippen. Ergänzt wird unser Angebot durch schonende Haarentfernung mit Sugaring. Unser Team aus 6 Fachkräften arbeitet mit Premium-Produkten von Redken und Kerra Queens. Termine können bequem online über Fresha gebucht werden.

## Plattform-Zugangsdaten

| Plattform | E-Mail / Account | Inhaber |
| --- | --- | --- |
| **Google Business Profile** | [bellavie_nk@gmx.de](mailto:bellavie_nk@gmx.de) | — |
| **Apple Business Connect** | [yakymenskyy@icloud.com](mailto:yakymenskyy@icloud.com) | Maddox Yakymenkyy |
| **Bing Places** | [kontakt@bellavie-nk.de](mailto:kontakt@bellavie-nk.de) | — |
| **Gelbe Seiten** | [yakymenskyy@icloud.com](mailto:yakymenskyy@icloud.com) | Maddox Yakymenkyy |
| **Das Örtliche** | [yakymenskyy@icloud.com](mailto:yakymenskyy@icloud.com) | Maddox Yakymenkyy |
| **Das Telefonbuch** | — | Auto-Übernahme von Das Örtliche |
| [**11880.com**](http://11880.com) | [kontakt@bellavie-nk.de](mailto:kontakt@bellavie-nk.de) | — |
| [**kennstdueinen.de**](http://kennstdueinen.de) | [kontakt@bellavie-nk.de](mailto:kontakt@bellavie-nk.de) | Maddox Yakymenkyy |
| **Cylex** | [kontakt@bellavie-nk.de](mailto:kontakt@bellavie-nk.de) | — |
| **Yelp** | [kontakt@bellavie-nk.de](mailto:kontakt@bellavie-nk.de) | — |
| **Treatwell** | — | Übersprungen (Fresha vorhanden) |
| **Facebook Business** | — | Wird von anderem Team-Mitglied gemanaged |
| **Fresha** | — | Aktiv |

> Passwort-Platzhalter: `[BELLAVIE_STANDARD_PW]` — echtes Passwort in Bitwarden/1Password.
> 

## Eingetragene Daten pro Plattform (Checkliste)

### Google Business Profile

- [x]  Name, Adresse, Öffnungszeiten, Fotos, Beschreibung, Website, Buchungs-Link
- [x]  Kategorie: Friseursalon + 4 Zusatzkategorien, Attribute gesetzt, Verifiziert
- [ ]  Services/Leistungen eintragen
- [ ]  Reserve with Google aktivieren (nach DNS-Setup)

### Apple Business Connect

- [x]  Account erstellt, Unternehmensdaten, Öffnungszeiten
- [ ]  DNS TXT-Eintrag bei GoDaddy
- [ ]  USt-IdNr. eintragen
- [ ]  Verifizierung abschließen

### Bing Places

- [x]  Google-Import, Verifiziert

### Gelbe Seiten, Das Örtliche, [11880.com](http://11880.com), [kennstdueinen.de](http://kennstdueinen.de), Cylex, Yelp

- [x]  Eintrag erstellt
- [ ]  Bestätigung ausstehend (je nach Portal)

### Das Telefonbuch

- [ ]  Auto-Übernahme von Das Örtliche abwarten

> Dynamische Status-Updates zu einzelnen Portalen leben in Logs + Tasks, nicht hier.
>