<?php
/**
 * Einmal-Skript: Redaktions-Nachträge vom 15.09.2026.
 *
 * Hintergrund: Auf Hostpoint ist MySQL von der SSH-Shell aus nicht
 * erreichbar — nur Web-Prozesse dürfen zur DB. Dieses Skript wird
 * daher kurzzeitig in den Webroot gelegt, per HTTPS mit Token
 * aufgerufen und danach gelöscht (löscht sich zusätzlich selbst).
 *
 * Was es tut:
 *
 *   A) Drei neue Beiträge aus news-import-1509.json anlegen —
 *      Spielbericht der 1. Mannschaft (2:1 gegen den FC Gunzwil),
 *      Spielbericht der Db-Junioren (3:3 beim SC Kriens) und Cupsieg
 *      der A-Junioren (5:1 gegen Team Wiggertal). Aufbau wie bei den
 *      Nachträgen vom 07./10.09.: Bildblock, dann Fliesstext-Absätze.
 *      Das Mannschaftsfoto der 1. Mannschaft (FCS_1_Team_Web.jpg) ist
 *      schon als Anhang da und wird wiederverwendet.
 *   B) 1. Mannschaft, Kader: Joel Aschwanden bekommt den Kopfsponsor
 *      «Bilger Mattli Bomatter Gisler» — Logo bmbg-color.svg, dieselbe Datei
 *      wie beim Sponsor «BMBG» auf /sponsoren/ — und tauscht die
 *      Rückennummer mit Noel Herger: Aschwanden neu 21, Herger neu 23.
 *      Damit tauschen die beiden auch den Platz im Kader (die Anzeige
 *      sortiert nach Nummer). Es werden nur diese zwei Zeilen im
 *      Seitenfeld «Kader» ersetzt; steht eine nicht mehr so da wie
 *      erwartet (Redaktion hat im Admin gearbeitet), meldet das Skript
 *      ABBRUCH für diese Zeile und rührt sie nicht an.
 *
 * Die Bilddateien überträgt das aufrufende Shell-Skript vorher per
 * scp; dieses Skript prüft nur noch, ob sie da sind.
 *
 * Idempotent: bestehende Beiträge werden am Slug erkannt und
 * übersprungen, gesetzte Kader-Zeilen melden «SKIP». Zweiter Lauf
 * ändert nichts.
 * Probelauf ohne Schreiben:  ?token=…&dry=1
 */
if ( ! isset( $_GET['token'] ) || ! hash_equals( '__TOKEN__', (string) $_GET['token'] ) ) {
	http_response_code( 403 ); exit( 'forbidden' );
}

require __DIR__ . '/wp-load.php';
require_once ABSPATH . 'wp-admin/includes/image.php';

header( 'Content-Type: text/plain; charset=utf-8' );
set_time_limit( 600 );

$dry = ! empty( $_GET['dry'] );
echo $dry ? "MODUS: Probelauf (es wird nichts geschrieben)\n\n" : "MODUS: Schreiben\n\n";

$fehler = 0;
$updir  = wp_upload_dir();

/* News-Bilder liegen im Monatsordner, Sponsorlogos der Teamseiten in
   2026/06 (dort sucht die Vorlage der 1. Mannschaft). */
$news_ordner  = '2026/09';
$news_basedir = $updir['basedir'] . '/' . $news_ordner . '/';
$news_baseurl = $updir['baseurl'] . '/' . $news_ordner . '/';
$logo_basedir = $updir['basedir'] . '/2026/06/';

/** Anhang zu einer bereits hochgeladenen Datei finden oder anlegen. */
function fcs_anhang( $datei, $titel, $ordner, $basedir, $baseurl, $dry ) {
	if ( '' === $datei ) { return 0; }
	$pfad = $basedir . $datei;
	if ( ! file_exists( $pfad ) ) {
		echo "   FEHLER – Datei fehlt: uploads/{$ordner}/{$datei}\n";
		return -1;
	}
	$vorhanden = get_posts( array(
		'post_type'   => 'attachment', 'post_status' => 'inherit', 'posts_per_page' => 1,
		'meta_key'    => '_wp_attached_file', 'meta_value' => $ordner . '/' . $datei,
		'fields'      => 'ids',
	) );
	if ( $vorhanden ) { return (int) $vorhanden[0]; }
	if ( $dry ) { return 0; }

	$typ = wp_check_filetype( $datei, null );
	$id  = wp_insert_attachment( array(
		'guid'           => $baseurl . $datei,
		'post_mime_type' => $typ['type'] ? $typ['type'] : 'image/jpeg',
		'post_title'     => $titel,
		'post_content'   => '',
		'post_status'    => 'inherit',
	), $pfad, 0, true );
	if ( is_wp_error( $id ) ) { echo "   FEHLER Anhang «{$datei}»: " . $id->get_error_message() . "\n"; return -1; }
	wp_update_attachment_metadata( $id, wp_generate_attachment_metadata( $id, $pfad ) );
	return (int) $id;
}

