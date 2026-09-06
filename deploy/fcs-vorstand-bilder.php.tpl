<?php
/**
 * Einmal-Skript: Vorstandsseite bindet Vorschaubilder statt Originale ein.
 *
 * Hintergrund: Auf Hostpoint ist MySQL von der SSH-Shell aus nicht
 * erreichbar — nur Web-Prozesse dürfen zur DB. Dieses Skript wird
 * daher kurzzeitig in den Webroot gelegt, per HTTPS mit Token
 * aufgerufen und danach gelöscht (löscht sich zusätzlich selbst).
 *
 * Das Problem: Im Inhalt der Seite /verein/vorstand/ stehen bei sieben
 * Personen die von WordPress erzeugten Vorschau-Versionen
 * («-300x200» bzw. «-200x300»). Die Karten sind aber 375 px breit und
 * werden auf Retina-Bildschirmen mit 750 px ausgespielt — die Bilder
 * werden also bis zu 4,7-fach hochskaliert und wirken entsprechend
 * matschig. Die Originale liegen mit 2500x1667 bzw. 1280x1920 längst
 * in derselben Mediathek.
 *
 * Was das Skript tut: In den betroffenen <figure>-Blöcken den
 * Dateinamen auf das Original umstellen, die width/height-Angaben
 * mitziehen und «size-medium» auf «size-full» setzen. Der Bildaus-
 * schnitt ändert sich dabei nicht — die Vorlage schneidet ohnehin über
 * CSS auf 4:5 zu (object-fit: cover), und die Seitenverhältnisse der
 * Vorschauen entsprechen denen der Originale.
 *
 * Bilder, die schon auf dem Original stehen (Markus Indergand) oder
 * bewusst eine Silhouette zeigen (Robin Lindauer), bleiben unberührt.
 *
 * Idempotent: ein zweiter Lauf meldet «SKIP».
 * Probelauf ohne Schreiben:  ?token=…&dry=1
 */
if ( ! isset( $_GET['token'] ) || ! hash_equals( '__TOKEN__', (string) $_GET['token'] ) ) {
	http_response_code( 403 ); exit( 'forbidden' );
}

require __DIR__ . '/wp-load.php';

header( 'Content-Type: text/plain; charset=utf-8' );
set_time_limit( 300 );

$dry = ! empty( $_GET['dry'] );
echo $dry ? "MODUS: Probelauf (es wird nichts geschrieben)\n\n" : "MODUS: Schreiben\n\n";

$fehler = 0;

/* Vorschaudatei => array( Originaldatei, Breite, Höhe ) */
$bilder = array(
	'Iwan_Herger-300x200.jpg'    => array( 'Iwan_Herger.jpg',     2500, 1667 ),
	'Paddi_Schorno-300x200.jpg'  => array( 'Paddi_Schorno.jpg',   2500, 1667 ),
	'Rene_Gnos-300x200.jpg'      => array( 'Rene_Gnos.jpg',       2500, 1667 ),
	'Ralph_Bomatter-200x300.jpg' => array( 'Ralph_Bomatter.jpg',  1280, 1920 ),
	'Claudia_Gisler-200x300.jpg' => array( 'Claudia_Gisler.jpg',  1280, 1920 ),
	'Reto_Planzer-200x300.jpg'   => array( 'Reto_Planzer.jpg',    1280, 1920 ),
	'Orlando_Gisler-200x300.jpg' => array( 'Orlando_Gisler.jpg',  1280, 1920 ),
);

/* ── A) Originaldateien müssen wirklich da sein ─────────────────── */
echo "A) Originale in uploads/2026/06\n";
$updir = wp_upload_dir();
$fehlt = array();
foreach ( $bilder as $info ) {
	if ( ! file_exists( $updir['basedir'] . '/2026/06/' . $info[0] ) ) { $fehlt[] = $info[0]; }
}
if ( $fehlt ) {
	echo "   FEHLER – diese Originale fehlen: " . implode( ', ', $fehlt ) . "\n";
	echo "            Ohne sie würde die Seite leere Kästen zeigen. Abbruch.\n";
	echo "\nFERTIG – ABER 1 Stelle braucht Aufmerksamkeit (siehe oben).\n";
	exit;
}
echo '   OK – alle ' . count( $bilder ) . " Originale sind da.\n";

/* ── B) Seiteninhalt umschreiben ────────────────────────────────── */
echo "\nB) Vorstandsseite\n";

$seite = get_page_by_path( 'verein/vorstand' );
if ( ! $seite ) { $seite = get_page_by_path( 'vorstand' ); }
if ( ! $seite ) {
	echo "   FEHLER – Seite nicht gefunden.\n";
	$fehler++;
} else {
	$alt_inhalt = $seite->post_content;
	$getauscht  = array();

	/* Nur innerhalb des jeweiligen <figure>-Blocks arbeiten, damit
	   width/height keiner fremden Abbildung verstellt werden. */
	$neu_inhalt = preg_replace_callback(
		'#<figure\b[^>]*>.*?</figure>#s',
		function ( $treffer ) use ( $bilder, &$getauscht ) {
			$block = $treffer[0];
			foreach ( $bilder as $vorschau => $info ) {
				if ( false === strpos( $block, $vorschau ) ) { continue; }
				list( $original, $w, $h ) = $info;
				$block = str_replace( $vorschau, $original, $block );
				$block = preg_replace( '#\bwidth="\d+"#',  'width="' . $w . '"',  $block );
				$block = preg_replace( '#\bheight="\d+"#', 'height="' . $h . '"', $block );
				$block = str_replace( 'size-medium', 'size-full', $block );
				$getauscht[] = $vorschau . ' -> ' . $original . " ({$w}x{$h})";
				break;
			}
			return $block;
		},
		$alt_inhalt
	);

	if ( null === $neu_inhalt ) {
		echo "   FEHLER – Umschreiben fehlgeschlagen, Inhalt unverändert.\n";
		$fehler++;
	} elseif ( $neu_inhalt === $alt_inhalt ) {
		echo "   SKIP – #{$seite->ID} bindet bereits die Originale ein.\n";
	} else {
		foreach ( $getauscht as $z ) { echo '   ' . ( $dry ? 'würde tauschen: ' : 'getauscht: ' ) . $z . "\n"; }
		if ( count( $getauscht ) !== count( $bilder ) ) {
			echo '   HINWEIS – erwartet waren ' . count( $bilder ) . ' Bilder, gefunden ' . count( $getauscht ) . ".\n";
			echo "             Der Rest steht vermutlich schon auf dem Original.\n";
		}
		if ( ! $dry ) {
			$ok = wp_update_post( array( 'ID' => $seite->ID, 'post_content' => $neu_inhalt ), true );
			if ( is_wp_error( $ok ) ) {
				echo '   FEHLER – Speichern fehlgeschlagen: ' . $ok->get_error_message() . "\n";
				$fehler++;
			}
		}
	}
}

/* ── Abschluss ──────────────────────────────────────────────────── */
if ( ! $dry ) {
	wp_cache_flush();
	@unlink( __FILE__ );
	echo "\nSkript hat sich selbst gelöscht.\n";
}
echo "\n" . ( 0 === $fehler ? "FERTIG – keine Fehler.\n" : "FERTIG – ABER {$fehler} Stelle(n) brauchen Aufmerksamkeit (siehe oben).\n" );
