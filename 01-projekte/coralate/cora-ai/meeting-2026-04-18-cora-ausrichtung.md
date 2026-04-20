---
typ: meeting
name: "Cora Ausrichtung mit Lars und Jann"
projekt: "[[cora-ai]]"
datum: 2026-04-18
teilnehmer: ["[[jann-allenberger]]", "[[lars-blum]]", "Deniz Özbek"]
ist_transkript: false
zusammenfassung: "Positionierung auf breiten Fitness-Coach festgezogen (Option B). Feature-Set so weit wie moeglich: Workout-Aenderungen, Empfehlungen, Planung, Chat-Interface testweise, Freundesfunktion. Trigger bleibt post/pre_workout ueber Context Builder."
offene_punkte: ["SaMD-Analyse obligatorisch", "Launch-Scope konkret priorisieren", "Chat-Interface Scope definieren", "Freunde + GDPR klaeren"]
erstellt: 2026-04-18
quelle: extrahiert
vertrauen: extrahiert
---

## Anlass

Bestandsaufnahme am 2026-04-18 hat gezeigt dass Vault-Doku und Live-DB bei Cora auseinanderlaufen. Vollständige Analyse: [[cora-diskrepanzen]].

Kurzfassung: Vault beschreibt Korrelations-Engine mit 3 Modi und 4 Action-Typen. DB implementiert klassischen Fitness-Coach mit 6 Triggern und 19 Action-Typen. Drift seit 7. April, nie zusammengeführt.

## Meeting-Ziel

1. Positionierung festziehen. Coach oder Korrelations-Engine oder Zwischenweg.
2. Feature-Scope für Launch definieren.
3. Nächste Build-Schritte ableiten.

## Diskussionspunkte

### 1. Positionierung

Drei Optionen:

**A. Vault-Weg.** Cora als Korrelations-Engine. 3 Modi, 4 Actions, kein Coach-Vokabular, harte SaMD-Abgrenzung. Entspricht Jann's Scope-Proposal vom 12. April.

**B. DB-Weg.** Cora als Fitness-Coach mit 19 Actions. Entspricht dem was bereits gebaut ist. Braucht Rechtsberatung zu SaMD-Risiko.

**C. Mittelweg.** Scope-Workshop, Liste aller Outputs durchgehen, pro Typ entscheiden.

Frage: War die Vault-Repositionierung vom 16./17. April eine Team-Entscheidung oder ein einseitiger Update?

### 2. Action-Types konsolidieren

Vault hat 4: GEWICHT_ANPASSEN, VOLUMEN_ANPASSEN, FOOD_SCREEN_OEFFNEN, VARIATION_VORSCHLAGEN.

DB hat 19 in 9 Kategorien. Kritisch im Coach-Territorium: `recovery_recommendation`, `form_correction`, `warmup_suggestion`, `cooldown_suggestion`, `motivation_message`.

Welche Actions braucht Cora zum Launch? Welche sind strukturell in Ordnung, welche öffnen SaMD-Risiko?

### 3. Modi vs. Trigger

Vault: 3 Modi als UX-Frames (Narrator, Card Q&A, Home-Chat RAG).
DB: 6 Trigger als Backend-Events (pre_workout, post_workout, daily_start, daily_summary, coaching_chat, post_food_log).

Mögliche Konsolidierung: Modi als UX-Layer, Trigger als Backend-Event. Narrator kann von pre_workout oder post_workout getriggert werden. Card Q&A von User-Tap auf Korrelationskarte. Home-Chat RAG von Chat-Screen.

Frage an Jann: Was erwartet das Frontend aktuell? Wie sendet es Requests an `cora-engine`?

### 4. Sprach-Regeln

Vault-Regel: "Datenbeobachtung + Zielbezug + offene Möglichkeit, nie Anweisung, nie Diagnose." Verbotene Wörter: "du musst", "du solltest", "kritisch", "um X zu vermeiden".

DB-Realität: Alle 6 Test-Outputs vom 7. April verletzen die Regel wörtlich.

