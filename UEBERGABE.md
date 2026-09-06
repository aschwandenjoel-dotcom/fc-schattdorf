# Übergabe / Rechnerwechsel

Stand: **05.09.2026**. Diese Datei beschreibt, was gerade offen ist und was
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

**Fünf Deploys stehen aus.** Ihre DB-Teile sind voneinander
unabhängig — sie fassen verschiedene Felder an:

1. `./deploy/deploy-redaktion-vorrunde-2627.sh` — Redaktions-
   Rückmeldungen vom 03.09.2026 (Abschnitt 2a).
2. `./deploy/deploy-news-import-0926.sh` — 25 News von der alten
   Vereinsseite nachtragen (Abschnitt 2b). Keine Theme-Änderung.
3. `./deploy/deploy-1mannschaft-vorrunde-2627.sh` — 1. Mannschaft,
   Betreuerstab, Kader und Kopfsponsoren (Abschnitt 2c).
4. `./deploy/deploy-3mannschaft-feritec.sh` — 3. Mannschaft, neues
   Mannschaftsfoto und Feritec AG als alleiniger Teamsponsor
   (Abschnitt 2d).
5. `./deploy/deploy-vorstand-bilder.sh` — Vorstandsseite bindet
   Vorschaubilder statt Originale ein (Abschnitt 2e). Reine
   DB-Änderung, kein Theme-Code, keine neuen Dateien.
6. `./deploy/deploy-impressum.sh` — Impressum: Webdesign «Urinet
   Aschwanden», urinet.ch, Onlineschaltung und Stand September 2026.
   Reine DB-Änderung, unabhängig von allem anderen, jederzeit.

Nummer 1, 3 und 4 sind gleich aufgebaut: Theme-Code per rsync, dann die
neuen Bilddateien, dann die DB-Änderung über ein token-geschütztes
Skript im Webroot. Nummer 2 überträgt Mediendateien und legt Beiträge
an, Nummer 5 hat nur den DB-Teil. Jeder fragt vor dem Schreiben nach,
ist idempotent und wird am Schluss gegen die Live-Seite verifiziert.

**Zur Reihenfolge:** der rsync überträgt jedes Mal den ganzen
Theme-Ordner. Wer zuerst läuft, nimmt also den Code der beiden anderen
mit — deren DB-Teile fehlen dann aber noch. Wenige Minuten lang zeigt
die Seite in diesem Fall Vorlagen, die auf noch nicht gesetzte Felder
zugreifen; die Vorlagen fallen dabei auf ihre Standardwerte zurück,
kaputt geht nichts. Eine Ausnahme sind die **fest verdrahteten
Titelbilder**: `page-1mannschaft.php` zeigt auf `FCS1_Web2627.jpg`,
`page-3mannschaft.php` auf `FCS3_Web2627.jpg` und `feritec-2026.png`.
Die haben keinen Fallback und laufen bis zum jeweiligen Deploy ins
Leere. `deploy-redaktion-vorrunde-2627.sh` prüft das in einem Schritt 0
gegen live und fragt nach, bevor es den Theme-Ordner überträgt. Am
ruhigsten läuft es in der Reihenfolge 1, 2, 3 kurz hintereinander.
Nummer 4 ist davon unabhängig und kann jederzeit laufen.

**Vorher `./scripts/pull-prod-db.sh` laufen lassen.** Zuletzt am
05.09.2026 geholt (`backups/prod-db-20260905-121635.sql.gz`) — dieser
Dump ist zugleich der Rückweg.

### 2a. Deploy Redaktions-Rückmeldungen

`./deploy/deploy-redaktion-vorrunde-2627.sh` setzt die Rückmeldungen
vom 03.09.2026 um (DB-Teil: `deploy/fcs-redaktion-vorrunde-2627.php.tpl`).
Am 05.09.2026 komplett auf dem Live-Stand von 12:16 Uhr durchgespielt:
alle 44 lokal prüfbaren Muster grün, zweiter Lauf meldet überall
«SKIP». Live wird mit 46 Einzelprüfungen verifiziert.

Was der Deploy erledigt:

- Aktive: «Frauen Team Uri I» -> «Frauen Team Uri», «Senioren Team Uri I»
  -> «Senioren Team Uri», «Frauen Team Uri II» in den Papierkorb (Seite,
  SportsPress-Team, Menüpunkt, Vorlage `page-frauen-uri-2.php` gelöscht).
- Junioren-Teams auf die Funktionärsliste Vorrunde 2026/27: A -> Aa,
  Fa/Fb/Fc/Fd -> Fa/Fb/Fc, Fe/Ff -> Fd, Df und Ef aufgelöst, alle
  Betreuerstäbe neu, Reihenfolge neu, Mannschaftsfotos raus (Übersicht
  zeigt jetzt die Silhouette). Juniorinnen neu FF11/FF14/FF17.
- Junioren-Übersicht: Gruppenbild aller Junioren unter dem Titel
  (`assets/img/fcschattdorf_junioren1.jpg`, über das neue Seitenfeld
  «Gruppenbild» austauschbar).
- Vorstand: Monja Deplazes -> Robin Lindauer (Silhouette,
  079 912 04 80), René Gnos neu «Sportchef». Ebenso «Vorfall melden».
- Mitglied werden: Jahrgänge ergänzt (Kinderfussball 2018–2013,
  Junioren 2012–2006), neue Rubrik «Passivmitglied» mit Kontakt Admin.
- Fussballschule: Stand gemäss Flyer Herbst 2026 (Jahrgang 2020/2021,
  Daten, Kosten, Leitungsteam).
- Trainingslager: Datum «Juli 2027»; Anmelde-Buttons, Flyer-Abschnitt
  und «Bist du dabei?» abgeschaltet. Technisch über leere Felder — die
  Vorlage blendet die Blöcke aus, sobald `tl_anmeldung_url`,
  `tl_flyer_bild` bzw. `tl_cta_lead` leer sind.
- Vereinsgeschichte: zählt ab 1933 (93 Jahre) statt ab dem ersten
  Chronik-Eintrag 1916. Neues Seitenfeld «Gründungsjahr».
- Navigation: «Ehrenmitglieder» -> «Ehren-/Freimitglieder».
- WhatsApp-Kanal neben Facebook und Instagram (Footer, Hero-Leiste und
  Overlay-Menü).
- Startseite: Co-Sponsor «Herger Küchen AG» entfernt.
- Neues Brückli-Logo auf der ganzen Seite: Startseite, Sponsoren,
  Teamsponsoren der 1. Mannschaft und Teamseiten Ba/Dc/Ed-Ee/Fa-Fb-Fc.
  Die 1. Mannschaft führte das Logo unter dem abweichenden Dateinamen
  `gasthaus-brueckli-color.jpg`, die Junioren unter
  `sp-gasthaus-brueckli.jpg` — der Tausch in Abschnitt H2 des
  Deploy-Skripts deckt seit dem 05.09.2026 beide alten Namen ab
  (vorher blieb die 1. Mannschaft beim alten Logo). Ebenso neues
  Zurich-Logo «Generalagentur Simon Mani» (Sponsoren und
  2. Mannschaft).
