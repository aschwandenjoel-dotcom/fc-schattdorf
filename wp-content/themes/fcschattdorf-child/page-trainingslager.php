<?php
/**
 * Template Name: Trainingslager
 * Template Post Type: page
 *
 * Datum, Ort, Kennzahlen, Texte und Kontakte werden über die Feld-Box
 * «Seiteninhalte» gepflegt (inc/fcs-fields-design1.php); das Layout
 * kommt aus der Vorlage.
 */
defined( 'ABSPATH' ) || exit;

add_action( 'wp_enqueue_scripts', function () {
    $dir = get_stylesheet_directory();
    $uri = get_stylesheet_directory_uri();
    wp_enqueue_style( 'fcs-trainingslager', $uri . '/assets/fcs-trainingslager.css', [], filemtime( $dir . '/assets/fcs-trainingslager.css' ) );
}, 5 );

$img = get_stylesheet_directory_uri() . '/assets/img/';

get_header();

$daten        = fcs_pf( 'tl_daten', '20 – 24 Juli 2026' );
$ort          = fcs_pf( 'tl_ort', 'Zuchwil' );
$anmelde_url  = fcs_pf( 'tl_anmeldung_url', 'https://www.fcschattdorf.ch/anmeldung-juniorentrainingslager' );
$facts        = fcs_pf_lines( 'tl_facts', array(
	'5 | Tage Trainingslager',
	'2× | Training täglich',
	'3× | Verpflegung pro Tag',
	'20–24 | Juli 2026 · Zuchwil',
) );
$impressionen = fcs_pf_lines( 'tl_impressionen', array(
	'Start ins Abenteuer | Top Trainingsbedingungen, bestes Sommerwetter und jede Menge Teamspirit. Das Juniorentrainingslager in Zuchwil startet mit vollem Programm.',
	'Zweimal täglich auf dem Platz | Morgens und nachmittags wird trainiert – Technik, Taktik und Spielfreude stehen im Mittelpunkt. Unsere Coaches begleiten euch durch jede Einheit.',
	'Abkühlung nach dem Training | Nach dem Sport gehört die Zeit euch – das Freibad auf dem Campus mit Wasserrutsche sorgt für die perfekte Erholung und unvergessliche Momente.',
	'Teamgeist & Freundschaft | Fussballtennis, Minigolf und gemeinsame Abende – das Abendprogramm schweisst zusammen. Stimmung garantiert: 10/10!',
) );
$campus       = fcs_pf_lines( 'tl_campus', array(
	'Fussballplätze | Topgepflegte Rasenplätze für zwei tägliche Trainingseinheiten – genügend Platz für alle Juniorenteams gleichzeitig.',
	'Freibad mit Rutsche | Das Freibad direkt auf dem Gelände bietet nach dem Training die perfekte Abkühlung – mit Wasserrutschbahn für alle.',
	'Unterkunft | Komfortable Schlafsäle direkt auf dem Gelände – alle Spieler wohnen zusammen und erleben echtes Lagerfeeling.',
	'Professionelle Küche | Ausgebildete Köche bereiten täglich drei frische Mahlzeiten zu – ausgewogen, abwechslungsreich und auf junge Sportler abgestimmt.',
	'Freizeitanlagen | Tischtennis, Fussballtennis, Minigolf und mehr. Das Abendprogramm sorgt für Teamgeist und Spass abseits des Platzes.',
	'Lage Zuchwil | Im Kanton Solothurn, gut erreichbar mit Auto und öffentlichem Verkehr. Anreise-Details werden nach der Anmeldung kommuniziert.',
) );
$programm     = fcs_pf_lines( 'tl_programm', array(
	'Morgen · täglich | Morgentraining | Jeden Morgen steht die erste Trainingseinheit auf dem Programm – mit Fokus auf Technik, Koordination und taktische Grundlagen. Unsere Coaches begleiten euch durch gezielte Übungen und Spielformen.',
	'3× täglich | Frühstück, Mittag & Abendessen | Täglich dreimal frisch und ausgewogen bekocht von professionellen Köchen – Frühstück als Energiestart, Mittagessen zur Erholung nach dem Training, Abendessen für die Regeneration. Wechselnde Menüs, kein Tag wie der andere.',
	'Nachmittag · täglich | Nachmittagstraining | Die zweite Trainingseinheit am Nachmittag steht im Zeichen des Spiels – Wettkämpfe, Spielformen und jede Menge Ball. Hier zeigt sich, was am Morgen gelernt wurde.',
	'Freizeit | Spass mit Freunden | Nach dem Training gehört die Zeit euch. Pool mit Wasserrutsche, Tischtennis, Fussballtennis, Minigolf – das Freizeitprogramm sorgt für neue Freundschaften und unvergessliche Momente abseits des Platzes.',
	'Letzter Tag · Highlight | Abschlussturnier | Der krönende Abschluss der Woche: Alle Teams treten gegeneinander an – volles Programm, voller Einsatz, grosses Finale. Das Abschlussturnier ist der Höhepunkt jedes Trainingslagers.',
) );
$flyer_bild   = fcs_pf( 'tl_flyer_bild', $img . 'tl-flyer.jpg' );
/* Zeigt das Feld auf ein Upload-Bild, das lokal fehlt (Uploads werden nicht
   synchronisiert), das mitgelieferte Theme-Bild verwenden. Live bleibt das
   von der Redaktion gepflegte Bild aktiv. */
