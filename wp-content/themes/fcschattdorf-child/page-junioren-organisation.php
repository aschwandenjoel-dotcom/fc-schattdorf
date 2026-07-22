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

$up = wp_upload_dir()['baseurl'] . '/2026/06/';

$personen = [
    [ 'name' => 'Iwan Herger',       'role' => 'Juniorenobmann & Leiter 11er Fussball', 'email' => 'hergeriwan@hotmail.com',            'phone' => '078 698 91 95', 'img' => 'Iwan_Herger.jpg' ],
    [ 'name' => 'Jacqueline Kempf',  'role' => 'Leiterin KIFU',                          'email' => 'jacqueline.kempf-imholz@gmx.ch',   'phone' => '078 795 29 67', 'img' => 'Jacqueline_Kempf.jpg' ],
    [ 'name' => 'Karl Arnold',        'role' => 'J&S Coach',                              'email' => 'tschuedi.kari@gmail.com',           'phone' => '079 159 82 38', 'img' => 'ArnoldKarl.jpg' ],
    [ 'name' => 'Ivo Bissig',         'role' => 'Material & Projekte',                    'email' => 'ivo.bissig@ur.ch',                  'phone' => '079 251 65 73', 'img' => 'Ivo_Bissig_2.jpg' ],
    [ 'name' => 'Dominique Scheiber', 'role' => 'Kommunikation & Social Media',           'email' => 'kommunikation@fcschattdorf.ch',     'phone' => '079 296 27 26', 'img' => 'IMG_8327.jpeg' ],
    [ 'name' => 'Linus Epp',          'role' => 'Presse',                                 'email' => 'linus.epp@gmx.ch',                  'phone' => '079 223 38 51', 'img' => 'Silhouette_Male_v2.jpg' ],
    [ 'name' => 'May Van der Ven',    'role' => 'Social Media',                           'email' => '',                                  'phone' => '',              'img' => 'May_Van_der_Ven.jpg' ],
    [ 'name' => 'Lea Deplazes',       'role' => 'Social Media',                           'email' => '',                                  'phone' => '',              'img' => '3a0f4db6-105d-4a7c-809d-66f56c9468e1.jpeg' ],
    [ 'name' => 'Nadine Scheiber',    'role' => 'Social Media',                           'email' => '',                                  'phone' => '',              'img' => 'IMG_8335.jpeg' ],
    [ 'name' => 'Aline Kempf',        'role' => 'Fotos',                                  'email' => 'aeli-kempf@hotmail.com',            'phone' => '',              'img' => 'Aline_Kempf.jpeg' ],
    [ 'name' => 'Tamara Eller',       'role' => 'Fotos',                                  'email' => 'txmara.llr@gmail.com',              'phone' => '',              'img' => 'Tamara_Eller.jpg' ],
];

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
					<img src="<?php echo esc_url( $up . $p['img'] ); ?>" alt="<?php echo esc_attr( $p['name'] ); ?>">
				</figure>
				<h3 class="wp-block-heading"><?php echo esc_html( $p['name'] ); ?></h3>
				<p>
					<strong><?php echo esc_html( $p['role'] ); ?></strong>
					<?php if ( $p['email'] ) : ?>
						<br><a href="mailto:<?php echo esc_attr( $p['email'] ); ?>">E-Mail</a>
					<?php endif; ?>
					<?php if ( $p['phone'] ) : ?>
						<br>M: <?php echo esc_html( $p['phone'] ); ?>
					<?php endif; ?>
				</p>
			</div>
			<?php endforeach; ?>
		</div>
		<?php endforeach; ?>
	</div>
</section>

<?php get_footer(); ?>
