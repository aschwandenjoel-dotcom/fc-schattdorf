<?php
/**
 * Einmal-Skript: fünf neue Betreuer-Porträts einsetzen (25.09.2026).
 *
 * Auf Hostpoint ist MySQL nur aus Web-Prozessen erreichbar; dieses
 * Skript wird deshalb kurz in den Webroot gelegt, per HTTPS mit Token
 * aufgerufen und löscht sich danach selbst.
 *
 *   A) Team Uri FF14 (Seite mit Vorlage page-junioren-team.php):
 *      Philipp Bissig, Luca Forte und Heinz Gisler trugen bisher eine
 *      Silhouette und bekommen ihr Porträt. Ersetzt wird die dritte
 *      Spalte der Zeile mit dem Namen im Feld fcs_jt_betreuer; steht
 *      dort schon ein echtes Porträt, bleibt es (HINWEIS).
 *   B) Frauen Team Uri (Seite mit Vorlage page-frauen-uri-1.php,
 *      Feld fcs_team_staff): Dominique Scheiber bekommt ihr neues
 *      Porträt statt Domi_Scheiber.jpg, und Fabrice Arnold kommt als
 *      Trainer neu dazu — er führt die Equipe laut Spielberichten,
 *      stand auf der Teamseite aber nicht. Er wird VOR die Betreuerin
 *      gesetzt (Trainer zuoberst, wie bei den Aktiven).
 *
 * Die Bilddateien überträgt das aufrufende Shell-Skript vorher per
 * scp; dieses Skript prüft nur noch, ob sie da sind.
 *
 * Idempotent: gesetzte Werte melden «SKIP». Zweiter Lauf ändert nichts.
 * Probelauf ohne Schreiben:  ?token=…&dry=1
 */
if ( ! isset( $_GET['token'] ) || ! hash_equals( '__TOKEN__', (string) $_GET['token'] ) ) {
	http_response_code( 403 ); exit( 'forbidden' );
}

require __DIR__ . '/wp-load.php';
header( 'Content-Type: text/plain; charset=utf-8' );

$dry = ! empty( $_GET['dry'] );
echo $dry ? "MODUS: Probelauf (es wird nichts geschrieben)\n\n" : "MODUS: Schreiben\n\n";

$fehler = 0;
$updir  = wp_upload_dir();
$bilder = array(
	'Philipp_Bissig_2627.jpg', 'Luca_Forte_2627.jpg', 'Heinz_Gisler_2627.jpg',
	'Dominique_Scheiber_2627.jpg', 'Fabrice_Arnold_2627.jpg',
);

/* ── 0) Bilddateien ─────────────────────────────────────────────── */
echo "0) Bilddateien\n";
$fehlt = array();
foreach ( $bilder as $b ) {
	if ( ! file_exists( $updir['basedir'] . '/2026/06/' . $b ) ) { $fehlt[] = $b; }
}
if ( $fehlt ) {
	echo '   FEHLER – diese Dateien fehlen: ' . implode( ', ', $fehlt ) . "\n";
	echo "            Ohne sie zeigten die Karten leere Kästen. Abbruch.\n";
	echo "\nFERTIG – ABER 1 Stelle braucht Aufmerksamkeit (siehe oben).\n";
	exit;
}
echo '   OK – alle ' . count( $bilder ) . " Dateien sind da.\n";

/** Seite über mehrere mögliche Pfade finden. */
function fcs_seite( $pfade ) {
	foreach ( (array) $pfade as $pfad ) {
		$s = get_page_by_path( $pfad );
		if ( $s ) { return $s; }
	}
	$name = basename( end( $pfade ) );
	$t    = get_posts( array( 'post_type' => 'page', 'post_status' => 'publish', 'name' => $name, 'posts_per_page' => 1 ) );
	return $t ? $t[0] : null;
}

/* ── A) Team Uri FF14: Silhouetten ersetzen ─────────────────────── */
echo "\nA) Team Uri FF14\n";

