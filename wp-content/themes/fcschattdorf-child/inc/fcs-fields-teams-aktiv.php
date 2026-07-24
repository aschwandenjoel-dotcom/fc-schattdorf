<?php
/**
 * Pflegbare Seitenfelder für die Teamseiten der Aktiven
 * (1., 2. und 3. Mannschaft).
 *
 * Ergänzt die Feld-Box «Seiteninhalte» (inc/fcs-page-fields.php) um
 * Listen-Felder für Betreuerstab, Kader und Team-Sponsoren. Pro Zeile
 * steht ein Eintrag, die Spalten sind mit ' | ' getrennt. Die Vorlagen
 * lesen die Werte über die Helfer fcsh_team_*() weiter unten; leere
 * Felder zeigen weiterhin die Standardwerte der Vorlage.
 *
 * Tabellen/Spielpläne (IFV-Links, Matchcenter) bleiben bewusst fest in
 * den Vorlagen — sie ändern höchstens einmal pro Saison.
 */
defined( 'ABSPATH' ) || exit;

add_filter( 'fcs_page_fields_config', function ( $config ) {
	/* Gleiche Felder für alle drei Team-Vorlagen; nur die 1. Mannschaft
	   zeigt zusätzlich ein Kader. Bilddateien = Dateiname im
	   Upload-Ordner 2026/06 (Mediathek). */
	$staff = array(
		'label' => 'Betreuerstab (einer pro Zeile: Rolle | Name | Porträt-Bilddatei | Sponsorlogo-Datei — Logo optional; Bilddateien aus dem Upload-Ordner 2026/06)',
		'type'  => 'textarea',
	);
	$sponsoren = array(
		'label' => 'Team-Sponsoren (einer pro Zeile: Name | Logo-Bilddatei | Website — Website optional)',
		'type'  => 'textarea',
	);

	$config['page-1mannschaft.php'] = array(
		'team_staff' => $staff,
		'team_kader' => array(
			'label' => 'Kader (ein Spieler pro Zeile: Position | Rückennummer | Name | Porträt-Bilddatei | Sponsorlogo-Datei | Sponsorname — die letzten beiden optional; Zeilen mit gleicher Position bilden eine Gruppe)',
			'type'  => 'textarea',
		),
		'team_sponsoren' => $sponsoren,
	);
	$config['page-2mannschaft.php'] = array(
		'team_staff'     => $staff,
		'team_sponsoren' => $sponsoren,
	);
	$config['page-3mannschaft.php'] = array(
		'team_staff'     => $staff,
		'team_sponsoren' => $sponsoren,
	);
	return $config;
} );

/* ── Helfer: Listen-Felder in die Datenstruktur der Vorlagen wandeln ──
   $fallback ist jeweils im gleichen Zeilenformat wie das Feld selbst. */

/* Betreuerstab: 'Rolle | Name | Porträtbild | Sponsorlogo' */
function fcsh_team_staff( $fallback = array() ) {
	$staff = array();
	foreach ( fcs_pf_lines( 'team_staff', $fallback ) as $zeile ) {
		$t = array_map( 'trim', explode( '|', $zeile ) );
		if ( count( $t ) < 3 ) {
			continue;
		}
		$staff[] = array(
			'role'     => $t[0],
			'name'     => $t[1],
			'portrait' => $t[2],
			'badge'    => $t[3] ?? '',
		);
	}
	return $staff;
}

/* Kader: 'Position | Nr | Name | Porträtbild | Sponsorlogo | Sponsorname'
   → nach Position gruppiert (Gruppen-Reihenfolge = erstes Vorkommen) */
function fcsh_team_kader( $fallback = array() ) {
	$squad = array();
	foreach ( fcs_pf_lines( 'team_kader', $fallback ) as $zeile ) {
		$t = array_map( 'trim', explode( '|', $zeile ) );
		if ( count( $t ) < 4 ) {
			continue;
		}
		$squad[ $t[0] ][] = array(
			'nr'       => $t[1],
			'name'     => $t[2],
			'portrait' => $t[3],
			'badge'    => $t[4] ?? '',
			'sponsor'  => $t[5] ?? '',
		);
	}
	return $squad;
}

/* Team-Sponsoren: 'Name | Logo-Bilddatei | Website' */
function fcsh_team_sponsoren( $fallback = array() ) {
	$sponsoren = array();
	foreach ( fcs_pf_lines( 'team_sponsoren', $fallback ) as $zeile ) {
		$t = array_map( 'trim', explode( '|', $zeile ) );
		if ( count( $t ) < 2 ) {
			continue;
		}
		$sponsoren[] = array(
			'name' => $t[0],
			'img'  => $t[1],
			'url'  => $t[2] ?? '',
		);
	}
	return $sponsoren;
}
