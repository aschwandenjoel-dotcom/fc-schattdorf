<?php
/**
 * Template Name: Junioren Organisation
 * Template Post Type: page
 *
 * Gleiches Layout wie die Vorstandsseite (page-vorstand.php): Hero +
 * Karten-Grid im fcvo-* Stil, gespeist aus $personen statt Gutenberg-Content.
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
	// Priorität 20: muss NACH wp-block-library drucken, siehe page-vorstand.php.
	wp_enqueue_style( 'fcs-vorstand', $uri . '/assets/fcs-vorstand.css', [], filemtime( $dir . '/assets/fcs-vorstand.css' ) );
}, 20 );

/* Personen aus der Datenbank (WP-Admin -> Personen, Bereich «Junioren-Organisation»).
   Registrierung des Inhaltstyps und Abfrage: inc/fcs-personen.php */
$personen = fcs_get_personen( 'junioren-organisation' );

get_header();
?>

<div class="fcvo-hero">
	<div class="fcvo-hero__eyebrow">FC Schattdorf</div>
	<h1 class="fcvo-hero__title">Junioren Organisation</h1>
	<p class="fcvo-hero__sub">Die Menschen hinter der Juniorenabteilung — ehrenamtlich im Einsatz für den FC Schattdorf.</p>
</div>

<section class="fcx-sec fcvo-body">
	<div class="fcvo-grid">
		<?php foreach ( array_chunk( $personen, 3 ) as $reihe ) : ?>
		<div class="wp-block-columns">
			<?php foreach ( $reihe as $p ) : ?>
			<div class="wp-block-column">
				<figure class="wp-block-image">
					<img src="<?php echo esc_url( fcs_person_bild_url( $p['bild'] ) ); ?>" alt="<?php echo esc_attr( $p['name'] ); ?>">
				</figure>
				<h3 class="wp-block-heading"><?php echo esc_html( $p['name'] ); ?></h3>
				<p>
					<strong><?php echo esc_html( $p['rolle'] ); ?></strong>
					<?php if ( $p['email'] ) : ?>
						<br><a href="mailto:<?php echo esc_attr( $p['email'] ); ?>">E-Mail</a>
					<?php endif; ?>
					<?php if ( $p['tel'] ) : ?>
						<br>M: <?php echo esc_html( $p['tel'] ); ?>
					<?php endif; ?>
				</p>
			</div>
			<?php endforeach; ?>
		</div>
		<?php endforeach; ?>
	</div>
</section>

<?php get_footer(); ?>
