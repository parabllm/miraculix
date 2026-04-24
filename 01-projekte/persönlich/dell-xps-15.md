---
typ: reference
name: "Dell XPS 15 9530"
aliase: ["XPS15", "Laptop", "Dell Laptop"]
bereich: persoenlich
kategorie: hardware
erstellt: 2026-04-23
notizen: "Haupt-Arbeitslaptop. Tuning-Referenz nach Optimierungs-Session 2026-04-23."
quelle: chat-session
vertrauen: bestätigt
---

## Specs

| Komponente | Wert |
|---|---|
| Modell | Dell XPS 15 9530 |
| CPU | 13th Gen Intel Core i7-13700H, 2.40 GHz |
| RAM | 16 GB, 4800 MT/s, gelötet (nicht aufrüstbar) |
| GPU dedicated | NVIDIA GeForce RTX 4050 Laptop |
| GPU integrated | Intel Iris Xe Graphics |
| SSD | 954 GB (290 GB belegt) |
| WLAN | Intel Wi-Fi 6E AX211 160 MHz |
| OS | Windows 11 Home 25H2, Build 26200.8246 |
| Reset-Datum | 2026-01-20 |

## Probleme (Ausgangslage 2026-04-23)

- RAM-Auslastung idle bei 90 Prozent
- Maus hängt nach Boot 30 bis 45 Sekunden komplett
- Internet/Chrome bricht gelegentlich ein, Websites 30 bis 60 Sekunden unbenutzbar
- Akku-Laufzeit schlecht, häufiges Nachladen nötig
- Bildschirm-Helligkeit subjektiv niedrig

## Root Causes identifiziert

1. NVIDIA Control Panel global auf "NVIDIA Hochleistungsprozessor". dGPU (RTX 4050) lief dauerhaft statt nur bei Bedarf. Iris Xe wurde umgangen.
2. Windows 11 25H2 AI-Services (WSAIFabricSvc, WorkloadsSessionHost) fressen RAM nach Idle.
3. DiagTrack (Connected User Experiences) triggert CompatTelRunner-Spikes nach Updates.
4. Killer Network Service priorisiert Traffic falsch, bricht Upload-Speeds ein.
5. Dell-Bloatware mit 6 Services (SupportAssist, TechHub, Digital Delivery etc.) frisst ca. 500 MB RAM.
6. WSL2 ohne Memory-Cap, kann bis 8 GB RAM wachsen.
7. Chrome ohne Memory Saver, 35 Prozesse parallel mit 1.2 GB RAM.
8. Windows Search Indexer scannt Vault, Downloads, Documents. Dauerhafte SSD-Last.

## Durchgeführte Optimierungen

### GPU
- NVIDIA Control Panel: "Bevorzugter Grafikprozessor" auf "Automatische Auswahl"
- Energieverwaltungsmodus auf "Normal"
- Windows Grafikeinstellungen: Chrome, Claude, Obsidian, Slack, WhatsApp, Teams, Wispr Flow auf "Energie sparen" (Iris Xe)

### Services deaktiviert
- WSAIFabricSvc (Win11 25H2 AI-Service, Registry-Lock gegen Windows Update)
- DiagTrack (Connected User Experiences and Telemetry)
- dmwappushservice
- Killer Analytics Service
- Killer Dynamic Bandwidth Management
- Killer Network Service
- Killer Provider Data Helper Service
- Killer Smart AP Selection Service
- Dell Digital Delivery Services
- Dell SupportAssist Remediation
- DellClientManagementService
- DellConnectedServiceDelivery
- DellTechHub
- SupportAssistAgent (Dell SupportAssist PC Analytics)

### Autostart
- Alle nicht-essentiellen Einträge deaktiviert
- Aktiv bleiben: GoogleDriveFS, SecurityHealthSystray, Wispr Flow

### Hintergrund-Apps
- Microsoft Teams, Outlook, Microsoft 365 Copilot, OneNote, People, Calendar: Hintergrundberechtigung auf "Nie"

### WSL
- .wslconfig unter %UserProfile% angelegt
- memory=4GB (Cap für VmmemWSL)
- processors=4, swap=0
- autoMemoryReclaim=gradual, sparseVhd=true

### Chrome
- Memory Saver auf "Maximal"
- Energy Saver aktiviert
- Flag "GPU rasterization" auf Enabled
- Hardware Acceleration an

### Windows-Settings
- Energiemodus auf "Beste Energieeffizienz"
- Battery Saver aktiviert bei 50 Prozent
- Adaptive Brightness aus
- Windows Search Indexer: Scope reduziert (Benutzer-Ordner raus, nur Startmenü + wenige Unterordner)
- Storage Sense aktiviert, wöchentlich, Papierkorb 30 Tage
- Defender Scheduled Scan auf Sonntag 03:00

### Dell Optimizer (installiert via Microsoft Store)
- Primary Usage: Mostly Mobile
- Charge Mode: Primarily AC Use
- Thermal Mode: Cool (oder Quiet)

## Ergebnis

Vorher vs. Nachher (gleicher App-Stack, 5 Minuten Idle):

| Metrik | Vorher | Nachher |
|---|---|---|
| RAM-Auslastung | 90 Prozent | 58 bis 72 Prozent |
| Boot-Hänger Maus | 30 bis 45 Sek | keine |
| Chrome-Prozesse | 35, 1230 MB | 11 bis 13, 400 bis 450 MB |
| VmmemWSL | 600 MB dauerhaft | 0 wenn Docker aus, max 4 GB wenn Docker läuft |

## Offene Punkte / langfristig beobachten

- Windows Updates können Killer-Services und WSAIFabricSvc reaktivieren. Alle 2 Wochen in services.msc checken, ggf. wieder deaktivieren.
- DellPairService aktiv gelassen (falls Dell-BT-Zubehör). Bei Bedarf auch deaktivieren.
- BIOS-Updates über Dell Optimizer regelmäßig einspielen (Battery-Firmware kann 5 bis 10 Prozent Laufzeit bringen).
- Bei Performance-Einbruch: Chrome Tabs aufräumen, Docker wenn nicht gebraucht im Tray "Quit Docker Desktop".

## Nicht umgesetzt (bewusste Entscheidung)

- Fast Startup deaktivieren
- Pagefile fest setzen
- Visual Effects reduzieren
- Windows Widgets deaktivieren
- Edge Hintergrund deaktivieren
- Dell-Apps (SupportAssist, TechHub) komplett deinstallieren (Services reichen)

Grund: Aktueller Zustand ist gut genug. Wenn später Probleme kommen, Liste abarbeiten.

## Hardware-Limits

- RAM gelötet, Upgrade auf 32 GB nicht möglich ohne Mainboard-Tausch
- Display: OLED oder FHD+ Panel, Helligkeit hardware-limitiert auf 400 bis 500 Nits
- Akku nach 2.5 Jahren: Kapazitätsverlust normal 10 bis 20 Prozent, via Dell Optimizer Battery Health Check prüfen
