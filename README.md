# FC Schattdorf – WordPress (lokale Entwicklung)

Lokale, per Skript aufsetzbare WordPress-Umgebung für die neue Vereinsseite.
Läuft über Docker und ist 1:1 auf ein echtes Hosting übertragbar.

## Voraussetzungen

- **Docker Desktop** (installiert & gestartet) — bereits vorhanden ✅
- macOS / Linux mit Bash

## Schnellstart

```bash
# 1. .env aus Vorlage anlegen (enthält Ports & lokale Passwörter)
cp .env.example .env

# 2. Skripte ausführbar machen (nur beim ersten Mal)
chmod +x scripts/*.sh

# 3. Alles automatisch aufsetzen
./scripts/setup.sh
```

Nach ~1–2 Minuten (beim ersten Mal etwas länger wegen Image-Download):

| Was            | Adresse                          | Zugang                       |
|----------------|----------------------------------|------------------------------|
| Webseite       | http://localhost:8080            | —                            |
| WordPress-Admin| http://localhost:8080/wp-admin   | `admin` / `admin123`         |
| Datenbank      | http://localhost:8081 (Adminer)  | siehe `.env`                 |

## Was das Setup automatisch macht

- WordPress installieren, Sprache **Deutsch**, Zeitzone **Europe/Zurich**
- Theme **Astra** + eigenes **Child-Theme** (`fcschattdorf-child`) aktivieren
- Plugins installieren & aktivieren:
  - **SportsPress** – Teams, Kader, Spielpläne, Tabellen
  - **The Events Calendar** – Events / Kalender
  - **Fluent Forms** – Kontakt-/Anmeldeformulare
  - **MailPoet** – Newsletter
  - **Yoast SEO** – Suchmaschinen
- Seitenstruktur + Hauptmenü anlegen:
  `Home · Verein · Aktive · Junioren · Events · Sponsoren · Kontakt · Helfereinsätze`
- „Home" als Startseite setzen, Permalinks auf `/beitragsname/`

## Tägliche Befehle

```bash
docker compose up -d        # starten
docker compose down         # stoppen (Daten bleiben erhalten)
./scripts/wp.sh plugin list # beliebige WP-CLI-Befehle absetzen
./scripts/reset.sh          # ALLES zurücksetzen (löscht Daten)
```

## Anpassen

- **Vereinsfarben / Design:** `wp-content/themes/fcschattdorf-child/assets/custom.css`
  (Variablen ganz oben — Platzhalter ist Rot/Weiss, bitte ans echte Logo angleichen)
- **Logo:** WP-Admin → Design → Customizer → Website-Logo
- **Ports / Passwörter:** `.env`

## Projektstruktur

```
.
├── docker-compose.yml        # Container-Definition (DB, WordPress, WP-CLI, Adminer)
├── .env                      # Ports, Passwörter, Admin-Zugang
├── scripts/
│   ├── setup.sh              # Komplett-Setup (idempotent)
│   ├── wp.sh                 # WP-CLI-Wrapper
│   └── reset.sh              # Alles löschen
├── wp-content/themes/fcschattdorf-child/   # eigenes Theme (im Repo versioniert)
└── README.md
```

## Hinweis zum späteren Go-Live

Diese Umgebung ist zum **Bauen & Testen**. Für die echte Seite später:
Hosting bei einem Schweizer Anbieter (Hostpoint/Cyon/Infomaniak), Domain
`fcschattdorf.ch` verbinden, Inhalte exportieren/migrieren. Das Child-Theme
und die Konfiguration lassen sich direkt übernehmen.
