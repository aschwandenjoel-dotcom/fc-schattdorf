<?php
/**
 * Front-Page – FC Schattdorf
 * News-First-Startseite: Hero-Story, grosser News-Feed, Spielbetrieb-Band,
 * prominenter Sponsoren-Bereich, Claim, Footer.
 * Inhalte (Texte, Bilder, Links, PDFs) bleiben unverändert – nur Form/Anordnung.
 */
if ( ! defined( 'ABSPATH' ) ) { exit; }

/* ── Helfer: URL einer Seite per Pfad (hierarchisch) ─────────────── */
if ( ! function_exists( 'fcsh_page_url' ) ) {
	function fcsh_page_url( $path, $fallback = '' ) {
		$p = get_page_by_path( $path );
		return $p ? get_permalink( $p ) : ( $fallback !== '' ? $fallback : home_url( '/' ) );
	}
}
/* ── Helfer: Team-Tag aus Kategorie ──────────────────────────────── */
if ( ! function_exists( 'fcsh_team_tag' ) ) {
	function fcsh_team_tag( $post_id ) {
		$cats = get_the_category( $post_id );
		if ( ! empty( $cats ) ) {
			foreach ( $cats as $c ) {
				if ( strtolower( $c->name ) !== 'allgemein' && strtolower( $c->name ) !== 'uncategorized' ) {
					return $c->name;
				}
			}
		}
		return 'FCS I';
	}
}

$theme_uri = get_stylesheet_directory_uri();
$img       = $theme_uri . '/assets/img';
$up        = wp_upload_dir()['baseurl'] . '/2026/06/';

/* ── News laden ──────────────────────────────────────────────────── */
$news_q = new WP_Query( array(
	'post_type'           => 'post',
	'post_status'         => 'publish',
	'posts_per_page'      => 5,
	'ignore_sticky_posts' => true,
) );
$news = $news_q->posts;

$fallback_imgs = array(
	$img . '/fcs1-web.jpg',
	$img . '/fcs2-web.jpg',
	$img . '/aa-junioren-2526.jpg',
	$img . '/cb-junioren-2526.jpg',
);

/* Aufbereitung: Bild/URL/Tag/Datum je Beitrag */
$items = array();
foreach ( $news as $i => $p ) {
	$thumb = get_the_post_thumbnail_url( $p->ID, 'full' );
	if ( ! $thumb ) { $thumb = $fallback_imgs[ $i % count( $fallback_imgs ) ]; }
	$items[] = array(
		'id'    => $p->ID,
		'title' => get_the_title( $p ),
		'url'   => get_permalink( $p ),
		'img'   => $thumb,
		'date'  => get_the_date( 'd.m.Y', $p ),
		'tag'   => fcsh_team_tag( $p->ID ),
		'teaser'=> wp_trim_words( wp_strip_all_tags( $p->post_content ), 32 ),
	);
}
/* Wunsch: die Startseite führt immer nur die neuste Story im Hero. */
$slides = array_slice( $items, 0, 1 );

/* Hero-Daten für JS */
$hero_json = array();
foreach ( $slides as $s ) {
	$hero_json[] = array( 'tag' => $s['tag'], 'date' => $s['date'], 'title' => $s['title'], 'url' => $s['url'] );
}

/* ── Events laden (eigener fcs_event-CPT – gepflegt im Admin unter
   «Events», dieselbe Quelle wie die /events/-Seite). Nur kommende
   Termine, max. 4. Keine hartkodierten Inhalte mehr. ─────────────── */
$events = array();
if ( function_exists( 'fcs_get_events' ) ) {
	$upper = function_exists( 'mb_strtoupper' ) ? 'mb_strtoupper' : 'strtoupper';
	foreach ( fcs_get_events( true, 4 ) as $ev ) {
		if ( empty( $ev['datum'] ) ) {
			continue;
		}
		$events[] = array(
			'day'   => $ev['datum']['tag'],
			'mon'   => $upper( $ev['datum']['mon_kurz'] ),
			'full'  => $ev['datum']['dmy'],
			'title' => $ev['titel'],
			'loc'   => $ev['ort_kurz'],
			'url'   => fcsh_page_url( 'events' ) . '#ev-' . $ev['id'],
		);
	}
}

