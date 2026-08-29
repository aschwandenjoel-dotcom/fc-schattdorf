<?php
/**
 * Template Name: Junioren Team
 * Template Post Type: page
 */
defined( 'ABSPATH' ) || exit;

add_action( 'wp_enqueue_scripts', function () {
    $dir = get_stylesheet_directory();
    $uri = get_stylesheet_directory_uri();
    wp_enqueue_style( 'fcs-1mannschaft', $uri . '/assets/fcs-1mannschaft.css', [], filemtime( $dir . '/assets/fcs-1mannschaft.css' ) );
}, 5 );

add_filter( 'body_class', function( $classes ) {
    $classes[] = 'fcs-team-page';
    return $classes;
} );

$up = wp_upload_dir()['baseurl'] . '/2026/06/';

/* ── Team-Daten aus den Seitenfeldern (Box «Seiteninhalte» im Editor,
      definiert in inc/fcs-fields-junioren-team.php) ────────────────── */
$title = fcs_pf( 'jt_titel', get_the_title() );
$photo = fcs_pf( 'jt_foto', 'Mannschaftsfoto_Platzhalter.jpg' );

/* Betreuerstab: eine Zeile pro Person «Rolle | Name | Portrait-Dateiname» */
$staff = [];
foreach ( fcs_pf_lines( 'jt_betreuer' ) as $line ) {
    $p = array_map( 'trim', explode( '|', $line ) );
    $staff[] = [ 'role' => $p[0] ?? '', 'name' => $p[1] ?? '', 'portrait' => $p[2] ?? '' ];
}

/* Team-Sponsoren: eine Zeile pro Sponsor «Name | Logo-Dateiname | Link» */
$sponsors = [];
foreach ( fcs_pf_lines( 'jt_sponsoren' ) as $line ) {
    $p = array_map( 'trim', explode( '|', $line ) );
    $sponsors[] = [ 'name' => $p[0] ?? '', 'img' => $p[1] ?? '', 'url' => $p[2] ?? '' ];
}

get_header();
?>

<div class="fc1m-page">

  <!-- ── Hero: Teamfoto mit Titel ── -->
  <div class="fc1m-hero">
    <div class="fc1m-photo">
      <img src="<?php echo esc_url( $up . $photo ); ?>" alt="<?php echo esc_attr( $title ); ?> FC Schattdorf">
    </div>
    <div class="fc1m-herobar">
      <div class="fc1m-herobar__inner">
        <h1 class="fc1m-herobar__title"><?php echo esc_html( $title ); ?></h1>
      </div>
    </div>
  </div>

  <!-- ── Tabelle & Spielplan beim IFV ── -->
  <?php
  /* Solange kein teamspezifischer Matchcenter-Link hinterlegt ist
     (Felder «Tabelle»/«Spielplan» der Seite), führen die Kacheln auf die
     IFV-Vereinsseite mit dem Spielbetrieb aller FCS-Teams. */
  $ifv_fallback  = 'https://www.ifv.ch/Innerschweizerischer-Fussballverband/Vereine-IFV/Verein-IFV.aspx/v-329/a-as/';
  $tabelle_url   = fcs_pf( 'jt_tabelle', $ifv_fallback );
  $spielplan_url = fcs_pf( 'jt_spielplan', $ifv_fallback );
  ?>
  <section class="fc1m-ifv">
    <div class="fc1m-wrap">
      <div class="fc1m-ifv__grid">
        <a class="fc1m-ifv__tile" href="<?php echo esc_url( $tabelle_url ); ?>" target="_blank" rel="noopener noreferrer">
          <span class="fc1m-ifv__label">Tabelle</span>
          <span class="fc1m-ifv__meta">Rangliste beim IFV</span>
          <svg viewBox="0 0 12 12" fill="none" stroke="currentColor" stroke-width="1.6" aria-hidden="true"><path d="M2 10L10 2M5 2h5v5"/></svg>
        </a>
        <a class="fc1m-ifv__tile" href="<?php echo esc_url( $spielplan_url ); ?>" target="_blank" rel="noopener noreferrer">
          <span class="fc1m-ifv__label">Spielplan</span>
          <span class="fc1m-ifv__meta">Alle Spiele beim IFV</span>
          <svg viewBox="0 0 12 12" fill="none" stroke="currentColor" stroke-width="1.6" aria-hidden="true"><path d="M2 10L10 2M5 2h5v5"/></svg>
        </a>
      </div>
    </div>
  </section>

  <?php if ( ! empty( $staff ) ) : ?>
  <!-- ── Betreuerstab ── -->
  <section class="fc1m-staff-sec">
    <div class="fc1m-wrap">
      <div class="fc1m-sechead">
        <h2 class="fc1m-sechead__title">Betreuerstab</h2>
      </div>
      <div class="fc1m-person-grid">
        <?php foreach ( $staff as $s ) : ?>
        <div class="fc1m-person">
          <div class="fc1m-person__photo" style="background-image: url('<?php echo esc_url( $up . $s['portrait'] ); ?>');">
          </div>
          <div class="fc1m-person__name"><?php echo esc_html( $s['name'] ); ?></div>
          <div class="fc1m-person__role"><?php echo esc_html( $s['role'] ); ?></div>
        </div>
        <?php endforeach; ?>
      </div>
    </div>
  </section>
  <?php endif; ?>

  <?php if ( ! empty( $sponsors ) ) : ?>
  <!-- ── Team-Sponsoren ── -->
  <section class="fc1m-sponsors-sec">
    <div class="fc1m-wrap">
      <div class="fc1m-sechead">
        <h2 class="fc1m-sechead__title">Team-Sponsoren</h2>
      </div>
      <div class="fc1m-sponsor-grid">
        <?php foreach ( $sponsors as $sp ) : ?>
        <div class="fc1m-sponsor-box">
          <div class="fc1m-sponsor-box__logo">
            <img src="<?php echo esc_url( $up . $sp['img'] ); ?>" alt="<?php echo esc_attr( $sp['name'] ); ?>">
          </div>
          <?php if ( $sp['url'] ) : ?>
          <a href="<?php echo esc_url( $sp['url'] ); ?>" class="fc1m-sponsor-box__name" target="_blank" rel="noopener noreferrer"><?php echo esc_html( $sp['name'] ); ?></a>
          <?php else : ?>
          <span class="fc1m-sponsor-box__name"><?php echo esc_html( $sp['name'] ); ?></span>
          <?php endif; ?>
        </div>
        <?php endforeach; ?>
      </div>
    </div>
  </section>
  <?php endif; ?>
</div><!-- .fc1m-page -->

<?php get_footer(); ?>
