---
name: wp-team
description: Legt ein neues Team in SportsPress an und erstellt die zugehörige WordPress-Seite inkl. Navigation. Für FC Schattdorf – kennt die Seitenstruktur (Aktive / Junioren) und Namenskonventionen des Projekts.
argument-hint: "<Teamname> [aktive|junioren]"
license: MIT
metadata:
  author: fc-schattdorf
  version: "1.0.0"
---

# wp-team Skill

Du legst ein neues Team für den FC Schattdorf an. Du kennst die gesamte Projektstruktur und weisst genau, was dazu gehört.

## Projektkontext

- WordPress läuft lokal auf `http://localhost:8090`
- WP-CLI ist im Docker-Container verfügbar: `docker compose exec wordpress wp`
- SportsPress verwaltet Teams, Spieler (Player) und Staff als Custom Post Types
- Navigationsstruktur: Aktive → Unterseiten | Junioren → Teams → Unterseiten
- Theme: Astra + Child-Theme `fcschattdorf-child`

## Seitenstruktur (Elternseiten)

```
Aktive (parent slug: aktive)
  ├── 1. Mannschaft
  ├── 2. Mannschaft
  ├── 3. Mannschaft
  ├── Frauen Team Uri I
  ├── Frauen Team Uri II
  └── Senioren Team Uri I

Junioren (parent slug: junioren)
  └── Teams (parent slug: junioren/teams)
        ├── A-Junioren
        ├── Ba-Junioren / Bb-Junioren
        ├── Ca-Junioren / Cb-Junioren
        ├── Da-Junioren bis Df-Junioren
        ├── Ea/Eb, Ec, Ed/Ee, Ef
        ├── Uri FF11
        └── Fa/Fb/Fc/Fd, Fe/Ff
```

## Was du tust, wenn `/wp-team` aufgerufen wird

### Schritt 1 – Argumente auswerten

Der Benutzer gibt an:
- **Teamname** (z.B. `"Da-Junioren"`, `"1. Mannschaft"`, `"Frauen Team Uri I"`)
- **Kategorie** (optional): `aktive` oder `junioren` – wenn nicht angegeben, erkenne es aus dem Namen:
  - Enthält der Name "Junioren", "FF11", "Fa"/"Fb" etc. → `junioren`
  - Enthält "Mannschaft", "Frauen", "Senioren" → `aktive`

### Schritt 2 – Duplikat-Check

Gib zuerst diesen Befehl aus und erkläre was er tut:

```bash
docker compose exec wordpress wp post list --post_type=sp_team --fields=post_title,post_status --format=table
```

Weise den Benutzer darauf hin, die Ausgabe zu prüfen, ob das Team schon existiert. Fahre erst fort wenn bestätigt.

### Schritt 3 – SportsPress-Team anlegen

Generiere den WP-CLI-Befehl:

```bash
docker compose exec wordpress wp post create \
  --post_type=sp_team \
  --post_title="<TEAMNAME>" \
  --post_status=publish \
  --post_name="<SLUG>"
```

- SLUG: Kleinbuchstaben, Umlaute ersetzen (ä→ae, ö→oe, ü→ue), Leerzeichen → Bindestriche
- Beispiele: `"1. Mannschaft"` → `1-mannschaft`, `"Da-Junioren"` → `da-junioren`

### Schritt 4 – WordPress-Seite erstellen

Bestimme die Elternseite:
- Aktive-Teams → Elternseite mit Slug `aktive`
- Junioren-Teams → Elternseite mit Slug `junioren/teams` (also erst Eltern-ID ermitteln)

Eltern-ID ermitteln:
```bash
# Für aktive Teams:
docker compose exec wordpress wp post list --post_type=page --post_status=publish --fields=ID,post_title,post_name --format=table | grep -i "aktive"

# Für Junioren:
docker compose exec wordpress wp post list --post_type=page --post_status=publish --fields=ID,post_title,post_name --format=table | grep -i "teams"
```

Seite erstellen (mit der ermittelten Eltern-ID):
```bash
docker compose exec wordpress wp post create \
  --post_type=page \
  --post_title="<TEAMNAME>" \
  --post_status=publish \
  --post_name="<SLUG>" \
  --post_parent=<ELTERN-ID>
```

Seiteninhalt: Erkläre dem Benutzer, dass die Seite zunächst leer ist und folgende Bausteine manuell ergänzt werden sollten:
- SportsPress-Widget: Kader-Tabelle (`[sp_list_players]` oder Block)
- iFrame: ifv.ch-Matchcenter für Spielplan/Tabelle
- Tickaroo-Liveticker-Embed (falls vorhanden)

### Schritt 5 – Navigation prüfen

Gib diesen Befehl aus:
```bash
docker compose exec wordpress wp menu list --format=table
```

Weise darauf hin, dass das neue Team manuell im WordPress-Backend unter **Design → Menüs** in die richtige Position eingefügt werden sollte (unter Aktive bzw. Junioren → Teams).

### Schritt 6 – Zusammenfassung

Zeige am Ende eine Tabelle:

| Was | Status |
|---|---|
| SportsPress-Team `<TEAMNAME>` | ✅ angelegt |
| WordPress-Seite `/<KATEGORIE>/<SLUG>` | ✅ erstellt |
| Menü-Eintrag | ⚠️ manuell ergänzen |
| Kader / Spieler | ⚠️ noch leer |
| Matchcenter-iFrame | ⚠️ noch nicht eingebettet |

Gib ausserdem die direkten Admin-Links aus:
- Seite bearbeiten: `http://localhost:8090/wp-admin/post.php?post=<SEITEN-ID>&action=edit`
- Team bearbeiten: `http://localhost:8090/wp-admin/post.php?post=<TEAM-ID>&action=edit`
- Menüs verwalten: `http://localhost:8090/wp-admin/nav-menus.php`

## Fehlerbehandlung

- Wenn Docker nicht läuft → weise darauf hin: `docker compose up -d`
- Wenn SportsPress nicht installiert ist → Hinweis: Plugin zuerst aktivieren
- Wenn die Elternseite nicht gefunden wird → frage den Benutzer nach der Eltern-ID oder schlage vor, die Seite zuerst unter der richtigen Elternseite manuell anzulegen
