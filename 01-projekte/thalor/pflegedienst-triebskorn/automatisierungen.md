---
typ: detail-doc
name: "Automatisierungen Pflegedienst Triebskorn"
ueber_projekt: "[[pflegedienst-triebskorn]]"
status: scouting
erstellt: 2026-04-22
quelle: gespräch_eris_2026-04-22
vertrauen: angenommen
---

## Zweck

Sammelstelle für mögliche Automatisierungs-Touchpoints bei [[pflegedienst-triebskorn]], analog zur Struktur in [[heiraten-daenemark]] (Admin-Hub-Brainstorm). Aktuell reine Potenzial-Doku, kein Auftrag, keine Architektur-Entscheidung.

## Potenzial-Bereiche

**Stand 2026-04-22:** grobe Richtungen aus Gespräch mit [[eris-osmani-wiedmeier]]. Konkrete Pain-Points und Prozesse folgen.

### Personalverwaltung

Hypothetisch (vertrauen: angenommen):

- Bewerbermanagement (Pflegekräfte sind knapp, Inbound-Bewerbungen strukturieren)
- Dienstplan-Unterstützung
- Onboarding neuer Pflegekräfte
- Stammdatenpflege, Qualifikationsnachweise, Fortbildungs-Tracking
- Abwesenheits- und Urlaubsverwaltung

### Personalkommunikation

Hypothetisch (vertrauen: angenommen):

- Interne Team-Kommunikation (Schichtwechsel, Patienten-Updates)
- Erreichbarkeit ausserhalb Bürozeiten (24/7 telefonische Bereitschaft laut Web)
- Standard-Antworten auf Familien-Anfragen
- Dokumentations-Pflicht (jeder Mitarbeiter muss über Tätigkeiten dokumentieren)

## Kritische Punkte

- **DSGVO ist verschärft im Pflegekontext.** Patientendaten = Gesundheitsdaten = besondere Kategorie nach Art. 9 DSGVO. Jede Automatisierung muss das berücksichtigen.
- **Keine Patienteninhalte in LLM-Pipelines** ohne explizite, schriftliche Auftragsverarbeitung und ggf. Einwilligungen.
- **Kein SaMD-Risiko provozieren** (analog [[coralate]]-Regel) - Automatisierung darf keine medizinischen Entscheidungen beeinflussen oder Symptominterpretation machen.

## Offene Aufgaben

- [ ] Konkrete Pain-Points von Eris einholen (was nervt aktuell, wo verbringt die Geschäftsführung Zeit?) #mittel
- [ ] DSGVO-Rahmen für Pflegedienst klären, bevor irgendeine Automation gepitcht wird #hoch
- [ ] Touchpoints konkretisieren sobald Website-MVP-Pitch erfolgreich

## Referenz

- Strukturanalogie zu [[heiraten-daenemark]] (Admin-Hub-Brainstorm)
- Entscheider-Konstellation analog [[bellavie]] und [[heiraten-daenemark]] (Sohn als Brücke zu Eltern als Inhaber)
