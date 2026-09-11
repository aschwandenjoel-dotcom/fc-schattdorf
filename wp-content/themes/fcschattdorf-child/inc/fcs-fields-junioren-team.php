<?php
/**
 * Pflegbare Seitenfelder für die Vorlage «Junioren Team».
 *
 * Alle Junioren-Teamseiten nutzen dieselbe Vorlage (page-junioren-team.php);
 * jede Seite pflegt hier ihre eigenen Werte (Teamname, Teamfoto, Betreuer,
 * Sponsoren, IFV-Teams). Listen-Felder: ein Eintrag pro Zeile, Teile mit
 * « | » getrennt. Bild-Dateinamen beziehen sich auf den Upload-Ordner
 * 2026/06. Die Matchcenter-Links baut inc/fcs-ifv.php aus den Nummern.
 */
defined( 'ABSPATH' ) || exit;

add_filter( 'fcs_page_fields_config', function ( $config ) {
	$config['page-junioren-team.php'] = array(
		'jt_titel'     => array( 'label' => 'Teamname (Titel im Titelbild, z. B. Junioren Mannschaft Da)', 'type' => 'text' ),
		'jt_foto'      => array( 'label' => 'Teamfoto: Bild-Dateiname aus der Mediathek 2026/06 (z. B. Da_Junioren_25-26.jpg)', 'type' => 'text' ),
		'jt_foto_pos'  => array( 'label' => 'Teamfoto: senkrechte Lage im Titelbild in Prozent (leer = 50 = Bildmitte; kleiner zeigt mehr vom oberen Rand, z. B. 25, wenn oben Köpfe abgeschnitten sind)', 'type' => 'text' ),
		'jt_ifv'       => array( 'label' => 'IFV-Teams für Tabelle und Spielplan (eines pro Zeile: Kürzel | Team-Nummer | Vereinsnummer | ohne Tabelle — Team-Nummer = «t=…» in der Matchcenter-Adresse des Teams, Vereinsnummer = «v=…», leer = 329 FC Schattdorf, Altdorf 326, Erstfeld 327; «ohne Tabelle» = nur Spielplan-Kachel, für E/F-Teams; bei mehreren Teams wie Ea/Eb bekommt jedes seine Kacheln)', 'type' => 'textarea' ),
		'jt_tabelle'   => array( 'label' => 'Link «Tabelle» — nur wenn oben kein IFV-Team steht (leer = IFV-Vereinsseite mit allen FCS-Teams)', 'type' => 'url' ),
		'jt_spielplan' => array( 'label' => 'Link «Spielplan» — nur wenn oben kein IFV-Team steht (leer = IFV-Vereinsseite mit allen FCS-Teams)', 'type' => 'url' ),
		'jt_betreuer'  => array( 'label' => 'Betreuerstab (einer pro Zeile: Rolle | Name | Portrait-Dateiname aus 2026/06)', 'type' => 'textarea' ),
		'jt_sponsoren' => array( 'label' => 'Team-Sponsoren (einer pro Zeile: Name | Logo-Dateiname aus 2026/06 | Link — Link darf leer sein)', 'type' => 'textarea' ),
	);
	return $config;
} );
