<?php
/**
 * Template Name: Helfereinsätze
 * Template Post Type: page
 */
defined( 'ABSPATH' ) || exit;

add_action( 'wp_enqueue_scripts', function () {
    $dir = get_stylesheet_directory();
    $uri = get_stylesheet_directory_uri();
    wp_enqueue_style( 'fcs-helfereinsaetze', $uri . '/assets/fcs-helfereinsaetze.css', [], filemtime( $dir . '/assets/fcs-helfereinsaetze.css' ) );
}, 5 );

$up = wp_upload_dir()['baseurl'] . '/2026/06/';

get_header();
?>

<div class="fche-page">

  <!-- ── Hero ── -->
  <div class="fche-hero">
    <img class="fche-hero__img" src="<?php echo esc_url( $up . 'Helferportal1.jpg' ); ?>" alt="Helfereinsätze">
    <div class="fche-hero__scrim"></div>
    <div class="fche-hero__text">
      <h1 class="fche-hero__heading fche-in">Helfereinsätze</h1>
    </div>
  </div>

  <div class="fche-content">

    <!-- ── Portal-Hinweis ── -->
    <div class="fche-portal fche-in">
      <div class="fche-portal__label">Registrierung</div>
      <p class="fche-portal__text">
        Der FC Schattdorf nutzt ab der Rückrunde 24/25 ein neues <a href="https://portal.helfereinsatz.ch/fc-schattdorf/" target="_blank" rel="noopener noreferrer">Helferportal<svg viewBox="0 0 20 20" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M4 10h12M11 5l5 5-5 5"/></svg></a>. Das System ermöglicht es Mitgliedern, sich einfach zu registrieren und für verschiedene freiwillige Aufgaben anzumelden – unter anderem Clubhaus (Buffet), Grillstand und weitere Einsätze.
      </p>
    </div>

    <!-- ── Wer soll sich anmelden? ── -->
    <section class="fche-section fche-in">
      <h2 class="fche-section__title">Wer soll sich anmelden?</h2>
      <ul class="fche-eligibility">
        <li><svg viewBox="0 0 20 20" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M4 10.5l4 4 8-9"/></svg>Bisherige Helfer</li>
        <li><svg viewBox="0 0 20 20" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M4 10.5l4 4 8-9"/></svg>Aktive Spieler</li>
        <li><svg viewBox="0 0 20 20" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M4 10.5l4 4 8-9"/></svg>C-, B-, A-Junioren und FF-19-Juniorinnen</li>
        <li><svg viewBox="0 0 20 20" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M4 10.5l4 4 8-9"/></svg>Eltern von F-, E- und D-Junioren</li>
      </ul>
    </section>

    <!-- ── Anleitung herunterladen ── -->
    <section class="fche-section fche-in">
      <h2 class="fche-section__title">Anleitung herunterladen</h2>
      <a class="fche-download" href="<?php echo esc_url( $up . 'Anleitung_Helferportal_FCS_25_03_05.pdf' ); ?>" target="_blank" rel="noopener">
        <span class="fche-download__icon">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
        </span>
        <span>
          <span class="fche-download__label">📄 Anleitung Registrierung und Anmeldung Helferportal (PDF)</span>
        </span>
        <svg class="fche-download__arrow" viewBox="0 0 20 20" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M4 10h12M11 5l5 5-5 5"/></svg>
      </a>
    </section>

  </div>

</div><!-- .fche-page -->

<?php get_footer(); ?>
