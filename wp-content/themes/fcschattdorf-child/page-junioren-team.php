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

$up   = wp_upload_dir()['baseurl'] . '/2026/06/';
$slug = get_queried_object()->post_name ?? '';

/* ── Team-Daten ─────────────────────────────────────────────────────── */
$teams = [

    'junioren-a-junioren' => [
        'title'  => 'Junioren Mannschaft A',
        'photo'  => 'A_Junioren_25-26.jpg',
        'staff'  => [
            [ 'role' => 'Betreuer', 'name' => 'Igor Sureta',   'portrait' => 'Igor_Sureta.jpg' ],
            [ 'role' => 'Betreuer', 'name' => 'Sascha Gisler', 'portrait' => 'Sascha_Gisler.jpg' ],
            [ 'role' => 'Betreuer', 'name' => 'Roger Zurfluh', 'portrait' => 'Silhouette_Male_v2.jpg' ],
        ],
        'sponsors' => [
            [ 'img' => 'sp-maler-nideroest.jpg', 'name' => 'Maler Nideroest AG', 'url' => 'https://www.maler-nideroest-ag.ch/' ],
            [ 'img' => 'Schelbert_AG.png',        'name' => 'Schelbert AG',        'url' => 'https://www.schelbert-ag.ch' ],
        ],
    ],

    'junioren-b-junioren-a' => [
        'title'  => 'Junioren Mannschaft Ba',
        'photo'  => 'BA_Junioren_25-26.jpg',
        'staff'  => [
            [ 'role' => 'Betreuer', 'name' => 'Lon Simonaj',      'portrait' => 'Lon_Simonaj.jpg' ],
            [ 'role' => 'Betreuer', 'name' => 'Fabrizio Merenda', 'portrait' => 'Fabrizio_Merenda.jpg' ],
        ],
        'sponsors' => [
            [ 'img' => 'sp-texaid.jpg',           'name' => 'TEXAID',           'url' => 'https://www.texaid.ch/de/' ],
            [ 'img' => 'sp-gasthaus-brueckli.jpg', 'name' => 'Gasthaus Brückli', 'url' => 'https://www.brueckli.ch/' ],
        ],
    ],

    'junioren-b-junioren-b' => [
        'title'  => 'Junioren Mannschaft Bb',
        'photo'  => 'Bb_Junioren_25-26.jpg',
        'staff'  => [
            [ 'role' => 'Betreuer', 'name' => 'Niels Chab',      'portrait' => 'Niels_Chab.jpg' ],
            [ 'role' => 'Betreuer', 'name' => 'Patrik Müller',   'portrait' => 'Patrik_Mueller.jpg' ],
            [ 'role' => 'Betreuer', 'name' => 'Robert Gwerder',  'portrait' => 'Robert_Gwerder.jpg' ],
        ],
        'sponsors' => [
            [ 'img' => 'sp-baeckerei-schillig.jpg', 'name' => 'Bäckerei Schillig', 'url' => 'https://www.beck-schillig.ch/' ],
            [ 'img' => 'sp-texaid.jpg',              'name' => 'TEXAID',             'url' => 'https://www.texaid.ch/de/' ],
        ],
    ],

    'junioren-c-junioren-a' => [
        'title'  => 'Junioren Mannschaft Ca',
        'photo'  => 'Ca_Junioren_25-26.jpg',
        'staff'  => [
            [ 'role' => 'Betreuer', 'name' => 'Bernhard Gisler', 'portrait' => 'Bernhard_Gisler.jpg' ],
            [ 'role' => 'Betreuer', 'name' => 'Fabio Moser',     'portrait' => 'Fabio_Moser.jpg' ],
        ],
        'sponsors' => [
            [ 'img' => 'sp-arnold-ag.png',      'name' => 'Arnold AG',        'url' => 'https://www.arnoldag.ch' ],
            [ 'img' => 'sp-toplehrstellen.png', 'name' => 'toplehrstellen.ch','url' => 'https://toplehrstellen.ch/' ],
        ],
    ],

    'junioren-c-junioren-b' => [
        'title'  => 'Junioren Mannschaft Cb',
        'photo'  => 'Cb_Junioren_25-26.jpg',
        'staff'  => [
            [ 'role' => 'Betreuer', 'name' => 'Fuad Softic',      'portrait' => 'Fuad_Softic.jpg' ],
            [ 'role' => 'Betreuer', 'name' => 'Alem Elezovic',    'portrait' => 'Alem_Elezovic.jpg' ],
            [ 'role' => 'Betreuer', 'name' => 'Sebastian Herzog', 'portrait' => 'Sebastian_Herzog.jpg' ],
        ],
        'sponsors' => [
            [ 'img' => 'kebab-huesli.jpg',  'name' => 'Kebab Hüsli', 'url' => '' ],
            [ 'img' => 'sp-apfelschuss.png','name' => 'Apfelschuss',  'url' => 'https://www.apfelschuss.ch' ],
        ],
    ],

    'junioren-d-junioren' => [
        'title'  => 'Junioren Mannschaft Da',
        'photo'  => 'Da_Junioren_25-26.jpg',
        'staff'  => [
            [ 'role' => 'Betreuer', 'name' => 'Adrian Tresch', 'portrait' => 'Adi_Tresch.jpg' ],
            [ 'role' => 'Betreuer', 'name' => 'Iwan Bissig',   'portrait' => 'Iwan_Bissig.jpg' ],
        ],
        'sponsors' => [
            [ 'img' => 'sp-dosenbach.jpg',    'name' => 'Dosenbach Sport', 'url' => 'https://www.dosenbach.ch/' ],
            [ 'img' => 'sp-merck-profile.png','name' => 'Merck',            'url' => 'https://www.merckgroup.com/ch-en' ],
        ],
    ],

    'junioren-e-junioren' => [
        'title'  => 'Junioren Mannschaft Ea/Eb',
        'photo'  => 'Ea_Juniore_2526.jpg',
        'staff'  => [
            [ 'role' => 'Betreuer', 'name' => 'Markus Baumann', 'portrait' => 'Kusi_Baumann.jpg' ],
            [ 'role' => 'Betreuer', 'name' => 'Andre Planzer',  'portrait' => 'Silhouette_Male_v2.jpg' ],
            [ 'role' => 'Betreuer', 'name' => 'Fabian Bachmann','portrait' => 'Fabian_Bachmann.jpg' ],
        ],
        'sponsors' => [
            [ 'img' => 'sp-gipo.png', 'name' => 'GIPO',  'url' => 'https://www.gipo.ch' ],
            [ 'img' => 'sp-coop.jpg', 'name' => 'Coop',  'url' => 'https://www.coop.ch' ],
        ],
    ],

    'junioren-f-junioren' => [
        'title'  => 'Junioren Mannschaft Fa/Fb/Fc/Fd',
        'photo'  => 'FaFbFcFd_Junioren_25-26.jpg',
        'staff'  => [
            [ 'role' => 'Betreuer', 'name' => 'Mathias Venzin',  'portrait' => 'Ti_Venzin.jpg' ],
            [ 'role' => 'Betreuer', 'name' => 'Simon Welti',     'portrait' => 'Simon_Welti.jpg' ],
            [ 'role' => 'Betreuer', 'name' => 'Christian Esins', 'portrait' => 'Christian_Esins.jpg' ],
            [ 'role' => 'Betreuer', 'name' => 'André Deplazes',  'portrait' => 'Andre_Deplazes.jpg' ],
        ],
        'sponsors' => [
            [ 'img' => 'sp-sata.jpg',       'name' => 'SATA AG',      'url' => 'https://www.sata-ag.ch/' ],
            [ 'img' => 'sp-energieuri.jpg', 'name' => 'Energie Uri',  'url' => 'https://www.energieuri.ch' ],
            [ 'img' => 'sp-gasthaus-brueckli.jpg', 'name' => 'Gasthaus Brückli', 'url' => 'https://www.brueckli.ch/' ],
        ],
    ],

    'team-uri-ff11' => [
        'title'  => 'Team Uri FF11',
        'photo'  => 'IMG_7801.jpg',
        'staff'  => [
            [ 'role' => 'Betreuer', 'name' => 'Marino Arnold',   'portrait' => 'Silhouette_Male_v2.jpg' ],
            [ 'role' => 'Betreuer', 'name' => 'Phillipp Bissig', 'portrait' => 'Silhouette_Male_v2.jpg' ],
            [ 'role' => 'Betreuer', 'name' => 'Michael Gisler',  'portrait' => 'Michael_Gisler.jpg' ],
            [ 'role' => 'Betreuer', 'name' => 'Ruedi Herger',    'portrait' => 'Ruedi_Herger.jpg' ],
        ],
        'sponsors' => [
            [ 'img' => 'sp-coop.jpg', 'name' => 'Coop', 'url' => 'https://www.coop.ch' ],
        ],
    ],

    'junioren-db-junioren' => [
        'title'  => 'Junioren Mannschaft Db',
        'photo'  => 'Db_Junioren_25-26.jpg',
        'staff'  => [
            [ 'role' => 'Betreuer', 'name' => 'Sandro Zamuner',  'portrait' => 'Sandro_Zamuner.jpg' ],
            [ 'role' => 'Betreuer', 'name' => 'André Zgraggen',  'portrait' => 'Andre_Zgraggen.jpg' ],
            [ 'role' => 'Betreuer', 'name' => 'Endrit Krasniqi', 'portrait' => 'Endrit_Krasniqi.jpg' ],
        ],
        'sponsors' => [
            [ 'img' => 'sp-dosenbach.jpg',    'name' => 'Dosenbach Sport',    'url' => 'https://www.dosenbach.ch/' ],
            [ 'img' => 'sp-zahnarzt-uri.png', 'name' => 'Zahnarzt URI',       'url' => 'https://zahnarzt-uri.ch/' ],
        ],
    ],

    'junioren-dc-junioren' => [
        'title'  => 'Junioren Mannschaft Dc',
        'photo'  => 'Dc_Junioren_2526.jpg',
        'staff'  => [
            [ 'role' => 'Betreuer', 'name' => 'Jonathan Schürpf', 'portrait' => 'Joni_Schuerpf.jpg' ],
            [ 'role' => 'Betreuer', 'name' => 'Daniel Triolo',    'portrait' => 'Daniel_Triolo.jpg' ],
            [ 'role' => 'Betreuer', 'name' => 'Elias Müller',     'portrait' => 'Elias_Mueller.jpg' ],
            [ 'role' => 'Betreuer', 'name' => 'Fabio Achermann',  'portrait' => 'Fabio_Achermann.jpg' ],
        ],
        'sponsors' => [
            [ 'img' => 'sp-dosenbach.jpg',        'name' => 'Dosenbach Sport',  'url' => 'https://www.dosenbach.ch/' ],
            [ 'img' => 'sp-gasthaus-brueckli.jpg', 'name' => 'Gasthaus Brückli','url' => 'https://www.brueckli.ch/' ],
        ],
    ],

    'junioren-dd-junioren' => [
        'title'  => 'Junioren Mannschaft Dd',
        'photo'  => 'Team_Foto_2526.jpeg',
        'staff'  => [
            [ 'role' => 'Betreuer', 'name' => 'Bruno Inderbitzin', 'portrait' => 'Bruno_Inderbitzin_2.jpg' ],
            [ 'role' => 'Betreuer', 'name' => 'Fabrice Arnold',    'portrait' => 'Fabrice_Arnold_2.jpg' ],
            [ 'role' => 'Betreuer', 'name' => 'Darko Panic',       'portrait' => 'Darko_Panic_2.jpg' ],
            [ 'role' => 'Betreuer', 'name' => 'Sam Bürer',         'portrait' => 'sam_buerer_2.jpg' ],
        ],
        'sponsors' => [
            [ 'img' => 'sp-interdiscount.png', 'name' => 'Interdiscount', 'url' => 'https://www.interdiscount.ch/de' ],
            [ 'img' => 'sp-bmbg.png',          'name' => 'BMBG',          'url' => 'https://www.bmbg.ch/' ],
        ],
    ],

    'junioren-de-junioren' => [
        'title'  => 'Junioren Mannschaft De',
        'photo'  => 'De_Junioren_25-26.jpg',
        'staff'  => [
            [ 'role' => 'Betreuer', 'name' => 'Daniel Reichmuth', 'portrait' => 'Reichmuth_Daniel.jpg' ],
            [ 'role' => 'Betreuer', 'name' => 'René Gnos',        'portrait' => 'Rene_Gnos.jpg' ],
            [ 'role' => 'Betreuer', 'name' => 'Ulrich Arnold',    'portrait' => 'Ulrich_Arnold.jpg' ],
        ],
        'sponsors' => [
            [ 'img' => 'sp-dosenbach.jpg',    'name' => 'Dosenbach Sport', 'url' => 'https://www.dosenbach.ch/' ],
            [ 'img' => 'sp-merck-profile.png','name' => 'Merck',           'url' => 'https://www.merckgroup.com/ch-en' ],
        ],
    ],

    'junioren-df-junioren' => [
        'title'  => 'Junioren Mannschaft Df',
        'photo'  => 'Df_Junioren_25-26.jpg',
        'staff'  => [
            [ 'role' => 'Betreuer', 'name' => 'Marko Kojadinovic', 'portrait' => 'Silhouette_Male_v2.jpg' ],
            [ 'role' => 'Betreuer', 'name' => 'Alessandro Gallo',  'portrait' => 'Alessandro_Gallo.jpg' ],
        ],
        'sponsors' => [
            [ 'img' => 'sp-maler-nideroest.jpg', 'name' => 'Maler Nideroest AG', 'url' => 'https://www.maler-nideroest-ag.ch/' ],
            [ 'img' => 'sp-dosenbach.jpg',        'name' => 'Dosenbach Sport',    'url' => 'https://www.dosenbach.ch/' ],
        ],
    ],

    'junioren-ec-junioren' => [
        'title'  => 'Junioren Mannschaft Ec',
        'photo'  => 'Ec_Junioren_2526.jpg',
        'staff'  => [
            [ 'role' => 'Betreuer', 'name' => 'Christian Meier',  'portrait' => 'Christian_Meier.jpg' ],
            [ 'role' => 'Betreuer', 'name' => 'Valentin Arnold',  'portrait' => 'Silhouette_Male_v2.jpg' ],
            [ 'role' => 'Betreuer', 'name' => 'Manuel Gnos',      'portrait' => 'Manuel_Gnos.jpg' ],
        ],
        'sponsors' => [
            [ 'img' => 'sp-gisler-transporte.jpg', 'name' => 'Gisler Transporte', 'url' => 'https://www.gisler-transporte.ch/' ],
        ],
    ],

    'junioren-edee-junioren' => [
        'title'  => 'Junioren Mannschaft Ed/Ee',
        'photo'  => 'EdEe_Junioren_25-26.jpg',
        'staff'  => [
            [ 'role' => 'Betreuer', 'name' => 'Mario Trovatelli',  'portrait' => 'Mario_Trova.jpg' ],
            [ 'role' => 'Betreuer', 'name' => 'Jacqueline Kempf',  'portrait' => 'Jaqueline_Kempf.jpg' ],
        ],
        'sponsors' => [
            [ 'img' => 'sp-ukb.jpg',   'name' => 'UKB',            'url' => 'https://www.ukb.ch/' ],
            [ 'img' => 'sp-local.jpg', 'name' => 'local.ch',       'url' => 'https://www.local.ch/' ],
            [ 'img' => 'sp-gasthaus-brueckli.jpg', 'name' => 'Gasthaus Brückli', 'url' => 'https://www.brueckli.ch/' ],
        ],
    ],

    'junioren-ef-junioren' => [
        'title'  => 'Junioren Mannschaft Ef',
        'photo'  => 'Ef_Junioren_25-26.jpg',
        'staff'  => [
            [ 'role' => 'Betreuer', 'name' => 'Jasmin Jaun', 'portrait' => 'Jasmin_Jaun_1.jpg' ],
            [ 'role' => 'Betreuer', 'name' => 'Simon Gnos',  'portrait' => 'Simon_Gnos.jpg' ],
        ],
        'sponsors' => [
            [ 'img' => 'sp-opus-personal.jpg', 'name' => 'Opus Personal', 'url' => 'http://opus-personal.ch/' ],
        ],
    ],

    'junioren-feff-junioren' => [
        'title'  => 'Junioren Mannschaft Fe/Ff',
        'photo'  => 'FeFf_Junioren_25-26.jpg',
        'staff'  => [
            [ 'role' => 'Betreuer', 'name' => 'Luan Krosa',               'portrait' => 'Luan_Krosa.jpg' ],
            [ 'role' => 'Betreuer', 'name' => 'Ramanan Ananthavettivelu', 'portrait' => 'Ramanan_Ananthacettivelu.jpg' ],
            [ 'role' => 'Betreuer', 'name' => 'Andre Schelbert',          'portrait' => 'Andre_Schelbert.jpg' ],
            [ 'role' => 'Betreuer', 'name' => 'Sandro Zwyssig',           'portrait' => 'Sandro_Zwyssig.jpg' ],
        ],
        'sponsors' => [
            [ 'img' => 'sp-imholz-sport.jpg', 'name' => 'Imholz Sport', 'url' => 'http://imholzsport.ch/' ],
            [ 'img' => 'sp-local.jpg',         'name' => 'local.ch',     'url' => 'https://www.local.ch/' ],
        ],
    ],

];

