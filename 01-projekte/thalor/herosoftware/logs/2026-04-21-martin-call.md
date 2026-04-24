---
typ: meeting-note
datum: 2026-04-21
projekt: "[[herosoftware]]"
teilnehmer: ["[[martin-herd]]", "[[robin-kronshagen]]"]
thema: "Skript-Übergabe HeroSoftware an Martin Herd (Blick Solutions)"
status: durchgeführt
erstellt: 2026-04-19
aktualisiert: 2026-04-21
quelle: chat_deniz_2026-04-21
vertrauen: bestätigt
---

# Call mit Martin Herd 21.04.2026, 11:00-11:30

Google Meet: https://meet.google.com/oie-nvxt-uim
Email: martin@blicksolutions.de

## Beteiligten-Konstellation

| Person | Rolle | Anstellung |
|---|---|---|
| [[martin-herd]] | Developer, übernimmt die 4 Hetzner-Scripts | Hauptjob Digital Ocean + nebenher [[calvin-blick]]s Firma Blick Solutions |
| [[robin-kronshagen]] | Founder HeroSoftware, operativer Ansprechpartner für Deniz | HeroSoftware GmbH |
| [[calvin-blick]] | Robin's Chef bei HeroSoftware, Deniz' übergeordneter Ansprechpartner | HeroSoftware + eigene Firma Blick Solutions |
| Deniz | Freelancer, hat die Pipeline gebaut, kein Developer | Thalor |

Calvin hat Martin aus seiner Blick-Solutions-Firma für die HeroSoftware-Skript-Übernahme entsendet. Martin ist also kein HeroSoftware-Mitarbeiter.

## Politischer Kontext aus dem Call letzte Woche (~15.04.)

- Martin ging in den Call mit der Annahme, dass Deniz Developer ist und die Node.js-Scripts selbst weiter betreuen, deployen und in die HeroSoft-Infra integrieren wird. Quote aus dem Call sinngemäß "was ist mit der Node.js App, wir müssen gucken dass hier und da..."
- Erwartungshaltung war offenbar: Deniz macht das technisch, danach zieht er sich zurück
- Deniz ist aber kein Developer. Das hat zu einem peinlichen Moment im Call geführt
- Nach dem Haupt-Call hat Martin gegenüber Robin nochmal angemerkt, dass diese Aufgabe eigentlich nicht in seinen Scope fällt. Martin will das nicht unbedingt übernehmen

## Ziel des Calls heute

Die 4 Hetzner-Scripts sauber an Martin übergeben, inkl. Deployment auf Hetzner und Cron-Setup. Dabei die Rollen-Lücke schließen ohne Martin in eine Aufgabe zu drängen die er eigentlich ablehnt.

**Scripts:**
- `daily-sync.mjs` täglich 06:00
- `lgm-push.mjs` Dienstag 07:00
- `lgm-status-sync.mjs` täglich 12:00
- `mantle-reconcile.mjs` jeden 2. Sonntag 01:00

## Zugriffs-Status

- GitHub Repo `parabllm/hero-software-sync` (privat): Martin hat Collaborator-Access **schon erhalten**
- Hetzner SSH: offen, im Call klären ob Martin Zugang bekommt und wer deployed
- `.env` Keys: offen, Übergabe der Secrets nötig wenn Martin deployed

## Strategie-Notizen für das Gespräch

### Ziel für heute

Rollen sauber trennen und das Deployment-Problem lösen, ohne Martin in eine Code-Owner-Rolle zu drängen. Konkretes Ergebnis bis Ende des Calls: Wer deployt, wohin, bis wann, und wer ist Erstkontakt bei Runtime-Fehlern.

### Rollen-Klarstellung (aktiv ansprechen)

Letzte Woche ist unklar geblieben wer was ist. Heute klar machen:

- Deniz ist Freelancer und hat die Pipeline gebaut. Kein Developer im HeroSoft-Team. Kann deployen, kann Cron einrichten, kann die Scripts debuggen. Aber ist nicht der laufende Code-Maintainer.
- Martin bringt Linux- und Infra-Expertise aus DigitalOcean mit. Übernimmt Betrieb der Infrastruktur. Nicht die Node.js-Applikationslogik.
- Wer laufender Code-Owner wird (Bugs fixen, neue Features bauen) ist eine Frage zwischen Robin, Calvin und Deniz, nicht zwischen Martin und Deniz. Heute nicht klären, aber ansprechen dass der Punkt offen ist.

### Was Martin letzte Woche wahrscheinlich gemeint hat (Terminologie-Decoder)

Quote sinngemäß: "wir müssen gucken dass die Node.js App drüber läuft und das gucken und das gucken".

