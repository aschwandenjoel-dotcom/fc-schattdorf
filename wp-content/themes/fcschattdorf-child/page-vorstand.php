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

/* Die Porträts liegen als «medium» (200 px) im Editor-Inhalt, WordPress
   schreibt daraus sizes="… 200px". Der Browser laedt deshalb die
   200-px-Datei und zieht sie auf die 375 px breite Karte.
   Auf Retina-Laptops faellt das nicht auf: dort rechnet der Browser
   200 x 2 = 400 und nimmt die 683-px-Datei. Auf einem externen Monitor
   (DPR 1) nimmt er die 200-px-Datei — sichtbar unscharf.
   Die grossen Dateien liegen alle auf dem Server (bis 1280 px), dem
   Browser wurde nur die falsche Breite genannt.
   Kartenbreite: Grid max. 1180 px, 3 Spalten, 1.75rem Abstand
   -> (1180 - 56) / 3 = 375 px; darunter 2 Spalten (<=900 px), 1 (<=560 px).
   Begrenzt auf kleine Quellgroessen, damit z. B. das Logo unberuehrt bleibt. */
add_filter( 'wp_calculate_image_sizes', function ( $sizes, $size ) {
	$breite = is_array( $size ) ? (int) $size[0] : 0;
	if ( $breite > 0 && $breite <= 400 ) {
		return '(max-width: 560px) 92vw, (max-width: 900px) 45vw, 375px';
	}
	return $sizes;
}, 10, 2 );

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