- Junioren-Übersicht (`/junioren/teams/`): das Gruppenbild war unscharf.
  Ursache war die Datei — `assets/img/fcschattdorf_junioren1.jpg` mass
  nur **1200×560 px**, wurde aber randlos über die ganze Fensterbreite
  gezogen. **Das Original ist gefunden:** die alte Vereinsseite liefert
  dasselbe Foto unter
  `https://www.fcschattdorf.ch/images/design/parallax/parallax.jpg` in
  **3000×2002 px** — es war dort das Parallax-Bild der Startseite. Die
  kleine Datei war ein Ausschnitt daraus.
  Neu im Theme als `assets/img/junioren-gruppenbild.jpg`
  (3000×2002, progressives JPEG, Qualität 84, ~1,5 MB — in
  Originalauflösung, ohne Verkleinerung, damit nichts weichgerechnet
  wird). Die kleine Fassung ist gelöscht und wird nirgends mehr
  referenziert.
  Dargestellt wird es wie das Parallax-Band der alten Startseite:
  `background-attachment: fixed`, das Band ist nur das Fenster auf ein
  im Viewport festgenageltes Bild. Beim Scrollen wandert der
  Ausschnitt, man sieht nach und nach andere Teile des Fotos. Ohne
  Verlauf darüber — das Bild soll unverfälscht wirken. Auf Touch-Geräten
  und bei `prefers-reduced-motion` schaltet das CSS auf
  `background-attachment: scroll`, weil iOS `fixed` unzuverlässig
  rendert. Die Vorlage setzt das Bild inline (`style="background-image…"`),
  damit das Seitenfeld «Gruppenbild» weiter greift; ein Ersatzbild
  sollte deshalb ebenfalls ab ~2500 px breit sein.

  Nachjustierungen vom 05.09.2026:
  - **`background-position: center 55%` und Bandhöhe
    `max(20rem, calc(100vh - 15rem))`.** Beides gehört zusammen und
    sorgt dafür, dass beim Seitenanfang die ganze Gruppe im Fenster
    liegt.

    Die Grundlage sind gemessene Werte statt Augenmass: im Foto stehen
    die Kinder zwischen **38 % und 88 % der Höhe** und zwischen **10 %
    und 88 % der Breite** (zeilen- und spaltenweise über den Rot-Anteil
    ermittelt). Bei `background-attachment: fixed` rechnet der Browser
    das Bild auf das **ganze Fenster**, das Band zeigt davon nur einen
    Streifen — damit die 50 % Bildhöhe der Gruppe hineinpassen, muss der
    Streifen so hoch wie möglich sein. Daher reicht das Band bis zur
    Faltkante: `100vh` minus 15rem (6.25rem Kopfzeile + 8.75rem
    Kopfblock).

    Frühere Werte und warum sie nicht reichten: 52vh schnitt die
    vorderste Reihe ab, 66vh half nur auf hohen Fenstern, und
    `center bottom` war zu tief — auf niedrigen Fenstern fehlten die
    hinteren Reihen, während unten nur Rasen zu sehen war.

    Durchgerechnet und stichprobenweise im Browser geprüft für
    1280×720, 1366×768, 1440×900, 1512×750, 1536×864, 1600×900,
    1680×950, 1920×1080 und 2560×1400: überall ist die Gruppe
    vollständig sichtbar, auf den meisten Grössen mit etwas mehr Luft
    über der Gruppe als darunter. Am knappsten ist 1512×750 (MacBook mit
    Browserleiste) — dort passt es gerade eben. **21:9-Formate
    (3440×1440) schneiden unten noch etwas an**; dafür ist das Bild
    rechnerisch zu hoch für den Streifen, das liesse sich nur mit einem
    engeren Bildzuschnitt lösen.
  - **Andockender Seitenkopf.** Der Kopf («TEAMS / FC Schattdorf ·
    Junioren») wandert beim Scrollen unter der Kopfzeile mit und bleibt
    stehen, sobald seine Unterkante die Unterkante des Gruppenbildes
    erreicht; danach scrollt er normal weg. Umgesetzt ohne JavaScript:
    `.fctc-dock` umschliesst Kopf und Bild, `.fctc-dock .fctc-header`
    ist `position: sticky` — ein klebendes Element wird von seinem
    umschliessenden Block begrenzt, dessen Unterkante genau die
    Bildunterkante ist. `top` ist die Höhe der geschrumpften Kopfzeile
    (4.75rem, ab 64rem Breite 4.5rem; der 4-px-Rand steckt dank
    border-box schon darin).
    **Der Container `.fctc-dock` steht nur in
    `page-junioren-teams.php`** — die anderen Vorlagen mit
    `.fctc-header` (Juniorenkonzept, Fussball-Tauschbörse, Top Club 88)
    bleiben unberührt. Wer die Andockhöhe ändert, muss sie mit der
    Kopfzeilenhöhe in `fcs-front.css` abgleichen.

  **Achtung beim Prüfen mit Headless-Chrome:** `--screenshot` zeichnet
  die Geometrie vom Seitenanfang, den fixierten Hintergrund aber zur
  aktuellen Scrollposition. Ein gescrollter Screenshot zeigt deshalb
  Kopfbereich und Band an der Stelle wie oben, den Bildausschnitt
  jedoch verschoben. Das ist ein Artefakt des Werkzeugs, kein Fehler
  der Seite — und zugleich der Beleg, dass `fixed` greift.
- Startseite, «Termine & Spielbetrieb»: der Leerzustand «Zurzeit sind
  keine Termine erfasst.» war in `--fcx-muted` (Blaugrau) gesetzt und
  ging auf dem roten Band unter. Er ist jetzt der linke Spaltenkopf und
  teilt sich eine CSS-Regel mit «Spielbetrieb IFV» rechts
  (`.fcx-event__empty, .fcx-spielbetrieb__lbl`): weiss, .6875rem, 800,
  `letter-spacing:.18em`, Versalien, `margin:0 0 1rem`. Beide Spalten
  beginnen damit auf derselben Linie und können nicht auseinanderlaufen.
- cash. und Brand Automobile farbig statt ausgegraut (05.09.2026,
  Startseite und Sponsorenseite) — Hintergrund im Abschnitt
  «Ausgegraute Sponsorenlogos» weiter unten.
- Schiedsrichter: alle vier Fotos aus der Serie vom August 2026 — Leon
  Ziegler und Lucas Martins Ferreira neu, Stephan Gisler und René Hüglin
  ersetzt.
- 2. Mannschaft: neues Mannschaftsfoto, Betreuerstab neu (Igor Sureta,
  Roger Zurfluh, Robin Lindauer — Mathias Lussmann entfällt).
- Sechs Spieler-Sponsorenlogos in höherer Auflösung (siehe unten).
- **Team-Umschalter der Juniorenseiten neu.** Bisher lief über jeder
  Teamseite ein Band mit allen 18 Teamnamen — drei Zeilen zwischen
  Kopfzeile und Titelbild. Es ist ersatzlos entfernt
  (`.fcsh-sub-nav--grid` in `functions.php`, `fcs-front.css` und
  `custom.css`); an seine Stelle tritt ein zusammengeklappter
  Umschalter rechts neben dem Teamnamen. Geöffnet zeigt er alle Teams
  nach Alterskategorie gruppiert mit Kurznamen (A · Aa, B · Ba Bb, …,
  Juniorinnen · FF11 FF14 FF17), dazu ein Link auf die Übersicht.
  Gestaltet in der Sprache des Kopfzeilen-Megamenüs (`.fcx-megas`):
  Ink-2 als Grund, Haarlinien in Weiss, Schatten `0 18px 40px`, alles
  eckig — laut DESIGN.md bleibt interaktive Chrome bei 0px Radius. Rot
  markiert ausschliesslich das aktuelle Team. Der Auslöser folgt
  `.fcx-btn--onphoto` (Ink-Fläche, weisser Rahmen, Versalien). Neue Dateien:
  `assets/fcs-junioren-team.css` und `assets/fcs-junioren-team.js`.
  Technisch `<details>`/`<summary>`, funktioniert also auch ohne
  JavaScript — das Skript ergänzt nur Schliessen per Klick daneben und
  Escape. Auf breiten Bildschirmen klappt das Feld nach oben über das
  Titelbild auf (darunter beginnt sofort der Inhalt), auf schmalen nach
  unten. Geprüft mit Chrome headless bei 1280 und 500 px: kein
  waagrechter Überhang, `scrollWidth == clientWidth`.
