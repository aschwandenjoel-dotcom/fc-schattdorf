# Übergabe / Rechnerwechsel

Stand: **13.08.2026**. Diese Datei beschreibt, was gerade offen ist und was
auf einem neuen Rechner eingerichtet werden muss. Die dauerhaften
Projektregeln stehen in `CLAUDE.md`, das Setup der lokalen Umgebung in
`README.md`.

## 1. Aktueller Stand

**Live (https://fcschattdorf.dynalias.net)**

- Theme-Code ist auf dem Stand von `main`. Geprüft am 13.08.2026 durch
  Byte-Vergleich der ausgelieferten Stylesheets mit den lokalen Dateien
  (`fcs-kontakt.css`, `fcs-helfereinsaetze.css`, `fcs-front.css`,
  `fcs-schiedsrichter.css` identisch) sowie über die Marker `fche-screen`
  und `<wbr>` im ausgelieferten HTML.
- Die Datenbank ist **noch nicht** aktualisiert: die Schiedsrichter-Seite
  zeigt 5 statt 7 Schiedsrichter, die Spielleiter-Liste steht auf dem
  alten Stand (noch mit Küttel Thomas / Zamuner Sandro, ohne Tresch Fabio /
  Zamuner Alessandro).

**Repo**

- `main` == `origin/main`, alles gepusht.
- Einzige offene Änderung im Arbeitsverzeichnis: `fc-schattdorf-db.sql`
  (Transfer-Dump, wird von `scripts/backup.sh` erzeugt — gehört nicht zu
  den Code-Änderungen und ist absichtlich nicht mitcommittet).

## 2. Offener Schritt: Schiedsrichter-Stand nach live

In dieser Reihenfolge ausführen:

```bash
./scripts/pull-prod-db.sh          # 1. Live-Dump nach backups/ = Sicherung
./deploy/deploy-schiedsrichter.sh  # 2. Live-DB ändern (Probelauf -> Rückfrage)
./scripts/pull-prod-db.sh          # 3. lokal wieder = live
```

Zu Schritt 1: `scripts/backup.sh` sichert nur die **lokale** Umgebung und
taugt hier nicht als Rückweg. Der Rückweg ist der Live-Dump aus
`pull-prod-db.sh` (`backups/prod-db-<Zeitstempel>.sql.gz`).

Zu Schritt 2: Das Skript legt zwei Personen an (Lucas Martins Ferreira,
Leon Ziegler — beide «SR – Anfänger») und setzt das Seitenfeld
`fcs_sr_spielleiter`. Es ist idempotent; Erledigtes meldet «SKIP». Meldet
Teil B **ABBRUCH**, wurde die Spielleiter-Liste zwischenzeitlich im
Live-Admin gepflegt — dann nicht blind `&force=1` nachschieben, sondern
erst abgleichen.

Der Theme-Deploy `./deploy/deploy-responsiv-kontakt-helfer.sh` ist bereits
gelaufen und muss **nicht** wiederholt werden (er wäre aber gefahrlos
wiederholbar).

## 3. Neuer Rechner: was gebraucht wird

**Aus dem Repo kommt alles an Code**, inklusive Child-Theme, `scripts/`
und der freigegebenen Deploy-Skripte:

```bash
git clone git@github.com:aschwandenjoel-dotcom/fc-schattdorf.git
cd fc-schattdorf
cp .env.example .env          # enthält nur lokale Ports/Passwörter
chmod +x scripts/*.sh deploy/*.sh
./scripts/setup.sh            # Docker-Umgebung aufbauen
```

**Nicht im Repo** und deshalb separat nötig:

| Was | Warum | Wie |
|---|---|---|
| Docker + Colima laufend | lokale Umgebung | `colima start`, dann `docker compose up -d` |
| SSH-Zugang zu Hostpoint | jedes Deploy- und Pull-Skript nutzt `scp`/`ssh` als `aziwivac@sl1819.web.hostpoint.ch` | öffentlichen Schlüssel des neuen Rechners im Hostpoint-Panel hinterlegen und einmal `ssh aziwivac@sl1819.web.hostpoint.ch` testen |
| Datenbank-Inhalt | liegt im Docker-Volume, nicht im Git | `./scripts/pull-prod-db.sh` (bevorzugt) oder ersatzweise `fc-schattdorf-db.sql` importieren |
| Uploads / Medien | liegen im Docker-Volume | `rsync -avz aziwivac@sl1819.web.hostpoint.ch:www/fcschattdorf/wp-content/uploads/ <ziel>` — `pull-prod-db.sh` synchronisiert sie bewusst nicht |

`.env` enthält ausschliesslich lokale Docker-Passwörter und ist aus
`.env.example` erzeugbar — es muss nichts Geheimes vom alten Rechner
kopiert werden. Der einzige echte Zugangsschlüssel ist der SSH-Zugang zu
Hostpoint.

**Ohne SSH-Zugang** funktionieren lokale Arbeit und `git push`
uneingeschränkt; nur `pull-prod-db.sh`, die Deploy-Skripte und der
Uploads-Abgleich fallen aus.

## 4. Für die Claude-Session auf dem neuen Rechner

`CLAUDE.md` wird automatisch gelesen und enthält die Projektregeln (u. a.:
Live-DB ist die Quelle der Wahrheit, vor lokaler Inhaltsarbeit
`pull-prod-db.sh`; DB-Änderungen Richtung live nur über token-geschützte
Web-PHP-Skripte; vor dem Deploy den Live-Theme-Code gegen lokal prüfen,
weil er neuer sein kann). Der jeweils offene Stand steht in dieser Datei —
nach jedem erledigten Schritt hier nachführen.
