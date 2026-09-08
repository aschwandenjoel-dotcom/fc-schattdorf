<?php
/**
 * Feld-Definitionen für die Vorlage «Liveticker» (page-liveticker.php).
 *
 * Ergänzt die Feld-Box «Seiteninhalte» (inc/fcs-page-fields.php) über
 * den Filter 'fcs_page_fields_config'. Vor jedem Spiel: Ticker in der
 * Tickaroo-App anlegen, Link kopieren, hier ins erste Feld — fertig.
 */
defined( 'ABSPATH' ) || exit;

add_filter( 'fcs_page_fields_config', function ( $config ) {
	$config['page-liveticker.php'] = array(
		'lt_url'           => array( 'label' => 'Link zum aktuellen Ticker (Tickaroo-Adresse; gesetzt = Seite leitet dorthin weiter, leer = Hinweis «Zurzeit kein Liveticker»)', 'type' => 'url' ),
		'lt_text'          => array( 'label' => 'Hinweistext, wenn kein Ticker läuft', 'type' => 'textarea' ),
		'lt_spielplan_url' => array( 'label' => 'Link «Spielplan beim IFV» (leer = Spielplan 1. Mannschaft)', 'type' => 'url' ),
	);
	return $config;
} );
