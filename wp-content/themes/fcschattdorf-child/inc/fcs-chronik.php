<?php
/**
 * Chronik (Vereinsgeschichte) als eigener Inhaltstyp.
 *
 * Die Einträge werden im WP-Admin unter «Chronik» gepflegt und von der
 * Seitenvorlage page-vereinsgeschichte.php als Zeitstrahl ausgegeben.
 * Pro Eintrag: Titel (WP-Titel), Text (Editor) sowie Jahr, Kategorie und
 * Meilenstein-Markierung (Feld-Box unterhalb des Editors).
 */
defined( 'ABSPATH' ) || exit;

const FCS_CHRONIK_CATS = array(
	'gruendung'     => 'Gründung',
	'verein'        => 'Verein',
	'sport'         => 'Sport',
	'infrastruktur' => 'Infrastruktur',
);

/* ── Inhaltstyp registrieren ──────────────────────────────────── */
add_action( 'init', function () {
	register_post_type( 'fcs_chronik', array(
		'labels' => array(
			'name'               => 'Chronik',
			'singular_name'      => 'Chronik-Eintrag',
			'menu_name'          => 'Chronik',
			'add_new'            => 'Eintrag hinzufügen',
			'add_new_item'       => 'Chronik-Eintrag hinzufügen',
			'edit_item'          => 'Chronik-Eintrag bearbeiten',
			'new_item'           => 'Neuer Chronik-Eintrag',
			'all_items'          => 'Alle Einträge',
			'search_items'       => 'Chronik durchsuchen',
			'not_found'          => 'Keine Chronik-Einträge gefunden',
			'not_found_in_trash' => 'Keine Chronik-Einträge im Papierkorb',
		),
		/* Keine eigenen Front-URLs – die Ausgabe macht die Seitenvorlage */
		'public'        => false,
		'show_ui'       => true,
		'show_in_menu'  => true,
		'menu_position' => 21,
		'menu_icon'     => 'dashicons-book-alt',
		'supports'      => array( 'title', 'editor' ),
		'show_in_rest'  => true,
		'has_archive'   => false,
		'rewrite'       => false,
	) );

	$auth = function () { return current_user_can( 'edit_posts' ); };
	register_post_meta( 'fcs_chronik', 'fcs_year', array(
		'type' => 'integer', 'single' => true, 'show_in_rest' => true,
		'sanitize_callback' => 'absint', 'auth_callback' => $auth,
	) );
	register_post_meta( 'fcs_chronik', 'fcs_cat', array(
		'type' => 'string', 'single' => true, 'show_in_rest' => true,
		'sanitize_callback' => function ( $v ) {
			return array_key_exists( $v, FCS_CHRONIK_CATS ) ? $v : 'verein';
		},
		'auth_callback' => $auth,
	) );
	register_post_meta( 'fcs_chronik', 'fcs_milestone', array(
		'type' => 'boolean', 'single' => true, 'show_in_rest' => true,
		'sanitize_callback' => 'rest_sanitize_boolean', 'auth_callback' => $auth,
	) );
} );

/* ── Feld-Box: Jahr, Kategorie, Meilenstein ───────────────────── */
add_action( 'add_meta_boxes_fcs_chronik', function () {
	add_meta_box( 'fcs-chronik-felder', 'Chronik-Angaben', function ( $post ) {
		wp_nonce_field( 'fcs_chronik_save', 'fcs_chronik_nonce' );
		$year = get_post_meta( $post->ID, 'fcs_year', true );
		$cat  = get_post_meta( $post->ID, 'fcs_cat', true );
		$ms   = (bool) get_post_meta( $post->ID, 'fcs_milestone', true );
		?>
		<p>
			<label for="fcs_year"><strong>Jahr</strong> (Pflichtfeld, z.&nbsp;B. 1956)</label><br>
			<input type="number" id="fcs_year" name="fcs_year" min="1900" max="2100"
			       value="<?php echo esc_attr( $year ); ?>" required style="width:8em;">
		</p>
		<p>
			<label for="fcs_cat"><strong>Kategorie</strong></label><br>
			<select id="fcs_cat" name="fcs_cat">
				<?php foreach ( FCS_CHRONIK_CATS as $key => $label ) : ?>
					<option value="<?php echo esc_attr( $key ); ?>" <?php selected( $cat, $key ); ?>>
						<?php echo esc_html( $label ); ?>
					</option>
				<?php endforeach; ?>
			</select>
		</p>
		<p>
			<label>
				<input type="checkbox" name="fcs_milestone" value="1" <?php checked( $ms ); ?>>
				<strong>Meilenstein</strong> – hervorgehobene Darstellung im Zeitstrahl
			</label>
		</p>
		<p class="description">
			Reihenfolge innerhalb desselben Jahres: Feld «Reihenfolge» in den
			Seiten-Attributen (kleinere Zahl zuerst).
		</p>
		<?php
	}, 'fcs_chronik', 'normal', 'high' );
} );

