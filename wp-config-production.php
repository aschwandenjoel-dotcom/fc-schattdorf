<?php
/**
 * wp-config.php für Produktionsumgebung – FC Schattdorf
 * ACHTUNG: Datenbankzugangsdaten beim Hoster anpassen!
 */

// === DATENBANK (beim Hoster anpassen) ===
define('DB_NAME',     'DEIN_DB_NAME');
define('DB_USER',     'DEIN_DB_USER');
define('DB_PASSWORD', 'DEIN_DB_PASSWORT');
define('DB_HOST',     'localhost');
define('DB_CHARSET',  'utf8mb4');
define('DB_COLLATE',  'utf8mb4_unicode_ci');

// === SICHERHEITS-SALTS (neu generiert – nicht ändern) ===
// Diese Salts via https://api.wordpress.org/secret-key/1.1/salt/ neu generieren
define('AUTH_KEY',         'HIER_SALT_EINFÜGEN');
define('SECURE_AUTH_KEY',  'HIER_SALT_EINFÜGEN');
define('LOGGED_IN_KEY',    'HIER_SALT_EINFÜGEN');
define('NONCE_KEY',        'HIER_SALT_EINFÜGEN');
define('AUTH_SALT',        'HIER_SALT_EINFÜGEN');
define('SECURE_AUTH_SALT', 'HIER_SALT_EINFÜGEN');
define('LOGGED_IN_SALT',   'HIER_SALT_EINFÜGEN');
define('NONCE_SALT',       'HIER_SALT_EINFÜGEN');

// === URLS (nach Migration anpassen) ===
define('WP_HOME',    'https://www.fcschattdorf.ch');
define('WP_SITEURL', 'https://www.fcschattdorf.ch');

// === PRODUKTION: Debug AUS ===
define('WP_DEBUG',         false);
define('WP_DEBUG_LOG',     false);
define('WP_DEBUG_DISPLAY', false);

// === PERFORMANCE ===
define('WP_MEMORY_LIMIT',     '256M');
define('WP_MAX_MEMORY_LIMIT', '512M');
define('COMPRESS_SCRIPTS',    true);
define('COMPRESS_CSS',        true);

// === SICHERHEIT ===
define('DISALLOW_FILE_EDIT',   true);  // Editor im Admin deaktivieren
define('FORCE_SSL_ADMIN',      true);  // Admin immer über HTTPS
define('WP_AUTO_UPDATE_CORE',  'minor'); // Minor Updates automatisch

// === DATENBANK-TABELLEN-PREFIX (Standard: wp_) ===
$table_prefix = 'wp_';

// === ABSPANN ===
if ( ! defined('ABSPATH') ) {
    define('ABSPATH', __DIR__ . '/');
}
require_once ABSPATH . 'wp-settings.php';
