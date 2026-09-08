<?php
/**
 * Template Name: Liveticker
 *
 * Feste Adresse /liveticker/ für den Tickaroo-Liveticker der 1. Mannschaft.
 *
 * Tickaroo kennt kein «immer der neueste Ticker»-Embed — jeder Ticker hat
 * seine eigene Adresse. Bisher stand diese Adresse fest in front-page.php,
 * vor jedem Spiel wäre ein Code-Deploy nötig gewesen. Jetzt pflegt die
 * Redaktion den Link im Seitenfeld «Link zum aktuellen Ticker» (Box
 * «Seiteninhalte» dieser Seite): ist er gesetzt, leitet die Seite dorthin
 * weiter (302 — absichtlich nicht dauerhaft, der Link wechselt ja); ist er
 * leer, erscheint der Hinweis «Zurzeit kein Liveticker» mit dem Weg zum
 * IFV-Spielplan. Die Startseite verlinkt auf diese Seite, nicht mehr auf
 * einen einzelnen Ticker; die Adresse taugt damit auch für Social Media.
 *
 * Stufe 2 (automatisch über Tickaroos Such-API, braucht client_secret) ist
 * in UMSTELLUNG.md / Chat vom 08.09.2026 beschrieben.
 */
defined( 'ABSPATH' ) || exit;

/* Weiterleitung muss vor jeder Ausgabe passieren. */
$lt_url = trim( (string) fcs_pf( 'lt_url', '' ) );
if ( '' !== $lt_url && wp_http_validate_url( $lt_url ) ) {
	wp_redirect( $lt_url, 302, 'fcs-liveticker' );
	exit;
}

add_action( 'wp_enqueue_scripts', function () {
	$dir = get_stylesheet_directory();
	$uri = get_stylesheet_directory_uri();
	wp_enqueue_style( 'fcs-kontakt', $uri . '/assets/fcs-kontakt.css', [], filemtime( $dir . '/assets/fcs-kontakt.css' ) );
}, 5 );

add_filter( 'body_class', function ( $c ) { $c[] = 'fcx-wine-page'; return $c; } );

get_header();

$text     = fcs_pf( 'lt_text', 'Zurzeit läuft kein Liveticker. Sobald die 1. Mannschaft spielt, findest du hier den Ticker zum Spiel.' );
$plan_url = fcs_pf( 'lt_spielplan_url', 'https://matchcenter.ifv.ch/default.aspx?oid=7&lng=1&v=329&t=30614&ls=24454&sg=67609&a=pt' );
?>

<div class="fck-page">

  <div class="fck-header fck-in">
    <h1 class="fck-header__title"><?php the_title(); ?></h1>
    <p class="fck-header__sub">1. Mannschaft · FC Schattdorf</p>
  </div>

  <div class="fck-content">
    <div class="fck-card fck-in">

      <p class="fck-card__address"><?php echo nl2br( esc_html( $text ) ); ?></p>

      <div class="fck-rows">
        <a class="fck-row" href="<?php echo esc_url( $plan_url ); ?>" target="_blank" rel="noopener">
          <span class="fck-row__icon">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><rect x="3" y="4" width="18" height="18" rx="2"/><path d="M16 2v4M8 2v4M3 10h18"/></svg>
          </span>
          <span class="fck-row__body">
            <span class="fck-row__label">Nächste Spiele</span>
            <span class="fck-row__value">Spielplan beim IFV</span>
          </span>
          <svg class="fck-row__arrow" viewBox="0 0 20 20" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M4 10h12M11 5l5 5-5 5"/></svg>
        </a>
      </div>

    </div>
  </div>

</div>

<?php get_footer(); ?>
