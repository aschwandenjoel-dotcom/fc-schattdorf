<?php
/**
 * Einmal-Skript: 3. Mannschaft – neuer Teamsponsor Feritec AG.
 *
 * Hintergrund: Auf Hostpoint ist MySQL von der SSH-Shell aus nicht
 * erreichbar — nur Web-Prozesse dürfen zur DB. Dieses Skript wird
 * daher kurzzeitig in den Webroot gelegt, per HTTPS mit Token
 * aufgerufen und danach gelöscht (löscht sich zusätzlich selbst).
 *
 * Inhalt:
 *   A) Dateien prüfen (Mannschaftsfoto und Feritec-Logo müssen in
 *      uploads/2026/06 liegen — das Deploy-Skript lädt sie vorher hoch)
 *   B) 3. Mannschaft: Team-Sponsoren neu «Feritec AG» als alleiniger
 *      Sponsor — «Binary One» faellt weg
 *
 * Das neue Mannschaftsfoto steckt in der Vorlage (page-3mannschaft.php),
 * nicht in der DB — dafür ist hier nichts zu tun.
 *
 * Schutz gegen Überschreiben von Redaktions-Arbeit: Teil B ersetzt nur,
 * wenn der bestehende Wert exakt dem erwarteten alten Stand entspricht.
 * Weicht er ab, meldet das Skript «ABBRUCH» und rührt nichts an — dann
 * mit &force=1 bewusst überschreiben.
 *
 * Idempotent: schon Erledigtes meldet «SKIP».
 * Probelauf ohne Schreiben:  ?token=…&dry=1
 */
if ( ! isset( $_GET['token'] ) || ! hash_equals( '__TOKEN__', (string) $_GET['token'] ) ) {
	http_response_code( 403 ); exit( 'forbidden' );
}

require __DIR__ . '/wp-load.php';

header( 'Content-Type: text/plain; charset=utf-8' );
set_time_limit( 300 );

$dry   = ! empty( $_GET['dry'] );
$force = ! empty( $_GET['force'] );
echo $dry ? "MODUS: Probelauf (es wird nichts geschrieben)\n\n" : "MODUS: Schreiben\n\n";

$fehler = 0;

/** Seite über ihren Pfad holen (Slug-Kette ab Wurzel). */
function fcs_seite( $pfad ) {
	$p = get_page_by_path( $pfad );
	return $p instanceof WP_Post ? $p : null;
}

/** Meta-Wert nur ersetzen, wenn er einem der erwarteten alten Werte entspricht.
    $alt_erwartet ist eine Liste, weil hier zwei Altstände in Frage kommen:
    der Live-Stand (nur Binary One) und der Zwischenstand eines früheren
    Laufs dieses Skripts, als Feritec noch zusätzlich zu Binary One kam. */
function fcs_ersetze_meta( $post_id, $key, array $alt_erwartet, $neu, $dry, $force ) {
	$norm = function ( $v ) { return str_replace( "\r\n", "\n", trim( (string) $v ) ); };
	$ist  = $norm( get_post_meta( $post_id, $key, true ) );
	$neu  = $norm( $neu );
	$alt_erwartet = array_map( $norm, $alt_erwartet );
	if ( $ist === $neu ) { echo "   SKIP – #{$post_id} {$key} steht bereits auf dem neuen Stand.\n"; return true; }
	if ( ! in_array( $ist, $alt_erwartet, true ) && ! $force ) {
		echo "   ABBRUCH – #{$post_id} {$key} ist «{$ist}», erwartet war einer von:\n"
		   . "             «" . implode( "» / «", $alt_erwartet ) . "»\n"
		   . "             Nichts geändert. Mit &force=1 trotzdem setzen.\n";
		return false;
	}
	echo $dry ? "   würde setzen: #{$post_id} {$key} -> «{$neu}»\n"
	          : "   gesetzt: #{$post_id} {$key} -> «{$neu}»\n";
	if ( ! $dry ) { update_post_meta( $post_id, $key, $neu ); }
	return true;
}

/* ══════════════════════════════════════════════════════════════════
   A) Dateien
   ══════════════════════════════════════════════════════════════════ */
echo "A) Dateien in uploads/2026/06\n";

$dateien = array(
	'FCS3_Web2627.jpg',   // Mannschaftsfoto Vorrunde 2026/27 (Trikots Feritec)
	'feritec-2026.png',   // Logo Feritec AG, aus dem Vektor-Logo von feritec.ch
);
$updir = wp_upload_dir();
$fehlt = array();
foreach ( $dateien as $d ) {
	if ( ! file_exists( $updir['basedir'] . '/2026/06/' . $d ) ) { $fehlt[] = $d; }
}
if ( $fehlt ) {
	echo "   FEHLER – diese Dateien fehlen: " . implode( ', ', $fehlt ) . "\n";
	echo "            Zuerst hochladen, dann dieses Skript erneut laufen lassen.\n";
	$fehler++;
} else {
	echo "   OK – beide Dateien sind da.\n";
}

/* ══════════════════════════════════════════════════════════════════
   B) 3. Mannschaft: Team-Sponsoren
   ══════════════════════════════════════════════════════════════════ */
echo "\nB) 3. Mannschaft – Team-Sponsoren\n";

$m3 = fcs_seite( 'aktive/3-mannschaft' );
if ( ! $m3 ) { $m3 = fcs_seite( '3-mannschaft' ); }
if ( ! $m3 ) {
	echo "   FEHLER – Seite nicht gefunden.\n";
	$fehler++;
} elseif ( $fehlt ) {
	echo "   ÜBERSPRUNGEN – ohne das Logo würde die Seite ein leeres Kästchen zeigen.\n";
} else {
	/* Feritec AG ist alleiniger Sponsor der 3. Mannschaft — Binary One
	   faellt damit weg (Rueckmeldung vom 05.09.2026). */
	$alt = array(
		'Binary One | sp-binary-one.jpg | https://www.binaryone.ch/',
		"Feritec AG | feritec-2026.png | https://www.feritec.ch/\nBinary One | sp-binary-one.jpg | https://www.binaryone.ch/",
	);
	$neu = 'Feritec AG | feritec-2026.png | https://www.feritec.ch/';
	if ( ! fcs_ersetze_meta( $m3->ID, 'fcs_team_sponsoren', $alt, $neu, $dry, $force ) ) { $fehler++; }
}

/* ── Abschluss ──────────────────────────────────────────────────── */
if ( ! $dry ) {
	wp_cache_flush();
	@unlink( __FILE__ );
	echo "\nSkript hat sich selbst gelöscht.\n";
}
echo "\n" . ( 0 === $fehler ? "FERTIG – keine Fehler.\n" : "FERTIG – ABER {$fehler} Stelle(n) brauchen Aufmerksamkeit (siehe oben).\n" );