/* ── Navigation (auf echte WP-Seiten gemappt) ────────────────────── */
$nav = array(
	array( 'label' => 'Home', 'href' => home_url( '/' ), 'active' => true ),
	array( 'label' => 'News', 'href' => fcsh_page_url( 'news', home_url( '/news/' ) ) ),
	array( 'label' => 'Verein', 'children' => array(
		array( 'Portrait', fcsh_page_url( 'verein' ) ),
		array( 'Vorstand', fcsh_page_url( 'verein/vorstand', fcsh_page_url( 'vorstand' ) ) ),
		array( 'Mitglied werden', fcsh_page_url( 'verein/mitglied-werden', fcsh_page_url( 'mitglied-werden' ) ) ),
		array( 'Fanshop', fcsh_page_url( 'verein/fanshop', fcsh_page_url( 'fanshop' ) ) ),
		array( 'Schiedsrichter', fcsh_page_url( 'verein/schiedsrichter', fcsh_page_url( 'schiedsrichter' ) ) ),
		array( 'Ehrenmitglieder', fcsh_page_url( 'verein/ehrenmitglieder', fcsh_page_url( 'ehrenmitglieder' ) ) ),
		array( 'Vereinsgeschichte', fcsh_page_url( 'verein/vereinsgeschichte', fcsh_page_url( 'vereinsgeschichte' ) ) ),
		array( 'So finden Sie uns', fcsh_page_url( 'verein/anfahrt', fcsh_page_url( 'anfahrt' ) ) ),
		array( 'Vorfall melden', fcsh_page_url( 'verein/vorfall-melden', fcsh_page_url( 'vorfall-melden' ) ) ),
	) ),
	array( 'label' => 'Helfereinsätze', 'href' => fcsh_page_url( 'helfereinsaetze' ) ),
	array( 'label' => 'Aktive', 'children' => array(
		array( '1. Mannschaft', fcsh_page_url( 'aktive/1-mannschaft', fcsh_page_url( '1-mannschaft' ) ) ),
		array( '2. Mannschaft', fcsh_page_url( 'aktive/2-mannschaft', fcsh_page_url( '2-mannschaft' ) ) ),
		array( '3. Mannschaft', fcsh_page_url( 'aktive/3-mannschaft', fcsh_page_url( '3-mannschaft' ) ) ),
		array( 'Frauen Uri I', fcsh_page_url( 'aktive/frauen-uri-1', fcsh_page_url( 'frauen-uri-1' ) ) ),
		array( 'Frauen Uri II', fcsh_page_url( 'aktive/frauen-uri-2', fcsh_page_url( 'frauen-uri-2' ) ) ),
		array( 'Senioren Uri I', fcsh_page_url( 'aktive/senioren-uri-1', fcsh_page_url( 'senioren-uri-1' ) ) ),
	) ),
	array( 'label' => 'Junioren', 'children' => array(
		array( 'Juniorengeschichte', fcsh_page_url( 'junioren/juniorengeschichte', fcsh_page_url( 'juniorengeschichte' ) ) ),
		array( 'Organisation', fcsh_page_url( 'junioren/junioren-organisation', fcsh_page_url( 'junioren-organisation' ) ) ),
		array( 'Teams', fcsh_page_url( 'junioren/teams', fcsh_page_url( 'teams' ) ) ),
		array( 'Goalietraining', fcsh_page_url( 'junioren/goalietraining', fcsh_page_url( 'goalietraining' ) ) ),
		array( 'Fussballschule', fcsh_page_url( 'junioren/fussballschule', fcsh_page_url( 'fussballschule' ) ) ),
		array( 'Trainingslager', fcsh_page_url( 'junioren/trainingslager', fcsh_page_url( 'trainingslager' ) ) ),
		array( 'Betreuer werden', fcsh_page_url( 'junioren/betreuer-werden', fcsh_page_url( 'betreuer-werden' ) ) ),
	) ),
	array( 'label' => 'Events', 'children' => array(
		array( 'Alle Events', fcsh_page_url( 'events' ) ),
		array( 'Dorf- & Grümpelturnier', fcsh_page_url( 'gruempelturnier', fcsh_page_url( 'events' ) ) ),
	) ),
	array( 'label' => 'Sponsoren', 'href' => fcsh_page_url( 'sponsoren' ) ),
	array( 'label' => 'Kontakt', 'href' => fcsh_page_url( 'kontakt' ) ),
);

