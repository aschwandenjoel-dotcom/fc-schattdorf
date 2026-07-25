<?php
/**
 * Template Name: 1. Mannschaft
 * Template Post Type: page
 */
defined( 'ABSPATH' ) || exit;

add_action( 'wp_enqueue_scripts', function () {
    $dir = get_stylesheet_directory();
    $uri = get_stylesheet_directory_uri();
    wp_enqueue_style( 'fcs-1mannschaft', $uri . '/assets/fcs-1mannschaft.css', [], filemtime( $dir . '/assets/fcs-1mannschaft.css' ) );
}, 5 );

$up = wp_upload_dir()['baseurl'] . '/2026/06/';

/* Pflegbare Inhalte aus der Feld-Box «Seiteninhalte» (Definitionen und
   Helfer in inc/fcs-fields-teams-aktiv.php); Fallback = bisheriger Stand.
   Bilddateien liegen im Upload-Ordner 2026/06. */

// Betreuerstab: Rolle | Name | Porträtbild | Sponsorlogo (kleines Overlay in der Ecke)
$staff = fcsh_team_staff( [
    'Trainer | Thomas Zberg | ZbergThomas.jpg',
    'Co-Trainer | Reto Infanger | Reto_Infanger.jpg | infanger_reto.jpg',
    'Torwarttrainer | Thomas Aschwanden | AschwandenThomas.jpg | aschw_tom_orig.jpg',
    'Masseur | Simon Arnold | arnold_simon2122.jpg',
] );

// Kader: Position | Nr | Name | Porträtbild | Sponsorlogo | Sponsorname (gruppiert nach Position)
$squad = fcsh_team_kader( [
    'Torhüter | 1 | Gian Gisler | GianGisler.jpg | herger_sport.png | Herger Sport',
    'Torhüter | 1 | Yannick Arnold | BoeriArnold.jpg | Boeri_I.png | Zahnarzt-Uri',
    'Verteidigung | 2 | Elias Muoser | EliasMuoser.jpg | Muoser_Elias.jpg | Kebab Häsli',
    'Verteidigung | 3 | Tim Gisler | TimGisler.jpg | Gisler_Tim.jpg | Musch',
    'Verteidigung | 4 | Samuel Wirth | SamuelWirth.jpg | saemi.jpg | KMS AG',
    'Verteidigung | 5 | Sandro Stampfli | StampfliSandro.jpg | Schelbert_AG.png | Schelbert AG',
    'Verteidigung | 18 | Franco Heinzer | HeinzerFranco.jpg | franco_heinzer_sp.jpg | Heidi Nails',
    'Mittelfeld | 6 | Joachim Gisler | GislerJoachim.jpg | Noah_Noel_Joecha.jpg | Synaxis Altdorf',
    'Mittelfeld | 7 | Noel Gisler | Noel_Gisler.jpg | Noah_Noel_Joecha.jpg | Synaxis Altdorf',
    'Mittelfeld | 8 | Simon Wipfli | SimonWipfli.jpg | Wipfli.png | Dätwyler',
    'Mittelfeld | 9 | Robin Mahrow | MahrowRobin.jpg | Mahrow_Robin_Livio.jpg | Apéro & Pasta Association',
    'Mittelfeld | 10 | Cédric Gisler | CediGisler.jpg | Adidach.jpg | Adidach',
    'Mittelfeld | 11 | Andri Baumann | BaumannAndri.jpg | andri_baumann_sp.jpg | Brand Automobile',
    'Mittelfeld | 13 | Skander Agrebi | AgrebiSkander.jpg | skander_II.jpg | BMBG',
    'Mittelfeld | 15 | Linus Arnold | Linus_Arnold.jpg | gotthard_holzbau.png | Gotthard Holzbau',
    'Mittelfeld | 19 | Nico Zgraggen | Nico_Zgraggen.jpg | Muoser_Elias.jpg | Kebab Häsli',
    'Mittelfeld | 20 | Nico Bissig | NicoBissig.jpg | raiffeisen_logo.png | Raiffeisen',
    'Sturm | 12 | Livio Gisler | LivioGisler.jpg | livio_gisler_sp.jpg | Energie Uri',
    'Sturm | 14 | Mattia Schorno | MattiaSchorno.jpg | zurich_vers.png | Zurich Insurance',
    'Sturm | 16 | Patrik Stampfli | StampfliPatrik.jpg | Staempf_Paedi.jpg | Gasthaus Brückli',
] );

