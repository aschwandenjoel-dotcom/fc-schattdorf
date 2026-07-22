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

// portrait = background portrait photo, badge = small sponsor overlay in corner
$staff = [
    ['role' => 'Trainer',        'name' => 'Thomas Zberg',      'portrait' => 'ZbergThomas.jpg',       'badge' => ''],
    ['role' => 'Co-Trainer',     'name' => 'Reto Infanger',     'portrait' => 'Reto_Infanger.jpg',     'badge' => 'infanger_reto.jpg'],
    ['role' => 'Torwarttrainer', 'name' => 'Thomas Aschwanden', 'portrait' => 'AschwandenThomas.jpg',  'badge' => 'aschw_tom_orig.jpg'],
    ['role' => 'Masseur',        'name' => 'Simon Arnold',      'portrait' => 'arnold_simon2122.jpg',  'badge' => ''],
];

// portrait = player portrait photo, badge = small sponsor logo overlay
$squad = [
    'Torhüter' => [
        ['nr'=>'1',  'name'=>'Gian Gisler',    'portrait'=>'GianGisler.jpg',    'badge'=>'herger_sport.png',         'sponsor'=>'Herger Sport'],
        ['nr'=>'1',  'name'=>'Yannick Arnold',  'portrait'=>'BoeriArnold.jpg',   'badge'=>'Boeri_I.png',              'sponsor'=>'Zahnarzt-Uri'],
    ],
    'Verteidigung' => [
        ['nr'=>'2',  'name'=>'Elias Muoser',    'portrait'=>'EliasMuoser.jpg',   'badge'=>'Muoser_Elias.jpg',         'sponsor'=>'Kebab Häsli'],
        ['nr'=>'3',  'name'=>'Tim Gisler',       'portrait'=>'TimGisler.jpg',     'badge'=>'Gisler_Tim.jpg',           'sponsor'=>'Musch'],
        ['nr'=>'4',  'name'=>'Samuel Wirth',     'portrait'=>'SamuelWirth.jpg',   'badge'=>'saemi.jpg',                'sponsor'=>'KMS AG'],
        ['nr'=>'5',  'name'=>'Sandro Stampfli',  'portrait'=>'StampfliSandro.jpg','badge'=>'Schelbert_AG.png',         'sponsor'=>'Schelbert AG'],
        ['nr'=>'18', 'name'=>'Franco Heinzer',   'portrait'=>'HeinzerFranco.jpg', 'badge'=>'franco_heinzer_sp.jpg',   'sponsor'=>'Heidi Nails'],
    ],
    'Mittelfeld' => [
        ['nr'=>'6',  'name'=>'Joachim Gisler',  'portrait'=>'GislerJoachim.jpg', 'badge'=>'Noah_Noel_Joecha.jpg',    'sponsor'=>'Synaxis Altdorf'],
        ['nr'=>'7',  'name'=>'Noel Gisler',      'portrait'=>'Noel_Gisler.jpg',   'badge'=>'Noah_Noel_Joecha.jpg',    'sponsor'=>'Synaxis Altdorf'],
        ['nr'=>'8',  'name'=>'Simon Wipfli',     'portrait'=>'SimonWipfli.jpg',   'badge'=>'Wipfli.png',              'sponsor'=>'Dätwyler'],
        ['nr'=>'9',  'name'=>'Robin Mahrow',     'portrait'=>'MahrowRobin.jpg',   'badge'=>'Mahrow_Robin_Livio.jpg',  'sponsor'=>'Apéro & Pasta Association'],
        ['nr'=>'10', 'name'=>'Cédric Gisler',    'portrait'=>'CediGisler.jpg',    'badge'=>'Adidach.jpg',             'sponsor'=>'Adidach'],
        ['nr'=>'11', 'name'=>'Andri Baumann',    'portrait'=>'BaumannAndri.jpg',  'badge'=>'andri_baumann_sp.jpg',    'sponsor'=>'Brand Automobile'],
        ['nr'=>'13', 'name'=>'Skander Agrebi',   'portrait'=>'AgrebiSkander.jpg', 'badge'=>'skander_II.jpg',          'sponsor'=>'BMBG'],
        ['nr'=>'15', 'name'=>'Linus Arnold',     'portrait'=>'Linus_Arnold.jpg',  'badge'=>'gotthard_holzbau.png',    'sponsor'=>'Gotthard Holzbau'],
        ['nr'=>'19', 'name'=>'Nico Zgraggen',    'portrait'=>'Nico_Zgraggen.jpg', 'badge'=>'Muoser_Elias.jpg',        'sponsor'=>'Kebab Häsli'],
        ['nr'=>'20', 'name'=>'Nico Bissig',      'portrait'=>'NicoBissig.jpg',    'badge'=>'raiffeisen_logo.png',     'sponsor'=>'Raiffeisen'],
    ],
    'Sturm' => [
        ['nr'=>'12', 'name'=>'Livio Gisler',    'portrait'=>'LivioGisler.jpg',   'badge'=>'livio_gisler_sp.jpg',     'sponsor'=>'Energie Uri'],
        ['nr'=>'14', 'name'=>'Mattia Schorno',  'portrait'=>'MattiaSchorno.jpg', 'badge'=>'zurich_vers.png',         'sponsor'=>'Zurich Insurance'],
        ['nr'=>'16', 'name'=>'Patrik Stampfli', 'portrait'=>'StampfliPatrik.jpg','badge'=>'Staempf_Paedi.jpg',       'sponsor'=>'Gasthaus Brückli'],
    ],
];

