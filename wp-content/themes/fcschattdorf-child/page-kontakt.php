<?php
/**
 * Template for Kontakt page (slug: kontakt, ID: 74)
 *
 * Adresse/Telefon/E-Mail werden über die Feld-Box «Seiteninhalte»
 * gepflegt (inc/fcs-page-fields.php); das Layout kommt aus der Vorlage.
 */
defined( 'ABSPATH' ) || exit;

add_action( 'wp_enqueue_scripts', function () {
    $dir = get_stylesheet_directory();
    $uri = get_stylesheet_directory_uri();
    wp_enqueue_style( 'fcs-kontakt', $uri . '/assets/fcs-kontakt.css', [], filemtime( $dir . '/assets/fcs-kontakt.css' ) );
}, 5 );

add_filter( 'body_class', function ( $c ) { $c[] = 'fcx-wine-page'; return $c; } );

get_header();

$adresse = fcs_pf( 'kontakt_adresse', "FC Schattdorf\n6467 Schattdorf UR" );
$tel     = fcs_pf( 'kontakt_tel', '041 870 75 65' );
$mail    = fcs_pf( 'kontakt_mail', 'kommunikation@fcschattdorf.ch' );
?>

<div class="fck-page">

  <!-- ── Titel ── -->
  <div class="fck-header fck-in">
    <p class="fck-header__sub">FC Schattdorf</p>
    <h1 class="fck-header__title"><?php the_title(); ?></h1>
  </div>

  <div class="fck-content">
    <div class="fck-card fck-in">

      <p class="fck-card__address">
        <?php echo nl2br( esc_html( $adresse ) ); ?>
      </p>

      <div class="fck-rows">
        <a class="fck-row" href="<?php echo esc_attr( fcsh_tel_href( $tel ) ); ?>">
          <span class="fck-row__icon">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07A19.5 19.5 0 0 1 4.69 12a19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 3.6 1.27h3a2 2 0 0 1 2 1.72c.127.96.361 1.903.7 2.81a2 2 0 0 1-.45 2.11L7.91 8.91a16 16 0 0 0 6 6l.91-.91a2 2 0 0 1 2.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0 1 21.73 16.92z"/></svg>
          </span>
          <span class="fck-row__body">
            <span class="fck-row__label">Telefon</span>
            <span class="fck-row__value"><?php echo esc_html( $tel ); ?></span>
          </span>
          <svg class="fck-row__arrow" viewBox="0 0 20 20" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M4 10h12M11 5l5 5-5 5"/></svg>
        </a>

        <a class="fck-row" href="mailto:<?php echo esc_attr( $mail ); ?>">
          <span class="fck-row__icon">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
          </span>
          <span class="fck-row__body">
            <span class="fck-row__label">E-Mail</span>
            <span class="fck-row__value"><?php echo esc_html( $mail ); ?></span>
          </span>
          <svg class="fck-row__arrow" viewBox="0 0 20 20" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M4 10h12M11 5l5 5-5 5"/></svg>
        </a>
      </div>

    </div>
  </div>

</div>

<?php get_footer(); ?>