$team = $teams[ $slug ] ?? [ 'title' => get_the_title(), 'photo' => 'Mannschaftsfoto_Platzhalter.jpg', 'staff' => [], 'sponsors' => [] ];

get_header();
?>

<div class="fc1m-page">

  <!-- ── Hero: Teamfoto mit Titel ── -->
  <div class="fc1m-hero">
    <div class="fc1m-photo">
      <img src="<?php echo esc_url( $up . $team['photo'] ); ?>" alt="<?php echo esc_attr( $team['title'] ); ?> FC Schattdorf">
    </div>
    <div class="fc1m-herobar">
      <div class="fc1m-herobar__inner">
        <h1 class="fc1m-herobar__title"><?php echo esc_html( $team['title'] ); ?></h1>
      </div>
    </div>
  </div>


  <?php if ( ! empty( $team['staff'] ) ) : ?>
  <!-- ── Betreuerstab ── -->
  <section class="fc1m-staff-sec">
    <div class="fc1m-wrap">
      <div class="fc1m-sechead">
        <h2 class="fc1m-sechead__title">Betreuerstab</h2>
      </div>
      <div class="fc1m-person-grid">
        <?php foreach ( $team['staff'] as $s ) : ?>
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

  <?php if ( ! empty( $team['sponsors'] ) ) : ?>
  <!-- ── Team-Sponsoren ── -->
  <section class="fc1m-sponsors-sec">
    <div class="fc1m-wrap">
      <div class="fc1m-sechead">
        <h2 class="fc1m-sechead__title">Team-Sponsoren</h2>
      </div>
      <div class="fc1m-sponsor-grid">
        <?php foreach ( $team['sponsors'] as $sp ) : ?>
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
