<?php
/**
 * Einmal-Skript: Beitragsbild und Kategorie von «Bittere 2:3 Niederlage
 * gegen Hünenberg» auf den Stand der Quelle bringen.
 *
 * Hintergrund: Beim Import am 07.09.2026 hing der Beitrag auf
 * FCS_1_Team_Web.jpg und Kategorie «1. Mannschaft» — eine Fehl-
 * einschätzung. Die alte Vereinsseite bindet dort FCS_2_Web.jpg ein,
 * das Mannschaftsfoto der zweiten Mannschaft. Der Import folgt der
 * Quelle, also gehört beides zurückgesetzt.
 *
 * Das Import-Skript selbst kann das nicht: es überspringt Beiträge,
 * deren Slug schon existiert. Deshalb dieses gezielte Skript.
 *
 * Es setzt dreierlei:
 *   - Beitragsbild auf den Anhang zu uploads/2026/09/FCS_2_Web.jpg
 *   - den wp:image-Block im Inhalt auf dasselbe Bild
 *   - Kategorie «2. Mannschaft» statt «1. Mannschaft»
 *
 * Idempotent: steht das Bild schon richtig, meldet es «SKIP».
 * Probelauf ohne Schreiben:  ?token=…&dry=1
 */
if ( ! isset( $_GET['token'] ) || ! hash_equals( '__TOKEN__', (string) $_GET['token'] ) ) {
	http_response_code( 403 ); exit( 'forbidden' );
}

require __DIR__ . '/wp-load.php';

header( 'Content-Type: text/plain; charset=utf-8' );
set_time_limit( 120 );

$dry = ! empty( $_GET['dry'] );
echo $dry ? "MODUS: Probelauf (es wird nichts geschrieben)\n\n" : "MODUS: Schreiben\n\n";

/**
 * Korrigiert den Beitrag. Als Funktion, damit jeder Abbruch ein
 * schlichtes return ist — das Löschen am Ende läuft trotzdem.
 */
function fcs_1577_korrigieren( $dry ) {

	$slug     = 'bittere-2-3-niederlage-gegen-huenenberg';
	$datei    = '2026/09/FCS_2_Web.jpg';
	$kat_neu  = '2. Mannschaft';

	$treffer = get_posts( array(
		'post_type' => 'post', 'post_status' => 'any',
		'name' => $slug, 'posts_per_page' => 1, 'fields' => 'ids',
	) );
	if ( ! $treffer ) {
		echo "FEHLER – Beitrag «{$slug}» nicht gefunden.\n";
		return;
	}
	$id = (int) $treffer[0];
	echo "Beitrag: #{$id}\n";

	/* Anhang zu FCS_2_Web.jpg — der liegt seit dem ersten Nachtrag vor. */
	$anhang = get_posts( array(
		'post_type' => 'attachment', 'post_status' => 'inherit', 'posts_per_page' => 1,
		'meta_key' => '_wp_attached_file', 'meta_value' => $datei, 'fields' => 'ids',
	) );
	if ( ! $anhang ) {
		echo "FEHLER – kein Anhang zu {$datei}; nichts geändert.\n";
		return;
	}
	$bild_id  = (int) $anhang[0];
	$bild_url = wp_get_attachment_url( $bild_id );
	echo "Bild:    #{$bild_id}  {$bild_url}\n\n";

	$aktuell = (int) get_post_thumbnail_id( $id );
	$inhalt  = get_post_field( 'post_content', $id );
	$kat     = get_term_by( 'name', $kat_neu, 'category' );

	$bild_ok = ( $aktuell === $bild_id ) && false === strpos( $inhalt, 'FCS_1_Team_Web' );
	$kat_ok  = $kat && has_term( (int) $kat->term_id, 'category', $id );

	if ( $bild_ok && $kat_ok ) {
		echo "SKIP – Bild und Kategorie stehen bereits richtig.\n";
		return;
	}
	if ( ! $kat ) {
		echo "FEHLER – Kategorie «{$kat_neu}» existiert nicht; nichts geändert.\n";
		return;
	}

	/* Den Bildblock als Ganzes ersetzen – so bleibt die Block-Struktur
	   gültig, statt nur Zeichenketten im Markup zu tauschen. */
	$block = '<!-- wp:image {"id":' . $bild_id . ',"sizeSlug":"large","linkDestination":"none"} -->' . "\n"
		. '<figure class="wp-block-image size-large"><img src="' . esc_url( $bild_url )
		. '" alt="' . esc_attr( get_the_title( $id ) ) . '" class="wp-image-' . $bild_id . '" /></figure>' . "\n"
		. '<!-- /wp:image -->';
	$neu = preg_replace( '#<!-- wp:image .*?<!-- /wp:image -->#s', $block, $inhalt, 1, $ersetzt );

	echo "   Beitragsbild:  #{$aktuell} -> #{$bild_id}\n";
	echo "   Bildblock:     " . ( $ersetzt ? 'wird ersetzt' : 'KEINER GEFUNDEN' ) . "\n";
	echo "   Kategorie:     -> «{$kat_neu}»\n";

	if ( ! $ersetzt ) {
		echo "\nABBRUCH – kein wp:image-Block im Inhalt; von Hand im Admin prüfen.\n";
		return;
	}
	if ( $dry ) {
		echo "\nProbelauf – nichts geschrieben.\n";
		return;
	}

	set_post_thumbnail( $id, $bild_id );
	wp_update_post( array( 'ID' => $id, 'post_content' => $neu ) );
	wp_set_post_terms( $id, array( (int) $kat->term_id ), 'category', false );
	clean_post_cache( $id );

	$k_inhalt = get_post_field( 'post_content', $id );
	if ( (int) get_post_thumbnail_id( $id ) === $bild_id
	  && false === strpos( $k_inhalt, 'FCS_1_Team_Web' )
	  && has_term( (int) $kat->term_id, 'category', $id ) ) {
		echo "\nOK – Bild und Kategorie geschrieben und zurückgelesen.\n";
	} else {
		echo "\nFEHLER – der zurückgelesene Stand passt nicht. Bitte im Admin prüfen.\n";
	}
}

fcs_1577_korrigieren( $dry );

/* ── Selbst löschen ─────────────────────────────────────────────── */
if ( ! $dry ) {
	@unlink( __FILE__ );
	echo "\nSkript hat sich selbst gelöscht.\n";
}
