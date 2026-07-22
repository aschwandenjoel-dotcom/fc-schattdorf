<?php
/**
 * Template Name: Trainingslager
 * Template Post Type: page
 */
defined( 'ABSPATH' ) || exit;

add_action( 'wp_enqueue_scripts', function () {
    $dir = get_stylesheet_directory();
    $uri = get_stylesheet_directory_uri();
    wp_enqueue_style( 'fcs-trainingslager', $uri . '/assets/fcs-trainingslager.css', [], filemtime( $dir . '/assets/fcs-trainingslager.css' ) );
}, 5 );

$up = wp_upload_dir()['baseurl'] . '/2026/06/';

get_header();
?>

<div class="tl-page">

  <!-- ══════════════════════════════════════════
       HERO
  ══════════════════════════════════════════ -->
  <section class="tl-hero">
    <div class="tl-hero__bg">
      <img class="tl-hero__img"
           src="<?php echo esc_url( $up . 'turnier_kids.jpeg' ); ?>"
           alt="Juniorentrainingslager FC Schattdorf">
    </div>
    <div class="tl-hero__slash"></div>

    <div class="tl-hero__content">
      <div class="tl-hero__eyebrow">
        FC Schattdorf <span>·</span> Junioren
      </div>
      <h1 class="tl-hero__title">
        Junioren<em>Trainingslager</em>
      </h1>
      <div class="tl-hero__dates">
        <strong>20 – 24 Juli 2026</strong> &nbsp;·&nbsp; Zuchwil
      </div>
      <a href="https://www.fcschattdorf.ch/anmeldung-juniorentrainingslager"
         class="tl-hero__cta" target="_blank" rel="noopener">
        Jetzt anmelden
        <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
          <path d="M5 12h14M12 5l7 7-7 7"/>
        </svg>
      </a>
    </div>

    <div class="tl-scroll-hint">
      <span>Scroll</span>
      <div class="tl-scroll-hint__line"></div>
    </div>
  </section>

  <!-- ══════════════════════════════════════════
       FACTS STRIP
  ══════════════════════════════════════════ -->
  <div class="tl-facts">
    <div class="tl-fact">
      <div class="tl-fact__num">5</div>
      <div class="tl-fact__label">Tage Trainingslager</div>
    </div>
    <div class="tl-fact">
      <div class="tl-fact__num">2×</div>
      <div class="tl-fact__label">Training täglich</div>
    </div>
    <div class="tl-fact">
      <div class="tl-fact__num">3×</div>
      <div class="tl-fact__label">Verpflegung pro Tag</div>
    </div>
    <div class="tl-fact">
      <div class="tl-fact__num">20–24</div>
      <div class="tl-fact__label">Juli 2026 · Zuchwil</div>
    </div>
  </div>

  <!-- ══════════════════════════════════════════
       IMPRESSIONEN
  ══════════════════════════════════════════ -->
  <section class="tl-section tl-section--black">
    <div class="tl-inner">
      <div class="tl-tag tl-reveal">Impressionen</div>
      <h2 class="tl-heading tl-reveal tl-reveal-delay-1">Das <em>Lager</em> erleben</h2>

      <div class="tl-story-grid">

        <div class="tl-story-item tl-reveal">
          <div class="tl-story-photo">
            <img src="<?php echo esc_url( $up . 'tl_ig_1.jpg' ); ?>" alt="Trainingslager FC Schattdorf">
          </div>
          <div class="tl-story-caption">
            <div class="tl-story-caption__title">Start ins Abenteuer</div>
            <div class="tl-story-caption__text">Top Trainingsbedingungen, bestes Sommerwetter und jede Menge Teamspirit. Das Juniorentrainingslager in Zuchwil startet mit vollem Programm.</div>
          </div>
        </div>

        <div class="tl-story-item tl-reveal tl-reveal-delay-1">
          <div class="tl-story-photo">
            <img src="<?php echo esc_url( $up . 'tl_ig_2.jpg' ); ?>" alt="Junioren Training FC Schattdorf">
          </div>
          <div class="tl-story-caption">
            <div class="tl-story-caption__title">Zweimal täglich auf dem Platz</div>
            <div class="tl-story-caption__text">Morgens und nachmittags wird trainiert – Technik, Taktik und Spielfreude stehen im Mittelpunkt. Unsere Coaches begleiten euch durch jede Einheit.</div>
          </div>
        </div>

        <div class="tl-story-item tl-reveal tl-reveal-delay-2">
          <div class="tl-story-photo">
            <img src="<?php echo esc_url( $up . 'tl_ig_3.jpg' ); ?>" alt="Abkühlung im Pool">
          </div>
          <div class="tl-story-caption">
            <div class="tl-story-caption__title">Abkühlung nach dem Training</div>
            <div class="tl-story-caption__text">Nach dem Sport gehört die Zeit euch – das Freibad auf dem Campus mit Wasserrutsche sorgt für die perfekte Erholung und unvergessliche Momente.</div>
          </div>
        </div>

        <div class="tl-story-item tl-reveal tl-reveal-delay-3">
          <div class="tl-story-photo">
            <img src="<?php echo esc_url( $up . 'tl_ig_4.jpg' ); ?>" alt="FC Schattdorf Junioren Teamgeist">
          </div>
          <div class="tl-story-caption">
            <div class="tl-story-caption__title">Teamgeist & Freundschaft</div>
            <div class="tl-story-caption__text">Fussballtennis, Minigolf und gemeinsame Abende – das Abendprogramm schweisst zusammen. Stimmung garantiert: 10/10!</div>
          </div>
        </div>

      </div>
    </div>
  </section>

  <!-- ══════════════════════════════════════════
       CAMPUS
  ══════════════════════════════════════════ -->
  <section class="tl-section tl-section--dark">
    <div class="tl-inner">
      <div class="tl-tag tl-reveal">Trainingsstandort</div>
      <h2 class="tl-heading tl-reveal tl-reveal-delay-1">Campus <em>Zuchwil</em></h2>

      <div class="tl-campus-grid">

        <div class="tl-campus-card tl-reveal">
          <span class="tl-campus-card__icon">⚽</span>
          <div class="tl-campus-card__title">Fussballplätze</div>
          <div class="tl-campus-card__text">Topgepflegte Rasenplätze für zwei tägliche Trainingseinheiten – genügend Platz für alle Juniorenteams gleichzeitig.</div>
        </div>

        <div class="tl-campus-card tl-reveal tl-reveal-delay-1">
          <span class="tl-campus-card__icon">🏊</span>
          <div class="tl-campus-card__title">Freibad mit Rutsche</div>
          <div class="tl-campus-card__text">Das Freibad direkt auf dem Gelände bietet nach dem Training die perfekte Abkühlung – mit Wasserrutschbahn für alle.</div>
        </div>

        <div class="tl-campus-card tl-reveal tl-reveal-delay-2">
          <span class="tl-campus-card__icon">🛏️</span>
          <div class="tl-campus-card__title">Unterkunft</div>
          <div class="tl-campus-card__text">Komfortable Schlafsäle direkt auf dem Gelände – alle Spieler wohnen zusammen und erleben echtes Lagerfeeling.</div>
        </div>

        <div class="tl-campus-card tl-reveal tl-reveal-delay-1">
          <span class="tl-campus-card__icon">👨‍🍳</span>
          <div class="tl-campus-card__title">Professionelle Küche</div>
          <div class="tl-campus-card__text">Ausgebildete Köche bereiten täglich drei frische Mahlzeiten zu – ausgewogen, abwechslungsreich und auf junge Sportler abgestimmt.</div>
        </div>

        <div class="tl-campus-card tl-reveal tl-reveal-delay-2">
          <span class="tl-campus-card__icon">🏓</span>
          <div class="tl-campus-card__title">Freizeitanlagen</div>
          <div class="tl-campus-card__text">Tischtennis, Fussballtennis, Minigolf und mehr. Das Abendprogramm sorgt für Teamgeist und Spass abseits des Platzes.</div>
        </div>

        <div class="tl-campus-card tl-reveal tl-reveal-delay-3">
          <span class="tl-campus-card__icon">📍</span>
          <div class="tl-campus-card__title">Lage Zuchwil</div>
          <div class="tl-campus-card__text">Im Kanton Solothurn, gut erreichbar mit Auto und öffentlichem Verkehr. Anreise-Details werden nach der Anmeldung kommuniziert.</div>
        </div>

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

        <div class="tl-program-item tl-reveal">
          <div class="tl-program-item__icon">🌅</div>
          <div class="tl-program-item__body">
            <div class="tl-program-item__label">Morgen · täglich</div>
            <div class="tl-program-item__title">Morgentraining</div>
            <div class="tl-program-item__desc">Jeden Morgen steht die erste Trainingseinheit auf dem Programm – mit Fokus auf Technik, Koordination und taktische Grundlagen. Unsere Coaches begleiten euch durch gezielte Übungen und Spielformen.</div>
          </div>
        </div>

        <div class="tl-program-item tl-reveal tl-reveal-delay-1">
          <div class="tl-program-item__icon">🍳</div>
          <div class="tl-program-item__body">
            <div class="tl-program-item__label">3× täglich</div>
            <div class="tl-program-item__title">Frühstück, Mittag & Abendessen</div>
            <div class="tl-program-item__desc">Täglich dreimal frisch und ausgewogen bekocht von professionellen Köchen – Frühstück als Energiestart, Mittagessen zur Erholung nach dem Training, Abendessen für die Regeneration. Wechselnde Menüs, kein Tag wie der andere.</div>
          </div>
        </div>

        <div class="tl-program-item tl-reveal tl-reveal-delay-2">
          <div class="tl-program-item__icon">⚽</div>
          <div class="tl-program-item__body">
            <div class="tl-program-item__label">Nachmittag · täglich</div>
            <div class="tl-program-item__title">Nachmittagstraining</div>
            <div class="tl-program-item__desc">Die zweite Trainingseinheit am Nachmittag steht im Zeichen des Spiels – Wettkämpfe, Spielformen und jede Menge Ball. Hier zeigt sich, was am Morgen gelernt wurde.</div>
          </div>
        </div>

        <div class="tl-program-item tl-reveal tl-reveal-delay-1">
          <div class="tl-program-item__icon">🤝</div>
          <div class="tl-program-item__body">
            <div class="tl-program-item__label">Freizeit</div>
            <div class="tl-program-item__title">Spass mit Freunden</div>
            <div class="tl-program-item__desc">Nach dem Training gehört die Zeit euch. Pool mit Wasserrutsche, Tischtennis, Fussballtennis, Minigolf – das Freizeitprogramm sorgt für neue Freundschaften und unvergessliche Momente abseits des Platzes.</div>
          </div>
        </div>

        <div class="tl-program-item tl-program-item--red tl-reveal tl-reveal-delay-2">
          <div class="tl-program-item__icon">🏆</div>
          <div class="tl-program-item__body">
            <div class="tl-program-item__label">Letzter Tag · Highlight</div>
            <div class="tl-program-item__title">Abschlussturnier</div>
            <div class="tl-program-item__desc">Der krönende Abschluss der Woche: Alle Teams treten gegeneinander an – volles Programm, voller Einsatz, grosses Finale. Das Abschlussturnier ist der Höhepunkt jedes Trainingslagers.</div>
          </div>
        </div>

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
          <img src="<?php echo esc_url( $up . 'IMG_8904.jpg' ); ?>" alt="Trainingslager Flyer FC Schattdorf">
        </div>
        <div class="tl-reveal tl-reveal-delay-2">
          <div class="tl-tag">Flyer & Infos</div>
          <h2 class="tl-heading">Alles auf<br><em>einen Blick</em></h2>
          <p style="font-size:1.0625rem;color:#6b7280;line-height:1.75;margin:0 0 2rem">
            Im Flyer findest du alle wichtigen Informationen zum Juniorentrainingslager 2026 – Programm, Kosten, Unterkunft und Anmeldedetails kompakt zusammengefasst.
          </p>
          <a href="https://www.fcschattdorf.ch/anmeldung-juniorentrainingslager"
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
        <p class="tl-cta-lead">Melde dich jetzt an und sichere dir deinen Platz am Juniorentrainingslager des FC Schattdorf. Plätze sind begrenzt!</p>
        <a href="https://www.fcschattdorf.ch/anmeldung-juniorentrainingslager"
           class="tl-cta-btn" target="_blank" rel="noopener">
          Jetzt anmelden
          <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24">
            <path d="M5 12h14M12 5l7 7-7 7"/>
          </svg>
        </a>

        <div class="tl-contacts">
          <div class="tl-contact-person">
            <div class="tl-contact-person__name">Sandro Zamuner</div>
            <div class="tl-contact-person__detail">
              Organisator TL Zuchwil<br>
              <a href="tel:+41792807720">079 280 77 20</a>
            </div>
          </div>
          <div class="tl-contact-person">
            <div class="tl-contact-person__name">René Gnos</div>
            <div class="tl-contact-person__detail">
              Organisator TL Zuchwil<br>
              <a href="tel:+41794206120">079 420 61 20</a>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>

</div>

<?php get_footer(); ?>
