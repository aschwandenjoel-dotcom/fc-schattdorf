<?php
/**
 * Template Name: Juniorenkonzept
 * Template Post Type: page
 *
 * Design «Top-Club 88» (assets/fcs-wine-info.css): Creme-Kopf auf Weinrot,
 * Infokarten, Aufzählungsraster, Abschluss-CTA mit PDF-Download.
 *
 * Alle Texte werden über die Feld-Box «Seiteninhalte» gepflegt
 * (inc/fcs-page-fields.php); die Fallbacks entsprechen dem Inhalt des
 * Juniorenkonzepts V2.0.
 */
defined( 'ABSPATH' ) || exit;

add_action( 'wp_enqueue_scripts', function () {
    $dir = get_stylesheet_directory();
    $uri = get_stylesheet_directory_uri();
    wp_enqueue_style( 'fcs-wine-info', $uri . '/assets/fcs-wine-info.css', [], filemtime( $dir . '/assets/fcs-wine-info.css' ) );
}, 5 );

add_filter( 'body_class', function ( $c ) { $c[] = 'fcx-wine-page'; $c[] = 'fcx-info-page'; return $c; } );

$up = wp_upload_dir()['baseurl'] . '/2026/06/';

get_header();

$jk_intro = fcs_pf_lines( 'jk_intro', array(
	'Das Juniorenkonzept richtet sich an alle Trainer und Funktionäre, an die Kinder und Jugendlichen, die beim FC Schattdorf Fussball spielen, sowie an deren Eltern. Es ist ein Leitfaden und eine Philosophie, die wir nach innen wie nach aussen leben — gegenüber anderen Vereinen, Gönnern, Sponsoren und Interessierten.',
	'Gleichzeitig ist es unser wichtigstes Hilfsmittel, um im Kinder- und Juniorenfussball seriös, sorgfältig und kompetent zu arbeiten. Es macht den Juniorenbereich für alle überblickbar und ermöglicht eine effiziente Koordination auf allen Stufen.',
) );
$jk_philosophie = fcs_pf_lines( 'jk_philosophie', array(
	'Der FC Schattdorf bietet allen sportbegeisterten Kindern und Jugendlichen Raum und Gelegenheit, den Fussballsport auszuüben. Der Verein richtet sich dabei auf den Breitensport aus.',
	'Die eigenen Junioren sind das grösste Gut eines Sportvereins. Wir fördern sie so, dass sie mit entsprechendem Alter wichtige Stützen der 1. Mannschaft werden. Im Juniorenbereich ist es unser Ziel, je eine Mannschaft pro Juniorenalter in der höchsten regionalen Stärkeklasse zu stellen — genauso wichtig sind uns aber Spielfreude, Kameradschaft und Fairness.',
) );
$jk_aufgaben = fcs_pf_lines( 'jk_aufgaben', array(
	'Breitenfussballförderung',
	'Freizeitorganisation',
	'Jugendorganisation in der Gemeinde',
	'Nachwuchsförderung',
	'Finden von neuen Funktionären (Ehrenamtlichkeit)',
) );
$jk_ziele = fcs_pf_lines( 'jk_ziele', array(
	'Soziales Ziel | «Spass am Fussball» steht im Vordergrund. Erziehung, Charakterbildung, Fairplay, gemeinsames Beisammensein und Mannschaftsgefühl sind wesentliche Bestandteile.',
	'Sportliches Ziel | Im Zentrum steht immer die Ausbildung des Spielers. Nach Abschluss seiner Juniorenzeit soll ein Junior alle technischen und taktischen Fertigkeiten besitzen.',
	'Organisatorisches Ziel | Jede Juniorenmannschaft sollte zwei Trainer bzw. Betreuer haben. Die Juniorenabteilung ist durch den Leiter Junioren im Vorstand vertreten.',
) );
$jk_grundsaetze = fcs_pf_lines( 'jk_grundsaetze', array(
	'Altersgerecht trainieren | Nicht einfach das Training der Aktiven übernehmen. Je jünger die Junioren, desto stärker steht der reine Spielgedanke im Zentrum.',
	'Ausbildungsbewusst trainieren | Auch die jüngsten Junioren wollen etwas lernen und Fortschritte machen — und nicht nur beschäftigt werden.',
	'Nach Schwerpunkten trainieren | Der Trainer bereitet jedes Training vor, denn der vorbereitete Trainer trainiert besser.',
	'Zielgerichtet trainieren | Pro Trainingseinheit werden Schwerpunkte gesetzt, statt zu viele Themen auf einmal zu behandeln.',
) );
$jk_titel = fcs_pf( 'jk_titel', 'Juniorenkonzept FC Schattdorf' );
$jk_text  = fcs_pf( 'jk_text', 'Das vollständige Konzept mit Ausbildungszielen aller Kategorien, Torhütertraining, Spielphilosophie sowie Rechten und Pflichten von Junioren, Eltern und Betreuern gibt es als PDF.' );
$jk_pdf   = fcs_pf( 'jk_pdf', $up . 'Juniorenkonzept.pdf' );
?>

