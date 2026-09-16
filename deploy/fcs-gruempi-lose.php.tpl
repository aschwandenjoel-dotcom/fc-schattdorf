<?php
/**
 * Einmal-Skript: Losnummern und Ziehungsprotokoll auf der
 * Grümpelturnier-Seite (13.09.2026).
 *
 * Hintergrund: Auf Hostpoint ist MySQL von der SSH-Shell aus nicht
 * erreichbar — nur Web-Prozesse dürfen zur DB. Dieses Skript wird
 * daher kurzzeitig in den Webroot gelegt, per HTTPS mit Token
 * aufgerufen und danach gelöscht (löscht sich zusätzlich selbst).
 *
 * Was es tut:
 *   A) Zwei PDFs als Mediathek-Einträge anlegen (damit die Redaktion
 *      sie findet): die gezogenen Losnummern (Ziehungsprotokoll in
 *      digitaler Form, übernommen von der alten Joomla-Seite) und das
 *      vom Notar beglaubigte Ziehungsprotokoll (Scan).
 *   B) Seitenfeld «Weitere Downloads» der Grümpelturnier-Seite füllen —
 *      die Vorlage zeigt daraus Download-Karten unter dem Reglement.
 *
 * Die Dateien überträgt das aufrufende Shell-Skript vorher per scp;
 * dieses Skript prüft nur noch, ob sie da sind.
 *
 * Idempotent: bestehende Anhänge werden erkannt, gesetzte Felder melden
 * «SKIP». Probelauf ohne Schreiben:  ?token=…&dry=1
 */
if ( ! isset( $_GET['token'] ) || ! hash_equals( '__TOKEN__', (string) $_GET['token'] ) ) {
	http_response_code( 403 ); exit( 'forbidden' );
}

require __DIR__ . '/wp-load.php';

header( 'Content-Type: text/plain; charset=utf-8' );
set_time_limit( 300 );

$dry = ! empty( $_GET['dry'] );
echo $dry ? "MODUS: Probelauf (es wird nichts geschrieben)\n\n" : "MODUS: Schreiben\n\n";

$fehler  = 0;
$updir   = wp_upload_dir();
$ordner  = '2026/06';
$basedir = $updir['basedir'] . '/' . $ordner . '/';
$baseurl = $updir['baseurl'] . '/' . $ordner . '/';

$pdfs = array(
	'Losnummern_Gruempi_2026.pdf'        => 'Gezogene Losnummern Grümpelturnier 2026',
	'Ziehungsprotokoll_Gruempi_2026.pdf' => 'Ziehungsprotokoll Grümpelturnier 2026 (beglaubigt)',
);

/* ── 0) Dateien müssen da sein ──────────────────────────────────── */
echo "0) Dateien\n";
$fehlt = array();
foreach ( array_keys( $pdfs ) as $datei ) {
	if ( ! file_exists( $basedir . $datei ) ) { $fehlt[] = $ordner . '/' . $datei; }
}
if ( $fehlt ) {
	echo '   FEHLER – diese Dateien fehlen: ' . implode( ', ', $fehlt ) . "\n";
	echo "\nFERTIG – ABER 1 Stelle braucht Aufmerksamkeit (siehe oben).\n";
	exit;
}
echo "   OK – beide PDFs sind da.\n";

/* ── A) Mediathek-Einträge ──────────────────────────────────────── */
echo "\nA) Mediathek\n";
foreach ( $pdfs as $datei => $titel ) {
	$da = get_posts( array(
		'post_type' => 'attachment', 'post_status' => 'inherit', 'posts_per_page' => 1, 'fields' => 'ids',
		'meta_key' => '_wp_attached_file', 'meta_value' => $ordner . '/' . $datei,
	) );
	if ( $da ) { echo "   SKIP – «{$titel}» gibt es schon (#{$da[0]}).\n"; continue; }
	if ( $dry ) { echo "   würde anlegen: «{$titel}» ({$datei})\n"; continue; }
	$id = wp_insert_attachment( array(
		'guid'           => $baseurl . $datei,
		'post_mime_type' => 'application/pdf',
		'post_title'     => $titel,
		'post_content'   => '',
		'post_status'    => 'inherit',
	), $basedir . $datei, 0, true );
	if ( is_wp_error( $id ) ) { echo '   FEHLER «' . $datei . '»: ' . $id->get_error_message() . "\n"; $fehler++; continue; }
	update_post_meta( $id, '_wp_attached_file', $ordner . '/' . $datei );
	echo "   angelegt: «{$titel}» (#{$id})\n";
}

/* ── B) Seitenfeld «Weitere Downloads» ──────────────────────────── */
echo "\nB) Grümpelturnier-Seite\n";
$seite = get_posts( array( 'post_type' => 'page', 'post_status' => 'publish', 'name' => 'gruempelturnier', 'posts_per_page' => 1 ) );
if ( ! $seite ) {
	echo "   FEHLER – Seite «gruempelturnier» nicht gefunden.\n";
	$fehler++;
} else {
	$seite = $seite[0];
	$soll  = 'Gezogene Losnummern 2026 | ' . $baseurl . 'Losnummern_Gruempi_2026.pdf | Ziehung vom Samstag, 20. Juni 2026 – alle 16 Gewinne mit Los-Nummer | Losverkauf' . "\n"
	       . 'Ziehungsprotokoll 2026, beglaubigt | ' . $baseurl . 'Ziehungsprotokoll_Gruempi_2026.pdf | Beglaubigt durch den Notar · Preise bis 30.09.2026 unter losverkauf@fcschattdorf.ch anfordern | Losverkauf';
	$ist = (string) get_post_meta( $seite->ID, 'fcs_gt_downloads', true );
	if ( trim( $ist ) === trim( $soll ) ) {
		echo "   SKIP – Seite #{$seite->ID}: Downloads stehen schon.\n";
	} else {
		echo '   ' . ( $dry ? 'würde setzen: ' : 'gesetzt: ' ) . "Seite #{$seite->ID} «Weitere Downloads» (2 Zeilen: Losnummern, Ziehungsprotokoll)\n";
		if ( ! $dry ) { update_post_meta( $seite->ID, 'fcs_gt_downloads', $soll ); }
	}
}

/* ── Abschluss ──────────────────────────────────────────────────── */
if ( ! $dry ) {
	wp_cache_flush();
	@unlink( __FILE__ );
	echo "\nSkript hat sich selbst gelöscht.\n";
}
echo "\n" . ( 0 === $fehler ? "FERTIG – keine Fehler.\n" : "FERTIG – ABER {$fehler} Stelle(n) brauchen Aufmerksamkeit (siehe oben).\n" );
