<?php
/**
 * Einmal-Änderung: Beitragsbild («Titelbild») des News-Beitrags
 * «33. Dorf- und 66. Grümpelturnier des FC Schattdorf» in der
 * PRODUKTIONS-DB (Hostpoint) auf das Original-Header-Bild umstellen.
 *
 * Hintergrund: Beim Import wurde das erste Galeriebild (thumbnail.jpg) als
 * Beitragsbild gesetzt. Gewünscht ist stattdessen das Artikel-Header-Bild
 * (Original von /images/thumbnail-13.jpeg, 1600×900) — dieses liegt auf
 * Live NICHT in der Galerie, wird also als NEUER Anhang angelegt und als
 * Beitragsbild gesetzt. Das alte Beitragsbild bleibt als Anhang/Inline-
 * Leadbild erhalten (non-destruktiv), nur das _thumbnail_id ändert sich.
 *
 * Auf Hostpoint ist MySQL nur aus Web-Prozessen erreichbar. Dieses Skript
 * wird darum kurz in den Webroot gelegt, per HTTPS mit Token aufgerufen und
 * löscht sich anschliessend selbst.
 *
 * Voraussetzung: Die Bilddatei liegt bereits unter
 *   wp-content/uploads/2026/07/gruempelturnier-hero.jpg
 * (per rsync durch deploy-gruempi-thumb.sh).
 *
 * Idempotent: Existiert der Anhang (gleicher Dateipfad) schon, wird er
 * wiederverwendet statt dupliziert; ist er bereits das Beitragsbild,
 * passiert nichts.
 */

if ( ! isset( $_GET['token'] ) || ! hash_equals( '__TOKEN__', (string) $_GET['token'] ) ) {
	http_response_code( 403 ); exit( 'forbidden' );
}

require __DIR__ . '/wp-load.php';
require_once ABSPATH . 'wp-admin/includes/image.php';

header( 'Content-Type: text/plain; charset=utf-8' );
set_time_limit( 600 );

$SLUG   = '33-dorf-und-66-gruempelturnier-des-fc-schattdorf';
$SUBDIR = '2026/07';                       // Upload-Unterordner
$FILE   = 'gruempelturnier-hero.jpg';      // neues Header-/Beitragsbild
$ALT    = '33. Dorf- und 66. Grümpelturnier des FC Schattdorf';

function done( $msg ) {
	echo $msg, "\n";
	@unlink( __FILE__ );          // Skript entfernt sich selbst
	exit;
}

/* ── Beitrag finden ───────────────────────────────────────────────── */
$post = get_page_by_path( $SLUG, OBJECT, 'post' );
if ( ! $post ) {
	done( "ABBRUCH: Beitrag mit Slug «{$SLUG}» nicht gefunden — nichts geändert." );
}
$post_id = $post->ID;

/* ── Bilddatei vorhanden? ─────────────────────────────────────────── */
$uploads = wp_get_upload_dir();
$rel     = $SUBDIR . '/' . $FILE;                   // relativ zum uploads-Basisdir
$abs     = trailingslashit( $uploads['basedir'] ) . $rel;
$url     = trailingslashit( $uploads['baseurl'] ) . $rel;
if ( ! file_exists( $abs ) ) {
	done( "ABBRUCH: Bilddatei fehlt unter uploads/{$rel} — zuerst rsync ausführen." );
}

/* ── Anhang idempotent anlegen/wiederverwenden ────────────────────── */
$existing = get_posts( array(
	'post_type'      => 'attachment',
	'post_status'    => 'inherit',
	'posts_per_page' => 1,
	'fields'         => 'ids',
	'meta_key'       => '_wp_attached_file',
	'meta_value'     => $rel,
) );

if ( $existing ) {
	$att_id = (int) $existing[0];
	$att_note = "Anhang wiederverwendet (ID {$att_id})";
} else {
	$att_id = wp_insert_attachment( array(
		'post_mime_type' => 'image/jpeg',
		'post_title'     => sanitize_file_name( pathinfo( $FILE, PATHINFO_FILENAME ) ),
		'post_content'   => '',
		'post_status'    => 'inherit',
		'guid'           => $url,
	), $abs, $post_id, true );
	if ( is_wp_error( $att_id ) || ! $att_id ) {
		done( 'ABBRUCH: wp_insert_attachment fehlgeschlagen — nichts geändert.' );
	}
	update_post_meta( $att_id, '_wp_attachment_image_alt', $ALT );
	wp_update_attachment_metadata( $att_id, wp_generate_attachment_metadata( $att_id, $abs ) );
	$att_note = "Neuer Anhang angelegt (ID {$att_id})";
}

/* ── Beitragsbild setzen ──────────────────────────────────────────── */
$old_id   = (int) get_post_thumbnail_id( $post_id );
$old_file = $old_id ? get_post_meta( $old_id, '_wp_attached_file', true ) : '(keines)';

if ( $old_id === $att_id ) {
	done( "SKIP: Beitragsbild ist bereits Anhang {$att_id} ({$rel}) — nichts geändert." );
}

set_post_thumbnail( $post_id, $att_id );

done(
	"OK: Beitragsbild umgestellt.\n" .
	"  Beitrag:  ID {$post_id}  ({$SLUG})\n" .
	"  {$att_note}\n" .
	"  alt:  ID {$old_id}  ({$old_file})\n" .
	"  neu:  ID {$att_id}  ({$rel})\n" .
	"  URL:  {$url}"
);
