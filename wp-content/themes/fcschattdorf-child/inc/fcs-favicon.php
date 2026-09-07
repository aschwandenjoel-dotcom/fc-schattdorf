<?php
/**
 * Favicon aus dem Theme, solange im Customizer kein Website-Icon gesetzt ist.
 *
 * Hintergrund: Nach dem Domainwechsel (08.09.2026) zeigte der Browser das
 * WordPress-«W» — die Seite hatte nie ein Website-Icon, und WordPress
 * beantwortet /favicon.ico dann mit seinem eigenen Logo. Die alte Seite
 * hatte das Vereinsemblem (rotes FCS, schwarze Spielerfigur); genau das
 * liegt jetzt in assets/img/favicon/, aus fcs-logo.svg abgeleitet (die
 * Figur ist dort weiss und wurde für helle Browser-Tabs dunkel gesetzt).
 *
 * Wird im Customizer (Website-Identität → Website-Icon) ein Icon gesetzt,
 * gewinnt dieses: WordPress gibt dann seine eigenen Tags aus und dieses
 * Modul hält sich zurück.
 */
defined( 'ABSPATH' ) || exit;

function fcs_favicon_url( $datei ) {
	return get_stylesheet_directory_uri() . '/assets/img/favicon/' . $datei;
}

/* <head>: SVG für moderne Browser, PNG-Rückfall, Apple-Touch-Icon */
add_action( 'wp_head', function () {
	if ( has_site_icon() ) {
		return;
	}
	printf( '<link rel="icon" href="%s" sizes="any">' . "\n", esc_url( fcs_favicon_url( 'favicon.ico' ) ) );
	printf( '<link rel="icon" type="image/svg+xml" href="%s">' . "\n", esc_url( fcs_favicon_url( 'favicon.svg' ) ) );
	printf( '<link rel="icon" type="image/png" sizes="32x32" href="%s">' . "\n", esc_url( fcs_favicon_url( 'favicon-32.png' ) ) );
	printf( '<link rel="icon" type="image/png" sizes="192x192" href="%s">' . "\n", esc_url( fcs_favicon_url( 'favicon-192.png' ) ) );
	printf( '<link rel="apple-touch-icon" href="%s">' . "\n", esc_url( fcs_favicon_url( 'apple-touch-icon.png' ) ) );
}, 2 );

/* /favicon.ico ohne Website-Icon: WordPress würde auf sein «W» umleiten —
   stattdessen auf das Vereinsemblem. */
add_action( 'do_faviconico', function () {
	if ( has_site_icon() ) {
		return;
	}
	wp_redirect( fcs_favicon_url( 'favicon.ico' ), 302 );
	exit;
} );

/* Login-Seite und Admin haben keinen wp_head — dort dieselben Tags. */
add_action( 'login_head', function () {
	if ( ! has_site_icon() ) {
		printf( '<link rel="icon" type="image/png" sizes="32x32" href="%s">' . "\n", esc_url( fcs_favicon_url( 'favicon-32.png' ) ) );
	}
} );
add_action( 'admin_head', function () {
	if ( ! has_site_icon() ) {
		printf( '<link rel="icon" type="image/png" sizes="32x32" href="%s">' . "\n", esc_url( fcs_favicon_url( 'favicon-32.png' ) ) );
	}
} );
