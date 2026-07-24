<?php
/**
 * Template Name: Sponsoren
 * Template Post Type: page
 */
defined( 'ABSPATH' ) || exit;

add_action( 'wp_enqueue_scripts', function () {
    $dir = get_stylesheet_directory();
    $uri = get_stylesheet_directory_uri();
    wp_enqueue_style( 'fcs-sponsoren', $uri . '/assets/fcs-sponsoren.css', [], filemtime( $dir . '/assets/fcs-sponsoren.css' ) );
}, 5 );

$up = wp_upload_dir()['baseurl'] . '/2026/06/';

/* Sponsoren aus dem Inhaltstyp fcs_sponsor (Pflege im Admin-Menü «Sponsoren») */
$sponsoren = fcs_get_sponsoren();

get_header();
?>

<div class="fcsp-page">

  <!-- ── Header ── -->
  <div class="fcsp-header">
    <div class="fcsp-header__inner">
      <div class="fcsp-header__label">FC Schattdorf</div>
      <h1>Unsere Sponsoren</h1>
      <p class="fcsp-header__sub">Wir danken unseren Sponsoren herzlich für ihre Unterstützung. Ohne sie wäre der Spielbetrieb in dieser Form nicht möglich.</p>
    </div>
  </div>

  <!-- ── Content ── -->
  <div class="fcsp-main">

    <!-- Hauptsponsor -->
    <div class="fcsp-section">
      <div class="fcsp-section__head">
        <h2 class="fcsp-section__title">Hauptsponsor</h2>
      </div>
      <div class="fcsp-main-sponsor">
        <?php foreach ( $sponsoren['haupt'] as $sp ) : ?>
        <div class="fcsp-box">
          <div class="fcsp-box__logo">
            <img src="<?php echo esc_url( $sp['logo'] ); ?>" alt="<?php echo esc_attr( $sp['name'] ); ?>">
          </div>
          <?php if ( $sp['url'] ) : ?>
          <a href="<?php echo esc_url( $sp['url'] ); ?>" class="fcsp-box__name" target="_blank" rel="noopener noreferrer"><?php echo esc_html( $sp['name'] ); ?></a>
          <?php else : ?>
          <span class="fcsp-box__name"><?php echo esc_html( $sp['name'] ); ?></span>
          <?php endif; ?>
        </div>
        <?php endforeach; ?>
      </div>
    </div>

    <!-- Nachwuchs-Patronat -->
    <div class="fcsp-section">
      <div class="fcsp-section__head">
        <h2 class="fcsp-section__title">Nachwuchs-Patronat</h2>
      </div>
      <div class="fcsp-grid fcsp-grid--single">
        <?php foreach ( $sponsoren['patronat'] as $sp ) : ?>
        <div class="fcsp-box">
          <div class="fcsp-box__logo">
            <img src="<?php echo esc_url( $sp['logo'] ); ?>" alt="<?php echo esc_attr( $sp['name'] ); ?>">
          </div>
          <?php if ( $sp['url'] ) : ?>
          <a href="<?php echo esc_url( $sp['url'] ); ?>" class="fcsp-box__name" target="_blank" rel="noopener noreferrer"><?php echo esc_html( $sp['name'] ); ?></a>
          <?php else : ?>
          <span class="fcsp-box__name"><?php echo esc_html( $sp['name'] ); ?></span>
          <?php endif; ?>
        </div>
        <?php endforeach; ?>
      </div>
    </div>

    <!-- Co-Sponsoren -->
    <div class="fcsp-section">
      <div class="fcsp-section__head">
        <h2 class="fcsp-section__title">Co-Sponsoren</h2>
      </div>
      <div class="fcsp-grid fcsp-grid--wide">
        <?php foreach ( $sponsoren['co_sponsoren'] as $sp ) : ?>
        <div class="fcsp-box">
          <div class="fcsp-box__logo">
            <img src="<?php echo esc_url( $sp['logo'] ); ?>" alt="<?php echo esc_attr( $sp['name'] ); ?>">
          </div>
          <?php if ( $sp['url'] ) : ?>
          <a href="<?php echo esc_url( $sp['url'] ); ?>" class="fcsp-box__name" target="_blank" rel="noopener noreferrer"><?php echo esc_html( $sp['name'] ); ?></a>
          <?php else : ?>
          <span class="fcsp-box__name"><?php echo esc_html( $sp['name'] ); ?></span>
          <?php endif; ?>
        </div>
        <?php endforeach; ?>
      </div>
    </div>

    <!-- Club-Sponsor -->
    <div class="fcsp-section">
      <div class="fcsp-section__head">
        <h2 class="fcsp-section__title">Club-Sponsor</h2>
      </div>
      <div class="fcsp-grid fcsp-grid--single">
        <?php foreach ( $sponsoren['club'] as $sp ) : ?>
        <div class="fcsp-box">
          <div class="fcsp-box__logo">
            <img src="<?php echo esc_url( $sp['logo'] ); ?>" alt="<?php echo esc_attr( $sp['name'] ); ?>">
          </div>
          <?php if ( $sp['url'] ) : ?>
          <a href="<?php echo esc_url( $sp['url'] ); ?>" class="fcsp-box__name" target="_blank" rel="noopener noreferrer"><?php echo esc_html( $sp['name'] ); ?></a>
          <?php else : ?>
          <span class="fcsp-box__name"><?php echo esc_html( $sp['name'] ); ?></span>
          <?php endif; ?>
        </div>
        <?php endforeach; ?>
      </div>
    </div>

    <!-- Nachwuchs-Sponsoren -->
    <div class="fcsp-section">
      <div class="fcsp-section__head">
        <h2 class="fcsp-section__title">Nachwuchs-Sponsoren</h2>
      </div>
      <div class="fcsp-grid fcsp-grid--wide">
        <?php foreach ( $sponsoren['nachwuchs'] as $sp ) : ?>
        <div class="fcsp-box">
          <div class="fcsp-box__logo">
            <img src="<?php echo esc_url( $sp['logo'] ); ?>" alt="<?php echo esc_attr( $sp['name'] ); ?>">
          </div>
          <?php if ( $sp['url'] ) : ?>
          <a href="<?php echo esc_url( $sp['url'] ); ?>" class="fcsp-box__name" target="_blank" rel="noopener noreferrer"><?php echo esc_html( $sp['name'] ); ?></a>
          <?php else : ?>
          <span class="fcsp-box__name"><?php echo esc_html( $sp['name'] ); ?></span>
          <?php endif; ?>
        </div>
        <?php endforeach; ?>
      </div>
    </div>

    <!-- Spielersponsoren -->
    <div class="fcsp-section">
      <div class="fcsp-section__head">
        <h2 class="fcsp-section__title">Spielersponsoren</h2>
      </div>
      <div class="fcsp-player-grid">
        <?php foreach ( $sponsoren['spieler'] as $sp ) : ?>
        <div class="fcsp-player-box">
          <?php if ( $sp['logo'] ) : ?>
          <div class="fcsp-player-box__logo">
            <img src="<?php echo esc_url( $sp['logo'] ); ?>" alt="<?php echo esc_attr( $sp['name'] ); ?>">
          </div>
          <?php else : ?>
          <div class="fcsp-player-box__logo fcsp-player-box__logo--text">
            <svg class="fcsp-player-icon" width="28" height="28" fill="none" stroke="currentColor" stroke-width="1.5" viewBox="0 0 24 24"><rect x="3" y="5" width="18" height="14" rx="2"/><circle cx="12" cy="12" r="3"/></svg>
            <span>Logo folgt</span>
          </div>
          <?php endif; ?>
          <?php if ( $sp['url'] ) : ?>
          <a href="<?php echo esc_url( $sp['url'] ); ?>" class="fcsp-player-box__name" target="_blank" rel="noopener noreferrer"><?php echo esc_html( $sp['name'] ); ?></a>
          <?php else : ?>
          <span class="fcsp-player-box__name"><?php echo esc_html( $sp['name'] ); ?></span>
          <?php endif; ?>
        </div>
        <?php endforeach; ?>
      </div>
    </div>

    <!-- CTA -->
    <div class="fcsp-cta">
      <div class="fcsp-cta__text">
        <div class="fcsp-cta__label">Sponsor werden</div>
        <div class="fcsp-cta__title">Interesse an einer Partnerschaft?</div>
        <div class="fcsp-cta__sub">Sponsoringkonzept herunterladen oder direkt Kontakt aufnehmen: <a href="mailto:marketing@fcschattdorf.ch" class="fcsp-cta__mail">marketing@fcschattdorf.ch</a></div>
      </div>
      <a href="<?php echo esc_url( $up . 'FCS_Sponsoringkonzept_Version_6_2024.pdf' ); ?>"
         class="fcsp-cta__btn" target="_blank" rel="noopener">
        <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M12 15V3m0 12-4-4m4 4 4-4M3 17v2a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-2"/></svg>
        PDF herunterladen
      </a>
    </div>

  </div>
</div>

<?php get_footer(); ?>