- "Node.js App" = die 4 Cron-Scripts. Kein Backend-Service, kein Webserver, keine Endpoints. Self-contained `.mjs` Dateien, starten per Cron, laufen durch, beenden sich.
- "drüber laufen lassen" = auf einer Infrastruktur betreiben. Aktuell Hetzner Helsinki `204.168.188.228`, `/opt/hero/`, Logs unter `/var/log/hero/`. Martin könnte das anderswo wollen (DigitalOcean Droplet).
- "das und das gucken" = unspezifisch. Runtime-Sorgen: Monitoring, Fehlerbenachrichtigung, Updates, Log-Rotation, Secret-Rotation.

Das sind Operations-Fragen, keine Dev-Fragen. Martin erwartet wahrscheinlich etwas komplizierteres als es tatsächlich ist.

### Die 4 Scripts auf einen Blick

| Script | Zweck | Cron | Duration |
|---|---|---|---|
| `daily-sync.mjs` | Mantle → Attio Billing Sync (MRR, Plans) | `0 6 * * *` | 15-17 Min |
| `lgm-push.mjs` | Attio-Listen → LGM Audiences | `0 7 * * 2` | wenige Min |
| `lgm-status-sync.mjs` | LGM Reply-Status → Attio | `0 12 * * *` | wenige Min |
| `mantle-reconcile.mjs` | Disaster Recovery + Backfill | `0 1 * * 0/2` | 30-40 Min |

- Node 20+ LTS
- Einzige Dep: `nodemailer`
- Config via `.env` (API-Keys Mantle/Attio/LGM + SMTP-Auth + Notify-Empfänger)
- Standard-Flags: `--help`, `--check`, `--dry`, `--execute`
- Notify: STRATO SMTP, aktuell an `oezbek@thalor.de`, muss umgestellt werden
- Repo: `github.com/parabllm/hero-software-sync` privat, Martin hat Collaborator-Access
- Docs im Repo: README, INTERNALS, OPERATIONS, DEPLOYMENT

### Server-Voraussetzungen

**OS und Hardware**
- Linux, Ubuntu 24.04 LTS empfohlen. Debian-basiert OK, andere Distros auch möglich.
- Ab 1 GB RAM reicht im Normalbetrieb. `mantle-reconcile` peakt bei 200 bis 400 MB.
- 5 GB freier Speicher (Scripts winzig, Logs wachsen mit der Zeit).
- Root- oder sudo-Zugang für Install und `crontab -e`.

**Software auf dem Server**
- Node.js v20 LTS oder höher. Auf Thalor-Hetzner ist v22.22.2 drauf, läuft.
- `npm` (kommt mit Node)
- `git` für Repo-Updates via `git pull`
- `cron` Standard auf jedem Linux

**Netzwerk Outbound**
- HTTPS Port 443 zu: `api.heymantle.com`, `api.attio.com`, `apiv2.lagrowthmachine.com`, `github.com`
- SMTP Port 587 TLS zu STRATO (`smtp.strato.de` oder entsprechend konfiguriert)

**Filesystem-Setup**
- Scripts-Verzeichnis z.B. `/opt/hero/`
- Logs-Verzeichnis z.B. `/var/log/hero/`
- `.env` Datei im Scripts-Verzeichnis, Permissions 600 (nur Owner liest)

**`.env` Inhalt (Deniz übergibt)**
- `MANTLE_API_KEY`
- `ATTIO_API_KEY`
- `LGM_API_KEY`
- SMTP-Auth: `SMTP_HOST`, `SMTP_PORT`, `SMTP_USER`, `SMTP_PASS`
- Notify: `NOTIFY_EMAIL_FROM` (MUSS zum SMTP_USER passen, sonst STRATO 550), `NOTIFY_EMAIL_TO`

**Setup-Kommandos auf frischem Server (nur bei Option B relevant)**

```bash
# Node und git installieren
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs git

# Verzeichnisse anlegen
sudo mkdir -p /opt/hero /var/log/hero

# Repo klonen (Martin hat Collaborator-Access)
cd /opt/hero
git clone https://github.com/parabllm/hero-software-sync.git .
npm install

# .env anlegen, Deniz uebergibt Inhalt
nano .env
chmod 600 .env

# Auth-Test pro Script
node daily-sync.mjs --check
node lgm-push.mjs --check
node lgm-status-sync.mjs --check
node mantle-reconcile.mjs --check

# Dry-Run vor Live-Lauf
node daily-sync.mjs --dry

# Cron einrichten
crontab -e
```

