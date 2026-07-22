<?php
/**
 * Template Name: Vorfall melden
 * Template Post Type: page
 */
defined( 'ABSPATH' ) || exit;

add_action( 'wp_enqueue_scripts', function () {
    $dir = get_stylesheet_directory();
    $uri = get_stylesheet_directory_uri();
    wp_enqueue_style( 'fcs-vorfall', $uri . '/assets/fcs-vorfall.css', [], filemtime( $dir . '/assets/fcs-vorfall.css' ) );
}, 5 );

add_filter( 'body_class', function ( $c ) { $c[] = 'fcx-wine-page'; return $c; } );

get_header();
?>

<div class="fcvf-page">

  <!-- ── Titel ── -->
  <div class="fcvf-header">
    <h1 class="fcvf-header__title">Vorfall oder Verdacht melden</h1>
    <p class="fcvf-header__sub">FC Schattdorf — Anlaufstelle für Ethikvorfälle</p>
  </div>

  <div class="fcvf-content">

    <!-- ── Einleitung ── -->
    <p class="fcvf-intro">
      Der FC Schattdorf nimmt den Schutz aller Vereinsmitglieder — insbesondere der Kinder und Jugendlichen — sehr ernst. Wer Zeuge eines Vorfalls wird oder einen Verdacht hat, kann diesen vertraulich und wenn gewünscht anonym melden.
    </p>

    <!-- ── Swiss Sport Integrity (primärer Kanal) ── -->
    <section class="fcvf-ssi">
      <div class="fcvf-ssi__inner">
        <div class="fcvf-ssi__label">Offizielle Meldestelle</div>
        <h2 class="fcvf-ssi__title">Swiss Sport Integrity</h2>
        <p class="fcvf-ssi__text">
          Swiss Sport Integrity ist die unabhängige Anlaufstelle für Ethikvorfälle im Schweizer Sport. Alle Meldungen werden vertraulich behandelt — eine Meldung ist auch vollständig anonym möglich.
        </p>
        <div class="fcvf-ssi__channels">
          <a class="fcvf-ssi__btn" href="https://swisssportintegrity.integrityline.io" target="_blank" rel="noopener noreferrer">
            Online melden
            <svg viewBox="0 0 20 20" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M4 10h12M11 5l5 5-5 5"/></svg>
          </a>
          <div class="fcvf-ssi__hotline">
            <span class="fcvf-ssi__hotline-label">Hotline</span>
            <a href="tel:+41315502131" class="fcvf-ssi__hotline-num">+41 31 550 21 31</a>
            <span class="fcvf-ssi__hotline-hours">Mo–Fr, 8:30–11:30 und 13:30–16:30 Uhr</span>
          </div>
        </div>
        <p class="fcvf-ssi__link-note">
          Weitere Informationen:
          <a href="https://www.sportintegrity.ch/organisation/vorfall-melden" target="_blank" rel="noopener noreferrer">sportintegrity.ch</a>
        </p>
      </div>
    </section>

    <!-- ── Was kann gemeldet werden ── -->
    <section class="fcvf-section">
      <h2 class="fcvf-section__title">Was kann gemeldet werden?</h2>
      <ul class="fcvf-list">
        <li>Unfaires oder grenzüberschreitendes Verhalten</li>
        <li>Verdacht auf Gewalt oder Missbrauch</li>
        <li>Diskriminierung oder Mobbing</li>
        <li>Verstösse gegen den Verhaltenskodex des FC Schattdorf</li>
        <li>Ethikverstösse und Missstände in der Vereinsstruktur</li>
        <li>Verdacht auf Doping</li>
      </ul>
    </section>

    <!-- ── Interne Ansprechpersonen ── -->
    <section class="fcvf-section">
      <h2 class="fcvf-section__title">Interne Ansprechpersonen</h2>
      <p class="fcvf-section__lead">
        Für eine erste Auskunft oder wenn jemand innerhalb des Vereins lieber direkt Kontakt aufnehmen möchte, stehen folgende Personen zur Verfügung:
      </p>
      <div class="fcvf-contacts">
        <div class="fcvf-contact">
          <div class="fcvf-contact__role">Präsident</div>
          <div class="fcvf-contact__name">Ralph Bomatter</div>
          <a href="mailto:praesident@fcschattdorf.ch" class="fcvf-contact__link">praesident@fcschattdorf.ch</a>
          <a href="tel:+41793904201" class="fcvf-contact__link">079 390 42 01</a>
        </div>
        <div class="fcvf-contact">
          <div class="fcvf-contact__role">Administration</div>
          <div class="fcvf-contact__name">Monja Deplazes</div>
          <a href="mailto:admin@fcschattdorf.ch" class="fcvf-contact__link">admin@fcschattdorf.ch</a>
          <a href="tel:+41786584434" class="fcvf-contact__link">078 658 44 34</a>
        </div>
      </div>
    </section>

    <!-- ── Vertraulichkeit ── -->
    <div class="fcvf-notice">
      Alle Meldungen — intern wie extern — werden absolut vertraulich behandelt. Es besteht keine Pflicht, sich zu identifizieren.
    </div>

  </div>

</div><!-- .fcvf-page -->

<?php get_footer(); ?>
