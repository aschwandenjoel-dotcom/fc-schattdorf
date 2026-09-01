# Übergabe / Rechnerwechsel

Stand: **01.09.2026**. Diese Datei beschreibt, was gerade offen ist und was
auf einem neuen Rechner eingerichtet werden muss. Die dauerhaften
Projektregeln stehen in `CLAUDE.md`, das Setup der lokalen Umgebung in
`README.md`.

## 1. Aktueller Stand

**Live (https://fcschattdorf.dynalias.net)**

- Theme-Code ist auf dem Stand von `main`. Erneut geprüft am 29.08.2026
  durch Byte-Vergleich der ausgelieferten Stylesheets mit den Repo-Blobs
  (`fcs-kontakt.css`, `fcs-front.css`, `fcs-wine-info.css`,
  `fcs-schiedsrichter.css`, `fcs-trainingslager.css` identisch).
  `fcs-top-club-88.css` liefert live 404 — richtig so, die Datei ist im
  Repo gelöscht und durch `fcs-wine-info.css` ersetzt.
- DNS, Besuchersicht, Serversicht und Zertifikat am 29.08.2026 grün
  (`./scripts/check-live.sh`); Zertifikat läuft bis 21.10.2026.
- Der Schiedsrichter-Stand ist ausgerollt (13.08.2026). Geprüft: 7
  Schiedsrichter inkl. Lucas Martins Ferreira und Leon Ziegler («SR –
  Anfänger»), Spielleiter-Liste mit Tresch Fabio und Zamuner Alessandro,
  ohne Küttel Thomas und Zamuner Sandro; das Deploy-Skript hat sich vom
  Server geräumt (HTTP 404).
- Beide Neuzugänge haben noch kein Foto (Platzhalter-Symbol). Bilder bei
  Bedarf im Live-Admin unter Personen → Bild nachtragen.

**Repo**

- `main` == `origin/main`, alles gepusht.
- Am 29.08.2026 zusammengeführt (Merge `a89355b`): Joels
  DNS-Absicherung vom 12.08.2026
  (`scripts/check-live.sh`, `scripts/lib-live.sh`,
  `scripts/pull-theme-live.sh`) war nie gepusht und fehlte in diesem
  Stand. Einziger Konflikt war `.gitignore`, wo beide Seiten
  Deploy-Ausnahmen ergänzt hatten — beide Blöcke behalten.
- `fc-schattdorf-db.sql` (Transfer-Dump aus `scripts/backup.sh`) ist
  inzwischen versioniert (`9b6312a`) und damit keine offene
  Arbeitsverzeichnis-Änderung mehr. Der Stand vom 29.08.2026 in dieser
  Datei behauptete das noch; korrigiert am 01.09.2026.

## 2. Offene Schritte

Kein Deploy. Beide sind gelaufen und live geprüft:
`deploy/deploy-responsiv-kontakt-helfer.sh` (Theme) und
`deploy/deploy-schiedsrichter.sh` (DB). Beide sind idempotent und
könnten gefahrlos erneut laufen, es besteht aber kein Grund dazu.

**Nichts offen.** `./scripts/pull-prod-db.sh` ist am 01.09.2026
gelaufen, die lokale DB entspricht wieder dem Live-Stand.

**Lokale Umgebung am 01.09.2026 neu aufgebaut.** Die Docker-Volumes
`db_data` und `wordpress_data` waren im Konto `Joel` leer (frische
Colima-VM; die alte Umgebung liegt in der separaten Colima-Instanz des
Kontos `fabian` auf demselben Mac). Neu aufgesetzt mit
`./scripts/setup.sh` — WordPress, Astra und die Plugins sportspress,
the-events-calendar, fluentform, mailpoet, wordpress-seo — danach
`pull-prod-db.sh` und der Uploads-Abgleich. Kein Code ging dabei
verloren: unter `fabian` liegt kein zweiter Checkout, dessen
Claude-Sitzungen liefen gegen dieses Verzeichnis.

Zwei Punkte daraus, die beim nächsten Mal Zeit sparen:

- **Port 8080 kann vom zweiten Benutzerkonto belegt sein.** Der
  Colima-SSH-Mux des Kontos `fabian` hielt `*.8080` systemweit. Der
  WordPress-Container lief einwandfrei, war von aussen aber nicht
  erreichbar (`Connection reset by peer`), und `lsof` zeigte unter dem
  eigenen Benutzer keinen Listener. Sichtbar wird der Halter mit
  `netstat -anv -p tcp | grep 8080` (Spalte `process:pid`). Lösung: im
  anderen Konto `colima stop`, danach `docker compose restart
  wordpress`. Adminer auf 8081 war nie betroffen.
- **Uploads sind jetzt eingebunden statt kopiert.** `docker-compose.yml`
  mountet `./wp-content/uploads` in `wordpress` und `wpcli` (beide, damit
  WP-CLI dieselben Dateien sieht wie Apache). Der rsync von live geht
  damit direkt ins Projektverzeichnis; das frühere `docker compose cp`
  in das Volume entfällt. Das Verzeichnis war über `.gitignore` schon
  ausgenommen. Die Anzeige `root:root` im Container ist bei Colimas
  virtiofs normal — Apache und WP-CLI können trotzdem schreiben.

Erledigt am 29.08.2026: `deploy-designstand.sh`,
`deploy-responsiv-kontakt-helfer.sh` und `deploy-schiedsrichter.sh`
riefen live noch mit nacktem `curl` auf und binden jetzt
`scripts/lib-live.sh` ein. Damit gilt die Regel aus `CLAUDE.md`
(kein direktes `curl` gegen live) für alle Skripte.

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
| Uploads / Medien | nicht im Git (`.gitignore`) | `rsync -avz aziwivac@sl1819.web.hostpoint.ch:www/fcschattdorf/wp-content/uploads/ ./wp-content/uploads/` — `docker-compose.yml` mountet dieses Verzeichnis seit 01.09.2026 in `wordpress` und `wpcli`, der rsync landet also direkt am richtigen Ort. `pull-prod-db.sh` synchronisiert Medien bewusst nicht |

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
