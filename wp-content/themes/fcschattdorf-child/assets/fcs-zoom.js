/* Bild-Zoom für Personenfotos — siehe inc/fcs-zoom.php.
   Ohne Fremdcode: <dialog> mit showModal(), Ereignis-Delegation, Escape
   und Klick schliessen, Fokus kehrt zur Kachel zurück. Silhouetten
   (Platzhalter) bekommen keinen Zoom. */
(function () {
  'use strict';
  /* Personen-Kacheln plus das grosse Teamfoto im Titelbild (.fc1m-photo) */
  var SEL = '.fc1m-person__photo, .fc1m-player__photo, .fcjo-card__photo, .fc1m-photo';
  if (!('HTMLDialogElement' in window)) { return; }

  /* Bild-URL der Kachel: <img> (ohne Sponsor-Badge) oder background-image */
  function urlOf(el) {
    var img = el.querySelector('img:not([class*="badge"])');
    if (img && img.currentSrc) { return img.currentSrc; }
    if (img && img.src) { return img.src; }
    var m = /url\(["']?([^"')]+)["']?\)/.exec(getComputedStyle(el).backgroundImage || '');
    return m ? m[1] : '';
  }
  function textOf(root, sel) {
    var n = root && root.querySelector(sel);
    return n ? n.textContent.trim() : '';
  }
  function captionOf(el) {
    if (el.classList.contains('fc1m-photo')) {
      return { name: textOf(el.closest('.fc1m-hero'), '.fc1m-herobar__title'), role: 'Teamfoto' };
    }
    var card = el.closest('.fc1m-person, .fc1m-player, .fcjo-card');
    return {
      name: textOf(card, '.fc1m-person__name, .fc1m-player__name, .fcjo-card__name'),
      role: textOf(card, '.fc1m-person__role, .fc1m-player__pos, .fcjo-card__role')
    };
  }

  var dlg, imgEl, nameEl, roleEl, opener = null;
  function build() {
    dlg = document.createElement('dialog');
    dlg.className = 'fcs-zoom';
    dlg.setAttribute('aria-label', 'Foto vergrössert');
    dlg.innerHTML =
      '<button type="button" class="fcs-zoom__close" aria-label="Schliessen">&times;</button>' +
      '<figure class="fcs-zoom__fig"><img class="fcs-zoom__img" alt="">' +
      '<figcaption class="fcs-zoom__cap"><strong></strong><span></span></figcaption></figure>';
    document.body.appendChild(dlg);
    imgEl  = dlg.querySelector('.fcs-zoom__img');
    nameEl = dlg.querySelector('.fcs-zoom__cap strong');
    roleEl = dlg.querySelector('.fcs-zoom__cap span');
    /* Klick irgendwo (Bild, Grund, Knopf) schliesst */
    dlg.addEventListener('click', function () { dlg.close(); });
    dlg.addEventListener('close', function () {
      document.documentElement.classList.remove('fcs-zoom-open');
      imgEl.removeAttribute('src');
      if (opener) { opener.focus({ preventScroll: true }); opener = null; }
    });
  }

  function open(el) {
    var url = urlOf(el);
    if (!url || /silhouette|platzhalter/i.test(url)) { return; }
    if (!dlg) { build(); }
    var cap = captionOf(el);
    imgEl.src = url;
    imgEl.alt = cap.name;
    nameEl.textContent = cap.name;
    roleEl.textContent = cap.role;
    opener = el;
    document.documentElement.classList.add('fcs-zoom-open');
    dlg.showModal();
  }

  /* Kacheln mit echtem Foto markieren und per Tastatur erreichbar machen */
  function init() {
    var tiles = document.querySelectorAll(SEL);
    for (var i = 0; i < tiles.length; i++) {
      var el = tiles[i], url = urlOf(el);
      if (!url || /silhouette|platzhalter/i.test(url)) { continue; }
      el.classList.add('fcs-zoomable');
      el.setAttribute('role', 'button');
      el.setAttribute('tabindex', '0');
      el.setAttribute('aria-label', 'Foto vergrössern: ' + captionOf(el).name);
    }
  }

  document.addEventListener('click', function (e) {
    var el = e.target.closest && e.target.closest(SEL);
    if (!el || !el.classList.contains('fcs-zoomable')) { return; }
    e.preventDefault();
    open(el);
  });
  document.addEventListener('keydown', function (e) {
    if (e.key !== 'Enter' && e.key !== ' ') { return; }
    var el = e.target.closest && e.target.closest(SEL);
    if (!el || !el.classList.contains('fcs-zoomable')) { return; }
    e.preventDefault();
    open(el);
  });

  if (document.readyState === 'loading') { document.addEventListener('DOMContentLoaded', init); }
  else { init(); }
})();
