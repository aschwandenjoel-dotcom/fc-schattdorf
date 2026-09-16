<?php
/**
 * Bild-Zoom für Personenfotos (Betreuerstab, Kader, Betreuer-Übersicht).
 *
 * Ein Klick auf ein Porträt öffnet es gross in einem <dialog> über der
 * Seite (Rückmeldung vom 12.09.2026). Kein Fremdcode: assets/fcs-zoom.js
 * hängt sich per Ereignis-Delegation an die Foto-Kacheln, assets/fcs-zoom.css
 * gestaltet die Ebene in der Sprache des Overlay-Menüs (Ink, eckig).
 *
 * Geladen nur auf Vorlagen, die solche Kacheln zeigen. Silhouetten
 * (Platzhalter ohne Foto) bleiben ohne Zoom — das regelt das Skript.
 */
defined( 'ABSPATH' ) || exit;

add_action( 'wp_enqueue_scripts', function () {
	$vorlagen = array(
		'page-1mannschaft.php',
		'page-2mannschaft.php',
		'page-3mannschaft.php',
		'page-frauen-uri-1.php',
		'page-senioren-uri-1.php',
		'page-junioren-team.php',
		'page-betreuer.php',
	);
	if ( ! is_page_template( $vorlagen ) ) {
		return;
	}
	$dir = get_stylesheet_directory();
	$uri = get_stylesheet_directory_uri();
	wp_enqueue_style( 'fcs-zoom', $uri . '/assets/fcs-zoom.css', array(), filemtime( $dir . '/assets/fcs-zoom.css' ) );
	wp_enqueue_script( 'fcs-zoom', $uri . '/assets/fcs-zoom.js', array(), filemtime( $dir . '/assets/fcs-zoom.js' ), true );
}, 6 );
