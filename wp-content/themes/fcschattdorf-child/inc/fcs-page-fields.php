<?php
/**
 * Pflegbare Textbausteine für Seiten mit Design-Vorlage.
 *
 * Seiten wie Kontakt oder Helfereinsätze haben ein festes Layout (Karten,
 * Icons, Buttons) — der Fliesstext-Editor würde es zerstören. Stattdessen
 * bekommen sie eine Feld-Box («Seiteninhalte») unterhalb des Editors:
 * pro Vorlage sind hier die pflegbaren Felder definiert, die Vorlage liest
 * sie über fcs_pf( 'schluessel', 'fallback' ).
 *
 * Feldtypen: text, textarea (mehrzeilig; bei Listen ein Eintrag pro Zeile),
 * url, email.
 */
defined( 'ABSPATH' ) || exit;

function fcs_page_fields_config() {
	/* Weitere Vorlagen können ihre Felder über den Filter
	   'fcs_page_fields_config' beisteuern (eigene inc/fcs-fields-*.php). */
	return apply_filters( 'fcs_page_fields_config', array(
		'page-kontakt.php' => array(
			'kontakt_adresse' => array( 'label' => 'Adresse (Zeilen per Umbruch)', 'type' => 'textarea' ),
			'kontakt_tel'     => array( 'label' => 'Telefon (Anzeige, z. B. 041 870 75 65)', 'type' => 'text' ),
			'kontakt_mail'    => array( 'label' => 'E-Mail', 'type' => 'email' ),
		),
		'page-juniorenkonzept.php' => array(
			'jk_titel' => array( 'label' => 'Titel des Download-Blocks', 'type' => 'text' ),
			'jk_text'  => array( 'label' => 'Beschreibungstext', 'type' => 'textarea' ),
			'jk_pdf'   => array( 'label' => 'PDF-Link (URL aus der Mediathek)', 'type' => 'url' ),
		),
		'page-helfereinsaetze.php' => array(
			'he_portal_text' => array( 'label' => 'Text Portal-Hinweis (der Portal-Link wird automatisch angehängt)', 'type' => 'textarea' ),
			'he_portal_url'  => array( 'label' => 'Link zum Helferportal', 'type' => 'url' ),
			'he_zielgruppen' => array( 'label' => 'Wer soll sich anmelden? (ein Eintrag pro Zeile)', 'type' => 'textarea' ),
			'he_pdf'         => array( 'label' => 'Anleitung: PDF-Link (URL aus der Mediathek)', 'type' => 'url' ),
			'he_pdf_label'   => array( 'label' => 'Anleitung: Beschriftung', 'type' => 'text' ),
		),
		'page-schiedsrichter.php' => array(
			'sr_spielleiter' => array( 'label' => 'Spielleiter (ein Name pro Zeile)', 'type' => 'textarea' ),
		),
		'page-vorfall-melden.php' => array(
			'vf_intro'         => array( 'label' => 'Einleitung', 'type' => 'textarea' ),
			'vf_ssi_text'      => array( 'label' => 'Text Swiss Sport Integrity', 'type' => 'textarea' ),
			'vf_ssi_url'       => array( 'label' => 'Link «Online melden»', 'type' => 'url' ),
			'vf_hotline'       => array( 'label' => 'Hotline-Nummer (Anzeige)', 'type' => 'text' ),
			'vf_hotline_zeiten'=> array( 'label' => 'Hotline-Zeiten', 'type' => 'text' ),
			'vf_meldebar'      => array( 'label' => 'Was kann gemeldet werden? (ein Eintrag pro Zeile)', 'type' => 'textarea' ),
			'vf_kontakte_lead' => array( 'label' => 'Einleitung interne Ansprechpersonen', 'type' => 'textarea' ),
			'vf_kontakte'      => array( 'label' => "Ansprechpersonen (eine pro Zeile: Rolle | Name | E-Mail | Telefon)", 'type' => 'textarea' ),
			'vf_notice'        => array( 'label' => 'Vertraulichkeits-Hinweis', 'type' => 'textarea' ),
		),
	) );
}

