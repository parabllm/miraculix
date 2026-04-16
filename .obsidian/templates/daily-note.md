<%*
const datum = tp.date.now("YYYY-MM-DD");
const wochentag = tp.date.now("dddd", 0, tp.file.title, "YYYY-MM-DD");
const jahr = tp.date.now("YYYY");
const monat = tp.date.now("MM");
await tp.file.move(`/04-tagebuch/${jahr}/${monat}/${datum}`);
_%>---
typ: tagebuch
datum: <% datum %>
kapazitaet: null
kapazitaets_notiz: ""
fokus_projekte: []
---

# <% datum %> — <% wochentag %>

## Kalender heute

## Offene Aufgaben

## Session-Notizen

## Tages-Review