/* ── IFV-Links ───────────────────────────────────────────────────── */
$ifv = array(
	array( 'label' => 'Tabelle',          'sub' => '1. Mannschaft', 'url' => 'https://matchcenter.ifv.ch/default.aspx?v=329&oid=7&lng=1&t=30614&a=trr' ),
	array( 'label' => 'Spielplan',        'sub' => '1. Mannschaft', 'url' => 'https://matchcenter.ifv.ch/default.aspx?oid=7&lng=1&v=329&t=30614&ls=24454&sg=67609&a=pt' ),
	array( 'label' => 'Spielbetrieb FCS', 'sub' => 'alle Teams',    'url' => 'https://www.ifv.ch/Innerschweizerischer-Fussballverband/Vereine-IFV/Verein-IFV.aspx/v-329/a-as/' ),
	array( 'label' => 'Liveticker',       'sub' => '1. Mannschaft', 'url' => 'https://cdn.tickaroo.com/embed/v4/fullpage/6375c4e2a76a60b2e34cff9b/fploTWVBarsiJF_29Yb6AUcSQeq7pY.html' ),
);

/* ── Sponsoren-Gruppen ───────────────────────────────────────────── */
$sponsor_groups = array(
	array( 'label' => 'Hauptsponsor', 'items' => array(
		array( 'img' => $up . 'muoser-gray.png',            'img_color' => $up . 'muoser-color.png',            'name' => 'Muoser',            'url' => 'https://www.muoser.ch/' ),
	)),
	array( 'label' => 'Nachwuchs-Patronat', 'items' => array(
		array( 'img' => $up . 'GAMMA_4in1_CMYK.png',        'img_color' => $up . 'gamma-color-transparent.png', 'name' => 'GAMMA',             'url' => 'https://www.gamma-holding.ch/' ),
	)),
	array( 'label' => 'Co-Sponsoren', 'items' => array(
		array( 'img' => $up . 'herger-kuechen-gray.png',    'img_color' => $up . 'sp-herger-kuechen-transparent.png', 'name' => 'Herger Küchen AG',  'url' => 'https://herger-kuechen.ch/' ),
		array( 'img' => $up . 'brand-automobile-gray.png',  'img_color' => $up . 'brand-automobile-color.png',  'name' => 'Brand Automobile',  'url' => 'https://www.brand-automobile.ch/' ),
		array( 'img' => $up . 'imholz-sport-gray.png',      'img_color' => $up . 'imholz-sport-color-transparent.png', 'name' => 'Sport Imholz',      'url' => 'http://imholzsport.ch/' ),
		array( 'img' => $up . 'Cash.png',                   'img_color' => $up . 'Cash.png',                    'name' => 'cash.',              'url' => 'https://cashsport.ch/' ),
	)),
	array( 'label' => 'Club-Sponsoren', 'items' => array(
		array( 'img' => $up . 'gasthausbrueckli-gray.png',  'img_color' => $up . 'gasthaus-brueckli-color.jpg', 'name' => 'Gasthaus Brückli',  'url' => 'https://www.brueckli.ch/', 'height' => '72px' ),
	)),
	array( 'label' => 'Nachwuchs-Sponsoren', 'items' => array(
		array( 'img' => $up . 'ewa-gray.png',               'img_color' => $up . 'ewa-color.svg',               'name' => 'EWA energieUri',    'url' => 'https://www.energieuri.ch/' ),
		array( 'img' => $up . 'logo_ukb-gray.png',          'img_color' => $up . 'ukb-color.svg',               'name' => 'Urner Kantonalbank','url' => 'https://www.ukb.ch' ),
		array( 'img' => $up . 'arnold-color.svg',           'img_color' => $up . 'arnold-color.svg',            'name' => 'Arnold AG',         'url' => 'https://www.arnoldag.ch/' ),
		array( 'img' => $up . 'zahnarztpraxisuri-gray.png', 'img_color' => $up . 'zahnarzt-color.png',          'name' => 'Zahnarzt-URI.ch',   'url' => 'https://zahnarzt-uri.ch/' ),
	)),
);

$logo_svg = $img . '/fcs-logo.svg';
$ver = file_exists( get_stylesheet_directory() . '/assets/fcs-home.css' ) ? filemtime( get_stylesheet_directory() . '/assets/fcs-home.css' ) : '1';
$ver_front = file_exists( get_stylesheet_directory() . '/assets/fcs-front.css' ) ? filemtime( get_stylesheet_directory() . '/assets/fcs-front.css' ) : '1';
$ver_js = file_exists( get_stylesheet_directory() . '/assets/fcs-home.js' ) ? filemtime( get_stylesheet_directory() . '/assets/fcs-home.js' ) : '1';

