<?php
/**
 * Template Name: Fussball Tauschbörse
 * Template Post Type: page
 *
 * Design «Top-Club 88» (assets/fcs-wine-info.css): Creme-Kopf auf Weinrot,
 * Infokarten, Aufzählungsraster, Abschluss-CTA mit Link zur WhatsApp-Gruppe.
 *
 * Alle Texte werden über die Feld-Box «Seiteninhalte» gepflegt
 * (inc/fcs-page-fields.php).
 */
defined( 'ABSPATH' ) || exit;

add_action( 'wp_enqueue_scripts', function () {
    $dir = get_stylesheet_directory();
    $uri = get_stylesheet_directory_uri();
    wp_enqueue_style( 'fcs-wine-info', $uri . '/assets/fcs-wine-info.css', [], filemtime( $dir . '/assets/fcs-wine-info.css' ) );
}, 5 );

add_filter( 'body_class', function ( $c ) { $c[] = 'fcx-wine-page'; $c[] = 'fcx-info-page'; return $c; } );

get_header();

$tb_intro = fcs_pf_lines( 'tb_intro', array(
	'Du hast Fussballausrüstung zu vergeben oder suchst etwas Bestimmtes? In unserer WhatsApp-Tauschbörse kannst du Schuhe, Trikots, Schienbeinschoner und mehr direkt mit anderen Vereinsmitgliedern tauschen oder verkaufen.',
	'Gerade Kinderfüsse wachsen schnell: Was der einen Familie zu klein geworden ist, passt der nächsten genau. So bleibt gute Ausrüstung im Verein und muss nicht neu gekauft werden.',
) );
$tb_was = fcs_pf_lines( 'tb_was', array(
	'Fussballschuhe',
	'Trikots und Trainingskleider',
	'Schienbeinschoner',
	'Torhüterhandschuhe',
	'Bälle und Sporttaschen',
) );
$tb_ablauf = fcs_pf_lines( 'tb_ablauf', array(
	'Gruppe beitreten | Über den Button unten der WhatsApp-Gruppe beitreten — offen für alle Mitglieder und Eltern des FC Schattdorf.',
	'Angebot oder Gesuch posten | Foto, Grösse, Zustand und Preis (oder «gratis abzugeben») in die Gruppe stellen.',
	'Direkt abmachen | Übergabe unter euch abmachen, am einfachsten beim nächsten Training oder Spiel.',
) );
$tb_hinweis  = fcs_pf( 'tb_hinweis', 'Die Tauschbörse ist ein Angebot von Mitgliedern für Mitglieder. Bitte geht fair und respektvoll miteinander um und nutzt die Gruppe ausschliesslich für Fussballausrüstung — der FC Schattdorf tritt dabei weder als Verkäufer noch als Vermittler auf.' );
$tb_cta_titel = fcs_pf( 'tb_cta_titel', 'Die Tauschbörse läuft auf WhatsApp' );
$tb_cta_text  = fcs_pf( 'tb_cta_text', 'Ein Klick genügt — danach kannst du sofort mitlesen, anbieten und suchen.' );
$tb_url       = fcs_pf( 'tb_url', 'https://chat.whatsapp.com/Lk1bxiLmnLdA3K6x8W1cRG' );
?>

<div class="fctc-page">

  <!-- Header -->
  <div class="fctc-header">
    <div class="fctc-header__inner">
      <h1><?php the_title(); ?></h1>
      <p class="fctc-header__label">FC Schattdorf · Junioren</p>
    </div>
  </div>

  <!-- Main -->
  <div class="fctc-main">

    <!-- Worum geht es? -->
    <div class="fctc-info">
      <h2>Worum geht es?</h2>
      <?php foreach ( $tb_intro as $absatz ) : ?>
      <p><?php echo esc_html( $absatz ); ?></p>
      <?php endforeach; ?>
    </div>

    <!-- Was getauscht wird -->
    <div class="fctc-info">
      <h2>Was getauscht wird</h2>
      <ul class="fctc-list">
        <?php foreach ( $tb_was as $eintrag ) : ?>
        <li><?php echo esc_html( $eintrag ); ?></li>
        <?php endforeach; ?>
      </ul>
    </div>

    <!-- Ablauf -->
    <div class="fctc-info">
      <h2>So funktioniert’s</h2>
      <ol class="fctc-steps">
        <?php foreach ( $tb_ablauf as $zeile ) :
            $teile = array_map( 'trim', explode( '|', $zeile ) );
            ?>
        <li>
          <div>
            <strong><?php echo esc_html( $teile[0] ); ?></strong>
            <span><?php echo esc_html( $teile[1] ?? '' ); ?></span>
          </div>
        </li>
        <?php endforeach; ?>
      </ol>
      <?php if ( $tb_hinweis ) : ?>
      <p class="fctc-note"><?php echo esc_html( $tb_hinweis ); ?></p>
      <?php endif; ?>
    </div>

    <!-- CTA: WhatsApp-Gruppe -->
    <?php if ( $tb_url ) : ?>
    <div class="fctc-cta">
      <div class="fctc-cta__text">
        <div class="fctc-cta__label">Mitmachen</div>
        <div class="fctc-cta__title"><?php echo esc_html( $tb_cta_titel ); ?></div>
        <div class="fctc-cta__sub"><?php echo esc_html( $tb_cta_text ); ?></div>
      </div>
      <div class="fctc-cta__action">
        <a href="<?php echo esc_url( $tb_url ); ?>" class="fctc-btn" target="_blank" rel="noopener noreferrer">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M12.04 2C6.58 2 2.13 6.45 2.13 11.91c0 1.75.46 3.46 1.32 4.96L2 22l5.25-1.38a9.9 9.9 0 0 0 4.79 1.22h.01c5.46 0 9.91-4.45 9.91-9.91 0-2.65-1.03-5.14-2.9-7.01A9.82 9.82 0 0 0 12.04 2zm0 1.82c2.16 0 4.19.84 5.72 2.37a8.04 8.04 0 0 1 2.37 5.72c0 4.46-3.63 8.09-8.09 8.09a8.1 8.1 0 0 1-4.13-1.13l-.3-.18-3.07.8.82-3-.19-.31a8.02 8.02 0 0 1-1.23-4.28c0-4.46 3.63-8.08 8.1-8.08zm-3.2 4.1c-.15 0-.4.06-.6.29-.21.22-.8.78-.8 1.9s.82 2.2.93 2.36c.12.15 1.6 2.44 3.87 3.42.54.24.96.38 1.29.48.54.17 1.04.15 1.43.09.44-.06 1.34-.55 1.53-1.08.19-.53.19-.98.13-1.08-.05-.09-.2-.15-.42-.26-.22-.11-1.34-.66-1.55-.74-.2-.07-.36-.11-.51.12-.15.22-.58.73-.71.88-.13.15-.26.17-.49.06-.22-.11-.95-.35-1.81-1.12a6.8 6.8 0 0 1-1.26-1.56c-.13-.22-.01-.34.1-.45.1-.1.22-.26.34-.39.11-.13.15-.22.22-.37.08-.15.04-.28-.02-.39-.06-.11-.5-1.24-.69-1.7-.18-.44-.37-.38-.5-.39h-.44z"/></svg>
          WhatsApp-Gruppe beitreten
        </a>
      </div>
    </div>
    <?php endif; ?>

  </div>
</div>

<?php get_footer(); ?>
