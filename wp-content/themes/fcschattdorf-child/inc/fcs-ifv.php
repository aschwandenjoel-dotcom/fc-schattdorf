<?php
/**
 * Links ins IFV-Matchcenter (Tabelle, Spielplan) für ein einzelnes Team.
 *
 * Das Matchcenter adressiert Teams über zwei Nummern aus der Adresse:
 *   v = Verein (FC Schattdorf 329, FC Altdorf 326 — dort laufen die
 *       Team-Uri-Frauen), t = Team. Beide bleiben über die Saisons
 *       gleich; die 1. Mannschaft ist seit Jahren t=30614.
 *
 * Für den Spielplan hängt das Matchcenter zusätzlich ls (Liga-Saison)
 * und sg (Gruppe) an — die wechseln JEDE SAISON. Mit ls=0&sg=0 wählt
 * der Server die aktuelle Gruppe selbst (geprüft an Schnappschüssen von
 * 2023 und März 2026). Feste ls/sg-Werte in Links zeigen nach dem
 * Saisonwechsel still auf die alte Saison — genau das war bis
 * September 2026 bei allen Aktiv-Teams der Fall.
 *
 * Deshalb: Links immer über diese Helfer bauen, nie von Hand.
 */
defined( 'ABSPATH' ) || exit;

const FCS_IFV_VEREIN = 329; // FC Schattdorf

/** IFV-Vereinsseite mit dem Spielbetrieb aller FCS-Teams (Rückfall). */
function fcs_ifv_verein_url() {
	return 'https://www.ifv.ch/Innerschweizerischer-Fussballverband/Vereine-IFV/Verein-IFV.aspx/v-329/a-as/';
}

/** Resultate + Rangliste eines Teams. */
function fcs_ifv_tabelle_url( $team, $verein = FCS_IFV_VEREIN ) {
	return sprintf( 'https://matchcenter.ifv.ch/default.aspx?v=%d&oid=7&lng=1&t=%d&a=trr', (int) $verein, (int) $team );
}

/** Team-Spielplan (alle Spiele der laufenden Saison). */
function fcs_ifv_spielplan_url( $team, $verein = FCS_IFV_VEREIN ) {
	return sprintf( 'https://matchcenter.ifv.ch/default.aspx?oid=7&lng=1&v=%d&t=%d&ls=0&sg=0&a=pt', (int) $verein, (int) $team );
}

/**
 * Seitenfeld «IFV-Teams» einer Teamseite in Kacheln übersetzen.
 *
 * Eine Zeile pro Team: «Kürzel | Team-Nummer | Vereinsnummer»; die
 * Vereinsnummer darf fehlen (dann FC Schattdorf). Steht in einer
 * weiteren Spalte «ohne Tabelle», gibt es nur die Spielplan-Kachel —
 * im Kinderfussball (E, F) führt der IFV keine Rangliste. Seiten wie
 * Ea/Eb oder Fa/Fb/Fc führen mehrere Teams — dann bekommt jede Kachel
 * das Kürzel im Namen («Spielplan Ea»), bei einem Team bleibt es bei
 * «Tabelle» / «Spielplan».
 *
 * Rückgabe: Liste von [label, meta, url]; leer, wenn kein Team
 * eingetragen ist (die Vorlage zeigt dann ihren Rückfall).
 */
function fcs_ifv_kacheln( $zeilen ) {
	$teams = array();
	foreach ( (array) $zeilen as $zeile ) {
		$t = array_map( 'trim', explode( '|', $zeile ) );
		if ( count( $t ) < 2 || ! ctype_digit( $t[1] ) ) {
			continue;
		}
		$eintrag = array( 'kurz' => $t[0], 'team' => (int) $t[1], 'verein' => FCS_IFV_VEREIN, 'tabelle' => true );
		/* Spalten 3+ in beliebiger Reihenfolge: Zahl = Vereinsnummer,
		   «ohne Tabelle» = nur Spielplan. */
		foreach ( array_slice( $t, 2 ) as $opt ) {
			if ( ctype_digit( $opt ) ) {
				$eintrag['verein'] = (int) $opt;
			} elseif ( false !== mb_stripos( $opt, 'tabelle' ) ) {
				$eintrag['tabelle'] = false;
			}
		}
		$teams[] = $eintrag;
	}
	$kacheln = array();
	$mehrere = count( $teams ) > 1;
	foreach ( $teams as $t ) {
		$suffix    = $mehrere && '' !== $t['kurz'] ? ' ' . $t['kurz'] : '';
		if ( $t['tabelle'] ) {
			$kacheln[] = array( 'Tabelle' . $suffix, 'Rangliste beim IFV', fcs_ifv_tabelle_url( $t['team'], $t['verein'] ) );
		}
		$kacheln[] = array( 'Spielplan' . $suffix, 'Alle Spiele beim IFV', fcs_ifv_spielplan_url( $t['team'], $t['verein'] ) );
	}
	return $kacheln;
}
