(function () {
  'use strict';

  // ── Scroll progress bar ──────────────────────────────────────
  var progressBar = document.getElementById('fcvgProgress');
  if (progressBar) {
    function updateProgress() {
      var h = document.documentElement;
      var scrollTop = h.scrollTop || document.body.scrollTop;
      var scrollH = h.scrollHeight - h.clientHeight;
      progressBar.style.width = (scrollH > 0 ? (scrollTop / scrollH * 100) : 0) + '%';
    }
    window.addEventListener('scroll', updateProgress, { passive: true });
  }

  // Der Einblend-Effekt der Timeline-Eintraege ist eine reine, einmalige
  // CSS-Lade-Animation (siehe fcs-vereinsgeschichte.css, nth-of-type-Stagger) —
  // kein Scroll-/JS-Gate mehr, damit Inhalt nie von IntersectionObserver-
  // Timing oder Headless-Renderern abhaengt.

  // ── Active decade tracking in nav ───────────────────────────
  var navLinks   = document.querySelectorAll('.fcvg-nav__link');
  var decadeEls  = document.querySelectorAll('.fcvg-decade');

  var decadeObserver = new IntersectionObserver(
    function (entries) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) {
          var id = entry.target.id;
          navLinks.forEach(function (a) {
            a.classList.toggle('is-active', a.getAttribute('href') === '#' + id);
          });
        }
      });
    },
    { rootMargin: '-12% 0px -72% 0px' }
  );

  decadeEls.forEach(function (el) { decadeObserver.observe(el); });

  // ── Smooth scroll for nav links ──────────────────────────────
  navLinks.forEach(function (a) {
    a.addEventListener('click', function (e) {
      e.preventDefault();
      var target = document.querySelector(a.getAttribute('href'));
      if (!target) return;
      var nav    = document.getElementById('fcvgNav');
      var offset = nav ? nav.offsetHeight + 12 : 56;
      window.scrollTo({
        top: target.getBoundingClientRect().top + window.pageYOffset - offset,
        behavior: 'smooth'
      });
    });
  });

  // ── Hero stat counter animation ──────────────────────────────
  var statNums    = document.querySelectorAll('.fcvg-stat__num[data-count]');
  var statsEl     = document.querySelector('.fcvg-hero__stats');
  var counted     = false;

  function easeOutQuart(t) { return 1 - Math.pow(1 - t, 4); }

  function animateCount(el, target, duration) {
    var start = performance.now();
    (function tick(now) {
      var p = Math.min((now - start) / duration, 1);
      el.textContent = Math.round(easeOutQuart(p) * target);
      if (p < 1) requestAnimationFrame(tick);
    })(start);
  }

  if (statsEl && statNums.length) {
    var statsObserver = new IntersectionObserver(
      function (entries) {
        if (entries[0].isIntersecting && !counted) {
          counted = true;
          statNums.forEach(function (el, i) {
            var target = parseInt(el.getAttribute('data-count'), 10);
            setTimeout(function () { animateCount(el, target, 1600); }, i * 80);
          });
          statsObserver.disconnect();
        }
      },
      { threshold: 0.6 }
    );
    statsObserver.observe(statsEl);
  }

  // ── Lightbox ─────────────────────────────────────────────────
  var lb      = document.getElementById('fcvgLightbox');
  var lbImg   = document.getElementById('fcvgLbImg');
  var lbBack  = document.getElementById('fcvgLbBackdrop');
  var lbClose = document.getElementById('fcvgLbClose');

  function openLb(src, alt) {
    if (!lb) return;
    lbImg.src = src;
    lbImg.alt = alt || '';
    lb.classList.add('is-open');
    lb.setAttribute('aria-hidden', 'false');
    document.body.style.overflow = 'hidden';
    lb.focus();
  }

  function closeLb() {
    if (!lb) return;
    lb.classList.remove('is-open');
    lb.setAttribute('aria-hidden', 'true');
    document.body.style.overflow = '';
    setTimeout(function () { lbImg.src = ''; }, 320);
  }

  document.querySelectorAll('.fcvg-entry__img').forEach(function (wrap) {
    wrap.addEventListener('click', function () {
      var img = wrap.querySelector('img');
      if (img) openLb(img.src, img.alt);
    });
    wrap.addEventListener('keydown', function (e) {
      if (e.key === 'Enter' || e.key === ' ') {
        e.preventDefault();
        var img = wrap.querySelector('img');
        if (img) openLb(img.src, img.alt);
      }
    });
  });

  if (lbClose) lbClose.addEventListener('click', closeLb);
  if (lbBack)  lbBack.addEventListener('click', closeLb);
  document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape' && lb && lb.classList.contains('is-open')) closeLb();
  });

})();