$results = [
    [
        'date'     => '13.06.2026',
        'home'     => 'FC Rothenburg',
        'home_logo'=> 'fc-rothenburg.jpg',
        'away'     => 'FC Schattdorf',
        'away_logo'=> 'fc-schattdorf.jpg',
        'score'    => '2:3',
        'platz'    => '',
        'link'     => 'https://www.fcschattdorf.ch/spielberichte/29-meisterschaft/berichte-meisterschaft-23-24/1535-fc-rothenburg-fc-schattdorf-2',
    ],
    [
        'date'     => '19.05.2026',
        'home'     => 'FC Willisau',
        'home_logo'=> 'fc-willisau.png',
        'away'     => 'FC Schattdorf',
        'away_logo'=> 'fc-schattdorf.jpg',
        'score'    => '1:2',
        'platz'    => '',
        'link'     => 'https://www.fcschattdorf.ch/spielberichte/29-meisterschaft/berichte-meisterschaft-23-24/1525-fc-willisau-fc-schattdorf-4',
    ],
    [
        'date'     => '11.05.2026',
        'home'     => 'FC Schattdorf',
        'home_logo'=> 'fc-schattdorf.jpg',
        'away'     => 'SC Obergeissenstein',
        'away_logo'=> 'sc-obergeissenstein.jpg',
        'score'    => '3:3',
        'platz'    => 'Grüner Wald',
        'link'     => 'https://www.fcschattdorf.ch/spielberichte/29-meisterschaft/berichte-meisterschaft-23-24/1516-fc-schattdorf-sc-obergeissenstein-5',
    ],
    [
        'date'     => '12.04.2026',
        'home'     => 'FC Schattdorf',
        'home_logo'=> 'fc-schattdorf.jpg',
        'away'     => 'FC Perlen-Buchrain',
        'away_logo'=> 'fc-perlen-buchrain.png',
        'score'    => '1:1',
        'platz'    => 'Grüner Wald',
        'link'     => 'https://www.fcschattdorf.ch/spielberichte/29-meisterschaft/berichte-meisterschaft-23-24/1484-fc-schattdorf-fc-perlen-buchrain-3',
    ],
    [
        'date'     => '07.04.2026',
        'home'     => 'FC Gunzwil',
        'home_logo'=> 'fc-gunzwil.jpg',
        'away'     => 'FC Schattdorf',
        'away_logo'=> 'fc-schattdorf.jpg',
        'score'    => '2:0',
        'platz'    => '',
        'link'     => 'https://www.fcschattdorf.ch/spielberichte/29-meisterschaft/berichte-meisterschaft-23-24/1483-fc-gunzwil-fc-schattdorf-4',
    ],
    [
        'date'     => '30.03.2026',
        'home'     => 'FC Schattdorf',
        'home_logo'=> 'fc-schattdorf.jpg',
        'away'     => 'FC Sempach',
        'away_logo'=> 'fc-sempach.jpg',
        'score'    => '0:1',
        'platz'    => '',
        'link'     => 'https://www.fcschattdorf.ch/spielberichte/29-meisterschaft/berichte-meisterschaft-23-24/1477-fc-schattdorf-fc-sempach-5',
    ],
    [
        'date'     => '30.03.2026',
        'home'     => 'FC Schattdorf',
        'home_logo'=> 'fc-schattdorf.jpg',
        'away'     => 'SC Goldau',
        'away_logo'=> 'sc-goldau.jpg',
        'score'    => '1:2',
        'platz'    => '',
        'link'     => 'https://www.fcschattdorf.ch/spielberichte/29-meisterschaft/berichte-meisterschaft-23-24/1476-fc-schattdorf-sc-goldau-3',
    ],
    [
        'date'     => '22.03.2026',
        'home'     => 'FC Eschenbach',
        'home_logo'=> 'fc-eschenbach.jpg',
        'away'     => 'FC Schattdorf',
        'away_logo'=> 'fc-schattdorf.jpg',
        'score'    => '2:1',
        'platz'    => '',
        'link'     => 'https://www.fcschattdorf.ch/spielberichte/29-meisterschaft/berichte-meisterschaft-23-24/1466-fc-eschenbach-fc-schattdorf-4',
    ],
    [
        'date'     => '02.11.2025',
        'home'     => 'FC Hochdorf',
        'home_logo'=> 'fc-hochdorf.jpg',
        'away'     => 'FC Schattdorf',
        'away_logo'=> 'fc-schattdorf.jpg',
        'score'    => '2:3',
        'platz'    => '',
        'link'     => 'https://www.fcschattdorf.ch/spielberichte/29-meisterschaft/berichte-meisterschaft-23-24/1448-fc-hochdorf-fc-schattdorf',
    ],
    [
        'date'     => '28.10.2025',
        'home'     => 'FC Schattdorf',
        'home_logo'=> 'fc-schattdorf.jpg',
        'away'     => 'FC Rothenburg',
        'away_logo'=> 'fc-rothenburg.jpg',
        'score'    => '3:0',
        'platz'    => 'Grüner Wald',
        'link'     => 'https://www.fcschattdorf.ch/spielberichte/29-meisterschaft/berichte-meisterschaft-23-24/1442-fc-schattdorf-fc-rothenburg-2',
    ],
];

// Team sponsors with names and URLs
$sponsors = [
    ['img'=>'muoser-color.png',           'name'=>'Muoser',           'url'=>'https://www.muoser.ch/'],
    ['img'=>'imholz-sport-color.jpg',     'name'=>'Imholz Sport',     'url'=>'http://imholzsport.ch/'],
    ['img'=>'axanova.jpg',                'name'=>'Axanova',          'url'=>'http://www.axanova.ch/'],
    ['img'=>'kebab-huesli.jpg',           'name'=>'Kebab Häsli',      'url'=>''],
    ['img'=>'gasthaus-brueckli-color.jpg','name'=>'Gasthaus Brückli', 'url'=>'https://www.brueckli.ch/'],
    ['img'=>'Schelbert_AG.png',           'name'=>'Schelbert AG',     'url'=>'https://www.schelbert-ag.ch/'],
];

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
            <img src="<?php echo esc_url( $up . $p['badge'] ); ?>" alt="" class="fc1m-player__badge" aria-hidden="true">
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
