<?php
if ( ! defined( 'ABSPATH' ) ) exit;

$up      = wp_upload_dir()['baseurl'] . '/2026/06/';
$uri     = get_stylesheet_directory_uri();
$logo    = $uri . '/assets/img/fcs-logo-footer.svg';

$haupt = [
    ['img' => 'muoser-gray.png',            'name' => 'Muoser',           'url' => 'https://www.muoser.ch/'],
];
$patronat = [
    ['img' => 'GAMMA_4in1_CMYK.png',        'name' => 'GAMMA',             'url' => 'https://www.gamma-holding.ch/'],
];
$co = [
    ['img' => 'herger-kuechen-gray.png',    'name' => 'Herger Küchen AG',  'url' => 'https://herger-kuechen.ch/'],
    ['img' => 'brand-automobile-gray.png',  'name' => 'Brand Automobile',  'url' => 'https://www.brand-automobile.ch/'],
    ['img' => 'imholz-sport-gray.png',      'name' => 'Sport Imholz',      'url' => 'http://imholzsport.ch/'],
    ['img' => 'Cash.png',                   'name' => 'cash.',              'url' => 'https://cashsport.ch/'],
];
$club = [
    ['img' => 'gasthausbrueckli-gray.png',  'name' => 'Gasthaus Brückli',  'url' => 'https://www.brueckli.ch/'],
];
$nachwuchs = [
    ['img' => 'ewa-gray.png',               'name' => 'EWA energieUri',    'url' => 'https://www.energieuri.ch/'],
    ['img' => 'logo_ukb-gray.png',          'name' => 'Urner Kantonalbank','url' => 'https://www.ukb.ch'],
    ['img' => 'arnold-color.svg',           'name' => 'Arnold AG',         'url' => 'https://www.arnoldag.ch/'],
    ['img' => 'zahnarztpraxisuri-gray.png', 'name' => 'Zahnarzt-URI.ch',   'url' => 'https://zahnarzt-uri.ch/'],
];

$sp_sections = [
    ['label' => 'Hauptsponsor',        'items' => $haupt],
    ['label' => 'Nachwuchs-Patronat',  'items' => $patronat],
    ['label' => 'Co-Sponsoren',        'items' => $co],
    ['label' => 'Club-Sponsoren',      'items' => $club],
    ['label' => 'Nachwuchs-Sponsoren', 'items' => $nachwuchs],
];

$impressum_url   = home_url( '/impressum/' );
$datenschutz_url = home_url( '/datenschutzerklaerung/' );
$kontakt_url     = fcsh_page_url( 'kontakt', home_url( '/kontakt/' ) );
$vorstand_url    = fcsh_page_url( 'vorstand', home_url( '/vorstand/' ) );
$lageplan_url    = fcsh_page_url( 'anfahrt', home_url( '/anfahrt/' ) );
/* Mailchimp-Anmeldung (Original-URL von fcschattdorf.ch, validiert 24.07.2026) */
$newsletter_url  = 'https://us16.list-manage.com/subscribe?u=e95f0901b53137263a8b4fdd3&id=ed86c0b0f5';
?>

<?php astra_content_bottom(); ?>
    </div><!-- ast-container -->
    </div><!-- #content -->
<?php astra_content_after(); astra_footer_before(); ?>

<footer class="fcsh-footer">
  <div class="fcsh-footer__main">

    <!-- Left -->
    <div class="fcsh-footer__left" data-aos="fade-up">

      <div>
        <div class="fcsh-footer__nl-icon">
          <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="4" width="20" height="16" rx="2"/><path d="m2 7 10 7 10-7"/></svg>
        </div>
        <div class="fcsh-footer__nl-title">Newsletter</div>
      </div>

      <a href="<?php echo esc_url( $newsletter_url ); ?>" class="fcsh-footer__nl-link" target="_blank" rel="noopener">
        Jetzt anmelden
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14M12 5l7 7-7 7"/></svg>
      </a>

      <div class="fcsh-footer__logo">
        <a href="<?php echo esc_url( home_url( '/' ) ); ?>">
          <img src="<?php echo esc_url( $logo ); ?>" alt="FC Schattdorf">
        </a>
      </div>

      <div class="fcsh-footer__quicklinks">
        <a href="<?php echo esc_url( $kontakt_url ); ?>">Kontakt</a>
        <a href="<?php echo esc_url( $vorstand_url ); ?>">Vorstand</a>
        <a href="<?php echo esc_url( $lageplan_url ); ?>">Lageplan</a>
        <a href="<?php echo esc_url( admin_url() ); ?>" class="fcsh-footer__login">Login</a>
      </div>

    </div>

    <!-- Right: Sponsors -->
    <div class="fcsh-footer__right" data-aos="fade-up" data-aos-delay="100">
      <?php foreach ( $sp_sections as $sec ) : ?>
      <div class="fcsh-footer__sp-row">
        <div class="fcsh-footer__sp-label"><?php echo esc_html( $sec['label'] ); ?></div>
        <div class="fcsh-footer__sp-items">
          <?php foreach ( $sec['items'] as $sp ) : ?>
          <a href="<?php echo esc_url( $sp['url'] ); ?>" class="fcsh-footer__sp-item" target="_blank" rel="noopener noreferrer">
            <div class="fcsh-footer__sp-logo">
              <img src="<?php echo esc_url( $up . $sp['img'] ); ?>" alt="<?php echo esc_attr( $sp['name'] ); ?>">
            </div>
            <span class="fcsh-footer__sp-name"><?php echo esc_html( $sp['name'] ); ?></span>
          </a>
          <?php endforeach; ?>
        </div>
      </div>
      <?php endforeach; ?>
    </div>

  </div>

  <!-- Bottom bar -->
  <div class="fcsh-footer__bar">
    <span class="fcsh-footer__copy">&copy; <?php echo esc_html( date( 'Y' ) ); ?> FC Schattdorf &middot; Design &amp; Konzept: ubiqdesign (Original-Vorlage)</span>
    <div class="fcsh-footer__legal">
      <a href="<?php echo esc_url( $impressum_url ); ?>">Impressum</a>
      <a href="<?php echo esc_url( $datenschutz_url ); ?>">Datenschutz</a>
    </div>
  </div>
</footer>

<?php astra_footer_after(); ?>
    </div><!-- #page -->
<?php astra_body_bottom(); wp_footer(); ?>
</body>
</html>
