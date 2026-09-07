<?php
/**
 * Jahrgangs-Spannen für die Anmeldung — rechnen sich pro Saison selbst.
 *
 * Auf «Mitglied werden» steht, welche Jahrgänge im Juniorenbereich und
 * im Kinderfussball spielen. Das waren feste Zahlen und veralteten mit
 * jeder Saison still. Jetzt kommen sie aus dem Saisonjahr:
 *
 *   %%fcs_jahrgaenge_junioren%%  -> «2012 bis 2006»   (A- bis C-Junioren)
 *   %%fcs_jahrgaenge_kinder%%    -> «2018 bis 2013»   (F- bis D-Junioren)
 *
 * Die Platzhalter stehen im Text, nicht die Zahlen — der Saisonwechsel
 * braucht also keinen Deploy. Sie gehen durch dieselbe Ersetzung wie
 * %%fcs_vereinsjahre%% (inc/fcs-vereinsjahre.php) und funktionieren
 * deshalb auch in den Feldern der Box «Seiteninhalte» und in Yoast.
 *
 * Wichtig: Der Wechsel passiert im Sommer, nicht am 1. Januar. Die
 * Jahrgangs-Einteilung hängt an der Saison; würde sie im Januar
 * umspringen, stünde ein halbes Jahr lang die Einteilung der noch gar
 * nicht begonnenen Saison auf der Seite.
 */
defined( 'ABSPATH' ) || exit;

/**
 * Startjahr der laufenden Saison.
 *
 * Die Saison läuft von Sommer zu Sommer; ab August zählt das laufende
 * Jahr, davor noch das Vorjahr. Saison 2026/27 -> 2026.
 */
function fcs_saisonjahr() {
	$jahr  = (int) current_time( 'Y' );
	$monat = (int) current_time( 'n' );
	return $monat >= 8 ? $jahr : $jahr - 1;
}

/**
 * Jahrgangs-Spanne als Text, jüngster zuerst: «2012 bis 2006».
 *
 * Die beiden Werte sind Altersabstände zum Saisonstartjahr, nicht
 * Jahreszahlen — daran ändert der Saisonwechsel nichts.
 */
function fcs_jahrgaenge( $jahre_juengste, $jahre_aelteste ) {
	$saison = fcs_saisonjahr();
	return sprintf( '%d bis %d', $saison - $jahre_juengste, $saison - $jahre_aelteste );
}

/** A- bis C-Junioren. Saison 2026/27: Jahrgang 2012 bis 2006. */
function fcs_jahrgaenge_junioren() {
	return fcs_jahrgaenge( 14, 20 );
}

/** F- bis D-Junioren (Kinderfussball). Saison 2026/27: Jahrgang 2018 bis 2013. */
function fcs_jahrgaenge_kinder() {
	return fcs_jahrgaenge( 8, 13 );
}

/* Beide Spannen in die gemeinsame Platzhalter-Tabelle hängen. */
add_filter( 'fcs_platzhalter', function ( $map ) {
	$map['%%fcs_jahrgaenge_junioren%%'] = fcs_jahrgaenge_junioren();
	$map['%%fcs_jahrgaenge_kinder%%']   = fcs_jahrgaenge_kinder();
	return $map;
} );
