---
typ: infrastruktur
name: "DigitalOcean Droplet HeroSoftware CRM-Sync"
projekt: "[[herosoftware]]"
status: aufsetzen
erstellt: 2026-04-21
aktualisiert: 2026-04-21
quelle: martin_call_2026-04-21_plus_ssh_sondierung
vertrauen: bestätigt
kontakte: ["[[martin-herd]]", "[[calvin-blick]]"]
---

DigitalOcean-Droplet für die HeroSoftware CRM-Sync-Scripts. Ersetzt den Thalor-Hetzner (`204.168.188.228`, `/opt/crm-sync/`) für alle HeroSoft-Syncs. Cutover vom alten Server steht aus, zuerst muss das Droplet sauber laufen.

## Ownership und Zugang

- **Infrastructure-Owner:** [[calvin-blick]] via DigitalOcean-Space Blick Solutions. Eigenes Projekt für HeroSoftware-Sync angelegt.
- **Operations:** [[martin-herd]], Developer bei Blick Solutions
- **Deployment und Scripts:** Deniz (einmaliges Setup, danach bei Bedarf als Freelancer erreichbar)
- **SSH-Zugang aktuell:** Deniz als `root` mit ed25519 Key (`C:\Users\deniz\.ssh\id_ed25519`)

## Server-Details

| Bereich | Wert |
|---|---|
| IP | `68.183.222.21` |
| Private IP (DO-intern) | `10.19.0.6` |
| Hostname | `hero-software-sync-automation` |
| OS | Ubuntu 24.04.4 LTS (Noble Numbat) |
| Kernel | 6.8.0-110-generic x86_64 |
| Virtualization | KVM (DigitalOcean Droplet) |
| CPU | 1 vCPU, Intel DO-Regular |
| RAM | 458 MB total |
| Swap | 0 MB (muss eingerichtet werden, siehe unten) |
| Disk | 8.7 GB, 2.5 GB genutzt, 6.3 GB frei |
| Timezone | UTC (nicht Berlin) |
| Image | DigitalOcean 1-Click Node.js Droplet |

## Installierte Software (aus 1-Click-Image)

| Komponente | Version | Pfad |
|---|---|---|
| Node.js | v24.14.1 | `/usr/bin/node` |
| npm | 11.11.0 | `/usr/bin/npm` |
| git | 2.43.0 | `/usr/bin/git` |
| cron | active | systemd |
| nginx | running | Default-Config, Port 80 |
| PM2 | running | verwaltet Demo-App "hello" als `nodejs` user |
| UFW Firewall | aktiv | 22/80/443 offen, outbound frei |
| DO Droplet Agent | running | |

## Bestehende User und Apps

- **`root`** mit Deniz' Public Key in `authorized_keys`
- **`nodejs`** System-User (UID 999, GID 988, in `sudo`-Gruppe), Home `/home/nodejs`, Passwort in `/root/.digitalocean_passwords` (Klartext, vom DO-Image generiert)
- **PM2-App "hello"** läuft als `nodejs` user aus `/var/www/html/hello.js`, Port 3000 (localhost only), Demo-App vom 1-Click-Image, verbraucht ca. 41 MB RAM

## Netzwerk

- Eingehend: nur SSH 22 (mit LIMIT gegen Brute-Force), HTTP 80, HTTPS 443
- Ausgehend: alles erlaubt. Getestet und erreichbar:
  - `api.heymantle.com` HTTP 404 (Root-Endpoint, API reagiert)
  - `api.attio.com` HTTP 404 (dito)
  - `apiv2.lagrowthmachine.com` HTTP 200
  - `github.com` HTTP 200

## RAM-Kapazitäts-Problem

Das Droplet hat nur 458 MB RAM. `mantle-reconcile.mjs` peakt laut Doku bei 200 bis 400 MB. Zusammen mit Bestandsverbrauch (nginx, PM2, systemd, ca. 200 MB) würde das OOM-killen.

**Lösung vor dem ersten `mantle-reconcile --execute`:** 1 GB Swap-File anlegen. Swap-Performance spielt keine Rolle weil reconcile nur einmal pro Woche nachts läuft.

```bash
# Swap einrichten
sudo fallocate -l 1G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
# optional: swappiness reduzieren damit RAM bevorzugt wird
echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
free -h
```