add_action( 'save_post_fcs_chronik', function ( $post_id ) {
	if ( ! isset( $_POST['fcs_chronik_nonce'] )
		|| ! wp_verify_nonce( $_POST['fcs_chronik_nonce'], 'fcs_chronik_save' )
		|| defined( 'DOING_AUTOSAVE' ) && DOING_AUTOSAVE
		|| ! current_user_can( 'edit_post', $post_id ) ) {
		return;
	}
	update_post_meta( $post_id, 'fcs_year', absint( $_POST['fcs_year'] ?? 0 ) );
	$cat = sanitize_key( $_POST['fcs_cat'] ?? '' );
	update_post_meta( $post_id, 'fcs_cat', array_key_exists( $cat, FCS_CHRONIK_CATS ) ? $cat : 'verein' );
	update_post_meta( $post_id, 'fcs_milestone', empty( $_POST['fcs_milestone'] ) ? 0 : 1 );
} );

/* ── Admin-Liste: Spalten Jahr/Kategorie/Meilenstein, nach Jahr sortiert ── */
add_filter( 'manage_fcs_chronik_posts_columns', function ( $cols ) {
	return array(
		'cb'            => $cols['cb'],
		'fcs_year'      => 'Jahr',
		'title'         => 'Titel',
		'fcs_cat'       => 'Kategorie',
		'fcs_milestone' => 'Meilenstein',
	);
} );
add_action( 'manage_fcs_chronik_posts_custom_column', function ( $col, $post_id ) {
	if ( 'fcs_year' === $col ) {
		echo esc_html( get_post_meta( $post_id, 'fcs_year', true ) );
	} elseif ( 'fcs_cat' === $col ) {
		$cat = get_post_meta( $post_id, 'fcs_cat', true );
		echo esc_html( FCS_CHRONIK_CATS[ $cat ] ?? $cat );
	} elseif ( 'fcs_milestone' === $col ) {
		echo get_post_meta( $post_id, 'fcs_milestone', true ) ? '★' : '—';
	}
}, 10, 2 );
add_filter( 'manage_edit-fcs_chronik_sortable_columns', function ( $cols ) {
	$cols['fcs_year'] = 'fcs_year';
	return $cols;
} );
add_action( 'pre_get_posts', function ( $q ) {
	if ( ! is_admin() || ! $q->is_main_query() || 'fcs_chronik' !== $q->get( 'post_type' ) ) {
		return;
	}
	if ( ! $q->get( 'orderby' ) || 'fcs_year' === $q->get( 'orderby' ) ) {
		$q->set( 'meta_key', 'fcs_year' );
		$q->set( 'orderby', array( 'meta_value_num' => $q->get( 'order' ) ?: 'ASC', 'menu_order' => 'ASC' ) );
	}
} );

/* ── Abfrage für die Seitenvorlage ────────────────────────────── */
function fcs_get_chronik_events() {
	$posts = get_posts( array(
		'post_type'      => 'fcs_chronik',
		'post_status'    => 'publish',
		'posts_per_page' => -1,
		'meta_key'       => 'fcs_year',
		'orderby'        => array( 'meta_value_num' => 'ASC', 'menu_order' => 'ASC' ),
	) );
	$events = array();
	foreach ( $posts as $p ) {
		$events[] = array(
			'year'      => (int) get_post_meta( $p->ID, 'fcs_year', true ),
			'cat'       => get_post_meta( $p->ID, 'fcs_cat', true ) ?: 'verein',
			'milestone' => (bool) get_post_meta( $p->ID, 'fcs_milestone', true ),
			'title'     => get_the_title( $p ),
			'text'      => $p->post_content,
		);
	}
	return $events;
}
