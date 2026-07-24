<?php
/**
 * Template Name: Grümpelturnier
 * Template Post Type: page
 *
 * Daten, Programm, Kategorien, Sponsoren und Anmeldung werden über die
 * Feld-Box «Seiteninhalte» gepflegt (inc/fcs-fields-design1.php); das
 * Layout kommt aus der Vorlage.
 */
defined( 'ABSPATH' ) || exit;

add_action( 'wp_enqueue_scripts', function () {
    $dir = get_stylesheet_directory();
    $uri = get_stylesheet_directory_uri();
    wp_enqueue_style( 'fcs-gruempelturnier', $uri . '/assets/fcs-gruempelturnier.css', [], filemtime( $dir . '/assets/fcs-gruempelturnier.css' ) );
}, 5 );

$up = wp_upload_dir()['baseurl'] . '/2026/06/';

get_header();

$kopfzeile   = fcs_pf( 'gt_kopfzeile', '33. Dorfturnier · 66. Grümpelturnier' );
$titel       = fcs_pf( 'gt_titel', 'Dorf- & Grümpelturnier 2026' );
$datum_ort   = fcs_pf( 'gt_datum_ort', '19. & 20. Juni 2026 · Sportplatz Grüner Wald, Schattdorf' );
$programm    = fcs_pf_lines( 'gt_programm', array(
	'Donnerstag | 18. Juni | Intern | FCS Intern | Vereinsinternes Turnier | Das Turnierwochenende startet mit einem internen Fussballturnier für Mitglieder und Angehörige des FC Schattdorf.',
	'Freitag | 19. Juni | Dorfturnier | Dorfturnier | 33. Dorfturnier – Vereine & Firmen | Am Freitag treten lokale Vereine, Firmen und Betriebe gegeneinander an. Ein geselliger Wettbewerb mit Grillstand und DJ-Abend.',
	'Samstag | 20. Juni | Grümpelturnier | Grümpelturnier | 66. Grümpelturnier – 6 Kategorien | Der grosse Turniertag mit allen Nachwuchs- und Aktivkategorien: Piccolo, Knaben 2, Knaben 1, Mädchen, Herren und Mixed. Parallel dazu: Public Viewing der FIFA WM 2026.',
) );
$kat_titel   = fcs_pf( 'gt_kategorien_titel', 'Kategorien Samstag, 20. Juni' );
$kategorien  = fcs_pf_lines( 'gt_kategorien', array(
	'Nachwuchs | Piccolo (P) | Jahrgang 2016 und jünger | ' . $up . 'Piccolo_20.06.2026.pdf',
	'Nachwuchs | Knaben 2 (S2) | Jahrgang 2013 und jünger | ' . $up . 'Spielplan_Knaben2.pdf',
	'Nachwuchs | Knaben 1 (S1) | Jahrgang 2010 und jünger | ' . $up . 'Spielplan_Knaben1.pdf',
	'Aktivkategorie | Herren | Offen für alle Herrenteams | ' . $up . 'Spielplan_Herren.pdf',
	'Nachwuchs | Mädchen | Nachwuchs Mädchenkategorie | ' . $up . 'Maedchen_20.06.2026.pdf',
	'Aktivkategorie | Mixed | Mind. 2 Frauen pro Team auf dem Feld | ' . $up . 'Mixed_20.06.2026.pdf',
) );
$reg_titel   = fcs_pf( 'gt_reglement_titel', 'Reglement Grümpelturnier 2026' );
$reg_pdf     = fcs_pf( 'gt_reglement_pdf', $up . 'Reglement_Gruempi_2026.pdf' );
$rahmen      = fcs_pf_lines( 'gt_rahmenprogramm', array(
	'Public Viewing FIFA WM 2026 | Passend zum Turnier läuft die FIFA Weltmeisterschaft 2026. Ausgewählte Spiele werden live auf der Anlage gezeigt.',
	'Grillstand | Frisch vom Grill – an beiden Tagen sorgt unser Grillstand für die kulinarische Verpflegung der Spieler und Zuschauer.',
	'DJ Freitag & Samstag | Nach den Spielen geht die Party weiter – mit DJ-Musik und Partyzeltatmosphäre an beiden Abenden.',
	'Partyzelt | Das grosse Partyzelt auf der Anlage bietet Platz für alle – Spieler, Fans und Begleitung geniessen gemeinsam das Turnierflair.',
) );
$dank        = fcs_pf( 'gt_sponsoren_dank', 'Herzlichen Dank an alle Partner, die das Grümpelturnier 2026 möglich machen.' );
$sp_haupt    = fcs_pf_lines( 'gt_sponsor_haupt', array(
	'SwissLight | ' . $up . 'SwissLight.png | https://swiss-light.ch/',
) );
$sp_event    = fcs_pf_lines( 'gt_sponsor_event', array(
	'Bikewelt Gisler | ' . $up . 'Bikewelt.png | https://www.bikeweltgisler.ch/',
	'Druckerei Kuster | ' . $up . 'Kuster.png | https://druckerei-kuster.ch/',
) );
$sp_weitere  = fcs_pf_lines( 'gt_sponsor_weitere', array(
	'Der Anker | ' . $up . 'Sponsor_Anker.jpeg | https://deranker.ch',
	'Baldini | ' . $up . 'Sponsor_Baldini.jpg | https://www.baldini.ch/',
	'Blüma-Cordelia Meier | ' . $up . 'Sponsor_Bluema.jpg | https://blumen-c-meier.ch/',
	'Dätwyler Stiftung | ' . $up . 'Sponsor_Daetwyler.jpg | https://www.daetwyler-stiftung.ch/',
	'Gelateria Artigiana | ' . $up . 'Sponsor_Gelateria.png | https://gelateria-artigiana.ch/',
	'Sandro Tresch Fotografie | ' . $up . 'Sponsor_Tresch.png | https://sandrotresch.com/',
	'Snowlife | ' . $up . 'Sponsor_Snowlife.png | https://snowlife.ch/',
	'Schuler Weine | ' . $up . 'Sponsor_Schuler.png | https://www.schuler.ch/',
	'TCS Uri | ' . $up . 'Sponsor_TCS.jpg | https://www.tcs.ch/de/der-tcs/sektionen/uri/',
) );
$schluss     = fcs_pf( 'gt_anmeldeschluss', '7. Juni 2026' );
$anmelde_url = fcs_pf( 'gt_anmeldung_url', home_url( '/anmeldung-gruempelturnier' ) );
$cta_titel   = fcs_pf_lines( 'gt_cta_titel', array( 'Dabei sein beim', 'Grümpelturnier 2026' ) );

