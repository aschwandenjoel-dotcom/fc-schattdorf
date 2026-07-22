<?php
/**
 * Template Name: Schiedsrichter
 * Template Post Type: page
 */
defined( 'ABSPATH' ) || exit;

add_action( 'wp_enqueue_scripts', function () {
    $dir = get_stylesheet_directory();
    $uri = get_stylesheet_directory_uri();
    wp_enqueue_style( 'fcs-schiedsrichter', $uri . '/assets/fcs-schiedsrichter.css', [], filemtime( $dir . '/assets/fcs-schiedsrichter.css' ) );
}, 5 );

$uploads = wp_upload_dir()['baseurl'] . '/2026/06/';

$referees = [
  [
    'name'  => 'Stephan Gisler',
    'role'  => 'SR-INSP – Inspizient',
    'image' => $uploads . 'Gisler_Stephan.jpg',
    'ifv'   => 'http://www.ifv.ch/Innerschweizerischer-Fussballverband/Vereine-IFV/Verein-IFV.aspx/v-329/a-sr/',
  ],
  [
    'name'  => 'Ayman Labib Badr',
    'role'  => 'SR – Anfänger',
    'image' => null,
    'ifv'   => 'http://www.ifv.ch/Innerschweizerischer-Fussballverband/Vereine-IFV/Verein-IFV.aspx/v-329/a-sr/',
  ],
  [
    'name'  => 'René Hüglin',
    'role'  => 'SR – Junioren B / SR – 5. Liga',
    'image' => $uploads . 'ReneHueglin.jpg',
    'ifv'   => 'http://www.football.ch/ifv/de/verein.aspx?v=329&sr=425693',
  ],
  [
    'name'  => 'Ukaj Alex',
    'role'  => 'SR – Junioren',
    'image' => null,
    'ifv'   => 'http://www.ifv.ch/Innerschweizerischer-Fussballverband/Vereine-IFV/Verein-IFV.aspx/v-329/a-sr/',
  ],
  [
    'name'  => 'Giuseppe Accardi',
    'role'  => 'SR – Anfänger',
    'image' => null,
    'ifv'   => 'http://www.ifv.ch/Innerschweizerischer-Fussballverband/Vereine-IFV/Verein-IFV.aspx/v-329/a-sr/',
  ],
];

$spielleiter = [
  'Baumann Damian',
  'Bissig Ivo',
  'Küttel Thomas',
  'Leu Nicolas',
  'Lustenberger Thomas',
  'Marxen Henning',
  'Scheiber Bernhard',
  'Scheiber René',
  'Zamuner Sandro',
  'Zgraggen André',
  'Zwyssig Sandro',
];

get_header();
?>

