<?php
/**
 * Einmal-Skript: Rolle von Dominique Scheiber auf der Frauen-Teamseite.
 *
 * Auf Hostpoint ist MySQL nur aus Web-Prozessen erreichbar; dieses
 * Skript wird deshalb kurz in den Webroot gelegt, per HTTPS mit Token
 * aufgerufen und löscht sich danach selbst.
 *
 * Rückmeldung von ihr selbst (25.09.2026): sie ist nicht mehr
 * Betreuerin, sondern «Verantwortliche Frauenfussball Uri». Geändert
 * wird nur die erste Spalte ihrer Zeile im Seitenfeld «Betreuerstab»
 * (fcs_team_staff der Seite «Frauen Team Uri»); Name und Bild bleiben,
 * Fabrice Arnold als Trainer bleibt unberührt.
 *
 * Schutz: die Zeile muss vorher genau so dastehen. Weicht sie ab,
 * meldet das Skript ABBRUCH und rührt nichts an.
 *
 * Idempotent: steht die neue Rolle schon da, meldet es «SKIP».
 * Probelauf ohne Schreiben:  ?token=…&dry=1
 */
if ( ! isset( $_GET['token'] ) || ! hash_equals( '__TOKEN__', (string) $_GET['token'] ) ) {
	http_response_code( 403 ); exit( 'forbidden' );
}

require __DIR__ . '/wp-load.php';
header( 'Content-Type: text/plain; charset=utf-8' );

$dry = ! empty( $_GET['dry'] );
echo $dry ? "MODUS: Probelauf (es wird nichts geschrieben)\n\n" : "MODUS: Schreiben\n\n";

$name      = 'Dominique Scheiber';
$rolle_alt = 'Betreuerin';
$rolle_neu = 'Verantwortliche Frauenfussball Uri';

$seite = get_page_by_path( 'aktive/frauen-uri-1' );
if ( ! $seite ) { $seite = get_page_by_path( 'frauen-uri-1' ); }
if ( ! $seite ) {
	$t     = get_posts( array( 'post_type' => 'page', 'post_status' => 'publish', 'name' => 'frauen-uri-1', 'posts_per_page' => 1 ) );
	$seite = $t ? $t[0] : null;
}
if ( ! $seite ) {
	echo "FEHLER – Seite «Frauen Team Uri» nicht gefunden.\n";
	exit;
}
echo "Seite: #{$seite->ID} «{$seite->post_title}»\n\n";

$ist    = str_replace( "\r\n", "\n", (string) get_post_meta( $seite->ID, 'fcs_team_staff', true ) );
$zeilen = explode( "\n", $ist );
$fehler = 0;
$treffer = false;

foreach ( $zeilen as $i => $zeile ) {
	$t = array_map( 'trim', explode( '|', $zeile ) );
	if ( count( $t ) < 2 || $t[1] !== $name ) { continue; }
	$treffer = true;
	if ( $t[0] === $rolle_neu ) {
		echo "SKIP – {$name} steht schon auf «{$rolle_neu}».\n";
		break;
	}
	if ( $t[0] !== $rolle_alt ) {
		echo "ABBRUCH – erwartet war die Rolle «{$rolle_alt}», es steht «{$t[0]}».\n";
		echo "          Da hat jemand im Admin gearbeitet. Bitte dort von Hand\n";
		echo "          auf «{$rolle_neu}» setzen.\n";
		$fehler++;
		break;
	}
	$t[0] = $rolle_neu;
	$zeilen[ $i ] = implode( ' | ', $t );
	echo ( $dry ? 'würde setzen: ' : 'gesetzt: ' ) . "{$name}: «{$rolle_alt}» -> «{$rolle_neu}»\n";
	if ( ! $dry ) { update_post_meta( $seite->ID, 'fcs_team_staff', implode( "\n", $zeilen ) ); }
	break;
}

if ( ! $treffer ) {
	echo "FEHLER – {$name} steht nicht im Betreuerstab der Seite.\n";
	$fehler++;
}

if ( ! $dry ) {
	wp_cache_flush();
	@unlink( __FILE__ );
	echo "\nSkript hat sich selbst gelöscht.\n";
}
echo "\n" . ( 0 === $fehler ? "FERTIG – keine Fehler.\n" : "FERTIG – ABER {$fehler} Stelle(n) brauchen Aufmerksamkeit (siehe oben).\n" );