**Crontab-Zeilen (Berlin-Zeitzone)**
```
0 6 * * *      cd /opt/hero && /usr/bin/node daily-sync.mjs >> /var/log/hero/daily-sync.log 2>&1
0 7 * * 2      cd /opt/hero && /usr/bin/node lgm-push.mjs >> /var/log/hero/lgm-push.log 2>&1
0 12 * * *     cd /opt/hero && /usr/bin/node lgm-status-sync.mjs >> /var/log/hero/lgm-status.log 2>&1
0 1 * * 0/2    cd /opt/hero && /usr/bin/node mantle-reconcile.mjs --execute >> /var/log/hero/mantle-reconcile.log 2>&1
```

**Optional (nice-to-have)**
- `logrotate` für `/var/log/hero/*.log` (Logs wachsen sonst unbegrenzt)
- SSH-Key-Auth statt Passwort
- `fail2ban` gegen Brute-Force auf SSH

### Thalor-Hetzner Realitäts-Check (falls Option A)

Auf `204.168.188.228` (Ubuntu 24.04, Node v22.22.2) laufen aktuell:

- **Alte** Scripts in `/opt/crm-sync/`, nicht `/opt/hero/`: `daily-sync.mjs`, `lgm-push.mjs`, `lgm-status-sync.mjs`
- Alte Version hat API-Keys hardcoded in den Scripts, keine `.env`
- Alter Crontab: `daily-sync` 03:00 (nicht 06:00), `lgm-push` Dienstag 06:00, `lgm-status` 12:00
- `mantle-reconcile` läuft aktuell noch nicht als Cron, ist nur lokal bei Deniz
- Thalor-Websites (nginx + Astro) und Deniz' privates n8n (Docker) laufen daneben auf demselben Server

**Bei Option A ist der Cutover:**
1. Alte Crons deaktivieren (`crontab -e`, 3 Zeilen auskommentieren)
2. Neues Repo in `/opt/hero/` deployen (Setup-Kommandos oben)
3. `.env` befüllen (Keys wurden am 13.04. rotiert, alte hardcoded Keys in `/opt/crm-sync/` sind obsolet)
4. Neue Crons aktivieren
5. Erste Cron-Runs monitoren

### Deployment-Optionen

**A - Deniz deployt auf bestehendem Thalor-Hetzner**
- Server läuft, `/opt/hero/` existiert, self-hosted n8n daneben als Failover
- Nachteil: läuft auf Thalor-Infra, nicht HeroSoft-Ownership
- Aufwand: 30 bis 60 Minuten

**B - Deniz deployt auf HeroSoft-eigenem Server (DigitalOcean Droplet?)**
- HeroSoft hat Infrastructure-Ownership
- Droplet muss existieren oder aufgesetzt werden, Secrets übergeben
- Aufwand: 2 bis 4 Stunden inkl. Server-Setup
- Dieser Weg passt zum Kalender-Titel "Umzug zu DigitalOcean"

**C - Martin deployt selber**
- Nicht empfohlen. Martin hat klar gesagt es fällt nicht in seinen Scope.

**Empfehlung:** B oder A vorschlagen, je nach Martin's Antwort auf "wollt ihr das auf eigenem Server oder auf meinem Hetzner?".

### Ongoing-Betriebsmodell (muss heute klar werden)

| Aufgabe | Wer |
|---|---|
| Server läuft (SSH, OS-Updates, Netz) | Martin |
| Cron-Job läuft durch, Logs rotieren | Martin |
| Script-Fehler triagieren | Martin macht Erstanalyse, Deniz erklärt Code bei Bedarf |
| Node.js-Code debuggen / fixen / Features | OFFEN - Robin und Calvin müssen klären |
| API-Key-Rotation | HeroSoft-Team |
| Notify-Empfänger umstellen | HeroSoft-Team |

### Wahrscheinliche Fragen von Martin und Antworten

- **"Wie containerisieren wir das?"** Ist nicht nötig. Node.js-Binary + `.env` + Crontab-Eintrag reicht. Docker wäre Overkill für 4 Cron-Scripts.
- **"Brauchen wir CI/CD?"** Aktuell manuell `git pull` + `npm install`. Reicht für seltene Updates. CI/CD nicht nötig.
- **"Wo ist das Logging?"** Pro Script eine Datei unter `/var/log/hero/*.log`. `logrotate` noch zu konfigurieren, ist dokumentiert.
- **"Wie weiss ich ob was fehlschlaegt?"** Notify-Mails via `nodemailer`. Anti-Spam-Lock-Files verhindern Dauer-Mails bei Crash-Loops.
- **"Wer hat die API-Keys?"** Aktuell Deniz lokal in `.env`. Bei Deployment uebergibt Deniz. Keys wurden am 13.04. rotiert.
- **"Wie prüfe ich Gesundheit?"** Jedes Script hat `--check` für Auth-Test. Plus Log-Tail. Plus Notify bei Fehler.
- **"Was ist mit dem n8n Cloud Workflow (WF1)?"** Läuft separat auf `herosoftware.app.n8n.cloud`. Nicht Teil dieser Übergabe. HeroSoft-Team hat dort bereits Access.
- **"Läuft schon was in Produktion?"** Der alte `daily-sync` Cron vom 25.03. läuft täglich 04:00 auf Hetzner (alte Version). Die neuen 4 Scripts laufen aktuell lokal bei Deniz, noch nicht auf dem Server.