/* Sponsoren: Hauptsponsor als eigener, grosser Block vor den übrigen Gruppen */
$sponsor_lead = array_shift( $sponsor_groups );
?><!DOCTYPE html>
<html <?php language_attributes(); ?>>
<head>
<meta charset="<?php bloginfo( 'charset' ); ?>">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
<link rel="stylesheet" href="<?php echo esc_url( $theme_uri . '/assets/fcs-home.css?v=' . $ver ); ?>">
<link rel="stylesheet" href="<?php echo esc_url( $theme_uri . '/assets/fcs-front.css?v=' . $ver_front ); ?>">
<?php wp_head(); ?>
</head>
<body <?php body_class( 'fcsh' ); ?>>

<?php fcsh_render_site_header(); ?>

<!-- ══ OVERLAY-MENÜ ══ -->
<div class="fcsh-overlay">
	<div class="fcsh-overlay__top">
		<a href="<?php echo esc_url( home_url( '/' ) ); ?>"><img src="<?php echo esc_url( $logo_svg ); ?>" alt="FC Schattdorf"></a>
		<button class="fcsh-close" data-fcsh-menu-close>
			<span>SCHLIESSEN</span>
			<svg viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg>
		</button>
	</div>
	<nav class="fcsh-overlay__nav">
		<div class="fcsh-overlay__grid">
			<?php foreach ( $nav as $item ) : ?>
				<?php
				$active_class = ! empty( $item['active'] ) ? ' fcsh-mitem--active' : '';
			?>
				<?php if ( ! empty( $item['children'] ) ) : ?>
					<div class="fcsh-mitem<?php echo $active_class; ?>">
						<button data-fcsh-section>
							<?php echo esc_html( $item['label'] ); ?>
							<svg class="fcsh-mitem__chev" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"/></svg>
						</button>
						<div class="fcsh-mitem__sub">
							<?php foreach ( $item['children'] as $c ) : ?>
								<a href="<?php echo esc_url( $c[1] ); ?>">→ <?php echo esc_html( $c[0] ); ?></a>
							<?php endforeach; ?>
						</div>
					</div>
				<?php else : ?>
					<div class="fcsh-mitem<?php echo $active_class; ?>"><a href="<?php echo esc_url( $item['href'] ); ?>"><?php echo esc_html( $item['label'] ); ?></a></div>
				<?php endif; ?>
			<?php endforeach; ?>
		</div>
	</nav>
	<div class="fcsh-overlay__foot">
		<a href="https://www.facebook.com/fcschattdorf.ch/" target="_blank" rel="noopener">Facebook</a>
		<a href="https://www.instagram.com/fcschattdorf1933/" target="_blank" rel="noopener">Instagram</a>
		<a href="https://matchcenter.ifv.ch" target="_blank" rel="noopener">IFV Matchcenter</a>
		<span>© <?php echo esc_html( date( 'Y' ) ); ?> FC Schattdorf</span>
	</div>
</div>