- Fussballschule: neues Flyer-PDF verlinkt.

- **Vereinsgeschichte: Eintrag «Erste Gründung» (1916) entfernt**
  (Rückmeldung vom 05.09.2026, Teil M des DB-Skripts). Er geht in den
  Papierkorb, nicht in die endgültige Löschung — im Admin also
  wiederherstellbar. Die Chronik beginnt jetzt mit der Neugründung 1933.

  Nebenwirkungen, bewusst so: die Jahrzehnt-Leiste beginnt neu bei
  «1930er», und der Zähler «Kapitel unserer Story» steht auf 44 statt
  45. Gründungsjahr (1933) und «93 Jahre Geschichte» bleiben — die
  kommen aus dem Seitenfeld «Gründungsjahr», nicht aus dem ersten
  Chronik-Eintrag.

  **Zur Prüfung durch die Redaktion:** der Eintrag von 1933 heisst
  «Neugründung des FC Schattdorf» und im Text steht «gründete … den FC
  Schattdorf **erneut**». Beides bezieht sich auf die erste Gründung von
  1916, die jetzt nicht mehr zu sehen ist. Inhaltlich stimmt es
  weiterhin, liest sich ohne den Bezug aber etwas verloren — Titel und
  Text bewusst nicht angefasst, das ist eine redaktionelle
  Entscheidung.

  Beim Durchsehen der Seite sonst nichts gefunden: die Kennzahl «3×
  IFV-Cup Champion» deckt sich mit der Chronik (2005, 2011, 2024), die
  Jahrzehnt-Leiste ist lückenlos, die Chronik endet mit 2024.

- **Juniorinnen FF11, FF14 und FF17 mit Betreuerstab und Trikotsponsor**
  (Angaben der Redaktion vom 05.09.2026, Teil L des DB-Skripts). FF14
  und FF17 waren bis dahin leere Seiten.

  | Team | Betreuerstab | Trikotsponsor |
  |---|---|---|
  | FF11 | Michael Gisler, Ruedi Herger, Marino Arnold, Arturo Schneeberger | Gasthaus Brückli |
  | FF14 | Philipp Bissig, Luca Forte, Heinz Gisler | Raiffeisen Urnerland |
  | FF17 | Sam Bürer, Noreen Häfliger | TEKO Oberflächentechnik |

  Bei FF11 ersetzt Gasthaus Brückli den bisherigen Eintrag Coop. Das
  TEKO-Logo lag bereits als `sp-teko.png` in der Mediathek; die Firma
  ist die Teko Oberflächentechnik AG (teko-ag.ch, über den Logo-Text
  abgeglichen) — das Trikot ist laut Redaktion das frühere Damen-2-Dress
  mit deren Werbung.

  **Offen bei diesen drei Teams:** die Mannschaftsfotos werden
  nachgereicht (FF11 von Aline Kempf, FF14 vom FC Altdorf, FF17 vom
  ESC); bis dahin bleibt das Feld «Teamfoto» leer und die Übersicht
  zeigt das Silhouetten-Symbol. Ohne Porträt sind Marino Arnold, Arturo
  Schneeberger, Philipp Bissig, Luca Forte, Heinz Gisler und Noreen
  Häfliger. Die Redaktion schrieb «Mike Gisler» — eingetragen ist
  «Michael Gisler», wie in der Funktionärsliste und beim Bilddateinamen.

- **Grümpelturnier: Druckerei Kuster neu mit Farblogo.** Auf der
  Turnierseite lag von Kuster die reine Schwarz-Variante
  (`Kuster.png`). Die Marke ist tatsächlich farbig — graue Wortmarke,
  gelbgrünes «K», gelbgrüne Trennpunkte. Belegt über zwei Wege: das
  Favicon auf druckerei-kuster.ch zeigt das «K» in Grau und Gelbgrün,
  und im Webarchiv liegt die Farbfassung derselben Datei
  (`logo_x2.png`, 287×105 — **exakt die Abmessung ihrer heutigen
  Weiss-Fassung**, also dasselbe Logo in zwei Farbwegen). Neu als
  `Kuster_farbig.png` in der Mediathek, Teil K des DB-Skripts hängt das
  Feld um.

  **SwissLight und Bikewelt Gisler bleiben schwarz.** Auf beiden
  Firmenwebsites gibt es nur einfarbige Fassungen — SwissLight einen
  dunklen Schriftzug plus eine weisse Variante für dunkle Flächen,
  Bikewelt ein SVG in reinem Weiss. Nach heutigem Stand sind das
  bewusst monochrome Marken; ein Farblogo müsste beim Sponsor
  angefragt werden. Ebenfalls einfarbig und vermutlich so gewollt:
  Der Anker (schwarzer Anker) und Sandro Tresch Fotografie
  (schwarze Signatur). Farbig sind Baldini, Blümä, Dätwyler,
  Gelateria, Schuler, Snowlife und TCS Uri.

  Nicht gemacht und bewusst so: das Kuster-Favicon als Logo einsetzen
  (nur das «K», 270 px) oder die Schwarz-Logos künstlich einfärben —
  das wäre Markenverfälschung.

- **Titelbild der Teamseiten füllt den ersten Bildschirm** (Auftrag vom
  05.09.2026). Kopfzeile und Mannschaftsfoto sollen beim Aufrufen genau
  bis zum unteren Fensterrand reichen. Vorher gab das feste
  Seitenverhältnis 100:44 die Höhe vor — bei 1440×900 waren das 634 px
  Bild plus 100 px Kopfzeile, also **166 px zu wenig**. Neu richtet sich
  `.fc1m-hero` nach dem Fenster:
  `height: calc(100svh - var(--fcx-hdr-h))`. Die Variable trägt bereits
  die Kopfzeilenhöhe (6.25rem, unter 64rem 5.5rem), Kopfzeile und Bild
  passen dadurch immer zusammen.

  `svh` statt `vh`, weil `vh` auf dem Handy die Höhe **ohne**
  eingeblendete Adressleiste meint — das Bild ragte damit beim Laden
  unten heraus. Ein `@supports`-Block hält `vh` als Rückfall.

  **Erst ab 64rem.** In einem hochkanten Fenster würde die volle
  Resthöhe aus einem querformatigen Mannschaftsfoto einen schmalen
  Streifen schneiden, auf dem kaum jemand zu erkennen wäre; darunter
  bleibt es deshalb beim festen Seitenverhältnis.

  Gilt für alle Teamseiten — Aktive wie Junioren, sie teilen sich
  `fcs-1mannschaft.css`. Geprüft bei 1024×768, 1280×800, 1440×900 und
  1920×1080: die unterste Bildzeile ist überall noch Titelbild, das rote
  IFV-Band beginnt erst darunter.

- **Mannschaftsfoto der 3. Mannschaft anders zugeschnitten**
  (Rückmeldung vom 05.09.2026: unten zu viel weg). Das Titelband ist
  sehr breit (100:44), das Foto dagegen 4:3 — es wird also stark
  beschnitten. Alle Teamseiten teilen sich `object-position: center 35%`;
  damit fielen bei diesem Bild die Beine der vorderen Reihe weg, weil
  die Mannschaft darauf tiefer steht als auf den übrigen Fotos. Neu gilt
  **nur für diese Seite** `center 65%` (Körperklasse
  `page-template-page-3mannschaft`) — der Überhang geht oben weg statt
  unten. Geprüft an 35/50/60/65/70/75 %: ab 75 % wird es für die hintere
  Reihe am oberen Rand eng, 65 % hat die Mannschaft samt Füssen drin und
  lässt oben Luft. Die übrigen Teamseiten bleiben unverändert.

  Der Wert ist auf `FCS3_Web2627.jpg` abgestimmt — das neue Foto, das
  `deploy-3mannschaft-feritec.sh` mitbringt. Läuft dieser Deploy hier
  zuerst, greift Schritt 0 und warnt, dass die Datei live noch fehlt.

