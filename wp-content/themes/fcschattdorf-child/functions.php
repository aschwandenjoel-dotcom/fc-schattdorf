<?php
/**
 * FC Schattdorf Child-Theme – Funktionen
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

/* ── Module: Inhaltstypen & pflegbare Seitenfelder (inc/fcs-*.php) ──
   Jede Datei ist ein in sich geschlossenes Modul (z. B. Chronik-CPT,
   Seiten-Feldboxen); neue Module werden automatisch geladen. */
foreach ( glob( __DIR__ . '/inc/fcs-*.php' ) as $fcsh_module ) {
	require_once $fcsh_module;
}
unset( $fcsh_module );

/* ── Helfer: URL einer Seite per Pfad ─────────────────────────────── */
if ( ! function_exists( 'fcsh_page_url' ) ) {
	function fcsh_page_url( $path, $fallback = '' ) {
		$p = get_page_by_path( $path );
		return $p ? get_permalink( $p ) : ( $fallback !== '' ? $fallback : home_url( '/' ) );
	}
}

/* ── Helfer: Team-Tag aus Kategorie ───────────────────────────────── */
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

/* ── News-Kontext-Erkennung ───────────────────────────────────────── */
function fcsh_is_news_context() {
	if ( is_singular( 'post' ) || is_home() || is_category() || is_tag() ) {
		return true;
	}
	if ( is_page() ) {
		$page = get_queried_object();
		if ( $page && $page->post_name === 'news' ) {
			return true;
		}
	}
	return false;
}

/* ── Inner-Header-Daten: Sektionsname + Sub-Nav ───────────────────── */
function fcsh_get_inner_header_data() {
	$section_title = '';
	$sub_nav       = array();
	$sub_nav_2     = array();

	if ( fcsh_is_news_context() ) {
		/* News laufen bewusst ohne Filter/Sortierung – ein durchgehender Feed. */
		$section_title = 'News';
	} elseif ( is_page() ) {
		$current_id = get_queried_object_id();
		$ancestors  = get_ancestors( $current_id, 'page' );

		if ( ! empty( $ancestors ) ) {
			/* Kind-Seite: oberstes Elternteil ist Sektion */
			$top_id        = end( $ancestors );
			$section_title = get_the_title( $top_id );
			$children      = get_pages( array(
				'parent'      => $top_id,
				'sort_column' => 'ID',
				'sort_order'  => 'ASC',
				'post_status' => 'publish',
			) );
			foreach ( $children as $child ) {
				$sub_nav[] = array(
					'label'  => get_the_title( $child ),
					'href'   => get_permalink( $child ),
					'active' => ( $child->ID === $current_id || in_array( $child->ID, $ancestors ) ),
				);
			}

			/* Zweite Ebene: Geschwister anzeigen wenn mind. 2 Vorfahren */
			if ( count( $ancestors ) >= 2 ) {
				$parent_id      = $ancestors[0]; // direkter Elternteil
				$siblings       = get_pages( array(
					'parent'      => $parent_id,
					'sort_column' => 'menu_order',
					'sort_order'  => 'ASC',
					'post_status' => 'publish',
				) );
				foreach ( $siblings as $sib ) {
					$sub_nav_2[] = array(
						'label'  => get_the_title( $sib ),
						'href'   => get_permalink( $sib ),
						'active' => ( $sib->ID === $current_id ),
					);
				}
			}
		} else {
			/* Oberste Seite: sie IST die Sektion */
			$section_title = get_the_title( $current_id );
			$children      = get_pages( array(
				'parent'      => $current_id,
				'sort_column' => 'ID',
				'sort_order'  => 'ASC',
				'post_status' => 'publish',
			) );
			foreach ( $children as $child ) {
				$sub_nav[] = array(
					'label'  => get_the_title( $child ),
					'href'   => get_permalink( $child ),
					'active' => false,
				);
			}
		}
	} elseif ( function_exists( 'tribe_is_event' ) && ( is_singular( 'tribe_events' ) || tribe_get_option( 'eventsSlug' ) ) ) {
		$section_title = 'Events';
	} elseif ( is_singular() ) {
		$section_title = get_the_title();
	}

	return array( 'title' => $section_title, 'sub_nav' => $sub_nav, 'sub_nav_2' => $sub_nav_2 );
}

