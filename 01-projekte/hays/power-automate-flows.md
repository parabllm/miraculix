---
typ: aufgabe
name: "HAYS Power Automate Flows Doku"
projekt: "[[hays]]"
status: erledigt
benoetigte_kapazitaet: mittel
kontext: ["desktop"]
kontakte: []
quelle: notion_migration
vertrauen: extrahiert
erstellt: 2026-04-16
---

Vollständige technische Doku aller 7 Power Automate Flows im HAYS CEMEA Lizenzmanagement. Node-Trees, Switch-Logik, kritische Expressions, Lessons Learned. Stand 2026-04-08, Flows laufen produktiv.

## Architektur

- **Trigger:** Alle Flows außer Transfer Flow (×14) sind manuell. Typ "For a selected item" - Admin wählt SharePoint-Item aus und startet Flow.
- **Zentraler Datenspeicher:** `https://haysonline.sharepoint.com/sites/globallicensemanagement/admin`
- **Logging:** Alle Flows schreiben in `Flow_Activation_Backlog.xlsx` und `Flow_Masterslide_Backlog.xlsx`
- **Mail-Absender:** `lizenzmanagement@hays.de`, BCC Onboarding an `Deniz.Oezbek@hays.de`

## Gesamtprozess

```
SPOC-Liste (×14)
     ↓ Transfer Flow (automatisch)
Admin-Liste (zentral)
     ↓ DocuSign Initial
     ↓ DocuSign Reminder       ← Compliance-Phase
     ↓ Ready Check             ← Validierung gegen Masterslide
     ↓ [Admin manuell: LinkedIn Dashboard]
     ↓ Master Execute          ← Ausführung: Masterslide + Onboarding-Mail
     ↓ Activation Reminder
     ↓ Complete Request        ← Abschluss
     ↓ Cancel Request          ← jederzeit möglich
```

## Flow 1: Transfer Flow (×14)

Überträgt neue SPOC-Anfragen automatisch in die zentrale Admin-Liste.

- **Trigger:** Automatisch - neues Item in einer der 14 SPOC-Listen
- **Anzahl:** 14 Flows, einer pro Business Unit / Land
- **Änderungen:** Müssen 14× manuell wiederholt werden. Branch kopieren ("Copy to my clipboard") → in jedem weiteren Flow einfügen. Nach Einfügen immer SharePoint WebsiteLink und ListName anpassen (länderspezifisch).
- **Best Practice:** Länderspezifische Werte als Variablen am Anfang → nur Variablen-Init anpassen.

### Deletion/Resignation + Replace (März 2026)

SPOC kann bei Deletion/Resignation optional Nachfolger angeben.

- `Reassign = YES` → RequestType = SWITCH, CurrentUserMail = manuell eingetippte E-Mail (alter User), TargetUser = neuer User aus Personenfeld
- `Reassign = NO` → RequestType = REMOVAL

## Flow 2: Ready Check

Validiert die Anfrage vor Ausführung gegen den Masterslide. Stellt sicher dass der User tatsächlich in der richtigen Tabelle existiert (bei SWITCH/REMOVAL) oder eine neue Zeile angelegt werden kann (ASSIGNMENT).

### Node-Flow

```
Element_abrufen_aus_GLOBAL
  → Variable MatchFound (bool)
  → Variable ExelTableRows (array)
  → In_Tabelle_vorhandene_Zeilen_auflisten
  → Foreach: Zeilen → Array anfügen

→ Bedingung_Policy: Policy = "Signed" oder "Not_Needed"
    TRUE → Switch REQUEST_Type:
      CASE REMOVAL:  Foreach USER_SEARCH → Email match (case-insensitive)
                     TRUE → MatchFound, ReadyStatus = "READY"
                     FALSE → ReadyStatus = "NOT_FOUND"
      CASE ASSIGNMENT: ReadyStatus = "READY" (kein User-Match nötig)
      CASE SWITCH: coalesce(CurrentUserMail, CurrentUser/Email) matchen
    FALSE → ReadyStatus = "NOT_READY"
```

### Kritische Expression (SWITCH, Deletion+Replace)

```
toLower(trim(coalesce(
  outputs('Element_abrufen_aus_GLOBAL')?['body/CurrentUserMail'],
  outputs('Element_abrufen_aus_GLOBAL')?['body/CurrentUser/Email'],
  ''
)))
```

## Flow 3: DocuSign Initial

Sendet erste DocuSign-Signaturanforderung an End-User. Bei Anfragen mit Policy-Unterschrift-Pflicht (LinkedIn-Lizenzen über Schwelle).

- **Bedingung:** Mailing0 ≠ "DocuSign_Initial" (noch nicht gesendet)
- **Bei TRUE:** E-Mail senden, Backlog-Eintrag, AdminStatus = "DocuSign", Mailing0 = "DocuSign_Initial"

## Flow 4: DocuSign Reminder

Erinnerung wenn Policy nicht unterschrieben.

- **Bedingung:** PolicyValue = "Waiting" UND MailingValue = "DocuSign_Initial"
- **Schutz:** Läuft nicht wenn Policy bereits unterschrieben oder Initial-Mail noch nicht raus.

