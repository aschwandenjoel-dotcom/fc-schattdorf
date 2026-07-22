<?php
/**
 * Template Name: Grümpelturnier
 * Template Post Type: page
 */
defined( 'ABSPATH' ) || exit;

add_action( 'wp_enqueue_scripts', function () {
    $dir = get_stylesheet_directory();
    $uri = get_stylesheet_directory_uri();
    wp_enqueue_style( 'fcs-gruempelturnier', $uri . '/assets/fcs-gruempelturnier.css', [], filemtime( $dir . '/assets/fcs-gruempelturnier.css' ) );
}, 5 );

$up = wp_upload_dir()['baseurl'] . '/2026/06/';

get_header();
?>

<div class="fgt-page">

  <!-- ══════════════════════════════════════════
       PAGE TITLE
  ══════════════════════════════════════════ -->
  <div style="background:#fff;border-bottom:1px solid #e5e7eb;padding:3rem 2.5rem 2.5rem;">
    <div style="max-width:1100px;margin:0 auto;">
      <div style="font-size:.6875rem;font-weight:800;text-transform:uppercase;letter-spacing:.18em;color:#E30613;margin-bottom:.75rem;display:flex;align-items:center;gap:.5rem;">
        <span style="display:inline-block;width:20px;height:2px;background:#E30613;"></span>
        33. Dorfturnier &nbsp;·&nbsp; 66. Grümpelturnier
      </div>
      <h1 style="font-size:clamp(1.75rem,3.5vw,2.5rem);font-weight:900;color:#111;margin:0 0 .75rem;text-transform:uppercase;letter-spacing:-.01em;line-height:1.1;">Dorf- &amp; Grümpelturnier 2026</h1>
      <div style="font-size:1rem;color:#6b7280;">19. &amp; 20. Juni 2026 &nbsp;·&nbsp; Sportplatz Grüner Wald, Schattdorf</div>
    </div>
  </div>

  <!-- ══════════════════════════════════════════
       PROGRAMM
  ══════════════════════════════════════════ -->
  <section class="fgt-section fgt-section--white">
    <div class="fgt-inner">
      <div class="fgt-section__header">
        <h2>Programm</h2>
      </div>

      <div class="fgt-program">

        <div class="fgt-program-day">
          <div class="fgt-program-day__date">
            <div class="fgt-program-day__weekday">Donnerstag</div>
            <div class="fgt-program-day__dmy">18. Juni <span>Intern</span></div>
          </div>
          <div class="fgt-program-day__body">
            <div class="fgt-program-day__badge fgt-program-day__badge--gray">FCS Intern</div>
            <div class="fgt-program-day__title">Vereinsinternes Turnier</div>
            <div class="fgt-program-day__desc">Das Turnierwochenende startet mit einem internen Fussballturnier für Mitglieder und Angehörige des FC Schattdorf.</div>
          </div>
        </div>

        <div class="fgt-program-day">
          <div class="fgt-program-day__date">
            <div class="fgt-program-day__weekday">Freitag</div>
            <div class="fgt-program-day__dmy">19. Juni <span>Dorfturnier</span></div>
          </div>
          <div class="fgt-program-day__body">
            <div class="fgt-program-day__badge">Dorfturnier</div>
            <div class="fgt-program-day__title">33. Dorfturnier – Vereine &amp; Firmen</div>
            <div class="fgt-program-day__desc">Am Freitag treten lokale Vereine, Firmen und Betriebe gegeneinander an. Ein geselliger Wettbewerb mit Grillstand und DJ-Abend.</div>
          </div>
        </div>

        <div class="fgt-program-day">
          <div class="fgt-program-day__date">
            <div class="fgt-program-day__weekday">Samstag</div>
            <div class="fgt-program-day__dmy">20. Juni <span>Grümpelturnier</span></div>
          </div>
          <div class="fgt-program-day__body">
            <div class="fgt-program-day__badge">Grümpelturnier</div>
            <div class="fgt-program-day__title">66. Grümpelturnier – 6 Kategorien</div>
            <div class="fgt-program-day__desc">Der grosse Turniertag mit allen Nachwuchs- und Aktivkategorien: Piccolo, Knaben 2, Knaben 1, Mädchen, Herren und Mixed. Parallel dazu: Public Viewing der FIFA WM 2026.</div>
          </div>
        </div>

      </div>
    </div>
  </section>

  <!-- ══════════════════════════════════════════
       KATEGORIEN SAMSTAG
  ══════════════════════════════════════════ -->
  <section class="fgt-section fgt-section--gray">
    <div class="fgt-inner">
      <div class="fgt-section__header">
        <h2>Kategorien Samstag, 20. Juni</h2>
      </div>

      <div class="fgt-cat-grid">

        <div class="fgt-cat-card">
          <div class="fgt-cat-card__top">
            <div class="fgt-cat-card__label">Nachwuchs</div>
            <div class="fgt-cat-card__name">Piccolo (P)</div>
            <div class="fgt-cat-card__birth">Jahrgang 2016 und jünger</div>
          </div>
          <div class="fgt-cat-card__bottom">
            <a href="<?php echo esc_url( $up . 'Piccolo_20.06.2026.pdf' ); ?>"
               class="fgt-cat-card__pdf" target="_blank" rel="noopener">
              <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M12 15V3m0 12-4-4m4 4 4-4M3 17v2a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-2"/></svg>
              Spielplan herunterladen
            </a>
          </div>
        </div>

        <div class="fgt-cat-card">
          <div class="fgt-cat-card__top">
            <div class="fgt-cat-card__label">Nachwuchs</div>
            <div class="fgt-cat-card__name">Knaben 2 (S2)</div>
            <div class="fgt-cat-card__birth">Jahrgang 2013 und jünger</div>
          </div>
          <div class="fgt-cat-card__bottom">
            <a href="<?php echo esc_url( $up . 'Spielplan_Knaben2.pdf' ); ?>"
               class="fgt-cat-card__pdf" target="_blank" rel="noopener">
              <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M12 15V3m0 12-4-4m4 4 4-4M3 17v2a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-2"/></svg>
              Spielplan herunterladen
            </a>
          </div>
        </div>

        <div class="fgt-cat-card">
          <div class="fgt-cat-card__top">
            <div class="fgt-cat-card__label">Nachwuchs</div>
            <div class="fgt-cat-card__name">Knaben 1 (S1)</div>
            <div class="fgt-cat-card__birth">Jahrgang 2010 und jünger</div>
          </div>
          <div class="fgt-cat-card__bottom">
            <a href="<?php echo esc_url( $up . 'Spielplan_Knaben1.pdf' ); ?>"
               class="fgt-cat-card__pdf" target="_blank" rel="noopener">
              <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M12 15V3m0 12-4-4m4 4 4-4M3 17v2a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-2"/></svg>
              Spielplan herunterladen
            </a>
          </div>
        </div>

        <div class="fgt-cat-card">
          <div class="fgt-cat-card__top">
            <div class="fgt-cat-card__label">Aktivkategorie</div>
            <div class="fgt-cat-card__name">Herren</div>
            <div class="fgt-cat-card__birth">Offen für alle Herrenteams</div>
          </div>
          <div class="fgt-cat-card__bottom">
            <a href="<?php echo esc_url( $up . 'Spielplan_Herren.pdf' ); ?>"
               class="fgt-cat-card__pdf" target="_blank" rel="noopener">
              <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M12 15V3m0 12-4-4m4 4 4-4M3 17v2a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-2"/></svg>
              Spielplan herunterladen
            </a>
          </div>
        </div>

        <div class="fgt-cat-card">
          <div class="fgt-cat-card__top">
            <div class="fgt-cat-card__label">Nachwuchs</div>
            <div class="fgt-cat-card__name">Mädchen</div>
            <div class="fgt-cat-card__birth">Nachwuchs Mädchenkategorie</div>
          </div>
          <div class="fgt-cat-card__bottom">
            <a href="<?php echo esc_url( $up . 'Maedchen_20.06.2026.pdf' ); ?>"
               class="fgt-cat-card__pdf" target="_blank" rel="noopener">
              <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M12 15V3m0 12-4-4m4 4 4-4M3 17v2a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-2"/></svg>
              Spielplan herunterladen
            </a>
          </div>
        </div>

        <div class="fgt-cat-card">
          <div class="fgt-cat-card__top">
            <div class="fgt-cat-card__label">Aktivkategorie</div>
            <div class="fgt-cat-card__name">Mixed</div>
            <div class="fgt-cat-card__birth">Mind. 2 Frauen pro Team auf dem Feld</div>
          </div>
          <div class="fgt-cat-card__bottom">
            <a href="<?php echo esc_url( $up . 'Mixed_20.06.2026.pdf' ); ?>"
               class="fgt-cat-card__pdf" target="_blank" rel="noopener">
              <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M12 15V3m0 12-4-4m4 4 4-4M3 17v2a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-2"/></svg>
              Spielplan herunterladen
            </a>
          </div>
        </div>

      </div>

      <!-- Reglement -->
      <div style="margin-top:2rem;padding:1.5rem 2rem;background:#fff;border-radius:14px;box-shadow:0 2px 12px rgba(0,0,0,.07);display:flex;align-items:center;justify-content:space-between;gap:1.5rem;flex-wrap:wrap;">
        <div>
          <div style="font-size:.6875rem;font-weight:800;text-transform:uppercase;letter-spacing:.14em;color:#E30613;margin-bottom:.3rem;">Regelwerk</div>
          <div style="font-size:1.0625rem;font-weight:800;color:#111;">Reglement Grümpelturnier 2026</div>
          <div style="font-size:.875rem;color:#6b7280;margin-top:.2rem;">Alle Spielregeln, Kategorien und Turnierbedingungen</div>
        </div>
        <a href="<?php echo esc_url( $up . 'Reglement_Gruempi_2026.pdf' ); ?>"
           style="display:inline-flex;align-items:center;gap:.625rem;background:#E30613;color:#fff;text-decoration:none;font-size:.875rem;font-weight:800;text-transform:uppercase;letter-spacing:.08em;padding:.875rem 1.75rem;border-radius:8px;white-space:nowrap;flex-shrink:0;"
           target="_blank" rel="noopener">
          <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M12 15V3m0 12-4-4m4 4 4-4M3 17v2a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-2"/></svg>
          Reglement herunterladen
        </a>
      </div>

    </div>
  </section>

  <!-- ══════════════════════════════════════════
       RAHMENPROGRAMM
  ══════════════════════════════════════════ -->
  <section class="fgt-section fgt-section--white">
    <div class="fgt-inner">
      <div class="fgt-section__header">
        <h2>Rahmenprogramm</h2>
      </div>

      <div class="fgt-highlights">

        <div class="fgt-highlight">
          <span class="fgt-highlight__icon">📺</span>
          <div class="fgt-highlight__title">Public Viewing FIFA WM 2026</div>
          <div class="fgt-highlight__text">Passend zum Turnier läuft die FIFA Weltmeisterschaft 2026. Ausgewählte Spiele werden live auf der Anlage gezeigt.</div>
        </div>

        <div class="fgt-highlight">
          <span class="fgt-highlight__icon">🍖</span>
          <div class="fgt-highlight__title">Grillstand</div>
          <div class="fgt-highlight__text">Frisch vom Grill – an beiden Tagen sorgt unser Grillstand für die kulinarische Verpflegung der Spieler und Zuschauer.</div>
        </div>

        <div class="fgt-highlight">
          <span class="fgt-highlight__icon">🎧</span>
          <div class="fgt-highlight__title">DJ Freitag &amp; Samstag</div>
          <div class="fgt-highlight__text">Nach den Spielen geht die Party weiter – mit DJ-Musik und Partyzeltatmosphäre an beiden Abenden.</div>
        </div>

        <div class="fgt-highlight">
          <span class="fgt-highlight__icon">⛺</span>
          <div class="fgt-highlight__title">Partyzelt</div>
          <div class="fgt-highlight__text">Das grosse Partyzelt auf der Anlage bietet Platz für alle – Spieler, Fans und Begleitung geniessen gemeinsam das Turnierflair.</div>
        </div>

      </div>
    </div>
  </section>

  <!-- ══════════════════════════════════════════
       SPONSOREN
  ══════════════════════════════════════════ -->
  <section class="fgt-section fgt-section--gray">
    <div class="fgt-inner">
      <div class="fgt-section__header">
        <h2>Unsere Sponsoren</h2>
        <div class="fgt-section__sub">Herzlichen Dank an alle Partner, die das Grümpelturnier 2026 möglich machen.</div>
      </div>

      <!-- Hauptsponsor -->
      <div class="fgt-sponsor-group">
        <div class="fgt-sponsor-group__label">Hauptsponsor</div>
        <div class="fgt-sponsor-grid fgt-sponsor-grid--main">
          <div class="fgt-sponsor-box">
            <div class="fgt-sponsor-box__logo">
              <img src="<?php echo esc_url( $up . 'SwissLight.png' ); ?>" alt="SwissLight">
            </div>
            <a href="https://swiss-light.ch/" class="fgt-sponsor-box__name" target="_blank" rel="noopener">SwissLight</a>
          </div>
        </div>
      </div>

      <!-- Eventsponsor -->
      <div class="fgt-sponsor-group">
        <div class="fgt-sponsor-group__label">Eventsponsor</div>
        <div class="fgt-sponsor-grid fgt-sponsor-grid--main">
          <div class="fgt-sponsor-box">
            <div class="fgt-sponsor-box__logo">
              <img src="<?php echo esc_url( $up . 'Bikewelt.png' ); ?>" alt="Bikewelt Gisler">
            </div>
            <a href="https://www.bikeweltgisler.ch/" class="fgt-sponsor-box__name" target="_blank" rel="noopener">Bikewelt Gisler</a>
          </div>
          <div class="fgt-sponsor-box">
            <div class="fgt-sponsor-box__logo">
              <img src="<?php echo esc_url( $up . 'Kuster.png' ); ?>" alt="Druckerei Kuster">
            </div>
            <a href="https://druckerei-kuster.ch/" class="fgt-sponsor-box__name" target="_blank" rel="noopener">Druckerei Kuster</a>
          </div>
        </div>
      </div>

      <!-- Weitere Sponsoren -->
      <div class="fgt-sponsor-group">
        <div class="fgt-sponsor-group__label">Weitere Sponsoren</div>
        <div class="fgt-sponsor-grid">
          <div class="fgt-sponsor-box">
            <div class="fgt-sponsor-box__logo">
              <img src="<?php echo esc_url( $up . 'Sponsor_Anker.jpeg' ); ?>" alt="Der Anker">
            </div>
            <a href="https://deranker.ch" class="fgt-sponsor-box__name" target="_blank" rel="noopener">Der Anker</a>
          </div>
          <div class="fgt-sponsor-box">
            <div class="fgt-sponsor-box__logo">
              <img src="<?php echo esc_url( $up . 'Sponsor_Baldini.jpg' ); ?>" alt="Baldini">
            </div>
            <a href="https://www.baldini.ch/" class="fgt-sponsor-box__name" target="_blank" rel="noopener">Baldini</a>
          </div>
          <div class="fgt-sponsor-box">
            <div class="fgt-sponsor-box__logo">
              <img src="<?php echo esc_url( $up . 'Sponsor_Bluema.jpg' ); ?>" alt="Blüma-Cordelia Meier">
            </div>
            <a href="https://blumen-c-meier.ch/" class="fgt-sponsor-box__name" target="_blank" rel="noopener">Blüma-Cordelia Meier</a>
          </div>
          <div class="fgt-sponsor-box">
            <div class="fgt-sponsor-box__logo">
              <img src="<?php echo esc_url( $up . 'Sponsor_Daetwyler.jpg' ); ?>" alt="Dätwyler Stiftung">
            </div>
            <a href="https://www.daetwyler-stiftung.ch/" class="fgt-sponsor-box__name" target="_blank" rel="noopener">Dätwyler Stiftung</a>
          </div>
          <div class="fgt-sponsor-box">
            <div class="fgt-sponsor-box__logo">
              <img src="<?php echo esc_url( $up . 'Sponsor_Gelateria.png' ); ?>" alt="Gelateria Artigiana">
            </div>
            <a href="https://gelateria-artigiana.ch/" class="fgt-sponsor-box__name" target="_blank" rel="noopener">Gelateria Artigiana</a>
          </div>
          <div class="fgt-sponsor-box">
            <div class="fgt-sponsor-box__logo">
              <img src="<?php echo esc_url( $up . 'Sponsor_Tresch.png' ); ?>" alt="Sandro Tresch Fotografie">
            </div>
            <a href="https://sandrotresch.com/" class="fgt-sponsor-box__name" target="_blank" rel="noopener">Sandro Tresch Fotografie</a>
          </div>
          <div class="fgt-sponsor-box">
            <div class="fgt-sponsor-box__logo">
              <img src="<?php echo esc_url( $up . 'Sponsor_Snowlife.png' ); ?>" alt="Snowlife">
            </div>
            <a href="https://snowlife.ch/" class="fgt-sponsor-box__name" target="_blank" rel="noopener">Snowlife</a>
          </div>
          <div class="fgt-sponsor-box">
            <div class="fgt-sponsor-box__logo">
              <img src="<?php echo esc_url( $up . 'Sponsor_Schuler.png' ); ?>" alt="Schuler Weine">
            </div>
            <a href="https://www.schuler.ch/" class="fgt-sponsor-box__name" target="_blank" rel="noopener">Schuler Weine</a>
          </div>
          <div class="fgt-sponsor-box">
            <div class="fgt-sponsor-box__logo">
              <img src="<?php echo esc_url( $up . 'Sponsor_TCS.jpg' ); ?>" alt="TCS Uri">
            </div>
            <a href="https://www.tcs.ch/de/der-tcs/sektionen/uri/" class="fgt-sponsor-box__name" target="_blank" rel="noopener">TCS Uri</a>
          </div>
        </div>
      </div>

    </div>
  </section>

  <!-- ══════════════════════════════════════════
       ANMELDUNG CTA
  ══════════════════════════════════════════ -->
  <div class="fgt-cta">
    <div class="fgt-cta__label">Anmeldung</div>
    <h2>Dabei sein beim<br>Grümpelturnier 2026</h2>
    <p class="fgt-cta__deadline">Anmeldeschluss: <strong>7. Juni 2026</strong></p>
    <a href="<?php echo esc_url( home_url( '/anmeldung-gruempelturnier' ) ); ?>"
       class="fgt-cta__btn">
      Jetzt anmelden
      <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24"><path d="M5 12h14M12 5l7 7-7 7"/></svg>
    </a>
  </div>

</div>

<?php get_footer(); ?>
