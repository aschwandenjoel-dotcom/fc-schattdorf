<?php
/**
 * Template Name: Betreuer werden
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

  <div class="fcji-page-title">
    <h1>Betreuer werden</h1>
  </div>

  <!-- ── Flyer / CTA ── -->
  <section class="fcji-section fcji-section--gray">
    <div class="fcji-inner">
      <div class="fcji-flyer-row">
        <div class="fcji-flyer-img">
          <img src="<?php echo esc_url( $up . 'Flyer_Trainersuche.jpg' ); ?>" alt="Trainer gesucht – FC Schattdorf">
        </div>
        <div class="fcji-flyer-text">
          <div class="fcji-flyer-badge">Trainer gesucht!</div>
          <p>Du bist engagiert, liebst Fussball und willst etwas zurückgeben? Der FC Schattdorf sucht laufend motivierte Betreuerinnen und Betreuer für unsere Juniorenteams. Wir unterstützen dich vollumfänglich auf dem Weg zur Trainer-Lizenz.</p>
        </div>
      </div>
    </div>
  </section>

  <!-- ── Diploma path ── -->
  <section class="fcji-section fcji-section--white">
    <div class="fcji-inner">

      <div class="fcji-section__header">
        <h2>Ausbildungsweg zum Fussballtrainer</h2>
      </div>

      <div class="fcji-path">

        <div class="fcji-step">
          <div class="fcji-step__num">1</div>
          <div class="fcji-step__body">
            <div class="fcji-step__title">Einsteigerkurs</div>
            <div class="fcji-step__meta">
              <span class="fcji-step__tag">Ab 16 Jahre</span>
              <span class="fcji-step__tag">4 Stunden</span>
              <span class="fcji-step__tag">Kosten übernimmt FC Schattdorf</span>
            </div>
            <div class="fcji-step__desc">Obligatorisch für die Teilnahme am C-Basic Diplom. Kein Praxisteil – reine Theorie. Anmeldung erfolgt durch den J+S Coach des Vereins.</div>
          </div>
        </div>

        <div class="fcji-step">
          <div class="fcji-step__num">2</div>
          <div class="fcji-step__body">
            <div class="fcji-step__title">C-Basic Diplom / J+S Leiterkurs Jugendsport</div>
            <div class="fcji-step__meta">
              <span class="fcji-step__tag">Ab 18 Jahre</span>
              <span class="fcji-step__tag">6-tägiger Blockkurs</span>
              <span class="fcji-step__tag">EO-Entschädigung</span>
              <span class="fcji-step__tag">Kosten übernimmt FC Schattdorf</span>
            </div>
            <div class="fcji-step__desc">Berechtigt zum Trainieren von Junioren A/B/C/D und 3.–5. Liga Aktive, sowie 1./2. Liga Frauen. Schriftliche Theorieprüfung. Alle 2 Jahre Weiterbildungspflicht.</div>
          </div>
        </div>

        <div class="fcji-step">
          <div class="fcji-step__num">3</div>
          <div class="fcji-step__body">
            <div class="fcji-step__title">D-Diplom / J+S Leiterkurs Kindersport</div>
            <div class="fcji-step__meta">
              <span class="fcji-step__tag">Ab 18 Jahre</span>
              <span class="fcji-step__tag">6 Tage / mehrere Module</span>
              <span class="fcji-step__tag">EO-Entschädigung</span>
              <span class="fcji-step__tag">Kosten übernimmt FC Schattdorf</span>
            </div>
            <div class="fcji-step__desc">Für Trainer von E-, F- und G-Junioren (Kinderfussball). Theorie- und Methodik-Prüfung. Alle 2 Jahre ein Fortbildungsmodul.</div>
          </div>
        </div>

        <div class="fcji-step">
          <div class="fcji-step__num">4</div>
          <div class="fcji-step__body">
            <div class="fcji-step__title">UEFA C-Diplom / J+S Weiterbildung 1</div>
            <div class="fcji-step__meta">
              <span class="fcji-step__tag">Voraussetzung: C-Basic Diplom</span>
              <span class="fcji-step__tag">2 × 3 Tage</span>
              <span class="fcji-step__tag">EO-Entschädigung</span>
            </div>
            <div class="fcji-step__desc">Weiterführende Lizenz für ambitionierte Trainer. Berechtigt zum Leiten höherer Spielkategorien.</div>
          </div>
        </div>

        <div class="fcji-step">
          <div class="fcji-step__num">5</div>
          <div class="fcji-step__body">
            <div class="fcji-step__title">UEFA B-Diplom / J+S Weiterbildung 2</div>
            <div class="fcji-step__meta">
              <span class="fcji-step__tag">Voraussetzung: UEFA C-Diplom</span>
              <span class="fcji-step__tag">Mehrere Module</span>
            </div>
            <div class="fcji-step__desc">Höchste Lizenzstufe im Amateurfussball. Für die Leitung von 1./2. Liga-Mannschaften und höheren Juniorenkategorien.</div>
          </div>
        </div>

      </div>

    </div>
  </section>

  <!-- ── Contact ── -->
  <section class="fcji-section fcji-section--gray">
    <div class="fcji-inner">
      <div class="fcji-contact-clean">
        <div class="fcji-contact-clean__divider"></div>
        <div class="fcji-contact-clean__inner">
          <div class="fcji-contact-clean__label">Ansprechperson &amp; J+S Coach</div>
          <div class="fcji-contact-clean__name">Karl Arnold</div>
          <div class="fcji-contact-clean__links">
            <a href="tel:+41791598238" class="fcji-contact-clean__link">
              <svg width="15" height="15" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07A19.5 19.5 0 0 1 4.69 12a19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 3.6 1.27h3a2 2 0 0 1 2 1.72c.127.96.361 1.903.7 2.81a2 2 0 0 1-.45 2.11L7.91 8.91a16 16 0 0 0 6 6l.91-.91a2 2 0 0 1 2.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0 1 21.73 16.92z"/></svg>
              079 159 82 38
            </a>
            <a href="mailto:tschuedi.kari@gmail.com" class="fcji-contact-clean__link">
              <svg width="15" height="15" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
              tschuedi.kari@gmail.com
            </a>
          </div>
          <p class="fcji-contact-clean__note">Anmeldung für alle Kurse erfolgt durch den J+S Coach. Kurskosten werden vollumfänglich vom FC Schattdorf übernommen.</p>
        </div>
      </div>
    </div>
  </section>

</div>

<?php get_footer(); ?>
