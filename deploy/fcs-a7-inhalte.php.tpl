<?php
/**
 * Einmal-Skript: Inhalte für den Domainwechsel nachziehen
 * (UMSTELLUNG.md Schritt A7, Details in UMSTELLUNG-A7-INHALTE.md).
 *
 * Hintergrund: Auf Hostpoint ist MySQL von der SSH-Shell aus nicht
 * erreichbar — nur Web-Prozesse dürfen zur DB. Dieses Skript wird
 * daher kurzzeitig in den Webroot gelegt, per HTTPS mit Token
 * aufgerufen und danach gelöscht (löscht sich zusätzlich selbst).
 *
 * Es macht drei Dinge:
 *   A) Meta-Descriptions (Yoast, _yoast_wpseo_metadesc) für alle Seiten
 *      ohne Description setzen — vorhandene Werte werden NIE überschrieben.
 *      Teamseiten unter /junioren/teams/ bekommen ein Muster mit dem
 *      Teamnamen aus dem Seitentitel.
 *   B) Yoast-Standardbild für Social Media (og_default_image) auf das
 *      Startseiten-Foto setzen, falls noch keines gesetzt ist. Wirkt nur
 *      auf Seiten ohne eigenes Beitragsbild.
 *   C) Datenschutzerklärung ergänzen: Hoster (Hostpoint), E-Mail/Formulare
 *      (cyon, Warenkorb im Browser), Links zu Drittanbietern, Cookies-Text
 *      und «Stand». Schreibt nur, wenn der Seiteninhalt noch die erwarteten
 *      Textstellen der Fassung von 2023 enthält — wurde die Seite inzwischen
 *      im Admin geändert, meldet das Skript das und rührt sie nicht an
 *      (&force=1 übergeht das). wp_update_post legt eine Revision an, der
 *      alte Text bleibt im Admin unter «Revisionen» abrufbar.
 *
 * Idempotent: schon Erledigtes meldet «SKIP».
 * Probelauf ohne Schreiben:  ?token=…&dry=1
 */
if ( ! isset( $_GET['token'] ) || ! hash_equals( '__TOKEN__', (string) $_GET['token'] ) ) {
	http_response_code( 403 ); exit( 'forbidden' );
}

require __DIR__ . '/wp-load.php';

header( 'Content-Type: text/plain; charset=utf-8' );
set_time_limit( 120 );

$dry   = ! empty( $_GET['dry'] );
$force = ! empty( $_GET['force'] );
echo $dry ? "MODUS: Probelauf (es wird nichts geschrieben)\n\n" : "MODUS: Schreiben\n\n";

/* ── A) Meta-Descriptions ───────────────────────────────────────── */
echo "A) Meta-Descriptions (nur wo leer)\n";