/* Icons des Rahmenprogramms bleiben Teil des Designs (Zuordnung nach Reihenfolge) */
$rahmen_icons = array( '📺', '🍖', '🎧', '⛺' );
?>

<div class="fgt-page">

  <!-- ══════════════════════════════════════════
       PAGE TITLE
  ══════════════════════════════════════════ -->
  <div style="background:#fff;border-bottom:1px solid #e5e7eb;padding:3rem 2.5rem 2.5rem;">
    <div style="max-width:1100px;margin:0 auto;">
      <div style="font-size:.6875rem;font-weight:800;text-transform:uppercase;letter-spacing:.18em;color:#E30613;margin-bottom:.75rem;display:flex;align-items:center;gap:.5rem;">
        <span style="display:inline-block;width:20px;height:2px;background:#E30613;"></span>
        <?php echo esc_html( $kopfzeile ); ?>
      </div>
      <h1 style="font-size:clamp(1.75rem,3.5vw,2.5rem);font-weight:900;color:#111;margin:0 0 .75rem;text-transform:uppercase;letter-spacing:-.01em;line-height:1.1;"><?php echo esc_html( $titel ); ?></h1>
      <div style="font-size:1rem;color:#6b7280;"><?php echo esc_html( $datum_ort ); ?></div>
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

        <?php foreach ( $programm as $i => $zeile ) :
            $teile = array_map( 'trim', explode( '|', $zeile ) );
            $grau  = ( 0 === $i ) ? ' fgt-program-day__badge--gray' : ''; ?>
        <div class="fgt-program-day">
          <div class="fgt-program-day__date">
            <div class="fgt-program-day__weekday"><?php echo esc_html( $teile[0] ); ?></div>
            <div class="fgt-program-day__dmy"><?php echo esc_html( $teile[1] ?? '' ); ?> <span><?php echo esc_html( $teile[2] ?? '' ); ?></span></div>
          </div>
          <div class="fgt-program-day__body">
            <div class="fgt-program-day__badge<?php echo $grau; ?>"><?php echo esc_html( $teile[3] ?? '' ); ?></div>
            <div class="fgt-program-day__title"><?php echo esc_html( $teile[4] ?? '' ); ?></div>
            <div class="fgt-program-day__desc"><?php echo esc_html( $teile[5] ?? '' ); ?></div>
          </div>
        </div>
        <?php endforeach; ?>

      </div>
    </div>
  </section>

  <!-- ══════════════════════════════════════════
       KATEGORIEN SAMSTAG
  ══════════════════════════════════════════ -->
  <section class="fgt-section fgt-section--gray">
    <div class="fgt-inner">
      <div class="fgt-section__header">
        <h2><?php echo esc_html( $kat_titel ); ?></h2>
      </div>

      <div class="fgt-cat-grid">

        <?php foreach ( $kategorien as $zeile ) :
            $teile = array_map( 'trim', explode( '|', $zeile ) ); ?>
        <div class="fgt-cat-card">
          <div class="fgt-cat-card__top">
            <div class="fgt-cat-card__label"><?php echo esc_html( $teile[0] ); ?></div>
            <div class="fgt-cat-card__name"><?php echo esc_html( $teile[1] ?? '' ); ?></div>
            <div class="fgt-cat-card__birth"><?php echo esc_html( $teile[2] ?? '' ); ?></div>
          </div>
          <div class="fgt-cat-card__bottom">
            <a href="<?php echo esc_url( $teile[3] ?? '' ); ?>"
               class="fgt-cat-card__pdf" target="_blank" rel="noopener">
              <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M12 15V3m0 12-4-4m4 4 4-4M3 17v2a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-2"/></svg>
              Spielplan herunterladen
            </a>
          </div>
        </div>
        <?php endforeach; ?>

      </div>

      <!-- Reglement -->
      <div style="margin-top:2rem;padding:1.5rem 2rem;background:#fff;border-radius:14px;box-shadow:0 2px 12px rgba(0,0,0,.07);display:flex;align-items:center;justify-content:space-between;gap:1.5rem;flex-wrap:wrap;">
        <div>
          <div style="font-size:.6875rem;font-weight:800;text-transform:uppercase;letter-spacing:.14em;color:#E30613;margin-bottom:.3rem;">Regelwerk</div>
          <div style="font-size:1.0625rem;font-weight:800;color:#111;"><?php echo esc_html( $reg_titel ); ?></div>
          <div style="font-size:.875rem;color:#6b7280;margin-top:.2rem;">Alle Spielregeln, Kategorien und Turnierbedingungen</div>
        </div>
        <a href="<?php echo esc_url( $reg_pdf ); ?>"
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

        <?php foreach ( $rahmen as $i => $zeile ) :
            $teile = array_map( 'trim', explode( '|', $zeile ) ); ?>
        <div class="fgt-highlight">
          <span class="fgt-highlight__icon"><?php echo $rahmen_icons[ $i % count( $rahmen_icons ) ]; ?></span>
          <div class="fgt-highlight__title"><?php echo esc_html( $teile[0] ); ?></div>
          <div class="fgt-highlight__text"><?php echo esc_html( $teile[1] ?? '' ); ?></div>
        </div>
        <?php endforeach; ?>

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
        <div class="fgt-section__sub"><?php echo esc_html( $dank ); ?></div>
      </div>

      <?php
      /* Drei Sponsoren-Gruppen: Bezeichnung, Zeilen (Name | Logo-URL | Website), Grid-Modifier */
      $gruppen = array(
          array( 'Hauptsponsor', $sp_haupt, ' fgt-sponsor-grid--main' ),
          array( 'Eventsponsor', $sp_event, ' fgt-sponsor-grid--main' ),
          array( 'Weitere Sponsoren', $sp_weitere, '' ),
      );
      foreach ( $gruppen as $gruppe ) : list( $g_label, $g_zeilen, $g_mod ) = $gruppe; ?>
      <div class="fgt-sponsor-group">
        <div class="fgt-sponsor-group__label"><?php echo esc_html( $g_label ); ?></div>
        <div class="fgt-sponsor-grid<?php echo $g_mod; ?>">
          <?php foreach ( $g_zeilen as $zeile ) :
              $teile = array_map( 'trim', explode( '|', $zeile ) ); ?>
          <div class="fgt-sponsor-box">
            <div class="fgt-sponsor-box__logo">
              <img src="<?php echo esc_url( $teile[1] ?? '' ); ?>" alt="<?php echo esc_attr( $teile[0] ); ?>">
            </div>
            <a href="<?php echo esc_url( $teile[2] ?? '' ); ?>" class="fgt-sponsor-box__name" target="_blank" rel="noopener"><?php echo esc_html( $teile[0] ); ?></a>
          </div>
          <?php endforeach; ?>
        </div>
      </div>
      <?php endforeach; ?>

    </div>
  </section>

  <!-- ══════════════════════════════════════════
       ANMELDUNG CTA
  ══════════════════════════════════════════ -->
  <div class="fgt-cta">
    <div class="fgt-cta__label">Anmeldung</div>
    <h2><?php echo implode( '<br>', array_map( 'esc_html', $cta_titel ) ); ?></h2>
    <p class="fgt-cta__deadline">Anmeldeschluss: <strong><?php echo esc_html( $schluss ); ?></strong></p>
    <a href="<?php echo esc_url( $anmelde_url ); ?>"
       class="fgt-cta__btn">
      Jetzt anmelden
      <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24"><path d="M5 12h14M12 5l7 7-7 7"/></svg>
    </a>
  </div>

</div>

<?php get_footer(); ?>