<!-- ══ HERO-SLIDER ══ -->
<section class="fcsh-hero">
	<?php foreach ( $slides as $s ) : ?>
		<div class="fcsh-hero__slide" style="background-image:url('<?php echo esc_url( $s['img'] ); ?>')"></div>
	<?php endforeach; ?>
	<div class="fcsh-hero__overlay"></div>
	<div class="fcsh-hero__content">
		<div class="fcsh-hero__inner">
			<div class="fcsh-hero__meta">
				<span class="fcsh-hero__date" data-hero-date></span>
			</div>
			<a data-hero-link href="#"><h1 class="fcsh-hero__title" data-hero-title></h1></a>
			<?php if ( count( $slides ) > 1 ) : ?>
			<div class="fcsh-hero__controls">
				<button type="button" class="fcsh-arrow" data-hero-prev aria-label="Vorherige Story">
					<svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M15 19l-7-7 7-7"/></svg>
				</button>
				<button type="button" class="fcsh-arrow" data-hero-next aria-label="Nächste Story">
					<svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M9 5l7 7-7 7"/></svg>
				</button>
				<span class="fcsh-hero__count" data-hero-count></span>
			</div>
			<?php endif; ?>
		</div>
	</div>
	<div class="fcsh-hero__sponsor">
		<div style="text-align:right">
			<p class="lbl">Hauptsponsor</p>
			<p class="name">MUOSER</p>
		</div>
		<div class="fcsh-hero__socials">
			<a href="https://www.facebook.com/fcschattdorf.ch/" target="_blank" rel="noopener"><svg width="20" height="20" fill="currentColor" viewBox="0 0 24 24"><path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"/></svg></a>
			<a href="https://www.instagram.com/fcschattdorf1933/" target="_blank" rel="noopener"><svg width="20" height="20" fill="currentColor" viewBox="0 0 24 24"><path d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zm0-2.163c-3.259 0-3.667.014-4.947.072-4.358.2-6.78 2.618-6.98 6.98-.059 1.281-.073 1.689-.073 4.948 0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98 1.281.058 1.689.072 4.948.072 3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98-1.281-.059-1.69-.073-4.949-.073zm0 5.838c-3.403 0-6.162 2.759-6.162 6.162s2.759 6.163 6.162 6.163 6.162-2.759 6.162-6.163c0-3.403-2.759-6.162-6.162-6.162zm0 10.162c-2.209 0-4-1.79-4-4 0-2.209 1.791-4 4-4s4 1.791 4 4c0 2.21-1.791 4-4 4zm6.406-11.845c-.796 0-1.441.645-1.441 1.44s.645 1.44 1.441 1.44c.795 0 1.439-.645 1.439-1.44s-.644-1.44-1.439-1.44z"/></svg></a>
		</div>
	</div>
</section>
<script type="application/json" id="fcsh-hero-data"><?php echo wp_json_encode( $hero_json ); ?></script>

<!-- ══ SPONSORENBALKEN direkt unter dem Titelbild ══ -->
<?php
/* Alle Sponsoren in einer Reihe – der Hauptsponsor zuerst. */
$sponsor_strip = array();
if ( $sponsor_lead ) {
	foreach ( $sponsor_lead['items'] as $sp ) { $sponsor_strip[] = $sp; }
}
foreach ( $sponsor_groups as $g ) {
	foreach ( $g['items'] as $sp ) { $sponsor_strip[] = $sp; }
}
?>
<?php if ( ! empty( $sponsor_strip ) ) : ?>
<aside class="fcx-spbar" aria-label="Sponsoren des FC Schattdorf">
	<div class="fcx-spbar__track">
		<?php foreach ( $sponsor_strip as $sp ) : ?>
			<a class="fcx-spbar__item" href="<?php echo esc_url( $sp['url'] ); ?>" target="_blank" rel="noopener noreferrer">
				<img src="<?php echo esc_url( $sp['img'] ); ?>" alt="<?php echo esc_attr( $sp['name'] ); ?>" loading="lazy">
			</a>
		<?php endforeach; ?>
	</div>
</aside>
<?php endif; ?>

<!-- ══ TERMINE + SPIELBETRIEB: direkt unter dem Hero ══ -->
<section id="inhalt" class="fcx-sec fcx-agenda">
	<div class="fcx-sechead">
		<div>
			<h2 class="fcx-h2">Termine &amp; Spielbetrieb</h2>
		</div>
		<a class="fcx-btn" href="<?php echo esc_url( fcsh_page_url( 'events' ) ); ?>">Weitere Termine
			<svg viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M9 5l7 7-7 7"/></svg>
		</a>
	</div>

	<div class="fcx-band">
		<div class="fcx-termine">
			<?php if ( empty( $events ) ) : ?>
				<p class="fcx-event__empty">Zurzeit sind keine Termine erfasst.</p>
			<?php else : ?>
			<?php foreach ( $events as $e ) : ?>
				<a class="fcx-event" href="<?php echo esc_url( $e['url'] ); ?>">
					<span class="fcx-event__date">
						<span class="fcx-event__day"><?php echo esc_html( $e['day'] ); ?></span>
						<span class="fcx-event__mon"><?php echo esc_html( $e['mon'] ); ?></span>
					</span>
					<span class="fcx-event__body">
						<span class="fcx-event__title"><?php echo esc_html( $e['title'] ); ?></span>
						<?php if ( ! empty( $e['loc'] ) ) : ?><span class="fcx-event__loc"><?php echo esc_html( $e['loc'] ); ?></span><?php endif; ?>
						<span class="fcx-event__full"><?php echo esc_html( $e['full'] ); ?></span>
					</span>
				</a>
			<?php endforeach; ?>
			<?php endif; ?>
		</div>

		<div class="fcx-spielbetrieb">
			<p class="fcx-spielbetrieb__lbl">Spielbetrieb IFV</p>
			<div class="fcx-tiles">
				<?php foreach ( $ifv as $ifv_item ) : ?>
					<a class="fcx-tile" href="<?php echo esc_url( $ifv_item['url'] ); ?>" target="_blank" rel="noopener">
						<span class="fcx-tile__txt">
							<span class="fcx-tile__lbl"><?php echo esc_html( $ifv_item['label'] ); ?></span>
							<?php if ( ! empty( $ifv_item['sub'] ) ) : ?><span class="fcx-tile__sub"><?php echo esc_html( $ifv_item['sub'] ); ?></span><?php endif; ?>
						</span>
						<svg viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14"/></svg>
					</a>
				<?php endforeach; ?>
			</div>
		</div>
	</div>