Alternative: Droplet auf 1 GB RAM upgraden (ca. 2$/Monat mehr, ein Klick in DO-UI).

## Deployment-Plan (in Arbeit)

### Git-Repo

- **Repo:** `HeroSoftware-GmbH/hero-software-sync` (PRIVATE, Owner HeroSoftware-GmbH-Org)
- **URL:** `https://github.com/HeroSoftware-GmbH/hero-software-sync`
- **Collaborators:** Deniz (Push-Access), Martin Herd (Owner)
- **Altes Repo `parabllm/hero-software-sync` ist obsolet** und soll archiviert oder gelöscht werden

### Geplante Verzeichnisstruktur

```
/opt/crm-sync/              # Scripts-Verzeichnis (laut DEPLOYMENT.md)
├── .env                    # Secrets, Permissions 600
├── daily-sync.mjs
├── lgm-push.mjs
├── lgm-status-sync.mjs
├── mantle-reconcile.mjs
├── package.json
├── node_modules/
└── logs/
```

### Geplanter Run-User

Offene Entscheidung: bestehenden `nodejs` User nutzen (hat Sudo, Home schon da) oder dedizierten `crm-sync` User anlegen (wie DEPLOYMENT.md empfiehlt). Empfehlung: dedizierten `crm-sync` User, saubere Trennung zur PM2-Demo-App.

### Geplante Crontab (UTC, weil Server-Zeitzone UTC ist)

Berlin-Zeiten aus DEPLOYMENT.md müssen für UTC-Server um 2h (Sommerzeit) oder 1h (Winterzeit) zurückgerechnet werden. Oder: Server-Timezone auf Berlin stellen.

## Offene Setup-Tasks

- [ ] Swap-File 1 GB einrichten (Pflicht vor mantle-reconcile)
- [ ] Zeitzone entscheiden: Server auf Berlin oder Cron-Zeiten in UTC umrechnen
- [ ] Dedizierten `crm-sync` User anlegen (optional, empfohlen)
- [ ] Repo klonen nach `/opt/crm-sync/` (via HTTPS mit Personal Access Token oder Deploy-Key)
- [ ] `npm ci --omit=dev`
- [ ] `.env` anlegen mit allen Secrets (Mantle, Attio, LGM, STRATO SMTP)
- [ ] `--check` pro Script
- [ ] `--dry` pro Script
- [ ] Crontab einrichten
- [ ] Notify-Test (STRATO SMTP funktionieren lassen)
- [ ] Optional: Healthchecks.io aktivieren
- [ ] Cutover vom Thalor-Hetzner: alte Crons in `/opt/crm-sync/` auf `204.168.188.228` deaktivieren sobald DO-Droplet stabil läuft

## Abgrenzung zum Thalor-Hetzner

Der Thalor-Hetzner `204.168.188.228` hatte bisher die HeroSoft-Scripts in `/opt/crm-sync/` (alte Version mit hardcoded API-Keys). Nach Cutover:

- HeroSoft-Scripts laufen nur noch auf diesem DO-Droplet
- Thalor-Hetzner behaelt seine anderen Funktionen (Deniz' privates n8n auf `n8n.thalor.de`, Thalor-Websites)
- Alte `/opt/crm-sync/` auf Hetzner kann nach erfolgreichem Cutover archiviert oder geloescht werden

## Wichtige Dateien auf dem Droplet

- `/root/.ssh/authorized_keys` enthält Deniz' Public Key
- `/root/.digitalocean_passwords` enthält `nodejs`-User-Passwort im Klartext (vom DO-Image)
- `/etc/systemd/system/pm2-nodejs.service` ist der Auto-Start der PM2-Demo-App
- `/var/www/html/hello.js` ist die Demo-App

## Claude-Zugang via Desktop Commander

Wrapper-Script auf Deniz' Windows: `C:\Users\deniz\ssh-do.mjs`. Key-basiert, liest `id_ed25519` aus `.ssh/`. Aufruf:

```
node C:\Users\deniz\ssh-do.mjs "<command>"
```

Zum Vergleich: `C:\Users\deniz\ssh.mjs` geht auf den Thalor-Hetzner (Passwort-basiert).
