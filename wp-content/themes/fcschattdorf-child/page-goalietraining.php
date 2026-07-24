<?php
/**
 * Template Name: Goalietraining
 * Template Post Type: page
 *
 * Trainingszeiten und Trainer werden über die Feld-Box «Seiteninhalte»
 * gepflegt (inc/fcs-fields-design2.php); das Layout kommt aus der Vorlage.
 */
defined( 'ABSPATH' ) || exit;

add_action( 'wp_enqueue_scripts', function () {
    $dir = get_stylesheet_directory();
    $uri = get_stylesheet_directory_uri();
    wp_enqueue_style( 'fcs-junioren-info', $uri . '/assets/fcs-junioren-info.css', [], filemtime( $dir . '/assets/fcs-junioren-info.css' ) );
}, 5 );

$up = wp_upload_dir()['baseurl'] . '/2026/06/';

get_header();

$zeiten = fcs_pf_lines( 'gt_zeiten', array(
	'Junioren D & E | Montag · 17:45 – 19:00 Uhr | Hauptplatz Grüner Wald (bei Schönwetter)',
	'Junioren A, B & C | Montag · 19:00 – 20:00 Uhr | Hauptplatz Grüner Wald (bei Schönwetter)',
) );
$trainer = fcs_pf_lines( 'gt_trainer', array(
	'Luca Aschwanden | Betreuer Goalietraining Kifu | Silhouette_Male_v2.jpg',
	'Gian Gisler | Betreuer Goalietraining Kifu | GianGisler.jpg',
	'Raphael Imhof | Torhütertrainer 11er Fussball | Raphael_Imhof.jpg',
) );
?>

<div class="fcji-page">

  <div class="fcji-hero">
    <img src="<?php echo esc_url( $up . 'goalie_training.jpg' ); ?>" alt="Goalietraining FC Schattdorf">
    <div class="fcji-hero__overlay">
      <h1 class="fcji-hero__title">Goalietraining</h1>
    </div>
  </div>

  <!-- ── Trainingszeiten ── -->
  <section class="fcji-section fcji-section--white">
    <div class="fcji-inner">
      <div class="fcji-section__header">
        <h2>Trainingszeiten & Ort</h2>
      </div>
      <div class="fcji-info-grid">
        <?php foreach ( $zeiten as $zeile ) :
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
    </div>
  </section>

  <!-- ── Goalietrainer ── -->
  <section class="fcji-section fcji-section--gray">
    <div class="fcji-inner">
      <div class="fcji-section__header">
        <h2>Goalietrainer</h2>
      </div>
      <div class="fcji-person-grid">
        <?php foreach ( $trainer as $zeile ) :
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
