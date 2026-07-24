<?php
/**
 * Template Name: Juniorengeschichte
 * Template Post Type: page
 *
 * Fliesstext (Abschnitte mit H2 + Absätzen) wird im WordPress-Editor
 * gepflegt; Titel und Hero-Bild kommen aus der Vorlage.
 */
defined( 'ABSPATH' ) || exit;

add_action( 'wp_enqueue_scripts', function () {
    $dir = get_stylesheet_directory();
    $uri = get_stylesheet_directory_uri();
    wp_enqueue_style( 'fcs-juniorengeschichte', $uri . '/assets/fcs-juniorengeschichte.css', [], filemtime( $dir . '/assets/fcs-juniorengeschichte.css' ) );
}, 5 );

add_filter( 'body_class', function ( $c ) { $c[] = 'fcx-wine-page'; return $c; } );

$up = wp_upload_dir()['baseurl'] . '/2026/06/';

get_header();
?>

<div class="fcjg-page">

  <!-- ── Title ── -->
  <div class="fcjg-page-title">
    <h1>Geschichte der Juniorenabteilung</h1>
  </div>

  <!-- ── Hero Image ── -->
  <div class="fcjg-hero-img">
    <img src="<?php echo esc_url( $up . 'Juniorenabteilung.jpg' ); ?>" alt="Juniorenabteilung FC Schattdorf">
  </div>

  <!-- ── Inhalt aus dem Editor ── -->
  <div class="fcjg-content">
    <div class="fcjg-content__inner">
      <?php
      while ( have_posts() ) :
          the_post();
          the_content();
      endwhile;
      ?>
    </div>
  </div>

</div><!-- .fcjg-page -->

<?php get_footer(); ?>
