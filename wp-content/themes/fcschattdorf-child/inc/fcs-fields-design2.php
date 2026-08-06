<?php
/**
 * Pflegbare Felder für die Design-Vorlagen «Design 2»:
 * Goalietraining, Fussballschule, Betreuer werden, Mitglied werden, Top-Club 88.
 *
 * Ergänzt die zentrale Feld-Box aus inc/fcs-page-fields.php über den Filter
 * 'fcs_page_fields_config'. Die Vorlagen lesen die Werte mit
 * fcs_pf( 'schluessel', 'fallback' ) bzw. fcs_pf_lines( 'schluessel', array( … ) ).
 *
 * Listenfelder: ein Eintrag pro Zeile, Teile mit ' | ' getrennt (Format steht
 * jeweils im Feld-Label).
 */
defined( 'ABSPATH' ) || exit;

/* Bildangabe auflösen: Dateiname aus der Mediathek (relativ zu $basis)
   oder komplette URL (beginnt mit http). */
function fcsh_bild_url( $bild, $basis ) {
	$bild = trim( (string) $bild );
	if ( '' === $bild ) {
		return '';
	}
	return preg_match( '#^https?://#i', $bild ) ? $bild : $basis . $bild;
}

add_filter( 'fcs_page_fields_config', function ( $config ) {

	/* ── Goalietraining (Junioren) ── */
	$config['page-goalietraining.php'] = array(
		'gt_zeiten'  => array( 'label' => 'Trainingszeiten (eine Gruppe pro Zeile: Gruppe | Zeit | Ort)', 'type' => 'textarea' ),
		'gt_trainer' => array( 'label' => 'Goalietrainer (einer pro Zeile: Name | Rolle | Bilddatei aus der Mediathek oder Bild-URL)', 'type' => 'textarea' ),
	);

	/* ── Fussballschule (Junioren) ── */
	$config['page-fussballschule.php'] = array(
		'fs_intro'     => array( 'label' => 'Einleitungstext (**Text** wird fett angezeigt)', 'type' => 'textarea' ),
		'fs_karten'    => array( 'label' => 'Info-Karten (eine pro Zeile: Überschrift | Titel | Detail)', 'type' => 'textarea' ),
		'fs_pdf'       => array( 'label' => 'Flyer: PDF-Link (URL aus der Mediathek)', 'type' => 'url' ),
		'fs_pdf_label' => array( 'label' => 'Flyer: Beschriftung des Buttons', 'type' => 'text' ),
		'fs_team'      => array( 'label' => 'Leitungsteam (eine Person pro Zeile: Name | Rolle | Bilddatei aus der Mediathek oder Bild-URL)', 'type' => 'textarea' ),
	);

	/* ── Betreuer werden (Junioren) ── */
	$config['page-betreuer-werden.php'] = array(
		'bw_flyer_badge'  => array( 'label' => 'Flyer: Badge-Text (z. B. Trainer gesucht!)', 'type' => 'text' ),
		'bw_flyer_text'   => array( 'label' => 'Flyer: Aufruf-Text', 'type' => 'textarea' ),
		'bw_flyer_bild'   => array( 'label' => 'Flyer: Bilddatei aus der Mediathek oder Bild-URL', 'type' => 'text' ),
		'bw_schritte'     => array( 'label' => 'Ausbildungsweg (ein Schritt pro Zeile: Titel | Tags kommagetrennt | Beschreibung)', 'type' => 'textarea' ),
		'bw_kontakt_rolle'=> array( 'label' => 'Kontakt: Funktion (z. B. Ansprechperson & J+S Coach)', 'type' => 'text' ),
		'bw_kontakt_name' => array( 'label' => 'Kontakt: Name', 'type' => 'text' ),
		'bw_kontakt_tel'  => array( 'label' => 'Kontakt: Telefon (Anzeige, z. B. 079 159 82 38)', 'type' => 'text' ),
		'bw_kontakt_mail' => array( 'label' => 'Kontakt: E-Mail', 'type' => 'email' ),
		'bw_kontakt_note' => array( 'label' => 'Kontakt: Hinweistext unter den Kontaktangaben', 'type' => 'textarea' ),
	);

	/* ── Mitglied werden (Verein) ── */
	$config['page-mitglied-werden.php'] = array(
		'mw_sub'      => array( 'label' => 'Untertitel im Seitenkopf', 'type' => 'text' ),
		'mw_tracks'   => array( 'label' => 'Einstiegswege (einer pro Zeile: Badge | Titel | Text | Name | Rolle | E-Mail | Telefon — die erste Zeile wird hervorgehoben)', 'type' => 'textarea' ),
	);

	/* ── Top-Club 88 (Sponsoren) ── */
	$config['page-top-club-88.php'] = array(
		'tc_was_text' => array( 'label' => 'Text «Was ist der Top-Club 88?»', 'type' => 'textarea' ),
		'tc_vorteile' => array( 'label' => 'Mitglieder-Vorteile (einer pro Zeile: Titel | Beschreibung)', 'type' => 'textarea' ),
		'tc_vorstand' => array( 'label' => 'Vorstand (einer pro Zeile: Rolle | Name | E-Mail | Telefon | Bilddatei optional)', 'type' => 'textarea' ),
		'tc_cta_text' => array( 'label' => 'Mitglied-werden-Text (die Mail-Adresse wird automatisch angehängt)', 'type' => 'textarea' ),
		'tc_cta_mail' => array( 'label' => 'Mitglied-werden: E-Mail-Adresse', 'type' => 'email' ),
	);

	return $config;
} );
