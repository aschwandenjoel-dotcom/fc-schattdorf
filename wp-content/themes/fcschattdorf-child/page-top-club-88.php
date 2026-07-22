<?php
/**
 * Template for Top-Club 88 (slug: top-club-88, ID: 349)
 */
defined( 'ABSPATH' ) || exit;

add_action( 'wp_enqueue_scripts', function () {
    $dir = get_stylesheet_directory();
    $uri = get_stylesheet_directory_uri();
    wp_enqueue_style( 'fcs-top-club-88', $uri . '/assets/fcs-top-club-88.css', [], filemtime( $dir . '/assets/fcs-top-club-88.css' ) );
}, 5 );

add_filter( 'body_class', function ( $c ) { $c[] = 'fcx-wine-page'; return $c; } );

$up = wp_upload_dir()['baseurl'] . '/2026/06/';

$vorstand = [
    [
        'name'  => 'Kai Mahrow',
        'role'  => 'Präsident',
        'email' => 'topclubfcs@gmail.com',
        'phone' => '079 605 08 19',
        'img'   => 'Kai_Mahrow.jpg',
    ],
    [
        'name'  => 'Daniel Reichmuth',
        'role'  => 'Vorstand',
        'email' => 'tschigi75@gmx.net',
        'phone' => '079 616 28 35',
        'img'   => '',
    ],
    [
        'name'  => 'Petra Truttmann',
        'role'  => 'Vorstand',
        'email' => 'petratru@hotmail.com',
        'phone' => '079 743 84 02',
        'img'   => '',
    ],
];

get_header();
?>

<div class="fctc-page">

  <!-- Header -->
  <div class="fctc-header">
    <div class="fctc-header__inner">
      <div class="fctc-header__label">FC Schattdorf</div>
      <h1>Top-Club 88</h1>
      <p class="fctc-header__sub">Der Sponsorenclub des FC Schattdorf. Seit Jahren eine wichtige Stütze für unsere erste Mannschaft und unsere Juniorenabteilung.</p>
    </div>
  </div>

  <!-- Main -->
  <div class="fctc-main">

    <!-- Was ist der Top-Club 88? -->
    <div class="fctc-info">
      <h2>Was ist der Top-Club 88?</h2>
      <p>Der Top-Club 88 ist der Sponsorenclub des FC Schattdorf. Sein Ziel ist die finanzielle und moralische Unterstützung des Vereins, insbesondere der ersten Mannschaft und der Juniorenabteilung. Die Mitglieder sind keine anonymen Geldgeber, sondern Menschen, die hinter dem FC Schattdorf stehen und den Verein aktiv begleiten.</p>
    </div>

    <!-- Mitgliedschaft -->
    <div class="fctc-info">
      <h2>Was bekommst du als Mitglied?</h2>
      <ul class="fctc-benefits">
        <li>
          <div>
            <strong>Jahresbeitrag 250 Franken</strong><br>
            <span>Die Hälfte davon geht direkt an die 1. Mannschaft</span>
          </div>
        </li>
        <li>
          <div>
            <strong>Saisonkarte</strong><br>
            <span>Freier Eintritt zu allen Heimspielen des FC Schattdorf (ausser Cup)</span>
          </div>
        </li>
        <li>
          <div>
            <strong>Exklusive Clubanlässe</strong><br>
            <span>2 bis 4 Events pro Jahr, zu denen nur Mitglieder eingeladen sind</span>
          </div>
        </li>
      </ul>
    </div>

    <!-- Vorstand -->
    <h2 class="fctc-section-title">Vorstand Top-Club 88</h2>
    <div class="fctc-vorstand-grid">
      <?php foreach ( $vorstand as $m ) : ?>
      <div class="fctc-card">

        <?php if ( $m['img'] ) : ?>
        <div class="fctc-card__photo">
          <img src="<?php echo esc_url( $up . $m['img'] ); ?>" alt="<?php echo esc_attr( $m['name'] ); ?>">
        </div>
        <?php else : ?>
        <div class="fctc-card__photo fctc-card__photo--placeholder">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1" stroke-linecap="round" stroke-linejoin="round">
            <circle cx="12" cy="7" r="4"/>
            <path d="M4 20c0-4 3.6-7 8-7s8 3 8 7"/>
          </svg>
        </div>
        <?php endif; ?>

        <div class="fctc-card__info">
          <div class="fctc-card__role"><?php echo esc_html( $m['role'] ); ?></div>
          <div class="fctc-card__name"><?php echo esc_html( $m['name'] ); ?></div>
          <div class="fctc-card__divider"></div>
          <a href="mailto:<?php echo esc_attr( $m['email'] ); ?>" class="fctc-card__email">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="4" width="20" height="16" rx="2"/><path d="m2 7 10 7 10-7"/></svg>
            <?php echo esc_html( $m['email'] ); ?>
          </a>
          <div class="fctc-card__phone">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.8 19.8 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72c.127.96.361 1.903.7 2.81a2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0 1 22 16.92z"/></svg>
            <?php echo esc_html( $m['phone'] ); ?>
          </div>
        </div>

      </div>
      <?php endforeach; ?>
    </div>

    <!-- CTA -->
    <div class="fctc-cta">
      <div class="fctc-cta__text">
        <div class="fctc-cta__label">Interesse?</div>
        <div class="fctc-cta__title">Mitglied werden</div>
        <div class="fctc-cta__sub">Melde dich einfach bei Kai Mahrow oder einem der Vorstandsmitglieder. Am schnellsten erreichst du den Vorstand per Mail an <a href="mailto:topclubfcs@gmail.com">topclubfcs@gmail.com</a>.</div>
      </div>
    </div>

  </div>
</div>

<?php get_footer(); ?>
