# Übergabe / Rechnerwechsel

Stand: **12.09.2026**. Diese Datei beschreibt, was gerade offen ist und was
auf einem neuen Rechner eingerichtet werden muss. Die dauerhaften
Projektregeln stehen in `CLAUDE.md`, das Setup der lokalen Umgebung in
`README.md`.

## 1. Aktueller Stand

**Live (https://www.fcschattdorf.ch — seit 07.09.2026 23:5x, vorher fcschattdorf.dynalias.net)**

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

**Domainwechsel erledigt (07./08.09.2026).** Favicon-Modul (`inc/fcs-favicon.php`,
Vereinsemblem statt WordPress-«W») ist seit 08.09. live. Plan und Protokoll in
`UMSTELLUNG.md` (Phasen A und B abgehakt), Branch `umstellung` ist
fast-forward in `main` — kann gelöscht werden. Wichtig für den Betrieb:

- `wp-config.php` auf Hostpoint setzt `WP_HOME`/`WP_SITEURL` fest auf
  `https://www.fcschattdorf.ch` (Konstanten schlagen die DB); Sicherung
  der alten Fassung liegt daneben als `wp-config.php.bak-20260907`.
- Das Zertifikat für `fcschattdorf.ch`/`www` ist **kein FreeSSL**, sondern
  das übernommene Let's-Encrypt-Zertifikat der alten cyon-Seite, gültig
  bis **17.11.2026** (Hostpoints FreeSSL-Bestellung hing stundenlang).
  Bis Anfang November muss FreeSSL im Panel übernommen haben — sonst
  erneuern (Plan B in `UMSTELLUNG.md`, C-Phase).
- Test-Host `fcschattdorf.dynalias.net` leitet per 301 auf www und bleibt
  bis ca. Dezember 2026 (C6).
- Offen aus B6: Kontaktformular und Fanshop-Testbestellung auf der neuen
  Domain einmal auslösen. Phase C (Search Console, 404-Log, Mail
  beobachten, cyon/UBIQ) steht in `UMSTELLUNG.md`.

**Ein Schritt steht aus:** `./scripts/deploy-theme.sh` — zwei
Responsive-Korrekturen vom 12.09. (Abschnitt 2r): der Claim-Text «Seit
1933 …» liegt auf dem Telefon wieder über dem Streifenmuster, und das
Teamfoto der Teamseiten wird auf dem Telefon ganz gezeigt, Titel und
Umschalter darunter. Reiner Theme-Deploy, keine DB, keine Bilder.

**Erledigt und live nachgeprüft (12.09.2026, 00:10):** der Deploy vom
11.09. ist komplett gelaufen — `deploy-inhalte-1109.sh` und der
Theme-Deploy. Live geprüft: FF17-Teamfoto und Porträts, Claudia Gisler
unter `Claudia_Gisler_2026.jpg`, Team-Kacheln (Da zeigt `t=30622`),
1. Mannschaft ohne die alte Gruppe `ls=24454`. Die Prüfliste der
Team-Nummern in Abschnitt 2p (jede Kachel einmal anklicken) bleibt
offen — das kann nur jemand im Browser tun.

**Erledigt und live nachgeprüft (11.09.2026):** die beiden Schritte vom
10.09. (`deploy-inhalte-1009.sh` und der Theme-Deploy) sind gelaufen —
der Frauen-Hero zeigt `FrauenUri1_Web2627.jpg`, das alte Foto ist weg,
FF14 hat ihr Teamfoto auch live.

**Alles vom 09.09.2026 ist live** und wurde nachgeprüft: gelaufen sind
`deploy-liveticker.sh`, `scripts/deploy-theme.sh` (zweimal — der zweite
Lauf für die Responsive-Korrektur am Grümpelturnier-Programm),
`deploy-inhalte-0909.sh` und `deploy-news-1577-bild.sh`. 21 Muster über
Startseite, `/events/`, `/sponsoren/`, `/verein/vorstand/`,
`/aktive/2-mannschaft/` und `/junioren/fussballschule/` waren grün, alle
Token-Skripte vom Webroot verschwunden. Zwei Beobachtungen daraus:

- Die «93. Generalversammlung» verschwand schon mit dem **Theme**-Deploy
  von `/events/`, bevor der Inhalte-Deploy sie in den Papierkorb legte.
  Genau so soll die Anzeige-Ebene der Automatik wirken (Abschnitt 2k).
- Zwischen Theme- und Inhalte-Deploy verwies die Startseite auf ein noch
  nicht hochgeladenes `muoser-weiss.png` — die Hero-Ecke zeigte
  solange ein kaputtes Bild. **Lehre für künftige Deploys dieser Art:**
  wenn eine Vorlage auf eine neue Datei zeigt, gehören Datei und
  Vorlage in denselben Lauf, oder die Datei zuerst.

Offen bleiben ausserdem Schritte ohne Deploy: Kontaktformular und
Fanshop-Testbestellung auf der neuen Domain einmal auslösen (B6),
Phase C in `UMSTELLUNG.md` und die Zertifikatsübernahme bis Anfang
November.

**Erledigt und live nachgeprüft (06./07.09.2026):** Redaktions-
Rückmeldungen (2a), News-Nachtrag mit 25 Beiträgen (2b), 1. Mannschaft
(2c), 3. Mannschaft (2d), Vorstandsbilder (2e), Fussleiste und
Jahrgangs-Automatik (2g) sowie das Impressum (Urinet Aschwanden,
urinet.ch, Stand September 2026). Die Abschnitte bleiben als Protokoll stehen.

Zwei Stolpersteine beim Nachprüfen, die schon zu Fehlalarmen geführt
haben:

- Die vier Vorstandsfotos liegen live als `<name>_hoch.jpg`. Wer nach
  `Rene_Gnos.jpg` sucht, findet nichts und hält den Deploy
  fälschlich für gescheitert.
- «Team Uri Frauen» steht auch im Fliesstext eines älteren Beitrags.
  Als Prüfmuster für den News-Import taugt es nicht — dafür den vollen
  Titel nehmen.

**Zu Beginn jeder Session `./scripts/pull-prod-db.sh` laufen lassen.**
Die lokale DB entsprach am 09.09.2026 dem Live-Stand (frisch gezogen,
danach derselbe Inhalte-Deploy lokal wie live gefahren) — durch die
Redaktionsarbeit im Live-Admin veraltet sie aber laufend.

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

- **Jahreszahlen der Vereinsgeschichte rechnen sich selbst fort**
  (`inc/fcs-vereinsjahre.php`, neu am 06.09.2026). Die Meta-Beschreibung
  sagte «110 Jahre FC Schattdorf … von der ersten Gründung 1916» —
  beides ab 1916 gerechnet, während die Seite ab 1933 zählt, und die
  Zahl wäre jeden Neujahr veraltet.

  Neu liefern zwei Funktionen beides: `fcs_gruendungsjahr()` (Seitenfeld
  «Gründungsjahr», sonst 1933, mit Plausibilitätsgrenzen) und
  `fcs_vereinsjahre()`. Die Vorlage benutzt sie für «Gegründet …» und
  «Jahre Geschichte»; Yoast bekommt sie als Platzhalter
  `%%fcs_vereinsjahre%%` und `%%fcs_gruendungsjahr%%`, angemeldet über
  `wpseo_register_extra_replacements`. In der Datenbank stehen die
  Platzhalter, eingesetzt werden sie bei jedem Seitenaufruf — **der
  Jahreswechsel braucht also keinen Deploy**.

  Ein Sicherheitsnetz auf `wpseo_metadesc`, `wpseo_opengraph_desc`,
  `wpseo_twitter_description` und `wpseo_title` ersetzt die Platzhalter
  auch dann, wenn Yoast einmal fehlt — roh im Quelltext landen sie nie.
  Geprüft: Feld testweise auf 1930 gesetzt, daraufhin zeigten Seite und
  Beschreibung übereinstimmend 96 Jahre; nach dem Leeren wieder 93.

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

### 2g. Jahrgänge auf «Mitglied werden» rechnen sich selbst

Auf der Seite standen die Jahrgänge doppelt und fest im Text — einmal im
Titel («Juniorenbereich · Jahrgang 2012–2006») und einmal im Fliesstext.
Sie veralteten damit jede Saison still. Neu stehen sie **nur noch im
Text**, und dort als Platzhalter:

    %%fcs_jahrgaenge_junioren%%   ->  «2012 bis 2006»   (A- bis C-Junioren)
    %%fcs_jahrgaenge_kinder%%     ->  «2018 bis 2013»   (F- bis D-Junioren)

`inc/fcs-jahrgaenge.php` löst sie bei jedem Seitenaufruf auf. Gerechnet
wird nicht mit Jahreszahlen, sondern mit Altersabständen zum Saisonjahr
(Junioren 14–20, Kinder 8–13) — daran ändert der Saisonwechsel nichts.

**Der Wechsel passiert im August, nicht am 1. Januar.** Die
Jahrgangs-Einteilung hängt an der Saison; spränge sie im Januar um,
stünde ein halbes Jahr lang die Einteilung der noch gar nicht
begonnenen Saison auf der Seite:

| Stichtag | Saison | Junioren A–C | Kinder F–D |
| --- | --- | --- | --- |
| 09.2026 … 07.2027 | 2026/27 | 2012 bis 2006 | 2018 bis 2013 |
| 08.2027 … 07.2028 | 2027/28 | 2013 bis 2007 | 2019 bis 2014 |
| ab 08.2028 | 2028/29 | 2014 bis 2008 | 2020 bis 2015 |

Die Ersetzung läuft über den Filter `fcs_platzhalter` und damit durch
dieselbe Funktion wie `%%fcs_vereinsjahre%%` (`inc/fcs-vereinsjahre.php`,
Abschnitt weiter unten). `fcs_pf()` und `fcs_pf_lines()` lösen sie jetzt
ebenfalls auf — die Platzhalter funktionieren also auch in den Feldern
der Box «Seiteninhalte» und in Yoast, nicht nur in den Vorgaben der
Vorlage.

**Warum es zusätzlich einen DB-Deploy braucht:** die Einstiegswege
stehen im Seitenfeld `fcs_mw_tracks` (Seite #36). Sobald dieses Feld
gepflegt ist — und das ist es seit dem Redaktions-Deploy —, greift die
Vorgabe der Vorlage nicht mehr. Der Theme-Deploy allein ändert an der
Seite deshalb nichts.

Reihenfolge zwingend:

    ./scripts/deploy-theme.sh        # zuerst: Modul und Vorlage
    ./deploy/deploy-jahrgaenge.sh    # danach: Feldwert in der DB

`deploy-jahrgaenge.sh` prüft in Schritt 1 per SSH, ob
`inc/fcs-jahrgaenge.php` live liegt, und bricht sonst ab — sonst
stünden die rohen `%%…%%` auf der Seite. Das PHP-Skript ersetzt vier
Textstellen und schreibt nur, wenn jede davon **genau einmal**
vorkommt; wurde das Feld zwischenzeitlich im Admin gepflegt, meldet es
ABBRUCH und rührt nichts an. Ein zweiter Lauf meldet SKIP.

Wird das Feld künftig im Admin bearbeitet: die Platzhalter
stehenlassen, keine festen Jahreszahlen eintragen. Der Hinweis dazu
steht im Beschriftungstext des Feldes (`inc/fcs-fields-design2.php`).

### 2h. Trainingslager-Porträts und Schiedsrichter-Fotos

**Trainingslager.** Sandro Zamuner und René Gnos standen im Aufruf-Block
nur als Name mit Telefonnummer, frei im Weissraum. Sie sitzen jetzt in
derselben Kartenform wie `.tl-campus-card` weiter oben auf der Seite:
weiss, 12 px Radius, rote Oberkante, weicher Schatten, Foto randlos
oben (4:5, von oben beschnitten), Telefonnummer als eigene Zeile mit
Trennlinie — auf dem Handy ein sicheres Ziel zum Antippen.

Der Block trägt **bewusst keine Überschrift** — der Anmelde-Aufruf
«Bist du dabei?» ist abgeschaltet, und eine eigene sollte der
Kontaktteil auf Wunsch nicht bekommen. Damit die beiden Karten
trotzdem nicht in einer riesigen leeren Fläche stehen, nimmt die
Klasse `tl-cta-section--kontakt` die doppelte Polsterung heraus,
solange `tl_cta_lead` und `tl_anmeldung_url` leer sind.

Das Zeilenformat von `tl_kontakte` hat dafür ein viertes Feld
bekommen:

    Name | Rolle | Telefon | Bilddatei

Leeres viertes Feld = kein Foto. Beide Bilder (`Sandro_Zamuner.jpg`,
`Rene_Gnos_hoch.jpg`) lagen bereits in uploads/2026/06 — der Deploy
überträgt keine Dateien, er ergänzt nur den Feldwert. Wie bei den
Jahrgängen gilt: das Feld ist gepflegt, die Vorlagen-Vorgabe greift
nicht, es braucht beide Deploys.

**Schiedsrichter.** Am 07.09.2026 kamen sechs benannte Aufnahmen. Vier
davon sind dieselben Bilder, die schon live liegen — neu waren nur
Ayman Labib Badr und Giuseppe Accardi. Ukaj Alex hat weiterhin kein
Foto, dafür liegt keine Aufnahme vor.

Alle sechs Dateien trugen **EXIF-Orientierung 6**: im Finder und im
Browser sehen sie aufrecht aus, die Pixel liegen aber quer (640×480).
WordPress berücksichtigt das beim Erzeugen der Vorschaubilder nicht —
die Karten hätten die beiden liegend gezeigt. Die zwei übernommenen
Bilder sind deshalb gedreht und das Tag auf 1 gesetzt worden; sie sind
jetzt 480×640 wie die übrigen. **Bei künftigen Handyfotos immer
zuerst die Orientierung prüfen.**

### 2i. Fanshop: Bestellungen an die Administration

`fcsh_handle_shop_order()` in `functions.php` schickte die
Bestellbenachrichtigung an `marketing@fcschattdorf.ch`. Empfänger ist
neu `admin@fcschattdorf.ch` (Wunsch vom 07.09.2026). Die
Bestätigungsmail an den Besteller bleibt unverändert.

`marketing@` steht weiterhin auf der Sponsoren-Seite und beim Vorstand
— das ist die Adresse für Sponsoring-Anfragen und hat mit dem Fanshop
nichts zu tun. Nicht versehentlich mitziehen.

Reine Theme-Änderung, kein DB-Deploy.

### 2j. News-Nachtrag vom 07.09.2026

Der erste Nachtrag (Abschnitt 2b) endete bei Beitrag 1573 vom 04.09.
Seither sind auf www.fcschattdorf.ch drei weitere erschienen:

| Nr. | Titel | Kategorie | Bild |
| --- | --- | --- | --- |
| 1577 | Bittere 2:3 Niederlage gegen Hünenberg | 2. Mannschaft | `FCS_2_Web.jpg` (lag schon live) |
| 1576 | Erneute Niederlage für die Ba-Junioren | Junioren | `Ba-GeringQWEB.jpg` (neu) |
| 1575 | Den SC Engelberg gleich zweimal bezwungen | Junioren | `Ca-2425-geringWEB.jpg` (lag schon live) |

**Die Quelle findet man am zuverlässigsten über den RSS-Feed**
`https://www.fcschattdorf.ch/newsblog?format=feed&type=rss` — die
Übersichts- und Kategorieseiten laden ihre Beiträge per JavaScript
nach und sind mit `curl` leer. Die Kategoriefeeds sind ebenfalls leer;
die Zuordnung zu «1. Mannschaft», «Junioren» usw. muss aus dem Inhalt
kommen.

**Bilder und Zuordnung sind die der Quelle.** Ein einziger Eingriff:
in 1576 stand «Ba- Junioren» mit Leerzeichen — Tippfehler der Quelle,
korrigiert.

**Achtung, Nachzügler:** der Deploy vom 07.09.2026 lief mit einer
früheren Fassung der Datenliste, in der 1577 auf `FCS_1_Team_Web.jpg`
und «1. Mannschaft» hing. Der News-Import kann das nicht nachziehen —
er überspringt Beiträge, deren Slug schon existiert. Dafür gibt es
`./deploy/deploy-news-1577-bild.sh`, das gezielt Beitragsbild,
Bildblock und Kategorie korrigiert.

Notiz zu 1577: der Beitrag trägt das Mannschaftsfoto der zweiten
Mannschaft und ist entsprechend eingeordnet. Auffällig bleibt, dass er
als einziger Bericht der zweiten Mannschaft nie «Schattdorf 2» im
Fliesstext nennt und die genannten Torschützen im Kader der ersten
stehen. Das zu klären ist Sache der Redaktion — der Import folgt der
Quelle.

**Zur Bildqualität** (Frage vom 07.09.2026): mehr ist nicht
herauszuholen. Die Beitragsbilder werden immer mit **rund 630 px**
dargestellt — der Inhaltsbereich ist gedeckelt, auch auf einem
2560-px-Schirm. Die Dateien sind 1600 px breit, also bereits 2,5-fach.
Gemessen am verlustfrei nachkodierten Detailgehalt liegen JPEG-Qualität
70 bis 95 gleichauf; nur Qualität 100 hält ~11 % mehr Detail, bei
vierfacher Dateigrösse. Und eine frische 1600-px-Verkleinerung aus dem
7035-px-Original unterscheidet sich um 1 % von der vorhandenen Datei.
Grössere Quelldateien landen schlicht nicht auf dem Bildschirm.

**Neu gegenüber dem ersten Nachtrag:** fett ausgezeichnete Absätze der
Quelle werden zu `<h3>`-Zwischentiteln statt zu Fliesstext (1577 hat
zwei davon). Der Lead-Absatz bleibt Fliesstext, wie in den 25 bereits
importierten Beiträgen. Die Datenliste führt sie unter
`zwischentitel`.

`Ba-GeringQWEB.jpg` kam mit 7035 px und 6,5 MB von der alten Seite und
wurde auf 1600 px / 564 KB gebracht — dieselbe Grösse wie die übrigen
Bilder des ersten Nachtrags.

### 2k. Redaktions-Nachträge vom 09.09.2026

Sieben Rückmeldungen aus zwei Mails (die letzten beiden — Schreibweise
des Apéro-Termins und Fussballschule — kamen nach). Der Theme-Teil geht über
`./scripts/deploy-theme.sh`, alles Inhaltliche über
`./deploy/deploy-inhalte-0909.sh` (DB-Teil:
`deploy/fcs-inhalte-0909.php.tpl`). Lokal auf dem Live-Stand vom
09.09.2026 durchgespielt: Probelauf, scharfer Lauf und zweiter Lauf
(«SKIP») grün, das Skript hat sich selbst gelöscht.

**1. Muoser-Wortmarke in der Hero-Ecke der Startseite.** Dort stand
`<p class="name">MUOSER</p>` — der Markenname in der Hausschrift des
Themes nachgebaut, was der Redaktion aufgefallen ist. Jetzt steht dort
die echte Wortmarke in Weiss. Herkunft der Datei:
`muoser-color.png` (1000×411, ein einziger Ton `#45516A`) auf die
Wortmarke zugeschnitten (0,0 → 1000×185; darunter beginnt nach einer
Lücke der Claim «Wir gestalten Räume») und mit
`scripts/logo-einfaerben.php` auf `#FFFFFF` umgefärbt — der
Alphakanal bleibt dabei Pixel für Pixel erhalten. Ergebnis:
`muoser-weiss.png`. Die Höhe gibt das CSS vor (1.375 rem, in
`fcs-front.css` 1.25 rem), nicht die Breite: so sitzt jedes künftige
Sponsorenlogo dort auf derselben Linie wie zuvor der Text. Der Logo-
Block ist wie bisher **kein Link** — das war er vorher auch nicht.

**2. Vergangene Veranstaltungen räumen sich selbst weg.** Zwei Ebenen
in `inc/fcs-events.php`, damit ein abgelaufener Termin nie stehen
bleibt:

- **Anzeige.** `page-events.php` ruft jetzt `fcs_get_events( true )`
  auf — wie die Termin-Kachel der Startseite es schon immer tat. Ein
  Termin verschwindet damit am Tag nach seinem letzten Tag von der
  Website, ganz ohne Cron.
- **Aufräumen.** Der tägliche Cron `fcs_events_aufraeumen` legt
  vergangene Veranstaltungen in den **Papierkorb**. Bewusst kein
  endgültiges Löschen: die Redaktion kann einen Eintrag
  wiederherstellen und z. B. für die Weihnachtsfeier des Folgejahres
  kopieren. Von der Website sind sie so oder so weg. Einträge ohne
  gültiges Datum fasst der Cron nie an.

Massgeblich ist `fcs_event_ende()` — das neue Feld **Enddatum**
(`fcs_ev_datum_bis`), sonst das Datum. Gerechnet wird mit
`current_time()`, nicht `date()`: der Server läuft auf UTC, gezählt
wird der Schweizer Kalendertag. Lokal geprüft mit drei Testterminen:
gestern → Papierkorb, mehrtägig-noch-laufend → bleibt, ohne Datum →
bleibt.

**3. Sechs neue Termine**, die «93. Generalversammlung» (21.08.2026)
in den Papierkorb:

| Datum | Titel | Zeit | Ort |
| --- | --- | --- | --- |
| 24.10.2026 | Vorrundenabschluss | ab 17.00 Uhr | Sportplatz Grüner Wald, Schattdorf |
| 28.11.2026 | Weihnachtsfeier | ab 18.00 Uhr | Uristier-Saal, Altdorf |
| 24.04.2027 | Ehren-/Freimitglieder und Sponsorenapéro | offen | offen |
| 27.05.2027 | Kick-in-one | offen | Sportplatz Grüner Wald, Schattdorf |
| 17.–19.06.2027 | Dorf- und Grümpelturnier | offen | Sportplatz Grüner Wald, Schattdorf |
| 04.12.2027 | Weihnachtsfeier | offen | Uristier-Saal, Altdorf |

Wo Zeit oder Ort noch ausstehen, steht wie bei der bisherigen GV
«Wird bekannt gegeben» (Kurzform «Zeit folgt» / «Ort folgt»). Das
Grümpelturnier ist der erste mehrtägige Eintrag: die Karte zeigt im
Datums-Badge den ersten Tag und daneben die Spanne
«17. – 19. Juni 2027» (`fcs_event_spanne()`, kürzt Monat und Jahr
weg, solange sie gleich bleiben). Die Zeile «Upcoming Events 2026»
führt die Jahreszahl nur noch, solange alle Termine im selben Jahr
liegen — sonst stünde über einer Liste bis 2027 die Zahl des ersten.

Zielgruppe, Hinweiszeile und Agenda bleiben bei allen sechs leer;
diese Angaben lagen nicht vor und werden nicht erfunden.

**Schreibweise des Apéro-Termins** (Rückmeldung vom 09.09.2026): ohne
Bindestrich nach «Freimitglieder», genau wie geliefert. Eine erste
Fassung dieses Deploys hatte ihn grammatikalisch ergänzt
(«Freimitglieder- und»). Das DB-Skript benennt einen bereits
angelegten Termin mit der alten Schreibweise um (Schritt A2), das
Ergebnis ist also dasselbe, egal ob der Deploy zum ersten oder zum
zweiten Mal läuft. Die Idempotenz der Terminanlage hängt seither am
**Datum**, nicht mehr am Titel — jeder der sechs Termine hat ein
eigenes, und ein von Hand geänderter Titel führt so nie zu einem
doppelten Eintrag.

**4. WhatsApp-Kanal korrigiert.** Der bisherige Link
(`0029VbCwxidGehEK9HVaJ01G`) war der falsche, richtig ist
`0029VbDULM4FXUugCV1Kiq1M`. Er stand nur im Theme-Code
(`front-page.php` dreimal, `footer.php` einmal), nicht in der
Datenbank — reine Theme-Änderung.

**5. Sponsoren.** Beide Einträge lagen ohne Website-Link vor:

- **Zurich Insurance** → `zurich.ch/de/standorte/generalagentur-simon-mani-6010-kriens`
- **Duftruim** (im Admin so benannt, auf dem Logo «Duftruim
  Massagepraxis / Olivia Bachmann») → `duftruim.com`, ausserdem
  `duftruim-color.png` → `duftruim-2026.png`. Trotz des Namens war
  `duftruim-color.png` das **graue** Logo; das farbige kam als
  `~/Downloads/Olivia Bachmann.png` (642×700) und wurde unverändert
  übernommen. Die alte Datei bleibt in der Mediathek liegen.

Der generische Link `zurich.ch` im Team-Sponsoren-Feld der
2. Mannschaft bleibt, wie er ist — er war nicht Teil der Rückmeldung.

**6. Porträts Robin Lindauer und Claudia Gisler** (aus `~/Downloads`,
beide 1280×1920, dieselbe Fotoserie wie die übrigen Vorstandsbilder,
unverändert übernommen).

- **Claudia Gisler**: das neue Foto ersetzt `Claudia_Gisler.jpg` unter
  demselben Namen. Anders geht es nicht sauber — der Bildblock der
  Vorstandsseite hängt an Mediathek-Eintrag **#218**, und WordPress
  baut das `srcset` aus dessen Vorschaudateien. Ein neuer Dateiname bei
  gleichbleibendem `wp-image-218` hätte im `srcset` weiter das alte
  Foto ausgeliefert. Das Deploy-Skript sichert die alte Fassung vorher
  auf dem Server als `Claudia_Gisler.bak-20260909.jpg` (lokal liegt sie
  ebenso), das DB-Skript rechnet die Vorschaugrössen neu.
- **Robin Lindauer**: hatte als Einziger im Vorstand noch die
  Silhouette. `Robin_Lindauer.jpg` wird als Mediathek-Eintrag angelegt
  (damit die Redaktion es findet und das `srcset` stimmt) und in den
  `<figure>`-Block mit `alt="Robin Lindauer"` gesetzt. Dieselbe Datei
  ersetzt sein Betreuerbild auf der **2. Mannschaft** — dort steht der
  Betreuerstab im Seitenfeld `fcs_team_staff`, die Liste in
  `page-2mannschaft.php` ist nur der Fallback; beide wurden
  nachgeführt. **Roger Zurfluh behält dort die Silhouette**, zu ihm
  liegt kein Foto vor.

Nicht angefasst: **Robin Mahrow** (Fussballschule, `Rubi_Mahrow.jpg`)
und **Robin Zurfluh** (1. Mannschaft) — andere Personen.

**7. Nico Zgraggen aus dem Team der Fussballschule** (Rückmeldung vom
09.09.2026). Wie beim Betreuerstab der 2. Mannschaft steht die Liste
im Seitenfeld (`fcs_fs_team`, Seite «Fussballschule»); die Liste in
`page-fussballschule.php` ist nur der Fallback — beide wurden
nachgeführt. Das DB-Skript streicht genau die Zeile, die mit
«Nico Zgraggen |» beginnt, und bricht ab, wenn dabei nicht exakt eine
Zeile wegfällt. Von acht Personen bleiben sieben. Der gleichnamige
**Spieler der 1. Mannschaft** (`Nico_Zgraggen_2627.jpg`) ist davon
nicht betroffen — andere Seite, anderes Feld.

**8. Grümpelturnier, Programm-Abschnitt auf dem Telefon** (Rückmeldung
vom 09.09.2026). Unterhalb von 480 px klappte das Datum als
Vollbreiten-Streifen **über** das Ereignis; gewünscht ist die
Desktop-Anordnung, Datum **links daneben**. In
`assets/fcs-gruempelturnier.css` ersetzt die 480er-Regel das
`grid-template-columns: 1fr` jetzt durch `100px 1fr`, dazu kleinere
Innenabstände und je eine Stufe kleinere Schrift bei Wochentag und
Datum — sonst bricht «DONNERSTAG» um. Bei 390 px und bei 320 px
geprüft: einzeilig, kein seitliches Überlaufen. Reine CSS-Änderung,
geht mit dem Theme-Deploy (Schritt 1) mit.

**Zum Nachprüfen von Responsive-Änderungen:** `--window-size` steuert
in Chrome 151 headless den Viewport **nicht** — Screenshots zeigen den
linken Ausschnitt einer Desktop-Ansicht, und Media Queries greifen
nicht. Verlässlich ist eine Hilfsseite im Webroot mit
`<iframe src="…" width="390">`: der iframe gibt dem eingebetteten
Dokument echte 390 px. Ausserdem gibt es auf macOS kein `timeout` —
ein davorgesetztes `timeout` lässt den Befehl kommentarlos ausfallen.

**Vier neue bzw. ersetzte Dateien in `wp-content/uploads/2026/06/`**
(Ordner ist über `.gitignore` ausgenommen, liegt also nur lokal und
nach dem Deploy live). Schritt 2 des Skripts überträgt sie und prüft
jede auf HTTP 200:

| Datei | Quelle |
| --- | --- |
| `muoser-weiss.png` | Wortmarke aus `muoser-color.png`, zugeschnitten und weiss eingefärbt |
| `Robin_Lindauer.jpg` | `~/Downloads/Robin_Web.jpg`, unverändert |
| `Claudia_Gisler.jpg` | `~/Downloads/Claudia_Web.jpg`, unverändert — **ersetzt** die bestehende Datei |
| `duftruim-2026.png` | `~/Downloads/Olivia Bachmann.png`, unverändert |

**Zur GV-Meta-Beschreibung:** auf `/events/` steht weiterhin
«…Generalversammlung, Turniere und Anlässe…» in der Yoast-
Beschreibung. Das ist eine Gattungsbeschreibung, kein Rest des
gelöschten Termins — bleibt bewusst stehen.

### 2l. Redaktions-Nachträge vom 10.09.2026

`./deploy/deploy-inhalte-1009.sh` (DB-Teil:
`deploy/fcs-inhalte-1009.php.tpl`, Texte:
`deploy/news-import-1009.json`). Lokal auf zwei frisch gezogenen
Live-Ständen durchgespielt: Probelauf, scharfer Lauf und zweiter Lauf
(«SKIP» überall) grün, das Skript hat sich samt Textliste selbst
gelöscht.

**Drei neue Beiträge** aus Word-Vorlagen in `~/Downloads`:

| Titel | Kategorie | Bild | Quelle |
| --- | --- | --- | --- |
| Charaktertest auf dem Grünen Wald | 1. Mannschaft | `FCS_1_Team_Web.jpg` (lag schon live) | `2026-09-12_FC Gunzwil (H).docx` |
| Erfolgreiche Englische Woche mit 2 Siegen! | Frauen | Artikel `Team_Uri_Frauen_09-09-2026.jpg`, Beitragsbild `Team_Uri_Frauen_Team_26-27.jpg` | `Zeitungsbericht Team Uri Frauen I_09.09.26.docx` |
| Urner Derby erst in der Schlussphase entschieden | Junioren | `Cb_Junioren_25-26.jpg` | `Spielbericht Cb Junioren FC Schattdorf FC Altdorf.docx` |

Aufbau wie beim Nachtrag vom 07.09.: Bildblock, Fliesstext, fett
ausgezeichnete Absätze der Quelle als `<h3>`-Zwischentitel. Nur die
Gunzwil-Vorschau hat welche (drei); die beiden Spielberichte sind in
der Quelle durchgehender Fliesstext und bleiben es.

**Titel: kein Teamname davor** (Regel vom 10.09.2026). Beide Berichte
tragen den Titel der Quelle, ohne Präfix — die Kategorie nennt das Team
ohnehin. Aus «Team Uri Frauen: Erfolgreiche Englische Woche…» wurde
«Erfolgreiche Englische Woche mit 2 Siegen!», aus «Cb-Junioren: Urner
Derby…» wieder «Urner Derby erst in der Schlussphase entschieden».
Slug jeweils mitgezogen (die Beiträge waren noch nicht live, es bleibt
also keine alte Adresse zurück).

Der Cb-Titel ist damit wortgleich mit dem Ca-Bericht vom 02.09.2026
(#821, derselbe Einsender). Unterschieden wird deshalb nur der **Slug**:
`…-entschieden-cb`. Ohne das hängte WordPress ein nichtssagendes «-2»
an.

**Beim Cb-Bericht** entfallen wie beim Ca-Bericht die Einsenderangaben,
die Zeitungsrubrik, die Resultatzeile und die Fotohinweise; es bleiben
die drei Fliesstext-Absätze.

**Die Beitragsdaten liegen am Vormittag des 10.09.** (08:28/08:29/08:30)
und nicht wie sonst auf 18:00 Uhr. Grund: WordPress macht aus einem
Beitrag mit Datum in der Zukunft einen **geplanten** Beitrag, der nicht
auf der Website steht. Das DB-Skript fängt das zusätzlich ab und nimmt
dann die aktuelle Zeit.

**Der Frauen-Bericht hat zwei Bilder** (Rückmeldung vom 10.09.2026).
Der Titel der Quelle beginnt mit «Team Uri Frauen: » — das ist weg, die
Kategorie sagt es ohnehin; Titel und Slug lauten jetzt «Erfolgreiche
Englische Woche mit 2 Siegen!».

Wichtiger ist das Bild. Das Jubelbild ist **hochkant** (1536×2048). Im
Hero der Startseite, der rund 2,1:1 breit ist und mit
`background-size: cover` arbeitet, bleibt davon nur ein waagrechter
Streifen von etwa 35 % der Bildhöhe sichtbar — und der wird um das
Anderthalbfache hochskaliert. Ergebnis: zu nah dran und flau. Das lässt
sich mit demselben Bild **nicht** beheben; ein Hochformat in einem
breiten Hero zeigt zwangsläufig nur einen Ausschnitt.

Deshalb trägt der Beitrag jetzt **zwei Bilder**: im Artikel weiterhin
das Jubelbild (neu in voller Quellauflösung statt auf 1200 px
verkleinert), als **Beitragsbild** — und damit im Hero und in den
News-Kacheln — das Mannschaftsfoto im Querformat
(`Team_Uri_Frauen_Team_26-27.jpg`, 2000 px). Dort sieht man das ganze
Team mit Luft ringsum, gestochen scharf. Soll im Hero doch das
Jubelbild stehen, genügt es, `beitragsbild` aus dem Frauen-Eintrag in
`deploy/news-import-1009.json` zu entfernen.

**Dazu ein zweiter Yoast-Stolperstein.** Ein Beitragsbild, das erst
nach `wp_insert_post()` per `set_post_thumbnail()` gesetzt wird, kennt
Yoast beim Bauen seiner Indexable-Zeile noch nicht — es nahm das erste
Bild im Text, also wieder das Hochformat. Das Beitragsbild geht deshalb
als `meta_input` **mit in den Insert**. Der Deploy prüft das mit dem
Muster `og:image[^>]*Team_Uri_Frauen_Team_26-27`.

**Neues Mannschaftsfoto der Frauen auf `/aktive/frauen-uri-1/`**
(`~/Downloads/Damen_Mannschaftsfoto.jpg`, 5282×3521 → 2500 px, wie
`FCS1_Web2627.jpg`). Der Dateiname steht wie bei der 1. und
3. Mannschaft in der **Vorlage** (`page-frauen-uri-1.php`,
`FrauenUri1_Web2526.jpg` -> `FrauenUri1_Web2627.jpg`), nicht in der DB
— deshalb der zusätzliche Theme-Deploy.

**Neues Teamfoto der Ba-Junioren** (`~/Downloads/Ba Junioren_Teamfoto.jpeg`,
2000×1500). Es geht an drei Stellen ein:

- Seitenfeld «Teamfoto» der Ba-Seite (`fcs_jt_foto`, Seite #64) — das
  speist zugleich die Kachel auf der Teams-Übersicht. Beide standen
  vorher auf dem Platzhalter.
- Bild und Beitragsbild im letzten Ba-Beitrag «Erneute Niederlage für
  die Ba-Junioren» (#857), bisher `Ba-GeringQWEB.jpg`.

**Erstes Teamfoto für Team Uri FF14** (`~/Downloads/FF14 Teamfoto.jpg`,
5150×3433, 13 MB — auf 2000 px verkleinert). Seite #806 stand ebenfalls
auf dem Platzhalter.

**Sieben neue Dateien in `wp-content/uploads/`** (Ordner ist über
`.gitignore` ausgenommen, liegt also nur lokal und nach dem Deploy
live). Schritt 1 des Skripts überträgt sie und prüft jede auf HTTP 200:

| Datei | Quelle |
| --- | --- |
| `2026/06/Ba_Junioren_26-27.jpg` (2000 px) | `Ba Junioren_Teamfoto.jpeg` |
| `2026/06/FF14_Team_26-27.jpg` (2000 px) | `FF14 Teamfoto.jpg` |
| `2026/09/Ba_Junioren_26-27.jpg` (1600 px) | dieselbe Quelle, News-Grösse |
| `2026/09/Cb_Junioren_25-26.jpg` (1600 px) | aus `2026/06/Cb_Junioren_25-26.jpg` |
| `2026/09/Team_Uri_Frauen_09-09-2026.jpg` (1536×2048) | `Damen Team Uri 1_Zeitungsberichtbild.jpeg`, volle Quellauflösung |
| `2026/09/Team_Uri_Frauen_Team_26-27.jpg` (2000 px) | `Damen_Mannschaftsfoto.jpg`, Beitragsbild des Frauen-Berichts |
| `2026/06/FrauenUri1_Web2627.jpg` (2500 px) | `Damen_Mannschaftsfoto.jpg`, Hero `/aktive/frauen-uri-1/` |

Damit bleiben die Grössen des Projekts erhalten: **Teamfotos 2000 px**
in `2026/06`, **News-Bilder 1600 px** in `2026/09` (Hochformat auf
1600 px Höhe, wie `Baar.jpg`).

**Stolperstein Yoast beim Bildwechsel.** Wird an einem bestehenden
Beitrag nur das Beitragsbild getauscht, zeigt die Seite sofort das neue
Bild — das `og:image` im Kopf aber weiter das alte. Yoast hält es in
seiner Indexable-Tabelle und rechnet es erst beim Speichern des
Beitrags neu; `set_post_thumbnail()` allein löst das nicht aus. Geteilte
Links auf Facebook und WhatsApp zeigten sonst noch tagelang das alte
Bild. Deshalb im DB-Skript **erst `set_post_thumbnail()`, dann
`wp_update_post()`** — die Reihenfolge ist der ganze Trick. Der
Deploy prüft es mit dem Muster `Ba-GeringQWEB` (erwartet 0).

### 2m. Teamfotos: Mannschaft sitzt senkrecht mittig (10.09.2026)

Rückmeldung: «schaue immer dass die Mannschaft — ob Aktive oder
Junioren — immer zentral in der Mitte ist, momentan sind sie oft zu
weit unten positioniert.» Das stimmte, und die Ursache lag an zwei
Stellen.

**Im CSS** stand `.fc1m-photo img { object-position: center 35% }`. Der
Hero schneidet das Foto mit `object-fit: cover` auf ein sehr breites
Band; 35 % zeigt mehr vom oberen Bildrand und schiebt die Mannschaft
nach unten. Jetzt steht dort `center`. **50 % ist ausserdem der einzige
Wert, der unabhängig von der Fenstergrösse hält:** nur bei 50 % fällt
die Bildmitte immer auf die Kastenmitte, jeder andere Wert verschiebt
den Ausschnitt mit dem Seitenverhältnis des Fensters mit. Die frühere
Ausnahme für die 3. Mannschaft (65 %) ist damit weg.

**In den Bildern** sass die Mannschaft je nach Foto bei 58–64 % der
Bildhöhe statt bei 50 %. Gemessen an einem Kontaktbogen mit
10 %-Linien:

| Foto | Mannschaft vorher | oben weggeschnitten |
| --- | --- | --- |
| `FCS1_Web2627.jpg` | 49 % | — (war schon mittig) |
| `FCS_2_Web2627.jpg` | 52 % | — (war schon mittig) |
| `FCS3_Web2627.jpg` | 64 % | 28 % |
| `FrauenUri1_Web2627.jpg` | 58 % | 17 % |
| `Ba_Junioren_26-27.jpg` | 61 % | 22 % |
| `FF14_Team_26-27.jpg` | 63 % | 26 % |

Rechenweg: Liegt die Mannschaft zwischen den Anteilen `oben` und
`unten` der Bildhöhe, bringt das Wegschneiden von `(oben + unten) − 1`
am oberen Rand ihre Mitte auf 50 %. Nur oben schneiden, nie unten —
sonst fehlen die Füsse.

**Damit gilt für jedes neue Teamfoto:** vor dem Hochladen oben
beschneiden, bis die Mannschaft mittig sitzt. Das gehört ins Bild, nicht
ins CSS — sonst braucht jedes Team wieder seine eigene Ausnahme. Der
Hinweis steht auch im CSS-Kommentar.

Alle sechs Team-Heros wurden danach bei 1600 px Fensterbreite
gerendert und gegen eine eingezeichnete Mittellinie geprüft.

### 2n. Startseite zeigt nur noch einen Termin (10.09.2026)

Der Abschnitt «Termine & Spielbetrieb» führte bis zu vier kommende
Termine. Auf Wunsch der Redaktion steht dort jetzt nur noch der
**nächste**; alle weiteren erreicht man über «Weitere Termine» auf
`/events/`. Eine Zeile in `front-page.php`:
`fcs_get_events( true, 4 )` -> `fcs_get_events( true, 1 )`.

**Unterkanten bündig** (Nachtrag gleichentags): Die rechte Spalte ist
wegen ihres Kopfes «Spielbetrieb IFV» 7,2 px höher als die Terminkarte
links; mit dem bisherigen `align-items: start` endete die Karte
entsprechend über den IFV-Kacheln. Das Band steht jetzt auf
`align-items: stretch`, `.fcx-termine` ist eine Flex-Spalte und die
Karten tragen `flex: 1 1 auto` — bei einem Termin füllt er die Spalte
ganz, bei mehreren wachsen alle gleichmässig mit. Nachgemessen: Karte,
rechte Spalte und Kacheln enden alle bei 107,3 px. Unterhalb von 60rem
steht ohnehin alles untereinander, dort ändert `stretch` nichts.

**Hinweis fürs Nachprüfen mit Screenshots:** die Kacheln blenden über
einen `IntersectionObserver` ein (`.fcx-reveal` -> `.is-in`). Springt
man per Skript zum Abschnitt, feuert der Observer nicht zuverlässig und
die Karten bleiben unsichtbar — das sieht nach einem Layoutfehler aus,
ist aber keiner. Im Testaufbau vorher
`document.querySelectorAll('.fcx-reveal').forEach(e => e.classList.add('is-in'))`
ausführen.

### 2o. Stolperstein: Vorschaugrössen nach einem Bildtausch (10.09.2026)

**Was schiefging.** Der Deploy vom 09.09. ersetzte das Porträt von
Claudia Gisler unter demselben Dateinamen und liess die
Vorschaugrössen auf dem Server über
`wp_generate_attachment_metadata()` neu rechnen. Die Volldatei war
danach korrekt — **vier der acht Vorschaugrössen aber nicht**:
`-1024x1536`, `-300x300`, `-200x300` und `-150x150` zeigten weiter das
alte Foto. Richtig neu gerechnet wurden nur `-683x1024`, `-768x1152`,
`-85x128` und `-21x32`. Warum die Neuberechnung bei den vier nicht
griff, liess sich von aussen nicht klären.

**Warum das auffällt.** Die Vorstandsseite spielt ein `srcset` aus. Je
nach Bildschirmbreite und Pixeldichte wählt der Browser eine der
stehengebliebenen Grössen — ein Teil der Besucher sah also weiter das
alte Bild, während die Volldatei längst neu war.

**Warum ich es zuerst übersah.** Beim Nachprüfen hatte ich die
Volldatei und *eine* Vorschau (`-683x1024`) angeschaut, beide waren
korrekt, und daraus geschlossen, alles sei in Ordnung. Die Rückmeldung
«das frische Image wurde beim Deploy nicht mitgezogen» war richtig.

**Regel daraus:** Wird eine Bilddatei unter demselben Namen ersetzt,
die als Mediathek-Eintrag mit `srcset` ausgespielt wird, **die
Vorschaugrössen nicht auf dem Server rechnen lassen, sondern lokal
erzeugen und fertig hochladen.** `deploy-inhalte-1009.sh` überträgt
deshalb alle neun Claudia-Dateien und vergleicht danach jede einzeln
byteweise (`md5`) mit der lokalen Fassung — eine Abweichung fällt sofort
auf, statt monatelang unbemerkt zu bleiben.

**Nicht betroffen** sind Bilder, die die Vorlagen als einfaches
`<img src>` einbinden (Teamfotos wie `FCS3_Web2627.jpg`): dort gibt es
kein `srcset`, nur die Volldatei zählt. Ebenso wenig neue Dateien mit
neuem Namen — deren Vorschaugrössen entstehen ohnehin frisch.

### 2p. Team Uri FF17 komplett, Tabelle/Spielplan je Mannschaft (11.09.2026)

Zwei Aufträge: die FF17 hat jetzt Teamfoto und Betreuerporträts, und
die Kacheln «Tabelle» und «Spielplan» führen auf jeder Teamseite zum
jeweiligen Team im IFV-Matchcenter statt auf den Spielbetrieb des
ganzen Vereins. Deploy: `./deploy/deploy-inhalte-1109.sh`
(DB-Teil `deploy/fcs-inhalte-1109.php.tpl`), danach
`./scripts/deploy-theme.sh`. Lokal ist beides schon durchgespielt (DB
frisch von live gezogen, DB-Skript lokal gefahren, Seiten geprüft).

**Bilder** (alle in `2026/06`, nur lokal bis zum Deploy):

| Datei | Quelle in `~/Downloads` | Bearbeitung |
| --- | --- | --- |
| `FF17_Team_26-27.jpg` (2000×1243) | `ffu17 teamfoto .jpg` (4906×3242, ESC) | unten 5,9 % weg, Mannschaft von 47 % auf 50 % Bildhöhe (gemessen über den Hautton-Anteil je Zeile: vorher 6–88 %, jetzt 6,5–93 %). Ausnahmsweise unten statt oben beschnitten — dort war nur Asphalt, die Mannschaft stand zu hoch, nicht zu tief. Reicht trotzdem nicht: das Foto ist so eng, dass der breite Hero die Köpfe der hinteren Reihe anschnitt (Rückmeldung 11.09.). Deshalb steht auf dieser Seite das neue Feld **«Teamfoto: senkrechte Lage» auf 15** (erst 25, Rückmeldung «ganz wenig weiter runter») — die Vorlage setzt dann `object-position: center 15%` inline, nur für diese Seite; alle anderen bleiben bei der Mitte. Geprüft bei 1440×900 und 1920×1080: alle Köpfe mit Luft, dafür fehlen unten die Schuhe. |
| `Sam_Buerer_2627.jpg` (1201×1600) | `Betreuer FF17.JPG` | Team-Uri-Dress; ersetzt auf der FF17-Seite das ältere `sam_buerer_2.jpg` |
| `Noreen_Haefliger.jpg` (1201×1600) | `Betreuerin FF17.JPG` | bisher Silhouette |

Stolperstein bei den Porträts: die Kamera hat sie liegend gespeichert
(5328×4000) mit **EXIF-Orientierung 8**. `sips -Z` behält den Tag und
die liegenden Pixel; `sips -r 270` dreht die Pixel, lässt den Tag aber
stehen — Browser drehen dann doppelt. Funktioniert hat der Weg über BMP
(`sips -s format bmp -Z 1600`, dann zurück nach JPEG, Qualität 88): BMP
kennt keine Orientierung, sips brennt sie beim Formatwechsel ein.
Ergebnis: stehende Pixel, kein Orientierungs-Tag. PNG als Zwischenformat
taugt nicht, sips schreibt den Tag dort mit (eXIf-Chunk).

Nicht angefasst: `page-betreuer.php` (Betreuer-Übersicht der Junioren)
führt Sam Bürer weiter mit `sam_buerer_2.jpg` und der Rolle «Betreuer
Junioren Dd» — hartkodiert in der Vorlage, redaktionell zu klären.

**Tabelle/Spielplan je Team.** Das Matchcenter adressiert Teams über
`v` (Verein: FC Schattdorf 329, FC Altdorf 326) und `t` (Team).
Beides bleibt über die Saisons gleich — die 1. Mannschaft ist seit
mindestens 2022 `t=30614`. Der Spielplan (`a=pt`) trägt zusätzlich
`ls` (Liga-Saison) und `sg` (Gruppe), **und die wechseln jede Saison.**
Genau das war der stille Fehler: der Spielplan-Link der 1. Mannschaft
(`ls=24454&sg=67609`) gehört laut Webarchiv zur Saison 2025/26 (die
2. Liga 2026/27 heisst dort `ls=25894&sg=70458`), 2., 3. und Frauen
ebenso, die Senioren zeigten sogar noch auf die Gruppe von 2022/23.
Mit `ls=0&sg=0` wählt der Server die aktuelle Gruppe selbst — belegt
an Schnappschüssen von März 2023 und **März 2026** (ESC Erstfeld,
`t=30602&ls=0&sg=0&a=pt` rendert den laufenden Spielplan).

Neu baut `inc/fcs-ifv.php` alle Links: `fcs_ifv_tabelle_url( t, v )`
(`a=trr`, Resultate + Rangliste), `fcs_ifv_spielplan_url( t, v )`
(`a=pt` mit `ls=0&sg=0`), `fcs_ifv_verein_url()` (Rückfall).
Aktiv-Vorlagen, Startseite und Liveticker-Vorgabe rufen die Helfer mit
ihrer Team-Nummer auf; von Hand geschriebene Matchcenter-Links gibt es
im Theme nicht mehr (`grep matchcenter` findet nur noch den nackten
Link im Footer und den Helfer).

Die Juniorenseiten bekommen das Seitenfeld **«IFV-Teams»** (`jt_ifv`,
eine Zeile pro Team: `Kürzel | Team-Nummer | Vereinsnummer | ohne
Tabelle`; Vereinsnummer darf fehlen = 329, Altdorf 326, Erstfeld 327;
die Spalten ab der dritten sind in beliebiger Reihenfolge erlaubt —
eine Zahl ist die Vereinsnummer, ein Text mit «Tabelle» schaltet die
Tabellen-Kachel ab). **Alle E- und F-Teams sowie FF11 stehen auf «ohne
Tabelle»** (Wunsch vom 11.09.: im Kinderfussball braucht es keine
Rangliste), sie zeigen nur «Spielplan». Seiten mit mehreren Teams
(Ea/Eb, Ed/Ee, Fa/Fb/Fc) zeigen je Team seine Kacheln mit Kürzel
(«Spielplan Ea», «Spielplan Eb») — das Raster (`auto-fit,
minmax(15rem)`) bricht von selbst um, auf dem Telefon zwei Spalten.
**Eine einzelne Kachel** (Ec, Fd, FF11) lief über die ganze Breite —
Rückmeldung «soll nicht extra länger gemacht werden». Die Vorlage
hängt dann `fc1m-ifv__grid--einzeln` an: zwei feste Spalten, die
Kachel ist so breit wie eine von zweien; unter 536 px Fensterbreite
eine Spalte — exakt dort, wo `auto-fit` zwei Kacheln untereinander
setzt (2 × 15rem + 1rem Abstand + 2 × 1.25rem Rand). Geprüft bei 540
(halbe Breite) und 500 px (volle Breite, wie ein Paar dort). Ohne
Eintrag greifen die freien Link-Felder «Tabelle»/«Spielplan», ganz ohne
Angaben die IFV-Vereinsseite.

**Kacheln auf dem Telefon kompakter** (Rückmeldung 11.09.: «auf
responsiv design zu gross»). Unter 600 px in `fcs-1mannschaft.css`:
Band 1rem statt clamp(1.5rem…) hoch, Kachel-Innenabstand .625rem /
.875rem statt 1rem / 1.25rem, Titel 1rem statt 1.375rem, Untertitel
.6875rem, Pfeil 11 px, Abstand .625rem. Gilt für alle Teamseiten,
Aktive wie Junioren (gleiches Stylesheet). Geprüft bei 500 px auf Da
(zwei Kacheln), Fa/Fb/Fc (drei) und Ec (eine).

**Woher die Nummern stammen — und was zu prüfen ist.** ifv.ch,
matchcenter.ifv.ch und football.ch sperren maschinelle Zugriffe
(Cloudflare, «Block Bot Score 1», auch für Headless-Chrome). Die
Nummern kommen aus dem Webarchiv: Matchcenter-Vereinsseite `v=329`
vom **21.10.2025** (Saison 2025/26). Die Zuordnung der Buchstaben zu
den Nummern setzt voraus, dass der Verein für 2026/27 die
Team-Einträge in clubcorner beibehalten und nur Fe/Ff, Df und Ef
gelöscht hat (so liest sich die Teammeldung in Abschnitt 2a). Das ist
plausibel, aber nicht belegt — **nach dem Theme-Deploy jede
Tabellen-Kachel einmal anklicken** und prüfen, ob das Matchcenter das
richtige Team nennt:

| Seite | Feld «IFV-Teams» | Name im Matchcenter 2025/26 |
| --- | --- | --- |
| Aa | `Aa \| 30617` | Youth League A |
| Ba | `Ba \| 42180` | Junioren B 1. Stärkeklasse a |
| Bb | `Bb \| 30618` | Junioren B 3. Stärkeklasse b |
| Ca | `Ca \| 30619` | Junioren C 1. Stärkeklasse a |
| Cb | `Cb \| 30620` | Junioren C 3. Stärkeklasse b |
| Da | `Da \| 30622` | Junioren D-9 a |
| Db | `Db \| 30623` | Junioren D-9 b |
| Dc | `Dc \| 50554` | Junioren D-9 c |
| Dd | `Dd \| 58109` | Junioren D-9 d |
| De | `De \| 76734` | Junioren D-7 e (D-7 f = 76735 ist aufgelöst) |
| Ea/Eb | `Ea \| 30625 \| ohne Tabelle`, `Eb \| 30626 \| ohne Tabelle` | Junioren E a, E b |
| Ec | `Ec \| 47203 \| ohne Tabelle` | Junioren E c |
| Ed/Ee | `Ed \| 52702 \| ohne Tabelle`, `Ee \| 54128 \| ohne Tabelle` | Junioren E d, E e (E f = 57684 aufgelöst) |
| Fa/Fb/Fc | `Fa \| 71266 \| ohne Tabelle`, `Fb \| 46556 \| ohne Tabelle`, `Fc \| 50565 \| ohne Tabelle` | Junioren F a, F b, F c |
| Fd | `Fd \| 48899 \| ohne Tabelle` | Junioren F d (F e = 52705, F f = 53419 aufgelöst) |
| FF11 | `FF11 \| 76737 \| ohne Tabelle` | Juniorinnen E / FF-11, Mädchen Team Uri FF-11 — beim FC Schattdorf gemeldet |
| FF14 | `FF14 \| 79188 \| 326` | beim FC Altdorf; Nummer von der Redaktion am 11.09. geliefert, nicht aus dem Archiv |
| FF17 | `FF17 \| 78478 \| 327` | beim ESC Erstfeld; Nummer von der Redaktion am 11.09. geliefert, nicht aus dem Archiv |

Stimmt ein Team nicht, im Live-Admin auf der Seite unter
«Seiteninhalte» die Nummer korrigieren — kein Deploy nötig. Die
Nummer steht in der Matchcenter-Adresse des Teams (`t=…`): Matchcenter
→ Verein → FC Schattdorf → Team anklicken.

**FF14 und FF17: Nummern von der Redaktion.** Beide Teams sind neu in
2026/27 und im Archiv nicht zu finden (der ESC-Schnappschuss vom März
2026 kennt noch keine FF17). Die Redaktion hat die Matchcenter-Links
am 11.09. nachgereicht: FF14 beim FC Altdorf (`v=326`, `t=79188`),
FF17 beim ESC Erstfeld (`v=327`, `t=78478`). Beide zeigen Tabelle und
Spielplan. Die zwischenzeitlich gesetzten freien Link-Felder auf die
Vereinsseiten leert das DB-Skript wieder (live waren sie nie gesetzt).
Für künftige neue Teams gilt derselbe Weg: Matchcenter → Verein → Team
anklicken, `t=…` aus der Adresse ins Feld «IFV-Teams» eintragen, bei
fremdem Verein mit dessen `v=…` als dritter Spalte. Kein Deploy nötig.

Nicht klärbar ohne Zugriff, gehört zur Prüfliste: ob `ls=0&sg=0` bei
einem Team, das gerade zwischen zwei Runden steht, die richtige Runde
wählt (2023 zeigte es die aktuelle Frühjahrsrunde). Die Frage nach
Tabellen im Kinderfussball hat sich erledigt — E und F zeigen
bewusst keine.

**Lokale Prüfung (11.09.2026):** Aa–De und FF14 je zwei Kacheln mit
`t=…&a=trr` und `t=…&ls=0&sg=0&a=pt`; Ea/Eb zwei, Fa/Fb/Fc drei, Ec,
Fd und FF11 je eine halbbreite Spielplan-Kachel, nirgends «Tabelle
E…/F…»; FF17 auf `t=78478` (v=327), FF14 auf `t=79188` (v=326);
1. Mannschaft, Startseite und Liveticker
ohne `ls=24454`; Senioren ohne `ls=19998`; Frauen mit `v=326`.
Screenshots bei 1440×900, 1920×1080 und 500 px: FF17-Hero mit allen
Köpfen, Betreuerstab mit beiden Porträts, Kachelraster sauber.
Beachten: `esc_url()` schreibt das `&` als `&#038;` — Prüfmuster mit
`&amp;` finden nichts, das Deploy-Skript nutzt deshalb `&#038;`.

### 2q. Startseite: Claim-Band auf dem Telefon kompakter (11.09.2026)

Rückmeldung: über «Seit 1933 für unsere Zukunft am Ball» stand im
schmalen Layout zu viel leeres rot-schwarzes Muster. Ursache: das Band
hatte eine feste Höhe `clamp(20rem, 42vh, 26rem)` und der Text sass
absolut am unteren Rand — auf einem 390-px-Telefon rund 290 px Band bei
etwa 100 px Text. Neu unter 600 px (`fcs-front.css`, Abschnitt
CLAIM-BAND): `height:auto`, Innenabstand `3rem` oben und `1.75rem`
unten, der Textblock ist `position:static`. Das Band misst jetzt 176 px
bei 390 px Breite. Desktop unverändert (die Regel liegt in einer
`max-width:600px`-Abfrage; `fcs-front.css` lädt auf der Startseite
nach `fcs-home.css` und gewinnt damit).

**Claudia Gisler: Porträt unter neuem Dateinamen** (Teil D des
DB-Skripts, Rückmeldung 11.09.: «claudia und claudia neu sind nicht
identisch»). Das neue Foto mit der neuen Brille (`Claudia_Web_neu.jpg`,
1280×1920) lag seit dem 10.09. byteweise korrekt live — aber unter dem
**alten Dateinamen** `Claudia_Gisler.jpg`. Browser, die die
Vorstandsseite schon kannten, und der Hostpoint-Cache lieferten
darum weiter das alte Bild; ein Byte-Vergleich auf dem Server zeigt
das nicht. Lehre: **ein Bildtausch braucht einen neuen Dateinamen.**
Neu heisst die Datei `Claudia_Gisler_2026.jpg`; die acht
Vorschaugrössen sind lokal gerechnet (`wp_generate_attachment_metadata`
im Container) und werden mitgeliefert und byteweise geprüft — der
Server rechnet nichts. Das DB-Skript hängt Mediathek-Eintrag #218 auf
die neue Datei um (Dateipfad, Metadaten, GUID), entfernt das
Smush-Backup, das noch auf den alten Namen zeigte, und ersetzt die
Bild-URL im Block der Vorstandsseite #35 (dort steht `src` fest im
Inhalt, nur das srcset kommt aus den Metadaten). Die alten Dateien
bleiben liegen, nichts verweist mehr darauf. Lokal geprüft: Seite
zeigt nur noch den neuen Namen, alle sieben srcset-Dateien HTTP 200.

**Werkzeug dazu — `scripts/screenshot-element.mjs`.** Mit Chrome
`--screenshot` sieht man auf der Startseite nur den Hero (100svh, füllt
jeden Viewport, auch 9000 px hohe). Das Skript steuert Chrome per
DevTools-Protokoll, setzt die Viewport-Breite nach dem Laden und
fotografiert den Bereich um einen CSS-Selektor:
`node scripts/screenshot-element.mjs http://localhost:8080/ .fcsh-parallax 390 /tmp/claim.png 120`.
Zwei Stolpersteine sind darin schon umschifft: die Metrik-Vorgabe vor
der Navigation bleibt wirkungslos (innerWidth 1), und wer den Viewport
auf Seitenhöhe vergrössert, um «alles» zu sehen, bekommt wieder nur
den Hero — er wächst mit.

### 2r. Responsive: Claim-Text über dem Muster, Teamfoto ganz (12.09.2026)

Zwei Rückmeldungen zum Telefon-Layout, beides nur CSS, beides noch
nicht live (Theme-Deploy steht aus, siehe Abschnitt 2).

**Claim-Band «Seit 1933 …»:** «die schwarze Linie ist über seit 1933».
Ursache war mein Umbau vom 11.09. (Abschnitt 2q): der Textblock stand
auf `position:static`, damit verliert `z-index:1` seine Wirkung und das
Streifenmuster aus `.fcsh-parallax::before` legte sich über die Schrift.
Jetzt `position:relative` — z-index greift wieder, Text liegt oben.
Geprüft bei 390 px.

**Teamfoto auf den Teamseiten:** «sehr klein — kann man das nicht
besser lösen?». Bis 40rem war das Titelbild eine 300 px hohe Box
(`min-height`), die vom querformatigen Foto links und rechts fast ein
Fünftel abschnitt; dazu lagen Titel und «Team wechseln» mit ihrem
Verlauf über der unteren Hälfte — vom Foto blieb wenig. Neu unter 40rem
(`fcs-1mannschaft.css`, Block «Telefon»): das Foto behält sein eigenes
Seitenverhältnis (`aspect-ratio:auto`, kein `min-height`) und bleibt
unverdeckt, der Titelbalken steht als dunkler Block darunter
(`position:static`, Hintergrund `--dark`). Das Bild ist damit in der
Höhe etwas kleiner (FF17: 242 statt 300 px bei 390 px Breite), zeigt
aber die ganze Mannschaft ohne Überlagerung. 40rem ist dieselbe Grenze,
ab der der Team-Umschalter nach unten aufklappt. Gilt für alle
Teamseiten (Aktive und Junioren, gleiches Stylesheet). Das Feld
«senkrechte Lage» (FF17: 15) wirkt nur noch auf dem Desktop, wo das
Foto beschnitten wird.

**«Team wechseln» auf dem Telefon:** Rückmeldung «weniger lang, sieht
künstlich vergrössert aus». Der Knopf lief bis 40rem über die volle
Breite (`width:100%`, Pfeil rechts aussen). Neu behält er seine
natürliche Breite, steht als eigene Zeile unter dem Titel
(`.fcjt-herobar` als Spalte), ist etwas kleiner (.6875rem, Innenabstand
.6rem/1rem) und ohne Glas-Effekt — er liegt jetzt auf dem dunklen
Balken, nicht mehr auf dem Foto. Das aufklappende Feld bleibt so breit
wie der Balken (`calc(100vw - 2.5rem)`), denn es hängt am Knopf und
würde sonst mit ihm schrumpfen. Datei `fcs-junioren-team.css`, Block
`@media (max-width: 40rem)`.

**Stolperstein CSS-Reihenfolge:** die Telefon-Regel stand zuerst VOR
der Grundregel `.fc1m-herobar{position:absolute}` — gleiche
Spezifität, die spätere Grundregel gewann, die Media-Query blieb
wirkungslos. Der Block steht jetzt hinter den Herobar-Regeln, mit
Kommentar. Gemessen per DevTools-Protokoll bei 390 px: Foto 242 px,
Titelbalken 123 px direkt darunter, 1. Mannschaft 260 + 62 px.

**Zu `scripts/screenshot-element.mjs`:** das Aufnehmen jenseits des
Viewports hängt seit dem 12.09. auf diesem Rechner reproduzierbar
(Chrome antwortet auf `Page.captureScreenshot` nicht mehr, auch nach
Neustart der Prozesse). Die Messwerte (`computed:`-Zeile) kommen
weiterhin zuverlässig — dafür taugt das Skript auf jeden Fall. Für
Bilder oberhalb der Falz reicht Chrome `--screenshot` mit
`--window-size=500,…` (unter 500 px Breite legt Chrome die Seite
trotzdem breiter aus).

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