/* Vorab-Berechnung via template_redirect (vor body_class) */
add_action( 'template_redirect', function () {
	global $fcsh_header_data;
	if ( ! is_front_page() ) {
		$fcsh_header_data = fcsh_get_inner_header_data();
	}
} );

/* ── Overlay-Nav-Array ────────────────────────────────────────────── */
function fcsh_get_overlay_nav() {
	$on_news = ( is_home() || is_singular( 'post' ) || is_category() || is_tag() );
	return array(
		array( 'label' => 'Home',          'href' => home_url( '/' ),                                                         'active' => is_front_page() ),
		array( 'label' => 'News',          'href' => fcsh_page_url( 'news', home_url( '/news/' ) ),                            'active' => $on_news ),
		array( 'label' => 'Verein',        'children' => array(
			array( 'Vorstand',          fcsh_page_url( 'verein/vorstand',          fcsh_page_url( 'vorstand' ) ) ),
			array( 'Mitglied werden',   fcsh_page_url( 'verein/mitglied-werden',   fcsh_page_url( 'mitglied-werden' ) ) ),
			array( 'Fanshop',           fcsh_page_url( 'verein/fanshop',           fcsh_page_url( 'fanshop' ) ) ),
			array( 'Schiedsrichter',    fcsh_page_url( 'verein/schiedsrichter',    fcsh_page_url( 'schiedsrichter' ) ) ),
			array( 'Ehrenmitglieder',   fcsh_page_url( 'verein/ehrenmitglieder',   fcsh_page_url( 'ehrenmitglieder' ) ) ),
			array( 'Vereinsgeschichte', fcsh_page_url( 'verein/vereinsgeschichte', fcsh_page_url( 'vereinsgeschichte' ) ) ),
			array( 'So finden Sie uns', fcsh_page_url( 'verein/anfahrt',           fcsh_page_url( 'anfahrt' ) ) ),
			array( 'Vorfall melden',    fcsh_page_url( 'verein/vorfall-melden',    fcsh_page_url( 'vorfall-melden' ) ) ),
		) ),
		array( 'label' => 'Helfereinsätze','href' => fcsh_page_url( 'helfereinsaetze' ) ),
		array( 'label' => 'Aktive',        'children' => array(
			array( '1. Mannschaft',  fcsh_page_url( 'aktive/1-mannschaft',   fcsh_page_url( '1-mannschaft' ) ) ),
			array( '2. Mannschaft',  fcsh_page_url( 'aktive/2-mannschaft',   fcsh_page_url( '2-mannschaft' ) ) ),
			array( '3. Mannschaft',  fcsh_page_url( 'aktive/3-mannschaft',   fcsh_page_url( '3-mannschaft' ) ) ),
			array( 'Frauen Uri I',   fcsh_page_url( 'aktive/frauen-uri-1',   fcsh_page_url( 'frauen-uri-1' ) ) ),
			array( 'Frauen Uri II',  fcsh_page_url( 'aktive/frauen-uri-2',   fcsh_page_url( 'frauen-uri-2' ) ) ),
			array( 'Senioren',       fcsh_page_url( 'aktive/senioren-uri-1', fcsh_page_url( 'senioren-uri-1' ) ) ),
		) ),
		array( 'label' => 'Junioren',      'children' => array(
			array( 'Übersicht',        fcsh_page_url( 'junioren' ) ),
			array( 'Juniorengeschichte', fcsh_page_url( 'junioren/juniorengeschichte', fcsh_page_url( 'juniorengeschichte' ) ) ),
			array( 'Organisation',     fcsh_page_url( 'junioren/junioren-organisation', fcsh_page_url( 'junioren-organisation' ) ) ),
			array( 'Teams',          fcsh_page_url( 'junioren/teams',          fcsh_page_url( 'teams' ) ) ),
			array( 'Goalietraining', fcsh_page_url( 'junioren/goalietraining', fcsh_page_url( 'goalietraining' ) ) ),
			array( 'Fussballschule', fcsh_page_url( 'junioren/fussballschule', fcsh_page_url( 'fussballschule' ) ) ),
			array( 'Trainingslager', fcsh_page_url( 'junioren/trainingslager', fcsh_page_url( 'trainingslager' ) ) ),
			array( 'Betreuer werden',fcsh_page_url( 'junioren/betreuer-werden',fcsh_page_url( 'betreuer-werden' ) ) ),
		) ),
		array( 'label' => 'Events',        'children' => array(
			array( 'Alle Events',            fcsh_page_url( 'events' ) ),
			array( 'Dorf- & Grümpelturnier', fcsh_page_url( 'gruempelturnier', fcsh_page_url( 'events' ) ) ),
		) ),
		array( 'label' => 'Sponsoren',     'children' => array(
			array( 'Sponsoren',   fcsh_page_url( 'sponsoren' ) ),
			array( 'Top-Club 88', fcsh_page_url( 'sponsoren/top-club-88', fcsh_page_url( 'top-club-88' ) ) ),
		) ),
		array( 'label' => 'Kontakt',       'href' => fcsh_page_url( 'kontakt' ) ),
	);
}