$_ud = wp_upload_dir();
if ( 0 === strpos( $flyer_bild, $_ud['baseurl'] ) &&
     ! file_exists( str_replace( $_ud['baseurl'], $_ud['basedir'], $flyer_bild ) ) ) {
	$flyer_bild = $img . 'tl-flyer.jpg';
}
$flyer_text   = fcs_pf( 'tl_flyer_text', 'Im Flyer findest du alle wichtigen Informationen zum Juniorentrainingslager 2026 – Programm, Kosten, Unterkunft und Anmeldedetails kompakt zusammengefasst.' );
$cta_lead     = fcs_pf( 'tl_cta_lead', 'Melde dich jetzt an und sichere dir deinen Platz am Juniorentrainingslager des FC Schattdorf. Plätze sind begrenzt!' );
$kontakte     = fcs_pf_lines( 'tl_kontakte', array(
	'Sandro Zamuner | Organisator TL Zuchwil | 079 280 77 20',
	'René Gnos | Organisator TL Zuchwil | 079 420 61 20',
) );

/* Fotos und Icons bleiben Teil des Designs (Zuordnung nach Reihenfolge) */
$story_fotos = array(
	array( 'tl-story-1.jpg', 'Trainingslager FC Schattdorf' ),
	array( 'tl-story-2.jpg', 'Junioren Training FC Schattdorf' ),
	array( 'tl-story-3.jpg', 'Abkühlung im Pool' ),
	array( 'tl-story-4.jpg', 'FC Schattdorf Junioren Teamgeist' ),
);
$campus_icons    = array( '⚽', '🏊', '🛏️', '👨‍🍳', '🏓', '📍' );
$campus_delays   = array( '', ' tl-reveal-delay-1', ' tl-reveal-delay-2', ' tl-reveal-delay-1', ' tl-reveal-delay-2', ' tl-reveal-delay-3' );
$programm_icons  = array( '🌅', '🍳', '⚽', '🤝', '🏆' );
$programm_delays = array( '', ' tl-reveal-delay-1', ' tl-reveal-delay-2', ' tl-reveal-delay-1', ' tl-reveal-delay-2' );
?>

