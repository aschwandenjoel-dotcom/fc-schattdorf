<?php
/**
 * Ehren- und Freimitglieder als eigener Inhaltstyp.
 *
 * Die Personen werden im WP-Admin unter «Ehrungen» gepflegt und von der
 * Seitenvorlage page-ehrenmitglieder.php als Tabellen ausgegeben.
 * Pro Person: Name (WP-Titel, verstorbene mit «† »-Präfix) sowie Typ,
 * Wohnort, Geburtsdatum und Wahljahr (Feld-Box). Die Reihenfolge innerhalb
 * eines Typs steuert das Feld «Reihenfolge» (menu_order).
 */
defined( 'ABSPATH' ) || exit;

const FCS_EHRUNG_TYPEN = array(
	'ehrenpraesident' => 'Ehrenpräsident',
	'ehrenmitglied'   => 'Ehrenmitglied',
	'freimitglied'    => 'Freimitglied',
);

/* ── Inhaltstyp registrieren ──────────────────────────────────── */
add_action( 'init', function () {
	register_post_type( 'fcs_ehrung', array(
		'labels' => array(
			'name'               => 'Ehrungen',
			'singular_name'      => 'Ehrung',
			'menu_name'          => 'Ehrungen',
			'add_new'            => 'Person hinzufügen',
			'add_new_item'       => 'Ehren-/Freimitglied hinzufügen',
			'edit_item'          => 'Ehren-/Freimitglied bearbeiten',
			'new_item'           => 'Neues Ehren-/Freimitglied',
			'all_items'          => 'Alle Personen',
			'search_items'       => 'Ehrungen durchsuchen',
			'not_found'          => 'Keine Ehrungen gefunden',
			'not_found_in_trash' => 'Keine Ehrungen im Papierkorb',
		),
		/* Keine eigenen Front-URLs – die Ausgabe macht die Seitenvorlage */
		'public'        => false,
		'show_ui'       => true,
		'show_in_menu'  => true,
		'menu_position' => 23,
		'menu_icon'     => 'dashicons-groups',
		'supports'      => array( 'title' ),
		'show_in_rest'  => true,
		'has_archive'   => false,
		'rewrite'       => false,
	) );

	$auth = function () { return current_user_can( 'edit_posts' ); };
	register_post_meta( 'fcs_ehrung', 'fcs_em_typ', array(
		'type' => 'string', 'single' => true, 'show_in_rest' => true,
		'sanitize_callback' => function ( $v ) {
			return array_key_exists( $v, FCS_EHRUNG_TYPEN ) ? $v : 'freimitglied';
		},
		'auth_callback' => $auth,
	) );
	foreach ( array( 'fcs_em_ort', 'fcs_em_geb', 'fcs_em_jahr' ) as $key ) {
		register_post_meta( 'fcs_ehrung', $key, array(
			'type' => 'string', 'single' => true, 'show_in_rest' => true,
			'sanitize_callback' => 'sanitize_text_field', 'auth_callback' => $auth,
		) );
	}
} );

/* ── Feld-Box: Typ, Wohnort, Geburtsdatum, Wahljahr, Reihenfolge ── */
add_action( 'add_meta_boxes_fcs_ehrung', function () {
	add_meta_box( 'fcs-ehrung-felder', 'Angaben zur Person', function ( $post ) {
		wp_nonce_field( 'fcs_ehrung_save', 'fcs_ehrung_nonce' );
		$typ  = get_post_meta( $post->ID, 'fcs_em_typ', true );
		$ort  = get_post_meta( $post->ID, 'fcs_em_ort', true );
		$geb  = get_post_meta( $post->ID, 'fcs_em_geb', true );
		$jahr = get_post_meta( $post->ID, 'fcs_em_jahr', true );
		?>
		<p class="description">
			Der Name wird als Titel erfasst («Nachname Vorname»); bei
			verstorbenen Personen mit vorangestelltem «†&nbsp;».
		</p>
		<p>
			<label for="fcs_em_typ"><strong>Typ</strong></label><br>
			<select id="fcs_em_typ" name="fcs_em_typ">
				<?php foreach ( FCS_EHRUNG_TYPEN as $key => $label ) : ?>
					<option value="<?php echo esc_attr( $key ); ?>" <?php selected( $typ, $key ); ?>>
						<?php echo esc_html( $label ); ?>
					</option>
				<?php endforeach; ?>
			</select>
		</p>
		<p>
			<label for="fcs_em_ort"><strong>Wohnort</strong> (z.&nbsp;B. Schattdorf)</label><br>
			<input type="text" id="fcs_em_ort" name="fcs_em_ort"
			       value="<?php echo esc_attr( $ort ); ?>" class="regular-text">
		</p>
		<p>
			<label for="fcs_em_geb"><strong>Geburtsdatum</strong> (z.&nbsp;B. 21.01.1907, darf leer bleiben)</label><br>
			<input type="text" id="fcs_em_geb" name="fcs_em_geb"
			       value="<?php echo esc_attr( $geb ); ?>" style="width:10em;">
		</p>
		<p>
			<label for="fcs_em_jahr"><strong>Wahljahr</strong> (z.&nbsp;B. 2015 oder 1991/1993, darf leer bleiben)</label><br>
			<input type="text" id="fcs_em_jahr" name="fcs_em_jahr"
			       value="<?php echo esc_attr( $jahr ); ?>" style="width:10em;">
		</p>
		<p>
			<label for="fcs_em_reihenfolge"><strong>Reihenfolge</strong> innerhalb des Typs (kleinere Zahl zuerst)</label><br>
			<input type="number" id="fcs_em_reihenfolge" name="fcs_em_reihenfolge"
			       value="<?php echo esc_attr( $post->menu_order ); ?>" style="width:8em;">
		</p>
		<?php
	}, 'fcs_ehrung', 'normal', 'high' );
} );