// Team-Sponsoren: Name | Logo-Bilddatei | Website (Resultate/Matchcenter zeigt die Seite nicht; IFV-Links oben bleiben fest)
$sponsors = fcsh_team_sponsoren( [
    'Muoser | muoser-color.png | https://www.muoser.ch/',
    'Imholz Sport | imholz-sport-color.jpg | http://imholzsport.ch/',
    'Axanova | axanova.jpg | http://www.axanova.ch/',
    'Kebab Häsli | kebab-huesli.jpg',
    'Gasthaus Brückli | gasthaus-brueckli-color.jpg | https://www.brueckli.ch/',
    'Schelbert AG | Schelbert_AG.png | https://www.schelbert-ag.ch/',
] );

get_header();
?>

<div class="fc1m-page">

  <!-- ── Hero: Teamfoto mit Titel ── -->
  <div class="fc1m-hero">
    <div class="fc1m-photo">
      <img src="<?php echo esc_url( $up . 'FCS1_Web2526.jpg' ); ?>" alt="1. Mannschaft FC Schattdorf">
    </div>
    <div class="fc1m-herobar">
      <div class="fc1m-herobar__inner">
        <h1 class="fc1m-herobar__title">1. Mannschaft</h1>
      </div>
    </div>
  </div>

  <!-- ── Team-Sponsoren direkt unter dem Titelbild ── -->
  <?php fcsh_render_team_sponsor_strip( $sponsors, $up ); ?>

  <!-- ── Tabelle & Spielplan beim IFV ── -->
  <section class="fc1m-ifv">
    <div class="fc1m-wrap">
      <div class="fc1m-ifv__grid">
        <a class="fc1m-ifv__tile" href="https://matchcenter.ifv.ch/default.aspx?v=329&oid=7&lng=1&t=30614&a=trr" target="_blank" rel="noopener noreferrer">
          <span class="fc1m-ifv__label">Tabelle</span>
          <span class="fc1m-ifv__meta">Rangliste beim IFV</span>
          <svg viewBox="0 0 12 12" fill="none" stroke="currentColor" stroke-width="1.6" aria-hidden="true"><path d="M2 10L10 2M5 2h5v5"/></svg>
        </a>
        <a class="fc1m-ifv__tile" href="https://matchcenter.ifv.ch/default.aspx?oid=7&lng=1&v=329&t=30614&ls=24454&sg=67609&a=pt" target="_blank" rel="noopener noreferrer">
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

  <!-- ── Kader ── -->
  <section class="fc1m-kader-sec">
    <div class="fc1m-wrap">
      <div class="fc1m-sechead">
        <h2 class="fc1m-sechead__title">Kader</h2>
      </div>
      <?php foreach ( $squad as $pos => $players ) : ?>
      <h3 class="fc1m-pos-title"><?php echo esc_html( $pos ); ?></h3>
      <div class="fc1m-player-grid">
        <?php foreach ( $players as $p ) : ?>
        <div class="fc1m-player">
          <div class="fc1m-player__photo" style="background-image: url('<?php echo esc_url( $up . $p['portrait'] ); ?>');">
            <?php if ( $p['badge'] ) : ?>
              <?php if ( $p['sponsor'] ) : /* Sponsor-Badge trägt den Sponsornamen als Alt */ ?>
            <img src="<?php echo esc_url( $up . $p['badge'] ); ?>" alt="Sponsor: <?php echo esc_attr( $p['sponsor'] ); ?>" class="fc1m-player__badge">
              <?php else : ?>
            <img src="<?php echo esc_url( $up . $p['badge'] ); ?>" alt="" class="fc1m-player__badge" aria-hidden="true">
              <?php endif; ?>
            <?php endif; ?>
            <span class="fc1m-player__nr"><?php echo esc_html( $p['nr'] ); ?></span>
          </div>
          <div class="fc1m-player__info">
            <div class="fc1m-player__name"><?php echo esc_html( $p['name'] ); ?></div>
            <div class="fc1m-player__pos"><?php echo esc_html( $pos ); ?></div>
            <?php if ( $p['sponsor'] ) : ?>
            <div class="fc1m-player__sponsor"><?php echo esc_html( $p['sponsor'] ); ?></div>
            <?php endif; ?>
          </div>
        </div>
        <?php endforeach; ?>
      </div>
      <?php endforeach; ?>
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
