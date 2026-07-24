<?php
/**
 * Template Name: Vorfall melden
 * Template Post Type: page
 *
 * Texte/Kontakte werden über die Feld-Box «Seiteninhalte» gepflegt
 * (inc/fcs-page-fields.php); das Layout kommt aus der Vorlage.
 */
defined( 'ABSPATH' ) || exit;

add_action( 'wp_enqueue_scripts', function () {
    $dir = get_stylesheet_directory();
    $uri = get_stylesheet_directory_uri();
    wp_enqueue_style( 'fcs-vorfall', $uri . '/assets/fcs-vorfall.css', [], filemtime( $dir . '/assets/fcs-vorfall.css' ) );
}, 5 );

add_filter( 'body_class', function ( $c ) { $c[] = 'fcx-wine-page'; return $c; } );

get_header();

$intro      = fcs_pf( 'vf_intro', 'Der FC Schattdorf nimmt den Schutz aller Vereinsmitglieder — insbesondere der Kinder und Jugendlichen — sehr ernst. Wer Zeuge eines Vorfalls wird oder einen Verdacht hat, kann diesen vertraulich und wenn gewünscht anonym melden.' );
$ssi_text   = fcs_pf( 'vf_ssi_text', 'Swiss Sport Integrity ist die unabhängige Anlaufstelle für Ethikvorfälle im Schweizer Sport. Alle Meldungen werden vertraulich behandelt — eine Meldung ist auch vollständig anonym möglich.' );
$ssi_url    = fcs_pf( 'vf_ssi_url', 'https://swisssportintegrity.integrityline.io' );
$hotline    = fcs_pf( 'vf_hotline', '+41 31 550 21 31' );
$hot_zeiten = fcs_pf( 'vf_hotline_zeiten', 'Mo–Fr, 8:30–11:30 und 13:30–16:30 Uhr' );
$meldebar   = fcs_pf_lines( 'vf_meldebar', array(
	'Unfaires oder grenzüberschreitendes Verhalten',
	'Verdacht auf Gewalt oder Missbrauch',
	'Diskriminierung oder Mobbing',
	'Verstösse gegen den Verhaltenskodex des FC Schattdorf',
	'Ethikverstösse und Missstände in der Vereinsstruktur',
	'Verdacht auf Doping',
) );
$lead       = fcs_pf( 'vf_kontakte_lead', 'Für eine erste Auskunft oder wenn jemand innerhalb des Vereins lieber direkt Kontakt aufnehmen möchte, stehen folgende Personen zur Verfügung:' );
$kontakte   = fcs_pf_lines( 'vf_kontakte', array(
	'Präsident | Ralph Bomatter | praesident@fcschattdorf.ch | 079 390 42 01',
	'Administration | Monja Deplazes | admin@fcschattdorf.ch | 078 658 44 34',
) );
$notice     = fcs_pf( 'vf_notice', 'Alle Meldungen — intern wie extern — werden absolut vertraulich behandelt. Es besteht keine Pflicht, sich zu identifizieren.' );
?>

<div class="fcvf-page">

  <!-- ── Titel ── -->
  <div class="fcvf-header">
    <h1 class="fcvf-header__title">Vorfall oder Verdacht melden</h1>
    <p class="fcvf-header__sub">FC Schattdorf — Anlaufstelle für Ethikvorfälle</p>
  </div>

  <div class="fcvf-content">

    <!-- ── Einleitung ── -->
    <p class="fcvf-intro"><?php echo esc_html( $intro ); ?></p>

    <!-- ── Swiss Sport Integrity (primärer Kanal) ── -->
    <section class="fcvf-ssi">
      <div class="fcvf-ssi__inner">
        <div class="fcvf-ssi__label">Offizielle Meldestelle</div>
        <h2 class="fcvf-ssi__title">Swiss Sport Integrity</h2>
        <p class="fcvf-ssi__text"><?php echo esc_html( $ssi_text ); ?></p>
        <div class="fcvf-ssi__channels">
          <a class="fcvf-ssi__btn" href="<?php echo esc_url( $ssi_url ); ?>" target="_blank" rel="noopener noreferrer">
            Online melden
            <svg viewBox="0 0 20 20" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M4 10h12M11 5l5 5-5 5"/></svg>
          </a>
          <div class="fcvf-ssi__hotline">
            <span class="fcvf-ssi__hotline-label">Hotline</span>
            <a href="<?php echo esc_attr( fcsh_tel_href( $hotline ) ); ?>" class="fcvf-ssi__hotline-num"><?php echo esc_html( $hotline ); ?></a>
            <span class="fcvf-ssi__hotline-hours"><?php echo esc_html( $hot_zeiten ); ?></span>
          </div>
        </div>
        <p class="fcvf-ssi__link-note">
          Weitere Informationen:
          <a href="https://www.sportintegrity.ch/organisation/vorfall-melden" target="_blank" rel="noopener noreferrer">sportintegrity.ch</a>
        </p>
      </div>
    </section>

    <!-- ── Was kann gemeldet werden ── -->
    <section class="fcvf-section">
      <h2 class="fcvf-section__title">Was kann gemeldet werden?</h2>
      <ul class="fcvf-list">
        <?php foreach ( $meldebar as $item ) : ?>
          <li><?php echo esc_html( $item ); ?></li>
        <?php endforeach; ?>
      </ul>
    </section>

    <!-- ── Interne Ansprechpersonen ── -->
    <section class="fcvf-section">
      <h2 class="fcvf-section__title">Interne Ansprechpersonen</h2>
      <p class="fcvf-section__lead"><?php echo esc_html( $lead ); ?></p>
      <div class="fcvf-contacts">
        <?php foreach ( $kontakte as $line ) :
            $teile = array_map( 'trim', explode( '|', $line ) );
            if ( count( $teile ) < 2 ) { continue; }
            list( $rolle, $name ) = $teile;
            $mail = $teile[2] ?? '';
            $tel  = $teile[3] ?? '';
            ?>
            <div class="fcvf-contact">
              <div class="fcvf-contact__role"><?php echo esc_html( $rolle ); ?></div>
              <div class="fcvf-contact__name"><?php echo esc_html( $name ); ?></div>
              <?php if ( $mail ) : ?>
                <a href="mailto:<?php echo esc_attr( $mail ); ?>" class="fcvf-contact__link"><?php echo esc_html( $mail ); ?></a>
              <?php endif; ?>
              <?php if ( $tel ) : ?>
                <a href="<?php echo esc_attr( fcsh_tel_href( $tel ) ); ?>" class="fcvf-contact__link"><?php echo esc_html( $tel ); ?></a>
              <?php endif; ?>
            </div>
        <?php endforeach; ?>
      </div>
    </section>

    <!-- ── Vertraulichkeit ── -->
    <div class="fcvf-notice"><?php echo esc_html( $notice ); ?></div>

  </div>

</div><!-- .fcvf-page -->

<?php get_footer(); ?>
