<?php
/**
 * Template Name: Juniorengeschichte
 * Template Post Type: page
 */
defined( 'ABSPATH' ) || exit;

add_action( 'wp_enqueue_scripts', function () {
    $dir = get_stylesheet_directory();
    $uri = get_stylesheet_directory_uri();
    wp_enqueue_style( 'fcs-juniorengeschichte', $uri . '/assets/fcs-juniorengeschichte.css', [], filemtime( $dir . '/assets/fcs-juniorengeschichte.css' ) );
}, 5 );

add_filter( 'body_class', function ( $c ) { $c[] = 'fcx-wine-page'; return $c; } );

$up = wp_upload_dir()['baseurl'] . '/2026/06/';

get_header();
?>

<div class="fcjg-page">

  <!-- ── Title ── -->
  <div class="fcjg-page-title">
    <h1>Geschichte der Juniorenabteilung</h1>
  </div>

  <!-- ── Hero Image ── -->
  <div class="fcjg-hero-img">
    <img src="<?php echo esc_url( $up . 'Juniorenabteilung.jpg' ); ?>" alt="Juniorenabteilung FC Schattdorf">
  </div>

  <!-- ── Anfänge ── -->
  <section class="fcjg-section">
    <div class="fcjg-inner">
      <div class="fcjg-section__header">
        <h2>Anfänge der Juniorenabteilung</h2>
      </div>
      <div class="fcjg-text">
        <p>Im Frühjahr 1937 wurde bereits die erste Juniorenabteilung des FCS ins Leben gerufen. Trainiert wurde damals vorerst auf dem Loomehlplatz bei der Gerbi und in dieser wurden auch die Mannschaftssitzungen und Hocks abgehalten. Die ersten Spielabmachungen wurden gegen Junioren Equipen aus den Nachbargemeinden, Altdorf, Seedorf, Flüelen, Erstfeld und gar Silenen organisiert.</p>
        <p>Man war sichtlich stolz eine Juniorenabteilung zu besitzen und so schenkte der Verein der Juniorenabteilung bereits im Jahre 1938 ein eigenes Fussball Leibchen für die damals 15 Spieler. Das erste grosse Erlebnis war das Einweihungsspiel dieses neuen Dresses gegen die Junioren des FC Brunnen.</p>
      </div>
    </div>
  </section>

  <!-- ── Weltkrieg ── -->
  <section class="fcjg-section">
    <div class="fcjg-inner">
      <div class="fcjg-section__header">
        <h2>Unterbruch durch den 2. Weltkrieg</h2>
      </div>
      <div class="fcjg-text">
        <p>Infolge der Anbauschlacht, welche durch den 2. Weltkrieg resultierte, verfügte der FC Schattdorf über keinen Fussballplatz mehr und so war die erste Aera der Juniorenbewegung vorderhand zu Ende. Bald darauf, nach dem 2. Weltkrieg, wurde jedoch die zweite Aera der Juniorenabteilung ins Leben gerufen, welche bis zum heutigen Tag Stand hält.</p>
      </div>
    </div>
  </section>

  <!-- ── Neustart ── -->
  <section class="fcjg-section">
    <div class="fcjg-inner">
      <div class="fcjg-section__header">
        <h2>Wachstum und Erfolge</h2>
      </div>
      <div class="fcjg-text">
        <p>Nebst ausgezeichneten Mannschaftsresultaten zeigten auch verschiedene Einzelspieler, welche die Juniorenabteilung des FC Schattdorf durchlaufen haben, ihr grosses Können in diversen Regionalauswahlen des IFV oder sogar des SFV, in Junioren Nationalmannschaften oder als spätere Aktive in Teams der Nationalliga A.</p>
        <p>Heute betreibt der FC Schattdorf mehrere Juniorenteams in verschiedenen Alterskategorien, unterstützt durch ein engagiertes Betreuerteam und spezielle Trainingsangebote wie Goalietraining, Fussballschule und Trainingslager.</p>
      </div>
    </div>
  </section>

</div><!-- .fcjg-page -->

<?php get_footer(); ?>
