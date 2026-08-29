<?php
/**
 * Template Name: Top-Club 88
 * Template Post Type: page
 *
 * Texte, Vorteile und Vorstand werden über die Feld-Box «Seiteninhalte»
 * gepflegt (inc/fcs-fields-design2.php); das Layout kommt aus der Vorlage.
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

$was_text = fcs_pf( 'tc_was_text', 'Der Top-Club 88 ist der Sponsorenclub des FC Schattdorf. Sein Ziel ist die finanzielle und moralische Unterstützung des Vereins, insbesondere der ersten Mannschaft und der Juniorenabteilung. Die Mitglieder sind keine anonymen Geldgeber, sondern Menschen, die hinter dem FC Schattdorf stehen und den Verein aktiv begleiten.' );
$vorteile = fcs_pf_lines( 'tc_vorteile', array(
	'Jahresbeitrag 250 Franken | Die Hälfte davon geht direkt an die 1. Mannschaft',
	'Saisonkarte | Freier Eintritt zu allen Heimspielen des FC Schattdorf (ausser Cup)',
	'Exklusive Clubanlässe | 2 bis 4 Events pro Jahr, zu denen nur Mitglieder eingeladen sind',
) );
$vorstand = fcs_pf_lines( 'tc_vorstand', array(
	'Präsident | Kai Mahrow | topclubfcs@gmail.com | 079 605 08 19 | Kai_Mahrow.jpg',
	'Vorstand | Daniel Reichmuth | tschigi75@gmx.net | 079 616 28 35',
	'Vorstand | Petra Truttmann | petratru@hotmail.com | 079 743 84 02',
) );
$cta_text = fcs_pf( 'tc_cta_text', 'Melde dich einfach bei Kai Mahrow oder einem der Vorstandsmitglieder. Am schnellsten erreichst du den Vorstand per Mail an' );
$cta_mail = fcs_pf( 'tc_cta_mail', 'topclubfcs@gmail.com' );
?>

<div class="fctc-page">

  <!-- Header -->
  <div class="fctc-header">
    <div class="fctc-header__inner">
      <h1>Top-Club 88</h1>
      <p class="fctc-header__label">FC Schattdorf · Kanton Uri</p>
    </div>
  </div>

  <!-- Main -->
  <div class="fctc-main">

    <!-- Was ist der Top-Club 88? -->
    <div class="fctc-info">
      <h2>Was ist der Top-Club 88?</h2>
      <p><?php echo esc_html( $was_text ); ?></p>
    </div>

    <!-- Mitgliedschaft -->
    <div class="fctc-info">
      <h2>Was bekommst du als Mitglied?</h2>
      <ul class="fctc-benefits">
        <?php foreach ( $vorteile as $zeile ) :
            $teile = array_map( 'trim', explode( '|', $zeile ) );
            ?>
        <li>
          <div>
            <strong><?php echo esc_html( $teile[0] ); ?></strong><br>
            <span><?php echo esc_html( $teile[1] ?? '' ); ?></span>
          </div>
        </li>
        <?php endforeach; ?>
      </ul>
    </div>

    <!-- Vorstand -->
    <h2 class="fctc-section-title">Vorstand Top-Club 88</h2>
    <div class="fctc-vorstand-grid">
      <?php foreach ( $vorstand as $zeile ) :
          $teile = array_map( 'trim', explode( '|', $zeile ) );
          if ( count( $teile ) < 2 ) { continue; }
          list( $rolle, $name ) = $teile;
          $mail = $teile[2] ?? '';
          $tel  = $teile[3] ?? '';
          $bild = fcsh_bild_url( $teile[4] ?? '', $up );
          ?>
      <div class="fctc-card">

        <?php if ( $bild ) : ?>
        <div class="fctc-card__photo">
          <img src="<?php echo esc_url( $bild ); ?>" alt="<?php echo esc_attr( $name ); ?>">
        </div>
        <?php else : ?>
        <div class="fctc-card__photo fctc-card__photo--placeholder">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1" stroke-linecap="round" stroke-linejoin="round">
            <circle cx="12" cy="7" r="4"/>
            <path d="M4 20c0-4 3.6-7 8-7s8 3 8 7"/>
          </svg>
        </div>
        <?php endif; ?>

        <div class="fctc-card__info">
          <div class="fctc-card__role"><?php echo esc_html( $rolle ); ?></div>
          <div class="fctc-card__name"><?php echo esc_html( $name ); ?></div>
          <div class="fctc-card__divider"></div>
          <?php if ( $mail ) : ?>
          <a href="mailto:<?php echo esc_attr( $mail ); ?>" class="fctc-card__email">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="4" width="20" height="16" rx="2"/><path d="m2 7 10 7 10-7"/></svg>
            <?php echo esc_html( $mail ); ?>
          </a>
          <?php endif; ?>
          <?php if ( $tel ) : ?>
          <div class="fctc-card__phone">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.8 19.8 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72c.127.96.361 1.903.7 2.81a2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0 1 22 16.92z"/></svg>
            <?php echo esc_html( $tel ); ?>
          </div>
          <?php endif; ?>
        </div>

      </div>
      <?php endforeach; ?>
    </div>

    <!-- CTA -->
    <div class="fctc-cta">
      <div class="fctc-cta__text">
        <div class="fctc-cta__label">Interesse?</div>
        <div class="fctc-cta__title">Mitglied werden</div>
        <div class="fctc-cta__sub"><?php echo esc_html( $cta_text ); ?> <a href="mailto:<?php echo esc_attr( $cta_mail ); ?>"><?php echo esc_html( $cta_mail ); ?></a>.</div>
      </div>
    </div>

  </div>
</div>

<?php get_footer(); ?>
