<?php
/**
 * Einmal-Skript: Schiedsrichter-Seite auf den IFV-Stand vom 08.08.2026.
 *
 * Hintergrund: Auf Hostpoint ist MySQL von der SSH-Shell aus nicht
 * erreichbar — nur Web-Prozesse dürfen zur DB. Dieses Skript wird
 * daher kurzzeitig in den Webroot gelegt, per HTTPS mit Token
 * aufgerufen und danach gelöscht (löscht sich zusätzlich selbst).
 *
 * Es macht genau zwei Dinge:
 *   A) legt zwei neue Personen im Bereich «schiedsrichter» an
 *      (Lucas Martins Ferreira, Leon Ziegler – beide «SR – Anfänger»)
 *   B) setzt das Seitenfeld fcs_sr_spielleiter der Seite
 *      «Schiedsrichter» auf die neue Spielleiter-Liste
 *      (neu: Tresch Fabio, Zamuner Alessandro;
 *       entfällt: Küttel Thomas, Zamuner Sandro)
 *
 * Schutz gegen Überschreiben von Redaktions-Arbeit: Teil B schreibt nur,
 * wenn das Feld noch exakt den erwarteten alten Wert enthält. Weicht es
 * ab (jemand hat es inzwischen im Admin gepflegt), meldet das Skript
 * das und rührt nichts an — dann mit &force=1 bewusst überschreiben.
 *
 * Idempotent: schon Erledigtes meldet «SKIP».
 * Probelauf ohne Schreiben:  ?token=…&dry=1
 */
if ( ! isset( $_GET['token'] ) || ! hash_equals( '__TOKEN__', (string) $_GET['token'] ) ) {
	http_response_code( 403 ); exit( 'forbidden' );
}

require __DIR__ . '/wp-load.php';

header( 'Content-Type: text/plain; charset=utf-8' );
set_time_limit( 120 );

$dry   = ! empty( $_GET['dry'] );
$force = ! empty( $_GET['force'] );
echo $dry ? "MODUS: Probelauf (es wird nichts geschrieben)\n\n" : "MODUS: Schreiben\n\n";

$IFV_LINK = 'http://www.ifv.ch/Innerschweizerischer-Fussballverband/Vereine-IFV/Verein-IFV.aspx/v-329/a-sr/';

/* ── A) Neue Schiedsrichter ─────────────────────────────────────── */
echo "A) Personen (Bereich «schiedsrichter»)\n";

$neu = array(
	array( 'name' => 'Lucas Martins Ferreira', 'rolle' => 'SR – Anfänger', 'order' => 60 ),
	array( 'name' => 'Leon Ziegler',           'rolle' => 'SR – Anfänger', 'order' => 70 ),
);

foreach ( $neu as $p ) {
	/* Gibt es die Person schon? (Titelvergleich über alle Personen) */
	$vorhanden = get_posts( array(
		'post_type'      => 'fcs_person',
		'post_status'    => array( 'publish', 'draft', 'pending' ),
		'posts_per_page' => -1,
		'title'          => $p['name'],
		'fields'         => 'ids',
	) );

	if ( $vorhanden ) {
		echo "   SKIP – «{$p['name']}» existiert bereits (#" . implode( ', #', $vorhanden ) . ").\n";
		continue;
	}

	if ( $dry ) {
		echo "   würde anlegen: «{$p['name']}» / {$p['rolle']} / Reihenfolge {$p['order']}\n";
		continue;
	}

	$id = wp_insert_post( array(
		'post_type'   => 'fcs_person',
		'post_status' => 'publish',
		'post_title'  => $p['name'],
		'menu_order'  => $p['order'],
	), true );

	if ( is_wp_error( $id ) ) {
		echo "   FEHLER bei «{$p['name']}»: " . $id->get_error_message() . "\n";
		continue;
	}

	update_post_meta( $id, 'fcs_pe_bereich', 'schiedsrichter' );
	update_post_meta( $id, 'fcs_pe_rolle', $p['rolle'] );
	update_post_meta( $id, 'fcs_pe_link', $IFV_LINK );
	echo "   angelegt: #{$id} «{$p['name']}» / " . get_post_meta( $id, 'fcs_pe_rolle', true ) . "\n";
}

/* ── B) Spielleiter-Liste ───────────────────────────────────────── */
echo "\nB) Seitenfeld fcs_sr_spielleiter\n";

$seiten = get_posts( array(
	'post_type'      => 'page',
	'post_status'    => 'publish',
	'posts_per_page' => 1,
	'meta_key'       => '_wp_page_template',
	'meta_value'     => 'page-schiedsrichter.php',
	'fields'         => 'ids',
) );

if ( ! $seiten ) {
	echo "   FEHLER – keine Seite mit der Vorlage page-schiedsrichter.php gefunden.\n";
} else {
	$seite = (int) $seiten[0];

	$alt_erwartet = implode( "\n", array(
		'Baumann Damian', 'Bissig Ivo', 'Küttel Thomas', 'Leu Nicolas',
		'Lustenberger Thomas', 'Marxen Henning', 'Scheiber Bernhard',
		'Scheiber René', 'Zamuner Sandro', 'Zgraggen André', 'Zwyssig Sandro',
	) );
	$neu_wert = implode( "\n", array(
		'Baumann Damian', 'Bissig Ivo', 'Leu Nicolas', 'Lustenberger Thomas',
		'Marxen Henning', 'Scheiber Bernhard', 'Scheiber René', 'Tresch Fabio',
		'Zamuner Alessandro', 'Zgraggen André', 'Zwyssig Sandro',
	) );

	$norm = function ( $v ) { return trim( str_replace( "\r\n", "\n", (string) $v ) ); };
	$ist  = $norm( get_post_meta( $seite, 'fcs_sr_spielleiter', true ) );

	if ( $ist === $norm( $neu_wert ) ) {
		echo "   SKIP – Seite #{$seite} trägt bereits die neue Liste.\n";
	} elseif ( '' !== $ist && $ist !== $norm( $alt_erwartet ) && ! $force ) {
		echo "   ABBRUCH – Seite #{$seite} enthält weder den erwarteten alten noch den neuen Wert.\n";
		echo "   Vermutlich wurde die Liste zwischenzeitlich im Admin gepflegt. Aktueller Inhalt:\n";
		echo "   ----\n   " . str_replace( "\n", "\n   ", $ist ) . "\n   ----\n";
		echo "   Bewusst überschreiben: denselben Aufruf mit &force=1 wiederholen.\n";
	} elseif ( $dry ) {
		echo "   würde Seite #{$seite} setzen auf:\n   " . str_replace( "\n", "\n   ", $neu_wert ) . "\n";
	} else {
		update_post_meta( $seite, 'fcs_sr_spielleiter', $neu_wert );
		echo "   gesetzt auf:\n   " . str_replace( "\n", "\n   ", $norm( get_post_meta( $seite, 'fcs_sr_spielleiter', true ) ) ) . "\n";
	}
}

if ( ! $dry ) {
	@unlink( __FILE__ );
	echo "\nFertig. Skript hat sich selbst gelöscht.\n";
} else {
	echo "\nProbelauf beendet – nichts geschrieben. Skript bleibt liegen.\n";
}