/* ── Kopfzeile: Logo mittig, Navigation drumherum, Mega-Panel ─────── */
function fcsh_render_site_header() {
	$nav  = fcsh_get_overlay_nav();
	$logo = get_stylesheet_directory_uri() . '/assets/img/fcs-logo.svg';

	/* Nach Label greifen, damit die Reihenfolge links/rechts fix bleibt */
	$by_label = array();
	foreach ( $nav as $item ) {
		$by_label[ $item['label'] ] = $item;
	}
	$pick = function ( $labels ) use ( $by_label ) {
		$out = array();
		foreach ( $labels as $l ) {
			if ( isset( $by_label[ $l ] ) ) {
				$out[] = $by_label[ $l ];
			}
		}
		return $out;
	};
	$left  = $pick( array( 'News', 'Aktive', 'Junioren', 'Verein' ) );
	$right = $pick( array( 'Events', 'Sponsoren', 'Helfereinsätze', 'Kontakt' ) );

	$render_items = function ( $items ) {
		foreach ( $items as $item ) {
			$key    = sanitize_title( $item['label'] );
			$active = ! empty( $item['active'] ) ? ' is-active' : '';
			if ( ! empty( $item['children'] ) ) {
				printf(
					'<button type="button" class="fcx-hdr__item%s" data-fcx-toggle="%s" aria-expanded="false" aria-controls="fcx-mega-%s">%s</button>',
					esc_attr( $active ),
					esc_attr( $key ),
					esc_attr( $key ),
					esc_html( $item['label'] )
				);
			} else {
				printf(
					'<a class="fcx-hdr__item%s" href="%s">%s</a>',
					esc_attr( $active ),
					esc_url( $item['href'] ),
					esc_html( $item['label'] )
				);
			}
		}
	};
	?>
<header class="fcx-hdr" data-fcx-hdr>
	<div class="fcx-hdr__bar">
		<nav class="fcx-hdr__nav fcx-hdr__nav--left" aria-label="Hauptnavigation links">
			<?php $render_items( $left ); ?>
		</nav>

		<a class="fcx-hdr__logo" href="<?php echo esc_url( home_url( '/' ) ); ?>">
			<img src="<?php echo esc_url( $logo ); ?>" alt="FC Schattdorf">
		</a>

		<nav class="fcx-hdr__nav fcx-hdr__nav--right" aria-label="Hauptnavigation rechts">
			<?php $render_items( $right ); ?>
		</nav>

		<button class="fcx-hdr__burger" data-fcsh-menu-open aria-label="Menü öffnen">
			<span></span><span></span><span></span>
		</button>
	</div>

	<?php foreach ( $nav as $item ) :
		if ( empty( $item['children'] ) ) {
			continue;
		}
		$key = sanitize_title( $item['label'] );
		?>
		<div class="fcx-mega" id="fcx-mega-<?php echo esc_attr( $key ); ?>" data-fcx-mega="<?php echo esc_attr( $key ); ?>">
			<div class="fcx-mega__inner">
				<p class="fcx-mega__title"><?php echo esc_html( $item['label'] ); ?></p>
				<div class="fcx-mega__links">
					<?php foreach ( $item['children'] as $child ) : ?>
						<a href="<?php echo esc_url( $child[1] ); ?>"><?php echo esc_html( $child[0] ); ?></a>
					<?php endforeach; ?>
				</div>
			</div>
		</div>
	<?php endforeach; ?>
</header>
	<?php
}