- **News-Bilder decken früher auf** (Rückmeldung vom 05.09.2026). Der
  Scroll-Auslöser in `fcs-home.js` stand auf
  `rootMargin: "0px 0px -8% 0px"` mit `threshold: 0.1` — die Karte
  startete also erst, wenn sie schon im Bild war. Zusammen mit 620 ms
  Übergang und bis zu 400 ms Staffelung sah man sie unscharf
  nachladen. Neu `rootMargin: "0px 0px 12% 0px"` mit `threshold: 0`:
  der Auslöser liegt jetzt **unterhalb** des Sichtfensters, die Karte
  bekommt beim Hereinscrollen einen Vorlauf. Bei 900 px Fensterhöhe und
  einer 420 px hohen Karte startet sie 222 px früher.

  Der Beobachter ist gemeinsam genutzt, die Änderung gilt also auch für
  die News-Kacheln und Termine der Startseite, die Sponsorenreihen und
  die Personenraster. Das ist gewollt — dasselbe Verhalten, dieselbe
  Ursache.

- **Wechsel der Hero-Storys auf der Startseite neu gemacht**
  (Rückmeldung vom 05.09.2026: «nicht clean»). Drei Ursachen:

  1. Beide Bilder blendeten gleichzeitig über die Opazität. In der Mitte
     lagen beide bei rund 50 %, der dunkle Grund schien durch — ein
     sichtbarer Helligkeitseinbruch. Neu liegt das kommende Bild über
     dem alten (`z-index`) und blendet allein ein, das alte bleibt
     darunter deckend stehen (`.is-leaving`), bis die Blende durch ist.
  2. Datum und Titel sprangen schlagartig um, während das Bild 0,9 s
     brauchte. Neu liegen beide in `.fcsh-hero__story` und gehen kurz
     raus (280 ms), werden getauscht und kommen wieder herein.
  3. Der Ken-Burns-Zoom lief über 9 s weiter, obwohl das Bild nach 0,9 s
     weg war — bei jedem Durchlauf startete er an einer anderen Stelle.
     Neu hängt er allein am aktiven Zustand und beginnt jedes Mal bei
     `scale(1.06)`.

  Dazu: die Automatik hält an, solange die Maus im Hero steht oder der
  Tastaturfokus dort liegt, und pausiert im Hintergrund-Tab.
  `prefers-reduced-motion` schaltet Zoom und Textbewegung ab.

  Bewusst **ohne** reservierte Mindesthöhe für den Titel: der Hero-Inhalt
  ist unten verankert, die Pfeile stehen also ohnehin still (gemessen:
  y = 683 bei allen fünf Storys), und die Titel-Grundlinie liegt immer
  auf 651 px. Ein erster Versuch mit `min-height` drückte kurze Titel um
  74 px nach oben und erzeugte genau den Sprung, den er verhindern
  sollte.

- **Ausschnitt der Betreuerfotos geändert.** `.fc1m-person__photo` stand
  auf `center 15%`: der Überhang wurde unten abgeschnitten, die reichliche
  Luft über dem Kopf blieb im Bild. Neu `center 50%` — der Überhang geht
  oben weg, die Gesichter sitzen mittig und füllen die Karte besser
  (Rückmeldung vom 05.09.2026). Der Wert ist an 18 Fotos inklusive der
  beiden Silhouetten geprüft; ab etwa 55 % wird es bei einzelnen
  Porträts am oberen Rand knapp. Betrifft den Betreuerstab aller
  Teamseiten.

  Noch auf dem alten Stand und mit demselben Verhalten: die Kaderfotos
  der 1. Mannschaft (`.fc1m-player__photo`, `center top`), das
  Leitungsteam der Fussballschule, die Schiedsrichterkarten und die
  Vorstandsseite (alle `object-position: center top`). Auf Zuruf ziehe
  ich die nach.

- **90 Bilder auf web-taugliche Grösse gebracht.** Ein Teil der
  Porträts waren unbearbeitete Kameraoriginale — `Fabrizio_Merenda.jpg`
  etwa 4690×7035 px und 15,5 MB für eine Karte, die rund 290 CSS-Pixel
  breit dargestellt wird, auf Retina also 580 Gerätepixel. Der Browser
  rechnet in einem Schritt um den Faktor 8 bis 16 herunter; feine helle
  Strukturen (graue Barthaare, Zaun, Himmel zwischen Bäumen) bleiben
  dabei als einzelne weisse Punkte stehen und verschwinden erst beim
  Hineinzoomen (Rückmeldung vom 05.09.2026). Jetzt offline sauber
  verkleinert: Porträts auf **1600 px** lange Kante, Kopfbilder auf
  2400 px, JPEG-Qualität 88. Zusammen **164,7 MB -> 33,0 MB, also
  80 % weniger**.

  **Ausgenommen sind die neun Bilder der Vorstandsseite** (Rückmeldung
  vom 05.09.2026: René Gnos und Patrick Schorno unscharf). Die Karten
  dort sind mit 363×484 CSS-Pixeln die grössten Personenkarten der
  Seite — auf Retina 726×968. Vier der Fotos sind zudem **quer**
  (2500×1667) und werden von `object-fit: cover` in ein hochkantes
  Format geschnitten, wobei die halbe Bildbreite wegfällt. Rechnung für
  René Gnos: vom Original liegen 1250 Quellpixel im Ausschnitt und
  füllen 726 Gerätepixel — Faktor 1,72. Nach der Verkleinerung auf
  1600 px waren es nur noch 800 Quellpixel, Faktor 1,10, also praktisch
  keine Reserve. Diese neun Dateien sind deshalb auf dem Originalstand
  und stehen nicht in `deploy/verkleinerte-bilder.txt`.

- **Vier Vorstandsfotos hochkant zugeschnitten** (Auftrag vom
  05.09.2026, Auflage: die Person muss ganz im Bild sein). René Gnos,
  Patrick Schorno, Iwan Herger und Markus Indergand lagen quer
  (2500×1667). `object-fit: cover` schnitt davon die halbe Bildbreite
  weg, und wo der Ausschnitt landete, war dem Zufall überlassen — bei
  Markus Indergand stand die Person deutlich ausserhalb der Mitte. Neu
  liegen sie als `<name>_hoch.jpg` in 1250×1667 vor, also exakt im
  Kartenverhältnis 3:4; die Person sitzt mittig, es wird nichts mehr
  abgeschnitten. Zuschnitt bei voller Bildhöhe, linke Kante bei
  x = 600 / 625 / 660 / 600.

  **Der Zuschnitt bringt keine Schärfe** — die Bildhöhe war schon vorher
  die bindende Grösse, es sind dieselben 1250 Quellpixel. Er bringt die
  Bildwahl. Eine frühere Notiz von mir behauptete das Gegenteil; das war
  falsch.

  Technisch wichtig: die vier Dateien sind **bewusst keine
  Mediathek-Einträge**, und das `<img>` trägt keine `wp-image-`Klasse
  mehr. Sonst hängt WordPress ein `srcset` mit den alten
  Querformat-Vorschauen an (`Rene_Gnos-1024x683.jpg` und so weiter) und
  der Browser holt sich je nach Bildschirm doch wieder den alten
  Ausschnitt. Teil J des DB-Skripts hängt die vier `<img>`-Tags um und
  bricht ab, wenn der erwartete alte Tag nicht gefunden wird.

  Die Zielgrösse ist nicht geraten: 800, 1200, 1600, 2400 und das
  Original wurden bei Retina in der echten Kartengrösse nebeneinander
  gerendert und pixelweise verglichen. 800 und 1200 wirken weich, 2400
  und das Original sprenkeln weiterhin — 1600 ist der Punkt, an dem die
  Sprenkel weg sind und die Schärfe bleibt. Ein erster Anlauf mit 1200
  war zu klein und wurde verworfen.

  Die Dateinamen bleiben, es sind reine Ersetzungen — keine
  Datenbankänderung nötig. Liste: `deploy/verkleinerte-bilder.txt`; die
  Originale liegen lokal als `<name>.orig.<ext>` und werden nicht
  deployt (nach erfolgreichem Deploy löschbar).

  **Achtung beim Prüfen:** Dateiname und URL bleiben gleich, der Inhalt
  ändert sich. Browser liefern deshalb erst nach einem harten Neuladen
  (Cmd+Shift+R) die neue Fassung aus.

