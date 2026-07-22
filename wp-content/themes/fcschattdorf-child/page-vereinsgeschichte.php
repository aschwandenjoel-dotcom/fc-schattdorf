<?php
/**
 * Template Name: Vereinsgeschichte
 * Template Post Type: page
 */
defined( 'ABSPATH' ) || exit;

add_action( 'wp_enqueue_scripts', function () {
    $dir = get_stylesheet_directory();
    $uri = get_stylesheet_directory_uri();
    wp_enqueue_style(  'fcs-vg', $uri . '/assets/fcs-vereinsgeschichte.css', [], filemtime( $dir . '/assets/fcs-vereinsgeschichte.css' ) );
    wp_enqueue_script( 'fcs-vg', $uri . '/assets/fcs-vereinsgeschichte.js',  [], filemtime( $dir . '/assets/fcs-vereinsgeschichte.js' ), true );
}, 5 );

add_filter( 'body_class', function ( $c ) { $c[] = 'fcx-wine-page'; return $c; } );

$events = [
  [ 'year'=>1916, 'cat'=>'gruendung', 'milestone'=>true,
    'title'=>'Erste Gründung',
    'text'=>'Am 8. Dezember 1916 wurde nach längerem Ringen um einen tauglichen Fussballplatz, gut besuchten Trainings und erfolgreichen Testspielen der FC Schattdorf das erste Mal gegründet. Infolge der Wirtschaftskrise Ende des ersten Weltkriegs musste der junge Verein jedoch bereits im zweiten Jahr seines Bestehens wieder aufgelöst werden.' ],

  [ 'year'=>1933, 'cat'=>'gruendung', 'milestone'=>true,
    'title'=>'Neugründung des FC Schattdorf',
    'text'=>'Am 9. September 1933 gründete eine beachtliche Anzahl Fussballbegeisterter im Saal des ersten Schattdorfer Schulhauses den FC Schattdorf erneut. Dabei wurden die folgenden sechs Fussballkollegen mit der Leitung des Clubs beauftragt: Franz Inderbitzin (Präsident), Josef Walker (Kassier), Josef Arnold (Aktuar), Alois Gisler (Materialverwalter), Josef Scheiber (Spielleiter), Johann Gisler (Captain).' ],

  [ 'year'=>1933, 'cat'=>'verein',
    'title'=>'Erste Vereinsregeln',
    'text'=>'Die Mitglieder verpflichteten sich, den Trainingsaufgeboten des Spielleiters Josef Scheiber regelmässig Folge zu leisten und einen Monatsbeitrag von 40 Rappen (!) in die Vereinskasse zu zahlen. Jeder Spieler war für die Anschaffung der Ausrüstung selber verantwortlich.' ],

  [ 'year'=>1934, 'cat'=>'verein',
    'title'=>'Aufnahme in den Schweizerischen Fussballverband',
    'text'=>'Am 8. Juli 1934 wurde der FC Schattdorf auf Gesuch hin in den Schweizerischen Fussballverband aufgenommen. Gespielt wird dabei auf dem Sportplatz bei Josef Welti, Rütti. Hierfür bezahlt der Verein pro Spiel anfänglich eine Benützungsgebühr von CHF 10.00; später pauschal CHF 300.00 bzw. CHF 500.00.' ],

  [ 'year'=>1941, 'cat'=>'sport', 'milestone'=>true,
    'title'=>'Aufstieg in die 3. Liga',
    'text'=>'Die 1. Mannschaft steigt in die 3. Liga auf.' ],

  [ 'year'=>1941, 'cat'=>'verein',
    'title'=>'Kriegsbedingte Unterbrechung',
    'text'=>'Im Rahmen der kriegsbedingten «Anbauschlacht» des Bundes wird der Sportplatz über zwei Jahre hinweg landwirtschaftlich genutzt. Der FC Schattdorf muss seine Heimspiele auf die gegnerischen Plätze verlegen oder Forfait erklären. Dies führt dazu, dass sich der FC Schattdorf für die Saison 1942/43 dispensieren lässt.' ],

  [ 'year'=>1944, 'cat'=>'infrastruktur',
    'title'=>'Sportplatz Schützenhausmatte',
    'text'=>'Der FC Schattdorf bezieht den Sportplatz «Schützenhausmatte» (82m × 60m).' ],

  [ 'year'=>1947, 'cat'=>'verein',
    'title'=>'Neuer Vereinspräsident',
    'text'=>'Adelrich Stampfli wird als Vereinspräsident gewählt. Er übernimmt das Amt für vier Jahre.' ],

  [ 'year'=>1949, 'cat'=>'infrastruktur',
    'title'=>'Bälmi-Matte – erster Platz im Dorfkern',
    'text'=>'Der FC Schattdorf bezieht mit dem Grundstück von Franz Gisler, der Bälmi-Matte, erstmals einen Sportplatz im Dorfkern. Heuen und Emden werden zum Ausgleichssport der Fussballer.' ],

  [ 'year'=>1951, 'cat'=>'verein',
    'title'=>'Franz Inderbitzin übernimmt wieder das Präsidium',
    'text'=>'Franz Inderbitzin übernimmt erneut das Präsidium und führt die Geschicke des Vereins bis 1973 – beinahe vierzig Jahre als Vereinspräsident insgesamt.' ],

  [ 'year'=>1956, 'cat'=>'infrastruktur', 'milestone'=>true,
    'title'=>'Einzug in den Grünen Wald',
    'text'=>'Am 12. August 1956 bezieht der FC Schattdorf nicht zuletzt dank der Initiative und Unterstützungsbereitschaft von OK-Präsident und Ehrenmitglied Alois Imholz den heutigen Sportplatz Grüner Wald – die Heimstätte des Vereins bis heute.' ],

  [ 'year'=>1962, 'cat'=>'infrastruktur',
    'title'=>'Garderobengebäude im Grünen Wald',
    'text'=>'Das in Will SG erworbene Garderobengebäude wird demontiert, nach Schattdorf transportiert und steht nach dem Wiederaufbau bis 2011 und damit beinahe 50 Jahre als Umkleidegebäude zur Verfügung.' ],

  [ 'year'=>1967, 'cat'=>'sport',
    'title'=>'Aufstieg in die 2. Liga',
    'text'=>'Die 1. Mannschaft wird in der 3. Liga Gruppensieger und steigt in die 2. Liga auf.' ],

  [ 'year'=>1968, 'cat'=>'sport',
    'title'=>'Abstieg in die 3. Liga',
    'text'=>'Die 1. Mannschaft steigt nach nur einer Saison in der 2. Liga wieder in die 3. Liga ab.' ],

  [ 'year'=>1972, 'cat'=>'sport',
    'title'=>'Erneuter Aufstieg in die 2. Liga',
    'text'=>'Die 1. Mannschaft steigt erneut in die 2. Liga auf.' ],

  [ 'year'=>1973, 'cat'=>'sport',
    'title'=>'Abstieg in die 3. Liga & neuer Präsident',
    'text'=>'Die 1. Mannschaft steigt wieder in die 3. Liga ab. Walter Moser wird als Vereinspräsident gewählt und führt die Geschicke des Vereins bis 1991.' ],

  [ 'year'=>1976, 'cat'=>'sport',
    'title'=>'Aufstieg in die 2. Liga',
    'text'=>'Die 1. Mannschaft wird in der 3. Liga Gruppensieger und steigt erneut in die 2. Liga auf.' ],

  [ 'year'=>1976, 'cat'=>'infrastruktur', 'milestone'=>true,
    'title'=>'Trainingsanlage Kastelen & neues Clubhaus',
    'text'=>'Dank dem Entgegenkommen der Dätwyler AG kann der FC Schattdorf ab 1. September 1976 die Trainingsanlage «Kastelen» in Betrieb nehmen. Zudem wird ein heimeliges Clubhaus an das bestehende Garderobengebäude im Grünen Wald angebaut.' ],

  [ 'year'=>1980, 'cat'=>'sport',
    'title'=>'Abstieg in die 3. Liga',
    'text'=>'Die 1. Mannschaft steigt in die 3. Liga ab.' ],

  [ 'year'=>1989, 'cat'=>'infrastruktur', 'milestone'=>true,
    'title'=>'Sportanlage Grundmatte eingeweiht',
    'text'=>'Im Mai 1989 wird die Sportanlage Grundmatte eingeweiht. Mit dem dort zur Verfügung stehenden Hartplatz hat der FC Schattdorf weitere Alternativen für das Training und für den Spielbetrieb.' ],

  [ 'year'=>1991, 'cat'=>'sport',
    'title'=>'Abstieg in die 4. Liga',
    'text'=>'Die 1. Mannschaft steigt in die 4. Liga ab. Hans Zimmermann wird vorerst als Vorstandskoordinator gewählt und übernimmt ab 1992 bis 1998 die Geschicke des Vereins als Vereinspräsident.' ],

  [ 'year'=>1992, 'cat'=>'sport',
    'title'=>'Aufstieg in die 3. Liga',
    'text'=>'Die 1. Mannschaft steigt als Gruppensieger aus der 4. Liga wieder in die 3. Liga auf.' ],

  [ 'year'=>1997, 'cat'=>'sport',
    'title'=>'Aufstieg in die 2. Liga',
    'text'=>'Die 1. Mannschaft steigt in die 2. Liga auf.' ],

  [ 'year'=>1998, 'cat'=>'verein',
    'title'=>'Neuer Vereinspräsident',
    'text'=>'Kurt Müller wird als Vereinspräsident gewählt. Er übt das Amt vier Jahre aus.' ],

  [ 'year'=>2002, 'cat'=>'verein',
    'title'=>'Neuer Vereinspräsident',
    'text'=>'Beny Tresch wird als Vereinspräsident gewählt. Er ist sieben Jahre im Amt.' ],

  [ 'year'=>2004, 'cat'=>'infrastruktur',
    'title'=>'Kunstrasen Grundmatte',
    'text'=>'Der Hartplatz der Sportanlage Grundmatte wird durch einen modernen Kunstrasenplatz ersetzt.' ],

  [ 'year'=>2005, 'cat'=>'sport', 'milestone'=>true,
    'title'=>'Erster IFV-Cupsieg',
    'text'=>'Die 1. Mannschaft gewinnt in einem Cup-Krimi gegen den FC Emmenbrücke nach Elfmeterschiessen erstmals in der Vereinsgeschichte den IFV-Cup.' ],

  [ 'year'=>2005, 'cat'=>'verein',
    'title'=>'Unwetterkatastrophe zerstört Kastelen',
    'text'=>'Im August 2005 verwüstet eine Unwetterkatastrophe das Schattdorfer Industriegebiet und zerstört die gesamte Trainingsanlage Kastelen.' ],

  [ 'year'=>2007, 'cat'=>'infrastruktur',
    'title'=>'Wiederaufbau Kastelen & neues Vereinslokal',
    'text'=>'Dank breiter Unterstützung kann die Trainingsanlage wieder voll genutzt werden. Zusammen mit der Katzenmusikgesellschaft und der Guggenmusik Nachtschwärmer wird ein neues, gemeinsam genutztes Vereinslokal erstellt.' ],

  [ 'year'=>2010, 'cat'=>'verein',
    'title'=>'Neuer Vereinspräsident',
    'text'=>'Kai Mahrow wird als Vereinspräsident gewählt und führt die Geschicke des Vereins sechs Jahre lang.' ],

  [ 'year'=>2011, 'cat'=>'infrastruktur', 'milestone'=>true,
    'title'=>'Neues Clubhaus eingeweiht',
    'text'=>'Unter der Bauleitung von Stephan Gisler und Projektleiter Iwan Bissig wird im Frühjahr 2011 das neue Clubhaus fertiggestellt und am 26. März 2011 mit einer tollen Party eingeweiht.' ],

  [ 'year'=>2011, 'cat'=>'sport', 'milestone'=>true,
    'title'=>'Zweiter IFV-Cupsieg',
    'text'=>'Die 1. Mannschaft gewinnt gegen den FC Willisau mit 2:1 zum zweiten Mal den IFV-Cup.' ],

  [ 'year'=>2012, 'cat'=>'infrastruktur',
    'title'=>'Verlust der Kastelen-Anlage',
    'text'=>'Der FC Schattdorf verliert den Zugang zu den Kastelen-Plätzen, welche zu Gewerbeflächen umgewandelt werden.' ],

  [ 'year'=>2013, 'cat'=>'verein', 'milestone'=>true,
    'title'=>'80-Jahr-Jubiläum',
    'text'=>'Der FC Schattdorf feiert am 3. August 2013 seinen 80. Geburtstag.' ],

  [ 'year'=>2014, 'cat'=>'sport',
    'title'=>'Abstieg in die 3. Liga',
    'text'=>'Die 1. Mannschaft steigt in die 3. Liga ab.' ],

  [ 'year'=>2016, 'cat'=>'verein',
    'title'=>'Neuer Vereinspräsident',
    'text'=>'René Deplazes wird als Vereinspräsident gewählt.' ],

  [ 'year'=>2017, 'cat'=>'sport',
    'title'=>'Aufstieg in die 2. Liga',
    'text'=>'Die 1. Mannschaft steigt in die 2. Liga auf.' ],

  [ 'year'=>2018, 'cat'=>'sport',
    'title'=>'2. Mannschaft steigt ab',
    'text'=>'Die 2. Mannschaft steigt in die 5. Liga ab.' ],

  [ 'year'=>2019, 'cat'=>'infrastruktur', 'milestone'=>true,
    'title'=>'Kunstrasen im Grünen Wald',
    'text'=>'Der Fussballplatz des Sportplatzes Grüner Wald wird von einem Natur- in einen modernen Kunstrasen umgerüstet und entspricht damit dem Standard der 2. Liga interregional.' ],

  [ 'year'=>2020, 'cat'=>'verein',
    'title'=>'COVID-19 – Saison abgebrochen',
    'text'=>'Die Saison 2019/20 wird aufgrund der COVID-19-Pandemie vorzeitig abgebrochen.' ],

  [ 'year'=>2021, 'cat'=>'sport', 'milestone'=>true,
    'title'=>'Historischer Aufstieg in die 2. Liga interregional',
    'text'=>'Die 1. Mannschaft steigt erstmals in der Vereinsgeschichte in die 2. Liga interregional auf – der bisher grösste sportliche Erfolg des FC Schattdorf. In derselben Saison gewinnen die Senioren 30+ den Schweizer Cup der Senioren und damit als erstes Schattdorfer Fussballteam einen nationalen Wettbewerb. Auch die 2. Mannschaft steigt in die 4. Liga auf.' ],

  [ 'year'=>2022, 'cat'=>'sport',
    'title'=>'Abstieg in die 2. Liga regional',
    'text'=>'Die 1. Mannschaft steigt in die 2. Liga regional ab.' ],

  [ 'year'=>2023, 'cat'=>'sport',
    'title'=>'Meister der 2. Liga regional',
    'text'=>'Die 1. Mannschaft wird Meister der 2. Liga regional. Das Aufstiegsrunden-Hinspiel gegen den FC Bülach gewinnt die 1. Mannschaft 2:0. Auswärts verliert die 1. Mannschaft nach Verlängerung 1:5 (Gesamtskore: 3:5) – der Aufstieg bleibt verwehrt.' ],

  [ 'year'=>2024, 'cat'=>'sport', 'milestone'=>true,
    'title'=>'Dritter IFV-Cup-Triumph',
    'text'=>'Die 1. Mannschaft holt zum dritten Mal den IFV-Cup-Pokal. Gegen den Drittligisten SC Schwyz gewinnt die 1. Mannschaft deutlich mit 5:0.' ],

  [ 'year'=>2024, 'cat'=>'verein',
    'title'=>'Neuer Vereinspräsident',
    'text'=>'Ralph Bomatter wird als Vereinspräsident gewählt.' ],
];

