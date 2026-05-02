---
typ: vault-mcp-artefakt
erstellt: 2026-05-01 19:51
quelle_geraet: mobile-handy
quelle_konversation: pulse-status-update-whatsapp-xian
ziel_pfad: 01-projekte/pulsepeptides/logs/2026-05-01-whatsapp-xianherb-pricing-inquiry.md
ziel_aktion: neue-datei
idempotenz_key: 2026-05-01-1951-whatsapp-xianherb-pricing
body_sha256: 4876dc4c0dc6272c110a243eff522582512674281562b6c6a617b23329444002
status: bereit-zum-mergen
verlinkungen_einbauen:
  - in: 01-projekte/pulsepeptides/knowledge-base/xian-sheerherb.md
    sektion: "Aktueller Stand"
    ziel_heading_ebene: 2
    text: "[[2026-05-01-whatsapp-xianherb-pricing-inquiry]] - Vivian uebernimmt Pricing-Anfrage, Deniz hat 300 Bottles je Produkt (BPC-157 Caps, 5-Amino-1MQ, KPV) angefragt"
pc_anweisung: |
  Konvention: Pulse-Chat-Logs (Slack, WhatsApp, DMs) liegen in
    01-projekte/pulsepeptides/logs/ nach Pattern YYYY-MM-DD-{thema}.md mit
    typ: log und Frontmatter-Feld kanal. Format-Vorbild ist
    2026-04-29-slack-invoice-verification-7347.md (Slack-Thread mit
    Kontext, Thread-Wiedergabe, Lernpunkte, Offene Punkte).
  Inhalt: WhatsApp-Gruppe "Pulse x XianHerb" Pricing-Inquiry. Quelle ist
    Screenshot vom 2026-05-01 19:47 den Deniz mit hochgeladen hat.
    Vivian (XiAN-Seite) ist NEUER Kontakt, war bisher nicht in
    [[xian-sheerherb]] gefuehrt - dort sollte sie als zweiter Kontakt
    ergaenzt werden, Rolle und Verhaeltnis zu Pax noch zu klaeren.
  Referenz-Files:
    - 01-projekte/pulsepeptides/logs/2026-04-29-slack-invoice-verification-7347.md
      (Format-Vorbild)
    - 01-projekte/pulsepeptides/knowledge-base/xian-sheerherb.md
      (Hintergrund, soll via verlinkungen_einbauen aktualisiert werden)
  Sondierungs-Tools:
    - vault_get_project_state("pulsepeptides")
    - vault_list_directory("01-projekte/pulsepeptides", depth=2)
    - vault_read_file der Slack-Invoice-Note als Format-Referenz
    - vault_list_eingang()
  Annahmen:
    - Wikilink [[xian-sheerherb]] zeigt auf
      01-projekte/pulsepeptides/knowledge-base/xian-sheerherb.md - exists
      (geprueft via vault_get_project_state der pulsepeptides.md, dort
      explizit referenziert).
    - Wikilink [[kalani-ginepri]] zeigt auf bekannten Kontakt aus
      pulsepeptides-Hauptfile.
    - Wikilink [[2026-05-01-kalani-call]] zeigt auf bestehende Note die
      parallel ein Status-Update bekommt.
    - verlinkungen_einbauen-Block: Wenn xian-sheerherb.md keine Sektion
      "Aktueller Stand" hat, soll PC-Claude sinnvoll umentscheiden
      (z.B. neue Sektion oder Verlinkung in eine vorhandene Status-Sektion
      einbauen). Nicht zwangsweise neue Sektion anlegen wenn Konvention
      anders ist.
  Risiken:
    - Vivian-Eintrag in xian-sheerherb.md ist NICHT Teil dieses Artefakts -
      sollte separat angelegt werden nach Klaerung mit Deniz (Vorname
      Vivian, Nachname unbekannt, Rolle unbekannt). PC-Claude bitte beim
      Merge nachfragen ob Vivian-Kontakt-Sektion gleich mit angelegt
      werden soll.
    - Quelle "WhatsApp-Screenshot" - Original-PNG liegt in der
      Konversation als IMG_7132.png, kein Vault-Anhang. Bei Bedarf
      koennte das Bild nach _anhaenge/projekte/pulsepeptides/ kopiert
      werden, ist aber kein Muss.