**17 neue Dateien in `wp-content/uploads/2026/06/`** — der Ordner ist
über `.gitignore` von der Versionierung ausgenommen, die Dateien liegen
also nur lokal und (nach dem Deploy) live. Schritt 3 des Deploy-Skripts
überträgt diese 17 plus die 81 verkleinerten Ersetzungen und prüft
danach jede einzeln auf HTTP 200:

| Datei | Quelle in `~/Downloads` |
|---|---|
| `Leon_Ziegler.jpg` | `Leon Ziegler_Schiedsrichter.jpeg` |
| `Lucas_Martins_Ferreira.jpg` | `Lucas Martins_Schiedsrichter.jpeg` |
| `Gisler_Stephan_2026.jpg` | `Stephan Gisler_Schiedsrichter.jpeg` |
| `Silhouette_Female.jpg` | `Silhouette_Female.jpg` |
| `ReneHueglin_2026.jpg` | `René Hüglin_Schiedsrichter.jpeg` |
| `FCS_2_Web2627.jpg` | `FCS 2_Web.jpg` |
| `gasthaus-brueckli-2026.jpg` | `brückli_neu.jpeg` |
| `zurich-ga-simon-mani-2026.png` | `ZH 54217-2601 Logo GA Simon Mani Pascal CMYK.pdf` |
| `Flyer_Fussballschule_Herbst_2026.pdf` | `Flyer_Fussballschule_A5_2026-Herbst-DRUCK.pdf` |
| `kms-2026.png` | `Spielersponsoren-Logo/Bild 05.09.26 um 12.24 (2).png` |
| `gotthard-holzbau-2026.png` | `Spielersponsoren-Logo/Bild 05.09.26 um 12.25.png` |
| `heidi-nails-2026.png` | `Spielersponsoren-Logo/Bild 05.09.26 um 12.18.png` |
| `raiffeisen-2026.png` | `Spielersponsoren-Logo/Bild 05.09.26 um 12.26.png` |
| `schelbert-2026.png` | `Spielersponsoren-Logo/Bild 05.09.26 um 12.25 (3).png` |
| `boge-2026.png` | `Spielersponsoren-Logo/Bild 05.09.26 um 12.26 (1).png` |
| `cash-2026.png` | aus `Cash.png` eingefärbt (siehe unten) |
| `brand-automobile-2026.png` | aus `brand-automobile-color.png` eingefärbt (siehe unten) |

Die vier Schiedsrichter-Fotos kamen als Querformat mit
EXIF-Orientierung 6. Sie wurden mit `sips -r 90` gedreht und das
Orientierungs-Tag danach auf 1 gesetzt — sonst hätte der Browser ein
zweites Mal gedreht. Das Zurich-Logo entstand mit
`sips -s format png -Z 1600` aus dem CMYK-PDF (transparenter Grund).

### Ausgegraute Sponsorenlogos: cash. und Brand Automobile

Auf der Startseite standen beide Logos flau grau neben den farbigen
übrigen Sponsoren. Das war **kein CSS-Problem** — die neue Startseite
(`.fcx-spgroup__item img` in `fcs-front.css`) filtert nichts, sie zeigt
`img_color` unverändert. Ausgegraut waren die **Dateien selbst**: von
der alten Vereinsseite stammten nur graue Fassungen, und
`brand-automobile-color.png` war trotz des Namens byteweise so grau wie
`brand-automobile-gray.png`. Ein Anlauf vom 28.06.2026 hat das schon
einmal versucht und Reste hinterlassen (`brand-auto-color-test.png`,
`brand-schwarz.png`, `brand-weiss-raw.png`, `brand-last-try.tmp` — beim
Aufräumen löschbar).

Beide Quelldateien sind flächig einfarbig: **ein einziger Grauwert**
(cash. 133, Brand 134), die Kantenglättung steckt komplett im
Alphakanal. Das Umfärben ist deshalb verlustfrei — Alpha bleibt Pixel
für Pixel erhalten, nur RGB wird gesetzt. Werkzeug dafür:
`scripts/logo-einfaerben.php` (Aufruf im Kopf der Datei). Es bricht ab,
wenn die Quelle mehr als einen Ton enthält, damit niemand versehentlich
ein mehrfarbiges Logo plattfärbt. Die beiden Dateien:

- `cash-2026.png` — Markenblau **#0B2A47**. Exakt aus dem Favicon von
  cashsport.ch entnommen (`favicon_cash.jpg`, 512×512); die Marke ist
  einfarbig, das Ergebnis ist also das echte Logo.
- `brand-automobile-2026.png` — **Schwarz**. Brand Automobile führt
  eine einfarbige Wortmarke: die eigene Website liefert nur eine weisse
  Fassung für dunklen Grund, das Apple-Touch-Icon ist ein weisses «b»
  auf Schwarz.

**Offen bei Brand Automobile:** Im Logo stehen rechts die Marken BMW,
MINI, Opel und Suzuki, die im Original farbig sind (BMW blau/weiss,
Opel gelb, Suzuki rot). In der FCS-Datei liegen sie nur als graue
Silhouetten vor — sie lassen sich nicht rekonstruieren, ohne die Logos
zu erfinden. Für eine wirklich farbige Fassung braucht es eine Datei
von der Garage. Kommt sie, genügt es, sie als
`brand-automobile-2026.png` abzulegen; Vorlage und Deploy zeigen bereits
auf diesen Namen.

### Spieler-Sponsorenlogos: was ersetzt wurde und was nicht

Der Ordner `Spielersponsoren-Logo/` im Projektwurzelverzeichnis enthält
17 Logos ohne sprechende Dateinamen (Bildschirmfotos vom 05.09.2026).
Er ist **nicht** über `.gitignore` ausgenommen — vor einem Commit
entweder löschen oder bewusst mitnehmen.

Ersetzt wurde nur, wo das neue Logo wirklich besser ist:

| Sponsor | bisher | neu |
|---|---|---|
| KMS AG | `kms-orig2.jpg` 456×188 | 898×380 |
| Gotthard Holzbau | `gotthard-orig.png` 388×136, **graustufig** | 1126×390, **farbig** |
| Heidi Nails | `heidi-nails-orig2.jpg` 724×202 | 1020×286 |
| Raiffeisen Urnerland | `raiffeisen-color.png` 348×51 | 958×278 |
| Schelbert AG | `schelbert-color.png` 300×82 | 1020×296 |
| BoGe Brauerei | `boge-color.jpg` 100×100 | 340×432 |

Bewusst **nicht** ersetzt:

- **Dätwyler, Synaxis** — die bisherigen Dateien sind SVG und damit in
  jeder Grösse scharf; die neuen sind Rasterbilder.
