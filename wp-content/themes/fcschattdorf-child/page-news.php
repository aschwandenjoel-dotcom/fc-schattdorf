<?php
/**
 * News – ein durchgehender Feed ohne Filter oder Sortierung:
 * dunkle Fläche, hochformatige Bilder, Kartenraster.
 */
defined( 'ABSPATH' ) || exit;

/* Volle Breite: Astra-Container aufheben (Regeln in fcs-front.css) */
add_filter( 'body_class', function ( $c ) { $c[] = 'fcx-wide'; $c[] = 'fcx-newspage'; return $c; } );

get_header();

$paged      = max( 1, get_query_var( 'paged' ), get_query_var( 'page' ) );
$query_args = array(
	'post_type'           => 'post',
	'post_status'         => 'publish',
	'posts_per_page'      => 12,
	'paged'               => $paged,
	'ignore_sticky_posts' => true,
);
$q = new WP_Query( $query_args );

$theme_img = get_stylesheet_directory_uri() . '/assets/img';
$fallbacks = array(
	$theme_img . '/fcs1-web.jpg',
	$theme_img . '/fcs2-web.jpg',
	$theme_img . '/aa-junioren-2526.jpg',
	$theme_img . '/cb-junioren-2526.jpg',
);
?>

<section class="fcx-sec fcx-sec--wine fcx-news">
	<div class="fcx-sechead">
		<div>
			<h1 class="fcx-h2">News</h1>
		</div>
	</div>

	<?php if ( $q->have_posts() ) : ?>
		<div class="fcx-newsgrid">
			<?php
			$i = 0;
			while ( $q->have_posts() ) :
				$q->the_post();
				$thumb = get_the_post_thumbnail_url( get_the_ID(), 'full' );
				if ( ! $thumb ) {
					$thumb = $fallbacks[ $i % count( $fallbacks ) ];
				}
				?>
				<a class="fcx-ncard" href="<?php the_permalink(); ?>">
					<div class="fcx-ncard__img">
						<img src="<?php echo esc_url( $thumb ); ?>" alt="<?php echo esc_attr( get_the_title() ); ?>" loading="lazy">
					</div>
					<span class="fcx-ncard__date"><?php echo esc_html( get_the_date( 'd.m.Y' ) ); ?></span>
					<h2 class="fcx-ncard__title"><?php the_title(); ?></h2>
					<p class="fcx-ncard__teaser"><?php echo esc_html( wp_trim_words( wp_strip_all_tags( get_the_content() ), 34 ) ); ?></p>
				</a>
				<?php
				$i++;
			endwhile;
			?>
		</div>

		<?php
		$paginate_args = array(
			'total'     => $q->max_num_pages,
			'current'   => $paged,
			'type'      => 'array',
			'prev_text' => '‹ Neuere',
			'next_text' => 'Ältere ›',
		);
		$links = paginate_links( $paginate_args );
		if ( $links ) : ?>
			<nav class="fcx-pager" aria-label="News-Seiten">
				<?php foreach ( $links as $link ) { echo wp_kses_post( $link ); } ?>
			</nav>
		<?php endif; ?>

	<?php else : ?>
		<p class="fcx-empty">Zurzeit sind keine News veröffentlicht.</p>
	<?php endif; ?>
</section>

<?php
wp_reset_postdata();
get_footer();
