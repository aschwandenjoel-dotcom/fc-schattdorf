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

    <div class="fce-section-label">Upcoming Events 2026</div>

    <!-- ── Generalversammlung ── -->
    <div class="fce-card" id="ev-gv">
      <div class="fce-card__head" onclick="fcToggle('ev-gv')" role="button" aria-expanded="false" tabindex="0">
        <div class="fce-card__date">
          <span class="fce-card__date-day">21</span>
          <span class="fce-card__date-mon">Aug</span>
        </div>
        <div class="fce-card__body">
          <div class="fce-card__year">2026</div>
          <div class="fce-card__title">93. Generalversammlung</div>
          <div class="fce-card__meta">
            <span class="fce-card__tag">
              <svg width="12" height="12" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>
              Ort folgt
            </span>
            <span class="fce-card__tag">
              <svg width="12" height="12" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
              Zeit folgt
            </span>
            <span class="fce-card__tag">
              <svg width="12" height="12" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87M16 3.13a4 4 0 0 1 0 7.75"/></svg>
              Alle Mitglieder
            </span>
          </div>
        </div>
        <div class="fce-card__toggle" aria-hidden="true">
          <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
            <polyline points="6 9 12 15 18 9"/>
          </svg>
        </div>
      </div>

      <div class="fce-detail" id="ev-gv-detail">
        <div class="fce-detail__inner">

          <div class="fce-detail__status">
            <svg width="12" height="12" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
            Einladung folgt zu gegebener Zeit
          </div>

          <div class="fce-detail__grid">
            <div class="fce-detail__item">
              <span class="fce-detail__item-label">Datum</span>
              <span class="fce-detail__item-value">Freitag, 21. August 2026</span>
            </div>
            <div class="fce-detail__item">
              <span class="fce-detail__item-label">Uhrzeit</span>
              <span class="fce-detail__item-value">Wird bekannt gegeben</span>
            </div>
            <div class="fce-detail__item">
              <span class="fce-detail__item-label">Ort</span>
              <span class="fce-detail__item-value">Wird bekannt gegeben</span>
            </div>
            <div class="fce-detail__item">
              <span class="fce-detail__item-label">Ausgabe</span>
              <span class="fce-detail__item-value">93. Generalversammlung</span>
            </div>
          </div>

          <p class="fce-detail__desc">
            Die Generalversammlung ist das höchste Organ des FC Schattdorf. Alle Aktivmitglieder sind herzlich eingeladen teilzunehmen und die Zukunft des Vereins mitzugestalten. Die formelle Einladung mit Traktanden wird rechtzeitig versandt.
          </p>

          <div class="fce-detail__agenda">
            <div class="fce-detail__agenda-title">Traktanden (vorläufig)</div>
            <ul class="fce-detail__agenda-list">
              <li>Begrüssung &amp; Feststellung der Beschlussfähigkeit</li>
              <li>Abnahme des Protokolls der letzten GV</li>
              <li>Jahresbericht des Präsidenten</li>
              <li>Jahresrechnung &amp; Revisorenbericht</li>
              <li>Festsetzung der Mitgliederbeiträge</li>
              <li>Wahlen des Vorstands</li>
              <li>Verschiedenes &amp; Anträge</li>
            </ul>
          </div>

        </div>
      </div>
    </div>
    <!-- / Generalversammlung -->

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
