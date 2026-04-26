---

## typ: meeting name: "coralate Weekly 2026-04-26" projekt: "[[coralate]]" datum: 2026-04-26 uhrzeit: "20:00-21:00" meet_link: "<https://meet.google.com/bcs-ictf-rcr>" teilnehmer: \[[jann-allenberger]]", "[[lars-blum]]", "Deniz Özbek"\] ist_transkript: false zusammenfassung: "" offene_punkte: \[\] erstellt: 2026-04-26 quelle: extrahiert vertrauen: extrahiert

## Kontext

Weekly-Routine. Letztes strukturiertes Meeting: [[meeting-2026-04-18-cora-ausrichtung]] (Positionierung auf breiten Fitness-Coach, Option B). Seitdem: TestFlight live (04-19), Food-Scanner Category Fix (04-20). Cora AI noch nicht funktional.

---

## Agenda

### 1. Stand seit letztem Meeting

- TestFlight: Erfahrungen, Bugs, Feedback?
- Food-Scanner: Stand nach Category Fix, naechste Baustellen?
- Was hat Jann gebaut oder geplant seit 04-18?

### 2. Sign-In Form und Onboarding-Design (Haupt-Thema)

Blockierender Input fuer Cora-Output ab Tag 1. Aus dem 04-18 Meeting explizit als Schluessel-Task markiert.

Offene Fragen:

- Welche User-Daten werden beim Signup abgefragt?
- Wie granular (Freitext vs. Picker vs. Slider)?
- Wie fliessen diese Daten spaeter in Coras Korrelationen ein?
- Progressive Disclosure oder alles auf einmal?
- Mindest-Datensatz fuer erste sinnvolle Cora-Outputs?

Vorschlag Agenda-Struktur:

1. Deniz zeigt Datenkategorien-Vorschlag (Goal, Equipment, Trainingsalter, Split, Ernaehrungseinschraenkungen)
2. Jann bewertet UI-Friction und Implementierungsaufwand
3. Lars priorisiert aus Trainings-Expertensicht was er wirklich braucht fuer Empfehlungen

### 3. Launch-Scope v1 vs. v1.1 (Offener Punkt seit 04-18)

"So viel wie möglich" ist kein Scope. Was kommt fuer v1, was nicht?

Vorschlag maximal 3 Features fuer v1 festziehen. Alles andere explizit in v1.1.

Kandidaten v1:

- post_workout Cora-Hinweis (bereits gebaut, Deniz-seitig)
- Food-Scanner (live)
- Onboarding Sign-In Form (geplant)

Kandidaten v1.1:

- Chat-Interface
- Trainings-Session planen
- Verletzungs-aware Workout-Flow
- Freundesfunktion

### 4. Cora AI - naechste Build-Schritte

Deniz-seitig ist die cora-engine Edge Function deployed und getestet. Offene Punkte:

- API-Contract mit Jann: Was sendet das Frontend bei workout_start / workout_end?
- Welche weiteren Trigger-Punkte gibt es in der App (food_scan_confirm, daily_open)?
- Jann-Seite: Git-Stand zeigen damit Deniz Trigger-Punkte identifizieren kann

### 5. SaMD-Rechtsberatung (Blocker)

Seit 04-18 offen. Status-Update: wurde sie beauftragt oder nicht? Ohne das kein gruenes Licht fuer oeffentlichen Launch mit Empfehlungs-Features.

---

## Entscheidungen

---

## Notizen

### Trigger-Types (Erstentwurf)

Im Call durchgegangene Liste:

- workout_start
- workout_end
- daily_brief
- analytics_click
- analytics_summary
- workout_template (Dropdown)
- pre_go
- post_go

Noch nicht final, Erstentwurf zur Diskussion. Erweiterung gegenueber 04-18 Stand (workout_start, workout_end).

### Cora-Aktionen waehrend des Workouts

Was Cora im Workout-Flow konkret tun koennen soll:

- Gewicht verringern
- Uebungen entfernen
- Suggestions fuer weight und reps: die ausgegrauten Platzhalter-Zahlen die in der App stehen sollen von Cora angepasst werden
- Uebung austauschen: offene Frage wie das in der App angezeigt wird, Loesung steht aus

### Uebungs-Metriken

Fuer die Uebungen brauchen wir gute Metriken. Punkt offen, Definition steht aus. Relevant damit Cora ueberhaupt entscheiden kann wann was angepasst wird.

### Cora-Output: Kurzantwort + Reasoning

Idee fuer das Output-Format: Cora generiert immer zwei Antwort-Ebenen.

- **Default:** kurze Antwort, nur das Wesentliche (z.B. "Gewicht 5kg runter")
- **Mehr-Info-Button:** klappt Reasoning aus, Begruendung warum (Korrelations-Daten, Historie, Logik)

Konsequenz fuers Backend: Gemini-Output-Schema muss beide Felder liefern (z.B. `message` und `reasoning`). Kein zweiter Call. Frontend rendert default zugeklappt, on-tap expand.

Vorteil: User der schnell weitermachen will hat kurze Aktion, User der verstehen will hat die Tiefe. Trust-Builder ohne UI zu ueberladen.

---

## Nächste Schritte