### Rote Linien für Deniz

- Nicht einwilligen Martin die Code-Maintenance aufzuhalsen. Das ist nicht sein Job.
- Nicht einwilligen den Code ongoing selber zu maintainen ohne laufenden Retainer oder neuen Auftrag. Das muss separat mit Robin und Calvin besprochen werden.
- OK: einmaliges sauberes Deployment uebernehmen (Option A oder B).
- OK: in den naechsten 2-4 Wochen für Runtime-Fragen erreichbar sein.
- Nicht OK: Martin erwartet dass Deniz jede Woche schaut ob die Scripts laufen.

## Agenda

1. **3 Min - Check-in, Rollen klären.** "Letzte Woche war nicht klar wer welche Rolle hat, lass uns das kurz geradeziehen."
2. **10 Min - System-Tour.** Was sind die 4 Scripts, was machen sie, kurz durch README und INTERNALS scrollen.
3. **10 Min - Deployment-Optionen.** A vs. B besprechen. Martin entscheiden lassen wo deployed wird. Secrets- und SSH-Transfer klären.
4. **5 Min - Ongoing-Betriebsmodell.** Tabelle oben durchgehen. Den offenen Code-Owner-Punkt ansprechen als "muss ich separat mit Robin und Calvin klären".
5. **2 Min - Nächste Schritte.** Konkrete Timeline, wer macht was bis wann.

## Besprochenes

Souverän verlaufenes Gespräch. Deniz hat die Situation offen aufgeklärt:

- Er ist Freelancer, kein Developer. Die komplette Pipeline (WF1, die 4 Sync-Scripts, das Hetzner-Setup) wurde mit Claude als Co-Pilot erarbeitet.
- Das erklärt auch den peinlichen Moment aus dem Call vom 15.04., bei dem Martin davon ausging dass Deniz als Dev weitermacht.
- Martin hat die Aufklärung professionell aufgenommen.

**Einigung:** HeroSoftware bekommt eigene Infrastructure. Kein Verbleib auf dem Thalor-Hetzner.

Martin hat Deniz explizit um eine saubere Endkunden-Dokumentation plus Loom-Video gebeten, damit das Team den Betrieb nachvollziehen kann.

## Entscheidungen

- **Deployment-Weg:** Option B (eigenes Droplet), nicht Option A (Thalor-Hetzner). Eigenes DO-Droplet in Blick Solutions' DigitalOcean-Space, eigenes Projekt für HeroSoftware-Sync.
- **Deniz setzt das Droplet auf und deployed** die Scripts. Martin stellt Zugang und Projekt-Raum bereit, kein laufendes Code-Ownership.
- **Neues Repo:** `HeroSoftware-GmbH/hero-software-sync` (PRIVATE, Owner HeroSoftware-GmbH-Org, Martin hat angelegt und Deniz Push-Access gegeben). Das alte `parabllm/hero-software-sync` ist obsolet.
- **Deniz liefert:** saubere Dokumentation plus Loom-Video plus Testing-Begleitung bis die Scripts auf dem Droplet stabil laufen.
- **Repository-Ownership** liegt bei HeroSoftware GmbH, nicht bei Deniz' parabllm-Account. Passt zum Grundsatz dass der Kunde den Code besitzt.

## Offene Punkte nach Call

- Droplet ist aufgesetzt (Ubuntu 24.04, Node 24, 458 MB RAM, IP `68.183.222.21`), Deniz hat SSH-Zugang per Key. Details in [[digitalocean-droplet]].
- RAM ist knapp für `mantle-reconcile` (peakt 200 bis 400 MB, aktuell nur 260 MB available). Muss Swap-File eingerichtet werden vor dem ersten Reconcile-Lauf.
- Zeitzone des Droplets ist UTC, nicht Berlin. Cron-Zeiten entsprechend anpassen oder Timezone umstellen.
- Deployment und `.env`-Befüllung steht an.
- Cutover vom Thalor-Hetzner erst nach stabilem Lauf auf DO.
- Code-Ownership langfristig: weiterhin offen zwischen Robin, Calvin und Deniz. Nicht Teil dieses Calls, wird separat geklärt.
