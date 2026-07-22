<?php
/**
 * Template Name: Mitglied werden
 * Template Post Type: page
 */
defined( 'ABSPATH' ) || exit;

add_action( 'wp_enqueue_scripts', function () {
    $dir = get_stylesheet_directory();
    $uri = get_stylesheet_directory_uri();
    wp_enqueue_style( 'fcs-mitglied', $uri . '/assets/fcs-mitglied.css', [], filemtime( $dir . '/assets/fcs-mitglied.css' ) );
}, 5 );

get_header();
?>

<div class="fcmb-page">

  <!-- ── Header ── -->
  <div class="fcmb-header">
    <h1 class="fcmb-header__title">Mitglied werden</h1>
    <p class="fcmb-header__sub">Beim FC Schattdorf ist jeder willkommen — ob aktiver Spieler, Junior oder Kind.</p>
  </div>

  <!-- ── Einstiegswege ── -->
  <div class="fcmb-tracks-wrap">
    <div class="fcmb-tracks">

      <!-- Aktivfussball -->
      <div class="fcmb-track fcmb-track--primary">
        <div class="fcmb-track__top">
          <span class="fcmb-track__tag">Aktivfussball</span>
          <svg class="fcmb-track__icon" viewBox="0 0 48 48" fill="none" aria-hidden="true">
            <circle cx="24" cy="14" r="7" stroke="currentColor" stroke-width="2"/>
            <path d="M8 42c0-8.837 7.163-16 16-16s16 7.163 16 16" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
          </svg>
          <h2 class="fcmb-track__title">Aktive Mannschaft</h2>
          <p class="fcmb-track__text">Du spielst Fussball und möchtest auf einem hohen Niveau trainieren? Melde dich unverbindlich bei unserem Sportchef — wir freuen uns auf dich.</p>
        </div>
        <div class="fcmb-track__contact">
          <div class="fcmb-track__contact-name">René Gnos</div>
          <div class="fcmb-track__contact-role">Sportchef</div>
          <div class="fcmb-track__contact-links">
            <a href="mailto:renegnos@bluewin.ch" class="fcmb-track__link fcmb-track__link--mail">renegnos@bluewin.ch</a>
            <a href="tel:+41794206120" class="fcmb-track__link fcmb-track__link--phone">079 420 61 20</a>
          </div>
        </div>
        <a href="mailto:renegnos@bluewin.ch" class="fcmb-track__cta">Kontakt aufnehmen</a>
      </div>

      <!-- Junioren A–C -->
      <div class="fcmb-track">
        <div class="fcmb-track__top">
          <span class="fcmb-track__tag">Junioren A–C</span>
          <svg class="fcmb-track__icon" viewBox="0 0 48 48" fill="none" aria-hidden="true">
            <circle cx="16" cy="14" r="6" stroke="currentColor" stroke-width="2"/>
            <circle cx="32" cy="14" r="6" stroke="currentColor" stroke-width="2"/>
            <path d="M2 40c0-7.732 6.268-14 14-14" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
            <path d="M32 26c7.732 0 14 6.268 14 14" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
            <path d="M18 40c0-3.314 2.686-6 6-6s6 2.686 6 6" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
          </svg>
          <h2 class="fcmb-track__title">Juniorenbereich</h2>
          <p class="fcmb-track__text">Für Anmeldungen im Juniorenbereich (A- bis C-Junioren) wende dich direkt an unseren Juniorenobmann und Vizepräsidenten.</p>
        </div>
        <div class="fcmb-track__contact">
          <div class="fcmb-track__contact-name">Iwan Herger</div>
          <div class="fcmb-track__contact-role">Vizepräsident · Juniorenobmann</div>
          <div class="fcmb-track__contact-links">
            <a href="mailto:juniorenabteilung@fcschattdorf.ch" class="fcmb-track__link fcmb-track__link--mail">juniorenabteilung@fcschattdorf.ch</a>
            <a href="tel:+41786989195" class="fcmb-track__link fcmb-track__link--phone">078 698 91 95</a>
          </div>
        </div>
        <a href="mailto:juniorenabteilung@fcschattdorf.ch" class="fcmb-track__cta">Kontakt aufnehmen</a>
      </div>

      <!-- Kinderfussball F–D -->
      <div class="fcmb-track">
        <div class="fcmb-track__top">
          <span class="fcmb-track__tag">Kinder F–D</span>
          <svg class="fcmb-track__icon" viewBox="0 0 48 48" fill="none" aria-hidden="true">
            <circle cx="24" cy="11" r="5.5" stroke="currentColor" stroke-width="2"/>
            <path d="M14 30c0-5.523 4.477-10 10-10s10 4.477 10 10v6H14v-6z" stroke="currentColor" stroke-width="2"/>
            <path d="M20 36v6M28 36v6" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
            <circle cx="12" cy="32" r="3" stroke="currentColor" stroke-width="1.5"/>
            <circle cx="36" cy="32" r="3" stroke="currentColor" stroke-width="1.5"/>
          </svg>
          <h2 class="fcmb-track__title">Kinderfussball</h2>
          <p class="fcmb-track__text">Die Jüngsten (F- bis D-Junioren) sind bei unserer KIFU-Leiterin in besten Händen. Einfach melden — Fussball macht Spass!</p>
        </div>
        <div class="fcmb-track__contact">
          <div class="fcmb-track__contact-name">Jacqueline Kempf</div>
          <div class="fcmb-track__contact-role">Leiterin KIFU · F–D Junioren</div>
          <div class="fcmb-track__contact-links">
            <a href="mailto:jacqueline.kempf-imholz@gmx.ch" class="fcmb-track__link fcmb-track__link--mail">jacqueline.kempf-imholz@gmx.ch</a>
            <a href="tel:+41787952967" class="fcmb-track__link fcmb-track__link--phone">078 795 29 67</a>
          </div>
        </div>
        <a href="mailto:jacqueline.kempf-imholz@gmx.ch" class="fcmb-track__cta">Kontakt aufnehmen</a>
      </div>

    </div>
  </div>

  <!-- ── Newsletter ── -->
  <div class="fcmb-newsletter">
    <div class="fcmb-newsletter__inner">
      <div class="fcmb-newsletter__text">
        <div class="fcmb-newsletter__label">Newsletter</div>
        <h2 class="fcmb-newsletter__title">Immer auf dem Laufenden</h2>
        <p class="fcmb-newsletter__sub">Spielberichte, Veranstaltungen, Neuigkeiten aus dem Verein — direkt in deinem Postfach.</p>
      </div>
      <a href="http://eepurl.com/fcschattdorf" target="_blank" rel="noopener noreferrer" class="fcmb-newsletter__btn">
        Newsletter abonnieren
        <svg viewBox="0 0 20 20" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M4 10h12M11 5l5 5-5 5"/></svg>
      </a>
    </div>
  </div>

</div><!-- .fcmb-page -->

<?php get_footer(); ?>
