<?php
/**
 * Einmal-Skript: P-Nummer bei René Gnos auf /verein/vorstand/ entfernen.
 *
 * Auf Hostpoint ist MySQL nur aus Web-Prozessen erreichbar; dieses
 * Skript wird deshalb kurz in den Webroot gelegt, per HTTPS mit Token
 * aufgerufen und löscht sich danach selbst.
 *
 * Die Vorstandsseite hält die Kontaktangaben im Seiteninhalt
 * (Gutenberg-Absatz), nicht in einem Seitenfeld. René Gnos war der
 * einzige Eintrag mit Festnetznummer; alle anderen führen nur «M:».
 * Ersetzt wird genau «<br>P: 041 870 19 15» im Sportchef-Absatz.
 *
 * Schutz: der Absatz muss vorher genau so dastehen. Weicht er ab
 * (Redaktion hat im Admin gearbeitet), meldet das Skript ABBRUCH und
 * rührt nichts an.
 *
 * Idempotent: steht die Nummer schon nicht mehr da, meldet es «SKIP».
 * Probelauf ohne Schreiben:  ?token=…&dry=1
 */
if ( ! isset( $_GET['token'] ) || ! hash_equals( '__TOKEN__', (string) $_GET['token'] ) ) {
	http_response_code( 403 ); exit( 'forbidden' );
}

require __DIR__ . '/wp-load.php';
header( 'Content-Type: text/plain; charset=utf-8' );

$dry = ! empty( $_GET['dry'] );
echo $dry ? "MODUS: Probelauf (es wird nichts geschrieben)\n\n" : "MODUS: Schreiben\n\n";

$alt = '<strong>Sportchef</strong><br><a href="mailto:finanzen@fcschattdorf.ch">E-Mail</a><br>P: 041 870 19 15<br>M: 079 420 61 20';
$neu = '<strong>Sportchef</strong><br><a href="mailto:finanzen@fcschattdorf.ch">E-Mail</a><br>M: 079 420 61 20';

$seite = get_page_by_path( 'verein/vorstand' );
if ( ! $seite ) { $seite = get_page_by_path( 'vorstand' ); }
if ( ! $seite ) {
	echo "FEHLER – Seite «Vorstand» nicht gefunden.\n";
	exit;
}
echo "Seite: #{$seite->ID} «{$seite->post_title}»\n\n";

$inhalt = $seite->post_content;

if ( false === strpos( $inhalt, 'P: 041 870 19 15' ) ) {
	echo "SKIP – die P-Nummer steht nicht (mehr) im Seiteninhalt.\n";
	echo "\nFERTIG – keine Fehler.\n";
	if ( ! $dry ) { @unlink( __FILE__ ); echo "Skript hat sich selbst gelöscht.\n"; }
	exit;
}
if ( false === strpos( $inhalt, $alt ) ) {
	echo "ABBRUCH – der Sportchef-Absatz steht nicht so da wie erwartet.\n";
	echo "          Da hat jemand im Admin gearbeitet. Bitte die Zeile\n";
	echo "          «P: 041 870 19 15» dort von Hand entfernen.\n";
	echo "\nFERTIG – ABER 1 Stelle braucht Aufmerksamkeit (siehe oben).\n";
	exit;
}

$inhalt_neu = str_replace( $alt, $neu, $inhalt, $n );
echo ( $dry ? 'würde setzen: ' : 'gesetzt: ' ) . "{$n} Stelle(n) — «P: 041 870 19 15» entfernt.\n";

if ( ! $dry ) {
	wp_update_post( array( 'ID' => $seite->ID, 'post_content' => $inhalt_neu ) );
	wp_cache_flush();
	@unlink( __FILE__ );
	echo "Skript hat sich selbst gelöscht.\n";
}
echo "\nFERTIG – keine Fehler.\n";
