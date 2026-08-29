<?php
/**
 * Template Name: Ehrenmitglieder
 * Template Post Type: page
 *
 * Die Personen werden im WP-Admin unter «Ehrungen» gepflegt
 * (Inhaltstyp fcs_ehrung, siehe inc/fcs-ehrenmitglieder.php).
 */
defined( 'ABSPATH' ) || exit;

add_action( 'wp_enqueue_scripts', function () {
    $dir = get_stylesheet_directory();
    $uri = get_stylesheet_directory_uri();
    wp_enqueue_style( 'fcs-ehrenmitglieder', $uri . '/assets/fcs-ehrenmitglieder.css', [], filemtime( $dir . '/assets/fcs-ehrenmitglieder.css' ) );
}, 5 );

add_filter( 'body_class', function ( $c ) { $c[] = 'fcx-wine-page'; return $c; } );

$ehrungen        = fcs_get_ehrungen();
$ehrenpraesident = $ehrungen['ehrenpraesident'];
$ehrenmitglieder = $ehrungen['ehrenmitglied'];
$freimitglieder  = $ehrungen['freimitglied'];

function fcs_ehren_row( $p ) {
    $dead = str_starts_with( $p['name'], '†' );
    $cls  = $dead ? ' class="row--deceased"' : '';
    return '<tr' . $cls . '>'
         . '<td>' . esc_html( $p['name'] ) . '</td>'
         . '<td>' . esc_html( $p['ort'] ) . '</td>'
         . '<td>' . esc_html( $p['geb'] ) . '</td>'
         . '<td>' . esc_html( $p['jahr'] ) . '</td>'
         . '</tr>';
}

get_header();
?>

<div class="fcem-page">

  <!-- ── Hero ── -->
  <div class="fcem-hero">
    <h1 class="fcem-hero__title">
      <span class="fcem-hero__line1">Ehren- &amp;</span>
      <span class="fcem-hero__line2">Freimitglieder</span>
    </h1>
    <p class="fcem-hero__eyebrow">FC Schattdorf &middot; seit 1926</p>
    <div class="fcem-hero__redline"></div>
  </div>

  <!-- ── Stats ── -->
  <div class="fcem-stats">
    <div class="fcem-stats__item">
      <div class="fcem-stats__num"><?php echo count($ehrenpraesident); ?></div>
      <div class="fcem-stats__label">Ehrenpräsident</div>
    </div>
    <div class="fcem-stats__sep"></div>
    <div class="fcem-stats__item">
      <div class="fcem-stats__num"><?php echo count($ehrenmitglieder); ?></div>
      <div class="fcem-stats__label">Ehrenmitglieder</div>
    </div>
    <div class="fcem-stats__sep"></div>
    <div class="fcem-stats__item">
      <div class="fcem-stats__num"><?php echo count($freimitglieder); ?></div>
      <div class="fcem-stats__label">Freimitglieder</div>
    </div>
  </div>

  <!-- ── Ehrenpräsident ── -->
  <div class="fcem-block">
    <div class="fcem-block__header">
      <span class="fcem-block__tag">Ehrenpräsident</span>
    </div>
    <table class="fcem-table">
      <thead><tr><th>Name / Vorname</th><th>Wohnort</th><th>Geburtsdatum</th><th>Wahljahr</th></tr></thead>
      <tbody>
        <?php /* Zeile bewusst ohne row--deceased-Klasse – wie die frühere statische Ausgabe */ ?>
        <?php foreach ( $ehrenpraesident as $p ) : ?>
        <tr><td><?php echo esc_html( $p['name'] ); ?></td><td><?php echo esc_html( $p['ort'] ); ?></td><td><?php echo esc_html( $p['geb'] ); ?></td><td><?php echo esc_html( $p['jahr'] ); ?></td></tr>
        <?php endforeach; ?>
      </tbody>
    </table>
  </div>

  <!-- ── Ehrenmitglieder ── -->
  <div class="fcem-block">
    <div class="fcem-block__header">
      <span class="fcem-block__tag">Ehrenmitglieder</span>
    </div>
    <table class="fcem-table">
      <thead><tr><th>Name / Vorname</th><th>Wohnort</th><th>Geburtsdatum</th><th>Wahljahr</th></tr></thead>
      <tbody>
        <?php foreach ( $ehrenmitglieder as $p ) echo fcs_ehren_row( $p ); ?>
      </tbody>
    </table>
  </div>

  <!-- ── Freimitglieder ── -->
  <div class="fcem-block">
    <div class="fcem-block__header">
      <span class="fcem-block__tag">Freimitglieder</span>
    </div>
    <table class="fcem-table">
      <thead><tr><th>Name / Vorname</th><th>Wohnort</th><th>Geburtsdatum</th><th>Wahljahr</th></tr></thead>
      <tbody>
        <?php foreach ( $freimitglieder as $p ) echo fcs_ehren_row( $p ); ?>
      </tbody>
    </table>
  </div>

  <div class="fcem-footer-note">&dagger; = verstorben</div>

</div><!-- .fcem-page -->

<?php get_footer(); ?>
