<?php
/**
 * Sponsoren als eigener Inhaltstyp.
 *
 * Die Sponsoren werden im WP-Admin unter «Sponsoren» gepflegt und von der
 * Seitenvorlage page-sponsoren.php nach Stufe gruppiert ausgegeben.
 * Pro Sponsor: Name (WP-Titel) sowie Stufe, Logo und Website-Link
 * (Feld-Box unterhalb des Titels). Reihenfolge innerhalb einer Stufe
 * über das Feld «Reihenfolge» (menu_order).
 */
defined( 'ABSPATH' ) || exit;

const FCS_SPONSOR_STUFEN = array(
	'haupt'        => 'Hauptsponsor',
	'patronat'     => 'Nachwuchs-Patronat',
	'co_sponsoren' => 'Co-Sponsor',
	'club'         => 'Club-Sponsor',
	'nachwuchs'    => 'Nachwuchs-Sponsor',
	'spieler'      => 'Spieler-Sponsor',
);

/**
 * Logo-Angabe in eine vollständige URL auflösen.
 *
 * Erlaubt ist eine komplette URL, ein absoluter Pfad oder nur der
 * Dateiname – Letzterer wird im Upload-Ordner 2026/06 gesucht
 * (dort liegen die Sponsorenlogos).
 */
function fcs_sponsor_logo_url( $logo ) {
	if ( '' === (string) $logo ) {
		return '';
	}
	if ( preg_match( '#^(https?:)?//#', $logo ) || 0 === strpos( $logo, '/' ) ) {
		return $logo;
	}
	return wp_upload_dir()['baseurl'] . '/2026/06/' . $logo;
}

/* ── Inhaltstyp registrieren ──────────────────────────────────── */
add_action( 'init', function () {
	register_post_type( 'fcs_sponsor', array(
		'labels' => array(
			'name'               => 'Sponsoren',
			'singular_name'      => 'Sponsor',
			'menu_name'          => 'Sponsoren',
			'add_new'            => 'Sponsor hinzufügen',
			'add_new_item'       => 'Sponsor hinzufügen',
			'edit_item'          => 'Sponsor bearbeiten',
			'new_item'           => 'Neuer Sponsor',
			'all_items'          => 'Alle Sponsoren',
			'search_items'       => 'Sponsoren durchsuchen',
			'not_found'          => 'Keine Sponsoren gefunden',
			'not_found_in_trash' => 'Keine Sponsoren im Papierkorb',
		),
		/* Keine eigenen Front-URLs – die Ausgabe macht die Seitenvorlage */
		'public'        => false,
		'show_ui'       => true,
		'show_in_menu'  => true,
		'menu_position' => 22,
		'menu_icon'     => 'dashicons-awards',
		'supports'      => array( 'title' ),
		'show_in_rest'  => true,
		'has_archive'   => false,
		'rewrite'       => false,
	) );

	$auth = function () { return current_user_can( 'edit_posts' ); };
	register_post_meta( 'fcs_sponsor', 'fcs_sp_stufe', array(
		'type' => 'string', 'single' => true, 'show_in_rest' => true,
		'sanitize_callback' => function ( $v ) {
			return array_key_exists( $v, FCS_SPONSOR_STUFEN ) ? $v : 'spieler';
		},
		'auth_callback' => $auth,
	) );
	register_post_meta( 'fcs_sponsor', 'fcs_sp_url', array(
		'type' => 'string', 'single' => true, 'show_in_rest' => true,
		'sanitize_callback' => 'esc_url_raw', 'auth_callback' => $auth,
	) );
	register_post_meta( 'fcs_sponsor', 'fcs_sp_logo', array(
		'type' => 'string', 'single' => true, 'show_in_rest' => true,
		'sanitize_callback' => 'sanitize_text_field', 'auth_callback' => $auth,
	) );
} );

