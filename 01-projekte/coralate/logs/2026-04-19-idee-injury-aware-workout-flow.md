---
typ: log
projekt: "[[coralate]]"
datum: 2026-04-19
art: idee
vertrauen: angenommen
quelle: chat_session
werkzeuge: []
---

Idee aufgekommen für den Umgang mit Verletzungen im Training. Kein Implementierungs-Auftrag, nur Konzept-Festhalten.

## Rechtlicher Disclaimer

Dieses Konzept muss vor Umsetzung rechtlich durchgegangen werden. Der Vorschlag liegt an der Grenze zwischen reinem Daten-Reminder und impliziter medizinischer Empfehlung. Anwaltliche Beratung zu Digital Health und MDR notwendig vor Launch. Nicht ohne Freigabe umsetzen.

## Grundidee

Kein AI-Output entscheidet über Gesundheits-Themen. Stattdessen deterministischer Match zwischen Nutzer-eingegebenen Verletzungen und der vom Trainer kuratierten Belastungs-Map der Übungen. AI formuliert nur das Wording, nicht die Logik.

## Bausteine

### Exercise-Body-Mapping

Jede Übung im Catalog hat Tags welche Körperregionen sie belastet. Granularität mittel: 8 Regionen (Schulter, Ellbogen, Handgelenk, Rücken, Hüfte, Knie, Sprunggelenk, Nacken) × 3 Seiten (links, rechts, beidseitig). Wird von Lars kuratiert, gelabelt als "Trainer-Erfahrungswerte", nicht als medizinische Richtlinien.

### Injury-Eingabe

Nutzer trägt Verletzung ein, entweder im Chat mit Cora oder im Profil. Feld enthält Region, Seite, Datum, offen/resolved.

### Pre-Workout Pop-up mit Schweregrad-Abfrage

Bei Workout-Start läuft deterministischer Check: aktive Verletzungen × Übungs-Tags. Bei Match erscheint Pop-up mit Frage an Nutzer.

"Du hast eine Verletzung am rechten Bein eingetragen. Die Übung Kniebeuge belastet diese Region. Wie sehr belastet dich die Verletzung gerade?"

Skala 1 bis 5.

Output-Logik:

- Wert gering (1-2): Cora schlägt vor, Gewicht um 20% zu reduzieren, Übung bleibt
- Wert mittel (3): Cora schlägt vor, Gewicht um 40-50% zu reduzieren, optional Alternativ-Übung
- Wert hoch (4-5): Cora schlägt komplette Entfernung der Übung vor

Alle Vorschläge als Ja/Nein-Button, Entscheidung bleibt beim Nutzer.

### Resolve-Option im Pop-up

Dritte Option um anzugeben dass die Verletzung nicht mehr aktuell ist. Ein Klick, Verletzung wird als resolved markiert, keine Reminder mehr.

### Kein Pop-up ohne eingetragene Verletzung

Wenn Nutzer keine aktive Verletzung in Profil hat, läuft Workout normal durch. Kein Pop-up, kein Prompting.

## Architektur-Prinzip

Cora kennt keine medizinischen Zusammenhänge. Cora kennt: Verletzungs-Region, Übungs-Tag, Schweregrad-Zahl. Cora gibt strukturiert zurück: Empfehlung (reduce/remove/keep), Gewichts-Prozent-Vorschlag, freundlicher Wording-Text. Der Mapping-Layer zwischen Schweregrad und Empfehlung ist deterministisch, nicht AI-generiert.

## Offene Punkte

- Rechtliche Prüfung des gesamten Flows mit Anwalt für Digital Health
- Wie viele Übungen sind im V1-Catalog geplant, damit Lars den Body-Mapping-Scope einschätzen kann
- Gibt es bereits einen Exercise-Catalog oder fangen wir bei Null an
- Retirement-Logik für alte Verletzungen (Auto-Ablauf vs nur manuell durch Nutzer)
- Wording-Varianten für die Pop-up-Texte, muss getestet werden gegen rechtliche Fallen

## Warum das saubere Lösung ist

Nutzer gibt Daten ein. App matcht Daten gegen deterministisches Mapping. Nutzer wird erinnert an seine eigenen Daten und gibt selbst Schweregrad an. App reduziert oder entfernt Übung basierend auf User-Input, nicht auf AI-Entscheidung. Handlungsautonomie komplett beim Nutzer. AI macht nur Text-Formulierung, keine Gesundheits-Empfehlung.

Trotzdem muss das vor Umsetzung rechtlich geprüft werden. Die Grenze ist fließend.