Falls Option A gewählt: Prompt-Regeln härten, Eval-Set aufsetzen das Output gegen Regel-Liste prüft.

### 5. Knowledge Chunks von Lars

6 Chunks aktuell aktiv, priorisiert auf Trainings-Prinzipien und Ernährung. Kategorien: training_principle, recovery, nutrition.

Frage an Lars: Welche Chunks funktionieren unter der Vault-Positionierung weiter? `recovery_sleep_readiness` ist unter strenger SaMD-Abgrenzung grenzwertig, weil es Health-Advice ist.

### 6. Launch-Feature-Set

Jann's Scope-Proposal listet für v1:

- Read-Ops (Daten erklären)
- Logging Writes (User tippt, Cora schreibt strukturiert)
- New-Correlation Events
- Weekly Brief
- Redirect-Pattern für komplexe Tasks

Für v1.1 (nach Launch):

- iMessage/SMS Bridge (Deniz skeptisch)
- Scheduling Writes
- Voice-Logging

Ist das Feature-Set Konsens? Deniz' Skepsis gegenüber iMessage-Bridge muss geklärt werden.

## Entscheidungen

- **Positionierung:** Option B. Breiter Fitness-Coach mit maximalen Features. Vault-SaMD-Hardlimit aufgehoben. Disclaimer-Strategie und Rechtsberatung stattdessen.
- **Sprach-Regelung festgezogen:** Empfehlungen auf Basis von Korrelations-Daten, nicht Gesundheitsdaten. Keine Zustandsdiagnosen ("du hast lange nicht trainiert"), stattdessen direkte Zahlen ("10% Gewicht runter"). Begründungen basieren auf Trainings-Historie, nicht auf Körperzustand.
- **Action-Types:** Alle 19 bestehenden bleiben aktiv. Erweiterung um Workout-Aenderungen, Planungs-Actions. Soll-Liste noch zu definieren.
- **Trigger (Erstentwurf):** workout_start, workout_end. Weitere werden nach Git-Analyse der App identifiziert (food_scan_confirm, daily_open, etc.).
- **API-Contract Testing Phase:** Wird nach Git-Pull definiert. Jann gibt vor was Frontend-seitig sinnvoll ist, Deniz passt cora-engine an.
- **Git-Analyse:** Geplant fuer naechste Session. Ziel: alle bestehenden Trigger-Punkte in der App identifizieren (inkl. Food Scanner, Workout-Flow, Social).
- **Chat-Interface:** Wird testweise eingebaut. Scope noch offen, kein Full-RAG-Requirement fuer ersten Test.
- **Freundesfunktion:** Bleibt im Produkt. Kopplung mit Cora noch unklar.
- **Feature-Set Richtung (nicht priorisiert):**
  - Workouts aendern (Gewicht, Saetze, Reps)
  - Workout-Empfehlungen aussprechen
  - Neue Uebungen einfuegen oder entfernen
  - Trainings-Sessions planen
  - Daten korrelieren und Aussagen treffen
  - Chat-Interface (testweise)
- **SaMD-Hardlimit als Team:** Kein hartes Limit mehr. Disclaimer-basierter Ansatz. Rechtsberatung wird beauftragt.

## Naechste Schritte

- [ ] SaMD-Rechtsberatung beauftragen (Prioritaet hoch, blockiert Launch)
- [ ] Launch-Scope priorisieren: was ist v1, was ist v1.1 (Deniz + Jann)
- [ ] Chat-Interface Scope definieren bevor Jann anfaengt (welche Daten, welche Actions)
- [ ] Action-Types Soll-Liste finalisieren (welche 19 bleiben, was kommt neu dazu)
- [ ] Prompts reviewen: Coach-Sprache pruefen, Formulierungsregeln fuer neuen Scope festlegen
- [ ] Lars: Knowledge-Chunks ausbauen, mehr Chunks fuer breiteren Scope benoetigt
- [ ] Jann: Frontend-Kontrakt klaeren, was sendet er bei pre/post_workout an cora-engine
- [ ] GDPR-Check Freundesfunktion + Cora-Datenzugriff
- [ ] **Sign-In Form und Onboarding-Daten konzipieren:** Welche Nutzerdaten werden beim Signup abgefragt, wie werden sie gespeichert, wie fliessen sie in Coras Korrelationen ein. Schluessel-Task fuer Datenqualitaet ab Tag 1.

