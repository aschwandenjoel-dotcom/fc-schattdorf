# Umstellung — A7: Inhalte gegenlesen

Stand: **05.09.2026**, Befund aus allen 65 Seiten der Live-Sitemap
(`fcschattdorf.dynalias.net`). Arbeitsliste für die Redaktion; was erledigt
ist, hier abhaken. Gehört zu `UMSTELLUNG.md`, Schritt A7.

## Befund in Kürze

| Prüfpunkt | Ergebnis |
|---|---|
| Nennung von cyon / Joomla / UBIQ / Hostpoint | keine — nichts zu ändern |
| Links auf die alte Seite `www.fcschattdorf.ch/…` | nur der Trainingslager-Anmeldelink (A6, erledigt) |
| PDFs/Dokumente (11 Links: Juniorenkonzept, Sponsoringkonzept, Grümpi-Spielpläne, Helferportal, Flyer Fussballschule) | alle erreichbar (HTTP 200), liegen in `wp-content/uploads/2026/06/` — kommen mit |
| `noindex`/Robots | nirgends gesetzt — gut |
| Yoast-Titel | überall gesetzt («Seite - FC Schattdorf») |
| **Meta-Description** | **fehlt auf 64 von 65 Seiten** (nur `/junioren/teams/` hat eine) |
| **OG-Bild** (Vorschaubild bei Facebook/WhatsApp) | fehlt auf ~40 Seiten (alle Verein-/Junioren-Unterseiten, Teams, Kontakt, Sponsoren) |
| Datenschutzerklärung | «Stand: September 2023» — von der alten Seite übernommen; nennt weder Hoster noch die externen Dienste der neuen Seite |
| Impressum | in Ordnung (Stand August 2026) |
| Externe Dienste, die beim Seitenaufruf geladen werden | Google Fonts (Inter) und AOS-Bibliothek von `unpkg.com` — beide auf jeder Seite; Facebook/Instagram/IFV/Tickaroo sind nur Links |
| Veraltete Inhalte | siehe Abschnitt 4 |

## 1. Meta-Descriptions (Yoast, pro Seite: «SEO → Meta-Beschreibung»)

Ziel ≤ 155 Zeichen. Vorschläge, aus dem jeweiligen Seiteninhalt abgeleitet —
gern umformulieren, wichtig ist, dass etwas drinsteht. Ohne Description
zeigt Google beliebige Textfetzen.

