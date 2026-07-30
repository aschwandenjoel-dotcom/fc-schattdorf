# Startseite: Abschnitt «Aktuellste News» (Bild links, Titel rechts)

Entfernt am 30.07.2026 aus der Startseite. Zeigte den neusten Beitrag als
graue Box unterhalb von «Termine & Spielbetrieb» — Bild links, Titel rechts
(z. B. «33. Dorf- und 66. Grümpelturnier des FC Schattdorf»).

Zum Wiederherstellen die drei Blöcke unten zurückspielen.

## 1. front-page.php — Variable (stand direkt nach `$slides = array_slice( $items, 0, 1 );`)

```php
$latest = isset( $items[0] ) ? $items[0] : null;
```

## 2. front-page.php — Markup (stand zwischen der Sektion «TERMINE + SPIELBETRIEB» und «SPONSOREN»)

```php
<!-- ══ AKTUELLSTE NEWS: Bild links, Text rechts ══ -->
<?php if ( $latest ) : ?>
<section class="fcx-sec fcx-latest">
	<a class="fcx-latestbox" href="<?php echo esc_url( $latest['url'] ); ?>">
		<div class="fcx-latestbox__img">
			<img src="<?php echo esc_url( $latest['img'] ); ?>" alt="<?php echo esc_attr( $latest['title'] ); ?>" loading="lazy">
		</div>
		<div class="fcx-latestbox__body">
			<p class="fcx-latestbox__title"><?php echo esc_html( $latest['title'] ); ?></p>
		</div>
	</a>
</section>
<?php endif; ?>
```

## 3. assets/fcs-front.css — Styles (standen nach dem `.fcx-tile`-Block)

```css
/* ── AKTUELLSTE NEWS: Bild-Text-Box unterhalb Termine ──────────
   Weisse Seitenfläche, die Box selbst hebt sich in Mist-Grau ab.
   Bild links (breiter Anteil), Titel rechts vertikal zentriert. */
.fcx-latestbox{
  display:grid;grid-template-columns:minmax(0,1.7fr) minmax(0,1fr);
  align-items:stretch;background:var(--fcx-mist);
  border-radius:1.5rem;overflow:hidden;
  transition:transform var(--fcx-fast) var(--fcx-ease);
}
@media(hover:hover) and (pointer:fine){
  .fcx-latestbox:hover .fcx-latestbox__title{color:var(--fcx-red);}
  .fcx-latestbox:hover .fcx-latestbox__img img{transform:scale(1.03);}
}
.fcx-latestbox__img{
  position:relative;overflow:hidden;background:var(--fcx-line);
  min-height:16rem;aspect-ratio:16/9;
}
.fcx-latestbox__img img{
  width:100%;height:100%;object-fit:cover;display:block;
  transition:transform 500ms var(--fcx-ease);
}
.fcx-latestbox__body{
  display:flex;align-items:center;
  padding:clamp(1.5rem,3vw,3rem);
}
.fcx-latestbox__title{
  margin:0;font-size:clamp(1.15rem,2vw,1.6rem);font-weight:800;line-height:1.3;
  color:var(--fcx-ink);letter-spacing:-.01em;text-wrap:balance;
  transition:color var(--fcx-fast) var(--fcx-ease);
}
@media(max-width:48rem){
  .fcx-latestbox{grid-template-columns:1fr;border-radius:1.25rem;}
  .fcx-latestbox__img{aspect-ratio:16/10;min-height:0;}
}
```
