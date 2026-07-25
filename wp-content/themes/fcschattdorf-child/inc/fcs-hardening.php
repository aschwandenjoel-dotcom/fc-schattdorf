<?php
/**
 * Härtung: Sicherheits-Header, keine Versions-Preisgabe,
 * keine öffentliche Benutzer-Auflistung über die REST-API.
 */
defined( 'ABSPATH' ) || exit;

/* WordPress-Version nicht im Generator-Meta-Tag preisgeben */
remove_action( 'wp_head', 'wp_generator' );
add_filter( 'the_generator', '__return_empty_string' );

/* Benutzer-Endpunkte der REST-API nur für angemeldete Nutzer
   (verhindert Benutzernamen-Enumeration über /wp-json/wp/v2/users) */
add_filter( 'rest_endpoints', function ( $endpoints ) {
	if ( is_user_logged_in() ) {
		return $endpoints;
	}
	foreach ( array( '/wp/v2/users', '/wp/v2/users/(?P<id>[\d]+)' ) as $route ) {
		unset( $endpoints[ $route ] );
	}
	return $endpoints;
} );

/* Sicherheits-Header (kein CSP: das Theme nutzt Inline-Skripte/-Styles) */
add_action( 'send_headers', function () {
	header( 'X-Frame-Options: SAMEORIGIN' );
	header( 'X-Content-Type-Options: nosniff' );
	header( 'Referrer-Policy: strict-origin-when-cross-origin' );
	header( 'Permissions-Policy: camera=(), microphone=(), geolocation=()' );
	if ( is_ssl() ) {
		header( 'Strict-Transport-Security: max-age=31536000' );
	}
} );
