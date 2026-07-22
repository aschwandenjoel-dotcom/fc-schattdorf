<?php
/**
 * Template Name: Betreuer
 * Template Post Type: page
 */
defined( 'ABSPATH' ) || exit;

add_action( 'wp_enqueue_scripts', function () {
    $dir = get_stylesheet_directory();
    $uri = get_stylesheet_directory_uri();
    wp_enqueue_style( 'fcs-junioren-org', $uri . '/assets/fcs-junioren-org.css', [], filemtime( $dir . '/assets/fcs-junioren-org.css' ) );
}, 5 );

$up = wp_upload_dir()['baseurl'] . '/2026/06/';

$betreuer = [

    /* ── Junioren A ── */
    [ 'name' => 'Igor Sureta',        'role' => 'Betreuer Junioren A',          'email' => 'i.sureta@cas-gruppe.ch',           'phone' => '078 725 28 75', 'img' => 'Igor_Sureta.jpg' ],
    [ 'name' => 'Sascha Gisler',      'role' => 'Betreuer Junioren A',          'email' => 'sascha77.gisler@gmx.ch',           'phone' => '079 501 01 89', 'img' => 'Sascha_Gisler.jpg' ],
    [ 'name' => 'Roger Zurfluh',      'role' => 'Betreuer Junioren A',          'email' => 'rzurfluh@bosshard.com',            'phone' => '079 372 64 26', 'img' => 'Silhouette_Male_v2.jpg' ],

    /* ── Junioren Ba ── */
    [ 'name' => 'Lon Simonaj',        'role' => 'Betreuer Junioren Ba',         'email' => 'lon.simonaj5@gmail.com',           'phone' => '079 884 67 99', 'img' => 'Lon_Simonaj.jpg' ],
    [ 'name' => 'Fabrizio Merenda',   'role' => 'Betreuer Junioren Ba',         'email' => 'fabrizio.mere@gmail.com',          'phone' => '079 315 00 45', 'img' => 'Fabrizio_Merenda.jpg' ],

    /* ── Junioren Bb ── */
    [ 'name' => 'Niels Chab',         'role' => 'Betreuer Junioren Bb',         'email' => 'niels.chab@gmail.com',             'phone' => '079 201 99 88', 'img' => 'Niels_Chab.jpg' ],
    [ 'name' => 'Robert Gwerder',     'role' => 'Betreuer Junioren Bb',         'email' => 'robert-gwerder@bluewin.ch',        'phone' => '079 680 34 02', 'img' => 'Robert_Gwerder.jpg' ],
    [ 'name' => 'Patrik Müller',      'role' => 'Betreuer Junioren Bb',         'email' => 'padimueller@gmx.ch',               'phone' => '079 273 32 83', 'img' => 'Patrik_Mueller.jpg' ],

    /* ── Junioren Ca ── */
    [ 'name' => 'Fabio Moser',        'role' => 'Betreuer Junioren Ca',         'email' => 'fabiomoser@bluewin.ch',            'phone' => '078 610 75 55', 'img' => 'Fabio_Moser.jpg' ],
    [ 'name' => 'Bernhard Gisler',    'role' => 'Betreuer Junioren Ca',         'email' => 'gisler-gampp@bluewin.ch',          'phone' => '079 204 68 88', 'img' => 'Berhard_Gisler.jpg' ],

    /* ── Junioren Cb ── */
    [ 'name' => 'Fuad Softic',        'role' => 'Betreuer Junioren Cb',         'email' => 'fsoftic@bluewin.ch',               'phone' => '076 336 93 58', 'img' => 'Fuad_Softic.jpg' ],
    [ 'name' => 'Alem Elezovic',      'role' => 'Betreuer Junioren Cb',         'email' => 'alem.ch@hotmail.com',              'phone' => '076 565 85 27', 'img' => 'Alem_Elezovic.jpg' ],
    [ 'name' => 'Sebastian Herzog',   'role' => 'Betreuer Junioren Cb',         'email' => 's.herzog@gmx.ch',                  'phone' => '079 640 92 52', 'img' => 'Sebastian_Herzog.jpg' ],

    /* ── Junioren Da ── */
    [ 'name' => 'Iwan Bissig',        'role' => 'Betreuer Junioren Da',         'email' => 'iwan.bissig@garaventa.com',        'phone' => '079 420 96 06', 'img' => 'Iwan_Bissig.jpg' ],
    [ 'name' => 'Adrian Tresch',      'role' => 'Betreuer Junioren Da',         'email' => 'adrian.tresch@adidach.ch',         'phone' => '079 435 55 80', 'img' => 'Adi_Tresch.jpg' ],

    /* ── Junioren Db ── */
    [ 'name' => 'André Zgraggen',     'role' => 'Betreuer Junioren Db',         'email' => 'zgraggen.andre@bluewin.ch',        'phone' => '079 434 90 84', 'img' => 'Andre_Zgraggen.jpg' ],
    [ 'name' => 'Endrit Krasniqi',    'role' => 'Betreuer Junioren Db',         'email' => 'endritkrasniqi01@hotmail.com',     'phone' => '078 269 82 10', 'img' => 'Endrit_Krasniqi.jpg' ],
    [ 'name' => 'Sandro Zamuner',     'role' => 'Betreuer Junioren Db',         'email' => 'szamuner@gmx.ch',                  'phone' => '079 280 77 20', 'img' => 'Sandro_Zamuner.jpg' ],

    /* ── Junioren Dc ── */
    [ 'name' => 'Jonathan Schürpf',   'role' => 'Betreuer Junioren Dc',         'email' => 'joni-schuerpf@hotmail.com',        'phone' => '079 338 79 98', 'img' => 'Joni_Schuerpf.jpg' ],
    [ 'name' => 'Daniel Triolo',      'role' => 'Betreuer Junioren Dc',         'email' => 'triolo@gmx.ch',                    'phone' => '078 400 31 08', 'img' => 'Daniel_Triolo.jpg' ],
    [ 'name' => 'Elias Müller',       'role' => 'Betreuer Junioren Dc',         'email' => 'eliasmueller477@gmail.com',        'phone' => '079 317 44 42', 'img' => 'Elias_Mueller.jpg' ],
    [ 'name' => 'Fabio Achermann',    'role' => 'Betreuer Junioren Dc',         'email' => 'fabio.achermann2004@gmail.cpm',   'phone' => '079 955 46 41', 'img' => 'Fabio_Achermann.jpg' ],

    /* ── Junioren Dd ── */
    [ 'name' => 'Bruno Inderbitzin',  'role' => 'Betreuer Junioren Dd',         'email' => 'bruno.inderbitzin@hotmail.com',    'phone' => '079 249 98 01', 'img' => 'Bruno_Inderbitzin_2.jpg' ],
    [ 'name' => 'Fabrice Arnold',     'role' => 'Betreuer Junioren Dd',         'email' => 'fabrice.a@gmx.ch',                 'phone' => '079 478 85 65', 'img' => 'Fabrice_Arnold_2.jpg' ],
    [ 'name' => 'Darko Panic',        'role' => 'Betreuer Junioren Dd',         'email' => 'dm-panic@hotmail.com',             'phone' => '078 888 18 98', 'img' => 'Darko_Panic_2.jpg' ],
    [ 'name' => 'Sam Bürer',          'role' => 'Betreuer Junioren Dd',         'email' => 'sam.buerer@gmx.ch',                'phone' => '078 805 46 09', 'img' => 'sam_buerer_2.jpg' ],

    /* ── Junioren De ── */
    [ 'name' => 'Daniel Reichmuth',   'role' => 'Betreuer Junioren De',         'email' => 'tschigi75@gmx.net',                'phone' => '079 616 28 35', 'img' => 'Reichmuth_Daniel.jpg' ],
    [ 'name' => 'René Gnos',          'role' => 'Betreuer Junioren De',         'email' => 'rene.gnos@axa.ch',                 'phone' => '079 420 61 20', 'img' => 'Rene_Gnos.jpg' ],
    [ 'name' => 'Ulrich Arnold',      'role' => 'Betreuer Junioren De',         'email' => 'ulrich.chocher@bluewin.ch',        'phone' => '079 519 48 52', 'img' => 'Ulrich_Arnold.jpg' ],

    /* ── Junioren Df ── */
    [ 'name' => 'Marko Kojadinovic',  'role' => 'Betreuer Junioren Df',         'email' => 'mbelac84@gmail.com',             'phone' => '078 334 23 34', 'img' => 'Silhouette_Male_v2.jpg' ],
    [ 'name' => 'Alessandro Gallo',   'role' => 'Betreuer Junioren Df',         'email' => 'animusliber.web@gmail.com',        'phone' => '079 777 35 49', 'img' => 'Alessandro_Gallo.jpg' ],

    /* ── Junioren Ea/Eb ── */
    [ 'name' => 'Markus Baumann',     'role' => 'Betreuer Junioren Ea/Eb',      'email' => 'kusi.baumann@outlook.com',         'phone' => '079 598 81 40', 'img' => 'Kusi_Baumann.jpg' ],
    [ 'name' => 'Fabian Bachmann',    'role' => 'Betreuer Junioren Ea/Eb',      'email' => 'fabian.bachmann@gmx.ch',           'phone' => '079 689 77 11', 'img' => 'Fabian_Bachmann.jpg' ],
    [ 'name' => 'Andre Planzer',      'role' => 'Betreuer Junioren Ea/Eb',      'email' => 'aplanzer@bluewin.ch',            'phone' => '079 462 50 50', 'img' => 'Silhouette_Male_v2.jpg' ],

    /* ── Junioren Ec ── */
    [ 'name' => 'Christian Meier',    'role' => 'Betreuer Junioren Ec',         'email' => 'cm79@gmx.net',                     'phone' => '079 819 49 38', 'img' => 'Christian_Meier.jpg' ],
    [ 'name' => 'Manuel Gnos',        'role' => 'Betreuer Junioren Ec',         'email' => 'manuel.gnos@bluewin.ch',           'phone' => '079 723 52 54', 'img' => 'Manuel_Gnos.jpg' ],
    [ 'name' => 'Valentin Arnold',    'role' => 'Betreuer Junioren Ec',         'email' => 'vali.arnold@bluewin.ch',         'phone' => '079 749 39 56', 'img' => 'Silhouette_Male_v2.jpg' ],

    /* ── Junioren Ed/Ee ── */
    [ 'name' => 'Mario Trovatelli',   'role' => 'Betreuer Junioren Ed/Ee',      'email' => 'mariot@gmx.ch',                    'phone' => '076 570 57 32', 'img' => 'Mario_Trova.jpg' ],
    [ 'name' => 'Jacqueline Kempf',   'role' => 'Betreuerin Junioren Ed/Ee',    'email' => 'jacqueline.kempf-imholz@gmx.ch',  'phone' => '078 795 29 67', 'img' => 'Jaqueline_Kempf.jpg' ],

    /* ── Junioren Ef ── */
    [ 'name' => 'Jasmin Jaun',        'role' => 'Betreuer Junioren Ef',         'email' => 'jasmin.jaun@gmx.ch',               'phone' => '079 922 45 88', 'img' => 'Jasmin_Jaun_1.jpg' ],
    [ 'name' => 'Simon Gnos',         'role' => 'Betreuer Junioren Ef',         'email' => 'simon_gnos@hotmail.ch',            'phone' => '078 849 41 95', 'img' => 'Simon_Gnos.jpg' ],

    /* ── Team Uri FF11 ── */
    [ 'name' => 'Michael Gisler',     'role' => 'Betreuer Team Uri FF11',       'email' => 'michael.gisler@datwyler.com',      'phone' => '079 752 83 92', 'img' => 'Michael_Gisler.jpg' ],
    [ 'name' => 'Ruedi Herger',       'role' => 'Betreuer Team Uri FF11',       'email' => 'binu.19@hotmail.ch',               'phone' => '079 725 11 45', 'img' => 'Ruedi_Herger.jpg' ],

    /* ── Junioren Fa/Fb/Fc/Fd ── */
    [ 'name' => 'Mathias Venzin',     'role' => 'Betreuer Junioren Fa/Fb/Fc/Fd','email' => 'mathias.venzin@schibli.ch',       'phone' => '079 824 89 84', 'img' => 'Ti_Venzin.jpg' ],
    [ 'name' => 'Simon Welti',        'role' => 'Betreuer Junioren Fa/Fb/Fc/Fd','email' => 's.welti@gmx.net',                 'phone' => '079 740 87 48', 'img' => 'Simon_Welti.jpg' ],
    [ 'name' => 'Christian Esins',    'role' => 'Betreuer Junioren Fa/Fb/Fc/Fd','email' => 'c.esins@aol.com',                 'phone' => '079 679 28 91', 'img' => 'Christian_Esins.jpg' ],
    [ 'name' => 'André Deplazes',     'role' => 'Betreuer Junioren Fa/Fb/Fc/Fd','email' => 'depi@gmx.ch',                    'phone' => '079 654 09 25', 'img' => 'Andre_Deplazes.jpg' ],

    /* ── Junioren Fe/Ff ── */
    [ 'name' => 'Luan Krosa',         'role' => 'Betreuer Junioren Fe/Ff',      'email' => 'luan.kro@outlook.com',             'phone' => '078 906 52 81', 'img' => 'Luan_Krosa.jpg' ],
    [ 'name' => 'Ramanan Ananthavettivelu', 'role' => 'Betreuer Junioren Fe/Ff','email' => 'anantha.ramanan@hotmail.com',     'phone' => '079 247 96 63', 'img' => 'Ramanan_Ananthacettivelu.jpg' ],
    [ 'name' => 'Andre Schelbert',    'role' => 'Betreuer Junioren Fe/Ff',      'email' => 'schelbert30@hotmail.com',          'phone' => '079 260 48 78', 'img' => 'Andre_Schelbert.jpg' ],
    [ 'name' => 'Sandro Zwyssig',     'role' => 'Betreuer Junioren Fe/Ff',      'email' => 'sandro.zwyssig@bluewin.ch',        'phone' => '079 811 78 74', 'img' => 'Sandro_Zwyssig.jpg' ],

    /* ── Fussballschule ── */
    [ 'name' => 'Jacqueline Kempf',   'role' => 'Leiterin Fussballschule',      'email' => '',                                 'phone' => '', 'img' => 'Jaqueline_Kempf.jpg' ],
    [ 'name' => 'Rachel Arnold',      'role' => 'Betreuer Fussballschule',      'email' => '',                                 'phone' => '', 'img' => 'rachel_ajpg.jpg' ],
    [ 'name' => 'Adriana Fedier',     'role' => 'Betreuerin Fussballschule',    'email' => '',                                 'phone' => '', 'img' => 'Adi_Fedier.jpg' ],
    [ 'name' => 'Robin Mahrow',       'role' => 'Betreuer Fussballschule',      'email' => '',                                 'phone' => '', 'img' => 'Rubi_Mahrow.jpg' ],
    [ 'name' => 'Jasmin Jaun',        'role' => 'Betreuerin Fussballschule',    'email' => '',                                 'phone' => '', 'img' => 'Jasmin_Jaun_1.jpg' ],
    [ 'name' => 'Orlando Gisler',     'role' => 'Betreuer Fussballschule',      'email' => '',                                 'phone' => '', 'img' => 'Orlando_Gisler.jpg' ],
    [ 'name' => 'Nicola Mahrow',      'role' => 'Betreuer Fussballschule',      'email' => '',                                 'phone' => '', 'img' => 'Nici_Mahrow_2.jpg' ],

    /* ── Goalietraining ── */
    [ 'name' => 'Luca Aschwanden',    'role' => 'Betreuer Goalietraining Kifu', 'email' => '',                                 'phone' => '', 'img' => 'Silhouette_Male_v2.jpg' ],
    [ 'name' => 'Gian Gisler',        'role' => 'Betreuer Goalietraining Kifu', 'email' => '',                                 'phone' => '', 'img' => 'GianGisler.jpg' ],
    [ 'name' => 'Raphael Imhof',      'role' => 'Torhütertrainer 11er Fussball','email' => '',                                 'phone' => '', 'img' => 'Raphael_Imhof.jpg' ],

];