## Flow 5: Master Execute (Herzstück)

Führt Lizenzzuweisung über Office Script im Masterslide durch, sendet Onboarding-Mail.

- **Trigger:** Manuell, AdminStatus MUSS "Done" sein (Admin hat Lizenz im LinkedIn Dashboard manuell zugewiesen)

### Node-Flow

```
Element_abrufen_aus_GLOBAL
  → Variables: Country, Product, MailingStatus, SkillText, ConText, HTML_Text
  → Verfassen_HTML_final, Verfassen_Row_Data

→ Bedingung_STATUS: AdminStatus = "Done" UND ReadyStatus = "READY"
    TRUE:
      → Bedingung_MAILING: OnboardingMailCheck = "SENT"?
          FALSE → E-Mail senden, OnboardingMailCheck = "SENT", Mailing0 = "Onboarding_Mail"
      → Switch REQUEST_TYPE:
          ASSIGNMENT: Skript_ASSIGNMENT (neue Zeile), AdminStatus = "Assigned"
          SWITCH: Skript_SWITCH (Email tauschen), AdminStatus = "Assigned"
          REMOVAL: Skript_REMOVAL (Zeile entfernen), AdminStatus = "Assigned"
      FALSE (Mailing fehlgeschlagen): Mailing0 = "Mail_Error", Terminate
    FALSE: AdminStatus = "Not_Ready", Terminate
```

### Kritische Expression SWITCH

```
// currentEmail für Script (Deletion+Replace-kompatibel):
toLower(trim(coalesce(
  outputs('Element_abrufen_aus_GLOBAL')?['body/CurrentUserMail'],
  outputs('Element_aktualisieren_MAILING_GLOBAL')?['body/CurrentUser/Email'],
  ''
)))
```

## Flow 6: Activation Reminder

Erinnerung an User dass zugewiesene Lizenz noch aktiviert werden muss. Nach Master Execute wenn User sich noch nicht eingeloggt hat.

## Flow 7: Complete Request

Schließt Ticket vollständig ab: Admin-Liste → "COMPLETED", SPOC-Liste → "COMPLETED", Abschluss-Mail an SPOC-Ersteller.

- **Schutz:** AdminStatus darf nicht bereits "COMPLETED" oder "CANCELLED" sein.

## Flow 8: Cancel Request

Storniert Ticket auf jeder Prozessstufe. Differenziert nach Stornierungsgrund.

### Switch Reason

- **CASE DOCUSIGN** (Storno in DocuSign-Phase): Info-Mail, Status = CANCELLED
- **CASE ACTIVATION** (Storno nach Master Execute - Lizenz wurde bereits zugewiesen): + `Skript_SWITCH_1` Office Script macht Masterslide-Änderung **rückgängig** (Reversal). Diese Stornierung unterscheidet sich fundamental: Masterslide-Änderungen werden aktiv rückgängig gemacht.
- **CASE OTHER**: Info-Mail, Status = CANCELLED

## Edge Cases - Häufige Fehlerszenarien

| Symptom | Ursache | Lösung |
|---|---|---|
| AdminStatus = Flow_Error | Office Script Timeout oder unbekannter RequestType | Master Execute → Switch-Block, Script-Log prüfen |
| AdminStatus = Not_Ready | AdminStatus ≠ "Done" oder ReadyStatus ≠ "READY" | Admin-Liste: beide Felder prüfen |
| ReadyStatus = NOT_FOUND | Email passt nicht mit Masterslide überein | Masterslide öffnen, Email-Schreibweise prüfen (Case/Leerzeichen) |
| DocuSign Reminder läuft nicht | Mailing0 ≠ "DocuSign_Initial" oder Policy ≠ "Waiting" | Beide Felder prüfen |
| Onboarding-Mail nicht angekommen | OnboardingMailCheck bereits "SENT" | Timestamp prüfen |
| Cancel macht nichts | AdminStatus bereits "COMPLETED"/"CANCELLED" | Schutz greift - Ticket prüfen |
| `trim(null)` Crash bei SWITCH | Personenfeld CurrentUser null (Deletion+Replace) | `coalesce()` statt `if(empty())` |
| Feld fehlt nach PatchItem | Feld aus PatchItem-Output referenziert, dort nicht aktualisiert | GetItem-Referenz verwenden |

## Lessons Learned

### coalesce() statt if(empty())

Power Automate wertet bei `if()` beide Branches aus - auch wenn Condition false ist. Wenn Personenfeld null ist, crasht `trim(null)` im nicht-genommenen Branch.

```
// FALSCH:
if(empty(body/CurrentUserMail), trim(body/CurrentUser/Email), trim(body/CurrentUserMail))

// RICHTIG:
coalesce(body/CurrentUserMail, body/CurrentUser/Email, '')
```

### GetItem vs PatchItem

- `Element_abrufen (GetItem)` → gibt ALLE Felder zurück → zuverlässig für Referenzen
- `Element_aktualisieren (PatchItem)` → gibt nur aktualisierte Felder zurück → nie für Referenzen auf nicht-aktualisierte Felder verwenden