get_header();
?>

<div id="fcvgProgress" class="fcvg-progress-bar" aria-hidden="true"></div>

<div class="fcvg-page">

  <!-- ══════════════════ HERO ══════════════════ -->
  <section class="fcvg-hero">
    <div class="fcvg-hero__content">
      <p class="fcvg-hero__eyebrow">FC Schattdorf &middot; Kanton Uri &middot; Gegründet 1916</p>
      <h1 class="fcvg-hero__title">VEREINS<br>GESCHICHTE</h1>
      <p class="fcvg-hero__sub"><em>Über 100 Jahre Leidenschaft, Zusammenhalt und Fussball</em></p>
    </div>

    <div class="fcvg-hero__stats">
      <div class="fcvg-stat">
        <span class="fcvg-stat__num" data-count="108">108</span>
        <span class="fcvg-stat__label">Jahre Geschichte</span>
      </div>
      <div class="fcvg-stat fcvg-stat--accent">
        <span class="fcvg-stat__num" data-count="3">3</span><span class="fcvg-stat__x">×</span>
        <span class="fcvg-stat__label">IFV-Cup Champion</span>
      </div>
      <div class="fcvg-stat">
        <span class="fcvg-stat__num" data-count="44">44</span>
        <span class="fcvg-stat__label">Kapitel unserer Story</span>
      </div>
    </div>
  </section>

  <!-- ══════════════════ DECADE NAV ══════════════════ -->
  <nav class="fcvg-nav" id="fcvgNav" aria-label="Jahrzehnte Navigation">
    <div class="fcvg-nav__inner">
      <?php
      $decades = array_unique( array_map( fn($e) => (int)( $e['year'] / 10 ) * 10, $events ) );
      foreach ( $decades as $d ) {
          echo '<a class="fcvg-nav__link" href="#decade-' . $d . '">' . $d . 'er</a>';
      }
      ?>
    </div>
  </nav>

  <!-- ══════════════════ TIMELINE ══════════════════ -->
  <div class="fcvg-timeline" id="fcvgTimeline">
    <div class="fcvg-spine" aria-hidden="true"></div>

    <?php
    $current_decade = null;
    foreach ( $events as $i => $ev ) :
        $decade = (int)( $ev['year'] / 10 ) * 10;
        $is_ms  = !empty( $ev['milestone'] );

        if ( $decade !== $current_decade ) :
            $current_decade = $decade;
            ?>
            <div class="fcvg-decade" id="decade-<?php echo $decade; ?>">
              <span class="fcvg-decade__label"><?php echo $decade; ?>er</span>
              <span class="fcvg-decade__rule" aria-hidden="true"></span>
            </div>
            <?php
        endif;
        ?>

        <article class="fcvg-entry<?php echo $is_ms ? ' fcvg-entry--milestone' : ''; ?>"
                 data-year="<?php echo esc_attr( $ev['year'] ); ?>"
                 data-cat="<?php echo esc_attr( $ev['cat'] ); ?>">

          <div class="fcvg-entry__year" aria-hidden="true"><?php echo $ev['year']; ?></div>

          <div class="fcvg-entry__node" aria-hidden="true">
            <div class="fcvg-entry__dot"></div>
          </div>

          <div class="fcvg-entry__card">
            <div class="fcvg-entry__body">
              <?php if ( $is_ms ) : ?>
                <span class="fcvg-entry__badge">
                  <svg viewBox="0 0 24 24" fill="currentColor" width="9" height="9" aria-hidden="true">
                    <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/>
                  </svg>
                  Meilenstein
                </span>
              <?php endif; ?>
              <h3 class="fcvg-entry__title"><?php echo esc_html( $ev['title'] ); ?></h3>
              <p class="fcvg-entry__text"><?php echo esc_html( $ev['text'] ); ?></p>
            </div>
          </div>

        </article>

    <?php endforeach; ?>
  </div><!-- .fcvg-timeline -->

</div><!-- .fcvg-page -->

<?php get_footer(); ?>
