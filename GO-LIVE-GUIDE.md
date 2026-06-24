# Go-Live Guide – FC Schattdorf Website

## Voraussetzungen
- Vereins-OK für Inhalte/Logo/Fotos
- Hosting-Account (Empfehlung: **Infomaniak** oder **Cyon** – CH-Hoster, DSGVO-konform)
- Domain `fcschattdorf.ch` (bereits registriert)

---

## Schritt 1 – Hosting einrichten (Infomaniak)

1. Login auf [infomaniak.com](https://www.infomaniak.com)
2. Neues **Web-Hosting** Paket erstellen (z.B. „Creator" ab CHF 5.75/Mt.)
3. **PHP-Version**: 8.2 oder neuer wählen
4. **MySQL-Datenbank** anlegen:
   - Name, Benutzer, Passwort notieren → in `wp-config-production.php` eintragen
5. **FTP-Zugangsdaten** bereithalten (oder SFTP)

---

## Schritt 2 – Migration (All-in-One WP Migration)

### Lokal: Export erstellen
```
Admin → All-in-One WP Migration → Export → Datei
→ Speichert als: fc-schattdorf-*.wpress
```

### Beim Hoster: WordPress frisch installieren
- Infomaniak bietet **1-Click WordPress Install** im Kundenbereich
- Nach Installation: Plugin „All-in-One WP Migration" installieren

### Import durchführen
```
Admin (Hoster) → All-in-One WP Migration → Import → Datei hochladen
→ Alle Daten werden überschrieben
```

> ⚠️ Falls die `.wpress`-Datei zu gross ist (>512 MB):
> Plugin „All-in-One WP Migration File Extension" gratis installieren
> → erhöht das Upload-Limit auf unbegrenzt

---

## Schritt 3 – URLs aktualisieren

Nach dem Import die URLs von `localhost:8090` auf `www.fcschattdorf.ch` umstellen:

```sql
-- Im phpMyAdmin oder via WP-CLI ausführen:
UPDATE wp_options SET option_value = 'https://www.fcschattdorf.ch'
  WHERE option_name IN ('siteurl', 'home');

UPDATE wp_posts SET
  post_content = REPLACE(post_content, 'http://localhost:8090', 'https://www.fcschattdorf.ch'),
  guid = REPLACE(guid, 'http://localhost:8090', 'https://www.fcschattdorf.ch');

UPDATE wp_postmeta SET meta_value =
  REPLACE(meta_value, 'http://localhost:8090', 'https://www.fcschattdorf.ch')
  WHERE meta_value LIKE '%localhost:8090%';
```

Oder via **WP-CLI** auf dem Server:
```bash
wp search-replace 'http://localhost:8090' 'https://www.fcschattdorf.ch' --all-tables
```

---

## Schritt 4 – wp-config.php anpassen

Datei `wp-config-production.php` umbenennen zu `wp-config.php` und ausfüllen:

```php
define('DB_NAME',     'infomaniak_db_name');
define('DB_USER',     'infomaniak_db_user');
define('DB_PASSWORD', 'infomaniak_db_passwort');
define('DB_HOST',     'localhost');  // bei Infomaniak meist 'localhost'

define('WP_HOME',    'https://www.fcschattdorf.ch');
define('WP_SITEURL', 'https://www.fcschattdorf.ch');
```

Neue Salts generieren: https://api.wordpress.org/secret-key/1.1/salt/

---

## Schritt 5 – SSL/HTTPS aktivieren

Infomaniak stellt **gratis Let's Encrypt SSL** bereit:
1. Kundenbereich → Domain → SSL-Zertifikat → Let's Encrypt aktivieren
2. In WordPress: Einstellungen → Allgemein → URLs auf `https://` umstellen
3. Weiterleitungsregel in `.htaccess` hinzufügen:

```apache
# HTTPS-Weiterleitung
RewriteEngine On
RewriteCond %{HTTPS} off
RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
```

---

## Schritt 6 – Echte Inhalte einpflegen

**Benötigt Vereins-OK:**
- [ ] Offizielles FC Schattdorf Logo hochladen
  → Admin → Design → Customizer → Website-Logo
- [ ] Mannschaftsfotos + Spielerfotos
- [ ] Originaltexte (Vereinsportrait, Vorstand, etc.)
- [ ] Sponsoren-Logos (mit Erlaubnis)
- [ ] Vorstandsliste aktualisieren

---

## Schritt 7 – Finaler Test auf Live-System

```
[ ] https://www.fcschattdorf.ch → Startseite lädt
[ ] https://www.fcschattdorf.ch/verein → Unterseite OK
[ ] https://www.fcschattdorf.ch/kontakt → Formular sendet
[ ] https://www.fcschattdorf.ch/wp-admin → Login funktioniert
[ ] SSL-Zertifikat gültig (Schloss-Symbol im Browser)
[ ] Google PageSpeed: > 70 Punkte
[ ] Mobile-Ansicht korrekt
```

---

## Schritt 8 – Nach Go-Live

| Aufgabe | Tool | Intervall |
|---------|------|-----------|
| Backups | UpdraftPlus | DB täglich, Dateien wöchentlich |
| Sicherheitsscan | Wordfence | wöchentlich automatisch |
| WordPress-Updates | Admin-Dashboard | sobald verfügbar |
| Plugin-Updates | Admin-Dashboard | wöchentlich prüfen |
| Google Analytics | GA4 einrichten | einmalig |
| Google Search Console | Sitemap einreichen | einmalig |

---

## Admin-Zugänge (lokal – vor Go-Live ändern!)

| | Lokal | Produktion |
|---|---|---|
| URL | http://localhost:8090/wp-admin | https://www.fcschattdorf.ch/wp-admin |
| Benutzername | admin | admin (ändern!) |
| Passwort | *(beim Setup gesetzt)* | **sicheres Passwort setzen!** |

> ⚠️ Admin-Passwort vor Go-Live unbedingt ändern!
> Admin → Benutzer → Profil → Passwort

---

## Empfohlene Hosting-Kosten (Infomaniak CH)

| Leistung | Paket | Preis |
|---------|-------|-------|
| Web-Hosting | Creator | ab CHF 5.75/Mt. |
| Domain `.ch` | – | ca. CHF 12/Jahr |
| SSL | Let's Encrypt | gratis |
| E-Mail | inkl. | im Paket |
| **Total** | | **ca. CHF 80–100/Jahr** |

---

*Erstellt: 24. Juni 2026 · FC Schattdorf Go-Live Guide v1.0*