| Seite | Vorschlag |
|---|---|
| `/` | Der FC Schattdorf – Fussball im Kanton Uri seit 1933: Aktive, Junioren, Frauen- und Seniorenteams, Termine, News, Sponsoren und Fanshop. |
| `/verein/` | Der FC Schattdorf als Verein: Vorstand, Mitgliedschaft, Fanshop, Schiedsrichter, Ehrenmitglieder, Vereinsgeschichte und die Sportanlagen Grüner Wald. |
| `/verein/vorstand/` | Der Vorstand des FC Schattdorf: Präsident, Vizepräsident, Finanzen, Administration, Wettspielbetrieb und weitere Ressorts mit Kontaktangaben. |
| `/verein/mitglied-werden/` | Mitglied werden beim FC Schattdorf: Aktivfussball, Junioren A–C, Kinderfussball und Fussballschule – Ansprechpersonen und Kontakt für deine Anmeldung. |
| `/verein/fanshop/` | Fanshop des FC Schattdorf: Caps, Beanies, Schals und weitere Fanartikel online bestellen oder im Clubhaus kaufen. Zahlung auf Rechnung. |
| `/verein/schiedsrichter/` | Die lizenzierten Schiedsrichter des FC Schattdorf und die Spielleiter im Kinderfussball. Interesse an der Schiedsrichter-Ausbildung? Melde dich. |
| `/verein/ehrenmitglieder/` | Ehrenpräsident, Ehrenmitglieder und Freimitglieder des FC Schattdorf – die Liste der Geehrten seit 1926. |
| `/verein/vereinsgeschichte/` | 110 Jahre FC Schattdorf: die Vereinsgeschichte von der ersten Gründung 1916 bis heute – Meilensteine, Aufstiege und drei IFV-Cupsiege. |
| `/verein/anfahrt/` | So finden Sie den FC Schattdorf: Hauptplatz Grüner Wald und Nebenplatz Grundmatte in 6467 Schattdorf UR – Adressen, Anlagen und Garderoben. |
| `/verein/vorfall-melden/` | Vorfall oder Verdacht melden: Anlaufstellen des FC Schattdorf und von Swiss Sport Integrity für Ethikvorfälle – vertraulich, auf Wunsch anonym. |
| `/helfereinsaetze/` | Helfereinsätze beim FC Schattdorf: Registrierung im Helferportal und Anmeldung für Clubhaus, Grillstand und weitere Einsätze – mit Anleitung als PDF. |
| `/aktive/` | Die Aktivteams des FC Schattdorf: 1., 2. und 3. Mannschaft, Frauen Team Uri I und II sowie Senioren Team Uri I – Kader, Staff, Tabellen, Spielpläne. |
| `/aktive/1-mannschaft/` | 1. Mannschaft des FC Schattdorf: Kader, Betreuerstab und Spielersponsoren sowie Tabelle und Spielplan beim IFV. |
| `/aktive/2-mannschaft/` | 2. Mannschaft des FC Schattdorf: Betreuerstab und Team-Sponsoren sowie Tabelle und Spielplan beim IFV. |
| `/aktive/3-mannschaft/` | 3. Mannschaft des FC Schattdorf: Betreuerstab und Team-Sponsoren sowie Tabelle und Spielplan beim IFV. |
| `/aktive/frauen-uri-1/` | Frauen Team Uri I – das Frauenteam des FC Schattdorf: Betreuerstab, Team-Sponsoren, Tabelle und Spielplan beim IFV. |
| `/aktive/frauen-uri-2/` | Frauen Team Uri II des FC Schattdorf: Betreuerstab, Team-Sponsoren, Tabelle und Spielplan beim IFV. |
| `/aktive/senioren-uri-1/` | Senioren Team Uri I des FC Schattdorf: Betreuerstab, Team-Sponsoren, Tabelle und Spielplan beim IFV. |
| `/junioren/` | Die Juniorenabteilung des FC Schattdorf: Fussball für Kinder und Jugendliche von den F- bis zu den A-Junioren und dem Team Uri FF11 – Teams, Leitung, Angebote. |
| `/junioren/juniorengeschichte/` | Geschichte der Juniorenabteilung des FC Schattdorf – von den Anfängen 1937 auf dem Loomehlplatz bis heute. |
| `/junioren/junioren-organisation/` | Organisation der Juniorenabteilung des FC Schattdorf: Juniorenobmann, Leitung Kinderfussball, J+S-Coach, Material und Kommunikation – mit Kontakt. |
| `/junioren/goalietraining/` | Goalietraining beim FC Schattdorf: Trainingszeiten für die Junioren D/E und A–C auf dem Hauptplatz Grüner Wald und das Trainerteam. |
| `/junioren/fussballschule/` | Fussballschule des FC Schattdorf für die jüngsten Kinder: montags auf dem Sportplatz Grüner Wald – Jahrgänge, Zeiten, Leitungsteam und Flyer. |
| `/junioren/trainingslager/` | Das Junioren-Trainingslager des FC Schattdorf: fünf Tage Fussball, zwei Trainings täglich, Campus mit Freibad – Impressionen und Infos zur nächsten Ausgabe. |
| `/junioren/betreuer-werden/` | Betreuer werden beim FC Schattdorf: Wir suchen Trainerinnen und Trainer für die Juniorenteams und begleiten dich bis zur Trainerlizenz – Ausbildungsweg und Kontakt. |
| `/junioren/juniorenkonzept/` | Das Juniorenkonzept des FC Schattdorf: Leitfaden und Philosophie für Trainer, Funktionäre, Kinder und Eltern – als PDF zum Herunterladen. |
| `/junioren/tauschboerse/` | Fussball-Tauschbörse des FC Schattdorf: Schuhe, Trikots und Ausrüstung per WhatsApp mit anderen Vereinsmitgliedern tauschen oder verkaufen. |
| `/junioren/teams/junioren-…/` (17 Teamseiten) | Muster: «D-Junioren Da des FC Schattdorf: Betreuerstab, Team-Sponsoren sowie Tabelle und Spielplan beim IFV.» |
| `/junioren/teams/team-uri-ff11/` | Team Uri FF11 – die Juniorinnen des FC Schattdorf: Betreuerstab, Team-Sponsoren, Tabelle und Spielplan beim IFV. |
| `/events/` | Events und Veranstaltungen des FC Schattdorf: Generalversammlung, Turniere und Anlässe – alle Termine auf einen Blick. |
| `/gruempelturnier/` | Dorf- und Grümpelturnier des FC Schattdorf auf dem Sportplatz Grüner Wald: Programm, Kategorien, Spielpläne, Reglement und Anmeldung. |
| `/sponsoren/` | Die Sponsoren des FC Schattdorf: Hauptsponsor, Nachwuchs-Patronat, Co-, Club- und Nachwuchs-Sponsoren – und das Sponsoringkonzept zum Download. |
| `/sponsoren/top-club-88/` | Top-Club 88 – der Sponsorenclub des FC Schattdorf: Ziele, Leistungen für Mitglieder und wie du dabei bist. |
| `/kontakt/` | Kontakt zum FC Schattdorf, 6467 Schattdorf UR: Kontaktformular und E-Mail an kommunikation@fcschattdorf.ch. |
| `/news/` | News des FC Schattdorf: Spielberichte, Turniere und Neuigkeiten aus dem Verein. |
| `/impressum/` | Impressum des FC Schattdorf: Kontaktadresse, Haftungsausschluss und Urheberrechte. |
| `/datenschutzerklaerung/` | Datenschutzerklärung des FC Schattdorf: welche Personendaten wir bearbeiten, wozu, und wie wir sie schützen. |