$descs = array(
	''                                 => 'Der FC Schattdorf – Fussball im Kanton Uri seit 1933: Aktive, Junioren, Frauen- und Seniorenteams, Termine, News, Sponsoren und Fanshop.',
	'verein'                           => 'Der FC Schattdorf als Verein: Vorstand, Mitgliedschaft, Fanshop, Schiedsrichter, Ehrenmitglieder, Vereinsgeschichte und die Sportanlagen Grüner Wald.',
	'verein/vorstand'                  => 'Der Vorstand des FC Schattdorf: Präsident, Vizepräsident, Finanzen, Administration, Wettspielbetrieb und weitere Ressorts mit Kontaktangaben.',
	'verein/mitglied-werden'           => 'Mitglied werden beim FC Schattdorf: Aktivfussball, Junioren A–C, Kinderfussball und Fussballschule – Ansprechpersonen und Kontakt für deine Anmeldung.',
	'verein/fanshop'                   => 'Fanshop des FC Schattdorf: Caps, Beanies, Schals und weitere Fanartikel online bestellen oder im Clubhaus kaufen. Zahlung auf Rechnung.',
	'verein/schiedsrichter'            => 'Die lizenzierten Schiedsrichter des FC Schattdorf und die Spielleiter im Kinderfussball. Interesse an der Schiedsrichter-Ausbildung? Melde dich.',
	'verein/ehrenmitglieder'           => 'Ehrenpräsident, Ehrenmitglieder und Freimitglieder des FC Schattdorf – die Liste der Geehrten seit 1926.',
	'verein/vereinsgeschichte'         => '%%fcs_vereinsjahre%% Jahre FC Schattdorf: die Vereinsgeschichte von der Gründung %%fcs_gruendungsjahr%% bis heute – Meilensteine, Aufstiege und drei IFV-Cupsiege.',
	'verein/anfahrt'                   => 'So finden Sie den FC Schattdorf: Hauptplatz Grüner Wald und Nebenplatz Grundmatte in 6467 Schattdorf UR – Adressen, Anlagen und Garderoben.',
	'verein/vorfall-melden'            => 'Vorfall oder Verdacht melden: Anlaufstellen des FC Schattdorf und von Swiss Sport Integrity für Ethikvorfälle – vertraulich, auf Wunsch anonym.',
	'helfereinsaetze'                  => 'Helfereinsätze beim FC Schattdorf: Registrierung im Helferportal und Anmeldung für Clubhaus, Grillstand und weitere Einsätze – mit Anleitung als PDF.',
	'aktive'                           => 'Die Aktivteams des FC Schattdorf: 1., 2. und 3. Mannschaft, Frauen Team Uri I und II sowie Senioren Team Uri I – Kader, Staff, Tabellen, Spielpläne.',
	'aktive/1-mannschaft'              => '1. Mannschaft des FC Schattdorf: Kader, Betreuerstab und Spielersponsoren sowie Tabelle und Spielplan beim IFV.',
	'aktive/2-mannschaft'              => '2. Mannschaft des FC Schattdorf: Betreuerstab und Team-Sponsoren sowie Tabelle und Spielplan beim IFV.',
	'aktive/3-mannschaft'              => '3. Mannschaft des FC Schattdorf: Betreuerstab und Team-Sponsoren sowie Tabelle und Spielplan beim IFV.',
	'aktive/frauen-uri-1'              => 'Frauen Team Uri I – das Frauenteam des FC Schattdorf: Betreuerstab, Team-Sponsoren, Tabelle und Spielplan beim IFV.',
	'aktive/frauen-uri-2'              => 'Frauen Team Uri II des FC Schattdorf: Betreuerstab, Team-Sponsoren, Tabelle und Spielplan beim IFV.',
	'aktive/senioren-uri-1'            => 'Senioren Team Uri I des FC Schattdorf: Betreuerstab, Team-Sponsoren, Tabelle und Spielplan beim IFV.',
	'junioren'                         => 'Die Juniorenabteilung des FC Schattdorf: Fussball für Kinder und Jugendliche von den F- bis zu den A-Junioren und dem Team Uri FF11.',
	'junioren/juniorengeschichte'      => 'Geschichte der Juniorenabteilung des FC Schattdorf – von den Anfängen 1937 auf dem Loomehlplatz bis heute.',
	'junioren/junioren-organisation'   => 'Organisation der Juniorenabteilung des FC Schattdorf: Juniorenobmann, Leitung Kinderfussball, J+S-Coach, Material und Kommunikation – mit Kontakt.',
	'junioren/goalietraining'          => 'Goalietraining beim FC Schattdorf: Trainingszeiten für die Junioren D/E und A–C auf dem Hauptplatz Grüner Wald und das Trainerteam.',
	'junioren/fussballschule'          => 'Fussballschule des FC Schattdorf für die jüngsten Kinder: montags auf dem Sportplatz Grüner Wald – Jahrgänge, Zeiten, Leitungsteam und Flyer.',
	'junioren/trainingslager'          => 'Das Junioren-Trainingslager des FC Schattdorf: fünf Tage Fussball, zwei Trainings täglich, Campus mit Freibad – Impressionen und Ausblick.',
	'junioren/betreuer-werden'         => 'Betreuer werden beim FC Schattdorf: Wir suchen Trainerinnen und Trainer für die Juniorenteams und begleiten dich bis zur Trainerlizenz.',
	'junioren/juniorenkonzept'         => 'Das Juniorenkonzept des FC Schattdorf: Leitfaden und Philosophie für Trainer, Funktionäre, Kinder und Eltern – als PDF zum Herunterladen.',
	'junioren/tauschboerse'            => 'Fussball-Tauschbörse des FC Schattdorf: Schuhe, Trikots und Ausrüstung per WhatsApp mit anderen Vereinsmitgliedern tauschen oder verkaufen.',
	'junioren/teams/team-uri-ff11'     => 'Team Uri FF11 – die Juniorinnen des FC Schattdorf: Betreuerstab, Team-Sponsoren, Tabelle und Spielplan beim IFV.',
	'events'                           => 'Events und Veranstaltungen des FC Schattdorf: Generalversammlung, Turniere und Anlässe – alle Termine auf einen Blick.',
	'gruempelturnier'                  => 'Dorf- und Grümpelturnier des FC Schattdorf auf dem Sportplatz Grüner Wald: Programm, Kategorien, Spielpläne, Reglement und Anmeldung.',
	'sponsoren'                        => 'Die Sponsoren des FC Schattdorf: Hauptsponsor, Nachwuchs-Patronat, Co-, Club- und Nachwuchs-Sponsoren – und das Sponsoringkonzept zum Download.',
	'sponsoren/top-club-88'            => 'Top-Club 88 – der Sponsorenclub des FC Schattdorf: Ziele, Leistungen für Mitglieder und wie du dabei bist.',
	'kontakt'                          => 'Kontakt zum FC Schattdorf, 6467 Schattdorf UR: Kontaktformular und E-Mail an kommunikation@fcschattdorf.ch.',
	'news'                             => 'News des FC Schattdorf: Spielberichte, Turniere und Neuigkeiten aus dem Verein.',
	'impressum'                        => 'Impressum des FC Schattdorf: Kontaktadresse, Haftungsausschluss und Urheberrechte.',
	'datenschutzerklaerung'            => 'Datenschutzerklärung des FC Schattdorf: welche Personendaten wir bearbeiten, wozu, und wie wir sie schützen.',
);