---

<!-- ALLES UNTER DIESER ZEILE IST DIE FERTIGE DATEI. -->

---
typ: log
projekt: "[[pulsepeptides]]"
datum: 2026-05-01
kanal: "WhatsApp Pulse x XianHerb"
thema: "Pricing-Inquiry BPC-157 Caps, 5-Amino-1MQ, KPV"
beteiligte: ["[[kalani-ginepri]]", "Vivian (XiAN Sheerherb)", "Deniz"]
erstellt: 2026-05-01
aktualisiert: 2026-05-01
quelle: whatsapp_screenshot_2026-05-01_1947
vertrauen: extrahiert
---

# WhatsApp-Thread: Pulse x XianHerb Pricing-Inquiry (2026-05-01)

## Kontext

Gruppe "Pulse x XianHerb" (Teilnehmer: Kalani, Vivian, Deniz, Pax) wurde 2026-04-28 von Kalani angelegt. Inquiry-Thema: BPC-157 Caps, 5-Amino-1MQ, KPV. Pax sollte Detail-Klaerung uebernehmen, hat sich aber nicht aktiv gemeldet. Vivian (XiAN-Seite) hat 2026-04-29 nach Mengen gefragt. Deniz hat heute 2026-05-01 17:33 mit konkreter Mengenangabe geantwortet und um Pricing gebeten.

Hintergrund-File: [[xian-sheerherb]]. Bezug zum aktuellen Backlog: KPV-Supplier-Wechsel von ZY zu XiAN, BPC-157 Caps und 5-Amino-1MQ als neue Produkte.

## Thread

**Kalani, 2026-04-28 16:20:**
"Hey ! So we are interested in new BPC-157 Caps"
"I added @Pax he will be taking over for me on some details"
"also 5-Amino-1MQ and KPV"

**Deniz, 2026-04-28 16:22:**
"Hey, nice to meet you guys"

**Vivian, 2026-04-29 08:00:**
"Hi, nice to meet you too"

**Vivian, 2026-04-29 08:01:**
"Could you tell me how much additional amount you need? So that I can give you a better quote."

**Deniz, 2026-05-01 17:33 (edited):**
"Hey Vivian, we'd need 300 bottles each for BPC-157 Caps, 5-Amino-1MQ and KPV. Could you share some pricing for those?"

## Lernpunkte

- Vivian (XiAN-Seite) ist neuer Kontakt, war bisher nicht in [[xian-sheerherb]] gefuehrt. Pax und Vivian sind beide auf XiAN-Seite involviert, Rollenverteilung unklar.
- Pax hat sich seit Gruppen-Anlage 28.04. nicht in der Inquiry gemeldet. Vivian uebernimmt vorlaeufig die Pricing-Anfrage.
- Deniz hat Mengenangabe als 300 Bottles je Produkt formuliert. Detail-Spezifikationen (mg pro Kapsel, Hilfsstoffe, Halal-Status, KPV-Form Kapsel vs. Lyophilisat, Direktdruck Batch-Nr. moeglich, MOQ-Verifizierung, Payment-Terms, Lead Time) noch offen, kommen vermutlich mit Vivians Pricing-Antwort.
- Erste Direkt-Anfrage von Deniz an XiAN ohne Kalani-Zwischenstation. Bestaetigung dass Deniz als COO direkt mit Suppliern kommunizieren darf.

## Offene Punkte

- Vivians Pricing-Antwort abwarten
- 5-Amino-1MQ Spec klaeren: Menge pro Kapsel, Hilfsstoffe, Halal
- KPV-Form: Kapsel oder Lyophilisat
- Direktdruck Batch-Nummer auf Flasche pruefen
- MOQ, Payment, Lead Time bestaetigen
- Vivian als zweiten Kontakt in [[xian-sheerherb]] ergaenzen (Rolle, Verantwortlichkeit, Verhaeltnis zu Pax)
- Status der Inquiry mit Kalani im naechsten Call (verschoben auf 2026-05-02 14:00, siehe [[2026-05-01-kalani-call]]) abgleichen
