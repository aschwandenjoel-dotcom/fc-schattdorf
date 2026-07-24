<?php
/**
 * Template Name: Juniorenkonzept
 * Template Post Type: page
 *
 * Texte/PDF-Link werden über die Feld-Box «Seiteninhalte» gepflegt
 * (inc/fcs-page-fields.php); das Layout kommt aus der Vorlage.
 */
defined( 'ABSPATH' ) || exit;

add_action( 'wp_enqueue_scripts', function () {
    $dir = get_stylesheet_directory();
    $uri = get_stylesheet_directory_uri();
    wp_enqueue_style( 'fcs-junioren-info', $uri . '/assets/fcs-junioren-info.css', [], filemtime( $dir . '/assets/fcs-junioren-info.css' ) );
}, 5 );

$up = wp_upload_dir()['baseurl'] . '/2026/06/';

get_header();

$jk_titel = fcs_pf( 'jk_titel', 'Juniorenkonzept FC Schattdorf' );
$jk_text  = fcs_pf( 'jk_text', 'Das Juniorenkonzept des FC Schattdorf beschreibt unsere Philosophie, Ziele und den Ausbildungsweg für unsere Nachwuchsspielerinnen und -spieler. Es bildet die Grundlage für die Arbeit aller Betreuer im Verein.' );
$jk_pdf   = fcs_pf( 'jk_pdf', $up . 'Juniorenkonzept.pdf' );
?>

<div class="fcji-page">

  <div class="fcji-page-title">
    <h1><?php the_title(); ?></h1>
  </div>

  <section class="fcji-section fcji-section--white">
    <div class="fcji-inner">
      <div class="fcji-pdf-block">
        <div class="fcji-pdf-block__icon">
          <svg width="36" height="36" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" viewBox="0 0 24 24">
            <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/>
            <line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/>
          </svg>
        </div>
        <h2><?php echo esc_html( $jk_titel ); ?></h2>
        <p><?php echo esc_html( $jk_text ); ?></p>
        <a href="<?php echo esc_url( $jk_pdf ); ?>" class="fcji-pdf-btn" target="_blank" rel="noopener noreferrer">
          <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M12 15V3m0 12-4-4m4 4 4-4M3 17v2a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-2"/></svg>
          Juniorenkonzept als PDF herunterladen
        </a>
      </div>
    </div>
  </section>

</div>

<?php get_footer(); ?>
