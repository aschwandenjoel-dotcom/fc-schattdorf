# Übergabe / Rechnerwechsel

Stand: **04.09.2026**. Diese Datei beschreibt, was gerade offen ist und was
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
- Einzige offene Änderung im Arbeitsverzeichnis: `fc-schattdorf-db.sql`
  (Transfer-Dump, wird von `scripts/backup.sh` erzeugt — gehört nicht zu
  den Code-Änderungen und ist absichtlich nicht mitcommittet).

## 2. Offene Schritte

**Offen: Domainwechsel auf www.fcschattdorf.ch** — Plan in `UMSTELLUNG.md`.
Der Branch `umstellung` enthält die vorbereiteten Code-Teile aus Phase A
(Weiterleitungsmodul `inc/fcs-redirects.php`, DB-Umstellung
`deploy/deploy-domain.sh` + `deploy/fcs-domain-switch.php.tpl`, Skripte
und Doku auf die neue Domain). **Nicht vor Schritt B2/B3 nach `main`
mergen:** auf dem Branch zeigen `scripts/lib-live.sh` & Co. bereits auf
`www.fcschattdorf.ch`, und das ist bis zur DNS-Umstellung noch die alte
Joomla-Seite bei cyon. Bis dahin `pull-prod-db.sh` und Deploys von `main`
aus fahren. Aus Phase A noch offen: A9, A11 (Termin, TTL senken); A10 erledigt
(wp-config.php ohne Host-Konstanten); A7 erledigt bis auf Redaktionsarbeit (veraltete Termine/Saison,
`UMSTELLUNG-A7-INHALTE.md` Abschnitt 4). A6 erledigt (Seitenfeld geleert, Theme-Teil
auf dem Branch). Erledigt: A1 (`my.cyon`-Zugang), A2
(Domain im Hostpoint-Panel), A3 (FluentSMTP über cyon-Postfach, alle
Testmails zugestellt), A4/A5/A8 (Code und Doku auf diesem Branch).

Erledigt 05.09.2026: `./deploy/deploy-a7-inhalte.sh` ist live gelaufen
(53 Meta-Descriptions, Yoast-Standardbild, Datenschutz mit Stand
September 2026) und wurde geprüft.

Sonst kein Deploy. Die beiden letzten sind gelaufen und live geprüft:
`deploy/deploy-responsiv-kontakt-helfer.sh` (Theme) und
`deploy/deploy-schiedsrichter.sh` (DB). Beide sind idempotent und
könnten gefahrlos erneut laufen, es besteht aber kein Grund dazu.

**Offen: `./scripts/pull-prod-db.sh`** — die lokale DB ist seit dem
13.08.2026 nicht mehr gezogen worden. Vor jeder Arbeit an Inhalten oder
Vorlagen nachholen, sonst arbeitet man auf altem Redaktionsstand.

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
