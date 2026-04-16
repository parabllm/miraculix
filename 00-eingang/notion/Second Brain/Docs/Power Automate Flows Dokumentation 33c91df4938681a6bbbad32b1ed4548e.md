# Power Automate Flows Dokumentation

Created: 8. April 2026 23:42
Doc ID: DOC-21
Doc Type: Workflow Spec
Gelöscht: No
Last Edited: 8. April 2026 23:42
Lifecycle: Active
Notes: Vollständige technische Dokumentation aller 7 Power Automate Flows mit Node-Trees, Switch-Logik, kritischen Expressions, Lessons Learned. Komplementär zum hays-flows Skill — Skill ist die Quick-Reference, dieser Doc ist die Detail-Doku.
Pattern Tags: Sync, Webhook
Project: HAYS CEMEA (../Projects/HAYS%20CEMEA%2033c91df4938681a2bb83c4c3998f67a5.md)
Stability: Stable
Stack: DocuSign, Power Automate, SharePoint
Verified: No

## Scope

Vollständige technische Dokumentation aller 7 Power Automate Flows im HAYS CEMEA Lizenzmanagement. Node-Flow, Switch-Logik, kritische Expressions, Lessons Learned. Quelle für Übergabe und Wartung.

## Architecture / Constitution

- **Trigger:** Alle Flows außer Transfer Flow (×14) sind manuell. Trigger-Typ "For a selected item" — Admin wählt SharePoint-Item aus und startet Flow
- **Zentraler Datenspeicher:** `https://haysonline.sharepoint.com/sites/globallicensemanagement/admin`
- **Logging:** Alle Flows schreiben in `Flow_Activation_Backlog.xlsx` und `Flow_Masterslide_Backlog.xlsx`
- **Mail-Absender:** `lizenzmanagement@hays.de`, BCC Onboarding an `Deniz.Oezbek@hays.de`

## Gesamtprozess-Überblick

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

**Zweck:** Überträgt neue SPOC-Anfragen automatisch in die zentrale Admin-Liste.

**Trigger:** Automatisch — neues Item in einer der 14 SPOC-Listen

**Anzahl:** 14 Flows, einer pro Business Unit / Land

### Wichtig für Änderungen

- Änderungen müssen 14× manuell wiederholt werden
- Branch kopieren (drei Punkte → "Copy to my clipboard") → in jedem weiteren Flow einfügen
- Nach dem Einfügen immer prüfen: **SharePoint WebsiteLink und ListName** anpassen (länderspezifisch!)
- Best Practice für neue Flows: Länderspezifische Werte als Variablen am Anfang → nur Variablen-Init anpassen

### Deletion/Resignation + Replace (März 2026)

Erweiterung: SPOC kann bei Deletion/Resignation optional einen Nachfolger angeben.

- `Reassign = YES` → RequestType = SWITCH, CurrentUserMail = manuell eingetippte E-Mail (alter User), TargetUser = neuer User aus Personenfeld
- `Reassign = NO` → RequestType = REMOVAL (wie bisher)

## Flow 2: Ready Check

**Zweck:** Validiert die Anfrage vor der Ausführung gegen den Masterslide. Stellt sicher dass der betroffene User tatsächlich in der richtigen Tabelle existiert (bei SWITCH/REMOVAL) oder dass eine neue Zeile angelegt werden kann (ASSIGNMENT).

**Trigger:** Manuell (Item auswählen → Flow starten)

### Node-Flow