/* ── Team-Sponsorenleiste unter dem Titelbild ─────────────────────
   Gleiche Optik wie der Sponsorenbalken der Startseite (.fcx-spbar,
   Styles in fcs-front.css) – nur mit den Sponsoren des Teams. */
function fcsh_render_team_sponsor_strip( $sponsors, $up ) {
	if ( empty( $sponsors ) ) {
		return;
	}
	?>
	<aside class="fcx-spbar" aria-label="Team-Sponsoren">
		<div class="fcx-spbar__track">
			<?php foreach ( $sponsors as $sp ) : ?>
				<?php if ( ! empty( $sp['url'] ) ) : ?>
					<a class="fcx-spbar__item" href="<?php echo esc_url( $sp['url'] ); ?>" target="_blank" rel="noopener noreferrer">
						<img src="<?php echo esc_url( $up . $sp['img'] ); ?>" alt="<?php echo esc_attr( $sp['name'] ); ?>" loading="lazy">
					</a>
				<?php else : ?>
					<span class="fcx-spbar__item">
						<img src="<?php echo esc_url( $up . $sp['img'] ); ?>" alt="<?php echo esc_attr( $sp['name'] ); ?>" loading="lazy">
					</span>
				<?php endif; ?>
			<?php endforeach; ?>
		</div>
	</aside>
	<?php
}

/* ── Styles & Scripts ─────────────────────────────────────────────── */
function fcs_enqueue_styles() {
	$dir = get_stylesheet_directory();
	$uri = get_stylesheet_directory_uri();

	wp_enqueue_style( 'astra-parent-style', get_template_directory_uri() . '/style.css', array(), wp_get_theme( 'astra' )->get( 'Version' ) );
	wp_enqueue_style( 'fcs-child-style',    get_stylesheet_uri(), array( 'astra-parent-style' ), wp_get_theme()->get( 'Version' ) );
	wp_enqueue_style( 'fcs-custom',         $uri . '/assets/custom.css', array( 'fcs-child-style' ), wp_get_theme()->get( 'Version' ) );
	wp_enqueue_style( 'aos',               'https://unpkg.com/aos@2.3.4/dist/aos.css', array(), '2.3.4' );
	wp_enqueue_script( 'aos',              'https://unpkg.com/aos@2.3.4/dist/aos.js', array(), '2.3.4', true );
	wp_add_inline_script( 'aos', 'document.addEventListener("DOMContentLoaded",function(){AOS.init({duration:700,once:false,easing:"ease-out"});});' );

	if ( ! is_front_page() ) {
		wp_enqueue_style( 'fcsh-inter-font', 'https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap', array(), null );
		/* Designsystem (Tokens + Bausteine) – identisch zur Startseite */
		wp_enqueue_style( 'fcs-front', $uri . '/assets/fcs-front.css', array(), filemtime( $dir . '/assets/fcs-front.css' ) );
		$css_ver = file_exists( $dir . '/assets/fcs-home.css' ) ? filemtime( $dir . '/assets/fcs-home.css' ) : '1';
		wp_enqueue_style( 'fcs-home', $uri . '/assets/fcs-home.css', array(), $css_ver );
		$js_ver = file_exists( $dir . '/assets/fcs-home.js' ) ? filemtime( $dir . '/assets/fcs-home.js' ) : '1';
		wp_enqueue_script( 'fcs-home', $uri . '/assets/fcs-home.js', array(), $js_ver, true );
	}
}
add_action( 'wp_enqueue_scripts', 'fcs_enqueue_styles' );

