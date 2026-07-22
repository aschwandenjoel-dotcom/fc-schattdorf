<?php
/**
 * Template Name: Ehrenmitglieder
 * Template Post Type: page
 */
defined( 'ABSPATH' ) || exit;

add_action( 'wp_enqueue_scripts', function () {
    $dir = get_stylesheet_directory();
    $uri = get_stylesheet_directory_uri();
    wp_enqueue_style( 'fcs-ehrenmitglieder', $uri . '/assets/fcs-ehrenmitglieder.css', [], filemtime( $dir . '/assets/fcs-ehrenmitglieder.css' ) );
}, 5 );

add_filter( 'body_class', function ( $c ) { $c[] = 'fcx-wine-page'; return $c; } );

$ehrenpräsident = [
  [ 'name' => '† Inderbitzin Franz', 'ort' => 'Altdorf', 'geb' => '21.01.1907', 'jahr' => '1956', 'tod' => true ],
];

$ehrenmitglieder = [
  [ 'name' => '† Walker Josef',        'ort' => 'Schattdorf',    'geb' => '',           'jahr' => '' ],
  [ 'name' => '† Imholz Karl',         'ort' => 'Schattdorf',    'geb' => '24.11.1917', 'jahr' => '' ],
  [ 'name' => '† Stampfli Adelrich',   'ort' => 'Schattdorf',    'geb' => '11.05.1918', 'jahr' => '' ],
  [ 'name' => '† Bissig Josef',        'ort' => 'Schattdorf',    'geb' => '25.10.1915', 'jahr' => '' ],
  [ 'name' => '† Imholz Alois',        'ort' => 'Schattdorf',    'geb' => '26.03.1920', 'jahr' => '' ],
  [ 'name' => '† Inderkum Josef',      'ort' => 'Schattdorf',    'geb' => '',           'jahr' => '' ],
  [ 'name' => '† Denier Oswald',       'ort' => 'Altdorf',       'geb' => '',           'jahr' => '' ],
  [ 'name' => '† Zberg Anton',         'ort' => 'Schattdorf',    'geb' => '24.01.1915', 'jahr' => '' ],
  [ 'name' => '† Inderbitzin Robert',  'ort' => 'Schattdorf',    'geb' => '05.02.1918', 'jahr' => '' ],
  [ 'name' => '† Gisler Albert',       'ort' => 'Schattdorf',    'geb' => '',           'jahr' => '' ],
  [ 'name' => '† Stadler Robert',      'ort' => 'Horw',          'geb' => '07.09.1941', 'jahr' => '' ],
  [ 'name' => '† Zgraggen Nikolaus',   'ort' => 'Schattdorf',    'geb' => '06.04.1916', 'jahr' => '' ],
  [ 'name' => '† Moser Walter',        'ort' => 'Altdorf',       'geb' => '02.10.1935', 'jahr' => '' ],
  [ 'name' => '† Arnold Hans',         'ort' => 'Altdorf',       'geb' => '24.07.1928', 'jahr' => '' ],
  [ 'name' => '† Scheiber Josef',      'ort' => 'Altdorf',       'geb' => '09.04.1927', 'jahr' => '1981' ],
  [ 'name' => 'Gamma Hansruedi',       'ort' => 'Altdorf',       'geb' => '22.08.1938', 'jahr' => '1981' ],
  [ 'name' => '† Frei Oskar',          'ort' => 'Schattdorf',    'geb' => '28.10.1942', 'jahr' => '1981' ],
  [ 'name' => '† Zimmermann Melk',     'ort' => 'Schattdorf',    'geb' => '',           'jahr' => '' ],
  [ 'name' => '† Bissig Anton',        'ort' => 'Schattdorf',    'geb' => '05.01.1939', 'jahr' => '1983' ],
  [ 'name' => 'Gisler Ambros',         'ort' => 'Schattdorf',    'geb' => '26.03.1941', 'jahr' => '1984' ],
  [ 'name' => 'Bissig Ruedi',          'ort' => 'Schattdorf',    'geb' => '11.06.1941', 'jahr' => '1985' ],
  [ 'name' => '† Scheiber Ernst',      'ort' => 'Altdorf',       'geb' => '13.07.1940', 'jahr' => '1988' ],
  [ 'name' => '† Hüglin Karl',         'ort' => 'Altdorf',       'geb' => '11.07.1938', 'jahr' => '1989' ],
  [ 'name' => 'Walker Josef',          'ort' => 'Bürglen',       'geb' => '15.10.1941', 'jahr' => '1989' ],
  [ 'name' => '† Frei Anny',           'ort' => 'Schattdorf',    'geb' => '24.02.1920', 'jahr' => '1991/1993' ],
  [ 'name' => 'Stampfli Ady',          'ort' => 'Schattdorf',    'geb' => '06.04.1949', 'jahr' => '1987/1994' ],
  [ 'name' => 'Müller Ruedi',          'ort' => 'Schattdorf',    'geb' => '10.09.1945', 'jahr' => '1982/1995' ],
  [ 'name' => '† Gamma Robert',        'ort' => 'Schattdorf',    'geb' => '22.08.1936', 'jahr' => '1983/1997' ],
  [ 'name' => 'Müller Kurt',           'ort' => 'Ibach',         'geb' => '06.06.1948', 'jahr' => '1994/2002' ],
  [ 'name' => 'Arnold Anton',          'ort' => 'Altdorf',       'geb' => '14.06.1953', 'jahr' => '1999/2003' ],
  [ 'name' => '† Arnold Ruedy',        'ort' => 'Schattdorf',    'geb' => '21.05.1952', 'jahr' => '1996/2003' ],
  [ 'name' => 'Berger Hanspeter',      'ort' => 'Schattdorf',    'geb' => '23.05.1951', 'jahr' => '1997/2003' ],
  [ 'name' => 'Méroz Fritz',           'ort' => 'Altdorf',       'geb' => '26.07.1956', 'jahr' => '1996/2003' ],
  [ 'name' => 'Locher Christoph',      'ort' => 'Schattdorf',    'geb' => '17.12.1951', 'jahr' => '1999/2004' ],
  [ 'name' => 'Muoser Jost',           'ort' => 'Flüelen',       'geb' => '26.10.1959', 'jahr' => '1998/2004' ],
  [ 'name' => 'Tresch Beny',           'ort' => 'Schattdorf',    'geb' => '03.07.1960', 'jahr' => '1998/2004' ],
  [ 'name' => 'Hauger Martin',         'ort' => 'Unterschächen', 'geb' => '26.07.1949', 'jahr' => '1999/2005' ],
  [ 'name' => '† Walker Urs',          'ort' => 'Bürglen',       'geb' => '21.02.1961', 'jahr' => '1997/2005' ],
  [ 'name' => '† Aschwanden Paul',     'ort' => 'Schattdorf',    'geb' => '05.12.1952', 'jahr' => '1999/2006' ],
  [ 'name' => 'Gisler Wisi',           'ort' => 'Schattdorf',    'geb' => '03.06.1959', 'jahr' => '2001/2007' ],
  [ 'name' => 'Müller Patrik',         'ort' => 'Schattdorf',    'geb' => '21.10.1969', 'jahr' => '2003/2008' ],
  [ 'name' => 'Hüglin René',           'ort' => 'Bürglen',       'geb' => '25.04.1969', 'jahr' => '2000/2009' ],
  [ 'name' => '† Zamuner Guido',       'ort' => 'Schattdorf',    'geb' => '18.04.1943', 'jahr' => '1996/2009' ],
  [ 'name' => 'Scheiber Benschi',      'ort' => 'Altdorf',       'geb' => '20.10.1970', 'jahr' => '2011' ],
  [ 'name' => 'Arnold Karl',           'ort' => 'Altdorf',       'geb' => '27.10.1958', 'jahr' => '2001/2012' ],
  [ 'name' => 'Zamuner Sandro',        'ort' => 'Altdorf',       'geb' => '18.02.1969', 'jahr' => '2012' ],
  [ 'name' => 'Gisler Stephan',        'ort' => 'Schattdorf',    'geb' => '12.03.1968', 'jahr' => '2004/2014' ],
  [ 'name' => 'Bomatter Wisi',         'ort' => 'Schattdorf',    'geb' => '04.07.1957', 'jahr' => '2000/2014' ],
  [ 'name' => 'Bissig Walter',         'ort' => 'Altdorf',       'geb' => '13.07.1944', 'jahr' => '1983/2014' ],
  [ 'name' => 'Scheiber Heidi',        'ort' => 'Altdorf',       'geb' => '01.02.1966', 'jahr' => '2015' ],
  [ 'name' => 'Zurfluh Roger',         'ort' => 'Schattdorf',    'geb' => '25.08.1973', 'jahr' => '2015' ],
  [ 'name' => 'Schillig Hans',         'ort' => 'Schattdorf',    'geb' => '31.12.1954', 'jahr' => '2016' ],
  [ 'name' => 'Trovatelli Mario',      'ort' => 'Bürglen',       'geb' => '17.01.1980', 'jahr' => '2018' ],
  [ 'name' => 'Büchi Roland',          'ort' => 'Schattdorf',    'geb' => '17.05.1967', 'jahr' => '2019' ],
  [ 'name' => 'Bissig Iwan',           'ort' => 'Schattdorf',    'geb' => '09.09.1973', 'jahr' => '2019' ],
  [ 'name' => 'Gnos René',             'ort' => 'Schattdorf',    'geb' => '27.07.1981', 'jahr' => '2019' ],
  [ 'name' => '† Bissig Othmar',       'ort' => 'Schattdorf',    'geb' => '20.01.1962', 'jahr' => '2020' ],
  [ 'name' => 'Bissig Ivo',            'ort' => 'Schattdorf',    'geb' => '24.04.1974', 'jahr' => '2022' ],
  [ 'name' => 'Deplazes René',         'ort' => 'Bürglen',       'geb' => '09.08.1968', 'jahr' => '2024' ],
  [ 'name' => 'Herger Iwan',           'ort' => 'Altdorf',       'geb' => '28.03.1981', 'jahr' => '2025' ],
];