</section>

<!-- ══ SPONSOREN ══ -->
<section class="fcx-sec fcx-sec--mist fcx-sponsors">
	<div class="fcx-sechead">
		<div>
			<h2 class="fcx-h2">Unsere Sponsoren</h2>
		</div>
		<a class="fcx-btn" href="<?php echo esc_url( fcsh_page_url( 'sponsoren' ) ); ?>">Alle Sponsoren
			<svg viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M9 5l7 7-7 7"/></svg>
		</a>
	</div>

	<?php if ( $sponsor_lead ) : ?>
		<div class="fcx-spgroup fcx-spgroup--lead" style="margin-top:clamp(2rem,4vw,3rem)">
			<p class="fcx-spgroup__lbl"><?php echo esc_html( $sponsor_lead['label'] ); ?></p>
			<div class="fcx-spgroup__items">
				<?php foreach ( $sponsor_lead['items'] as $sp ) : ?>
					<a class="fcx-spgroup__item" href="<?php echo esc_url( $sp['url'] ); ?>" target="_blank" rel="noopener noreferrer">
						<img src="<?php echo esc_url( $sp['img_color'] ?? $sp['img'] ); ?>" alt="<?php echo esc_attr( $sp['name'] ); ?>" loading="lazy">
					</a>
				<?php endforeach; ?>
			</div>
		</div>
	<?php endif; ?>

	<?php foreach ( $sponsor_groups as $g ) : ?>
		<div class="fcx-spgroup">
			<p class="fcx-spgroup__lbl"><?php echo esc_html( $g['label'] ); ?></p>
			<div class="fcx-spgroup__items">
				<?php foreach ( $g['items'] as $sp ) : ?>
					<a class="fcx-spgroup__item" href="<?php echo esc_url( $sp['url'] ); ?>" target="_blank" rel="noopener noreferrer">
						<img src="<?php echo esc_url( $sp['img_color'] ?? $sp['img'] ); ?>" alt="<?php echo esc_attr( $sp['name'] ); ?>" loading="lazy"<?php if ( ! empty( $sp['height'] ) ) echo ' style="height:' . esc_attr( $sp['height'] ) . '"'; ?>>
					</a>
				<?php endforeach; ?>
			</div>
		</div>
	<?php endforeach; ?>
</section>

<!-- ══ PARALLAX-BAND ══ -->
<section class="fcsh-parallax">
	<div class="fcsh-parallax__txt">
		<p>FC Schattdorf</p>
		<h2>Seit 1933 für unsere Zukunft<br>am Ball</h2>
	</div>
</section>

