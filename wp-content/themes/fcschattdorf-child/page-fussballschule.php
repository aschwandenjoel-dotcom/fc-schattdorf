<?php
/**
 * Template Name: Fussballschule
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
    <img src="<?php echo esc_url( $up . 'fussballschule_photo.jpg' ); ?>" alt="Fussballschule FC Schattdorf">
    <div class="fcji-hero__overlay">
      <h1 class="fcji-hero__title">Fussballschule</h1>
    </div>
  </div>

  <!-- ── Info ── -->
  <section class="fcji-section fcji-section--white">
    <div class="fcji-inner">
      <p class="fcji-intro">Ab dem 16. März 2026 findet jeweils <strong>montags von 17:45 bis 19:00 Uhr</strong> die Fussballschule für Kinder mit Jahrgang 2019 und 2020 auf dem <strong>Sportplatz Grüner Wald</strong> statt. Wir freuen uns auf deinen Besuch!</p>
      <div class="fcji-info-grid">
        <div class="fcji-info-card">
          <div class="fcji-info-card__label">Wann</div>
          <div class="fcji-info-card__title">Montag · 17:45 – 19:00 Uhr</div>
          <div class="fcji-info-card__detail">Ab 16. März 2026</div>
        </div>
        <div class="fcji-info-card">
          <div class="fcji-info-card__label">Für wen</div>
          <div class="fcji-info-card__title">Jahrgang 2019 &amp; 2020</div>
          <div class="fcji-info-card__detail">Kinder im Vorschul- und Schulalter</div>
        </div>
        <div class="fcji-info-card">
          <div class="fcji-info-card__label">Ort</div>
          <div class="fcji-info-card__title">Sportplatz Grüner Wald</div>
          <div class="fcji-info-card__detail">Schattdorf</div>
        </div>
      </div>
      <a href="<?php echo esc_url( $up . 'Flyer_Fussballschule.pdf' ); ?>" class="fcji-pdf-btn" target="_blank" rel="noopener">
        <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M12 15V3m0 12-4-4m4 4 4-4M3 17v2a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-2"/></svg>
        Flyer Fussballschule (PDF)
      </a>
    </div>
  </section>

  <!-- ── Leitungsteam ── -->
  <section class="fcji-section fcji-section--gray">
    <div class="fcji-inner">
      <div class="fcji-section__header">
        <h2>Leitungsteam</h2>
      </div>
      <div class="fcji-person-grid">
        <?php
        $team = [
            [ 'name' => 'Jacqueline Kempf', 'role' => 'Leiterin Fussballschule',   'img' => 'Jaqueline_Kempf.jpg' ],
            [ 'name' => 'Rachel Arnold',    'role' => 'Betreuer Fussballschule',    'img' => 'rachel_ajpg.jpg' ],
            [ 'name' => 'Adriana Fedier',   'role' => 'Betreuerin Fussballschule',  'img' => 'Adi_Fedier.jpg' ],
            [ 'name' => 'Robin Mahrow',     'role' => 'Betreuer Fussballschule',    'img' => 'Rubi_Mahrow.jpg' ],
            [ 'name' => 'Jasmin Jaun',      'role' => 'Betreuerin Fussballschule',  'img' => 'Jasmin_Jaun_1.jpg' ],
            [ 'name' => 'Orlando Gisler',   'role' => 'Betreuer Fussballschule',    'img' => 'Orlando_Gisler.jpg' ],
            [ 'name' => 'Nicola Mahrow',    'role' => 'Betreuer Fussballschule',    'img' => 'Nici_Mahrow_2.jpg' ],
        ];
        foreach ( $team as $p ) : ?>
        <div class="fcji-card">
          <div class="fcji-card__photo">
            <img src="<?php echo esc_url( $up . $p['img'] ); ?>" alt="<?php echo esc_attr( $p['name'] ); ?>">
          </div>
          <div class="fcji-card__info">
            <div class="fcji-card__name"><?php echo esc_html( $p['name'] ); ?></div>
            <div class="fcji-card__role"><?php echo esc_html( $p['role'] ); ?></div>
          </div>
        </div>
        <?php endforeach; ?>
      </div>
    </div>
  </section>

</div>

<?php get_footer(); ?>
