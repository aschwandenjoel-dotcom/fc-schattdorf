<?php
/**
 * Wiederverwendbares Skript: News-Beiträge aus einer Textliste anlegen.
 *
 * Wird von deploy/deploy-news.sh <TAG> mit Token und Dateiname der
 * Textliste (news-import-<TAG>.json) befüllt, kurz in den Webroot
 * gelegt, per HTTPS aufgerufen und löscht sich danach selbst (MySQL
 * ist auf Hostpoint nur aus Web-Prozessen erreichbar).
 *
 * Je Eintrag der Textliste:
 *   slug, titel, kategorie (Name der Kategorie), datum (Y-m-d H:i:s),
 *   bild (Datei im Monatsordner YYYY/MM des Datums, steht im Artikel),
 *   optional beitragsbild (Datei im selben Ordner — Hero der Startseite
 *   und News-Kacheln; sonst ist das Artikelbild auch Beitragsbild),
 *   absaetze (Liste), zwischentitel (Teilmenge der Absätze -> <h3>).
 *
 * Aufbau des Beitrags wie alle bisherigen Nachträge: Bildblock, dann
 * Absätze als Gutenberg-Blöcke. Beitragsbild geht als meta_input mit
 * in den Insert (Yoast baut sein og:image beim Speichern). Existiert
 * der Slug schon, wird nur ein abweichendes Beitragsbild nachgezogen
 * (erst set_post_thumbnail, dann wp_update_post — sonst bleibt bei
 * Yoast das alte og:image stehen).
 *
 * Idempotent; Probelauf ohne Schreiben:  ?token=…&dry=1
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
$liste  = '__JSON__';

/** Anhang zu einer bereits hochgeladenen Datei finden oder anlegen. */
function fcs_anhang( $datei, $titel, $ordner, $dry ) {
	global $updir;
	if ( '' === $datei ) { return 0; }
	$pfad = $updir['basedir'] . '/' . $ordner . '/' . $datei;
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
		'guid'           => $updir['baseurl'] . '/' . $ordner . '/' . $datei,
		'post_mime_type' => $typ['type'] ? $typ['type'] : 'image/jpeg',
		'post_title'     => $titel,
		'post_content'   => '',
		'post_status'    => 'inherit',
	), $pfad, 0, true );
	if ( is_wp_error( $id ) ) { echo "   FEHLER Anhang «{$datei}»: " . $id->get_error_message() . "\n"; return -1; }
	wp_update_attachment_metadata( $id, wp_generate_attachment_metadata( $id, $pfad ) );
	return (int) $id;
}

$daten = json_decode( (string) @file_get_contents( __DIR__ . '/' . $liste ), true );
if ( ! is_array( $daten ) || ! $daten ) {
	echo "FEHLER – {$liste} fehlt oder ist unlesbar.\n";
	exit;
}

/* ── 0) Bilddateien müssen vor dem Schreiben da sein ────────────── */
echo "0) Bilddateien\n";
$fehlt = array();
foreach ( $daten as $e ) {
	$ordner = substr( $e['datum'], 0, 4 ) . '/' . substr( $e['datum'], 5, 2 );
	foreach ( array( $e['bild'] ?? '', $e['beitragsbild'] ?? '' ) as $b ) {
		if ( '' !== $b && ! file_exists( $updir['basedir'] . "/{$ordner}/{$b}" ) ) { $fehlt[] = "{$ordner}/{$b}"; }
	}
}
if ( $fehlt ) {
	echo '   FEHLER – diese Dateien fehlen: ' . implode( ', ', array_unique( $fehlt ) ) . "\n";
	echo "            Ohne sie zeigten die Seiten leere Kästen. Abbruch.\n";
	echo "\nFERTIG – ABER 1 Stelle braucht Aufmerksamkeit (siehe oben).\n";
	exit;
}
echo "   OK – alle Bilddateien sind da.\n";

/* ── A) Beiträge ────────────────────────────────────────────────── */
echo "\nA) Beiträge aus {$liste}\n";