$freimitglieder = [
  [ 'name' => '† Herger Alois',             'ort' => 'Schattdorf', 'geb' => '04.03.1917', 'jahr' => '' ],
  [ 'name' => '† Inderbitzin Edy',          'ort' => 'Altdorf',    'geb' => '21.02.1922', 'jahr' => '' ],
  [ 'name' => '† Herger Josef',             'ort' => 'Schattdorf', 'geb' => '18.06.1926', 'jahr' => '' ],
  [ 'name' => '† Müller Josef',             'ort' => 'Schattdorf', 'geb' => '',           'jahr' => '' ],
  [ 'name' => '† Baumann Hans',             'ort' => 'Schattdorf', 'geb' => '01.06.1924', 'jahr' => '' ],
  [ 'name' => '† Zberg Hans',               'ort' => 'Schattdorf', 'geb' => '21.05.1923', 'jahr' => '' ],
  [ 'name' => '† Zurfluh Franz',            'ort' => 'Schattdorf', 'geb' => '01.08.1924', 'jahr' => '' ],
  [ 'name' => '† Furger Josef',             'ort' => 'Schattdorf', 'geb' => '17.05.1925', 'jahr' => '' ],
  [ 'name' => '† Zimmermann Emil',          'ort' => 'Schattdorf', 'geb' => '06.11.1924', 'jahr' => '' ],
  [ 'name' => '† Stadler Thomas',           'ort' => 'Arzano',     'geb' => '18.12.1936', 'jahr' => '' ],
  [ 'name' => 'Muoser Martin',              'ort' => 'Schattdorf', 'geb' => '04.03.1939', 'jahr' => '' ],
  [ 'name' => 'Gisler Oskar',               'ort' => 'Erstfeld',   'geb' => '22.12.1941', 'jahr' => '' ],
  [ 'name' => 'Walker Albert',              'ort' => 'Altdorf',    'geb' => '15.10.1941', 'jahr' => '' ],
  [ 'name' => 'Zurfluh Walter',             'ort' => 'Altdorf',    'geb' => '01.08.1942', 'jahr' => '' ],
  [ 'name' => 'Zgraggen Jakob',             'ort' => 'Schattdorf', 'geb' => '30.11.1939', 'jahr' => '' ],
  [ 'name' => '† Imholz Noldi',             'ort' => 'Schattdorf', 'geb' => '28.06.1929', 'jahr' => '1982' ],
  [ 'name' => 'Gamma Hans',                 'ort' => 'Baar',       'geb' => '26.11.1946', 'jahr' => '1982' ],
  [ 'name' => '† Zgraggen Hansbeat',        'ort' => 'Schattdorf', 'geb' => '02.05.1946', 'jahr' => '1982' ],
  [ 'name' => '† Tresch Karl',              'ort' => 'Schattdorf', 'geb' => '22.05.1947', 'jahr' => '1983' ],
  [ 'name' => 'Bissig Oskar',               'ort' => 'Schattdorf', 'geb' => '23.05.1947', 'jahr' => '1984' ],
  [ 'name' => 'Scheiber Ruedi',             'ort' => 'Schattdorf', 'geb' => '21.09.1947', 'jahr' => '1984' ],
  [ 'name' => '† Arnold Josef',             'ort' => 'Schattdorf', 'geb' => '26.09.1945', 'jahr' => '1986' ],
  [ 'name' => 'Bissig Hanspeter',           'ort' => 'Schattdorf', 'geb' => '16.09.1951', 'jahr' => '1988' ],
  [ 'name' => 'Zurfluh Paul',               'ort' => 'Attinghausen','geb'=> '22.07.1945', 'jahr' => '1990' ],
  [ 'name' => 'Imholz Daniela',             'ort' => 'Schattdorf', 'geb' => '20.09.1959', 'jahr' => '1991' ],
  [ 'name' => '† Jauch Werner',             'ort' => 'Schattdorf', 'geb' => '25.02.1944', 'jahr' => '1993' ],
  [ 'name' => '† Lorenzoni Werner',         'ort' => 'Göschenen',  'geb' => '02.04.1935', 'jahr' => '1993' ],
  [ 'name' => 'Imholz Stefan',              'ort' => 'Altdorf',    'geb' => '20.04.1957', 'jahr' => '1994' ],
  [ 'name' => '† Morg Adi',                 'ort' => 'Altdorf',    'geb' => '18.09.1944', 'jahr' => '1995' ],
  [ 'name' => 'Scheiber Ursula',            'ort' => 'Schattdorf', 'geb' => '10.04.1946', 'jahr' => '1995' ],
  [ 'name' => '† Welti Anton',              'ort' => 'Schattdorf', 'geb' => '15.06.1926', 'jahr' => '1996' ],
  [ 'name' => 'Zenklusen Fritz',            'ort' => 'Schattdorf', 'geb' => '06.01.1947', 'jahr' => '1996' ],
  [ 'name' => '† Trovatelli Leo',           'ort' => 'Altdorf',    'geb' => '09.07.1951', 'jahr' => '1997' ],
  [ 'name' => 'Imhof Heinz',                'ort' => 'Altdorf',    'geb' => '18.03.1958', 'jahr' => '1998' ],
  [ 'name' => 'Merenda Flavio',             'ort' => 'Schattdorf', 'geb' => '09.11.1964', 'jahr' => '1998' ],
  [ 'name' => '† Stadler Erwin',            'ort' => 'Schattdorf', 'geb' => '17.09.1937', 'jahr' => '1998' ],
  [ 'name' => 'Tresch Stefan',              'ort' => 'Schattdorf', 'geb' => '24.03.1953', 'jahr' => '1998' ],
  [ 'name' => 'Zimmermann Hans',            'ort' => 'Schattdorf', 'geb' => '06.10.1959', 'jahr' => '1998' ],
  [ 'name' => 'Binaghi Gianni',             'ort' => 'Schattdorf', 'geb' => '29.08.1948', 'jahr' => '1999' ],
  [ 'name' => '† Gisler Alois',             'ort' => 'Schattdorf', 'geb' => '02.01.1929', 'jahr' => '1999' ],
  [ 'name' => 'Stampfli-Gisler Marie-Theres','ort'=> 'Schattdorf', 'geb' => '03.06.1952', 'jahr' => '1999' ],
  [ 'name' => 'Tresch Agi',                 'ort' => 'Schattdorf', 'geb' => '31.05.1955', 'jahr' => '1999' ],
  [ 'name' => '† Fleischmann Peter',        'ort' => 'Altdorf',    'geb' => '07.05.1955', 'jahr' => '2000' ],
  [ 'name' => 'Müller Josef',               'ort' => 'Schattdorf', 'geb' => '20.07.1954', 'jahr' => '2000' ],
  [ 'name' => 'Wipfli Kurt',                'ort' => 'Bürglen',    'geb' => '22.03.1959', 'jahr' => '2000' ],
  [ 'name' => 'Locher-Stampfli Gaby',       'ort' => 'Schattdorf', 'geb' => '24.10.1955', 'jahr' => '2001' ],
  [ 'name' => 'Arnold-Tresch Gabi',         'ort' => 'Schattdorf', 'geb' => '06.02.1972', 'jahr' => '2002' ],
  [ 'name' => 'Geisser Lisa',               'ort' => 'Schattdorf', 'geb' => '21.01.1958', 'jahr' => '2002' ],
  [ 'name' => 'Geisser Martin',             'ort' => 'Schattdorf', 'geb' => '16.01.1959', 'jahr' => '2002' ],
  [ 'name' => 'Zberg Franz',                'ort' => 'Altdorf',    'geb' => '30.03.1950', 'jahr' => '2002' ],
  [ 'name' => 'Philipp Werner',             'ort' => 'Schattdorf', 'geb' => '21.08.1963', 'jahr' => '2003' ],
  [ 'name' => 'Planzer Peter',              'ort' => 'Schattdorf', 'geb' => '05.09.1958', 'jahr' => '2003' ],
  [ 'name' => 'Planzer Ruedi',              'ort' => 'Schattdorf', 'geb' => '04.06.1956', 'jahr' => '2003' ],
  [ 'name' => 'Gisler Oskar',               'ort' => 'Bürglen',    'geb' => '14.06.1965', 'jahr' => '2004' ],
  [ 'name' => 'Gisler Werner',              'ort' => 'Schattdorf', 'geb' => '09.12.1965', 'jahr' => '2004' ],
  [ 'name' => 'Stampfli Iwan',              'ort' => 'Schattdorf', 'geb' => '15.02.1962', 'jahr' => '2004' ],
  [ 'name' => 'Stampfli Paulo',             'ort' => 'Schattdorf', 'geb' => '05.01.1964', 'jahr' => '2004' ],
  [ 'name' => 'Schibli Bernhard',           'ort' => 'Altdorf',    'geb' => '23.09.1957', 'jahr' => '2005' ],
  [ 'name' => 'Trovatelli Ruth',            'ort' => 'Altdorf',    'geb' => '19.04.1957', 'jahr' => '2005' ],
  [ 'name' => 'Welti-Arnold Theres',        'ort' => 'Schattdorf', 'geb' => '21.08.1955', 'jahr' => '2005' ],
  [ 'name' => 'Ziegler Karl',               'ort' => 'Schattdorf', 'geb' => '21.05.1952', 'jahr' => '2005' ],
  [ 'name' => 'Bissig Josef',               'ort' => 'Schattdorf', 'geb' => '15.04.1945', 'jahr' => '2006' ],
  [ 'name' => '† Bissig Werner',            'ort' => 'Schattdorf', 'geb' => '08.06.1937', 'jahr' => '2006' ],
  [ 'name' => 'Büchi Roland',               'ort' => 'Schattdorf', 'geb' => '17.05.1967', 'jahr' => '2006' ],
  [ 'name' => 'Gisler Adalbert',            'ort' => 'Schattdorf', 'geb' => '24.10.1946', 'jahr' => '2006' ],
  [ 'name' => 'Jusufovic Ferid',            'ort' => 'Schattdorf', 'geb' => '02.06.1958', 'jahr' => '2006' ],
  [ 'name' => 'Scheiber Karl',              'ort' => 'Schattdorf', 'geb' => '03.09.1946', 'jahr' => '2006' ],
  [ 'name' => 'Thöny Trudi',                'ort' => 'Schattdorf', 'geb' => '23.07.1953', 'jahr' => '2006' ],
  [ 'name' => 'Welti Martin',               'ort' => 'Schattdorf', 'geb' => '11.03.1953', 'jahr' => '2006' ],
  [ 'name' => 'Zgraggen-Stampfli Petra',    'ort' => 'Schattdorf', 'geb' => '29.12.1973', 'jahr' => '2006' ],
  [ 'name' => 'Bissig Iwan',                'ort' => 'Schattdorf', 'geb' => '09.09.1973', 'jahr' => '2007' ],
  [ 'name' => '† Bissig Othmar',            'ort' => 'Schattdorf', 'geb' => '20.01.1962', 'jahr' => '2007' ],
  [ 'name' => 'Zurfluh Alois',              'ort' => 'Schattdorf', 'geb' => '27.01.1954', 'jahr' => '2007' ],
  [ 'name' => 'Trovatelli Mario',           'ort' => 'Bürglen',    'geb' => '17.01.1980', 'jahr' => '2008' ],
  [ 'name' => 'Bachmann Werner',            'ort' => 'Schattdorf', 'geb' => '25.09.1959', 'jahr' => '2009' ],
  [ 'name' => 'Deplazes René',              'ort' => 'Bürglen',    'geb' => '09.08.1968', 'jahr' => '2009' ],
  [ 'name' => 'Schillig Hans',              'ort' => 'Haldi',      'geb' => '31.12.1954', 'jahr' => '2009' ],
  [ 'name' => 'Shortiss Patrick',           'ort' => 'Schattdorf', 'geb' => '22.12.1964', 'jahr' => '2009' ],
  [ 'name' => 'Traxel Fredy',               'ort' => 'Attinghausen','geb'=> '18.09.1962', 'jahr' => '2009' ],
  [ 'name' => 'Planzer Jost',               'ort' => 'Bürglen',    'geb' => '22.10.1966', 'jahr' => '2010' ],
  [ 'name' => 'Montaquilla Roberto',        'ort' => 'Schattdorf', 'geb' => '19.11.1966', 'jahr' => '2010' ],
  [ 'name' => 'Bertolosi Hans',             'ort' => 'Schattdorf', 'geb' => '18.02.1966', 'jahr' => '2010' ],
  [ 'name' => 'Bissig-Jauch Claudia',       'ort' => 'Schattdorf', 'geb' => '14.08.1975', 'jahr' => '2010' ],
  [ 'name' => 'Gnos René',                  'ort' => 'Schattdorf', 'geb' => '27.07.1981', 'jahr' => '2011' ],
  [ 'name' => 'Zgraggen André',             'ort' => 'Bürglen',    'geb' => '16.03.1972', 'jahr' => '2012' ],
  [ 'name' => 'Schelbert André',            'ort' => 'Altdorf',    'geb' => '13.04.1983', 'jahr' => '2012' ],
  [ 'name' => 'Scheiber Roland',            'ort' => 'Schattdorf', 'geb' => '13.04.1983', 'jahr' => '2012' ],
  [ 'name' => 'Reichmuth Dani',             'ort' => 'Schattdorf', 'geb' => '25.04.1975', 'jahr' => '2012' ],
  [ 'name' => 'Gnos Pia',                   'ort' => 'Schattdorf', 'geb' => '09.04.1949', 'jahr' => '2013' ],
  [ 'name' => '† Gnos Walter',              'ort' => 'Schattdorf', 'geb' => '03.03.1947', 'jahr' => '2013' ],
  [ 'name' => 'Baumann Peter',              'ort' => 'Schattdorf', 'geb' => '02.10.1965', 'jahr' => '2013' ],
  [ 'name' => 'Mahrow Kai',                 'ort' => 'Bürglen',    'geb' => '22.10.1961', 'jahr' => '2015' ],
  [ 'name' => 'Enz Michi',                  'ort' => 'Schattdorf', 'geb' => '10.02.1982', 'jahr' => '2015' ],
  [ 'name' => 'Gnos Claudio',               'ort' => 'Schattdorf', 'geb' => '07.11.1972', 'jahr' => '2015' ],
  [ 'name' => 'Bissig Ivo',                 'ort' => 'Altdorf',    'geb' => '24.04.1974', 'jahr' => '2015' ],
  [ 'name' => 'Baumann Damian',             'ort' => 'Altdorf',    'geb' => '08.05.1975', 'jahr' => '2016' ],
  [ 'name' => 'Zgraggen Remo',              'ort' => 'Schattdorf', 'geb' => '22.10.1973', 'jahr' => '2016' ],
  [ 'name' => 'Gnos Daniel',                'ort' => '',           'geb' => '17.10.1986', 'jahr' => '2017' ],
  [ 'name' => 'Herger Iwan',                'ort' => 'Schattdorf', 'geb' => '28.03.1981', 'jahr' => '2017' ],
  [ 'name' => 'Inderkum Christoph',         'ort' => '',           'geb' => '17.02.1987', 'jahr' => '2017' ],
  [ 'name' => 'Scheiber Josef',             'ort' => '',           'geb' => '03.06.1940', 'jahr' => '2017' ],
  [ 'name' => 'Bomatter Ralph',             'ort' => 'Schattdorf', 'geb' => '15.11.1989', 'jahr' => '2018' ],
  [ 'name' => 'Infanger Reto',              'ort' => 'Schattdorf', 'geb' => '05.08.1992', 'jahr' => '2019' ],
  [ 'name' => 'Zberg Thomas',               'ort' => 'Schattdorf', 'geb' => '11.03.1978', 'jahr' => '2019' ],
  [ 'name' => 'Truttmann Petra',            'ort' => 'Altdorf',    'geb' => '04.01.1971', 'jahr' => '2020' ],
  [ 'name' => 'Imholz Karl',                'ort' => 'Altdorf',    'geb' => '20.04.1957', 'jahr' => '2020' ],
  [ 'name' => 'Britschgi Marino',           'ort' => 'Schattdorf', 'geb' => '27.03.1987', 'jahr' => '2021' ],
  [ 'name' => 'Geisser Ruedi',              'ort' => 'Schattdorf', 'geb' => '30.09.1954', 'jahr' => '2022' ],
  [ 'name' => 'Küttel Jasmin',              'ort' => 'Schattdorf', 'geb' => '12.05.1973', 'jahr' => '2023' ],
  [ 'name' => 'Schorno Patrick',            'ort' => 'Altdorf',    'geb' => '15.04.1976', 'jahr' => '2024' ],
  [ 'name' => 'Merenda Fabrizio',           'ort' => 'Schattdorf', 'geb' => '21.06.1978', 'jahr' => '2025' ],
];

