<?php
/**
 * Template Name: Fussballschule
 * Template Post Type: page
 *
 * Texte, Info-Karten, Flyer und Leitungsteam werden über die Feld-Box
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

$intro     = fcs_pf( 'fs_intro', 'Jeweils **montags von 17:45 bis 19:00 Uhr** trainiert die Fussballschule für Kinder mit Jahrgang 2020 und 2021 auf dem **Hauptplatz «Grüner Wald»** in Schattdorf. Mitnehmen, wenn vorhanden: Fussballschuhe, Schoner, Fussball (Grösse 4), Getränke und wettertaugliche Kleider. **Die Trainings finden bei jeder Witterung statt.** Fragen beantwortet Jacqueline Kempf-Imholz, 078 795 29 67.' );
$karten    = fcs_pf_lines( 'fs_karten', array(
	'Wann | Montag · 17:45 – 19:00 Uhr | 17.8. / 24.8. / 31.8. / 7.9. / 14.9. / 21.9. / 28.9. / 12.10. / 19.10. (Abschlussturnier)',
	'Für wen | Jahrgang 2020 & 2021 | Kinder im Vorschul- und Schulalter',
	'Ort | Hauptplatz «Grüner Wald» | Schattdorf',
	'Kosten | CHF 2.– pro Training | Versicherung ist Sache der Teilnehmer',
) );
$pdf       = fcs_pf( 'fs_pdf', $up . 'Flyer_Fussballschule.pdf' );
$pdf_label = fcs_pf( 'fs_pdf_label', 'Flyer Fussballschule (PDF)' );
$team      = fcs_pf_lines( 'fs_team', array(
	'Jacqueline Kempf-Imholz | Leiterin Fussballschule | Jacqueline_Kempf.jpg',
	'Rachel Arnold | Betreuerin Fussballschule | rachel_ajpg.jpg',
	'Nicola Mahrow | Betreuer Fussballschule | Nici_Mahrow_2.jpg',
	'Orlando Gisler | Betreuer Fussballschule | Orlando_Gisler.jpg',
	'Robin Mahrow | Betreuer Fussballschule | Rubi_Mahrow.jpg',
	'Nico Zgraggen | Betreuer Fussballschule | Nico_Zgraggen.jpg',
	'Janic Gisler | Betreuer Fussballschule | Silhouette_Male_v2.jpg',
	'Fabio Tresch | Betreuer Fussballschule | Silhouette_Male_v2.jpg',
) );
?>

<div class="fcji-page">

  <div class="fcji-hero">
    <img src="<?php echo esc_url( $up . 'fussballschule_photo.jpg' ); ?>" alt="Fussballschule FC Schattdorf">
    <div class="fcji-hero__overlay">
      <h1 class="fcji-hero__title">Fussballschule</h1>
    </div>
  </div>

  <!-- ── Info ── -->
  <section class="fcji-section fcji-section--white">
    <div class="fcji-inner">
      <p class="fcji-intro"><?php
        /* **Text** aus dem Feld wird fett ausgegeben */
        echo preg_replace( '/\*\*(.+?)\*\*/s', '<strong>$1</strong>', esc_html( $intro ) );
      ?></p>
      <div class="fcji-info-grid">
        <?php foreach ( $karten as $zeile ) :
            $teile = array_map( 'trim', explode( '|', $zeile ) );
            if ( count( $teile ) < 2 ) { continue; }
            ?>
        <div class="fcji-info-card">
          <div class="fcji-info-card__label"><?php echo esc_html( $teile[0] ); ?></div>
          <div class="fcji-info-card__title"><?php echo esc_html( $teile[1] ); ?></div>
          <?php if ( '' !== ( $teile[2] ?? '' ) ) : ?>
          <div class="fcji-info-card__detail"><?php echo esc_html( $teile[2] ); ?></div>
          <?php endif; ?>
        </div>
        <?php endforeach; ?>
      </div>
      <a href="<?php echo esc_url( $pdf ); ?>" class="fcji-pdf-btn" target="_blank" rel="noopener">
        <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M12 15V3m0 12-4-4m4 4 4-4M3 17v2a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-2"/></svg>
        <?php echo esc_html( $pdf_label ); ?>
      </a>
    </div>
  </section>

  <!-- ── Leitungsteam ── -->
  <section class="fcji-section fcji-section--gray">
    <div class="fcji-inner">
      <div class="fcji-section__header">
        <h2>Leitungsteam</h2>
      </div>
      <div class="fcji-person-grid">
        <?php foreach ( $team as $zeile ) :
            $teile = array_map( 'trim', explode( '|', $zeile ) );
            if ( count( $teile ) < 2 ) { continue; }
            list( $name, $rolle ) = $teile;
            $bild = fcsh_bild_url( $teile[2] ?? '', $up );
            ?>
        <div class="fcji-card">
          <div class="fcji-card__photo">
            <img src="<?php echo esc_url( $bild ); ?>" alt="<?php echo esc_attr( $name ); ?>">
          </div>
          <div class="fcji-card__info">
            <div class="fcji-card__name"><?php echo esc_html( $name ); ?></div>
            <div class="fcji-card__role"><?php echo esc_html( $rolle ); ?></div>
          </div>
        </div>
        <?php endforeach; ?>
      </div>
    </div>
  </section>

</div>

<?php get_footer(); ?>