## Offene Punkte fuer nachgelagerte Klaerung

- [ ] **SaMD:** Welcher Disclaimer-Text ist rechtlich ausreichend? Braucht Anwalt.
- [ ] **Launch-Priorisierung:** "So viel wie moeglich" ist kein Scope. Was kommt fuer v1 konkret raus, was nicht? Ohne das wird alles halb fertig.
- [ ] **Chat-Interface:** Wie tief geht der erste Test? Nur lesen, oder auch schreiben (Logging Writes)? Welche Datenkategorien sieht Cora im Chat?
- [ ] **Trainings-Session planen:** Bedeutet das proaktives Buchen von Jann's Seite aus oder nur auf explizite Nutzer-Anfrage? Proaktives Buchen war in Jann's Proposal als SaMD-Grenze markiert.
- [ ] **Freunde + Cora:** Darf Cora Freundes-Daten sehen? Anonymisiert oder roh? Braucht Consent beider User. GDPR Art. 6.
- [ ] **Eval-Setup:** Wie pruefen wir ob neue Prompts besser sind als alte? Kein Eval-Set = kein sicheres Iterieren.
- [ ] **Knowledge-Chunks Ziel-Anzahl:** Wie viele brauchen wir fuer Launch mit breitem Scope? Lars muss wissen worauf er hinarbeitet.
- [ ] **Action-Confirmation:** Muss der User jede Cora-Aktion explizit bestaetigen oder gibt es Auto-Execute? Letzteres ist SaMD-Risiko.
- [ ] **Sign-In Form und Onboarding:** Welche Nutzerdaten beim Signup, wie granular, wie in Cora-Korrelationen einfliessen. Siehe [[zukunftsausblick]] Abschnitt unten.

## Zukunftsausblick

Richtung die im Meeting als Ziel beschrieben wurde. Nicht priorisiert, kein Zeitplan.

**Cora als vollstaendiger Fitness-Coach.**
Mittelfristig soll Cora Workouts aendern, empfehlen und planen koennen, Uebungen einfuegen und entfernen, Korrelationen zwischen Training, Ernaehrung und Koerper ziehen und Aussagen dazu treffen. Chat-Interface als primaere Interaktionsschicht langfristig.

**Onboarding als Datenbasis.**
Coras Korrelationsqualitaet haengt direkt an den Nutzerdaten die beim Signup abgefragt werden. Ziel, Equipment, Trainingsalter, Split-Praeferenz, Ernaehrungseinschraenkungen sind der Seed fuer die ersten Empfehlungen. Je besser das Onboarding-Design, desto schneller relevante Outputs ab Tag 1. Offene Fragen: Wie viel Friction ist akzeptabel beim Signup? Progressive Disclosure (wenig am Anfang, mehr nachholen) oder alles auf einmal?

**Freundesfunktion.**
Soziale Schicht ist im Produkt geplant. Kopplung mit Cora noch offen: Sieht Cora Freundes-Daten? Vergleiche? Gemeinsame Challenges? Muss mit GDPR-Consent kombiniert werden.

**Wachsende Datenqualitaet.**
Cora wird mit mehr Daten besser. Wenige Workouts = schwache Korrelationen. Das Produkt muss Nutzern frueh genug Mehrwert zeigen bevor die Datenbasis stark genug ist, sonst Churn. Ueberbrueckungsstrategie (z.B. populationsbasierte Defaults von Lars bis genug User-Daten da sind) sollte diskutiert werden.

## Sparrings-Notiz (Deniz-interne Bewertung)

