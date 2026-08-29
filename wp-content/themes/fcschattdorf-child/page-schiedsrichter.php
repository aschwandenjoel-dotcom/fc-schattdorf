<?php
/**
 * Template Name: Schiedsrichter
 * Template Post Type: page
 *
 * Layout im Designstil von «Top-Club 88» (Weinrot + Creme-Karten).
 * Texte werden über die Feld-Box «Seiteninhalte» gepflegt
 * (inc/fcs-page-fields.php); das Layout kommt aus der Vorlage.
 */
defined( 'ABSPATH' ) || exit;

add_action( 'wp_enqueue_scripts', function () {
    $dir = get_stylesheet_directory();
    $uri = get_stylesheet_directory_uri();
    wp_enqueue_style( 'fcs-schiedsrichter', $uri . '/assets/fcs-schiedsrichter.css', [], filemtime( $dir . '/assets/fcs-schiedsrichter.css' ) );
}, 5 );

add_filter( 'body_class', function ( $c ) { $c[] = 'fcx-wine-page'; return $c; } );

/* Schiedsrichter aus der Datenbank (WP-Admin -> Personen, Bereich «Schiedsrichter»).
   Registrierung des Inhaltstyps und Abfrage: inc/fcs-personen.php */
$referees = fcs_get_personen( 'schiedsrichter' );

/* Pflegbare Textbausteine (inc/fcs-page-fields.php) */
$intro = fcs_pf( 'sr_intro', 'Ohne Schiedsrichter kein Spiel. Die lizenzierten Schiedsrichter des FC Schattdorf leiten Woche für Woche Partien im Verband. Im Kinderfussball übernehmen erfahrene Vereinsmitglieder als Spielleiter die Heimspiele der Junioren D und E.' );

$sl_intro = fcs_pf( 'sr_spielleiter_intro', 'Wir danken den folgenden FCS-Mitgliedern, die als Spielleiter bei den Heimspielen der Jun. D und E im Einsatz stehen:' );
$spielleiter = fcs_pf_lines( 'sr_spielleiter', [
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
] );
$sl_fussnote = fcs_pf( 'sr_fussnote', 'Für die Qualifikation zum Kinderfussball-Spielleiter muss ein eintägiger Kurs besucht werden. Interessent(inn)en melden sich bitte bei unserem Chef Wettspielbetrieb.' );

$cta_text = fcs_pf( 'sr_cta_text', 'Für detaillierte Informationen zum Schiedsrichterwesen beim FC Schattdorf steht dir Stephan Gisler gerne zur Verfügung.' );
$cta_mail = fcs_pf( 'sr_cta_mail', 'spiko@fcschattdorf.ch' );
$cta_tel  = fcs_pf( 'sr_cta_tel', '079 234 91 90' );
$quiz_url = fcs_pf( 'sr_quiz_url', 'https://www.werdeschiri.ch' );

get_header();
?>

<div class="fcsr-page">

  <!-- Header -->
  <div class="fcsr-header">
    <div class="fcsr-header__inner">
      <h1>Schiedsrichter</h1>
      <p class="fcsr-header__label">FC Schattdorf · Kanton Uri</p>
    </div>
  </div>

  <!-- Main -->
  <div class="fcsr-main">

    <!-- Einleitung -->
    <div class="fcsr-info">
      <h2>Schiedsrichter beim FC Schattdorf</h2>
      <p><?php echo esc_html( $intro ); ?></p>
    </div>

    <!-- Lizenzierte Schiedsrichter -->
    <h2 class="fcsr-section-title">Unsere lizenzierten Schiedsrichter</h2>
    <div class="fcsr-referee-grid">
      <?php foreach ( $referees as $ref ) :
          $bild_url = fcs_person_bild_url( $ref['bild'] );
          ?>
      <div class="fcsr-card">

        <?php if ( $bild_url ) : ?>
        <div class="fcsr-card__photo">
          <img src="<?php echo esc_url( $bild_url ); ?>" alt="<?php echo esc_attr( $ref['name'] ); ?>">
        </div>
        <?php else : ?>
        <div class="fcsr-card__photo fcsr-card__photo--placeholder">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1" stroke-linecap="round" stroke-linejoin="round">
            <circle cx="12" cy="7" r="4"/>
            <path d="M4 20c0-4 3.6-7 8-7s8 3 8 7"/>
          </svg>
        </div>
        <?php endif; ?>

        <div class="fcsr-card__info">
          <?php if ( $ref['rolle'] ) : ?>
          <div class="fcsr-card__role"><?php echo esc_html( $ref['rolle'] ); ?></div>
          <?php endif; ?>
          <div class="fcsr-card__name"><?php echo esc_html( $ref['name'] ); ?></div>
          <div class="fcsr-card__divider"></div>
          <?php if ( $ref['link'] ) : ?>
          <a class="fcsr-card__link" href="<?php echo esc_url( $ref['link'] ); ?>" target="_blank" rel="noopener">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
            IFV Daten
          </a>
          <?php endif; ?>
        </div>

      </div>
      <?php endforeach; ?>
    </div>

    <!-- Spielleiter Kinderfussball -->
    <div class="fcsr-info">
      <h2>Spielleiter im Kinderfussball</h2>
      <p><?php echo esc_html( $sl_intro ); ?></p>
      <ul class="fcsr-namelist">
        <?php foreach ( $spielleiter as $sl ) : ?>
        <li><?php echo esc_html( $sl ); ?></li>
        <?php endforeach; ?>
      </ul>
      <p class="fcsr-footnote"><?php echo esc_html( $sl_fussnote ); ?></p>
    </div>

    <!-- CTA -->
    <div class="fcsr-cta">
      <div class="fcsr-cta__text">
        <div class="fcsr-cta__label">Mitmachen</div>
        <div class="fcsr-cta__title">Werde Schiedsrichter</div>
        <div class="fcsr-cta__sub"><?php echo esc_html( $cta_text ); ?></div>
        <div class="fcsr-cta__contact">
          <?php if ( $cta_mail ) : ?>
          <a href="mailto:<?php echo esc_attr( $cta_mail ); ?>">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="4" width="20" height="16" rx="2"/><path d="m2 7 10 7 10-7"/></svg>
            <?php echo esc_html( $cta_mail ); ?>
          </a>
          <?php endif; ?>
          <?php if ( $cta_tel ) : ?>
          <a href="<?php echo esc_attr( fcsh_tel_href( $cta_tel ) ); ?>">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.8 19.8 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72c.127.96.361 1.903.7 2.81a2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0 1 22 16.92z"/></svg>
            <?php echo esc_html( $cta_tel ); ?>
          </a>
          <?php endif; ?>
        </div>
      </div>
      <?php if ( $quiz_url ) : ?>
      <a class="fcsr-cta__btn" href="<?php echo esc_url( $quiz_url ); ?>" target="_blank" rel="noopener">
        Regelfragen testen
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 13v6a2 2 0 01-2 2H5a2 2 0 01-2-2V8a2 2 0 012-2h6"/><polyline points="15 3 21 3 21 9"/><line x1="10" y1="14" x2="21" y2="3"/></svg>
      </a>
      <?php endif; ?>
    </div>

  </div>
</div>

<?php get_footer(); ?>
