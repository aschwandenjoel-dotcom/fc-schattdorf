<?php
/**
 * Vorstand – Inhalte bleiben im WordPress-Editor, nur die Form ist neu.
 * Greift automatisch für die Seite mit dem Slug "vorstand".
 */
defined( 'ABSPATH' ) || exit;

add_filter( 'body_class', function ( $c ) {
	$c[] = 'fcx-wide';
	$c[] = 'fcx-people';
	return $c;
} );

add_action( 'wp_enqueue_scripts', function () {
	$dir = get_stylesheet_directory();
	$uri = get_stylesheet_directory_uri();
	// Priorität 20: muss NACH wp-block-library drucken, sonst gewinnt deren
	// .wp-block-column{flex-basis:0} gegen unser Grid-Layout (gleiche Spezifität).
	wp_enqueue_style( 'fcs-vorstand', $uri . '/assets/fcs-vorstand.css', [], filemtime( $dir . '/assets/fcs-vorstand.css' ) );
}, 20 );

get_header();
?>

<div class="fcvo-hero">
	<div class="fcvo-hero__eyebrow">FC Schattdorf</div>
	<h1 class="fcvo-hero__title">Vorstand</h1>
	<p class="fcvo-hero__sub">Die Menschen hinter dem Verein — ehrenamtlich im Einsatz für den FC Schattdorf.</p>
</div>

<section class="fcx-sec fcvo-body">
	<?php /* Die Überschrift im Inhalt selbst wird per CSS ausgeblendet, da der Hero sie bereits trägt. */ ?>
	<div class="fcvo-grid">
		<?php
		while ( have_posts() ) :
			the_post();
			the_content();
		endwhile;
		?>
	</div>
</section>

<?php get_footer();