/* Teamseiten: Muster mit dem Teamnamen aus dem Titel («Junioren Mannschaft Da»). */
$teams = get_pages( array( 'child_of' => 0, 'post_status' => 'publish', 'number' => 0 ) );
foreach ( $teams as $tp ) {
	$pfad = get_page_uri( $tp );
	if ( 0 === strpos( $pfad, 'junioren/teams/junioren-' ) && ! isset( $descs[ $pfad ] ) ) {
		$name = trim( preg_replace( '/^Junioren\s+Mannschaft\s+/u', '', $tp->post_title ) );
		$descs[ $pfad ] = "Junioren-Team {$name} des FC Schattdorf: Betreuerstab, Team-Sponsoren sowie Tabelle und Spielplan beim IFV.";
	}
}

$n_set = 0; $n_skip = 0; $n_miss = 0;
foreach ( $descs as $pfad => $text ) {
	$page = '' === $pfad ? get_post( (int) get_option( 'page_on_front' ) ) : get_page_by_path( $pfad );
	if ( ! $page ) { echo "   FEHLT   /{$pfad}/ – keine Seite mit diesem Pfad\n"; $n_miss++; continue; }
	$ist = trim( (string) get_post_meta( $page->ID, '_yoast_wpseo_metadesc', true ) );
	if ( '' !== $ist ) { $n_skip++; continue; }
	if ( ! $dry ) { update_post_meta( $page->ID, '_yoast_wpseo_metadesc', $text ); }
	echo sprintf( "   %-7s /%s/ (#%d, %d Zeichen)\n", $dry ? 'würde' : 'SET', $pfad, $page->ID, mb_strlen( $text ) );
	$n_set++;
}
echo "   Total: {$n_set} " . ( $dry ? 'zu setzen' : 'gesetzt' ) . ", {$n_skip} schon vorhanden (SKIP), {$n_miss} Seiten nicht gefunden\n";