- **Centralgarage Musch** — `musch-color.webp` ist 2248×845, das neue
  916×596. Das neue enthält zusätzlich Adresse und Markenlogos, ist
  aber kleiner.
- **Apéro & Pasta Association** — `apero-pasta-orig.jpg` ist 957×1041,
  das neue 500×548. Gleiches Motiv, kleiner.
- **Zurich** — im Ordner liegt das schlichte «Z ZURICH»; die Redaktion
  wollte ausdrücklich die Generalagentur-Fassung.

### 2b. Deploy News-Nachtrag von der alten Vereinsseite

`./deploy/deploy-news-import-0926.sh` trägt die News nach, die auf
www.fcschattdorf.ch seit dem 30.06.2026 erschienen sind — dort endete
der Feed der neuen Seite. **25 Beiträge**, Stand 05.09.2026, der neuste
vom 04.09.2026.

Woher die Daten kommen: die Übersicht unter `/news` listet alle Beiträge
mit Datum, Schlagwort, Titel und Bild; der Volltext steht auf den
Detailseiten `/newsblog/<nr>-<slug>`. Beides wurde ausgelesen und in
`deploy/news-import-0926.json` abgelegt — Titel, Datum, Kategorie,
Bilddatei und die Absätze. Das Importskript
(`deploy/fcs-news-import-0926.php.tpl`) baut daraus Gutenberg-Blöcke im
selben Aufbau wie die bestehenden Beiträge: Bild, dann Absätze.

Kategorien: `FCS I` -> «1. Mannschaft», `FCS II` -> «2. Mannschaft»,
`Frauen I` -> «Frauen», alle `Junioren …` -> «Junioren». **Sechs
Beiträge tragen auf der alten Seite gar kein Schlagwort** und wurden von
Hand zugeordnet, adressiert über ihre Beitragsnummer:

| Nr. | Datum | Titel | Kategorie |
|---|---|---|---|
| 1550 | 26.08. | Zwei neue Ehrenmitglieder und erfreuliche Zahlen | Verein |
| 1543 | 15.08. | Den Schwung aus dem Saisonauftakt mitnehmen | 1. Mannschaft |
| 1542 | 09.08. | Gelungener Saisonauftakt – Baar 1:0 | 1. Mannschaft |
| 1541 | 08.08. | Endlich geht's wieder los | 1. Mannschaft |
| 1540 | 29.07. | FCS-Zyttig Sommer 2026 | Verein |
| 1539 | 27.07. | Juniorenlager: Fussball, Spass und Sonne pur | Junioren |

Verteilung insgesamt: 9× 1. Mannschaft, 10× Junioren, 3× 2. Mannschaft,
2× Verein, 1× Frauen.

**17 Mediendateien** liegen in `wp-content/uploads/2026/09/` — 16 Bilder
und die FCS-Zyttig als PDF (der Beitrag vom 29.07. hat kein Bild, dafür
den PDF-Link im Text). Die Bilder kamen als Kameraoriginale bis 8,7 MB
und wurden wie der übrige Bestand auf 1600 px lange Kante gebracht;
zusammen rund 20 MB. Schritt 1 des Deploys überträgt sie und prüft jede
einzeln auf HTTP 200, bevor das Importskript läuft.

**Reihenfolge:** die alte Seite sortiert nicht streng nach
Beitragsnummer, sondern nach ihrer eigenen Dokumentreihenfolge. An
mehreren Tagen erscheinen bis zu fünf Beiträge. Ein erster Anlauf gab
allen 18:00 Uhr — dadurch drehte WordPress die Reihenfolge innerhalb
eines Tages um. Jetzt trägt der zuoberst stehende Beitrag eines Tages
18:00, der nächste 17:59 und so weiter; nach Datum absteigend sortiert
ergibt das exakt die Folge der alten Seite. Nachgeprüft: **25 von 25
Positionen identisch** über alle drei Seiten des Feeds.

Lokal am 05.09.2026 durchgespielt: alle 25 Beiträge angelegt, Kategorien
und Beitragsbilder gesetzt, Newsseite und Hero der Startseite zeigen den
Stand vom 04.09.2026. Zweiter Lauf meldet 25× «SKIP».

**Nicht automatisiert:** neuere Beiträge auf der alten Seite müssen
wieder von Hand nachgezogen werden, indem `news-import-0926.json`
ergänzt oder eine neue Liste erzeugt wird. Es gibt keine laufende
Synchronisation.

### 2c. Deploy 1. Mannschaft (Vorrunde 2026/27)

`./deploy/deploy-1mannschaft-vorrunde-2627.sh` bringt die Seite
`/aktive/1-mannschaft/` auf den Stand der Vorrunde 2026/27 (DB-Teil:
`deploy/fcs-1mannschaft-vorrunde-2627.php.tpl`). Lokal auf dem
Live-Stand vom 04.09.2026 entwickelt und geprüft: 26 Spieler und 4
Betreuer rendern, alle 51 Bild-URLs liefern HTTP 200. Verifiziert wird
live mit 40 Einzelprüfungen.

**Quelle der Angaben ist www.fcschattdorf.ch/aktive/1-mannschaft** —
die alte Vereinsseite, auf der die Redaktion den aktuellen Stand
pflegt. Sie ist für Team-Inhalte die verlässlichste Quelle und sollte
bei künftigen Kaderarbeiten zuerst abgeglichen werden. Zwei Punkte
waren dort offen und wurden mit dem Verein geklärt: **Joel Aschwanden
(23) ist Verteidigung**, und **Nico Bissig trägt neu die 15, Linus
Arnold die 14** (auf fcschattdorf.ch stehen beide auf 15).

Was der Deploy erledigt:

- **Betreuerstab**: Saverio La Bella neu als Trainer, Thomas Zberg
  rückt vom Trainer zum «Coach» (neues Foto), Reto Infanger entfällt.
  Thomas Aschwanden und Simon Arnold unverändert.
- **Kader**: 11 Zugänge (Livio Mahrow, Mario Arnold, Fabio Moser,
  Sandro Imbach, Joel Aschwanden, Noel Herger, Ben Arnold, Tim Riesen,
  Gian-Luca Tresch, Robin Zurfluh, David Baumann), 5 Abgänge (Gian
  Gisler, Yannick Arnold, Sandro Stampfli, Skander Agrebi, Livio
  Gisler). Neue Porträts auch für Samuel Wirth, Elias Muoser und Nico
  Zgraggen.
- **Kopfsponsoren** durchgehend nachgeführt; neu bzw. gewechselt:
  Mazzei Hypnosetherapie (La Bella), Physio & Sport BackUp (Zberg),
  Apéro & Pasta Association (Mahrow), Arnold Umzüge AG (M. Arnold),
  Das Hauptwerk (Moser), Schibli Elektrotechnik (B. Arnold), Herger
  Küchen AG (Riesen), Zurich (Tresch), Schelbert AG statt Brand
  Automobile (A. Baumann), Coiffure AtmospHAIR statt Zurich
  (Schorno), Gasthaus Brückli statt Kebab Häsli (Zgraggen).
- **Neues Mannschaftsfoto** (`FCS1_Web2627.jpg`) im Hero.
- **Kader-Reihenfolge neu (05.09.2026)**: statt der drei Gruppen
  Torhüter/Verteidigung/Mittelfeld/Sturm zeigt die Seite eine
  durchgehende Liste aufsteigend nach Rückennummer. Die Position bleibt
  am Spieler und steht weiter auf seiner Karte; das Feldformat der
  Feld-Box ist unverändert (`Position | Nr | Name | …`), sortiert wird
  in `fcsh_team_kader()` (`inc/fcs-fields-teams-aktiv.php`). Die
  Zwischentitel `.fc1m-pos-title` sind samt CSS entfernt. Zeilen ohne
  Nummer landen am Schluss. Reine Theme-Änderung, keine DB-Migration.