foreach ( $daten as $e ) {
	$slug   = sanitize_title( $e['slug'] );
	$ordner = substr( $e['datum'], 0, 4 ) . '/' . substr( $e['datum'], 5, 2 );
	echo "· {$e['datum']}  {$e['titel']}\n";

	$da = get_posts( array( 'post_type' => 'post', 'post_status' => 'any', 'name' => $slug, 'posts_per_page' => 1, 'fields' => 'ids' ) );
	if ( $da ) {
		$pid = (int) $da[0];
		if ( empty( $e['beitragsbild'] ) ) { echo "   SKIP – existiert bereits (#{$pid}).\n"; continue; }
		$soll = fcs_anhang( $e['beitragsbild'], $e['titel'], $ordner, $dry );
		if ( -1 === $soll ) { $fehler++; continue; }
		$ist = (int) get_post_thumbnail_id( $pid );
		if ( $soll > 0 && $ist === $soll ) { echo "   SKIP – existiert bereits (#{$pid}), Beitragsbild ist schon {$e['beitragsbild']}.\n"; continue; }
		echo '   ' . ( $dry ? 'würde setzen: ' : 'gesetzt: ' ) . "Beitrag #{$pid} Beitragsbild -> {$e['beitragsbild']}\n";
		if ( ! $dry ) { set_post_thumbnail( $pid, $soll ); wp_update_post( array( 'ID' => $pid ) ); }
		continue;
	}

	$bild_id = fcs_anhang( $e['bild'] ?? '', $e['titel'], $ordner, $dry );
	if ( -1 === $bild_id ) { $fehler++; continue; }

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
			$bloecke[] = "<!-- wp:heading {\"level\":3} -->\n<h3 class=\"wp-block-heading\">" . esc_html( $absatz ) . "</h3>\n<!-- /wp:heading -->";
		} else {
			$bloecke[] = "<!-- wp:paragraph -->\n<p>" . esc_html( $absatz ) . "</p>\n<!-- /wp:paragraph -->";
		}
	}

	/* Datum in der Zukunft => WordPress plant den Beitrag, statt ihn zu zeigen. */
	$datum = $e['datum'];
	if ( strtotime( $datum ) > strtotime( current_time( 'mysql' ) ) ) {
		echo "   HINWEIS – {$datum} liegt in der Zukunft, nehme die aktuelle Zeit.\n";
		$datum = current_time( 'mysql' );
	}

	$kat = get_term_by( 'name', $e['kategorie'], 'category' );
	if ( ! $kat ) { echo "   FEHLER – Kategorie «{$e['kategorie']}» gibt es nicht.\n"; $fehler++; continue; }

	if ( $dry ) {
		echo "   würde anlegen: Kategorie «{$e['kategorie']}», " . count( $e['absaetze'] ) . ' Absätze (davon '
		   . count( $zwischentitel ) . ' Zwischentitel), Bild ' . ( ( $e['bild'] ?? '' ) ?: 'keines' )
		   . ( $bild_id > 0 ? " (Anhang #{$bild_id} vorhanden)" : ' (neuer Anhang)' )
		   . ( empty( $e['beitragsbild'] ) ? '' : ", Beitragsbild {$e['beitragsbild']}" ) . "\n";
		continue;
	}

	$thumb_id = $bild_id;
	if ( ! empty( $e['beitragsbild'] ) ) {
		$eigenes = fcs_anhang( $e['beitragsbild'], $e['titel'], $ordner, $dry );
		if ( -1 === $eigenes ) { $fehler++; continue; }
		if ( $eigenes > 0 ) { $thumb_id = $eigenes; }
	}

	$id = wp_insert_post( array(
		'post_type'     => 'post',
		'post_status'   => 'publish',
		'post_title'    => $e['titel'],
		'post_name'     => $slug,
		'post_date'     => $datum,
		'post_content'  => implode( "\n\n", $bloecke ),
		'post_category' => array( (int) $kat->term_id ),
		'meta_input'    => $thumb_id > 0 ? array( '_thumbnail_id' => $thumb_id ) : array(),
	), true );
	if ( is_wp_error( $id ) ) { echo '   FEHLER: ' . $id->get_error_message() . "\n"; $fehler++; continue; }
	echo "   angelegt: #{$id}, Kategorie «{$e['kategorie']}», Bild-Anhang #{$bild_id}"
		. ( $thumb_id !== $bild_id ? ", Beitragsbild {$e['beitragsbild']} (#{$thumb_id})" : '' ) . "\n";
}

/* ── Abschluss ──────────────────────────────────────────────────── */
if ( ! $dry ) {
	wp_cache_flush();
	@unlink( __DIR__ . '/' . $liste );
	@unlink( __FILE__ );
	echo "\nSkript und Textliste haben sich selbst gelöscht.\n";
}
echo "\n" . ( 0 === $fehler ? "FERTIG – keine Fehler.\n" : "FERTIG – ABER {$fehler} Stelle(n) brauchen Aufmerksamkeit (siehe oben).\n" );