<!-- ══ FOOTER ══ -->
<footer class="fcx-foot">
	<div class="fcx-foot__main">
		<div>
			<div class="fcx-foot__logo">
				<a href="<?php echo esc_url( home_url( '/' ) ); ?>"><img src="<?php echo esc_url( $logo_svg ); ?>" alt="FC Schattdorf"></a>
			</div>
			<p class="fcx-foot__claim">Seit 1933 für unsere Zukunft am Ball.</p>
			<div class="fcx-foot__social">
				<a href="https://www.facebook.com/fcschattdorf.ch/" target="_blank" rel="noopener" aria-label="Facebook"><svg width="18" height="18" fill="currentColor" viewBox="0 0 24 24"><path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"/></svg></a>
				<a href="https://www.instagram.com/fcschattdorf1933/" target="_blank" rel="noopener" aria-label="Instagram"><svg width="18" height="18" fill="currentColor" viewBox="0 0 24 24"><path d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zm0-2.163c-3.259 0-3.667.014-4.947.072-4.358.2-6.78 2.618-6.98 6.98-.059 1.281-.073 1.689-.073 4.948 0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98 1.281.058 1.689.072 4.948.072 3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98-1.281-.059-1.69-.073-4.949-.073zm0 5.838c-3.403 0-6.162 2.759-6.162 6.162s2.759 6.163 6.162 6.163 6.162-2.759 6.162-6.163c0-3.403-2.759-6.162-6.162-6.162zm0 10.162c-2.209 0-4-1.79-4-4 0-2.209 1.791-4 4-4s4 1.791 4 4c0 2.21-1.791 4-4 4zm6.406-11.845c-.796 0-1.441.645-1.441 1.44s.645 1.44 1.441 1.44c.795 0 1.439-.645 1.439-1.44s-.644-1.44-1.439-1.44z"/></svg></a>
			</div>
		</div>

		<div class="fcx-foot__nav">
			<div class="fcx-foot__col">
				<h3>Verein</h3>
				<a href="<?php echo esc_url( fcsh_page_url( 'verein/vorstand', fcsh_page_url( 'vorstand' ) ) ); ?>">Vorstand</a>
				<a href="<?php echo esc_url( fcsh_page_url( 'verein/mitglied-werden', fcsh_page_url( 'mitglied-werden' ) ) ); ?>">Mitglied werden</a>
				<a href="<?php echo esc_url( fcsh_page_url( 'verein/fanshop', fcsh_page_url( 'fanshop' ) ) ); ?>">Fanshop</a>
				<a href="<?php echo esc_url( fcsh_page_url( 'verein/anfahrt', fcsh_page_url( 'anfahrt' ) ) ); ?>">So finden Sie uns</a>
			</div>
			<div class="fcx-foot__col">
				<h3>Sport</h3>
				<a href="<?php echo esc_url( fcsh_page_url( 'news' ) ); ?>">News</a>
				<a href="<?php echo esc_url( fcsh_page_url( 'aktive' ) ); ?>">Aktive</a>
				<a href="<?php echo esc_url( fcsh_page_url( 'junioren' ) ); ?>">Junioren</a>
				<a href="<?php echo esc_url( fcsh_page_url( 'events' ) ); ?>">Events</a>
			</div>
			<div class="fcx-foot__col">
				<h3>Mitmachen</h3>
				<a href="<?php echo esc_url( fcsh_page_url( 'helfereinsaetze' ) ); ?>">Helfereinsätze</a>
				<a href="<?php echo esc_url( fcsh_page_url( 'sponsoren' ) ); ?>">Sponsoren</a>
				<a href="<?php echo esc_url( fcsh_page_url( 'kontakt' ) ); ?>">Kontakt</a>
				<a href="<?php echo esc_url( wp_login_url() ); ?>">Login</a>
			</div>
			<div class="fcx-foot__col">
				<h3>Newsletter</h3>
				<?php /* Mailchimp-Anmeldung (Original-URL von fcschattdorf.ch) – gleiche URL wie footer.php */ ?>
				<a href="https://us16.list-manage.com/subscribe?u=e95f0901b53137263a8b4fdd3&amp;id=ed86c0b0f5" target="_blank" rel="noopener noreferrer">Jetzt anmelden</a>
			</div>
		</div>
	</div>

	<div class="fcx-foot__bar">
		<p>© <?php echo esc_html( date( 'Y' ) ); ?> FC Schattdorf</p>
		<div>
			<a href="<?php echo esc_url( fcsh_page_url( 'impressum', '#' ) ); ?>">Impressum</a>
			<a href="<?php echo esc_url( fcsh_page_url( 'datenschutzerklaerung', home_url( '/datenschutzerklaerung/' ) ) ); ?>">Datenschutz</a>
		</div>
	</div>
</footer>

<script src="<?php echo esc_url( $theme_uri . '/assets/fcs-home.js?v=' . $ver_js ); ?>"></script>
<?php wp_footer(); ?>
</body>
</html>
<?php
wp_reset_postdata();
