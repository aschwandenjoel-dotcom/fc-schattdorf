/* ================================================================
   Team-Umschalter der Juniorenseiten (page-junioren-team.php)
   ----------------------------------------------------------------
   Das Aufklappen macht <details> von sich aus. Hier kommt nur dazu,
   was Browser dabei nicht mitliefern: Schliessen bei einem Klick
   daneben und mit Escape.
   ================================================================ */
( function () {
	'use strict';

	function schliessen( ausser ) {
		var offen = document.querySelectorAll( 'details[data-fcjt-switch][open]' );
		for ( var i = 0; i < offen.length; i++ ) {
			if ( offen[ i ] !== ausser ) {
				offen[ i ].open = false;
			}
		}
	}

	document.addEventListener( 'click', function ( e ) {
		var innerhalb = e.target.closest ? e.target.closest( 'details[data-fcjt-switch]' ) : null;
		schliessen( innerhalb );
	} );

	document.addEventListener( 'keydown', function ( e ) {
		if ( 'Escape' !== e.key ) {
			return;
		}
		var offen = document.querySelector( 'details[data-fcjt-switch][open]' );
		if ( ! offen ) {
			return;
		}
		offen.open = false;
		var ausloeser = offen.querySelector( 'summary' );
		if ( ausloeser ) {
			ausloeser.focus();
		}
	} );
}() );
