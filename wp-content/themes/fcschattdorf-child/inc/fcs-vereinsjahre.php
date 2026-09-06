<?php
/**
 * Gründungsjahr und Vereinsalter an einer Stelle — auch für Yoast.
 *
 * Die Vereinsgeschichte zeigt «X Jahre Geschichte» und rechnet dafür
 * vom Gründungsjahr bis heute. In der Meta-Beschreibung stand dieselbe
 * Zahl bis zum 06.09.2026 als fester Text («110 Jahre …») und veraltete
 * still — sie war ausserdem ab der ersten Gründung 1916 gerechnet,
 * während die Seite ab der Neugründung 1933 zählt.
 *
 * Damit so etwas nicht wieder auseinanderläuft, kommen beide Zahlen
 * jetzt aus denselben zwei Funktionen, und Yoast bekommt sie als
 * Platzhalter:
 *
 *   %%fcs_vereinsjahre%%    -> 93
 *   %%fcs_gruendungsjahr%%  -> 1933
 *
 * In der Beschreibung stehen die Platzhalter, nicht die Zahlen. Yoast
 * setzt sie bei jedem Seitenaufruf ein — der Jahreswechsel braucht also
 * keinen Deploy und keine Handarbeit.
 *
 * Gepflegt wird das Gründungsjahr im Seitenfeld «Gründungsjahr» der
 * Seite «Vereinsgeschichte» (leer = 1933).
 */
defined( 'ABSPATH' ) || exit;

/** Gründungsjahr aus dem Seitenfeld, sonst 1933 (Neugründung). */
function fcs_gruendungsjahr() {
	$seite = get_page_by_path( 'verein/vereinsgeschichte' );
	if ( ! $seite ) {
		$seite = get_page_by_path( 'vereinsgeschichte' );
	}
	$jahr = $seite ? (int) get_post_meta( $seite->ID, 'fcs_vg_gruendung', true ) : 0;
	/* Plausibilitätsgrenzen: ein Tippfehler im Feld soll nicht zu
	   «2026 Jahre Geschichte» führen. */
	if ( $jahr < 1850 || $jahr > (int) current_time( 'Y' ) ) {
		$jahr = 1933;
	}
	return $jahr;
}

/** Vollendete Vereinsjahre bis heute. */
function fcs_vereinsjahre() {
	return max( 0, (int) current_time( 'Y' ) - fcs_gruendungsjahr() );
}

/* ── Yoast-Platzhalter anmelden ───────────────────────────────────
   Über die dafür vorgesehene Aktion; sie läuft erst, wenn Yoast
   geladen ist. Ohne Yoast passiert schlicht nichts. */
add_action( 'wpseo_register_extra_replacements', function () {
	if ( ! function_exists( 'wpseo_register_var_replacement' ) ) {
		return;
	}
	wpseo_register_var_replacement(
		'%%fcs_vereinsjahre%%',
		'fcs_vereinsjahre',
		'advanced',
		'Vollendete Vereinsjahre seit der Gründung (z. B. 93)'
	);
	wpseo_register_var_replacement(
		'%%fcs_gruendungsjahr%%',
		'fcs_gruendungsjahr',
		'advanced',
		'Gründungsjahr des Vereins (z. B. 1933)'
	);
} );

/* ── Sicherheitsnetz ──────────────────────────────────────────────
   Sollte die Ersetzung einmal nicht greifen — Yoast deaktiviert, eine
   andere Ausgabestelle, ein künftiger Umbau der Platzhalter-Schnittstelle
   —, dürfen die rohen %%…%% nicht im Quelltext landen. */
function fcs_platzhalter_ersetzen( $text ) {
	if ( ! is_string( $text ) || false === strpos( $text, '%%fcs_' ) ) {
		return $text;
	}
	return str_replace(
		array( '%%fcs_vereinsjahre%%', '%%fcs_gruendungsjahr%%' ),
		array( (string) fcs_vereinsjahre(), (string) fcs_gruendungsjahr() ),
		$text
	);
}
foreach ( array( 'wpseo_metadesc', 'wpseo_opengraph_desc', 'wpseo_twitter_description', 'wpseo_title' ) as $fcs_hook ) {
	add_filter( $fcs_hook, 'fcs_platzhalter_ersetzen', 20 );
}
unset( $fcs_hook );
