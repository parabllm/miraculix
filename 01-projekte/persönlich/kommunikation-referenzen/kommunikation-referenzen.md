---
typ: sub-projekt
name: "Kommunikation-Referenzen"
projekt: "[[persönlich]]"
bereich: persoenlich
umfang: offen
status: aktiv
erstellt: 2026-04-24
zuletzt_aktualisiert: 2026-04-27
quelle: chat_session
vertrauen: bestätigt
notizen: "Zentrales Rohmaterial-Archiv für Kommunikations-Threads (E-Mail, Slack, WhatsApp, Teams). Dient als Pool für spätere Skill-Destillation."
---

# Kommunikation-Referenzen

Zentraler Rohmaterial-Pool für archivierte Kommunikations-Threads. Zweck: Pattern-Sammlung für spätere Skill-Destillation (z.B. `hays-email-kommunikation`, `pulse-slack-schreibstil`, zukünftige Kommunikations-Skills).

## Kontext

Kommunikation ist projekt-übergreifend. Ein Thread mit einem HAYS-Kollegen kann Thesis-bezogen sein, ein Slack-Austausch mit Kalani ist Pulse-bezogen, eine WhatsApp-Unterhaltung mit einem Thalor-Client ist wieder anders. Statt die Threads in Projekt-Logs zu verstecken, werden sie hier zentral abgelegt und per Frontmatter-Tag dem Projekt zugeordnet.

Sobald genug Material pro Kommunikationstyp gesammelt ist (Richtwert: 5+ Threads), wird über `miraculix-wissens-destillation` ein Skill gebaut oder ein bestehender erweitert.

## Ablage-Regeln

- **Nur auf expliziten Anstoß von Deniz.** Nichts proaktiv archivieren. Threads landen hier nur wenn Deniz explizit sagt "leg das in die Kommunikations-Referenzen".
- **Ein Thread = eine Datei.** Keine Sammel-Files.
- **Unterordner nach Kanal:** `email/`, `slack/`, `whatsapp/`, `teams/`. Weitere Kanäle on-demand anlegen.
- **Dateiname:** `YYYY-MM-DD_kontakt-slug_thema.md`. Datum = Start des Threads. Kontakt-Slug = Wikilink-Form (lowercase, Bindestrich).
- **HAYS-interne Kommunikation:** vertraulich, Deniz behandelt sie gesondert (keine separate Kennzeichnung im Vault nötig).

## Frontmatter-Schema

Jeder Thread-File beginnt mit diesem Frontmatter-Block:

```yaml
---
typ: kommunikation-thread
kanal: email              # email | slack | whatsapp | teams
projekt: bachelor-thesis  # Projekt-Tag zur Zuordnung
kontakte: ["[[kontakt-slug]]"]
herkunft: gmail_export    # Quelle des Archivs (gmail_export, slack_screenshot, whatsapp_export, etc.)
richtung: outbound        # outbound | inbound | beidseitig
status: abgeschlossen     # aktiv | abgeschlossen | wartend
thema: "Kurze Beschreibung"
datum_start: 2026-04-20
datum_ende: 2026-04-24
erstellt: 2026-04-24
zuletzt_aktualisiert: 2026-04-24
vertrauen: bestaetigt
---
```

## Struktur

```
kommunikation-referenzen/
├── kommunikation-referenzen.md     # Dieses File
├── email/                          # E-Mail-Threads
├── slack/                          # Slack-Exports
├── whatsapp/                       # WhatsApp-Threads
└── teams/                          # Teams-Nachrichten
```

## Cross-References

- **Kontakt-Files** in `03-kontakte/` verlinken relevante Threads in ihrer Interaktions-Historie
- **Projekt-Master-Files** können einen Verweis auf dieses Sub-Projekt halten, wenn viele Threads zum Projekt existieren
- **Skills** die aus diesem Material destilliert werden, referenzieren den Thread-Pfad als Quelle

## Aktueller Bestand

| Kanal | Anzahl | Projekte |
|---|---|---|
| email | 1 | bachelor-thesis |
| slack | 11 | pulsepeptides |
| whatsapp | 0 | - |
| teams | 0 | - |

### Threads im Detail

**Email:**
- [[2026-04-20_florian-goennenwein_thesis-interview]] (bachelor-thesis, Absage)

**Slack (alle pulsepeptides):**
- [[2026-04-09_christian_tuomo-test-batch]] - Affiliate Test-Batch abgelehnt (Messenger)
- [[2026-04-11_christian_kpv-stock-kommunikation]] - KPV Stock Kunden-Info
- [[2026-04-16_christian_telefonnummer-austausch-dm]] - DM, Kontakt-Austausch
- [[2026-04-20_christian_affiliate-1k-follower-cap]] - 1k Follower Cap Policy
- [[2026-04-20_christian_prostamax-custom-order]] - Custom Order Status + Handlung, Folge-Antwort 27.04. (mg)
- [[2026-04-20_christian_reta-lab-test]] - Axon-COA Entscheidung (Messenger)
- [[2026-04-20_christian-kalani_us-market-shipments]] - US-Shipment Position
- [[2026-04-20_kalani_kpv-position-dm]] - DM, strategische Rückfrage Deutsch
- [[2026-04-23_christian_pepspan-bulk-pricing]] - Bulk-Pricing Review-Schleife
- [[2026-04-24_christian_affiliate-free-samples]] - Free-Sample-Anfrage abgelehnt, Standard-Affiliate-Terms
- [[2026-04-27_christian_credit-card-processor]] - Credit Card Processor Status, "available soon"

## Destillations-Kandidaten

Werden aufgeführt wenn 5+ Threads eines Kommunikations-Typs existieren und ein Skill gebaut oder erweitert werden kann.