/* ── Body-Klasse für Inner-Header ─────────────────────────────────── */
add_filter( 'body_class', function ( $classes ) {
	global $fcsh_header_data;
	if ( ! is_front_page() ) {
		$classes[] = 'fcsh-has-inner-header';
		if ( empty( $fcsh_header_data['sub_nav'] ) ) {
			$classes[] = 'fcsh-no-sub-nav';
		}
		if ( fcsh_is_news_context() ) {
			$classes[] = 'fcsh-news-context';
		}
	}
	return $classes;
} );

/* ── Inner-Header + Sub-Nav + Overlay ausgeben (alle Nicht-Front-Seiten) */
add_action( 'wp_body_open', function () {
	if ( is_front_page() ) return;

	global $fcsh_header_data;
	if ( empty( $fcsh_header_data ) ) {
		$fcsh_header_data = fcsh_get_inner_header_data();
	}

	$uri      = get_stylesheet_directory_uri();
	$logo_svg = $uri . '/assets/img/fcs-logo.svg';
	$hd       = $fcsh_header_data;
	$nav      = fcsh_get_overlay_nav();
	?>

<?php fcsh_render_site_header(); ?>

<?php if ( ! empty( $hd['sub_nav_2'] ) ) : ?>
<nav class="fcsh-sub-nav fcsh-sub-nav--grid">
	<?php foreach ( $hd['sub_nav_2'] as $item ) : ?>
		<a href="<?php echo esc_url( $item['href'] ); ?>"<?php echo $item['active'] ? ' class="is-active"' : ''; ?>>
			<?php echo esc_html( $item['label'] ); ?>
		</a>
	<?php endforeach; ?>
</nav>
<?php endif; ?>

<!-- ══ OVERLAY-MENÜ ══ -->
<div class="fcsh-overlay">
	<div class="fcsh-overlay__top">
		<a href="<?php echo esc_url( home_url( '/' ) ); ?>"><img src="<?php echo esc_url( $logo_svg ); ?>" alt="FC Schattdorf"></a>
		<button class="fcsh-close" data-fcsh-menu-close>
			<span>SCHLIESSEN</span>
			<svg viewBox="0 0 24 24" fill="none" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg>
		</button>
	</div>
	<nav class="fcsh-overlay__nav">
		<div class="fcsh-overlay__grid">
			<?php foreach ( $nav as $item ) :
				$ac = ! empty( $item['active'] ) ? ' fcsh-mitem--active' : '';
			?>
				<?php if ( ! empty( $item['children'] ) ) : ?>
					<div class="fcsh-mitem<?php echo $ac; ?>">
						<button data-fcsh-section>
							<?php echo esc_html( $item['label'] ); ?>
							<svg class="fcsh-mitem__chev" viewBox="0 0 24 24" fill="none" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"/></svg>
						</button>
						<div class="fcsh-mitem__sub">
							<?php foreach ( $item['children'] as $c ) : ?>
								<a href="<?php echo esc_url( $c[1] ); ?>">→ <?php echo esc_html( $c[0] ); ?></a>
							<?php endforeach; ?>
						</div>
					</div>
				<?php else : ?>
					<div class="fcsh-mitem<?php echo $ac; ?>">
						<a href="<?php echo esc_url( $item['href'] ); ?>"><?php echo esc_html( $item['label'] ); ?></a>
					</div>
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
	<?php
} );