```
Element_abrufen_aus_GLOBAL
  → Variable MatchFound (bool) initialisieren
  → Variable ExelTableRows (array) initialisieren
  → In_Tabelle_vorhandene_Zeilen_auflisten (Masterslide lesen)
  → Foreach: Alle Zeilen → An Array anfügen

→ Bedingung_Policy:
    Prüft ob Policy-Voraussetzungen erfüllt sind (Policy = "Signed" oder "Not_Needed")

    TRUE → Switch REQUEST_Type:

      CASE REMOVAL:
        → Foreach USER_SEARCH:
            → Bedingung_MATCHING:
                User-Email aus Masterslide == CurrentUser-Email (case-insensitive)
                TRUE → MatchFound = True
                       → Element_aktualisieren: ReadyStatus = "READY"
        → If FALSE (kein Match): Element_aktualisieren: ReadyStatus = "NOT_FOUND"

      CASE ASSIGNMENT:
        → Element_aktualisieren: ReadyStatus = "READY"
        (Kein User-Match nötig — es wird ein neuer Eintrag angelegt)

      CASE SWITCH:
        → Foreach USER_SEARCH_1:
            → Bedingung_MATCHING_1:
                coalesce(CurrentUserMail, CurrentUser/Email) == Masterslide-Email
                (coalesce nötig für Deletion+Replace-Fall)
                TRUE → MatchFound = True
                       → Element_aktualisieren: ReadyStatus = "READY"
        → If FALSE: Element_aktualisieren: ReadyStatus = "NOT_FOUND"

    FALSE → Element_aktualisieren: ReadyStatus = "NOT_READY"
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

**Zweck:** Sendet die erste DocuSign-Signaturanforderung an den End-User. Wird bei Anfragen benötigt, die eine Policy-Unterschrift erfordern (z.B. LinkedIn-Lizenzen über einem bestimmten Schwellenwert).

**Trigger:** Manuell

### Node-Flow

```
Element_abrufen_aus_GLOBAL
  → Variable HTML Text (string) initialisieren
  → Verfassen_final_html (HTML-Template zusammenbauen)

→ Bedingung:
    Prüft ob DocuSign noch nicht gesendet wurde
    (Mailing0 ≠ "DocuSign_Initial" o.ä.)

    TRUE:
      → E-Mail_senden_(V2): DocuSign-Mail an User
      → Zeile_zu_Tabelle_hinzufügen_Flow_Backlog: Logging
      → Element_aktualisieren_GLOBAL: AdminStatus = "DocuSign", Mailing0 = "DocuSign_Initial"
      → Element_aktualisieren_LOCAL: Status in SPOC-Liste aktualisieren
```

## Flow 4: DocuSign Reminder

**Zweck:** Sendet eine Erinnerung wenn die Policy noch nicht unterschrieben wurde. Darf nur laufen wenn `Mailing0 = "DocuSign_Initial"` und `Policy = "Waiting"`.

**Trigger:** Manuell

### Node-Flow

```
Element_abrufen_GLOBAL
  → Variable MailingValue (string) = body/Mailing0/Value
  → Variable PolicyValue (string) = body/Policy/Value
  → Variable HTML Text (string) initialisieren
  → Verfassen_final_html

→ Bedingung:
    PolicyValue = "Waiting" UND MailingValue = "DocuSign_Initial"

    TRUE:
      → E-Mail_senden_Reminder: Erinnerungs-Mail
      → Zeile_zu_Tabelle_hinzufügen_Flow_Backlog: Logging
      → Element_aktualisieren_GLOBAL: Mailing0 = "DocuSign_Reminder"
```

**Schutz:** Läuft nicht wenn Policy bereits unterschrieben oder Mail noch nicht raus.

## Flow 5: Master Execute

**Zweck:** Herzstück des Prozesses. Führt die eigentliche Lizenzzuweisung über ein Office Script im Masterslide durch und sendet die Onboarding-Mail an den End-User.

**Trigger:** Manuell — **AdminStatus muss "Done" sein** (Admin hat Lizenz im LinkedIn Dashboard manuell zugewiesen)

### Node-Flow

```
Element_abrufen_aus_GLOBAL
  → Variable Country (string) initialisieren
  → Variable Product (string) initialisieren
  → Variable Mailing Status (bool) initialisieren
  → Variable SkillText (string) initialisieren
  → Foreach Skill-Array → SkillText aufbauen (concat mit '; ')
  → Variable ConText (string) initialisieren
  → Foreach Contract-Array → ConText aufbauen
  → Variable HTML_Text initialisieren
  → Verfassen_HTML_final (vollständige Onboarding-Mail)
  → Verfassen_Row_Data

