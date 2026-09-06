<?php
/**
 * Pflegbare Seitenfelder für die Teamseiten Frauen Team Uri und Senioren Team Uri.
 *
 * Ergänzt die Feld-Box «Seiteninhalte» (inc/fcs-page-fields.php) um die
 * Felder dieser drei Vorlagen: Betreuerstab und Team-Sponsoren werden als
 * Listen gepflegt (eine Zeile = ein Eintrag, Teile mit « | » getrennt).
 * Die Matchcenter-Links (Tabelle/Spielplan) bleiben in der Vorlage.
 */
defined( 'ABSPATH' ) || exit;

add_filter( 'fcs_page_fields_config', function ( $config ) {
	/* Beide Teamseiten nutzen dasselbe Layout und dieselben Felder. */
	$team_felder = array(
		'team_staff'     => array(
			'label' => 'Betreuerstab (eine Person pro Zeile: Rolle | Name | Bilddatei, optional | Badge-Datei)',
			'type'  => 'textarea',
		),
		'team_sponsoren' => array(
			'label' => 'Team-Sponsoren (einer pro Zeile: Name | Bilddatei | Link-URL — URL darf leer sein)',
			'type'  => 'textarea',
		),
	);

	$config['page-frauen-uri-1.php']   = $team_felder;
	$config['page-senioren-uri-1.php'] = $team_felder;

	return $config;
} );

/* Zeilen «Rolle | Name | Bilddatei | Badge» -> Staff-Einträge fürs Markup */
function fcsh_team_staff_from_lines( $lines ) {
	$staff = array();
	foreach ( $lines as $zeile ) {
		$teile = array_map( 'trim', explode( '|', $zeile ) );
		if ( count( $teile ) < 3 ) {
			continue;
		}
		$staff[] = array(
			'role'     => $teile[0],
			'name'     => $teile[1],
			'portrait' => $teile[2],
			'badge'    => $teile[3] ?? '',
		);
	}
	return $staff;
}

/* Zeilen «Name | Bilddatei | URL» -> Sponsor-Einträge fürs Markup */
function fcsh_team_sponsors_from_lines( $lines ) {
	$sponsors = array();
	foreach ( $lines as $zeile ) {
		$teile = array_map( 'trim', explode( '|', $zeile ) );
		if ( count( $teile ) < 2 ) {
			continue;
		}
		$sponsors[] = array(
			'name' => $teile[0],
			'img'  => $teile[1],
			'url'  => $teile[2] ?? '',
		);
	}
	return $sponsors;
}