add_action( 'save_post_fcs_ehrung', function ( $post_id ) {
	if ( ! isset( $_POST['fcs_ehrung_nonce'] )
		|| ! wp_verify_nonce( $_POST['fcs_ehrung_nonce'], 'fcs_ehrung_save' )
		|| defined( 'DOING_AUTOSAVE' ) && DOING_AUTOSAVE
		|| ! current_user_can( 'edit_post', $post_id ) ) {
		return;
	}
	$typ = sanitize_key( $_POST['fcs_em_typ'] ?? '' );
	update_post_meta( $post_id, 'fcs_em_typ', array_key_exists( $typ, FCS_EHRUNG_TYPEN ) ? $typ : 'freimitglied' );
	update_post_meta( $post_id, 'fcs_em_ort', sanitize_text_field( $_POST['fcs_em_ort'] ?? '' ) );
	update_post_meta( $post_id, 'fcs_em_geb', sanitize_text_field( $_POST['fcs_em_geb'] ?? '' ) );
	update_post_meta( $post_id, 'fcs_em_jahr', sanitize_text_field( $_POST['fcs_em_jahr'] ?? '' ) );
	/* menu_order direkt schreiben (kein wp_update_post – vermeidet Rekursion) */
	if ( isset( $_POST['fcs_em_reihenfolge'] ) ) {
		global $wpdb;
		$wpdb->update( $wpdb->posts, array( 'menu_order' => (int) $_POST['fcs_em_reihenfolge'] ), array( 'ID' => $post_id ) );
		clean_post_cache( $post_id );
	}
} );

/* ── Admin-Liste: Spalten Typ/Wohnort/Geburtsdatum/Wahljahr ───── */
add_filter( 'manage_fcs_ehrung_posts_columns', function ( $cols ) {
	return array(
		'cb'          => $cols['cb'],
		'title'       => 'Name',
		'fcs_em_typ'  => 'Typ',
		'fcs_em_ort'  => 'Wohnort',
		'fcs_em_geb'  => 'Geburtsdatum',
		'fcs_em_jahr' => 'Wahljahr',
	);
} );
add_action( 'manage_fcs_ehrung_posts_custom_column', function ( $col, $post_id ) {
	if ( 'fcs_em_typ' === $col ) {
		$typ = get_post_meta( $post_id, 'fcs_em_typ', true );
		echo esc_html( FCS_EHRUNG_TYPEN[ $typ ] ?? $typ );
	} elseif ( in_array( $col, array( 'fcs_em_ort', 'fcs_em_geb', 'fcs_em_jahr' ), true ) ) {
		$val = get_post_meta( $post_id, $col, true );
		echo '' === $val ? '—' : esc_html( $val );
	}
}, 10, 2 );
add_filter( 'manage_edit-fcs_ehrung_sortable_columns', function ( $cols ) {
	$cols['fcs_em_typ']  = 'fcs_em_typ';
	$cols['fcs_em_jahr'] = 'fcs_em_jahr';
	return $cols;
} );
add_action( 'pre_get_posts', function ( $q ) {
	if ( ! is_admin() || ! $q->is_main_query() || 'fcs_ehrung' !== $q->get( 'post_type' ) ) {
		return;
	}
	$orderby = $q->get( 'orderby' );
	if ( in_array( $orderby, array( 'fcs_em_typ', 'fcs_em_jahr' ), true ) ) {
		$q->set( 'meta_key', $orderby );
		$q->set( 'orderby', array( 'meta_value' => $q->get( 'order' ) ?: 'ASC', 'menu_order' => 'ASC' ) );
	} elseif ( ! $orderby ) {
		$q->set( 'orderby', array( 'menu_order' => 'ASC', 'ID' => 'ASC' ) );
	}
} );

/* ── Abfrage für die Seitenvorlage ────────────────────────────── */
function fcs_get_ehrungen() {
	$posts = get_posts( array(
		'post_type'      => 'fcs_ehrung',
		'post_status'    => 'publish',
		'posts_per_page' => -1,
		'orderby'        => array( 'menu_order' => 'ASC', 'ID' => 'ASC' ),
	) );
	$ehrungen = array_fill_keys( array_keys( FCS_EHRUNG_TYPEN ), array() );
	foreach ( $posts as $p ) {
		$typ = get_post_meta( $p->ID, 'fcs_em_typ', true ) ?: 'freimitglied';
		$ehrungen[ $typ ][] = array(
			'name' => get_the_title( $p ),
			'ort'  => get_post_meta( $p->ID, 'fcs_em_ort', true ),
			'geb'  => get_post_meta( $p->ID, 'fcs_em_geb', true ),
			'jahr' => get_post_meta( $p->ID, 'fcs_em_jahr', true ),
		);
	}
	return $ehrungen;
}
