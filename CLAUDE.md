# FC Schattdorf – Entwicklungsumgebung

WordPress-Site des FC Schattdorf. Lokal via Docker (`docker compose up -d`,
Colima muss laufen), live auf Hostpoint (https://fcschattdorf.dynalias.net).

**Offener Stand und Rechnerwechsel: `UEBERGABE.md`** — dort steht, was
gerade live ist, welcher Deploy noch aussteht und was auf einem neuen
Rechner eingerichtet werden muss. Nach erledigten Schritten nachführen.

## WICHTIG: Vor jeder lokalen Arbeit zuerst die Produktions-DB holen

Die **Live-Datenbank ist die Quelle der Wahrheit** — die Redaktion pflegt
Inhalte (Chronik, Sponsoren, Ehrungen, Personen, Events, Produkte,
Seitenfelder) im Live-Admin. Die lokale DB veraltet dadurch laufend.

**Regel: Zu Beginn jeder Session mit lokaler Arbeit an Inhalten, Vorlagen
oder Datenbank zuerst ausführen:**

```
./scripts/pull-prod-db.sh
```

Das Skript sichert vorher die lokale DB nach `backups/`, holt den
Live-Stand über ein token-geschütztes Web-Export-Skript (MySQL ist auf
Hostpoint nur aus Web-Prozessen erreichbar) und schreibt die URLs auf
`localhost:8080` um. Ausnahme: reine Code-Reviews/Recherchen ohne
DB-Bezug brauchen keinen Pull. Uploads/Medien synchronisiert das Skript
nicht (Hinweis im Skript-Kopf).

## Architektur (Stand Juli 2026)

- **Child-Theme** `wp-content/themes/fcschattdorf-child` — einzige
  versionierte Code-Basis. Module `inc/fcs-*.php` werden von
  functions.php per Glob geladen.
- **Inhaltstypen** (je ein Modul in `inc/`): fcs_chronik, fcs_sponsor,
  fcs_ehrung, fcs_person, fcs_event, fcs_produkt.
- **Feld-Box «Seiteninhalte»** (`inc/fcs-page-fields.php`): pflegbare
  Textbausteine für Design-Vorlagen; Konfiguration pro Vorlage über
  Filter `fcs_page_fields_config` in `inc/fcs-fields-*.php`.
- Vorlagen enthalten KEINE hartkodierten Inhalte mehr — neue Inhalte
  gehören in CPTs oder Seitenfelder, nie in PHP-Arrays.

## Deployment

- Theme-Code: `rsync -avz wp-content/themes/fcschattdorf-child/
  aziwivac@sl1819.web.hostpoint.ch:www/fcschattdorf/wp-content/themes/fcschattdorf-child/`
  (Cache-Busting via filemtime automatisch). SSH ist für Claude
  gesperrt — Deploy-Skript vorbereiten, der Nutzer führt es aus.
- DB-Änderungen Richtung live: token-geschütztes PHP-Skript in den
  Webroot legen, per HTTPS auslösen, danach löschen (MySQL ist auf
  Hostpoint nur aus Web-Prozessen erreichbar). Lebendes Beispiel für
  den Mechanismus: `deploy/fcs-db-export.php.tpl` (Export-Richtung).
  Niemals die lokale DB blind über die Live-DB stülpen.
- Nach Live-Import: Verifikations-Checks ~1 Minute warten
  (Hostpoint-Seitencache liefert sonst Fehlalarme).

## Backups

`./scripts/backup.sh` — DB + Uploads nach `backups/` und OneDrive.
Vor riskanten Änderungen immer ausführen.
