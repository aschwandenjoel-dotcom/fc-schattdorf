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
- Der Schiedsrichter-Stand ist ausgerollt (13.08.2026). Geprüft: 7
  Schiedsrichter inkl. Lucas Martins Ferreira und Leon Ziegler («SR –
  Anfänger»), Spielleiter-Liste mit Tresch Fabio und Zamuner Alessandro,
  ohne Küttel Thomas und Zamuner Sandro; das Deploy-Skript hat sich vom
  Server geräumt (HTTP 404).
- Beide Neuzugänge haben noch kein Foto (Platzhalter-Symbol). Bilder bei
  Bedarf im Live-Admin unter Personen → Bild nachtragen.

**Repo**

- `main` == `origin/main`, alles gepusht.
- Einzige offene Änderung im Arbeitsverzeichnis: `fc-schattdorf-db.sql`
  (Transfer-Dump, wird von `scripts/backup.sh` erzeugt — gehört nicht zu
  den Code-Änderungen und ist absichtlich nicht mitcommittet).

## 2. Offene Schritte

Keine. Beide Deploys sind gelaufen und live geprüft:
`deploy/deploy-responsiv-kontakt-helfer.sh` (Theme) und
`deploy/deploy-schiedsrichter.sh` (DB). Beide sind idempotent und
könnten gefahrlos erneut laufen, es besteht aber kein Grund dazu.

Nächster sinnvoller Schritt auf einem frischen Rechner ist deshalb nur
noch `./scripts/pull-prod-db.sh`, damit die lokale DB dem Live-Stand
entspricht.

**Muster für künftige DB-Änderungen** (auf Hostpoint ist MySQL nur aus
Web-Prozessen erreichbar, siehe `CLAUDE.md`):

```bash
./scripts/pull-prod-db.sh          # 1. Live-Dump nach backups/ = Sicherung
./deploy/<dein-db-skript>.sh       # 2. Live-DB ändern (Probelauf -> Rückfrage)
./scripts/pull-prod-db.sh          # 3. lokal wieder = live
```

`scripts/backup.sh` sichert nur die **lokale** Umgebung und taugt nicht
als Rückweg für eine Live-Änderung. Der Rückweg ist der Live-Dump aus
`pull-prod-db.sh` (`backups/prod-db-<Zeitstempel>.sql.gz`).
`deploy/fcs-schiedsrichter-update.php.tpl` taugt als Vorlage: Token-Schutz,
Probelauf via `&dry=1`, Abbruch statt Überschreiben, wenn der Live-Wert
nicht dem erwarteten alten Stand entspricht.

## 3. Neuer Rechner: was gebraucht wird

**Aus dem Repo kommt alles an Code**, inklusive Child-Theme, `scripts/`
und der freigegebenen Deploy-Skripte:

```bash
git clone https://github.com/aschwandenjoel-dotcom/fc-schattdorf.git
cd fc-schattdorf
cp .env.example .env          # enthält nur lokale Ports/Passwörter
chmod +x scripts/*.sh deploy/*.sh
./scripts/setup.sh            # Docker-Umgebung aufbauen
```

Der Klon dauert: das Repo ist rund 0.5 GB, weil `import/` die
Original-Assets der alten Website enthält. Das Repo ist **privat** und
muss es bleiben (Urheberrecht an diesen Assets).

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
