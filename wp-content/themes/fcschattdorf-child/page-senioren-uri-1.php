<?php
/**
 * Template Name: Senioren Team Uri
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

/* Betreuerstab & Sponsoren kommen aus der Feld-Box «Seiteninhalte»
   (inc/fcs-fields-teams-fs.php); leere Felder zeigen die Fallback-Daten. */
$staff = fcsh_team_staff_from_lines( fcs_pf_lines( 'team_staff', array(
    'Betreuer | André Schelbert | Silhouette_Male_v2.jpg',
    'Betreuer | Marino Britschgi | Silhouette_Male_v2.jpg',
) ) );

$sponsors = fcsh_team_sponsors_from_lines( fcs_pf_lines( 'team_sponsoren', array(
    'Herger Küchen | sp-herger-kuechen.jpg | https://herger-kuechen.ch/',
    'Mövenpick | sp-movenpick.png | https://www.movenpick.com',
    'Lindenapotheke | sp-lindenapotheke.png | https://lindenapo.ch/',
    'Maler Nideroest AG | sp-maler-nideroest.jpg | https://www.maler-nideroest-ag.ch/',
) ) );

$tabelle_url  = 'https://matchcenter.ifv.ch/default.aspx?v=329&oid=7&lng=1&t=30616&a=trr';
$spielplan_url= 'https://matchcenter.ifv.ch/default.aspx?oid=7&lng=1&v=329&t=30616&ls=19998&sg=57728&a=pt';
$mc_url       = 'https://matchcenter.ifv.ch/default.aspx?v=329&oid=7&lng=1&t=30616&a=re';

get_header();
?>

<div class="fc1m-page">

  <!-- ── Hero: Teamfoto mit Titel ── -->
  <div class="fc1m-hero">
    <div class="fc1m-photo">
      <img src="<?php echo esc_url( $up . 'Mannschaftsfoto_Platzhalter.jpg' ); ?>" alt="Senioren Team Uri FC Schattdorf">
    </div>
    <div class="fc1m-herobar">
      <div class="fc1m-herobar__inner">
        <h1 class="fc1m-herobar__title">Senioren Team Uri</h1>
      </div>
    </div>
  </div>

  <!-- ── Tabelle & Spielplan beim IFV ── -->
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
            <?php if ( $s['badge'] ) : ?>
            <img src="<?php echo esc_url( $up . $s['badge'] ); ?>" alt="" class="fc1m-person__badge" aria-hidden="true">
            <?php endif; ?>
          </div>
          <div class="fc1m-person__name"><?php echo esc_html( $s['name'] ); ?></div>
          <div class="fc1m-person__role"><?php echo esc_html( $s['role'] ); ?></div>
        </div>
        <?php endforeach; ?>
      </div>
    </div>
  </section>

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
</div><!-- .fc1m-page -->

<?php get_footer(); ?>
