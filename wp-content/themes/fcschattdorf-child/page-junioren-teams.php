<?php
/**
 * Template Name: Junioren Teams
 * Template Post Type: page
 *
 * Übersicht aller Juniorenteams im Design «Top-Club 88»
 * (assets/fcs-wine-info.css): Creme-Kopf auf Weinrot, Kachelraster.
 *
 * Die Kacheln entstehen automatisch aus den Unterseiten dieser Seite (Vorlage
 * «Junioren Team») — Reihenfolge = Seitenreihenfolge, Bild = deren Feld
 * «Teamfoto». Ein neues Team erscheint hier also, sobald seine Unterseite
 * angelegt ist; es muss hier nichts nachgeführt werden.
 *
 * Die Zeile unter dem Seitentitel wird über die Feld-Box «Seiteninhalte»
 * gepflegt (inc/fcs-page-fields.php).
 */
defined( 'ABSPATH' ) || exit;

add_action( 'wp_enqueue_scripts', function () {
    $dir = get_stylesheet_directory();
    $uri = get_stylesheet_directory_uri();
    wp_enqueue_style( 'fcs-wine-info', $uri . '/assets/fcs-wine-info.css', [], filemtime( $dir . '/assets/fcs-wine-info.css' ) );
}, 5 );

add_filter( 'body_class', function ( $c ) { $c[] = 'fcx-wine-page'; $c[] = 'fcx-info-page'; return $c; } );

$up = wp_upload_dir()['baseurl'] . '/2026/06/';

get_header();

$jl_label = fcs_pf( 'jl_label', 'FC Schattdorf · Junioren' );

/* Gruppenbild aller Junioren. Standard ist das mitgelieferte Theme-Bild
   (3000x2002, Originalauflösung von der alten Vereinsseite); das
   Seitenfeld «Gruppenbild» kann auf ein Bild aus der Mediathek zeigen.
   Es wird als fixierter Hintergrund gezeigt, ein Ersatzbild sollte
   deshalb ebenfalls gross sein (ab ~2500 px Breite). */
$jl_bild = fcsh_bild_url( fcs_pf( 'jl_bild', '' ), $up );
if ( '' === $jl_bild ) {
	$jl_bild = get_stylesheet_directory_uri() . '/assets/img/junioren-gruppenbild.jpg';
}

/* Teamkacheln = Unterseiten dieser Seite (Vorlage «Junioren Team»). */
$teams = get_posts( array(
	'post_type'      => 'page',
	'post_parent'    => get_the_ID(),
	'post_status'    => 'publish',
	'posts_per_page' => -1,
	'orderby'        => array( 'menu_order' => 'ASC', 'title' => 'ASC' ),
) );
?>

<div class="fctc-page">

  <!-- Seitenkopf und Gruppenbild bilden zusammen den Andock-Bereich:
       .fctc-dock ist der umschliessende Block, an dessen Unterkante der
       mitwandernde Kopf stehen bleibt (position: sticky). Der Container
       steht nur hier, die Wirkung gilt deshalb nur für diese Seite —
       .fctc-header nutzen auch andere Vorlagen. -->
  <div class="fctc-dock">

  <!-- Header -->
  <div class="fctc-header">
    <div class="fctc-header__inner">
      <h1><?php the_title(); ?></h1>
      <p class="fctc-header__label"><?php echo esc_html( $jl_label ); ?></p>
    </div>
  </div>

  <?php if ( $jl_bild ) : ?>
  <!-- Gruppenbild aller Junioren als feststehender Hintergrund: das Band
       ist ein Fenster auf ein im Viewport fixiertes Bild, beim Scrollen
       wandert also der Ausschnitt (wie das Parallax-Band der alten
       Vereinsseite). Deshalb Hintergrundbild statt <img> — mit role/
       aria-label, damit es für Screenreader ein Bild bleibt. -->
  <div class="fctc-hero" role="img" aria-label="Die Junioren des FC Schattdorf"
       style="background-image: url('<?php echo esc_url( $jl_bild ); ?>');"></div>
  <?php endif; ?>

  </div><!-- .fctc-dock -->

  <!-- Main -->
  <div class="fctc-main">

    <?php if ( ! empty( $teams ) ) : ?>
    <!-- Teamkacheln -->
    <h2 class="fctc-section-title">Team wählen</h2>
    <div class="fctc-teamgrid">
      <?php foreach ( $teams as $team ) :
          /* «Junioren Mannschaft Ed/Ee» -> Name «Ed/Ee», Kategorie «E-Junioren».
             Seiten ohne dieses Namensmuster (z. B. «Team Uri FF11») behalten
             ihren vollen Titel. */
          $titel = get_the_title( $team );
          $name  = trim( preg_replace( '/^Junioren\s+Mannschaft\s*/iu', '', $titel ) );
          $kat   = 'Junioren';
          if ( '' !== $name && $name !== $titel ) {
              $kat = mb_strtoupper( mb_substr( $name, 0, 1 ) ) . '-Junioren';
          } else {
              $name = $titel;
          }
          $bild = fcsh_bild_url( get_post_meta( $team->ID, 'fcs_jt_foto', true ), $up );
          ?>
      <a class="fctc-team" href="<?php echo esc_url( get_permalink( $team ) ); ?>">

        <?php if ( $bild ) : ?>
        <div class="fctc-team__photo">
          <img src="<?php echo esc_url( $bild ); ?>" alt="<?php echo esc_attr( $titel ); ?>" loading="lazy">
        </div>
        <?php else : ?>
        <div class="fctc-team__photo fctc-team__photo--placeholder">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
            <circle cx="12" cy="12" r="9"/>
            <path d="m12 7 4.5 3.3-1.7 5.3H9.2L7.5 10.3 12 7z"/>
            <path d="M12 3v4M4.2 9.5 7.5 10.3M19.8 9.5l-3.3.8M7.2 19.3l2-3.7M16.8 19.3l-2-3.7"/>
          </svg>
        </div>
        <?php endif; ?>

        <div class="fctc-team__info">
          <div class="fctc-team__cat"><?php echo esc_html( $kat ); ?></div>
          <div class="fctc-team__name"><?php echo esc_html( $name ); ?></div>
          <div class="fctc-team__more">
            Zum Team
            <svg width="12" height="12" viewBox="0 0 12 12" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M2 6h8M6.5 2.5 10 6l-3.5 3.5"/></svg>
          </div>
        </div>

      </a>
      <?php endforeach; ?>
    </div>
    <?php endif; ?>

  </div>
</div>

<?php get_footer(); ?>
