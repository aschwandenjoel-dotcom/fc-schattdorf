<?php
/**
 * Template Name: Events
 * Template Post Type: page
 */
defined( 'ABSPATH' ) || exit;

add_action( 'wp_enqueue_scripts', function () {
    $dir = get_stylesheet_directory();
    $uri = get_stylesheet_directory_uri();
    wp_enqueue_style( 'fcs-events', $uri . '/assets/fcs-events.css', [], filemtime( $dir . '/assets/fcs-events.css' ) );
}, 5 );

/* Events aus der Datenbank (WP-Admin -> Events).
   Registrierung des Inhaltstyps und Abfrage: inc/fcs-events.php */
$events = fcs_get_events();

get_header();
?>

<div class="fce-page">

  <!-- ── Header ── -->
  <div class="fce-header">
    <div class="fce-header__inner">
      <div class="fce-header__label">FC Schattdorf</div>
      <h1>Events &amp; Veranstaltungen</h1>
    </div>
  </div>

  <!-- ── Event list ── -->
  <div class="fce-main">

    <?php if ( ! $events ) : ?>

      <p class="fce-detail__desc">Zurzeit sind keine Veranstaltungen erfasst.</p>

    <?php else : ?>

      <div class="fce-section-label">Upcoming Events <?php echo esc_html( $events[0]['datum']['jahr'] ?? '' ); ?></div>

      <?php foreach ( $events as $ev ) :
          $card_id = 'ev-' . $ev['id'];
          ?>
      <div class="fce-card" id="<?php echo esc_attr( $card_id ); ?>">
        <div class="fce-card__head" onclick="fcToggle('<?php echo esc_js( $card_id ); ?>')" role="button" aria-expanded="false" tabindex="0">
          <div class="fce-card__date">
            <span class="fce-card__date-day"><?php echo esc_html( $ev['datum']['tag'] ?? '' ); ?></span>
            <span class="fce-card__date-mon"><?php echo esc_html( $ev['datum']['mon_kurz'] ?? '' ); ?></span>
          </div>
          <div class="fce-card__body">
            <div class="fce-card__year"><?php echo esc_html( $ev['datum']['jahr'] ?? '' ); ?></div>
            <div class="fce-card__title"><?php echo esc_html( $ev['titel'] ); ?></div>
            <div class="fce-card__meta">
              <?php if ( $ev['ort_kurz'] ) : ?>
              <span class="fce-card__tag">
                <svg width="12" height="12" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>
                <?php echo esc_html( $ev['ort_kurz'] ); ?>
              </span>
              <?php endif; ?>
              <?php if ( $ev['zeit_kurz'] ) : ?>
              <span class="fce-card__tag">
                <svg width="12" height="12" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                <?php echo esc_html( $ev['zeit_kurz'] ); ?>
              </span>
              <?php endif; ?>
              <?php if ( $ev['zielgruppe'] ) : ?>
              <span class="fce-card__tag">
                <svg width="12" height="12" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87M16 3.13a4 4 0 0 1 0 7.75"/></svg>
                <?php echo esc_html( $ev['zielgruppe'] ); ?>
              </span>
              <?php endif; ?>
            </div>
          </div>
          <div class="fce-card__toggle" aria-hidden="true">
            <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
              <polyline points="6 9 12 15 18 9"/>
            </svg>
          </div>
        </div>

        <div class="fce-detail" id="<?php echo esc_attr( $card_id ); ?>-detail">
          <div class="fce-detail__inner">

            <?php if ( $ev['status'] ) : ?>
            <div class="fce-detail__status">
              <svg width="12" height="12" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
              <?php echo esc_html( $ev['status'] ); ?>
            </div>
            <?php endif; ?>

            <div class="fce-detail__grid">
              <?php if ( $ev['datum'] ) : ?>
              <div class="fce-detail__item">
                <span class="fce-detail__item-label">Datum</span>
                <span class="fce-detail__item-value"><?php echo esc_html( $ev['datum']['lang'] ); ?></span>
              </div>
              <?php endif; ?>
              <?php if ( $ev['zeit'] ) : ?>
              <div class="fce-detail__item">
                <span class="fce-detail__item-label">Uhrzeit</span>
                <span class="fce-detail__item-value"><?php echo esc_html( $ev['zeit'] ); ?></span>
              </div>
              <?php endif; ?>
              <?php if ( $ev['ort'] ) : ?>
              <div class="fce-detail__item">
                <span class="fce-detail__item-label">Ort</span>
                <span class="fce-detail__item-value"><?php echo esc_html( $ev['ort'] ); ?></span>
              </div>
              <?php endif; ?>
              <?php if ( $ev['ausgabe'] ) : ?>
              <div class="fce-detail__item">
                <span class="fce-detail__item-label">Ausgabe</span>
                <span class="fce-detail__item-value"><?php echo esc_html( $ev['ausgabe'] ); ?></span>
              </div>
              <?php endif; ?>
            </div>

            <?php if ( $ev['beschreibung'] ) : ?>
            <p class="fce-detail__desc">
              <?php echo esc_html( $ev['beschreibung'] ); ?>
            </p>
            <?php endif; ?>

            <?php if ( $ev['agenda'] ) : ?>
            <div class="fce-detail__agenda">
              <?php if ( $ev['agenda_titel'] ) : ?>
              <div class="fce-detail__agenda-title"><?php echo esc_html( $ev['agenda_titel'] ); ?></div>
              <?php endif; ?>
              <ul class="fce-detail__agenda-list">
                <?php foreach ( $ev['agenda'] as $punkt ) : ?>
                <li><?php echo esc_html( $punkt ); ?></li>
                <?php endforeach; ?>
              </ul>
            </div>
            <?php endif; ?>

          </div>
        </div>
      </div>
      <?php endforeach; ?>

    <?php endif; ?>

  </div>
</div>

<script>
function fcToggle(id) {
  var card = document.getElementById(id);
  var head = card.querySelector('.fce-card__head');
  var isOpen = card.classList.toggle('is-open');
  head.setAttribute('aria-expanded', isOpen ? 'true' : 'false');
}
document.querySelectorAll('.fce-card__head').forEach(function(h) {
  h.addEventListener('keydown', function(e) {
    if (e.key === 'Enter' || e.key === ' ') {
      e.preventDefault();
      h.click();
    }
  });
});
</script>

<?php get_footer(); ?>
