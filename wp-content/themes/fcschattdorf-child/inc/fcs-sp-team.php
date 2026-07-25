<?php
/**
 * SportsPress-Teamseiten (/team/…) stilllegen.
 *
 * Die sp_team-Einzelseiten liefern HTTP 500, duplizieren die
 * gepflegten Teamseiten unter /aktive/ bzw. /junioren/teams/ und
 * standen trotzdem in der Sitemap (Suchmaschinen crawlten Fehlerseiten).
 * Hier: 301-Weiterleitung auf die richtige Teamseite + Ausschluss aus
 * der Sitemap. SportsPress selbst (Teams als Datencontainer) bleibt
 * unangetastet.
 */
defined( 'ABSPATH' ) || exit;

/* sp_team (und einzelne Spieler/Staff) aus der WP-Sitemap nehmen */
add_filter( 'wp_sitemaps_post_types', function ( $post_types ) {
	unset( $post_types['sp_team'], $post_types['sp_player'], $post_types['sp_staff'] );
	return $post_types;
} );

/* /team/<slug>/ -> gepflegte Teamseite (301) */
add_action( 'template_redirect', function () {
	if ( ! is_singular( 'sp_team' ) ) {
		return;
	}
	$slug = get_post_field( 'post_name', get_queried_object_id() );
	$map  = array(
		'1-mannschaft'   => 'aktive/1-mannschaft',
		'2-mannschaft'   => 'aktive/2-mannschaft',
		'3-mannschaft'   => 'aktive/3-mannschaft',
		'frauen-uri-1'   => 'aktive/frauen-uri-1',
		'frauen-uri-2'   => 'aktive/frauen-uri-2',
		'senioren-uri-1' => 'aktive/senioren-uri-1',
		'junioren-a'     => 'junioren/teams/junioren-a-junioren',
		'junioren-d'     => 'junioren/teams/junioren-d-junioren',
		/* b/c haben je zwei Teams -> Übersicht */
		'junioren-b'     => 'junioren/teams',
		'junioren-c'     => 'junioren/teams',
	);
	$ziel = isset( $map[ $slug ] ) ? home_url( '/' . $map[ $slug ] . '/' ) : home_url( '/' );
	wp_safe_redirect( $ziel, 301 );
	exit;
} );
