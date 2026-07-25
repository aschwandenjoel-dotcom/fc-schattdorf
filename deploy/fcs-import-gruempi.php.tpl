<?php
/**
 * Einmal-Import: News-Beitrag «33. Dorf- und 66. Grümpelturnier des FC
 * Schattdorf» + 25 Fotos in die PRODUKTIONS-DB (Hostpoint).
 *
 * Hintergrund: Auf Hostpoint ist MySQL nur aus Web-Prozessen erreichbar.
 * Dieses Skript wird daher kurz in den Webroot gelegt, per HTTPS mit Token
 * aufgerufen und löscht sich anschliessend selbst (zusätzlich entfernt es
 * das Deploy-Skript per ssh).
 *
 * WICHTIG – warum WP-API statt roher SQL-INSERTs:
 *   Die lokalen IDs (Post 789, Attachments 764–788) sind auf der Live-DB
 *   evtl. schon vergeben. Darum legt dieses Skript Beitrag und Anhänge über
 *   wp_insert_post()/wp_insert_attachment() an — die Live-DB vergibt neue,
 *   kollisionsfreie IDs. Der Beitragsinhalt wird mit genau diesen neuen IDs
 *   und den Live-URLs (home_url) frisch aufgebaut. Es wird NUR dieser eine
 *   Beitrag angefasst, die übrige DB bleibt unberührt.
 *
 * Voraussetzung: Die 25 Bilddateien liegen bereits unter
 *   wp-content/uploads/2026/07/  (per rsync durch deploy-gruempi.sh).
 *
 * Idempotent: Existiert der Beitrag (Slug) schon, passiert nichts.
 */

if ( ! isset( $_GET['token'] ) || ! hash_equals( '__TOKEN__', (string) $_GET['token'] ) ) {
	http_response_code( 403 ); exit( 'forbidden' );
}

require __DIR__ . '/wp-load.php';
require_once ABSPATH . 'wp-admin/includes/image.php';

header( 'Content-Type: text/plain; charset=utf-8' );
set_time_limit( 600 );

$SLUG    = '33-dorf-und-66-gruempelturnier-des-fc-schattdorf';
$TITLE   = '33. Dorf- und 66. Grümpelturnier des FC Schattdorf';
$SUBDIR  = '2026/07';                       // Upload-Unterordner der Bilder
$ALT     = '33. Dorf- und 66. Grümpelturnier des FC Schattdorf';

function done( $msg ) {
	echo $msg, "\n";
	@unlink( __FILE__ );          // Skript entfernt sich selbst
	exit;
}

/* ── Idempotenz: schon vorhanden? ─────────────────────────────────── */
$exists = get_page_by_path( $SLUG, OBJECT, 'post' );
if ( $exists ) {
	done( "SKIP: Beitrag existiert bereits (ID {$exists->ID}) — nichts geändert." );
}

/* ── Bild-Reihenfolge (erste = Beitragsbild/Leadbild) ─────────────── */
$files = array(
	'thumbnail.jpg',
	'thumbnail-2.jpg', 'thumbnail-3.jpg', 'thumbnail-4.jpg', 'thumbnail-5.jpg',
	'thumbnail-6.jpg', 'thumbnail-7.jpg', 'thumbnail-8.jpg', 'thumbnail-9.jpg',
	'thumbnail-10.jpg', 'thumbnail-11.jpg', 'thumbnail-12.jpg', 'thumbnail-13.jpg',
	'thumbnail-14.jpg', 'thumbnail-15.jpg', 'thumbnail-16.jpg',
	'gymi-106.jpg', 'gymi-119.jpg',
	'photo-2026-06-25-10-58-40.jpg', 'photo-2026-06-25-10-59-34.jpg',
	'photo-2026-06-25-10-59-53.jpg', 'photo-2026-06-25-11-00-26.jpg',
	'photo-2026-06-25-21-23-19.jpg', 'photo-2026-06-25-21-36-48.jpg',
	'photo-2026-06-25-21-40-55.jpg',
);

$updir   = wp_upload_dir();
$basedir = trailingslashit( $updir['basedir'] ) . $SUBDIR . '/';
$baseurl = trailingslashit( $updir['baseurl'] ) . $SUBDIR . '/';

/* Erst prüfen, dass alle Dateien da sind (rsync gelaufen?) */
$missing = array();
foreach ( $files as $f ) {
	if ( ! file_exists( $basedir . $f ) ) { $missing[] = $f; }
}
if ( $missing ) {
	done( "ABBRUCH: Bilddateien fehlen unter uploads/{$SUBDIR}/ — zuerst rsync ausführen:\n  " . implode( "\n  ", $missing ) );
}

/* ── Anhänge anlegen (Datei -> Media-Library-Eintrag) ─────────────── */
$ids = array();   // filename => neue Attachment-ID
foreach ( $files as $f ) {
	$att = array(
		'post_mime_type' => 'image/jpeg',
		'post_title'     => $TITLE,
		'post_status'    => 'inherit',
		'guid'           => $baseurl . $f,
	);
	$aid = wp_insert_attachment( $att, $basedir . $f, 0, true );
	if ( is_wp_error( $aid ) ) {
		done( "ABBRUCH bei {$f}: " . $aid->get_error_message() );
	}
	update_post_meta( $aid, '_wp_attachment_image_alt', $ALT );
	$meta = wp_generate_attachment_metadata( $aid, $basedir . $f );
	wp_update_attachment_metadata( $aid, $meta );
	$ids[ $f ] = $aid;
}