News-Beiträge: Yoast nimmt automatisch den Textanfang, dort ist nichts nötig.

## 2. OG-Bild (Vorschaubild beim Teilen)

Ein einziger Eingriff deckt alle ~40 Seiten ohne eigenes Bild ab:
**Yoast SEO → Einstellungen → Website-Grundlagen → Standard-Bild für Social
Media** (1200 × 630 px, z. B. Logo auf Vereinsrot oder ein Stadionfoto vom
Grünen Wald). Seiten mit Beitragsbild behalten ihr eigenes.

## 3. Datenschutzerklärung — Ergänzungen (Entwurf)

Die heutige Fassung stammt von der alten Seite («Stand: September 2023»)
und nennt weder Hoster noch die Dienste, die die neue Seite tatsächlich
nutzt. Vorschlag: bestehende Abschnitte lassen, folgende ergänzen bzw.
ersetzen und «Stand» auf September 2026 setzen. Rechtliche Endprüfung
durch den Verein.

**Hosting** (neu)
> Diese Website wird bei der Hostpoint AG, Rapperswil-Jona (Schweiz),
> betrieben. Beim Aufruf werden Server-Logdateien mit IP-Adresse,
> Browsertyp, Betriebssystem, Zugriffszeit und aufgerufener Seite erstellt.
> Wir und der Hoster verwenden diese Daten ausschliesslich für den sicheren
> und zuverlässigen Betrieb der Website.

