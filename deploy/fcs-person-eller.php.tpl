<?php
/**
 * Einmal-Skript: Tamara Eller aus der Junioren-Organisation entfernen.
 *
 * Auf Hostpoint ist MySQL nur aus Web-Prozessen erreichbar; dieses
 * Skript wird deshalb kurz in den Webroot gelegt, per HTTPS mit Token
 * aufgerufen und löscht sich danach selbst.
 *
 * Rückmeldung von ihr selbst (29.09.2026): sie hat das Ämtli «Fotos»
 * nicht mehr. Der Eintrag ist ein fcs_person-Beitrag (Bereich
 * «junioren-organisation», Rolle «Fotos») und wird in den
 * **Papierkorb** gelegt — nicht endgültig gelöscht, damit die
 * Redaktion ihn im Admin wiederherstellen kann.
 *
 * Aline Kempf trägt dieselbe Rolle; die Rubrik «Fotos» auf
 * /junioren/junioren-organisation/ bleibt also bestehen.
 *
 * Ihr Name steht ausserdem in drei Spielberichten der Frauen als
 * Torschützin — das ist Fliesstext und bleibt unberührt.
 *
 * Schutz: Titel, Bereich und Rolle müssen stimmen, sonst ABBRUCH.
 * Idempotent: liegt der Eintrag schon im Papierkorb, meldet es «SKIP».
 * Probelauf ohne Schreiben:  ?token=…&dry=1
 */
if ( ! isset( $_GET['token'] ) || ! hash_equals( '__TOKEN__', (string) $_GET['token'] ) ) {
	http_response_code( 403 ); exit( 'forbidden' );
}

require __DIR__ . '/wp-load.php';
header( 'Content-Type: text/plain; charset=utf-8' );

$dry = ! empty( $_GET['dry'] );
echo $dry ? "MODUS: Probelauf (es wird nichts geschrieben)\n\n" : "MODUS: Schreiben\n\n";

$name    = 'Tamara Eller';
$bereich = 'junioren-organisation';
$rolle   = 'Fotos';
$fehler  = 0;

$treffer = get_posts( array(
	'post_type'      => 'fcs_person',
	'post_status'    => array( 'publish', 'draft', 'pending', 'private' ),
	'posts_per_page' => -1,
	'title'          => $name,
) );

if ( ! $treffer ) {
	/* Schon im Papierkorb? Dann ist nichts mehr zu tun. */
	$weg = get_posts( array( 'post_type' => 'fcs_person', 'post_status' => 'trash', 'posts_per_page' => -1, 'title' => $name ) );
	if ( $weg ) {
		echo "SKIP – «{$name}» liegt bereits im Papierkorb (#{$weg[0]->ID}).\n";
		echo "\nFERTIG – keine Fehler.\n";
		if ( ! $dry ) { @unlink( __FILE__ ); echo "Skript hat sich selbst gelöscht.\n"; }
		exit;
	}
	echo "FEHLER – kein Personen-Eintrag «{$name}» gefunden.\n";
	echo "\nFERTIG – ABER 1 Stelle braucht Aufmerksamkeit (siehe oben).\n";
	exit;
}

foreach ( $treffer as $person ) {
	$ist_bereich = (string) get_post_meta( $person->ID, 'fcs_pe_bereich', true );
	$ist_rolle   = (string) get_post_meta( $person->ID, 'fcs_pe_rolle', true );
	echo "Gefunden: #{$person->ID} «{$person->post_title}», Bereich «{$ist_bereich}», Rolle «{$ist_rolle}»\n";

	if ( $ist_bereich !== $bereich || $ist_rolle !== $rolle ) {
		echo "   ABBRUCH – erwartet war Bereich «{$bereich}» und Rolle «{$rolle}».\n";
		echo "             Da hat jemand im Admin gearbeitet — bitte dort von Hand prüfen.\n";
		$fehler++;
		continue;
	}
	echo '   ' . ( $dry ? 'würde in den Papierkorb legen: ' : 'in den Papierkorb gelegt: ' ) . "#{$person->ID}\n";
	if ( ! $dry ) {
		if ( ! wp_trash_post( $person->ID ) ) {
			echo "   FEHLER – wp_trash_post() hat nicht geklappt.\n";
			$fehler++;
		}
	}
}

if ( ! $dry ) {
	wp_cache_flush();
	@unlink( __FILE__ );
	echo "\nSkript hat sich selbst gelöscht.\n";
}
echo "\n" . ( 0 === $fehler ? "FERTIG – keine Fehler.\n" : "FERTIG – ABER {$fehler} Stelle(n) brauchen Aufmerksamkeit (siehe oben).\n" );