/* ── Feld-Box: Stufe, Logo, Website ───────────────────────────── */
add_action( 'add_meta_boxes_fcs_sponsor', function () {
	add_meta_box( 'fcs-sponsor-felder', 'Sponsor-Angaben', function ( $post ) {
		wp_nonce_field( 'fcs_sponsor_save', 'fcs_sponsor_nonce' );
		$stufe = get_post_meta( $post->ID, 'fcs_sp_stufe', true );
		$url   = get_post_meta( $post->ID, 'fcs_sp_url', true );
		$logo  = get_post_meta( $post->ID, 'fcs_sp_logo', true );
		?>
		<p>
			<label for="fcs_sp_stufe"><strong>Stufe</strong></label><br>
			<select id="fcs_sp_stufe" name="fcs_sp_stufe">
				<?php foreach ( FCS_SPONSOR_STUFEN as $key => $label ) : ?>
					<option value="<?php echo esc_attr( $key ); ?>" <?php selected( $stufe, $key ); ?>>
						<?php echo esc_html( $label ); ?>
					</option>
				<?php endforeach; ?>
			</select>
		</p>
		<p>
			<label for="fcs_sp_logo"><strong>Logo</strong> (Dateiname im Upload-Ordner 2026/06 oder komplette Bild-URL; leer = «Logo folgt»)</label><br>
			<input type="text" id="fcs_sp_logo" name="fcs_sp_logo" class="widefat"
			       value="<?php echo esc_attr( $logo ); ?>" placeholder="z. B. muoser-color.png">
		</p>
		<p>
			<label for="fcs_sp_url"><strong>Website</strong> (optional, mit https://)</label><br>
			<input type="url" id="fcs_sp_url" name="fcs_sp_url" class="widefat"
			       value="<?php echo esc_attr( $url ); ?>" placeholder="https://…">
		</p>
		<p class="description">
			Reihenfolge innerhalb derselben Stufe: Feld «Reihenfolge» in den
			Seiten-Attributen (kleinere Zahl zuerst).
		</p>
		<?php
	}, 'fcs_sponsor', 'normal', 'high' );
} );

add_action( 'save_post_fcs_sponsor', function ( $post_id ) {
	if ( ! isset( $_POST['fcs_sponsor_nonce'] )
		|| ! wp_verify_nonce( $_POST['fcs_sponsor_nonce'], 'fcs_sponsor_save' )
		|| defined( 'DOING_AUTOSAVE' ) && DOING_AUTOSAVE
		|| ! current_user_can( 'edit_post', $post_id ) ) {
		return;
	}
	$stufe = sanitize_key( $_POST['fcs_sp_stufe'] ?? '' );
	update_post_meta( $post_id, 'fcs_sp_stufe', array_key_exists( $stufe, FCS_SPONSOR_STUFEN ) ? $stufe : 'spieler' );
	update_post_meta( $post_id, 'fcs_sp_url', esc_url_raw( wp_unslash( $_POST['fcs_sp_url'] ?? '' ) ) );
	update_post_meta( $post_id, 'fcs_sp_logo', sanitize_text_field( wp_unslash( $_POST['fcs_sp_logo'] ?? '' ) ) );
} );

/* ── Admin-Liste: Spalten Stufe/Logo/Website, nach Stufe sortiert ── */
add_filter( 'manage_fcs_sponsor_posts_columns', function ( $cols ) {
	return array(
		'cb'           => $cols['cb'],
		'title'        => 'Name',
		'fcs_sp_stufe' => 'Stufe',
		'fcs_sp_logo'  => 'Logo',
		'fcs_sp_url'   => 'Website',
	);
} );
add_action( 'manage_fcs_sponsor_posts_custom_column', function ( $col, $post_id ) {
	if ( 'fcs_sp_stufe' === $col ) {
		$stufe = get_post_meta( $post_id, 'fcs_sp_stufe', true );
		echo esc_html( FCS_SPONSOR_STUFEN[ $stufe ] ?? $stufe );
	} elseif ( 'fcs_sp_logo' === $col ) {
		$logo = fcs_sponsor_logo_url( get_post_meta( $post_id, 'fcs_sp_logo', true ) );
		if ( $logo ) {
			echo '<img src="' . esc_url( $logo ) . '" alt="" style="max-height:40px;max-width:100px;">';
		} else {
			echo '—';
		}
	} elseif ( 'fcs_sp_url' === $col ) {
		$url = get_post_meta( $post_id, 'fcs_sp_url', true );
		if ( $url ) {
			echo '<a href="' . esc_url( $url ) . '" target="_blank" rel="noopener noreferrer">' . esc_html( $url ) . '</a>';
		} else {
			echo '—';
		}
	}
}, 10, 2 );
add_filter( 'manage_edit-fcs_sponsor_sortable_columns', function ( $cols ) {
	$cols['fcs_sp_stufe'] = 'fcs_sp_stufe';
	return $cols;
} );
add_action( 'pre_get_posts', function ( $q ) {
	if ( ! is_admin() || ! $q->is_main_query() || 'fcs_sponsor' !== $q->get( 'post_type' ) ) {
		return;
	}
	if ( ! $q->get( 'orderby' ) || 'fcs_sp_stufe' === $q->get( 'orderby' ) ) {
		$q->set( 'meta_key', 'fcs_sp_stufe' );
		$q->set( 'orderby', array( 'meta_value' => $q->get( 'order' ) ?: 'ASC', 'menu_order' => 'ASC' ) );
	}
} );

/* ── Abfrage für die Seitenvorlage ────────────────────────────── */
function fcs_get_sponsoren() {
	$posts = get_posts( array(
		'post_type'      => 'fcs_sponsor',
		'post_status'    => 'publish',
		'posts_per_page' => -1,
		'orderby'        => array( 'menu_order' => 'ASC', 'title' => 'ASC' ),
	) );
	$sponsoren = array_fill_keys( array_keys( FCS_SPONSOR_STUFEN ), array() );
	foreach ( $posts as $p ) {
		$stufe = get_post_meta( $p->ID, 'fcs_sp_stufe', true );
		if ( ! array_key_exists( $stufe, $sponsoren ) ) {
			$stufe = 'spieler';
		}
		$sponsoren[ $stufe ][] = array(
			'name' => get_the_title( $p ),
			'url'  => get_post_meta( $p->ID, 'fcs_sp_url', true ),
			'logo' => fcs_sponsor_logo_url( get_post_meta( $p->ID, 'fcs_sp_logo', true ) ),
		);
	}
	return $sponsoren;
}
