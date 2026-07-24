<?php
/**
 * Template Name: Anfahrt
 * Template Post Type: page
 *
 * Anlagen-Angaben, Parkplätze und Hinweise werden über die Feld-Box
 * «Seiteninhalte» gepflegt (inc/fcs-fields-design1.php); das Layout
 * kommt aus der Vorlage.
 */
defined( 'ABSPATH' ) || exit;

add_action( 'wp_enqueue_scripts', function () {
    $dir = get_stylesheet_directory();
    $uri = get_stylesheet_directory_uri();
    wp_enqueue_style( 'fcs-anfahrt', $uri . '/assets/fcs-anfahrt.css', [], filemtime( $dir . '/assets/fcs-anfahrt.css' ) );
}, 5 );

add_filter( 'body_class', function ( $c ) { $c[] = 'fcx-wine-page'; return $c; } );

get_header();

$haupt_name    = fcs_pf( 'an_haupt_name', 'Grüner Wald' );
$haupt_adresse = fcs_pf_lines( 'an_haupt_adresse', array( 'Sportplatz Grüner Wald', '6467 Schattdorf UR' ) );
$haupt_specs   = fcs_pf_lines( 'an_haupt_specs', array(
	'Belag | Kunstrasen EN-15330',
	'Masse | 100 × 61,5 m',
	'Kapazität | ca. 900 Stehplätze',
	'Beleuchtung | 177 LUX',
	'Zulassung | 2. Liga interregional',
) );
$neben_name    = fcs_pf( 'an_neben_name', 'Grundmatte' );
$neben_adresse = fcs_pf_lines( 'an_neben_adresse', array( 'Sportanlage Grundmatte', '6467 Schattdorf UR' ) );
$neben_specs   = fcs_pf_lines( 'an_neben_specs', array(
	'Belag | Kunststoffrasen',
	'Masse | 94 × 60 m',
	'Kapazität | ca. 200 Stehplätze',
	'Beleuchtung | 120 LUX',
	'Garderoben | Turnhalle Grundmatte',
) );
$parkplaetze   = fcs_pf_lines( 'an_parkplaetze', array(
	'Feuerwehrlokal | kostenlos',
	'Grundmatte | 4 Stunden gratis, Parkscheibe erforderlich',
	'Dorfstrasse | Nähe alte Post, gebührenpflichtig',
) );
$park_hinweis  = fcs_pf( 'an_park_hinweis', 'Bitte keine reservierten Parkplätze der Coop-Tankstelle sowie Restaurant-, Laden- oder Privatparkplätze belegen.' );
$stollen       = fcs_pf( 'an_stollen_hinweis', 'Auf beiden Kunstrasenplätzen sind keine Stollenschuhe gestattet.' );
?>

<div class="fcan-page">

  <!-- ── Titel ── -->
  <div class="fcan-header">
    <h1 class="fcan-header__title">So finden Sie uns</h1>
    <p class="fcan-header__sub">FC Schattdorf · Kanton Uri</p>
  </div>

  <!-- ── Google Maps ── -->
  <div class="fcan-map">
    <iframe
      src="https://maps.google.com/maps?q=Sportplatz+Gr%C3%BCner+Wald%2C+6467+Schattdorf&t=&z=16&ie=UTF8&iwloc=&output=embed"
      width="100%"
      height="460"
      style="border:0;"
      allowfullscreen=""
      loading="lazy"
      referrerpolicy="no-referrer-when-downgrade"
      title="Sportplatz Grüner Wald, Schattdorf">
    </iframe>
  </div>

  <!-- ── Anlagen ── -->
  <div class="fcan-content">

    <div class="fcan-locations">

      <div class="fcan-location fcan-location--main">
        <div class="fcan-location__tag">Hauptplatz</div>
        <h2 class="fcan-location__name"><?php echo esc_html( $haupt_name ); ?></h2>
        <address class="fcan-location__address">
          <?php echo implode( '<br>', array_map( 'esc_html', $haupt_adresse ) ); ?>
        </address>
        <ul class="fcan-specs">
          <?php foreach ( $haupt_specs as $zeile ) :
              $teile = array_map( 'trim', explode( '|', $zeile ) ); ?>
            <li><span><?php echo esc_html( $teile[0] ); ?></span><span><?php echo esc_html( $teile[1] ?? '' ); ?></span></li>
          <?php endforeach; ?>
        </ul>
      </div>

      <div class="fcan-location">
        <div class="fcan-location__tag">Nebenplatz</div>
        <h2 class="fcan-location__name"><?php echo esc_html( $neben_name ); ?></h2>
        <address class="fcan-location__address">
          <?php echo implode( '<br>', array_map( 'esc_html', $neben_adresse ) ); ?>
        </address>
        <ul class="fcan-specs">
          <?php foreach ( $neben_specs as $zeile ) :
              $teile = array_map( 'trim', explode( '|', $zeile ) ); ?>
            <li><span><?php echo esc_html( $teile[0] ); ?></span><span><?php echo esc_html( $teile[1] ?? '' ); ?></span></li>
          <?php endforeach; ?>
        </ul>
      </div>

    </div>

    <!-- ── Parkplätze ── -->
    <div class="fcan-parking">
      <h3 class="fcan-parking__title">Parkplätze</h3>
      <ul class="fcan-parking__list">
        <?php foreach ( $parkplaetze as $zeile ) :
            $teile = array_map( 'trim', explode( '|', $zeile ) ); ?>
          <li>
            <strong><?php echo esc_html( $teile[0] ); ?></strong>
            <span><?php echo esc_html( $teile[1] ?? '' ); ?></span>
          </li>
        <?php endforeach; ?>
      </ul>
      <p class="fcan-parking__note"><?php echo esc_html( $park_hinweis ); ?></p>
    </div>

    <!-- ── Hinweis Stollenschuhe ── -->
    <div class="fcan-notice">
      <?php echo esc_html( $stollen ); ?>
    </div>

  </div>

</div><!-- .fcan-page -->

<?php get_footer(); ?>