<div class="fctc-page">

  <!-- Header -->
  <div class="fctc-header">
    <div class="fctc-header__inner">
      <h1><?php the_title(); ?></h1>
      <p class="fctc-header__label">FC Schattdorf · Junioren</p>
    </div>
  </div>

  <!-- Main -->
  <div class="fctc-main">

    <!-- Worum geht es? -->
    <div class="fctc-info">
      <h2>Worum geht es?</h2>
      <?php foreach ( $jk_intro as $absatz ) : ?>
      <p><?php echo esc_html( $absatz ); ?></p>
      <?php endforeach; ?>
    </div>

    <!-- Philosophie -->
    <div class="fctc-info">
      <h2>Unsere Philosophie</h2>
      <?php foreach ( $jk_philosophie as $absatz ) : ?>
      <p><?php echo esc_html( $absatz ); ?></p>
      <?php endforeach; ?>
    </div>

    <!-- Aufgaben der Juniorenabteilung -->
    <div class="fctc-info">
      <h2>Aufgaben der Juniorenabteilung</h2>
      <ul class="fctc-list">
        <?php foreach ( $jk_aufgaben as $aufgabe ) : ?>
        <li><?php echo esc_html( $aufgabe ); ?></li>
        <?php endforeach; ?>
      </ul>
    </div>

    <!-- Ziele -->
    <div class="fctc-info">
      <h2>Unsere Ziele</h2>
      <ul class="fctc-benefits">
        <?php foreach ( $jk_ziele as $zeile ) :
            $teile = array_map( 'trim', explode( '|', $zeile ) );
            ?>
        <li>
          <div>
            <strong><?php echo esc_html( $teile[0] ); ?></strong><br>
            <span><?php echo esc_html( $teile[1] ?? '' ); ?></span>
          </div>
        </li>
        <?php endforeach; ?>
      </ul>
    </div>

    <!-- Trainingsgrundsätze -->
    <div class="fctc-info">
      <h2>Grundsätze im Training</h2>
      <ul class="fctc-benefits">
        <?php foreach ( $jk_grundsaetze as $zeile ) :
            $teile = array_map( 'trim', explode( '|', $zeile ) );
            ?>
        <li>
          <div>
            <strong><?php echo esc_html( $teile[0] ); ?></strong><br>
            <span><?php echo esc_html( $teile[1] ?? '' ); ?></span>
          </div>
        </li>
        <?php endforeach; ?>
      </ul>
    </div>

    <!-- CTA: PDF-Download -->
    <?php if ( $jk_pdf ) : ?>
    <div class="fctc-cta">
      <div class="fctc-cta__text">
        <div class="fctc-cta__label">Zum Nachlesen</div>
        <div class="fctc-cta__title"><?php echo esc_html( $jk_titel ); ?></div>
        <div class="fctc-cta__sub"><?php echo esc_html( $jk_text ); ?></div>
      </div>
      <div class="fctc-cta__action">
        <a href="<?php echo esc_url( $jk_pdf ); ?>" class="fctc-btn" target="_blank" rel="noopener noreferrer">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 15V3m0 12-4-4m4 4 4-4M3 17v2a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-2"/></svg>
          PDF herunterladen
        </a>
      </div>
    </div>
    <?php endif; ?>

  </div>
</div>

<?php get_footer(); ?>