get_header();
?>

<div class="fcjo-page">

  <div class="fcjo-page-title">
    <h1>Betreuer</h1>
  </div>

  <section class="fcjo-section fcjo-section--light">
    <div class="fcjo-inner">
      <div class="fcjo-grid">
        <?php foreach ( $betreuer as $p ) : ?>
        <div class="fcjo-card">
          <div class="fcjo-card__photo">
            <img src="<?php echo esc_url( $up . $p['img'] ); ?>" alt="<?php echo esc_attr( $p['name'] ); ?>">
          </div>
          <div class="fcjo-card__info">
            <div class="fcjo-card__name"><?php echo esc_html( $p['name'] ); ?></div>
            <div class="fcjo-card__role"><?php echo esc_html( $p['role'] ); ?></div>
            <?php if ( $p['email'] ) : ?>
            <a class="fcjo-card__email" href="mailto:<?php echo esc_attr( $p['email'] ); ?>">E-Mail</a>
            <?php endif; ?>
            <?php if ( $p['phone'] ) : ?>
            <div class="fcjo-card__role">P: <?php echo esc_html( $p['phone'] ); ?></div>
            <?php endif; ?>
          </div>
        </div>
        <?php endforeach; ?>
      </div>
    </div>
  </section>

</div>

<?php get_footer(); ?>
