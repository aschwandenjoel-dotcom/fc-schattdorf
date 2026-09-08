<?php
/**
 * Einmal-Skript: Seite «Liveticker» (/liveticker/) anlegen.
 *
 * Hintergrund: Auf Hostpoint ist MySQL von der SSH-Shell aus nicht
 * erreichbar — nur Web-Prozesse dürfen zur DB. Dieses Skript wird
 * daher kurzzeitig in den Webroot gelegt, per HTTPS mit Token
 * aufgerufen und danach gelöscht (löscht sich zusätzlich selbst).
 *
 * Legt die Seite mit der Vorlage page-liveticker.php an (Slug liveticker,
 * kein Elternteil, für Suchmaschinen «noindex» — es ist eine
 * Weiterleitungsseite). Das Seitenfeld «Link zum aktuellen Ticker» bleibt
 * leer: der bisher fest verdrahtete Ticker war ein längst gespieltes
 * Spiel; die Redaktion setzt vor dem nächsten Match den neuen Link.
 *
 * Idempotent: existiert die Seite, werden nur Vorlage und noindex geprüft.
 * Probelauf ohne Schreiben:  ?token=…&dry=1
 */
if ( ! isset( $_GET['token'] ) || ! hash_equals( '__TOKEN__', (string) $_GET['token'] ) ) {
	http_response_code( 403 ); exit( 'forbidden' );
}

require __DIR__ . '/wp-load.php';

header( 'Content-Type: text/plain; charset=utf-8' );
$dry = ! empty( $_GET['dry'] );
echo $dry ? "MODUS: Probelauf (es wird nichts geschrieben)\n\n" : "MODUS: Schreiben\n\n";

$TPL = 'page-liveticker.php';
if ( ! file_exists( get_stylesheet_directory() . '/' . $TPL ) ) {
	echo "ABBRUCH – {$TPL} liegt nicht im Theme. Zuerst den Theme-Code deployen.\n";
	exit;
}

$seite = get_page_by_path( 'liveticker' );
if ( $seite && 'trash' === $seite->post_status ) {
	echo "HINWEIS – Seite #{$seite->ID} liegt im Papierkorb; wird wiederhergestellt.\n";
	if ( ! $dry ) { wp_untrash_post( $seite->ID ); $seite = get_post( $seite->ID ); }
}

if ( ! $seite ) {
	if ( $dry ) {
		echo "würde anlegen: Seite «Liveticker», Slug liveticker, Vorlage {$TPL}, noindex\n";
	} else {
		$id = wp_insert_post( array(
			'post_type'   => 'page',
			'post_status' => 'publish',
			'post_title'  => 'Liveticker',
			'post_name'   => 'liveticker',
			'post_content' => '',
		), true );
		if ( is_wp_error( $id ) ) { echo 'FEHLER: ' . $id->get_error_message() . "\n"; exit; }
		update_post_meta( $id, '_wp_page_template', $TPL );
		update_post_meta( $id, '_yoast_wpseo_meta-robots-noindex', '1' );
		update_post_meta( $id, 'fcs_lt_url', '' );
		echo "angelegt: Seite #{$id} /liveticker/ mit Vorlage {$TPL}, noindex\n";
	}
} else {
	echo "SKIP – Seite #{$seite->ID} /liveticker/ existiert (Status {$seite->post_status}).\n";
	foreach ( array( '_wp_page_template' => $TPL, '_yoast_wpseo_meta-robots-noindex' => '1' ) as $k => $soll ) {
		$ist = get_post_meta( $seite->ID, $k, true );
		if ( $ist === $soll ) { echo "   ok   {$k} = {$soll}\n"; continue; }
		if ( $dry ) { echo "   würde {$k}: «{$ist}» -> «{$soll}»\n"; }
		else { update_post_meta( $seite->ID, $k, $soll ); echo "   SET  {$k} = {$soll}\n"; }
	}
	echo '   Link zum aktuellen Ticker: ' . ( '' !== trim( (string) get_post_meta( $seite->ID, 'fcs_lt_url', true ) ) ? 'gesetzt' : 'leer (Hinweisseite)' ) . "\n";
}

if ( ! $dry ) {
	delete_option( 'rewrite_rules' );
	@unlink( __FILE__ );
	echo "\nFertig. Skript hat sich selbst gelöscht.\n";
} else {
	echo "\nProbelauf beendet – nichts geschrieben. Skript bleibt liegen.\n";
}