/* ── Theme-Grundlagen ─────────────────────────────────────────────── */
function fcs_theme_setup() {
	add_theme_support( 'title-tag' );
	add_theme_support( 'post-thumbnails' );
	add_theme_support( 'custom-logo' );

	register_nav_menus( array(
		'primary' => __( 'Hauptmenü', 'fcschattdorf-child' ),
		'footer'  => __( 'Footer-Menü', 'fcschattdorf-child' ),
	) );
}

/* ── Fanshop: AJAX order handler ──────────────────────────────────── */
add_action( 'wp_ajax_fcs_shop_order',        'fcsh_handle_shop_order' );
add_action( 'wp_ajax_nopriv_fcs_shop_order', 'fcsh_handle_shop_order' );

function fcsh_handle_shop_order() {
	if ( ! check_ajax_referer( 'fcs_shop_order', 'nonce', false ) ) {
		wp_send_json_error( 'Ungültige Anfrage.' );
	}

	$vorname     = sanitize_text_field( $_POST['vorname']     ?? '' );
	$nachname    = sanitize_text_field( $_POST['nachname']    ?? '' );
	$email       = sanitize_email(      $_POST['email']       ?? '' );
	$telefon     = sanitize_text_field( $_POST['telefon']     ?? '' );
	$adresse     = sanitize_text_field( $_POST['adresse']     ?? '' );
	$plz         = sanitize_text_field( $_POST['plz']         ?? '' );
	$ort         = sanitize_text_field( $_POST['ort']         ?? '' );
	$bemerkung   = sanitize_textarea_field( $_POST['bemerkung']   ?? '' );
	$order_items = sanitize_textarea_field( $_POST['order_items'] ?? '' );
	$order_total = sanitize_text_field( $_POST['order_total'] ?? '' );

	if ( ! $vorname || ! $nachname || ! is_email( $email ) || ! $adresse || ! $plz || ! $ort ) {
		wp_send_json_error( 'Bitte fülle alle Pflichtfelder aus.' );
	}

	$to      = 'marketing@fcschattdorf.ch';
	$subject = 'Fanshop-Bestellung von ' . $vorname . ' ' . $nachname;
	$message =
		"Neue Fanshop-Bestellung\n" .
		"=======================\n\n" .
		"Name:     $vorname $nachname\n" .
		"E-Mail:   $email\n" .
		( $telefon ? "Telefon:  $telefon\n" : '' ) .
		"Adresse:  $adresse, $plz $ort\n" .
		( $bemerkung ? "\nBemerkungen:\n$bemerkung\n" : '' ) .
		"\nBestellte Artikel:\n" .
		"------------------\n" .
		$order_items . "\n\n" .
		"Total: $order_total\n\n" .
		"--\nGesendet über den FC Schattdorf Fanshop";

	$headers = [ 'Content-Type: text/plain; charset=UTF-8', 'Reply-To: ' . $email ];
	$sent    = wp_mail( $to, $subject, $message, $headers );

	if ( $sent ) {
		/* confirmation to customer */
		wp_mail(
			$email,
			'Deine Fanshop-Bestellung bei FC Schattdorf',
			"Hallo $vorname!\n\nVielen Dank für deine Bestellung beim FC Schattdorf Fanshop.\n\n" .
			"Bestellte Artikel:\n$order_items\n\n" .
			"Total: $order_total\n\n" .
			"Wir werden uns in Kürze mit einer Rechnung bei dir melden.\n\n" .
			"Freundliche Grüsse\nFC Schattdorf",
			[ 'Content-Type: text/plain; charset=UTF-8' ]
		);
		wp_send_json_success( 'Bestellung eingegangen.' );
	} else {
		wp_send_json_error( 'E-Mail konnte nicht gesendet werden. Bitte kontaktiere uns direkt.' );
	}
}
add_action( 'after_setup_theme', 'fcs_theme_setup' );
