# Projektplan – FC Schattdorf Website (1:1-Nachbau mit WordPress)

Ziel: Die bestehende Seite **www.fcschattdorf.ch** strukturell und funktional 1:1
mit WordPress + Fussball-Erweiterungen nachbauen und **lokal** lauffähig aufsetzen.

> ⚖️ **Rechtlicher Hinweis:** *Struktur, Aufbau und Funktion* nachbauen ist
> unproblematisch. **Logo, Fotos und Originaltexte** sind urheber-/markenrechtlich
> geschützt – diese nur verwenden, wenn der Nachbau **für den FC Schattdorf selbst**
> erfolgt bzw. mit dessen Einverständnis. Sonst Platzhalter verwenden.

---

## 1. Soll-Struktur (Sitemap, exakt wie Original)

```
Home
News                         (Beiträge / Blog)
Verein
 ├─ Vorstand
 ├─ Mitglied werden
 ├─ Fanshop
 ├─ Sportanlagen
 ├─ Schiedsrichter
 ├─ Ehren- und Freimitglieder
 ├─ Vereinsgeschichte
 ├─ So finden Sie uns
 └─ Vorfall / Verdacht melden
Helfereinsätze
Aktive
 ├─ 1. Mannschaft
 ├─ 2. Mannschaft
 ├─ 3. Mannschaft
 ├─ Frauen Team Uri I
 ├─ Frauen Team Uri II
 └─ Senioren Team Uri I
Junioren
 ├─ Juniorengeschichte
 ├─ Organisation
 ├─ Teams  (A, Ba, Bb, Ca, Cb, Da–Df, Ea/Eb, Ec, Ed/Ee, Ef,
 │          Uri FF11, Fa/Fb/Fc/Fd, Fe/Ff  – 18 Teams)
 ├─ Betreuer
 ├─ Goalietraining
 ├─ Fussballschule
 ├─ Trainingslager
 ├─ Betreuer werden
 ├─ Juniorenkonzept
 └─ Fussball Tauschbörse  (externer WhatsApp-Link)
Events
 ├─ Events
 └─ Dorf- und Grümpelturnier
Sponsoren
Kontakt
```

---

## 2. Funktions-Mapping: Original → WordPress-Lösung

| Funktion im Original        | Umsetzung in WordPress                                   |
|-----------------------------|---------------------------------------------------------|
| News / Matchberichte        | WordPress-**Beiträge** + Kategorien je Team             |
| Teams, Kader, Spielerprofile| **SportsPress** (Teams, Players, Staff)                 |
| Tabellen, Spielpläne, Resultate | **ifv.ch-Matchcenter** als iFrame/Widget einbetten  |
| Liveticker                  | **Tickaroo**-Embed (Shortcode/iFrame)                   |
| Events / Turniere           | **The Events Calendar**                                 |
| Kontakt / Anmeldungen       | **Fluent Forms** (Mitglied werden, Betreuer werden, Vorfall melden) |
| Newsletter                  | **MailPoet** (oder Mailchimp-Embed wie Original)        |
| Sponsoren (mehrstufig)      | Custom Post Type **Sponsor** + Taxonomie „Stufe"        |
| Fanshop                     | Link/Seite (später optional **WooCommerce**)            |
| Helfereinsätze              | Seite + Formular (später optional Buchungs-Plugin)      |
| Social Media                | Footer-Icons (Facebook/Instagram)                       |
| SEO                         | **Yoast SEO**                                           |
| Mehrsprachig (nur DE)       | nicht nötig                                             |

### Sponsoring-Stufen (Taxonomie „Stufe")
- Hauptsponsor · Nachwuchs-Patronat · Co-Sponsoren · Club-Sponsoren · Nachwuchs-Sponsoren

---

## 3. Technischer Aufbau (bereits vorhanden ✅ / geplant ⬜)

- ✅ Docker-Umgebung (MariaDB, WordPress, WP-CLI, Adminer)
- ✅ Astra + Child-Theme `fcschattdorf-child`
- ✅ Setup-Skript-Grundgerüst, Git-Repo, README
- ⬜ Erweiterte Plugin-Liste (SportsPress + Add-ons, Custom Post Types)
- ⬜ Vollständige hierarchische Seitenstruktur + Menüs (statt flach)
- ⬜ SportsPress-Konfiguration (Saison, Ligen, Teams als Taxonomie)
- ⬜ Sponsor-CPT + Stufen-Taxonomie
- ⬜ Embed-Bausteine (ifv.ch, Tickaroo, Mailchimp)
- ⬜ Design-Feinschliff (Vereinsfarben, Logo, Footer mit Sponsoren)
- ⬜ Demo-Inhalte (1–2 Teams, News, Sponsoren) zum Testen

---

## 4. Phasenplan

### Phase 0 – Setup (heute)  ✅ teils erledigt
- [x] Docker-Umgebung & Skripte
- [x] Git-Repo
- [ ] `./scripts/setup.sh` einmal laufen lassen → WordPress läuft auf :8080