**23 neue Dateien in `wp-content/uploads/2026/06/`** (Ordner ist über
`.gitignore` ausgenommen, liegt also nur lokal und nach dem Deploy
live). Schritt 3 des Skripts überträgt genau diese und prüft jede
einzeln auf HTTP 200:

| Gruppe | Dateien | Quelle |
|---|---|---|
| Porträts | `Saverio_LaBella.jpg`, `Thomas_Zberg_2627.jpg`, `Livio_Mahrow.jpg`, `GianLuca_Tresch.jpg`, `Samuel_Wirth_2627.jpg`, `Tim_Riesen.jpg`, `Ben_Arnold.jpg`, `Noel_Herger.jpg`, `Nico_Zgraggen_2627.jpg`, `Joel_Aschwanden.jpg`, `Sandro_Imbach.jpg`, `Robin_Zurfluh.jpg`, `Elias_Muoser_2627.jpg` | `~/Downloads/swisstransfer_61839e75-…/_DSC40*_Web.jpg` (Fotoserie August 2026, 1280×1920, kein EXIF-Dreh nötig) |
| Mannschaftsfoto | `FCS1_Web2627.jpg` | `FCS 1_Team_Web.jpg` aus derselben Serie |
| Porträt | `David_Baumann.jpg` | fcschattdorf.ch (in der Serie nicht enthalten) |
| Sponsorenlogos | `mazzei-hypnosetherapie-2026.jpg`, `psbackup-2026.png`, `arnold-umzuege-2026.jpg`, `dashauptwerk-2026.png`, `schibli-elektrotechnik-2026.png`, `zurich-2026.png`, `coiffure-atmosphair-2026.png` | siehe unten |
| bereits vorhanden | `gasthaus-brueckli-2026.jpg` | liegt auch in der Liste des Redaktions-Deploys; doppelt geführt, damit jedes Skript für sich vollständig ist |

**Zu den Sponsorenlogos.** Die Dateien auf fcschattdorf.ch sind
48–162 px breit (`Matchblatt_neu*.png`), unsere Badges werden mit
64 px dargestellt, auf Retina also 128 px. Die Logos wurden deshalb
identifiziert und in hoher Auflösung von den Firmenseiten geholt:
Mazzei von `pmazzei.ch` (1400 px), Arnold Umzüge von
`arnoldumzuege.ch` (800 px), Das Hauptwerk von `dashauptwerk.com`
(503 px), Schibli von `schibliag.ch` (516 px), Zurich von Wikimedia
Commons (1280 px). Herger Küchen, Schelbert AG, Apéro & Pasta und
Gasthaus Brückli lagen bereits in guter Auflösung in der Mediathek.
Coiffure AtmospHAIR kommt mit 788 px direkt von fcschattdorf.ch.

Zwei Ungereimtheiten auf fcschattdorf.ch, die bewusst **nicht**
übernommen wurden: bei Thomas Zberg steht das BackUp-Logo unter einem
Link auf `bogebier.ch`, bei Mattia Schorno das AtmospHAIR-Logo unter
einem Link auf `zurich.ch`. Beides sind offenbar stehengebliebene
alte Links; unsere Vorlage speichert bei Spielern ohnehin nur den
Sponsornamen, keinen Link.

Ebenfalls nicht angefasst: die **Team-Sponsoren-Liste** unten auf der
Seite. Sie war nicht Teil des Auftrags — auf fcschattdorf.ch fehlt
dort neu «Schelbert AG». Falls der Eintrag auch bei uns weg soll, im
Admin unter «Seiteninhalte» → «Team-Sponsoren» löschen.

### 2d. Deploy 3. Mannschaft (Feritec AG)

`./deploy/deploy-3mannschaft-feritec.sh` bringt die Seite
`/aktive/3-mannschaft/` auf den Stand vom 05.09.2026 (DB-Teil:
`deploy/fcs-3mannschaft-feritec.php.tpl`). Lokal auf dem Live-Stand vom
05.09.2026 gefahren: Probelauf, scharfer Lauf und zweiter Lauf («SKIP»)
sind grün, das Skript hat sich selbst gelöscht (HTTP 404). Der Guard im
DB-Teil akzeptiert zwei Altstände — den Live-Stand (nur Binary One) und
den Zwischenstand einer ersten Fassung dieses Skripts, die Feritec noch
zusätzlich zu Binary One gesetzt hätte; beide Wege wurden lokal
durchgespielt.

Was der Deploy erledigt:

- **Neues Mannschaftsfoto** im Hero (`FCS3_Web2627.jpg`) — die Mannschaft
  in den neuen Trikots mit Feritec-Schriftzug. Der Dateiname steht in
  der Vorlage `page-3mannschaft.php`, nicht in der DB.
- **Feritec AG als alleiniger Team-Sponsor.** Binary One fällt weg
  (Rückmeldung vom 05.09.2026). Gesetzt wird das Seitenfeld
  `fcs_team_sponsoren`; die Vorlage führt denselben Stand als Fallback.
  Binary One stand nur auf dieser einen Seite — kein `fcs_sponsor`-
  Eintrag, kein anderes Team — und verschwindet damit von der ganzen
  Website. `sp-binary-one.jpg` bleibt in der Mediathek liegen.

**Zwei neue Dateien in `wp-content/uploads/2026/06/`** (Ordner ist über
`.gitignore` ausgenommen, liegt also nur lokal und nach dem Deploy
live). Schritt 3 des Skripts überträgt sie und prüft jede auf HTTP 200:

| Datei | Quelle |
|---|---|
| `FCS3_Web2627.jpg` | `~/Downloads/3 Manschaft.jpg`, unverändert übernommen |
| `feritec-2026.png` | Vektor-Logo `logo.svg` von feritec.ch, auf 1000×242 px gerendert (transparenter Grund) |

**Zum Logo:** `~/Downloads/Feritec Logo.jpg` lag nur mit 340×86 px und
weissem Grund vor. Der Sponsorenkasten ist 208 px breit, auf Retina also
416 px — deshalb wie bei den Logos der 1. Mannschaft die hochauflösende
Variante direkt von der Firmenseite, hier als Vektor. Gerendert mit
headless Chrome (`--screenshot --default-background-color=00000000`),
weil auf diesem Rechner weder `rsvg-convert` noch ImageMagick liegt.

**Alle drei Mannschaftsfotos wurden am 05.09.2026 neu erzeugt.** Die
Originale lagen in `~/Downloads`; die bisherigen Web-Fassungen kamen aus
kleineren Zweitdateien. Neu gerechnet mit
`sips -Z <Breite> --setProperty formatOptions 82`:

| Datei | Quelle | vorher | neu |
|---|---|---|---|
| `FCS1_Web2627.jpg` | `FCS 1_Team.jpg` (5720×3813) | 2500×1667, 2.0 MB | 2500×1667, 1.7 MB |
| `FCS_2_Web2627.jpg` | `FCS 2.jpg` (5845×3897) | 1920×1280, 1.2 MB | 2500×1667, 1.7 MB |
| `FCS3_Web2627.jpg` | `3 Mannschaft.png` (2000×1500) | 972×730, 0.4 MB | 2000×1500, 1.4 MB |

2500 px Breite ist das Hausmass für Mannschaftsfotos. Beim 3. Team gibt
die Quelle nicht mehr her als 2000 px — das drückt den Retina-Faktor
aber von 3,3 auf 1,6. Die Dateinamen bleiben gleich, die drei Deploys
laden also automatisch die besseren Fassungen hoch; an den Skripten war
nichts zu ändern.

