<?php
/**
 * Template Name: Sportanlagen
 * Template Post Type: page
 */
defined( 'ABSPATH' ) || exit;

add_action( 'wp_enqueue_scripts', function () {
    $dir = get_stylesheet_directory();
    $uri = get_stylesheet_directory_uri();
    wp_enqueue_style( 'fcs-sportanlagen', $uri . '/assets/fcs-sportanlagen.css', [], filemtime( $dir . '/assets/fcs-sportanlagen.css' ) );
}, 5 );

$uploads = wp_upload_dir()['baseurl'] . '/2026/06/';

get_header();
?>

<div class="fcsa-page">

  <!-- ── Header ── -->
  <div class="fcsa-header">
    <h1 class="fcsa-header__title">Sportanlagen</h1>
  </div>

  <!-- ── Hero-Bild ── -->
  <div class="fcsa-hero-img">
    <img src="<?php echo esc_url( $uploads . 'sportanlage_action-scaled.jpg' ); ?>" alt="Sportanlagen FC Schattdorf">
  </div>

  <!-- ── Hauptplatz: Grüner Wald ── -->
  <section class="fcsa-facility fcsa-facility--light">
    <div class="fcsa-facility__inner">
      <div class="fcsa-facility__header">
        <span class="fcsa-facility__label">Hauptplatz</span>
        <h2>Grüner Wald</h2>
      </div>
      <div class="fcsa-facility__body">
        <div class="fcsa-facility__stats">
          <div class="fcsa-stat">
            <div class="fcsa-stat__icon">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><rect x="3" y="3" width="18" height="18" rx="2"/><path d="M12 3v18M3 12h18M3 7h18M3 17h18"/></svg>
            </div>
            <div>
              <div class="fcsa-stat__label">Belag</div>
              <div class="fcsa-stat__value">Kunstrasen<br><small>KR EN-15330 zertifiziert</small></div>
            </div>
          </div>
          <div class="fcsa-stat">
            <div class="fcsa-stat__icon">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M3 6l9-3 9 3v12l-9 3-9-3V6z"/></svg>
            </div>
            <div>
              <div class="fcsa-stat__label">Masse</div>
              <div class="fcsa-stat__value">100 × 61,5 m</div>
            </div>
          </div>
          <div class="fcsa-stat">
            <div class="fcsa-stat__icon">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 00-3-3.87M16 3.13a4 4 0 010 7.75"/></svg>
            </div>
            <div>
              <div class="fcsa-stat__label">Kapazität</div>
              <div class="fcsa-stat__value">ca. 900 Stehplätze</div>
            </div>
          </div>
          <div class="fcsa-stat">
            <div class="fcsa-stat__icon">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><circle cx="12" cy="12" r="5"/><path d="M12 1v2M12 21v2M4.22 4.22l1.42 1.42M18.36 18.36l1.42 1.42M1 12h2M21 12h2M4.22 19.78l1.42-1.42M18.36 5.64l1.42-1.42"/></svg>
            </div>
            <div>
              <div class="fcsa-stat__label">Beleuchtung</div>
              <div class="fcsa-stat__value">177 LUX horizontal</div>
            </div>
          </div>
          <div class="fcsa-stat">
            <div class="fcsa-stat__icon">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
            </div>
            <div>
              <div class="fcsa-stat__label">Zulassung</div>
              <div class="fcsa-stat__value">2. Liga interregional</div>
            </div>
          </div>
          <div class="fcsa-stat">
            <div class="fcsa-stat__icon">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
            </div>
            <div>
              <div class="fcsa-stat__label">Erbaut</div>
              <div class="fcsa-stat__value">2019</div>
            </div>
          </div>
        </div>
        <div class="fcsa-facility__notes">
          <div class="fcsa-note fcsa-note--warn">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
            Keine Stollenschuhe gestattet
          </div>
          <div class="fcsa-note">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0118 0z"/><circle cx="12" cy="10" r="3"/></svg>
            Parkplätze beim Feuerwehrlokal und der Sportanlage Grundmatte
          </div>
        </div>
      </div>
    </div>
  </section>

  <!-- ── Nebenplatz: Grundmatte ── -->
  <section class="fcsa-facility fcsa-facility--light">
    <div class="fcsa-facility__inner fcsa-facility__inner--with-img">
      <div class="fcsa-facility__header">
        <span class="fcsa-facility__label">Nebenplatz</span>
        <h2>Grundmatte</h2>
      </div>
      <div class="fcsa-facility__body fcsa-facility__body--grid">
        <div class="fcsa-facility__images">
          <img class="fcsa-img fcsa-img--main"
               src="<?php echo esc_url( $uploads . 'grundmatte.jpg' ); ?>"
               alt="Grundmatte Schattdorf – Nebenplatz">
        </div>
        <div class="fcsa-facility__right">
          <div class="fcsa-facility__stats">
            <div class="fcsa-stat">
              <div class="fcsa-stat__icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><rect x="3" y="3" width="18" height="18" rx="2"/><path d="M12 3v18M3 12h18M3 7h18M3 17h18"/></svg>
              </div>
              <div>
                <div class="fcsa-stat__label">Belag</div>
                <div class="fcsa-stat__value">Kunststoffrasen</div>
              </div>
            </div>
            <div class="fcsa-stat">
              <div class="fcsa-stat__icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M3 6l9-3 9 3v12l-9 3-9-3V6z"/></svg>
              </div>
              <div>
                <div class="fcsa-stat__label">Masse</div>
                <div class="fcsa-stat__value">94 × 60 m</div>
              </div>
            </div>
            <div class="fcsa-stat">
              <div class="fcsa-stat__icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 00-3-3.87M16 3.13a4 4 0 010 7.75"/></svg>
              </div>
              <div>
                <div class="fcsa-stat__label">Kapazität</div>
                <div class="fcsa-stat__value">ca. 200 Stehplätze</div>
              </div>
            </div>
            <div class="fcsa-stat">
              <div class="fcsa-stat__icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><circle cx="12" cy="12" r="5"/><path d="M12 1v2M12 21v2M4.22 4.22l1.42 1.42M18.36 18.36l1.42 1.42M1 12h2M21 12h2M4.22 19.78l1.42-1.42M18.36 5.64l1.42-1.42"/></svg>
              </div>
              <div>
                <div class="fcsa-stat__label">Beleuchtung</div>
                <div class="fcsa-stat__value">120 LUX horizontal</div>
              </div>
            </div>
            <div class="fcsa-stat">
              <div class="fcsa-stat__icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
              </div>
              <div>
                <div class="fcsa-stat__label">Zulassung</div>
                <div class="fcsa-stat__value">2. Liga interregional</div>
              </div>
            </div>
            <div class="fcsa-stat">
              <div class="fcsa-stat__icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="M3 9l9-7 9 7v11a2 2 0 01-2 2H5a2 2 0 01-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
              </div>
              <div>
                <div class="fcsa-stat__label">Erbaut</div>
                <div class="fcsa-stat__value">2022</div>
              </div>
            </div>
          </div>
          <div class="fcsa-facility__notes">
            <div class="fcsa-note fcsa-note--warn">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
              Keine Stollenschuhe gestattet
            </div>
            <div class="fcsa-note">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 9l9-7 9 7v11a2 2 0 01-2 2H5a2 2 0 01-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
              Garderoben: Turnhalle Grundmatte Schattdorf
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>

</div><!-- .fcsa-page -->

<?php get_footer(); ?>