$ff14 = array(
	'Philipp Bissig' => 'Philipp_Bissig_2627.jpg',
	'Luca Forte'     => 'Luca_Forte_2627.jpg',
	'Heinz Gisler'   => 'Heinz_Gisler_2627.jpg',
);
$seite = fcs_seite( array( 'junioren/teams/team-uri-ff14', 'team-uri-ff14' ) );
if ( ! $seite ) {
	echo "   FEHLER – Seite «Team Uri FF14» nicht gefunden.\n";
	$fehler++;
} else {
	$ist    = str_replace( "\r\n", "\n", (string) get_post_meta( $seite->ID, 'fcs_jt_betreuer', true ) );
	$zeilen = explode( "\n", $ist );
	$geaendert = false;
	foreach ( $ff14 as $name => $datei ) {
		$gefunden = false;
		foreach ( $zeilen as $i => $zeile ) {
			$t = array_map( 'trim', explode( '|', $zeile ) );
			if ( count( $t ) < 2 || $t[1] !== $name ) { continue; }
			$gefunden = true;
			$bild = $t[2] ?? '';
			if ( $bild === $datei ) { echo "   SKIP – {$name} hat schon {$datei}.\n"; break; }
			if ( '' !== $bild && false === stripos( $bild, 'Silhouette' ) ) {
				echo "   HINWEIS – {$name} trägt schon ein Porträt ({$bild}), nicht ersetzt.\n";
				break;
			}
			$t[2] = $datei;
			$zeilen[ $i ] = implode( ' | ', $t );
			$geaendert = true;
			echo '   ' . ( $dry ? 'würde setzen: ' : 'gesetzt: ' ) . "#{$seite->ID} {$name}: " . ( $bild ?: '—' ) . " -> {$datei}\n";
			break;
		}
		if ( ! $gefunden ) { echo "   HINWEIS – {$name} steht nicht im Betreuerstab (nichts zu tun).\n"; }
	}
	if ( $geaendert && ! $dry ) { update_post_meta( $seite->ID, 'fcs_jt_betreuer', implode( "\n", $zeilen ) ); }
}

/* ── B) Frauen Team Uri: Scheiber neu, Arnold ergänzen ──────────── */
echo "\nB) Frauen Team Uri\n";

$alt_erwartet = 'Betreuerin | Dominique Scheiber | Domi_Scheiber.jpg';
$neu_wert     = "Trainer | Fabrice Arnold | Fabrice_Arnold_2627.jpg\n"
              . 'Betreuerin | Dominique Scheiber | Dominique_Scheiber_2627.jpg';

$seite = fcs_seite( array( 'aktive/frauen-uri-1', 'frauen-uri-1' ) );
if ( ! $seite ) {
	echo "   FEHLER – Seite «Frauen Team Uri» nicht gefunden.\n";
	$fehler++;
} else {
	$ist = trim( str_replace( "\r\n", "\n", (string) get_post_meta( $seite->ID, 'fcs_team_staff', true ) ) );
	if ( $ist === $neu_wert ) {
		echo "   SKIP – #{$seite->ID}: Betreuerstab steht schon auf dem neuen Stand.\n";
	} elseif ( '' === $ist ) {
		/* Feld leer: die Vorlage zeigt ihren Fallback. Dann hier setzen. */
		echo '   ' . ( $dry ? 'würde setzen: ' : 'gesetzt: ' ) . "#{$seite->ID} Betreuerstab (Feld war leer):\n";
		foreach ( explode( "\n", $neu_wert ) as $z ) { echo "                 {$z}\n"; }
		if ( ! $dry ) { update_post_meta( $seite->ID, 'fcs_team_staff', $neu_wert ); }
	} elseif ( $ist !== $alt_erwartet ) {
		echo "   ABBRUCH – #{$seite->ID}: Betreuerstab weicht vom erwarteten Stand ab.\n";
		echo "             erwartet: «{$alt_erwartet}»\n";
		echo "             steht:    «" . str_replace( "\n", ' ⏎ ', $ist ) . "»\n";
		echo "             Da hat jemand im Admin gearbeitet — bitte dort von Hand setzen.\n";
		$fehler++;
	} else {
		echo '   ' . ( $dry ? 'würde setzen: ' : 'gesetzt: ' ) . "#{$seite->ID} Betreuerstab:\n";
		echo "             «{$alt_erwartet}»\n          -> «" . str_replace( "\n", ' ⏎ ', $neu_wert ) . "»\n";
		if ( ! $dry ) { update_post_meta( $seite->ID, 'fcs_team_staff', $neu_wert ); }
	}
}

/* ── Abschluss ──────────────────────────────────────────────────── */
if ( ! $dry ) {
	wp_cache_flush();
	@unlink( __FILE__ );
	echo "\nSkript hat sich selbst gelöscht.\n";
}
echo "\n" . ( 0 === $fehler ? "FERTIG – keine Fehler.\n" : "FERTIG – ABER {$fehler} Stelle(n) brauchen Aufmerksamkeit (siehe oben).\n" );