<div class="tl-page">

  <!-- ══════════════════════════════════════════
       HERO
  ══════════════════════════════════════════ -->
  <section class="tl-hero">
    <div class="tl-hero__bg">
      <img class="tl-hero__img"
           src="<?php echo esc_url( get_stylesheet_directory_uri() . '/assets/img/tl-hero.jpg' ); ?>"
           alt="Juniorentrainingslager FC Schattdorf">
    </div>

    <div class="tl-hero__content">
      <div class="tl-hero__eyebrow">
        FC Schattdorf <span>·</span> Junioren
      </div>
      <h1 class="tl-hero__title">
        Junioren<em>Trainingslager</em>
      </h1>
      <div class="tl-hero__dates">
        <strong><?php echo esc_html( $daten ); ?></strong> &nbsp;·&nbsp; <?php echo esc_html( $ort ); ?>
      </div>
      <a href="<?php echo esc_url( $anmelde_url ); ?>"
         class="tl-hero__cta" target="_blank" rel="noopener">
        Jetzt anmelden
        <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
          <path d="M5 12h14M12 5l7 7-7 7"/>
        </svg>
      </a>
    </div>
  </section>

  <!-- ══════════════════════════════════════════
       FACTS STRIP
  ══════════════════════════════════════════ -->
  <div class="tl-facts">
    <?php foreach ( $facts as $zeile ) :
        $teile = array_map( 'trim', explode( '|', $zeile ) ); ?>
    <div class="tl-fact">
      <div class="tl-fact__num"><?php echo esc_html( $teile[0] ); ?></div>
      <div class="tl-fact__label"><?php echo esc_html( $teile[1] ?? '' ); ?></div>
    </div>
    <?php endforeach; ?>
  </div>

  <!-- ══════════════════════════════════════════
       IMPRESSIONEN
  ══════════════════════════════════════════ -->
  <section class="tl-section tl-section--black">
    <div class="tl-inner">
      <div class="tl-tag tl-reveal">Impressionen</div>
      <h2 class="tl-heading tl-reveal tl-reveal-delay-1">Das <em>Lager</em> erleben</h2>

      <div class="tl-story-grid">

        <?php foreach ( $impressionen as $i => $zeile ) :
            $teile = array_map( 'trim', explode( '|', $zeile ) );
            $foto  = $story_fotos[ $i % count( $story_fotos ) ];
            $delay = ( $i % 4 ) ? ' tl-reveal-delay-' . ( $i % 4 ) : ''; ?>
        <div class="tl-story-item tl-reveal<?php echo $delay; ?>">
          <div class="tl-story-photo">
            <img src="<?php echo esc_url( $img . $foto[0] ); ?>" alt="<?php echo esc_attr( $foto[1] ); ?>">
          </div>
          <div class="tl-story-caption">
            <div class="tl-story-caption__title"><?php echo esc_html( $teile[0] ); ?></div>
            <div class="tl-story-caption__text"><?php echo esc_html( $teile[1] ?? '' ); ?></div>
          </div>
        </div>
        <?php endforeach; ?>

      </div>
    </div>
  </section>

  <!-- ══════════════════════════════════════════
       CAMPUS
  ══════════════════════════════════════════ -->
  <section class="tl-section tl-section--dark">
    <div class="tl-inner">
      <div class="tl-tag tl-reveal">Trainingsstandort</div>
      <h2 class="tl-heading tl-reveal tl-reveal-delay-1">Campus <em><?php echo esc_html( $ort ); ?></em></h2>

      <div class="tl-campus-grid">

        <?php foreach ( $campus as $i => $zeile ) :
            $teile = array_map( 'trim', explode( '|', $zeile ) );
            $n     = $i % count( $campus_icons ); ?>
        <div class="tl-campus-card tl-reveal<?php echo $campus_delays[ $n ]; ?>">
          <span class="tl-campus-card__icon"><?php echo $campus_icons[ $n ]; ?></span>
          <div class="tl-campus-card__title"><?php echo esc_html( $teile[0] ); ?></div>
          <div class="tl-campus-card__text"><?php echo esc_html( $teile[1] ?? '' ); ?></div>
        </div>
        <?php endforeach; ?>

      </div>
    </div>
  </section>

  <!-- ══════════════════════════════════════════
       WAS DICH ERWARTET
  ══════════════════════════════════════════ -->
  <section class="tl-section tl-section--black">
    <div class="tl-inner">
      <div class="tl-tag tl-reveal">Programm</div>
      <h2 class="tl-heading tl-reveal tl-reveal-delay-1">Was dich <em>erwartet</em></h2>

      <div class="tl-program">

        <?php foreach ( $programm as $i => $zeile ) :
            $teile = array_map( 'trim', explode( '|', $zeile ) );
            $n     = $i % count( $programm_icons );
            $rot   = ( count( $programm ) - 1 === $i ) ? ' tl-program-item--red' : ''; ?>
        <div class="tl-program-item<?php echo $rot; ?> tl-reveal<?php echo $programm_delays[ $n ]; ?>">
          <div class="tl-program-item__icon"><?php echo $programm_icons[ $n ]; ?></div>
          <div class="tl-program-item__body">
            <div class="tl-program-item__label"><?php echo esc_html( $teile[0] ); ?></div>
            <div class="tl-program-item__title"><?php echo esc_html( $teile[1] ?? '' ); ?></div>
            <div class="tl-program-item__desc"><?php echo esc_html( $teile[2] ?? '' ); ?></div>
          </div>
        </div>
        <?php endforeach; ?>

      </div>
    </div>
  </section>

  <!-- ══════════════════════════════════════════
       FLYER
  ══════════════════════════════════════════ -->
  <section class="tl-section tl-section--dark">
    <div class="tl-inner">
      <div class="tl-flyer-row">
        <div class="tl-flyer-img-wrap tl-reveal">
          <div class="tl-flyer-corner"></div>
          <img src="<?php echo esc_url( $flyer_bild ); ?>" alt="Trainingslager Flyer FC Schattdorf">
        </div>
        <div class="tl-reveal tl-reveal-delay-2">
          <div class="tl-tag">Flyer & Infos</div>
          <h2 class="tl-heading">Alles auf<br><em>einen Blick</em></h2>
          <p style="font-size:1.0625rem;color:#6b7280;line-height:1.75;margin:0 0 2rem">
            <?php echo esc_html( $flyer_text ); ?>
          </p>
          <a href="<?php echo esc_url( $anmelde_url ); ?>"
             class="tl-cta-btn" target="_blank" rel="noopener">
            Jetzt anmelden
            <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
              <path d="M5 12h14M12 5l7 7-7 7"/>
            </svg>
          </a>
        </div>
      </div>
    </div>
  </section>

  <!-- ══════════════════════════════════════════
       CTA / CONTACT
  ══════════════════════════════════════════ -->
  <section class="tl-section tl-section--black">
    <div class="tl-inner">
      <div class="tl-cta-section tl-reveal">
        <div class="tl-tag" style="display:block;text-align:center;border:none;padding-left:0;margin-bottom:1rem">Mitmachen</div>
        <h2 class="tl-heading">Bist du <em>dabei?</em></h2>
        <p class="tl-cta-lead"><?php echo esc_html( $cta_lead ); ?></p>
        <a href="<?php echo esc_url( $anmelde_url ); ?>"
           class="tl-cta-btn" target="_blank" rel="noopener">
          Jetzt anmelden
          <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
            <path d="M5 12h14M12 5l7 7-7 7"/>
          </svg>
        </a>

        <div class="tl-contacts">
          <?php foreach ( $kontakte as $zeile ) :
              $teile = array_map( 'trim', explode( '|', $zeile ) );
              $tel   = $teile[2] ?? ''; ?>
          <div class="tl-contact-person">
            <div class="tl-contact-person__name"><?php echo esc_html( $teile[0] ); ?></div>
            <div class="tl-contact-person__detail">
              <?php echo esc_html( $teile[1] ?? '' ); ?><br>
              <?php if ( $tel ) : ?><a href="<?php echo esc_attr( fcsh_tel_href( $tel ) ); ?>"><?php echo esc_html( $tel ); ?></a><?php endif; ?>
            </div>
          </div>
          <?php endforeach; ?>
        </div>
      </div>
    </div>
  </section>

</div>

<?php get_footer(); ?>