Die Entscheidung fuer Option B ist nachvollziehbar fuer eine fruehe Test-Phase. Trotzdem drei Punkte die ich festhalten will:

**1. SaMD ist jetzt ein aktives Risiko, kein theoretisches.**
"Workout empfehlen", "Training planen", "Uebungen einfuegen" sind personalisierte Fitness-Empfehlungen. EU MDR schaut auf die Funktion, nicht auf den Disclaimer. Ohne Rechtsberatung weiss keiner ob der Disclaimer-Ansatz traegt. Bevor irgendetwas davon oeffentlich geht, muss das gecheckt sein.

**2. Scope bleibt unscharf.**
Alle Features aufzuzaehlen ohne Launch-Priorisierung fuehrt dazu dass Jann an zu vielen Fronten gleichzeitig baut. Empfehlung: Beim naechsten Call maximal 3 Features fuer v1 definieren, Rest explizit in v1.1 schieben.

**3. Chat-Interface unterschaetzt.**
"Testweise einbauen" klingt nach 2 Tagen. Ein Chat-Interface das auf Workout- und Ernaehrungs-Daten zugreift und Actions ausfuehrt ist architektonisch nicht trivial. Scope muss vor dem ersten Commit klar sein, sonst wird der Test-Build zur Last.

## Nachtrag (Recap Voice-Dump 2026-04-18 18:00)

Voice-Dump nach dem Meeting. Bestätigung der Outcomes plus vier verschriftlichte Punkte.

### Regulatorien

Linie passt. Keine medizinischen Empfehlungen. Fitnesstipps auf Basis von Korrelations-Daten.

### Workout-Planung und -Bearbeitung

Basis: vergangene Trainingsdaten plus initiale Onboarding-Daten. Sign-In Form damit blockierender Input für Cora-Output ab Tag 1, nicht Nice-to-have.

### Trigger (Erstentwurf bestätigt)

- workout_start
- workout_end
- Weitere nach Git-Analyse der App identifizieren

### API-Contract

- Definition nach Git-Pull
- [[jann-allenberger]] gibt Frontend-Bedarf vor, Deniz passt cora-engine an
- Git-Stand in nächster Session ziehen, alle Trigger-Punkte inkl. Food Scanner Flow identifizieren


## Nachtrag (2026-04-19 Abend)

Zwei Ideen aus Sparrings-Chat, zur Erinnerung in die Meeting-Notiz gezogen damit sie nicht vergessen werden.

### Meal-Prep, Saftkuren, Supplements vorher eintragen

Nutzer soll im Voraus planen können was er essen oder einnehmen wird. Use-Cases:

- Meal-Prep am Sonntag fuer die Woche: 5 Mahlzeiten vorbereitet, koennen pro Tag abgehakt werden
- Saftkuren: 3 Tage Saft-Fasten, voreingetragen mit Plan
- Supplements: taegliche Routine (Creatin morgens, Omega-3 abends)

Pattern: voreintragen, dann abhaken. Keine taegliche Neu-Eingabe noetig.

Push-Notifications konfigurierbar pro Eintrag. Beispiel: "Creatin 08:00", "Supplement X mit Mahlzeit". Nutzer stellt selbst ein, ob und wann er erinnert werden will.

Das ist ein eigener Feature-Block, kein Food-Scanner-Thema. Gehoert in den Logging-Layer von Cora, nicht in die Scan-Pipeline.

### Injury-aware Workout-Flow

Separate Idee, detailliert abgelegt in [[2026-04-19-idee-injury-aware-workout-flow]]. Kurz: Nutzer traegt Verletzung ein, bei Workout-Start matcht deterministischer Check gegen Uebungs-Belastungs-Tags, Pop-up fragt Schweregrad 1-5, Cora reduziert Gewicht oder entfernt Uebung entsprechend. Rechtliche Pruefung zwingend vor Umsetzung.

### Status

Beide Ideen nicht priorisiert, nicht fuer v1 eingeplant. Nur festgehalten damit sie beim Launch-Scope-Call wieder auftauchen.
