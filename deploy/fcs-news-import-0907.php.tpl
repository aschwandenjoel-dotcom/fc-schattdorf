<?php
/**
 * Einmal-Skript: drei weitere News von der alten Vereinsseite nachtragen.
 *
 * Hintergrund: Die Redaktion pflegt die News weiterhin auf
 * www.fcschattdorf.ch. Der Nachtrag vom 05.09.2026 endete bei Beitrag
 * 1573 (04.09.). Seither sind drei weitere erschienen (Stand
 * 07.09.2026) — dieses Skript legt sie an, mit Titel, Datum,
 * Volltext, Zwischentiteln, Kategorie und Beitragsbild.
 *
 * Die Daten stehen in news-import-0907.json. Zwei der drei Bilder
 * liegen schon in wp-content/uploads/2026/09 (aus dem ersten
 * Nachtrag), nur Ba-GeringQWEB.jpg kommt neu dazu — das Deploy-Skript
 * lädt es vorher hoch. Auf Hostpoint ist MySQL nur aus Web-Prozessen
 * erreichbar, deshalb der Umweg über den Webroot.
 *
 * Zu Beitrag 1577 «Bittere 2:3 Niederlage gegen Hünenberg»: die alte
 * Seite hängt dort FCS_2_Web.jpg an, das Mannschaftsfoto der zweiten
 * Mannschaft. Der Text ist aber ein Bericht der ersten: jeder echte
 * Bericht der zweiten nennt «Schattdorf 2» im Fliesstext (dreimal),
 * dieser kein einziges Mal, und die genannten Torschützen stehen im
 * Kader der ersten Mannschaft. Der Beitrag bekommt deshalb die
 * Kategorie «1. Mannschaft» und FCS_1_Team_Web.jpg wie die übrigen
 * Berichte der ersten Mannschaft.
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
$daten  = json_decode( (string) @file_get_contents( __DIR__ . '/news-import-0907.json' ), true );
if ( ! is_array( $daten ) || ! $daten ) {
	echo "FEHLER – news-import-0907.json fehlt oder ist unlesbar.\n"; exit;
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
	/* Fett ausgezeichnete Absaetze der Quelle sind Zwischentitel und
	   werden zu Ueberschriften. Der Lead-Absatz zaehlt nicht dazu – er
	   bleibt Fliesstext wie in den 25 bereits importierten Beitraegen. */
	$zwischentitel = isset( $e['zwischentitel'] ) ? (array) $e['zwischentitel'] : array();
	foreach ( $e['absaetze'] as $absatz ) {
		if ( in_array( $absatz, $zwischentitel, true ) ) {
			$bloecke[] = "<!-- wp:heading {\"level\":3} -->\n<h3 class=\"wp-block-heading\">"
				. esc_html( $absatz ) . "</h3>\n<!-- /wp:heading -->";
		} else {
			$bloecke[] = "<!-- wp:paragraph -->\n<p>" . esc_html( $absatz ) . "</p>\n<!-- /wp:paragraph -->";
		}
	}

	if ( $dry ) {
		echo "   würde anlegen: Kategorie «{$e['kategorie']}», "
		   . count( $e['absaetze'] ) . " Absätze (davon "
		   . count( isset( $e['zwischentitel'] ) ? (array) $e['zwischentitel'] : array() )
		   . " Zwischentitel), Bild " . ( $e['bild'] ? $e['bild'] : 'keines' ) . "\n";
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
	@unlink( __DIR__ . '/news-import-0907.json' );
	@unlink( __FILE__ );
	echo "\nSkript und Datenliste haben sich selbst gelöscht.\n";
}
echo "\n" . ( 0 === $fehler ? "FERTIG – keine Fehler.\n" : "FERTIG – ABER {$fehler} Fehler (siehe oben).\n" );