### Phase 1 – Struktur & Plugins
- [ ] Plugin-Liste in `setup.sh` erweitern:
      `sportspress`, `the-events-calendar`, `fluentform`, `mailpoet`, `wordpress-seo`,
      ggf. `custom-post-type-ui` (für Sponsoren)
- [ ] Hierarchische Seiten anlegen (Eltern/Kind) gemäss Sitemap (Abschnitt 1)
- [ ] Haupt- und Footer-Menü mit Untermenüs aufbauen
- [ ] Startseite, Permalinks, Sprache (bereits im Skript)

### Phase 2 – Fussball-Funktionen (SportsPress)
- [ ] Saison `2025/26`, Wettbewerbe (z. B. „2. Liga", „Junioren A") anlegen
- [ ] Teams als SportsPress-Taxonomie (alle Aktiv- & Juniorenteams)
- [ ] 1–2 Beispiel-Kader (Spieler + Staff) als Vorlage
- [ ] Team-Seitenvorlage: Kader + eingebettetes ifv.ch-Matchcenter + Liveticker
- [ ] Block/Shortcode für **ifv.ch-iFrame** und **Tickaroo** erstellen

### Phase 3 – Inhalte & Module
- [ ] News-Kategorien je Team, 2–3 Demo-Beiträge
- [ ] Sponsor-CPT + Stufen-Taxonomie, alle bekannten Sponsoren als Einträge
- [ ] Sponsoren-Block im Footer (Raster nach Stufe, Style ist im Child-Theme vorbereitet)
- [ ] Formulare: „Mitglied werden", „Betreuer werden", „Vorfall melden", „Kontakt"
- [ ] Events: Beispiel „Dorf- und Grümpelturnier"
- [ ] Newsletter-Anmeldung (MailPoet-Block oder Mailchimp-Embed)

### Phase 4 – Design / 1:1-Optik
- [ ] Vereinsfarben final setzen (`custom.css`-Variablen) – Logo-Farbcodes übernehmen
- [ ] Logo hochladen (Customizer → Website-Logo)
- [ ] Header-/Footer-Layout an Original angleichen (Logo, Menü, Sponsorenleiste)
- [ ] Startseiten-Layout: News-Teaser, nächste Spiele, Sponsoren
- [ ] Mobile-Ansicht prüfen (Astra ist responsive)

### Phase 5 – Test & Abnahme (lokal)
- [ ] Alle Seiten/Menüs klickbar, Formulare senden (lokal als Test)
- [ ] Embeds laden (ifv.ch, Tickaroo)
- [ ] Vergleich Seite-für-Seite mit Original
- [ ] Checkliste „fehlt etwas?" durchgehen

### Phase 6 – Go-Live (später, optional)
- [ ] Hosting CH (Hostpoint/Cyon/Infomaniak), Domain verbinden
- [ ] Migration: Datenbank + `wp-content` exportieren (z. B. „All-in-One WP Migration")
- [ ] Echte Inhalte/Logo/Fotos einpflegen (mit Vereins-OK)
- [ ] SSL/HTTPS, Backups (UpdraftPlus), Sicherheit (Wordfence)

---

## 5. Datenmodell (Kurzüberblick)

- **Beitrag (Post):** News/Matchberichte → Kategorie = Team
- **SportsPress Team:** Mannschaft (Taxonomie), verknüpft mit Spielern/Staff
- **SportsPress Player / Staff:** Kader
- **Seite (Page):** statische Inhalte (Verein, Junioren-Unterseiten …) – hierarchisch
- **CPT Sponsor:** Name, Logo, Link, Taxonomie „Stufe"
- **Event:** Turniere/Anlässe (The Events Calendar)

---

## 6. Lokales Aufsetzen – Befehle

```bash
cp .env.example .env       # einmalig
./scripts/setup.sh         # WordPress + Theme + Plugins + Struktur
# -> http://localhost:8080  (Admin: admin / admin123)

# Eigene WP-CLI-Befehle:
./scripts/wp.sh plugin list
```

Das Setup-Skript wird in Phase 1–3 schrittweise erweitert (Plugins, hierarchische
Seiten, SportsPress-Grunddaten, Sponsor-CPT), damit der gesamte Aufbau
**reproduzierbar per Skript** entsteht und nicht nur per Mausklick.

---

## 7. Offene Punkte / zu klären

- [ ] Ist der Nachbau **für den FC Schattdorf** (→ Originalinhalte erlaubt) oder als Übung (→ Platzhalter)?
- [ ] Fanshop: nur Link, oder echter Shop (WooCommerce)?
- [ ] Helfereinsätze: einfache Seite/Formular, oder echtes Buchungstool?
- [ ] Newsletter: MailPoet (eigenständig) oder Mailchimp wie im Original?
- [ ] Logo & exakte Vereinsfarben (Hex-Codes) beschaffen
```