/* Anzeige-Nummer -> tel:-Link (041 870 75 65 -> tel:+41418707565) */
function fcsh_tel_href( $display ) {
	$digits = preg_replace( '/\D+/', '', (string) $display );
	if ( '' === $digits ) {
		return '';
	}
	return 'tel:' . ( '0' === $digits[0] ? '+41' . substr( $digits, 1 ) : '+' . $digits );
}

/* Feldwert lesen: Seiten-Meta, sonst Fallback (= bisheriger fixer Text) */
function fcs_pf( $key, $fallback = '' ) {
	$v = get_post_meta( get_the_ID(), 'fcs_' . $key, true );
	return '' !== trim( (string) $v ) ? $v : $fallback;
}

/* Mehrzeilen-Feld als Liste (eine Zeile = ein Eintrag) */
function fcs_pf_lines( $key, $fallback = array() ) {
	$v = get_post_meta( get_the_ID(), 'fcs_' . $key, true );
	if ( '' === trim( (string) $v ) ) {
		return $fallback;
	}
	return array_values( array_filter( array_map( 'trim', explode( "\n", $v ) ) ) );
}

/* ── Feld-Box registrieren (nur auf Seiten mit passender Vorlage) ── */
add_action( 'add_meta_boxes_page', function ( $post ) {
	$tpl    = get_page_template_slug( $post );
	$config = fcs_page_fields_config();
	if ( empty( $config[ $tpl ] ) ) {
		return;
	}
	$fields = $config[ $tpl ];
	add_meta_box( 'fcs-page-fields', 'Seiteninhalte (werden auf der Seite angezeigt)', function ( $post ) use ( $fields ) {
		wp_nonce_field( 'fcs_pf_save', 'fcs_pf_nonce' );
		echo '<p class="description">Diese Felder füllen die festen Layout-Bausteine der Seite. Leere Felder zeigen den Standardtext der Vorlage.</p>';
		foreach ( $fields as $key => $f ) {
			$val = get_post_meta( $post->ID, 'fcs_' . $key, true );
			echo '<p><label for="fcs_' . esc_attr( $key ) . '"><strong>' . esc_html( $f['label'] ) . '</strong></label><br>';
			if ( 'textarea' === $f['type'] ) {
				echo '<textarea id="fcs_' . esc_attr( $key ) . '" name="fcs_' . esc_attr( $key ) . '" rows="4" style="width:100%;">' . esc_textarea( $val ) . '</textarea>';
			} else {
				echo '<input type="text" id="fcs_' . esc_attr( $key ) . '" name="fcs_' . esc_attr( $key ) . '" value="' . esc_attr( $val ) . '" style="width:100%;">';
			}
			echo '</p>';
		}
	}, 'page', 'normal', 'high' );
} );

add_action( 'save_post_page', function ( $post_id ) {
	if ( ! isset( $_POST['fcs_pf_nonce'] )
		|| ! wp_verify_nonce( $_POST['fcs_pf_nonce'], 'fcs_pf_save' )
		|| defined( 'DOING_AUTOSAVE' ) && DOING_AUTOSAVE
		|| ! current_user_can( 'edit_post', $post_id ) ) {
		return;
	}
	$config = fcs_page_fields_config();
	$tpl    = get_page_template_slug( $post_id );
	if ( empty( $config[ $tpl ] ) ) {
		return;
	}
	foreach ( $config[ $tpl ] as $key => $f ) {
		if ( ! isset( $_POST[ 'fcs_' . $key ] ) ) {
			continue;
		}
		$raw = wp_unslash( $_POST[ 'fcs_' . $key ] );
		switch ( $f['type'] ) {
			case 'textarea': $val = sanitize_textarea_field( $raw ); break;
			case 'url':      $val = esc_url_raw( $raw ); break;
			case 'email':    $val = sanitize_email( $raw ); break;
			default:         $val = sanitize_text_field( $raw );
		}
		update_post_meta( $post_id, 'fcs_' . $key, $val );
	}
} );
