<?php
/**
 * Template Name: Mitglied werden
 * Template Post Type: page
 *
 * Einstiegswege (Kontaktpersonen) werden über die
 * Feld-Box «Seiteninhalte» gepflegt (inc/fcs-fields-design2.php);
 * das Layout kommt aus der Vorlage.
 */
defined( 'ABSPATH' ) || exit;

add_action( 'wp_enqueue_scripts', function () {
    $dir = get_stylesheet_directory();
    $uri = get_stylesheet_directory_uri();
    wp_enqueue_style( 'fcs-mitglied', $uri . '/assets/fcs-mitglied.css', [], filemtime( $dir . '/assets/fcs-mitglied.css' ) );
}, 5 );

get_header();

$sub    = fcs_pf( 'mw_sub', 'Beim FC Schattdorf ist jeder willkommen — ob aktiver Spieler, Junior oder Kind.' );
$tracks = fcs_pf_lines( 'mw_tracks', array(
	'Aktivfussball | Aktive Mannschaft | Du spielst Fussball und möchtest auf einem hohen Niveau trainieren? Melde dich unverbindlich bei unserem Sportchef — wir freuen uns auf dich. | René Gnos | Sportchef | renegnos@bluewin.ch | 079 420 61 20',
	'Junioren A–C | Juniorenbereich | Für Anmeldungen im Juniorenbereich (A- bis C-Junioren) wende dich direkt an unseren Juniorenobmann und Vizepräsidenten. | Iwan Herger | Vizepräsident · Juniorenobmann | juniorenabteilung@fcschattdorf.ch | 078 698 91 95',
	'Kinder F–D | Kinderfussball | Die Jüngsten (F- bis D-Junioren) sind bei unserer KIFU-Leiterin in besten Händen. Einfach melden — Fussball macht Spass! | Jacqueline Kempf | Leiterin KIFU · F–D Junioren | jacqueline.kempf-imholz@gmx.ch | 078 795 29 67',
) );

/* Icons je Einstiegsweg (Design, bleibt in der Vorlage) */
$mw_icons = array(
	'<svg class="fcmb-track__icon" viewBox="0 0 48 48" fill="none" aria-hidden="true">
            <circle cx="24" cy="14" r="7" stroke="currentColor" stroke-width="2"/>
            <path d="M8 42c0-8.837 7.163-16 16-16s16 7.163 16 16" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
          </svg>',
	'<svg class="fcmb-track__icon" viewBox="0 0 48 48" fill="none" aria-hidden="true">
            <circle cx="16" cy="14" r="6" stroke="currentColor" stroke-width="2"/>
            <circle cx="32" cy="14" r="6" stroke="currentColor" stroke-width="2"/>
            <path d="M2 40c0-7.732 6.268-14 14-14" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
            <path d="M32 26c7.732 0 14 6.268 14 14" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
            <path d="M18 40c0-3.314 2.686-6 6-6s6 2.686 6 6" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
          </svg>',
	'<svg class="fcmb-track__icon" viewBox="0 0 48 48" fill="none" aria-hidden="true">
            <circle cx="24" cy="11" r="5.5" stroke="currentColor" stroke-width="2"/>
            <path d="M14 30c0-5.523 4.477-10 10-10s10 4.477 10 10v6H14v-6z" stroke="currentColor" stroke-width="2"/>
            <path d="M20 36v6M28 36v6" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
            <circle cx="12" cy="32" r="3" stroke="currentColor" stroke-width="1.5"/>
            <circle cx="36" cy="32" r="3" stroke="currentColor" stroke-width="1.5"/>
          </svg>',
);
?>

<div class="fcmb-page">

  <!-- ── Header ── -->
  <div class="fcmb-header">
    <h1 class="fcmb-header__title">Mitglied werden</h1>
    <p class="fcmb-header__sub"><?php echo esc_html( $sub ); ?></p>
  </div>

  <!-- ── Einstiegswege ── -->
  <div class="fcmb-tracks-wrap">
    <div class="fcmb-tracks">

      <?php foreach ( $tracks as $i => $zeile ) :
          $teile = array_map( 'trim', explode( '|', $zeile ) );
          if ( count( $teile ) < 6 ) { continue; }
          list( $badge, $titel, $text, $name, $rolle, $mail ) = $teile;
          $tel = $teile[6] ?? '';
          ?>
      <div class="fcmb-track<?php echo 0 === $i ? ' fcmb-track--primary' : ''; ?>">
        <div class="fcmb-track__top">
          <span class="fcmb-track__tag"><?php echo esc_html( $badge ); ?></span>
          <?php echo $mw_icons[ $i % count( $mw_icons ) ]; ?>
          <h2 class="fcmb-track__title"><?php echo esc_html( $titel ); ?></h2>
          <p class="fcmb-track__text"><?php echo esc_html( $text ); ?></p>
        </div>
        <div class="fcmb-track__contact">
          <div class="fcmb-track__contact-name"><?php echo esc_html( $name ); ?></div>
          <div class="fcmb-track__contact-role"><?php echo esc_html( $rolle ); ?></div>
          <div class="fcmb-track__contact-links">
            <a href="mailto:<?php echo esc_attr( $mail ); ?>" class="fcmb-track__link fcmb-track__link--mail"><?php echo esc_html( $mail ); ?></a>
            <?php if ( '' !== $tel ) : ?>
            <a href="<?php echo esc_attr( fcsh_tel_href( $tel ) ); ?>" class="fcmb-track__link fcmb-track__link--phone"><?php echo esc_html( $tel ); ?></a>
            <?php endif; ?>
          </div>
        </div>
        <a href="mailto:<?php echo esc_attr( $mail ); ?>" class="fcmb-track__cta">Kontakt aufnehmen</a>
      </div>
      <?php endforeach; ?>

    </div>
  </div>

</div><!-- .fcmb-page -->

<?php get_footer(); ?>