/* ── 0) Bilddateien müssen vor dem Schreiben da sein ────────────── */
echo "0) Bilddateien\n";
$noetig = array(
	$news_basedir . 'A_Junioren_09-09-2026.jpg',
	$news_basedir . 'Db_12-09-2026.jpg',
	$news_basedir . 'FCS_1_Team_Web.jpg',
	$logo_basedir . 'bmbg-color.svg',
	$logo_basedir . 'schibli-elektrotechnik-2026.png',
);
$fehlt = array();
foreach ( $noetig as $pfad ) {
	if ( ! file_exists( $pfad ) ) { $fehlt[] = str_replace( $updir['basedir'] . '/', '', $pfad ); }
}
if ( $fehlt ) {
	echo '   FEHLER – diese Dateien fehlen: ' . implode( ', ', $fehlt ) . "\n";
	echo "            Ohne sie zeigten die Seiten leere Kästen. Abbruch.\n";
	echo "\nFERTIG – ABER 1 Stelle braucht Aufmerksamkeit (siehe oben).\n";
	exit;
}
echo '   OK – alle ' . count( $noetig ) . " Dateien sind da.\n";

/* ── A) Neue Beiträge ───────────────────────────────────────────── */
echo "\nA) Neue Beiträge\n";

$daten = json_decode( (string) @file_get_contents( __DIR__ . '/news-import-1509.json' ), true );
if ( ! is_array( $daten ) || ! $daten ) {
	echo "   FEHLER – news-import-1509.json fehlt oder ist unlesbar.\n";
	$fehler++;
	$daten = array();
}

foreach ( $daten as $e ) {
	$slug = sanitize_title( $e['slug'] );
	echo "· {$e['datum']}  {$e['titel']}\n";

	$da = get_posts( array( 'post_type' => 'post', 'post_status' => 'any', 'name' => $slug, 'posts_per_page' => 1, 'fields' => 'ids' ) );
	if ( $da ) { echo "   SKIP – existiert bereits (#{$da[0]}).\n"; continue; }

	$bild_id = fcs_anhang( $e['bild'], $e['titel'], $news_ordner, $news_basedir, $news_baseurl, $dry );
	if ( -1 === $bild_id ) { $fehler++; continue; }

	/* Inhalt als Gutenberg-Blöcke, wie die bestehenden Beiträge. */
	$bloecke = array();
	if ( $bild_id > 0 ) {
		$url = wp_get_attachment_url( $bild_id );
		$bloecke[] = '<!-- wp:image {"id":' . $bild_id . ',"sizeSlug":"large","linkDestination":"none"} -->' . "\n"
			. '<figure class="wp-block-image size-large"><img src="' . esc_url( $url ) . '" alt="' . esc_attr( $e['titel'] ) . '" class="wp-image-' . $bild_id . '" /></figure>' . "\n"
			. '<!-- /wp:image -->';
	}
	$zwischentitel = isset( $e['zwischentitel'] ) ? (array) $e['zwischentitel'] : array();
	foreach ( $e['absaetze'] as $absatz ) {
		if ( in_array( $absatz, $zwischentitel, true ) ) {
			$bloecke[] = "<!-- wp:heading {\"level\":3} -->\n<h3 class=\"wp-block-heading\">"
				. esc_html( $absatz ) . "</h3>\n<!-- /wp:heading -->";
		} else {
			$bloecke[] = "<!-- wp:paragraph -->\n<p>" . esc_html( $absatz ) . "</p>\n<!-- /wp:paragraph -->";
		}
	}

	/* Ein Datum in der Zukunft würde WordPress zu einem geplanten
	   Beitrag machen — dann stünde er nicht auf der Website. */
	$datum = $e['datum'];
	if ( strtotime( $datum ) > strtotime( current_time( 'mysql' ) ) ) {
		echo "   HINWEIS – {$datum} liegt in der Zukunft, nehme die aktuelle Zeit.\n";
		$datum = current_time( 'mysql' );
	}

	if ( $dry ) {
		echo "   würde anlegen: Kategorie «{$e['kategorie']}», "
		   . count( $e['absaetze'] ) . " Absätze (davon "
		   . count( $zwischentitel ) . " Zwischentitel), Bild "
		   . ( $e['bild'] ? $e['bild'] : 'keines' )
		   . ( $bild_id > 0 ? " (Anhang #{$bild_id} vorhanden)" : ' (neuer Anhang)' ) . "\n";
		continue;
	}

	$kat = get_term_by( 'name', $e['kategorie'], 'category' );
	/* Beitragsbild als meta_input mit in den Insert — so kennt Yoast es
	   beim Bauen seiner Indexable-Zeile (og:image) schon. */
	$id = wp_insert_post( array(
		'post_type'     => 'post',
		'post_status'   => 'publish',
		'post_title'    => $e['titel'],
		'post_name'     => $slug,
		'post_date'     => $datum,
		'post_content'  => implode( "\n\n", $bloecke ),
		'post_category' => $kat ? array( (int) $kat->term_id ) : array(),
		'meta_input'    => $bild_id > 0 ? array( '_thumbnail_id' => $bild_id ) : array(),
	), true );
	if ( is_wp_error( $id ) ) { echo '   FEHLER: ' . $id->get_error_message() . "\n"; $fehler++; continue; }
	echo "   angelegt: #{$id}, Kategorie «{$e['kategorie']}», Bild-Anhang #{$bild_id}\n";
}