function fcs_ehren_row( $p ) {
    $dead = str_starts_with( $p['name'], '†' );
    $cls  = $dead ? ' class="row--deceased"' : '';
    return '<tr' . $cls . '>'
         . '<td>' . esc_html( $p['name'] ) . '</td>'
         . '<td>' . esc_html( $p['ort'] ) . '</td>'
         . '<td>' . esc_html( $p['geb'] ) . '</td>'
         . '<td>' . esc_html( $p['jahr'] ) . '</td>'
         . '</tr>';
}

get_header();
?>

<div class="fcem-page">

  <!-- ── Hero ── -->
  <div class="fcem-hero">
    <div class="fcem-hero__eyebrow">FC Schattdorf &mdash; seit 1926</div>
    <h1 class="fcem-hero__title">
      <span class="fcem-hero__line1">Ehren- &amp;</span>
      <span class="fcem-hero__line2">Freimitglieder</span>
    </h1>
    <div class="fcem-hero__redline"></div>
  </div>

  <!-- ── Stats ── -->
  <div class="fcem-stats">
    <div class="fcem-stats__item">
      <div class="fcem-stats__num">1</div>
      <div class="fcem-stats__label">Ehrenpräsident</div>
    </div>
    <div class="fcem-stats__sep"></div>
    <div class="fcem-stats__item">
      <div class="fcem-stats__num"><?php echo count($ehrenmitglieder); ?></div>
      <div class="fcem-stats__label">Ehrenmitglieder</div>
    </div>
    <div class="fcem-stats__sep"></div>
    <div class="fcem-stats__item">
      <div class="fcem-stats__num"><?php echo count($freimitglieder); ?></div>
      <div class="fcem-stats__label">Freimitglieder</div>
    </div>
  </div>

  <!-- ── Ehrenpräsident ── -->
  <div class="fcem-block">
    <div class="fcem-block__header">
      <span class="fcem-block__tag">Ehrenpräsident</span>
    </div>
    <table class="fcem-table">
      <thead><tr><th>Name / Vorname</th><th>Wohnort</th><th>Geburtsdatum</th><th>Wahljahr</th></tr></thead>
      <tbody>
        <tr><td>† Inderbitzin Franz</td><td>Altdorf</td><td>21.01.1907</td><td>1956</td></tr>
      </tbody>
    </table>
  </div>

  <!-- ── Ehrenmitglieder ── -->
  <div class="fcem-block">
    <div class="fcem-block__header">
      <span class="fcem-block__tag">Ehrenmitglieder</span>
    </div>
    <table class="fcem-table">
      <thead><tr><th>Name / Vorname</th><th>Wohnort</th><th>Geburtsdatum</th><th>Wahljahr</th></tr></thead>
      <tbody>
        <?php foreach ( $ehrenmitglieder as $p ) echo fcs_ehren_row( $p ); ?>
      </tbody>
    </table>
  </div>

  <!-- ── Freimitglieder ── -->
  <div class="fcem-block">
    <div class="fcem-block__header">
      <span class="fcem-block__tag">Freimitglieder</span>
    </div>
    <table class="fcem-table">
      <thead><tr><th>Name / Vorname</th><th>Wohnort</th><th>Geburtsdatum</th><th>Wahljahr</th></tr></thead>
      <tbody>
        <?php foreach ( $freimitglieder as $p ) echo fcs_ehren_row( $p ); ?>
      </tbody>
    </table>
  </div>

  <div class="fcem-footer-note">&dagger; = verstorben</div>

</div><!-- .fcem-page -->

<?php get_footer(); ?>