→ Bedingung_STATUS:
    AdminStatus = "Done" UND ReadyStatus = "READY"

    TRUE:
      → Bedingung_MAILING:
          Prüft ob Onboarding-Mail bereits gesendet (OnboardingMailCheck = "SENT")

          TRUE (bereits gesendet):
            → Mailing Status = True (kein erneutes Senden)

          FALSE (noch nicht gesendet):
            → E-Mail_senden_(V2)_Onboarding: Onboarding-Mail an TargetUser, BCC Deniz
            → Mailing Status = True
            → Element_aktualisieren_MAILING_GLOBAL: OnboardingMailCheck = "SENT", Mailing0 = "Onboarding_Mail"
            → Zeile_zu_Tabelle_hinzufügen_Flow_Backlog: Logging

      → Bedingung_MAILING_erfolgreich:
          Mailing Status = True

          TRUE:
            → Switch REQUEST_TYPE:

              CASE ASSIGNMENT:
                → Skript_ASSIGNMENT: Office Script in Masterslide
                    - Neue Zeile anlegen: TargetUser, Product, Country, Datum
                → ASSIGNMENT_DONE: AdminStatus = "Assigned", Backlog-Eintrag
                → Bei Fehler: ASSIGNMENT_ERROR → AdminStatus = "Flow_Error" → Terminate

              CASE SWITCH:
                → Skript_SWITCH: Office Script in Masterslide
                    - currentEmail = coalesce(CurrentUserMail, CurrentUser/Email)
                    - Bestehende Zeile: CurrentUser → TargetUser umschreiben
                → SWITCH_DONE: AdminStatus = "Assigned", Backlog
                → Bei Fehler: → Terminate mit Flow_Error

              CASE REMOVAL:
                → Skript_REMOVAL: Office Script in Masterslide
                    - Zeile des CurrentUser als "removed" markieren / löschen
                → Element_aktualisieren: AdminStatus = "Assigned"
                → Backlog-Eintrag

          FALSE (Mailing fehlgeschlagen):
            → Element_aktualisieren_MAIL_Error: Mailing0 = "Mail_Error"
            → Terminate: Beenden_MAIL_Error

    FALSE (AdminStatus ≠ Done oder ReadyStatus ≠ READY):
      → Element_aktualisieren_NOT_READY: AdminStatus = "Not_Ready"
      → Terminate
```

### Kritische Expressions SWITCH

```
// currentEmail für Script (Deletion+Replace-kompatibel):
toLower(trim(coalesce(
  outputs('Element_abrufen_aus_GLOBAL')?['body/CurrentUserMail'],
  outputs('Element_aktualisieren_MAILING_GLOBAL')?['body/CurrentUser/Email'],
  ''
)))
```

## Flow 6: Activation Reminder

**Zweck:** Sendet eine Erinnerungsmail an den User, dass er seine neu zugewiesene Lizenz noch aktivieren muss. Wird nach Master Execute ausgelöst wenn der User sich noch nicht eingeloggt hat.

**Trigger:** Manuell

### Node-Flow

```
Element_abrufen
  → Variable HTML Text initialisieren
  → Verfassen_final_html

→ Bedingung:
    Prüft ob Reminder sinnvoll ist (AdminStatus = "Assigned" o.ä.)

    TRUE:
      → E-Mail_senden_(V2): Aktivierungserinnerung an User
      → Element_aktualisieren: Status-Flag setzen
      → Zeile_zu_Tabelle_hinzufügen_Flow_Backlog: Logging
```

## Flow 7: Complete Request

**Zweck:** Schließt ein Ticket vollständig ab. Aktualisiert Admin-Liste auf "COMPLETED" und die ursprüngliche SPOC-Liste, und sendet eine Abschluss-Mail an den SPOC.

**Trigger:** Manuell

### Node-Flow

```
Element_abrufen
→ Bedingung:
    Prüft ob Ticket abgeschlossen werden kann
    (AdminStatus nicht bereits "COMPLETED" oder "CANCELLED")

    TRUE:
      → Element_aktualisieren (GLOBAL): AdminStatus = "COMPLETED"
      → Zeile_zu_Tabelle_hinzufügen_Flow_Backlog: Logging
      → Element_aktualisieren_1 (LOCAL/SPOC): Status = "COMPLETED"
      → E-Mail_senden_(V2): Abschluss-Mail an SPOC-Ersteller

    FALSE:
      → Terminate (Schutz vor Doppelausführung)
