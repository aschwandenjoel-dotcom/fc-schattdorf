<?php
/**
 * Einmal-Skript: Junioren-Organisation, Kommunikation & Social Media.
 *
 * Auf Hostpoint ist MySQL nur aus Web-Prozessen erreichbar; dieses
 * Skript wird deshalb kurz in den Webroot gelegt, per HTTPS mit Token
 * aufgerufen und löscht sich danach selbst.
 *
 * Rückmeldung vom 29.09.2026: Dominique Scheiber macht das Ämtli nicht
 * mehr, ihre Funktion «Kommunikation & Social Media» wird geteilt.
 *
 *   A) Dominique Scheiber in den Papierkorb — nur der Eintrag der
 *      Junioren-Organisation. Als «Verantwortliche Frauenfussball Uri»
 *      auf der Frauen-Teamseite bleibt sie; das steht in einem
 *      Seitenfeld und wird hier nicht angefasst.
 *   B) Joel Aschwanden neu, Rolle «Kommunikation», an ihrer Stelle
 *      (menu_order 50). Er erbt die Funktionsadresse
 *      kommunikation@fcschattdorf.ch — sie gehört zur Rolle, nicht zur
 *      Person, und wäre sonst nirgends mehr auf der Seite erreichbar.
 *      Porträt: sein Spielerbild der 1. Mannschaft.
 *   C) Marvin Burch neu, Rolle «Social Media», als erster der
 *      Social-Media-Gruppe (menu_order 65, vor May Van der Ven).
 *      Von ihm gibt es kein Foto — Silhouette, wie bei Linus Epp.
 *      Keine E-Mail, wie bei den übrigen Social-Media-Einträgen.
 *
 * Idempotent: bestehende Einträge werden am Namen erkannt («SKIP»),
 * ein zweiter Lauf ändert nichts.
 * Probelauf ohne Schreiben:  ?token=…&dry=1
 */
if ( ! isset( $_GET['token'] ) || ! hash_equals( '__TOKEN__', (string) $_GET['token'] ) ) {
	http_response_code( 403 ); exit( 'forbidden' );
}

require __DIR__ . '/wp-load.php';
header( 'Content-Type: text/plain; charset=utf-8' );

$dry = ! empty( $_GET['dry'] );
echo $dry ? "MODUS: Probelauf (es wird nichts geschrieben)\n\n" : "MODUS: Schreiben\n\n";

$bereich = 'junioren-organisation';
$fehler  = 0;
$updir   = wp_upload_dir();

/** Person dieses Bereichs am Namen finden (beliebiger Status). */
function fcs_orga_person( $name, $bereich ) {
	$treffer = get_posts( array(
		'post_type'      => 'fcs_person',
		'post_status'    => array( 'publish', 'draft', 'pending', 'private', 'trash' ),
		'posts_per_page' => -1,
		'title'          => $name,
	) );
	foreach ( $treffer as $t ) {
		if ( (string) get_post_meta( $t->ID, 'fcs_pe_bereich', true ) === $bereich ) { return $t; }
	}
	return null;
}

/* ── 0) Bilddateien müssen da sein ──────────────────────────────── */
echo "0) Bilddateien\n";
$noetig = array( 'Joel_Aschwanden.jpg', 'Silhouette_Male_v2.jpg' );
$fehlt  = array();
foreach ( $noetig as $b ) {
	if ( ! file_exists( $updir['basedir'] . '/2026/06/' . $b ) ) { $fehlt[] = $b; }
}
if ( $fehlt ) {
	echo '   FEHLER – diese Dateien fehlen: ' . implode( ', ', $fehlt ) . "\n";
	echo "\nFERTIG – ABER 1 Stelle braucht Aufmerksamkeit (siehe oben).\n";
	exit;
}
echo "   OK – beide Dateien liegen in uploads/2026/06/.\n";

/* ── A) Dominique Scheiber in den Papierkorb ────────────────────── */
echo "\nA) Dominique Scheiber\n";

$alt = fcs_orga_person( 'Dominique Scheiber', $bereich );
if ( ! $alt ) {
	echo "   FEHLER – kein Eintrag «Dominique Scheiber» im Bereich «{$bereich}».\n";
	$fehler++;
} elseif ( 'trash' === $alt->post_status ) {
	echo "   SKIP – liegt bereits im Papierkorb (#{$alt->ID}).\n";
} else {
	$rolle = (string) get_post_meta( $alt->ID, 'fcs_pe_rolle', true );
	echo "   Gefunden: #{$alt->ID}, Rolle «{$rolle}»\n";
	if ( 'Kommunikation & Social Media' !== $rolle ) {
		echo "   ABBRUCH – erwartet war die Rolle «Kommunikation & Social Media».\n";
		echo "             Da hat jemand im Admin gearbeitet — bitte dort prüfen.\n";
		$fehler++;
	} else {
		echo '   ' . ( $dry ? 'würde in den Papierkorb legen: ' : 'in den Papierkorb gelegt: ' ) . "#{$alt->ID}\n";
		if ( ! $dry && ! wp_trash_post( $alt->ID ) ) {
			echo "   FEHLER – wp_trash_post() hat nicht geklappt.\n";
			$fehler++;
		}
	}
}

/* ── B) und C) Die beiden neuen Einträge ────────────────────────── */
$neu = array(
	array(
		'name'  => 'Joel Aschwanden',
		'rolle' => 'Kommunikation',
		'bild'  => 'Joel_Aschwanden.jpg',
		'email' => 'kommunikation@fcschattdorf.ch',
		'order' => 50,
	),
	array(
		'name'  => 'Marvin Burch',
		'rolle' => 'Social Media',
		'bild'  => 'Silhouette_Male_v2.jpg',
		'email' => '',
		'order' => 65,
	),
);

foreach ( $neu as $n ) {
	echo "\n{$n['name']} – {$n['rolle']}\n";
	$da = fcs_orga_person( $n['name'], $bereich );
	if ( $da && 'trash' !== $da->post_status ) {
		echo "   SKIP – steht bereits im Bereich (#{$da->ID}).\n";
		continue;
	}
	if ( $dry ) {
		echo "   würde anlegen: Rolle «{$n['rolle']}», Bild {$n['bild']}"
		   . ( $n['email'] ? ", E-Mail {$n['email']}" : ', ohne E-Mail' )
		   . ", Position {$n['order']}\n";
		continue;
	}
	$id = wp_insert_post( array(
		'post_type'   => 'fcs_person',
		'post_status' => 'publish',
		'post_title'  => $n['name'],
		'menu_order'  => (int) $n['order'],
		'meta_input'  => array(
			'fcs_pe_bereich' => $bereich,
			'fcs_pe_rolle'   => $n['rolle'],
			'fcs_pe_email'   => $n['email'],
			'fcs_pe_tel'     => '',
			'fcs_pe_bild'    => $n['bild'],
			'fcs_pe_link'    => '',
		),
	), true );
	if ( is_wp_error( $id ) ) {
		echo '   FEHLER: ' . $id->get_error_message() . "\n";
		$fehler++;
		continue;
	}
	echo "   angelegt: #{$id}, Position {$n['order']}\n";
}

/* ── Abschluss ──────────────────────────────────────────────────── */
if ( ! $dry ) {
	wp_cache_flush();
	@unlink( __FILE__ );
	echo "\nSkript hat sich selbst gelöscht.\n";
}
echo "\n" . ( 0 === $fehler ? "FERTIG – keine Fehler.\n" : "FERTIG – ABER {$fehler} Stelle(n) brauchen Aufmerksamkeit (siehe oben).\n" );
