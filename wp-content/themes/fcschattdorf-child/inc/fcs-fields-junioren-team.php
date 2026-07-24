<?php
/**
 * Pflegbare Seitenfelder für die Vorlage «Junioren Team».
 *
 * Alle Junioren-Teamseiten nutzen dieselbe Vorlage (page-junioren-team.php);
 * jede Seite pflegt hier ihre eigenen Werte (Teamname, Teamfoto, Betreuer,
 * Sponsoren). Listen-Felder: ein Eintrag pro Zeile, Teile mit « | » getrennt.
 * Bild-Dateinamen beziehen sich auf den Upload-Ordner 2026/06.
 */
defined( 'ABSPATH' ) || exit;

add_filter( 'fcs_page_fields_config', function ( $config ) {
	$config['page-junioren-team.php'] = array(
		'jt_titel'     => array( 'label' => 'Teamname (Titel im Titelbild, z. B. Junioren Mannschaft Da)', 'type' => 'text' ),
		'jt_foto'      => array( 'label' => 'Teamfoto: Bild-Dateiname aus der Mediathek 2026/06 (z. B. Da_Junioren_25-26.jpg)', 'type' => 'text' ),
		'jt_tabelle'   => array( 'label' => 'Link «Tabelle» (leer = IFV-Vereinsseite mit allen FCS-Teams)', 'type' => 'url' ),
		'jt_spielplan' => array( 'label' => 'Link «Spielplan» (leer = IFV-Vereinsseite mit allen FCS-Teams)', 'type' => 'url' ),
		'jt_betreuer'  => array( 'label' => 'Betreuerstab (einer pro Zeile: Rolle | Name | Portrait-Dateiname aus 2026/06)', 'type' => 'textarea' ),
		'jt_sponsoren' => array( 'label' => 'Team-Sponsoren (einer pro Zeile: Name | Logo-Dateiname aus 2026/06 | Link — Link darf leer sein)', 'type' => 'textarea' ),
	);
	return $config;
} );