```

## Flow 8: Cancel Request

**Zweck:** Storniert ein Ticket auf jeder Prozessstufe (Phase 2–5). Differenziert nach Stornierungsgrund: zu welchem Zeitpunkt abgebrochen wurde, bestimmt was rückgängig gemacht werden muss.

**Trigger:** Manuell

### Node-Flow

```
Element_abrufen
  → Variable Product (string) initialisieren
  → Variable Country (string) initialisieren

→ Bedingung:
    Prüft ob Stornierung möglich (nicht bereits COMPLETED/CANCELLED)

    TRUE:
      → Switch Reason (Stornierungsgrund):

        CASE DOCUSIGN (Storno in DocuSign-Phase):
          → E-Mail_senden: Info an SPOC
          → Element_aktualisieren (GLOBAL): AdminStatus = "CANCELLED"
          → Zeile_zu_Tabelle_hinzufügen_Flow_Backlog
          → Element_aktualisieren_1 (LOCAL): Status = "CANCELLED"

        CASE ACTIVATION (Storno nach Master Execute — Lizenz wurde bereits zugewiesen):
          → E-Mail_senden: Info an SPOC
          → Element_aktualisieren (GLOBAL): AdminStatus = "CANCELLED"
          → Element_aktualisieren (LOCAL): Status = "CANCELLED"
          → Backlog-Eintrag
          → Skript_SWITCH_1: Office Script — macht Masterslide-Änderung rückgängig
          → Weitere Backlog-Einträge (Reversal dokumentieren)

        CASE OTHER (sonstiger Grund):
          → E-Mail_senden: Info an SPOC
          → Element_aktualisieren (GLOBAL): AdminStatus = "CANCELLED"
          → Element_aktualisieren (LOCAL): Status = "CANCELLED"
          → Backlog-Eintrag

    FALSE:
      → Terminate (Schutz vor Doppelausführung)
```

**Wichtig:** CASE ACTIVATION führt ein reversal Office Script aus — das unterscheidet diese Stornierung fundamental von den anderen: Masterslide-Änderungen werden aktiv rückgängig gemacht.

## Edge Cases — Häufige Fehlerszenarien

| Symptom | Ursache | Lösung |
| --- | --- | --- |
| AdminStatus = Flow_Error | Office Script Timeout oder unbekannter RequestType | Master Execute → Switch-Block; Script-Log prüfen |
| AdminStatus = Not_Ready | AdminStatus ≠ "Done" oder ReadyStatus ≠ "READY" | Admin-Liste: beide Felder prüfen, ggf. manuell korrigieren |
| ReadyStatus = NOT_FOUND | Email passt nicht mit Masterslide überein | Masterslide öffnen, Email-Schreibweise prüfen (Case/Leerzeichen) |
| DocuSign Reminder läuft nicht | Mailing0 ≠ "DocuSign_Initial" oder Policy ≠ "Waiting" | Admin-Liste: beide Felder prüfen |
| Onboarding-Mail nicht angekommen | OnboardingMailCheck bereits "SENT" | Mail wurde schon gesendet; Timestamp prüfen |
| Cancel macht nichts | AdminStatus bereits "COMPLETED"/"CANCELLED" | Schutz greift — Ticket prüfen |
| `trim(null)` Crash bei SWITCH | Personenfeld CurrentUser null (Deletion+Replace) | `coalesce()` statt `if(empty())` — siehe Lessons Learned |
| Feld fehlt nach PatchItem | Feld aus PatchItem-Output referenziert, dort nicht aktualisiert | GetItem-Referenz (`Element_abrufen`) verwenden |

## Lessons Learned

### coalesce() statt if(empty())

Power Automate wertet bei `if()` beide Branches aus — auch wenn die Condition false ist. Wenn ein Personenfeld null ist, crasht `trim(null)` im nicht-genommenen Branch.

```
// FALSCH:
if(empty(body/CurrentUserMail), trim(body/CurrentUser/Email), trim(body/CurrentUserMail))

// RICHTIG:
coalesce(body/CurrentUserMail, body/CurrentUser/Email, '')
```

### GetItem vs PatchItem

- `Element_abrufen (GetItem)` → gibt ALLE Felder zurück → zuverlässig für Referenzen
- `Element_aktualisieren (PatchItem)` → gibt nur aktualisierte Felder zurück → nie für Referenzen auf nicht-aktualisierte Felder verwenden