<?php
/**
 * Feld-Definitionen für die Design-Vorlagen Anfahrt, Trainingslager
 * und Grümpelturnier.
 *
 * Ergänzt die Feld-Box «Seiteninhalte» (inc/fcs-page-fields.php) über
 * den Filter 'fcs_page_fields_config'. Die Vorlagen lesen die Werte
 * mit fcs_pf() / fcs_pf_lines(); leere Felder zeigen den Standardtext
 * der Vorlage.
 */
defined( 'ABSPATH' ) || exit;

add_filter( 'fcs_page_fields_config', function ( $config ) {

	/* ── Anfahrt (page-anfahrt.php) ── */
	$config['page-anfahrt.php'] = array(
		'an_haupt_name'      => array( 'label' => 'Hauptplatz: Name', 'type' => 'text' ),
		'an_haupt_adresse'   => array( 'label' => 'Hauptplatz: Adresse (Zeilen per Umbruch)', 'type' => 'textarea' ),
		'an_haupt_specs'     => array( 'label' => 'Hauptplatz: Angaben (eine pro Zeile: Bezeichnung | Wert)', 'type' => 'textarea' ),
		'an_neben_name'      => array( 'label' => 'Nebenplatz: Name', 'type' => 'text' ),
		'an_neben_adresse'   => array( 'label' => 'Nebenplatz: Adresse (Zeilen per Umbruch)', 'type' => 'textarea' ),
		'an_neben_specs'     => array( 'label' => 'Nebenplatz: Angaben (eine pro Zeile: Bezeichnung | Wert)', 'type' => 'textarea' ),
		'an_parkplaetze'     => array( 'label' => 'Parkplätze (einer pro Zeile: Name | Hinweis)', 'type' => 'textarea' ),
		'an_park_hinweis'    => array( 'label' => 'Hinweis unterhalb der Parkplatz-Liste', 'type' => 'textarea' ),
		'an_stollen_hinweis' => array( 'label' => 'Hinweis-Banner am Seitenende (z. B. Stollenschuhe)', 'type' => 'textarea' ),
	);

	/* ── Trainingslager (page-trainingslager.php) ── */
	$config['page-trainingslager.php'] = array(
		'tl_daten'         => array( 'label' => 'Datum (Anzeige, z. B. 20 – 24 Juli 2026)', 'type' => 'text' ),
		'tl_ort'           => array( 'label' => 'Ort (z. B. Zuchwil)', 'type' => 'text' ),
		'tl_anmeldung_url' => array( 'label' => 'Link zur Anmeldung', 'type' => 'url' ),
		'tl_facts'         => array( 'label' => 'Kennzahlen-Leiste (eine pro Zeile: Zahl | Beschriftung)', 'type' => 'textarea' ),
		'tl_impressionen'  => array( 'label' => 'Impressionen (eine pro Zeile: Titel | Text; Reihenfolge entspricht den 4 Fotos)', 'type' => 'textarea' ),
		'tl_campus'        => array( 'label' => 'Campus-Karten (eine pro Zeile: Titel | Text)', 'type' => 'textarea' ),
		'tl_programm'      => array( 'label' => 'Programm (eine pro Zeile: Zeitangabe | Titel | Beschreibung; die letzte Zeile wird rot hervorgehoben)', 'type' => 'textarea' ),
		'tl_flyer_bild'    => array( 'label' => 'Flyer: Bild (URL aus der Mediathek)', 'type' => 'url' ),
		'tl_flyer_text'    => array( 'label' => 'Flyer: Beschreibungstext', 'type' => 'textarea' ),
		'tl_cta_lead'      => array( 'label' => 'Aufruf-Text im Abschluss-Block («Bist du dabei?»)', 'type' => 'textarea' ),
		'tl_kontakte'      => array( 'label' => 'Kontaktpersonen (eine pro Zeile: Name | Rolle | Telefon)', 'type' => 'textarea' ),
	);

	/* ── Grümpelturnier (page-gruempelturnier.php) ── */
	$config['page-gruempelturnier.php'] = array(
		'gt_kopfzeile'        => array( 'label' => 'Kopfzeile über dem Titel (z. B. 33. Dorfturnier · 66. Grümpelturnier)', 'type' => 'text' ),
		'gt_titel'            => array( 'label' => 'Seitentitel', 'type' => 'text' ),
		'gt_datum_ort'        => array( 'label' => 'Datum & Ort (Zeile unter dem Titel)', 'type' => 'text' ),
		'gt_programm'         => array( 'label' => 'Programm (ein Tag pro Zeile: Wochentag | Datum | Kurzlabel | Badge | Titel | Beschreibung; die erste Zeile erhält das graue Badge)', 'type' => 'textarea' ),
		'gt_kategorien_titel' => array( 'label' => 'Überschrift Kategorien (z. B. Kategorien Samstag, 20. Juni)', 'type' => 'text' ),
		'gt_kategorien'       => array( 'label' => 'Kategorien (eine pro Zeile: Gruppe | Name | Zusatz | Spielplan-PDF-URL)', 'type' => 'textarea' ),
		'gt_reglement_titel'  => array( 'label' => 'Reglement: Titel (z. B. Reglement Grümpelturnier 2026)', 'type' => 'text' ),
		'gt_reglement_pdf'    => array( 'label' => 'Reglement: PDF-Link (URL aus der Mediathek)', 'type' => 'url' ),
		'gt_rahmenprogramm'   => array( 'label' => 'Rahmenprogramm (ein Punkt pro Zeile: Titel | Text)', 'type' => 'textarea' ),
		'gt_sponsoren_dank'   => array( 'label' => 'Sponsoren: Dankestext unter der Überschrift', 'type' => 'textarea' ),
		'gt_sponsor_haupt'    => array( 'label' => 'Hauptsponsor (einer pro Zeile: Name | Logo-URL | Website)', 'type' => 'textarea' ),
		'gt_sponsor_event'    => array( 'label' => 'Eventsponsoren (einer pro Zeile: Name | Logo-URL | Website)', 'type' => 'textarea' ),
		'gt_sponsor_weitere'  => array( 'label' => 'Weitere Sponsoren (einer pro Zeile: Name | Logo-URL | Website)', 'type' => 'textarea' ),
		'gt_anmeldeschluss'   => array( 'label' => 'Anmeldeschluss (z. B. 7. Juni 2026)', 'type' => 'text' ),
		'gt_anmeldung_url'    => array( 'label' => 'Link zur Anmeldung (leer = Standardseite /anmeldung-gruempelturnier)', 'type' => 'url' ),
		'gt_cta_titel'        => array( 'label' => 'Anmeldebox: Titel (Zeilen ergeben Umbrüche)', 'type' => 'textarea' ),
	);

	return $config;
} );
