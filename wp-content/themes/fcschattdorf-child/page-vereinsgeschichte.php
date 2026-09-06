<?php
/**
 * Template Name: Vereinsgeschichte
 * Template Post Type: page
 */
defined( 'ABSPATH' ) || exit;

add_action( 'wp_enqueue_scripts', function () {
    $dir = get_stylesheet_directory();
    $uri = get_stylesheet_directory_uri();
    wp_enqueue_style(  'fcs-vg', $uri . '/assets/fcs-vereinsgeschichte.css', [], filemtime( $dir . '/assets/fcs-vereinsgeschichte.css' ) );
    wp_enqueue_script( 'fcs-vg', $uri . '/assets/fcs-vereinsgeschichte.js',  [], filemtime( $dir . '/assets/fcs-vereinsgeschichte.js' ), true );
}, 5 );

add_filter( 'body_class', function ( $c ) { $c[] = 'fcx-wine-page'; return $c; } );

/* Chronik-Einträge aus der Datenbank (WP-Admin -> Chronik).
   Registrierung des Inhaltstyps und Abfrage: inc/fcs-chronik.php */
$events = fcs_get_chronik_events();

/* Gründungsjahr für Kopfzeile und Zähler. Bewusst NICHT aus dem ersten
   Chronik-Eintrag abgeleitet, sondern über das Seitenfeld
   «Gründungsjahr» gesetzt: der Verein zählt ab der Neugründung 1933 (so
   auch der Claim im Footer), unabhängig davon, womit die Chronik gerade
   beginnt. */
$fcs_founded = (int) fcs_pf( 'vg_gruendung', 1933 );
$fcs_years   = max( 0, (int) current_time( 'Y' ) - $fcs_founded );

get_header();
?>

<div id="fcvgProgress" class="fcvg-progress-bar" aria-hidden="true"></div>

<div class="fcvg-page">

  <!-- ══════════════════ HERO ══════════════════ -->
  <section class="fcvg-hero">
    <div class="fcvg-hero__content">
      <h1 class="fcvg-hero__title">Vereinsgeschichte</h1>
      <p class="fcvg-hero__eyebrow">FC Schattdorf &middot; Kanton Uri &middot; Gegründet <?php echo $fcs_founded; ?></p>
    </div>
  </section>

  <!-- ══════════════════ DECADE NAV ══════════════════ -->
  <nav class="fcvg-nav" id="fcvgNav" aria-label="Jahrzehnte Navigation">
    <div class="fcvg-nav__inner">
      <?php
      $decades = array_unique( array_map( fn($e) => (int)( $e['year'] / 10 ) * 10, $events ) );
      foreach ( $decades as $d ) {
          echo '<a class="fcvg-nav__link" href="#decade-' . $d . '">' . $d . 'er</a>';
      }
      ?>
    </div>
  </nav>

  <!-- ══════════════════ STATS ══════════════════ -->
  <section class="fcvg-statsbar">
    <div class="fcvg-hero__stats">
      <div class="fcvg-stat">
        <span class="fcvg-stat__num" data-count="<?php echo $fcs_years; ?>"><?php echo $fcs_years; ?></span>
        <span class="fcvg-stat__label">Jahre Geschichte</span>
      </div>
      <div class="fcvg-stat fcvg-stat--accent">
        <span class="fcvg-stat__num" data-count="3">3</span><span class="fcvg-stat__x">×</span>
        <span class="fcvg-stat__label">IFV-Cup Champion</span>
      </div>
      <div class="fcvg-stat">
        <span class="fcvg-stat__num" data-count="<?php echo count( $events ); ?>"><?php echo count( $events ); ?></span>
        <span class="fcvg-stat__label">Kapitel unserer Story</span>
      </div>
    </div>
  </section>

  <!-- ══════════════════ TIMELINE ══════════════════ -->
  <div class="fcvg-timeline" id="fcvgTimeline">
    <div class="fcvg-spine" aria-hidden="true"></div>

    <?php
    $current_decade = null;
    foreach ( $events as $i => $ev ) :
        $decade = (int)( $ev['year'] / 10 ) * 10;
        $is_ms  = !empty( $ev['milestone'] );

        if ( $decade !== $current_decade ) :
            $current_decade = $decade;
            ?>
            <div class="fcvg-decade" id="decade-<?php echo $decade; ?>">
              <span class="fcvg-decade__label"><?php echo $decade; ?>er</span>
              <span class="fcvg-decade__rule" aria-hidden="true"></span>
            </div>
            <?php
        endif;
        ?>

        <article class="fcvg-entry<?php echo $is_ms ? ' fcvg-entry--milestone' : ''; ?>"
                 data-year="<?php echo esc_attr( $ev['year'] ); ?>"
                 data-cat="<?php echo esc_attr( $ev['cat'] ); ?>">

          <div class="fcvg-entry__year" aria-hidden="true"><?php echo $ev['year']; ?></div>

          <div class="fcvg-entry__node" aria-hidden="true">
            <div class="fcvg-entry__dot"></div>
          </div>

          <div class="fcvg-entry__card">
            <div class="fcvg-entry__body">
              <?php if ( $is_ms ) : ?>
                <span class="fcvg-entry__badge">
                  <svg viewBox="0 0 24 24" fill="currentColor" width="9" height="9" aria-hidden="true">
                    <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/>
                  </svg>
                  Meilenstein
                </span>
              <?php endif; ?>
              <h3 class="fcvg-entry__title"><?php echo esc_html( $ev['title'] ); ?></h3>
              <div class="fcvg-entry__text"><?php echo wp_kses_post( apply_filters( 'the_content', $ev['text'] ) ); ?></div>
            </div>
          </div>

        </article>

    <?php endforeach; ?>
  </div><!-- .fcvg-timeline -->

</div><!-- .fcvg-page -->

<?php get_footer(); ?>