Die ursprünglich gelieferte `3 Manschaft.jpg` (972×730) war eine
verkleinerte Zweitfassung. Die grössere `3 Mannschaft.png` lag im
selben Ordner und wurde beim ersten Durchgang übersehen — bei künftigen
Bildlieferungen lohnt der Blick auf gleichnamige Varianten mit anderer
Endung.

**Nicht angefasst: `/sponsoren/`.** Der Auftrag nannte Feritec AG als
*Team*sponsor. Soll die Firma auch in der allgemeinen Sponsorenliste
stehen, ist das ein eigener Eintrag im Admin unter «Sponsoren» (Logo
`feritec-2026.png` liegt nach dem Deploy bereits in der Mediathek).

### 2e. Deploy Vorstandsseite (Bildqualität)

`./deploy/deploy-vorstand-bilder.sh` behebt einen reinen Website-Fehler
(DB-Teil: `deploy/fcs-vorstand-bilder.php.tpl`). Lokal am 05.09.2026
gefahren: Probelauf, scharfer Lauf, zweiter Lauf («SKIP»), Selbst-
löschung (HTTP 404). Der Inhaltsvergleich vorher/nachher zeigt genau
sieben geänderte Zeilen, sonst nichts.

Im Inhalt der Seite `/verein/vorstand/` standen bei sieben Personen die
von WordPress erzeugten Vorschauen — `-300x200` bzw. `-200x300` —,
obwohl die Originale längst in derselben Mediathek liegen. Die Karten
sind 375 px breit, auf Retina also 750 px: die Bilder wurden bis zu
**4,7-fach** hochskaliert, der schlechteste Wert der ganzen Website.

| Person | vorher | neu |
|---|---|---|
| Iwan Herger, Patrick Schorno, René Gnos | 300×200 | 2500×1667 |
| Ralph Bomatter, Claudia Gisler, Reto Planzer, Orlando Gisler | 200×300 | 1280×1920 |

Das Skript arbeitet nur innerhalb der betroffenen `<figure>`-Blöcke,
zieht `width`/`height` mit und setzt `size-medium` auf `size-full`. Der
Bildausschnitt bleibt gleich — die Vorlage schneidet über CSS auf 4:5
zu (`object-fit: cover`), und die Vorschauen hatten dasselbe
Seitenverhältnis wie die Originale. Markus Indergand (steht schon auf
dem Original) und Robin Lindauer (Silhouette) bleiben unberührt.

### 2f. Noch offen — braucht Dateien oder Angaben

Diese Punkte aus derselben Rückmeldung liessen sich nicht erledigen:

- **Fotos von 13 Betreuern.** Wer kein Bild hatte, bekam die Silhouette:
  Heiri Stadler, Shukri Frangu, Kari Schilter, Philippe Waridel,
  Tim Riesen, Sebi Gisler, Noel Herger, Lulzim Musliu, Marino Arnold,
  Filipos Hagos, Janic Gisler, Fabio Tresch (`Silhouette_Male_v2.jpg`)
  und Christina Gisler (`Silhouette_Female.jpg`). Die vier per Chat
  gelieferten Porträts waren nicht die der Betreuer, sondern die
  Schiedsrichter-Fotos.
  **Zwei davon brauchen keinen Termin:** von Tim Riesen und Noel Herger
  liegen `Tim_Riesen.jpg` und `Noel_Herger.jpg` (je 1280×1920, Serie
  August 2026) in der Mediathek — sie sind auf den Juniorenseiten Dc
  und De nur nicht hinterlegt. Im Admin unter «Seiteninhalte» →
  «Betreuerstab» eintragen, dann bleiben elf offen.
- **Zwei Schiedsrichter-Fotos sind noch nicht zugeordnet:**
  `~/Downloads/IMG_3474.jpeg` (lockige Haare, Bart, helle Jeansshorts)
  und `~/Downloads/IMG_3505.jpeg` (Vollbart, kurze dunkle Haare).
  Ohne Bild sind noch Ayman Labib Badr, Ukaj Alex und
  Giuseppe Accardi — welcher ist wer?
- **Für Roger Zurfluh und Robin Lindauer** (Betreuer 2. Mannschaft)
  liegt kein Foto vor, beide haben die Silhouette.
- **Robin Lindauer hat die männliche Silhouette bekommen.** Seit
  04.09.2026 liegt auch `Silhouette_Female.jpg` bereit — falls die
  weibliche passender ist, im Admin auf der Vorstandsseite tauschen.
- **Das Zurich-Logo ist ein Hochformat-Lockup** (1323×1600). Die
  Logo-Kästen auf `/sponsoren/` sind 110 px hoch, das Logo erscheint
  dort entsprechend schmal. Falls vorhanden, wäre eine Querformat-
  Variante die bessere Wahl.
- **Sechs Logos aus `Spielersponsoren-Logo/` sind im Sponsoren-
  Inhaltstyp nicht verwendet**, weil es dort keinen passenden Eintrag
  gibt: Physio & Sport BackUp, Mazzei Hypnosetherapie, Arnold Umzüge AG,
  Das Hauptwerk, Schibli Elektrotechnik und Herger Küchen AG. Als
  Kader-Sponsorenlogos der 1. Mannschaft sind sie über Abschnitt 2b
  bereits im Einsatz. Offen ist nur, ob eine dieser Firmen zusätzlich
  auf `/sponsoren/` erscheinen soll — dann braucht es je Name, Stufe
  und Website.
- **Zwei Zurich-Logos liegen jetzt in der Mediathek:** `zurich-2026.png`
  (schlichtes «Z ZURICH», Kader-Sponsorlogo der 1. Mannschaft) und
  `zurich-ga-simon-mani-2026.png` (Generalagentur-Fassung, auf
  `/sponsoren/` und bei der 2. Mannschaft). Beides ist so gewollt.
- ~~**Fotoqualität auf der Vorstandsseite.**~~ **Erledigt am
  05.09.2026** (Abschnitt 2d). Die frühere Diagnose in dieser Datei war
  falsch: es fehlten keine grösseren Originale, die Seite band nur die
  Vorschau-Versionen ein. Die Originale lagen die ganze Zeit in der
  Mediathek.
- **Trainingslager-Ort 2027** steht noch auf «Zuchwil», während das
  Datum bereits «Juli 2027» ist. Sobald der Ort feststeht: Seitenfeld
  «Ort» und die Kennzahl «Juli | 2027 · Ort folgt».
- **`/aktive/frauen-uri-2/` liefert nach dem Deploy 404.** Es gibt keine
  Weiterleitungs-Infrastruktur im Theme; die SportsPress-Route
  `/team/frauen-uri-2/` zeigt neu auf `/aktive/`.
- **Sponsor «Herger Küchen» (#484) steht weiterhin auf `/sponsoren/`.**
  Die Rückmeldung nannte ausdrücklich nur die Startseite — falls er auch
  dort weg soll, den Eintrag im Admin löschen.
- **Logo «Physio & Sport BackUp» nur in 104×89 px.** Das ist der
  Kopfsponsor von Thomas Zberg und das einzige Logo der 1. Mannschaft,
  das nicht in hoher Auflösung beschafft werden konnte: `psbackup.ch`
  liefert unter dem eigenen Logo-Pfad `/assets/images/logo.png` die
  Angular-Startseite statt der Datei (Server-Fehlkonfiguration), und
  im Wayback-Archiv gibt es keinen Schnappschuss. Sobald die Datei
  vorliegt: `uploads/2026/06/psbackup-2026.png` ersetzen, der
  Dateiname bleibt.
- **Mario Arnold und Fabio Moser (beide Torhüter) haben kein Porträt**
  und zeigen `Silhouette_Male_v2.jpg` — so wie auf fcschattdorf.ch
  auch. In der Fotoserie vom August 2026 sind sie nicht enthalten.

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
