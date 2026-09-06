<?php
/**
 * Einmal-Skript: News von der alten Vereinsseite nachtragen.
 *
 * Hintergrund: Die Redaktion pflegt die News weiterhin auf
 * www.fcschattdorf.ch. Auf der neuen Seite endete der Feed am
 * 30.06.2026. Dieses Skript legt die 25 seither erschienenen Beiträge
 * an (Stand 05.09.2026) — mit Titel, Datum, Volltext, Kategorie und
 * Beitragsbild.
 *
 * Die Daten stehen in news-import-0926.json, die Bilder liegen bereits
 * in wp-content/uploads/2026/09/ (das Deploy-Skript lädt sie vorher
 * hoch). Auf Hostpoint ist MySQL nur aus Web-Prozessen erreichbar,
 * deshalb der Umweg über den Webroot.
 *
 * Idempotent: ein Beitrag mit demselben Slug wird übersprungen, ein
 * bereits angelegtes Bild wiederverwendet. Ein zweiter Lauf meldet
 * überall «SKIP».
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
$daten  = json_decode( (string) @file_get_contents( __DIR__ . '/news-import-0926.json' ), true );
if ( ! is_array( $daten ) || ! $daten ) {
	echo "FEHLER – news-import-0926.json fehlt oder ist unlesbar.\n"; exit;
}
echo count( $daten ) . " Beiträge in der Liste.\n\n";

$updir   = wp_upload_dir();
$ordner  = '2026/09';
$basedir = $updir['basedir'] . '/' . $ordner . '/';
$baseurl = $updir['baseurl'] . '/' . $ordner . '/';

/** Anhang zu einer bereits hochgeladenen Datei finden oder anlegen. */
function fcs_news_anhang( $datei, $titel, $ordner, $basedir, $baseurl, $dry ) {
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

foreach ( $daten as $e ) {
	$slug = sanitize_title( $e['slug'] );
	echo "· {$e['datum']}  {$e['titel']}\n";

	$da = get_posts( array( 'post_type' => 'post', 'post_status' => 'any', 'name' => $slug, 'posts_per_page' => 1, 'fields' => 'ids' ) );
	if ( $da ) { echo "   SKIP – existiert bereits (#{$da[0]}).\n"; continue; }

	$bild_id = fcs_news_anhang( $e['bild'], $e['titel'], $ordner, $basedir, $baseurl, $dry );
	if ( -1 === $bild_id ) { $fehler++; continue; }

	/* Inhalt als Gutenberg-Blöcke, wie die bestehenden Beiträge. */
	$bloecke = array();
	if ( $bild_id > 0 ) {
		$url = wp_get_attachment_url( $bild_id );
		$bloecke[] = '<!-- wp:image {"id":' . $bild_id . ',"sizeSlug":"large","linkDestination":"none"} -->' . "\n"
			. '<figure class="wp-block-image size-large"><img src="' . esc_url( $url ) . '" alt="' . esc_attr( $e['titel'] ) . '" class="wp-image-' . $bild_id . '" /></figure>' . "\n"
			. '<!-- /wp:image -->';
	}
	foreach ( $e['absaetze'] as $absatz ) {
		$bloecke[] = "<!-- wp:paragraph -->\n<p>" . esc_html( $absatz ) . "</p>\n<!-- /wp:paragraph -->";
	}
	if ( ! empty( $e['pdf'] ) ) {
		$pdf_id  = fcs_news_anhang( $e['pdf'], $e['titel'], $ordner, $basedir, $baseurl, $dry );
		$pdf_url = $pdf_id > 0 ? wp_get_attachment_url( $pdf_id ) : $baseurl . $e['pdf'];
		$bloecke[] = "<!-- wp:paragraph -->\n" . '<p><a href="' . esc_url( $pdf_url ) . '" target="_blank" rel="noopener">FCS-Zyttig Sommer 2026 als PDF öffnen</a></p>' . "\n<!-- /wp:paragraph -->";
	}

	if ( $dry ) {
		echo "   würde anlegen: Kategorie «{$e['kategorie']}», "
		   . count( $e['absaetze'] ) . " Absätze, Bild " . ( $e['bild'] ? $e['bild'] : 'keines' ) . "\n";
		continue;
	}

	$kat = get_term_by( 'name', $e['kategorie'], 'category' );
	$id  = wp_insert_post( array(
		'post_type'     => 'post',
		'post_status'   => 'publish',
		'post_title'    => $e['titel'],
		'post_name'     => $slug,
		'post_date'     => $e['datum'],
		'post_content'  => implode( "\n\n", $bloecke ),
		'post_category' => $kat ? array( (int) $kat->term_id ) : array(),
	), true );
	if ( is_wp_error( $id ) ) { echo "   FEHLER: " . $id->get_error_message() . "\n"; $fehler++; continue; }
	if ( $bild_id > 0 ) { set_post_thumbnail( $id, $bild_id ); }
	echo "   angelegt: #{$id}, Kategorie «{$e['kategorie']}»\n";
}

if ( ! $dry ) {
	wp_cache_flush();
	@unlink( __DIR__ . '/news-import-0926.json' );
	@unlink( __FILE__ );
	echo "\nSkript und Datenliste haben sich selbst gelöscht.\n";
}
echo "\n" . ( 0 === $fehler ? "FERTIG – keine Fehler.\n" : "FERTIG – ABER {$fehler} Fehler (siehe oben).\n" );