/* ── B) 1. Mannschaft: Kader-Zeilen Aschwanden / Herger ─────────── */
echo "\nB) 1. Mannschaft – Kopfsponsor Joel Aschwanden, Nummerntausch mit Noel Herger\n";

$zeilen_neu = array(
	'Verteidigung | 23 | Joel Aschwanden | Joel_Aschwanden.jpg'
		=> 'Verteidigung | 21 | Joel Aschwanden | Joel_Aschwanden.jpg | bmbg-color.svg | Bilger Mattli Bomatter Gisler',
	'Mittelfeld | 21 | Noel Herger | Noel_Herger.jpg'
		=> 'Mittelfeld | 23 | Noel Herger | Noel_Herger.jpg',
);

$m1 = get_page_by_path( 'aktive/1-mannschaft' );
if ( ! $m1 ) { $m1 = get_page_by_path( '1-mannschaft' ); }
if ( ! $m1 ) {
	echo "   FEHLER – Seite «1. Mannschaft» nicht gefunden.\n";
	$fehler++;
} else {
	$ist    = str_replace( "\r\n", "\n", (string) get_post_meta( $m1->ID, 'fcs_team_kader', true ) );
	$zeilen = explode( "\n", $ist );
	$trim   = array_map( 'trim', $zeilen );
	$geaendert = false;
	if ( '' === trim( $ist ) ) {
		/* Seitenfeld leer: die Vorlage zeigt dann ihren Fallback, den der
		   Theme-Deploy nachzieht — hier ist nichts zu tun. */
		echo "   HINWEIS – Seitenfeld «Kader» ist leer; die Vorlage liefert den Fallback (Theme-Deploy nötig).\n";
	} else {
		foreach ( $zeilen_neu as $alt => $neu ) {
			if ( false !== array_search( $neu, $trim, true ) ) {
				echo "   SKIP – steht schon: «{$neu}»\n";
				continue;
			}
			$idx = array_search( $alt, $trim, true );
			if ( false === $idx ) {
				echo "   ABBRUCH – die erwartete Kader-Zeile «{$alt}» steht nicht (mehr) so im Feld.\n";
				echo "             Da hat jemand im Admin gearbeitet — Zeile von Hand im Admin setzen:\n";
				echo "             {$neu}\n";
				$fehler++;
				continue;
			}
			$zeilen[ $idx ] = $neu;
			$trim[ $idx ]   = $neu;
			$geaendert      = true;
			echo '   ' . ( $dry ? 'würde setzen: ' : 'gesetzt: ' ) . "Seite #{$m1->ID}\n";
			echo "             «{$alt}»\n          -> «{$neu}»\n";
		}
		if ( $geaendert && ! $dry ) { update_post_meta( $m1->ID, 'fcs_team_kader', implode( "\n", $zeilen ) ); }
	}
}

/* ── Abschluss ──────────────────────────────────────────────────── */
if ( ! $dry ) {
	wp_cache_flush();
	@unlink( __DIR__ . '/news-import-1509.json' );
	@unlink( __FILE__ );
	echo "\nSkript und Datenliste haben sich selbst gelöscht.\n";
}
echo "\n" . ( 0 === $fehler ? "FERTIG – keine Fehler.\n" : "FERTIG – ABER {$fehler} Stelle(n) brauchen Aufmerksamkeit (siehe oben).\n" );
