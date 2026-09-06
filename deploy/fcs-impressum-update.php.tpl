<?php
/**
 * Einmal-Skript: Impressum — Webdesign-Angabe auf «Urinet Aschwanden».
 *
 * Hintergrund: Auf Hostpoint ist MySQL von der SSH-Shell aus nicht
 * erreichbar — nur Web-Prozesse dürfen zur DB. Dieses Skript wird
 * daher kurzzeitig in den Webroot gelegt, per HTTPS mit Token
 * aufgerufen und danach gelöscht (löscht sich zusätzlich selbst).
 *
 * Ersetzt im Gutenberg-Inhalt der Seite /impressum/ exakt den
 * Webdesign-Absatz. Fehlt der erwartete alte Absatz (Seite inzwischen im
 * Admin geändert), bricht das Skript ab statt zu raten. wp_update_post
 * legt eine Revision an. Idempotent: schon Erledigtes meldet «SKIP».
 * Probelauf ohne Schreiben:  ?token=…&dry=1
 */
if ( ! isset( $_GET['token'] ) || ! hash_equals( '__TOKEN__', (string) $_GET['token'] ) ) {
	http_response_code( 403 ); exit( 'forbidden' );
}

require __DIR__ . '/wp-load.php';

header( 'Content-Type: text/plain; charset=utf-8' );
$dry = ! empty( $_GET['dry'] );
echo $dry ? "MODUS: Probelauf (es wird nichts geschrieben)\n\n" : "MODUS: Schreiben\n\n";

/* Erwartete alte Fassungen (live: Original; lokal auch der Zwischenstand vom 05.09.) */
$alt = array(
	'<p>Urinet<br>Studenmätteli 2<br>6462 Seedorf<br>Onlineschaltung: August 2026</p>',
	'<p>Urinet Aschwanden<br>Studenmätteli 2<br>6462 Seedorf<br>Onlineschaltung: August 2026</p>',
);
$neu = '<p>Urinet Aschwanden<br>Studenmätteli 2<br>6462 Seedorf<br><a href="https://urinet.ch" target="_blank" rel="noopener">urinet.ch</a><br>Onlineschaltung: September 2026</p>';
$alt_stand = '<p><em>Stand: August 2026</em></p>';
$neu_stand = '<p><em>Stand: September 2026</em></p>';

$seite = get_page_by_path( 'impressum' );
$treffer = $seite ? array_values( array_filter( $alt, function ( $a ) use ( $seite ) { return false !== strpos( $seite->post_content, $a ); } ) ) : array();
if ( ! $seite ) {
	echo "FEHLER – Seite /impressum/ nicht gefunden.\n";
} elseif ( false !== strpos( $seite->post_content, $neu ) ) {
	echo "SKIP – Seite #{$seite->ID} trägt bereits die neue Webdesign-Angabe.\n";
} elseif ( ! $treffer ) {
	echo "ABBRUCH – Seite #{$seite->ID} enthält den erwarteten Webdesign-Absatz nicht mehr; von Hand im Admin anpassen.\n";
} elseif ( $dry ) {
	echo "würde Seite #{$seite->ID} ändern: Webdesign -> «Urinet Aschwanden, Studenmätteli 2, 6462 Seedorf, urinet.ch, Onlineschaltung: September 2026»; Stand -> September 2026.\n";
} else {
	$inhalt = str_replace( $treffer[0], $neu, $seite->post_content );
	$inhalt = str_replace( $alt_stand, $neu_stand, $inhalt );
	$r = wp_update_post( array( 'ID' => $seite->ID, 'post_content' => $inhalt ), true );
	echo is_wp_error( $r ) ? 'FEHLER: ' . $r->get_error_message() . "\n" : "geändert: Seite #{$seite->ID} (alte Fassung als Revision).\n";
}

if ( ! $dry ) {
	@unlink( __FILE__ );
	echo "\nFertig. Skript hat sich selbst gelöscht.\n";
} else {
	echo "\nProbelauf beendet – nichts geschrieben. Skript bleibt liegen.\n";
}