/* ── Beitragsinhalt (Gutenberg) mit den NEUEN IDs + Live-URLs bauen ─ */
$img_block = function ( $file ) use ( $ids, $baseurl, $ALT ) {
	$id = $ids[ $file ];
	return '<!-- wp:image {"id":' . $id . ',"sizeSlug":"large","linkDestination":"none"} -->' . "\n"
		. '<figure class="wp-block-image size-large"><img src="' . esc_url( $baseurl . $file )
		. '" alt="' . esc_attr( $ALT ) . '" class="wp-image-' . $id . '"/></figure>' . "\n"
		. '<!-- /wp:image -->';
};

$subtitle = 'Dorf- und Grümpelturnier des FC Schattdorf begeistert mit Sport, Stimmung und Public Viewing';
$paras = array(
	'Bei herrlichem Sommerwetter und ausgelassener Atmosphäre ging am vergangenen Wochenende das traditionelle Dorf- und Grümpelturnier des FC Schattdorf über die Bühne. Zahlreiche Mannschaften aus der Region lieferten sich packende Duelle und sorgten für ein rundum gelungenes Sportfest mit vielen Höhepunkten auf und neben dem Platz.',
	'Insgesamt nahmen 70 Teams mit rund 650 Spielerinnen und Spielern teil. Über das gesamte Wochenende strömten zusätzlich viele Fussballfans auf die Anlage und verfolgten die spannenden Spiele. Den Zuschauerinnen und Zuschauern wurden faire und hochklassige Partien geboten. Als Sieger bei den Herren setzte sich das Team &#8222;La Vaca&#8220; durch, während in der Mixed-Kategorie die &#8222;Flippers&#8220; den Turniersieg feiern konnten.',
	'Auch der Nachwuchs zeigte vollen Einsatz und viel Spielfreude. In der Kategorie Piccolo gewann das &#8222;Team Rot Schwarz&#8220;, bei den Mädchen überzeugten die &#8222;Turbo Queens&#8220;. In der Kategorie Schüler S2 sicherte sich die Gruppe &#8222;Grümpelturnier&#8220; den ersten Platz, während bei den Schülern S1 &#8222;FC Balers&#8220; als Sieger hervorgingen.',
	'Bereits zum Auftakt des Wochenendes gab es spannende Begegnungen im Dorfturnier: Hier setzte sich die Mannschaft &#8222;Porr Suisse AG&#8220; gegen die Konkurrenz &#8222;Ready or not &#8211; Kantonspolizei Uri&#8220; durch.',
	'Für beste Unterhaltung auch abseits des Rasens war gesorgt: DJ Ref am Freitag sowie DJ Ramon am Samstag heizten dem Publikum mit einer Mischung aus aktuellen Hits und Klassikern ordentlich ein und sorgten für ausgelassene Partystimmung bis in die Nacht. Ein weiteres Highlight bildete zudem das Public Viewing. Gemeinsam wurde mitgefiebert, gejubelt und die Fussballstimmung genossen.',
	'Die Gewinnerinnen und Gewinner der Tombola werden ab dem 1. Juli 2026 auf der Website des FC Schattdorf veröffentlicht.',
);

$out = array();
$out[] = $img_block( $files[0] );                 // Leadbild
$out[] = "\n" . '<!-- wp:heading {"level":3} -->';
$out[] = '<h3 class="wp-block-heading">' . esc_html( $subtitle ) . '</h3>';
$out[] = '<!-- /wp:heading -->';
foreach ( $paras as $p ) {
	$out[] = "\n" . '<!-- wp:paragraph -->';
	$out[] = '<p>' . $p . '</p>';
	$out[] = '<!-- /wp:paragraph -->';
}
/* Galerie: alle Bilder ausser dem Leadbild */
$out[] = "\n" . '<!-- wp:gallery {"linkTo":"none"} -->';
$out[] = '<figure class="wp-block-gallery has-nested-images columns-default is-cropped">';
foreach ( array_slice( $files, 1 ) as $f ) {
	$out[] = $img_block( $f );
}
$out[] = '</figure>';
$out[] = '<!-- /wp:gallery -->';
$content = implode( "\n", $out );

/* ── Beitrag anlegen ──────────────────────────────────────────────── */
$post_id = wp_insert_post( array(
	'post_type'    => 'post',
	'post_status'  => 'publish',
	'post_title'   => $TITLE,
	'post_name'    => $SLUG,
	'post_date'    => '2026-06-30 10:00:00',
	'post_author'  => 1,
	'post_content' => $content,
	'post_excerpt' => 'Bei herrlichem Sommerwetter ging das traditionelle Dorf- und Grümpelturnier des FC Schattdorf über die Bühne. 70 Teams mit rund 650 Spielerinnen und Spielern, packende Duelle, DJs und Public Viewing.',
), true );

if ( is_wp_error( $post_id ) ) {
	done( 'ABBRUCH: Beitrag konnte nicht angelegt werden: ' . $post_id->get_error_message() );
}

/* Kategorie «Verein» (anlegen falls fehlt) */
$term = get_term_by( 'slug', 'verein', 'category' );
if ( ! $term ) {
	$new = wp_insert_term( 'Verein', 'category', array( 'slug' => 'verein' ) );
	$cat_id = is_wp_error( $new ) ? 0 : (int) $new['term_id'];
} else {
	$cat_id = (int) $term->term_id;
}
if ( $cat_id ) {
	wp_set_post_categories( $post_id, array( $cat_id ) );
}

/* Beitragsbild + Anhänge dem Beitrag zuordnen */
set_post_thumbnail( $post_id, $ids[ $files[0] ] );
foreach ( $ids as $aid ) {
	wp_update_post( array( 'ID' => $aid, 'post_parent' => $post_id ) );
}

$url = get_permalink( $post_id );
done( "OK: Beitrag angelegt (ID {$post_id}), " . count( $ids ) . " Bilder importiert.\nURL: {$url}" );
