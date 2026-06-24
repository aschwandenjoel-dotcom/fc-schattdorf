<?php
/**
 * FC Schattdorf Child-Theme – Funktionen
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit; // Direktzugriff verhindern
}

/**
 * Eltern- und Child-Styles laden.
 */
function fcs_enqueue_styles() {
	// Astra (Eltern-Theme)
	wp_enqueue_style(
		'astra-parent-style',
		get_template_directory_uri() . '/style.css',
		array(),
		wp_get_theme( 'astra' )->get( 'Version' )
	);

	// Child-Theme Basis
	wp_enqueue_style(
		'fcs-child-style',
		get_stylesheet_uri(),
		array( 'astra-parent-style' ),
		wp_get_theme()->get( 'Version' )
	);

	// Eigene Anpassungen
	wp_enqueue_style(
		'fcs-custom',
		get_stylesheet_directory_uri() . '/assets/custom.css',
		array( 'fcs-child-style' ),
		wp_get_theme()->get( 'Version' )
	);
}
add_action( 'wp_enqueue_scripts', 'fcs_enqueue_styles' );

/**
 * Theme-Grundlagen.
 */
function fcs_theme_setup() {
	add_theme_support( 'title-tag' );
	add_theme_support( 'post-thumbnails' );
	add_theme_support( 'custom-logo' );

	// Menü-Standorte
	register_nav_menus( array(
		'primary' => __( 'Hauptmenü', 'fcschattdorf-child' ),
		'footer'  => __( 'Footer-Menü', 'fcschattdorf-child' ),
	) );
}
add_action( 'after_setup_theme', 'fcs_theme_setup' );
