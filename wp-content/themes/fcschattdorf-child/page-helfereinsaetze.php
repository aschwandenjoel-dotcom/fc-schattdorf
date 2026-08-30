<?php
/**
 * Template Name: Helfereinsätze
 * Template Post Type: page
 *
 * Texte/Links werden über die Feld-Box «Seiteninhalte» gepflegt
 * (inc/fcs-page-fields.php); das Layout kommt aus der Vorlage.
 */
defined( 'ABSPATH' ) || exit;

/* Astra streckt #content auf grossen Schirmen (#page{min-height:100vh}
   plus #page .site-content{flex-grow:1}). Diese Seite ist kurz, also
   blieb unter dem weinroten Seitenkoerper ein heller Streifen ueber dem
   Footer stehen. Die Schwesterseiten im selben Design (Kontakt, Anfahrt,
   Ehrenmitglieder, …) faerben diese Flaeche ueber die Body-Klasse ein:
   body.fcx-wine-page #content{background:var(--fcx-wine)} in fcs-front.css.
   Hier fehlte sie als einziger Seite dieser Familie. */
add_filter( 'body_class', function ( $c ) { $c[] = 'fcx-wine-page'; return $c; } );

add_action( 'wp_enqueue_scripts', function () {
    $dir = get_stylesheet_directory();
    $uri = get_stylesheet_directory_uri();
    wp_enqueue_style( 'fcs-helfereinsaetze', $uri . '/assets/fcs-helfereinsaetze.css', [], filemtime( $dir . '/assets/fcs-helfereinsaetze.css' ) );
}, 5 );

$up = wp_upload_dir()['baseurl'] . '/2026/06/';

get_header();

$portal_text = fcs_pf( 'he_portal_text', 'Der FC Schattdorf nutzt ab der Rückrunde 24/25 ein neues Helferportal. Das System ermöglicht es Mitgliedern, sich einfach zu registrieren und für verschiedene freiwillige Aufgaben anzumelden – unter anderem Clubhaus (Buffet), Grillstand und weitere Einsätze.' );
$portal_url  = fcs_pf( 'he_portal_url', 'https://portal.helfereinsatz.ch/fc-schattdorf/' );
$pdf         = fcs_pf( 'he_pdf', $up . 'Anleitung_Helferportal_FCS_25_03_05.pdf' );
$pdf_label   = fcs_pf( 'he_pdf_label', 'Anleitung Registrierung und Anmeldung Helferportal (PDF)' );

/* Im Text wird das erste Vorkommen von «Helferportal» zum Portal-Link. */
$portal_svg  = '<svg viewBox="0 0 20 20" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M4 10h12M11 5l5 5-5 5"/></svg>';
$portal_link = '<a href="' . esc_url( $portal_url ) . '" target="_blank" rel="noopener noreferrer">Helferportal' . $portal_svg . '</a>';
$portal_html = esc_html( $portal_text );
if ( false !== strpos( $portal_html, 'Helferportal' ) ) {
	$portal_html = preg_replace( '/Helferportal/', $portal_link, $portal_html, 1 );
} else {
	$portal_html .= ' ' . $portal_link;
}
?>

<div class="fche-page">

  <!-- ── Erster Bildschirm: Titel, Bild, Portal-Hinweis ──
       Eigener Kasten, damit er auf dem Handy genau die Bildschirmhoehe
       fuellt und der Download-Block erst nach dem Scrollen auftaucht. -->
  <div class="fche-screen">

    <!-- ── Titel ── -->
    <header class="fche-header">
      <h1 class="fche-header__title fche-in"><?php the_title(); ?></h1>
      <p class="fche-header__sub">FC Schattdorf · Mithelfen</p>
    </header>

    <div class="fche-content fche-content--intro">

      <!-- ── Bild ── -->
      <div class="fche-hero fche-in">
        <img class="fche-hero__img" src="<?php echo esc_url( $up . 'Helferportal1.jpg' ); ?>" alt="Helfereinsätze">
      </div>

      <!-- ── Portal-Hinweis ── -->
      <div class="fche-portal fche-in">
        <div class="fche-portal__label">Registrierung</div>
        <p class="fche-portal__text"><?php echo $portal_html; ?></p>
      </div>

    </div>

  </div>

  <div class="fche-content fche-content--tail">

    <!-- ── Anleitung herunterladen ── -->
    <section class="fche-section fche-in">
      <h2 class="fche-section__title">Anleitung herunterladen</h2>
      <a class="fche-download" href="<?php echo esc_url( $pdf ); ?>" target="_blank" rel="noopener">
        <span>
          <span class="fche-download__label"><?php echo esc_html( $pdf_label ); ?></span>
        </span>
        <svg class="fche-download__arrow" viewBox="0 0 20 20" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M4 10h12M11 5l5 5-5 5"/></svg>
      </a>
    </section>

  </div>

</div><!-- .fche-page -->

<?php get_footer(); ?>