<div class="fcsr-page">

  <!-- ── Title ── -->
  <div class="fcsr-page-title">
    <h1>Schiedsrichter</h1>
  </div>

  <!-- ════════════════════════════════════════
       SCHIEDSRICHTER MIT BILD
  ═════════════════════════════════════════ -->
  <section class="fcsr-section fcsr-section--dark">
    <div class="fcsr-inner">
      <div class="fcsr-section__header">
        <span class="fcsr-label">Schiedsrichter</span>
        <h2>Unsere lizenzierten Schiedsrichter</h2>
      </div>
      <div class="fcsr-referees">
        <?php foreach ( $referees as $ref ) : ?>
          <div class="fcsr-referee">
            <div class="fcsr-referee__photo">
              <?php if ( $ref['image'] ) : ?>
                <img src="<?php echo esc_url( $ref['image'] ); ?>"
                     alt="<?php echo esc_attr( $ref['name'] ); ?>">
              <?php else : ?>
                <div class="fcsr-referee__placeholder">
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.2">
                    <circle cx="12" cy="8" r="4"/>
                    <path d="M4 20c0-4 3.58-7 8-7s8 3 8 7"/>
                  </svg>
                </div>
              <?php endif; ?>
            </div>
            <div class="fcsr-referee__info">
              <div class="fcsr-referee__name"><?php echo esc_html( $ref['name'] ); ?></div>
              <div class="fcsr-referee__role"><?php echo esc_html( $ref['role'] ); ?></div>
              <a class="fcsr-ifv-btn" href="<?php echo esc_url( $ref['ifv'] ); ?>" target="_blank" rel="noopener">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
                IFV Daten
              </a>
            </div>
          </div>
        <?php endforeach; ?>
      </div>
    </div>
  </section>

  <!-- ════════════════════════════════════════
       WERDE SCHIEDSRICHTER
  ═════════════════════════════════════════ -->
  <section class="fcsr-section fcsr-section--light">
    <div class="fcsr-inner">
      <div class="fcsr-section__header">
        <span class="fcsr-label">Mitmachen</span>
        <h2>Werde Schiedsrichter beim FC Schattdorf</h2>
      </div>
      <div class="fcsr-become">
        <div class="fcsr-become__card">
          <div class="fcsr-become__icon">
            <svg viewBox="0 0 24 24" fill="none" stroke="#E30613" stroke-width="1.8">
              <path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/>
              <circle cx="12" cy="7" r="4"/>
            </svg>
          </div>
          <div>
            <div class="fcsr-become__title">Kontaktperson beim FC Schattdorf</div>
            <p>Für detaillierte Informationen zum Schiedsrichterwesen beim FC Schattdorf steht dir Stephan Gisler gerne zur Verfügung.</p>
            <div class="fcsr-contact-line">
              <a href="mailto:spiko@fcschattdorf.ch">spiko@fcschattdorf.ch</a>
              <span>·</span>
              <a href="tel:0792349190">079 234 91 90</a>
            </div>
          </div>
        </div>
        <div class="fcsr-become__card">
          <div class="fcsr-become__icon">
            <svg viewBox="0 0 24 24" fill="none" stroke="#E30613" stroke-width="1.8">
              <circle cx="12" cy="12" r="10"/>
              <path d="M12 16v-4M12 8h.01"/>
            </svg>
          </div>
          <div>
            <div class="fcsr-become__title">Teste deine Regelkenntnisse</div>
            <p>Hier findest du ein Regelfrage-Quiz – perfekt zur Vorbereitung.</p>
            <a class="fcsr-link-btn" href="https://www.werdeschiri.ch" target="_blank" rel="noopener">
              www.werdeschiri.ch
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 13v6a2 2 0 01-2 2H5a2 2 0 01-2-2V8a2 2 0 012-2h6"/><polyline points="15 3 21 3 21 9"/><line x1="10" y1="14" x2="21" y2="3"/></svg>
            </a>
          </div>
        </div>
      </div>
    </div>
  </section>

  <!-- ════════════════════════════════════════
       SPIELLEITER KINDERFUSSBALL
  ═════════════════════════════════════════ -->
  <section class="fcsr-section fcsr-section--dark">
    <div class="fcsr-inner">
      <div class="fcsr-section__header">
        <span class="fcsr-label">Kinderfussball</span>
        <h2>Unsere Spielleiter im Kinderfussball</h2>
      </div>
      <p class="fcsr-intro-text">Wir danken den folgenden FCS-Mitgliedern, die als Spielleiter bei den Heimspielen der Jun. D und E im Einsatz stehen:</p>
      <div class="fcsr-spielleiter">
        <?php foreach ( $spielleiter as $sl ) : ?>
          <div class="fcsr-spielleiter__item">
            <svg viewBox="0 0 24 24" fill="none" stroke="#E30613" stroke-width="2"><circle cx="12" cy="8" r="3"/><path d="M5 20c0-3.3 3.13-6 7-6s7 2.7 7 6"/></svg>
            <?php echo esc_html( $sl ); ?>
          </div>
        <?php endforeach; ?>
      </div>
      <p class="fcsr-footnote">Für die Qualifikation zum Kinderfussball-Spielleiter muss ein eintägiger Kurs besucht werden. Interessent(inn)en melden sich bitte bei unserem Chef Wettspielbetrieb.</p>
    </div>
  </section>

</div><!-- .fcsr-page -->

<?php get_footer(); ?>
