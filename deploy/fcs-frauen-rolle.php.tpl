<?php
/**
 * Einmal-Skript: Rollen im Betreuerstab der Frauen-Teamseite.
 *
 * Auf Hostpoint ist MySQL nur aus Web-Prozessen erreichbar; dieses
 * Skript wird deshalb kurz in den Webroot gelegt, per HTTPS mit Token
 * aufgerufen und löscht sich danach selbst.
 *
 * Zwei Rückmeldungen vom 25.09.2026:
 *   · Dominique Scheiber ist nicht mehr Betreuerin, sondern
 *     «Verantwortliche Frauenfussball Uri» (von ihr selbst gemeldet).
 *   · Fabrice Arnold ist «Betreuer», nicht «Trainer».
 *
 * Geändert wird jeweils nur die erste Spalte der Zeile im Seitenfeld
 * «Betreuerstab» (fcs_team_staff der Seite «Frauen Team Uri»); Namen,
 * Bilder und die Reihenfolge bleiben.
 *
 * Schutz: jede Zeile muss vorher die erwartete alte Rolle tragen.
 * Weicht sie ab, meldet das Skript für diese Zeile ABBRUCH und rührt
 * sie nicht an.
 *
 * Idempotent: gesetzte Rollen melden «SKIP».
 * Probelauf ohne Schreiben:  ?token=…&dry=1
 */
if ( ! isset( $_GET['token'] ) || ! hash_equals( '__TOKEN__', (string) $_GET['token'] ) ) {
	http_response_code( 403 ); exit( 'forbidden' );
}

require __DIR__ . '/wp-load.php';
header( 'Content-Type: text/plain; charset=utf-8' );

$dry = ! empty( $_GET['dry'] );
echo $dry ? "MODUS: Probelauf (es wird nichts geschrieben)\n\n" : "MODUS: Schreiben\n\n";

/* Name => [alte Rolle, neue Rolle] */
$rollen = array(
	'Dominique Scheiber' => array( 'Betreuerin', 'Verantwortliche Frauenfussball Uri' ),
	'Fabrice Arnold'     => array( 'Trainer',    'Betreuer' ),
);

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
$geaendert = false;

foreach ( $rollen as $name => $r ) {
	list( $rolle_alt, $rolle_neu ) = $r;
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
			echo "ABBRUCH – {$name}: erwartet war «{$rolle_alt}», es steht «{$t[0]}».\n";
			echo "          Da hat jemand im Admin gearbeitet. Bitte dort von Hand\n";
			echo "          auf «{$rolle_neu}» setzen.\n";
			$fehler++;
			break;
		}
		$t[0] = $rolle_neu;
		$zeilen[ $i ] = implode( ' | ', $t );
		$geaendert = true;
		echo ( $dry ? 'würde setzen: ' : 'gesetzt: ' ) . "{$name}: «{$rolle_alt}» -> «{$rolle_neu}»\n";
		break;
	}
	if ( ! $treffer ) {
		echo "FEHLER – {$name} steht nicht im Betreuerstab der Seite.\n";
		$fehler++;
	}
}

if ( $geaendert && ! $dry ) {
	update_post_meta( $seite->ID, 'fcs_team_staff', implode( "\n", $zeilen ) );
}

if ( ! $dry ) {
	wp_cache_flush();
	@unlink( __FILE__ );
	echo "\nSkript hat sich selbst gelöscht.\n";
}
echo "\n" . ( 0 === $fehler ? "FERTIG – keine Fehler.\n" : "FERTIG – ABER {$fehler} Stelle(n) brauchen Aufmerksamkeit (siehe oben).\n" );