**E-Mail und Formulare** (neu)
> Unsere E-Mail-Postfächer und der Versand von Formular-Mails laufen über
> die cyon GmbH, Basel. Angaben aus dem Kontaktformular und aus
> Fanshop-Bestellungen werden auf unserem Webserver gespeichert und per
> E-Mail an die zuständige Stelle im Verein übermittelt; wir verwenden sie
> nur zur Bearbeitung Ihrer Anfrage oder Bestellung. Der Warenkorb des Fanshops wird lokal in Ihrem Browser gespeichert (Web Storage) und nicht an uns übermittelt, bis Sie eine Bestellung absenden.

**Schriften und Skripte von Drittanbietern** (neu — entfällt, wenn wir
Google Fonts und AOS ins Theme legen, siehe unten)
> Zur Darstellung der Schriften wird die Schriftart Inter von Google Fonts
> (Google LLC, USA) geladen; für Animationen die Bibliothek AOS über das
> Content Delivery Network unpkg.com (Cloudflare, Inc., USA). Beim Laden
> wird Ihre IP-Adresse an diese Anbieter übermittelt.

**Links zu Drittanbietern** (neu)
> Wir verlinken auf Facebook, Instagram, das IFV-Matchcenter und den
> Liveticker von Tickaroo. Beim Anklicken gelten die Datenschutzbestimmungen
> des jeweiligen Anbieters; auf unserer Website selbst werden keine Inhalte
> dieser Dienste eingebunden.

**Cookies** (ersetzen)
> Wir setzen nur technisch notwendige Cookies (z. B. bei der Anmeldung im
> Verwaltungsbereich). Es gibt kein Tracking und keine Analyse-Cookies.

**Newsletter** (prüfen): Die neue Website hat keine Newsletter-Anmeldung.
Wird der Vereins-Newsletter weiterhin versendet (DNS-Zone: Mailgun über
`m.fcschattdorf.ch`), bleibt der Abschnitt und nennt das Versandwerkzeug;
sonst streichen.

**Empfehlung dazu:** Google Fonts (Inter) und AOS ins Child-Theme legen
statt extern zu laden — dann entfällt der Drittanbieter-Abschnitt, die
Seite lädt schneller und ist unabhängig von unpkg.com. Kleiner
Theme-Eingriff, kann auf dem Branch `umstellung` mitgehen.

## 4. Veraltete Inhalte (Redaktion, unabhängig vom Domainwechsel)

- [ ] `/events/`: «Upcoming Events» zeigt die 93. Generalversammlung vom
      21.08.2026 — ist vorbei. Nächste Termine erfassen oder Event beenden.
- [ ] Startseite: «Zurzeit sind keine Termine erfasst.» — Herbst-Termine
      (Spiele, Anlässe) eintragen.
- [ ] `/junioren/`: «Teams Saison 2025/26» → 2026/27; Teamliste mit dem
      Juniorenobmann abgleichen (auch Basis für die Redirect-Tabelle).
- [ ] `/junioren/fussballschule/`: «Ab dem 16. März 2026», Jahrgänge
      2019/2020 — Angaben für den nächsten Start nachführen.
- [ ] `/junioren/trainingslager/`: Hero zeigt «20 – 24 Juli 2026 · Zuchwil»
      (Seitenfelder `tl_daten`, `tl_ort`); als Rückblick lassen oder auf
      «Sommer 2027 · Infos folgen» stellen.
- [ ] `/gruempelturnier/`: Ausgabe 2026 als Rückblick in Ordnung; vor der
      Anmeldephase 2027 Spielpläne/Reglement ersetzen.
- [ ] `/verein/` und `/aktive/`: reine Verteilerseiten ohne Text — für
      Google eine Einleitung von 2–3 Sätzen ergänzen (Seitenfeld oder
      Vorlage), sonst stehen sie leer im Index.
- [ ] `/kontakt/`: nur Adresse und E-Mail — Öffnungszeiten Clubhaus oder
      Telefon ergänzen, falls gewünscht.
