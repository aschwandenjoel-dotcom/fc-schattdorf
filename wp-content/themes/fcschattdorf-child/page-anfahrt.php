<?php
/**
 * Template Name: Anfahrt
 * Template Post Type: page
 */
defined( 'ABSPATH' ) || exit;

add_action( 'wp_enqueue_scripts', function () {
    $dir = get_stylesheet_directory();
    $uri = get_stylesheet_directory_uri();
    wp_enqueue_style( 'fcs-anfahrt', $uri . '/assets/fcs-anfahrt.css', [], filemtime( $dir . '/assets/fcs-anfahrt.css' ) );
}, 5 );

add_filter( 'body_class', function ( $c ) { $c[] = 'fcx-wine-page'; return $c; } );

get_header();
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
        <h2 class="fcan-location__name">Grüner Wald</h2>
        <address class="fcan-location__address">
          Sportplatz Grüner Wald<br>
          6467 Schattdorf UR
        </address>
        <ul class="fcan-specs">
          <li><span>Belag</span><span>Kunstrasen EN-15330</span></li>
          <li><span>Masse</span><span>100 × 61,5 m</span></li>
          <li><span>Kapazität</span><span>ca. 900 Stehplätze</span></li>
          <li><span>Beleuchtung</span><span>177 LUX</span></li>
          <li><span>Zulassung</span><span>2. Liga interregional</span></li>
        </ul>
      </div>

      <div class="fcan-location">
        <div class="fcan-location__tag">Nebenplatz</div>
        <h2 class="fcan-location__name">Grundmatte</h2>
        <address class="fcan-location__address">
          Sportanlage Grundmatte<br>
          6467 Schattdorf UR
        </address>
        <ul class="fcan-specs">
          <li><span>Belag</span><span>Kunststoffrasen</span></li>
          <li><span>Masse</span><span>94 × 60 m</span></li>
          <li><span>Kapazität</span><span>ca. 200 Stehplätze</span></li>
          <li><span>Beleuchtung</span><span>120 LUX</span></li>
          <li><span>Garderoben</span><span>Turnhalle Grundmatte</span></li>
        </ul>
      </div>

    </div>

    <!-- ── Parkplätze ── -->
    <div class="fcan-parking">
      <h3 class="fcan-parking__title">Parkplätze</h3>
      <ul class="fcan-parking__list">
        <li>
          <strong>Feuerwehrlokal</strong>
          <span>kostenlos</span>
        </li>
        <li>
          <strong>Grundmatte</strong>
          <span>4 Stunden gratis, Parkscheibe erforderlich</span>
        </li>
        <li>
          <strong>Dorfstrasse</strong>
          <span>Nähe alte Post, gebührenpflichtig</span>
        </li>
      </ul>
      <p class="fcan-parking__note">Bitte keine reservierten Parkplätze der Coop-Tankstelle sowie Restaurant-, Laden- oder Privatparkplätze belegen.</p>
    </div>

    <!-- ── Hinweis Stollenschuhe ── -->
    <div class="fcan-notice">
      Auf beiden Kunstrasenplätzen sind keine Stollenschuhe gestattet.
    </div>

  </div>

</div><!-- .fcan-page -->

<?php get_footer(); ?>