/* ── B) Yoast-Standardbild ──────────────────────────────────────── */
echo "\nB) Yoast-Standardbild für Social Media\n";
$social = get_option( 'wpseo_social', array() );
if ( ! empty( $social['og_default_image'] ) ) {
	echo "   SKIP – schon gesetzt: {$social['og_default_image']}\n";
} else {
	$bild_url = home_url( '/wp-content/uploads/2026/06/FCS_2_Web.jpg' );
	$bild_id  = attachment_url_to_postid( $bild_url );
	if ( ! $bild_id ) {
		echo "   FEHLER – Bild nicht in der Mediathek gefunden: {$bild_url}\n";
	} elseif ( $dry ) {
		echo "   würde setzen: #{$bild_id} " . wp_get_attachment_url( $bild_id ) . "\n";
	} else {
		$social['og_default_image']    = wp_get_attachment_url( $bild_id );
		$social['og_default_image_id'] = (string) $bild_id;
		update_option( 'wpseo_social', $social );
		echo "   gesetzt: #{$bild_id} {$social['og_default_image']}\n";
	}
}

/* ── C) Datenschutzerklärung ────────────────────────────────────── */
echo "\nC) Datenschutzerklärung\n";
$ds = get_page_by_path( 'datenschutzerklaerung' );
if ( ! $ds ) {
	echo "   FEHLER – Seite /datenschutzerklaerung/ nicht gefunden.\n";
} else {
	$c = $ds->post_content;

	$sep = "<!-- wp:separator -->\n<hr class=\"wp-block-separator has-alpha-channel-opacity\" />\n<!-- /wp:separator -->";
	$h2  = function ( $t ) { return "<!-- wp:heading {\"level\":2} -->\n<h2 class=\"wp-block-heading\">{$t}</h2>\n<!-- /wp:heading -->"; };
	$p   = function ( $t ) { return "<!-- wp:paragraph -->\n<p>{$t}</p>\n<!-- /wp:paragraph -->"; };

	/* Erwartete Textstellen der Fassung 2023 */
	$alt_cookies = $h2( 'Nutzung der Website (Cookies und Server-Logdateien)' ) . "\n\n"
		. $p( 'Wir verwenden Session-Cookies und permanente Cookies. Sie können Cookies in Ihrem Browser jederzeit deaktivieren.' ) . "\n\n"
		. $p( 'Beim Besuch unserer Website werden Server-Logdateien erstellt, die u.a. IP-Adresse, Browsertyp, Betriebssystem und Zugriffszeit enthalten. Diese Daten werden ausschliesslich für den sicheren und zuverlässigen Betrieb der Website verwendet.' );
	$alt_dritte  = 'Ansonsten erfolgt keine Bekanntgabe an Dritte, weder im In- noch im Ausland.';
	$alt_schluss = $sep . "\n\n" . $h2( 'Schlussbestimmungen' );
	$alt_stand   = 'Stand: September 2023.';

	$neu_hosting = $h2( 'Hosting und Server-Logdateien' ) . "\n\n"
		. $p( 'Diese Website wird bei der Hostpoint AG, Rapperswil-Jona (Schweiz), betrieben. Beim Aufruf werden Server-Logdateien mit IP-Adresse, Browsertyp, Betriebssystem, Zugriffszeit und aufgerufener Seite erstellt. Wir und der Hoster verwenden diese Daten ausschliesslich für den sicheren und zuverlässigen Betrieb der Website.' ) . "\n\n"
		. $sep . "\n\n" . $h2( 'Cookies' ) . "\n\n"
		. $p( 'Wir setzen nur technisch notwendige Cookies ein, zum Beispiel bei der Anmeldung im Verwaltungsbereich. Es gibt kein Tracking und keine Analyse-Cookies.' );
	$neu_dritte  = 'Für den Betrieb der Website und der E-Mail setzen wir Dienstleister in der Schweiz ein (siehe unten); diese bearbeiten Daten nur in unserem Auftrag. Ansonsten erfolgt keine Bekanntgabe an Dritte, weder im In- noch im Ausland.';
	$neu_vor_schluss = $h2( 'E-Mail und Formulare' ) . "\n\n"
		. $p( 'Unsere E-Mail-Postfächer und der Versand von Formular-Mails laufen über die cyon GmbH, Basel. Angaben aus dem Kontaktformular und aus Fanshop-Bestellungen werden auf unserem Webserver gespeichert und per E-Mail an die zuständige Stelle im Verein übermittelt; wir verwenden sie nur zur Bearbeitung Ihrer Anfrage oder Bestellung. Der Warenkorb des Fanshops wird lokal in Ihrem Browser gespeichert und erst mit dem Absenden einer Bestellung an uns übermittelt.' ) . "\n\n"
		. $sep . "\n\n" . $h2( 'Links zu Drittanbietern' ) . "\n\n"
		. $p( 'Wir verlinken auf Facebook, Instagram, das IFV-Matchcenter und den Liveticker von Tickaroo. Beim Anklicken gelten die Datenschutzbestimmungen des jeweiligen Anbieters; auf unserer Website selbst werden keine Inhalte dieser Dienste eingebunden.' ) . "\n\n"
		. $alt_schluss;
	$neu_stand   = 'Stand: September 2026.';

	if ( false !== strpos( $c, 'Hostpoint AG' ) ) {
		echo "   SKIP – Seite #{$ds->ID} nennt Hostpoint bereits (Ergänzungen sind drin).\n";
	} else {
		$fehlt = array();
		foreach ( array( 'Cookies-Abschnitt' => $alt_cookies, 'Dritte-Satz' => $alt_dritte, 'Schlussbestimmungen' => $alt_schluss, 'Stand' => $alt_stand ) as $name => $marker ) {
			if ( false === strpos( $c, $marker ) ) { $fehlt[] = $name; }
		}
		if ( $fehlt && ! $force ) {
			echo "   ABBRUCH – Seite #{$ds->ID} enthält nicht mehr alle erwarteten Textstellen von 2023: " . implode( ', ', $fehlt ) . "\n";
			echo "   Vermutlich wurde die Seite inzwischen im Admin bearbeitet. Ergänzungen von Hand einpflegen (UMSTELLUNG-A7-INHALTE.md)\n";
			echo "   oder mit &force=1 nur die vorhandenen Stellen ersetzen lassen.\n";
		} else {
			$n = str_replace( array( $alt_cookies, $alt_dritte, $alt_schluss, $alt_stand ),
			                  array( $neu_hosting, $neu_dritte, $neu_vor_schluss, $neu_stand ), $c );
			if ( $dry ) {
				echo "   würde Seite #{$ds->ID} ergänzen: " . mb_strlen( $c ) . " -> " . mb_strlen( $n ) . " Zeichen, neue Abschnitte: Hosting, Cookies, E-Mail und Formulare, Links zu Drittanbietern; Stand -> September 2026\n";
			} else {
				$r = wp_update_post( array( 'ID' => $ds->ID, 'post_content' => $n ), true );
				if ( is_wp_error( $r ) ) {
					echo "   FEHLER: " . $r->get_error_message() . "\n";
				} else {
					echo "   ergänzt: Seite #{$ds->ID}, " . mb_strlen( $n ) . " Zeichen (alte Fassung als Revision im Admin).\n";
				}
			}
		}
	}
}

if ( ! $dry ) {
	@unlink( __FILE__ );
	echo "\nFertig. Skript hat sich selbst gelöscht.\n";
} else {
	echo "\nProbelauf beendet – nichts geschrieben. Skript bleibt liegen.\n";
}
