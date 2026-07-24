<?php
/**
 * Template for Datenschutzerklärung page (slug: datenschutzerklaerung, ID: 3)
 * Inhalt wird im WordPress-Editor gepflegt (the_content).
 */
defined( 'ABSPATH' ) || exit;

add_action( 'wp_enqueue_scripts', function () {
	$dir = get_stylesheet_directory();
	$uri = get_stylesheet_directory_uri();
	wp_enqueue_style( 'fcs-prose', $uri . '/assets/fcs-prose.css', [], filemtime( $dir . '/assets/fcs-prose.css' ) );
}, 5 );

get_header();
?>

<div class="fcx-prosepage">
  <h1><?php the_title(); ?></h1>
  <?php
  while ( have_posts() ) :
	  the_post();
	  the_content();
  endwhile;
  ?>
</div>

<?php get_footer(); ?>
