<?php
/**
 * Einmal-Skript: Termin «Ehren-/Freimitglieder und Sponsorenapéro»
 * von 24.04.2027 auf 10.04.2027 setzen.
 *
 * Auf Hostpoint ist MySQL nur aus Web-Prozessen erreichbar; dieses
 * Skript wird deshalb kurz in den Webroot gelegt, per HTTPS mit Token
 * aufgerufen und löscht sich danach selbst.
 *
 * Der Termin ist ein Eintrag des CPT fcs_event; das Datum steht im
 * Feld fcs_ev_datum (Format Y-m-d). Ort und Zeit bleiben unverändert
 * («Wird bekannt gegeben»). Das Datum kommt sonst nirgends vor —
 * geprüft über Postmeta, Seiteninhalte und Theme.
 *
 * Schutz: der Eintrag muss vorher auf dem erwarteten alten Datum
 * stehen. Weicht er ab (Redaktion hat im Admin gearbeitet), meldet das
 * Skript ABBRUCH und rührt nichts an.
 *
 * Idempotent: steht das neue Datum schon da, meldet es «SKIP».
 * Probelauf ohne Schreiben:  ?token=…&dry=1
 */
if ( ! isset( $_GET['token'] ) || ! hash_equals( '__TOKEN__', (string) $_GET['token'] ) ) {
	http_response_code( 403 ); exit( 'forbidden' );
}

require __DIR__ . '/wp-load.php';
header( 'Content-Type: text/plain; charset=utf-8' );

$dry = ! empty( $_GET['dry'] );
echo $dry ? "MODUS: Probelauf (es wird nichts geschrieben)\n\n" : "MODUS: Schreiben\n\n";

$titel = 'Ehren-/Freimitglieder und Sponsorenapéro';
$alt   = '2027-04-24';
$neu   = '2027-04-10';

$treffer = get_posts( array(
	'post_type'      => 'fcs_event',
	'post_status'    => 'publish',
	'posts_per_page' => -1,
	'title'          => $titel,
) );
if ( ! $treffer ) {
	/* Fallback: Titel kann im Admin leicht abweichen (Bindestrich, Schrägstrich). */
	$treffer = get_posts( array(
		'post_type'      => 'fcs_event',
		'post_status'    => 'publish',
		'posts_per_page' => -1,
		's'              => 'Sponsorenap',
	) );
}
if ( ! $treffer ) {
	echo "FEHLER – kein Termin «{$titel}» gefunden.\n";
	exit;
}
if ( count( $treffer ) > 1 ) {
	echo 'HINWEIS – ' . count( $treffer ) . " Termine passen auf die Suche:\n";
	foreach ( $treffer as $t ) {
		echo "          #{$t->ID} «{$t->post_title}» (" . get_post_meta( $t->ID, 'fcs_ev_datum', true ) . ")\n";
	}
}

$fehler = 0;
foreach ( $treffer as $ev ) {
	$ist = (string) get_post_meta( $ev->ID, 'fcs_ev_datum', true );
	echo "Termin #{$ev->ID} «{$ev->post_title}», Datum steht auf «{$ist}»\n";

	if ( $ist === $neu ) {
		echo "   SKIP – steht schon auf {$neu}.\n";
		continue;
	}
	if ( $ist !== $alt ) {
		echo "   ABBRUCH – erwartet war «{$alt}». Da hat jemand im Admin gearbeitet.\n";
		echo "             Bitte das Datum dort von Hand auf {$neu} setzen.\n";
		$fehler++;
		continue;
	}
	echo '   ' . ( $dry ? 'würde setzen: ' : 'gesetzt: ' ) . "{$alt} -> {$neu}\n";
	if ( ! $dry ) { update_post_meta( $ev->ID, 'fcs_ev_datum', $neu, $alt ); }
}

if ( ! $dry ) {
	wp_cache_flush();
	@unlink( __FILE__ );
	echo "\nSkript hat sich selbst gelöscht.\n";
}
echo "\n" . ( 0 === $fehler ? "FERTIG – keine Fehler.\n" : "FERTIG – ABER {$fehler} Stelle(n) brauchen Aufmerksamkeit (siehe oben).\n" );
