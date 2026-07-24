<?php
/**
 * Template Name: Betreuer werden
 * Template Post Type: page
 *
 * Flyer-Aufruf, Ausbildungsweg und Kontakt werden über die Feld-Box
 * «Seiteninhalte» gepflegt (inc/fcs-fields-design2.php);
 * das Layout kommt aus der Vorlage.
 */
defined( 'ABSPATH' ) || exit;

add_action( 'wp_enqueue_scripts', function () {
    $dir = get_stylesheet_directory();
    $uri = get_stylesheet_directory_uri();
    wp_enqueue_style( 'fcs-junioren-info', $uri . '/assets/fcs-junioren-info.css', [], filemtime( $dir . '/assets/fcs-junioren-info.css' ) );
}, 5 );

$up = wp_upload_dir()['baseurl'] . '/2026/06/';

get_header();

$flyer_badge = fcs_pf( 'bw_flyer_badge', 'Trainer gesucht!' );
$flyer_text  = fcs_pf( 'bw_flyer_text', 'Du bist engagiert, liebst Fussball und willst etwas zurückgeben? Der FC Schattdorf sucht laufend motivierte Betreuerinnen und Betreuer für unsere Juniorenteams. Wir unterstützen dich vollumfänglich auf dem Weg zur Trainer-Lizenz.' );
$flyer_bild  = fcsh_bild_url( fcs_pf( 'bw_flyer_bild', 'Flyer_Trainersuche.jpg' ), $up );
$schritte    = fcs_pf_lines( 'bw_schritte', array(
	'Einsteigerkurs | Ab 16 Jahre, 4 Stunden, Kosten übernimmt FC Schattdorf | Obligatorisch für die Teilnahme am C-Basic Diplom. Kein Praxisteil – reine Theorie. Anmeldung erfolgt durch den J+S Coach des Vereins.',
	'C-Basic Diplom / J+S Leiterkurs Jugendsport | Ab 18 Jahre, 6-tägiger Blockkurs, EO-Entschädigung, Kosten übernimmt FC Schattdorf | Berechtigt zum Trainieren von Junioren A/B/C/D und 3.–5. Liga Aktive, sowie 1./2. Liga Frauen. Schriftliche Theorieprüfung. Alle 2 Jahre Weiterbildungspflicht.',
	'D-Diplom / J+S Leiterkurs Kindersport | Ab 18 Jahre, 6 Tage / mehrere Module, EO-Entschädigung, Kosten übernimmt FC Schattdorf | Für Trainer von E-, F- und G-Junioren (Kinderfussball). Theorie- und Methodik-Prüfung. Alle 2 Jahre ein Fortbildungsmodul.',
	'UEFA C-Diplom / J+S Weiterbildung 1 | Voraussetzung: C-Basic Diplom, 2 × 3 Tage, EO-Entschädigung | Weiterführende Lizenz für ambitionierte Trainer. Berechtigt zum Leiten höherer Spielkategorien.',
	'UEFA B-Diplom / J+S Weiterbildung 2 | Voraussetzung: UEFA C-Diplom, Mehrere Module | Höchste Lizenzstufe im Amateurfussball. Für die Leitung von 1./2. Liga-Mannschaften und höheren Juniorenkategorien.',
) );
$k_rolle = fcs_pf( 'bw_kontakt_rolle', 'Ansprechperson & J+S Coach' );
$k_name  = fcs_pf( 'bw_kontakt_name', 'Karl Arnold' );
$k_tel   = fcs_pf( 'bw_kontakt_tel', '079 159 82 38' );
$k_mail  = fcs_pf( 'bw_kontakt_mail', 'tschuedi.kari@gmail.com' );
$k_note  = fcs_pf( 'bw_kontakt_note', 'Anmeldung für alle Kurse erfolgt durch den J+S Coach. Kurskosten werden vollumfänglich vom FC Schattdorf übernommen.' );
?>

<div class="fcji-page">

  <div class="fcji-page-title">
    <h1>Betreuer werden</h1>
  </div>

  <!-- ── Flyer / CTA ── -->
  <section class="fcji-section fcji-section--gray">
    <div class="fcji-inner">
      <div class="fcji-flyer-row">
        <div class="fcji-flyer-img">
          <img src="<?php echo esc_url( $flyer_bild ); ?>" alt="Trainer gesucht – FC Schattdorf">
        </div>
        <div class="fcji-flyer-text">
          <div class="fcji-flyer-badge"><?php echo esc_html( $flyer_badge ); ?></div>
          <p><?php echo esc_html( $flyer_text ); ?></p>
        </div>
      </div>
    </div>
  </section>

  <!-- ── Diploma path ── -->
  <section class="fcji-section fcji-section--white">
    <div class="fcji-inner">

      <div class="fcji-section__header">
        <h2>Ausbildungsweg zum Fussballtrainer</h2>
      </div>

      <div class="fcji-path">

        <?php foreach ( $schritte as $i => $zeile ) :
            $teile = array_map( 'trim', explode( '|', $zeile ) );
            if ( count( $teile ) < 2 ) { continue; }
            $titel = $teile[0];
            $tags  = array_values( array_filter( array_map( 'trim', explode( ',', $teile[1] ) ) ) );
            $desc  = $teile[2] ?? '';
            ?>
        <div class="fcji-step">
          <div class="fcji-step__num"><?php echo (int) $i + 1; ?></div>
          <div class="fcji-step__body">
            <div class="fcji-step__title"><?php echo esc_html( $titel ); ?></div>
            <div class="fcji-step__meta">
              <?php foreach ( $tags as $tag ) : ?>
              <span class="fcji-step__tag"><?php echo esc_html( $tag ); ?></span>
              <?php endforeach; ?>
            </div>
            <?php if ( '' !== $desc ) : ?>
            <div class="fcji-step__desc"><?php echo esc_html( $desc ); ?></div>
            <?php endif; ?>
          </div>
        </div>
        <?php endforeach; ?>

      </div>

    </div>
  </section>

  <!-- ── Contact ── -->
  <section class="fcji-section fcji-section--gray">
    <div class="fcji-inner">
      <div class="fcji-contact-clean">
        <div class="fcji-contact-clean__divider"></div>
        <div class="fcji-contact-clean__inner">
          <div class="fcji-contact-clean__label"><?php echo esc_html( $k_rolle ); ?></div>
          <div class="fcji-contact-clean__name"><?php echo esc_html( $k_name ); ?></div>
          <div class="fcji-contact-clean__links">
            <a href="<?php echo esc_attr( fcsh_tel_href( $k_tel ) ); ?>" class="fcji-contact-clean__link">
              <svg width="15" height="15" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07A19.5 19.5 0 0 1 4.69 12a19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 3.6 1.27h3a2 2 0 0 1 2 1.72c.127.96.361 1.903.7 2.81a2 2 0 0 1-.45 2.11L7.91 8.91a16 16 0 0 0 6 6l.91-.91a2 2 0 0 1 2.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0 1 21.73 16.92z"/></svg>
              <?php echo esc_html( $k_tel ); ?>
            </a>
            <a href="mailto:<?php echo esc_attr( $k_mail ); ?>" class="fcji-contact-clean__link">
              <svg width="15" height="15" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
              <?php echo esc_html( $k_mail ); ?>
            </a>
          </div>
          <p class="fcji-contact-clean__note"><?php echo esc_html( $k_note ); ?></p>
        </div>
      </div>
    </div>
  </section>

</div>

<?php get_footer(); ?>
