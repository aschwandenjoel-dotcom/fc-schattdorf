<?php
/**
 * Template Name: Goalietraining
 * Template Post Type: page
 */
defined( 'ABSPATH' ) || exit;

add_action( 'wp_enqueue_scripts', function () {
    $dir = get_stylesheet_directory();
    $uri = get_stylesheet_directory_uri();
    wp_enqueue_style( 'fcs-junioren-info', $uri . '/assets/fcs-junioren-info.css', [], filemtime( $dir . '/assets/fcs-junioren-info.css' ) );
}, 5 );

$up = wp_upload_dir()['baseurl'] . '/2026/06/';

get_header();
?>

<div class="fcji-page">

  <div class="fcji-hero">
    <img src="<?php echo esc_url( $up . 'goalie_training.jpg' ); ?>" alt="Goalietraining FC Schattdorf">
    <div class="fcji-hero__overlay">
      <h1 class="fcji-hero__title">Goalietraining</h1>
    </div>
  </div>

  <!-- ── Trainingszeiten ── -->
  <section class="fcji-section fcji-section--white">
    <div class="fcji-inner">
      <div class="fcji-section__header">
        <h2>Trainingszeiten & Ort</h2>
      </div>
      <div class="fcji-info-grid">
        <div class="fcji-info-card">
          <div class="fcji-info-card__label">Junioren D &amp; E</div>
          <div class="fcji-info-card__title">Montag · 17:45 – 19:00 Uhr</div>
          <div class="fcji-info-card__detail">Hauptplatz Grüner Wald (bei Schönwetter)</div>
        </div>
        <div class="fcji-info-card">
          <div class="fcji-info-card__label">Junioren A, B &amp; C</div>
          <div class="fcji-info-card__title">Montag · 19:00 – 20:00 Uhr</div>
          <div class="fcji-info-card__detail">Hauptplatz Grüner Wald (bei Schönwetter)</div>
        </div>
      </div>
    </div>
  </section>

  <!-- ── Goalietrainer ── -->
  <section class="fcji-section fcji-section--gray">
    <div class="fcji-inner">
      <div class="fcji-section__header">
        <h2>Goalietrainer</h2>
      </div>
      <div class="fcji-person-grid">
        <div class="fcji-card">
          <div class="fcji-card__photo">
            <img src="<?php echo esc_url( $up . 'Silhouette_Male_v2.jpg' ); ?>" alt="Luca Aschwanden">
          </div>
          <div class="fcji-card__info">
            <div class="fcji-card__name">Luca Aschwanden</div>
            <div class="fcji-card__role">Betreuer Goalietraining Kifu</div>
          </div>
        </div>
        <div class="fcji-card">
          <div class="fcji-card__photo">
            <img src="<?php echo esc_url( $up . 'GianGisler.jpg' ); ?>" alt="Gian Gisler">
          </div>
          <div class="fcji-card__info">
            <div class="fcji-card__name">Gian Gisler</div>
            <div class="fcji-card__role">Betreuer Goalietraining Kifu</div>
          </div>
        </div>
        <div class="fcji-card">
          <div class="fcji-card__photo">
            <img src="<?php echo esc_url( $up . 'Raphael_Imhof.jpg' ); ?>" alt="Raphael Imhof">
          </div>
          <div class="fcji-card__info">
            <div class="fcji-card__name">Raphael Imhof</div>
            <div class="fcji-card__role">Torhütertrainer 11er Fussball</div>
          </div>
        </div>
      </div>
    </div>
  </section>

</div>

<?php get_footer(); ?>
