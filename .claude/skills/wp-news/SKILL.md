---
name: wp-news
description: Legt News-Beiträge für fcschattdorf.ch an — aus Word-Spielberichten/Matchvorschauen und Bildern in ~/Downloads eine Textliste bauen, Bilder aufbereiten, lokal durchspielen, Deploy-Befehl für den Nutzer vorbereiten. Kennt die Regeln der Redaktion (Titel ohne Teampräfix, Beitragsbild fürs Telefon, Reihenfolge im Hero).
argument-hint: "[Quelle(n) in ~/Downloads oder Text] [Kategorie] [Bild]"
license: MIT
metadata:
  author: fc-schattdorf
  version: "1.0.0"
---

# wp-news — News-Beiträge hochladen

Du legst einen oder mehrere News-Beiträge auf fcschattdorf.ch an. Der
Weg ist immer derselbe: **Textliste (JSON) + Bilder → lokal
durchspielen → der Nutzer führt den Deploy aus.** SSH ist für dich
gesperrt; du bereitest vor, prüfst lokal und nennst den Befehl.

## Werkzeuge (liegen im Repo)

| Datei | Zweck |
| --- | --- |
| `scripts/docx-news.py "<datei.docx>" [--kategorie K] [--bild DATEI] [--beitragsbild DATEI] [--datum "Y-m-d H:i:s"] [--slug S] [--titel T]` | Word-Datei → JSON-Eintrag auf stdout. Erkennt Zwischentitel (ganzer Absatz fett, oder fetter Kopf + Umbruch), lässt Einsender/Rubrik/Resultat/Foto-Zeilen weg, entfernt Teampräfix im Titel, setzt Guillemets. **Ausgabe immer lesen und prüfen.** |
| `deploy/news-import-<TAG>.json` | Textliste, ein Array von Einträgen (Felder unten). TAG = Datum `TTMM`, z. B. `1709`. |
| `deploy/fcs-news.php.tpl` | Generisches DB-Skript (nicht anfassen; `deploy-news.sh` füllt Token und Listenname). |
| `./deploy/deploy-news.sh <TAG> --lokal` | Probelauf, scharfer Lauf, zweiter Lauf gegen Docker + Prüfmuster. |
| `./deploy/deploy-news.sh <TAG>` | **Führt der Nutzer aus.** Bilder hochladen, Probelauf, Rückfrage, scharf, 60 s warten, prüfen. |

Felder eines Eintrags: `slug`, `titel`, `kategorie` (exakter
Kategoriename: `1. Mannschaft`, `2. Mannschaft`, `3. Mannschaft`,
`Frauen`, `Junioren`, `Senioren`, `Verein`, `Allgemein`), `datum`
(`YYYY-MM-DD HH:MM:SS`, **nie in der Zukunft**), `bild` (Datei im
Artikel), optional `beitragsbild` (Hero/Kacheln), `absaetze`,
`zwischentitel` (Teilmenge der Absätze, werden `<h3>`), `quelle`
(Herkunft, nur Doku).

## Ablauf

1. **Live-DB holen:** `./scripts/pull-prod-db.sh` (Pflicht — sonst
   prüfst du gegen einen veralteten Stand und Slugs kollidieren).
2. **Quellen finden:** `ls -lat ~/Downloads | head` — Word-Dateien
   (`.docx`) und Bilder. Ist der Text direkt in der Anfrage, den
   Eintrag von Hand schreiben; Titel dann aus dem ersten Satz bilden.
3. **Text extrahieren:** `scripts/docx-news.py` pro Datei, Ausgabe
   prüfen: Titel, Zwischentitel, kein Einsender/«(le)»-Rest am falschen
   Ort, Resultatzeile weg. Bei Spielberichten der Junioren steht
   «(le)» am Ende des letzten Absatzes — das bleibt.
4. **Bilder aufbereiten** nach `wp-content/uploads/<YYYY>/<MM>/`
   (Monat des Beitragsdatums; Ordner ist gitignored, liegt nur lokal
   und nach dem Deploy live). **News-Grösse 1600 px lange Kante,
   JPEG-Qualität 88, progressiv.** Dateiname sprechend, ohne
   Leerzeichen: `Ca_12-09-2026.jpg`, `Team_Uri_Frauen_09-09-2026.jpg`,
   `A_Junioren_09-09-2026.jpg`. Verkleinern mit `sips -Z 1600 -s
   format jpeg -s formatOptions 88 IN --out OUT`. **Ausschnitte nie mit
   `sips --cropOffset`** (schneidet auf diesem Mac stillschweigend
   zentriert) — dafür GD im Container:
   `docker compose exec -T wordpress php -r '…imagecrop…'`.
   Mannschaftsfotos, die schon live liegen (z. B.
   `2026/09/FCS_1_Team_Web.jpg` für die 1. Mannschaft), einfach
   wiederverwenden — der Deploy überträgt nur, was live fehlt.
5. **Textliste schreiben:** `deploy/news-import-<TAG>.json`. Mehrere
   Beiträge in einem Lauf: Datum minutenweise staffeln, der **neueste
   steht zuoberst im Hero** (Regel: die 1. Mannschaft zuerst, wenn
   nichts anderes gesagt ist).
6. **Lokal durchspielen:** `./deploy/deploy-news.sh <TAG> --lokal`.
   Erwartet: Probelauf «würde anlegen», scharf «angelegt», zweiter
   Lauf «SKIP», Skript danach 404, Prüfungen grün. Dann Seite
   anschauen (Zwischentitel als `<h3>`, Hero-Reihenfolge:
   `curl -s localhost:8080/ | grep -o '"title":"[^"]*"' | head`).
7. **`.gitignore`:** Ausnahme `!deploy/news-import-<TAG>.json`
   ergänzen (Block «deploy/*» ignoriert sonst alles).
8. **`UEBERGABE.md`:** kurzer Abschnitt (Titel, Kategorie, Bild,
   Quelle, Besonderheiten), «offene Schritte» oben nachführen.
9. **Dem Nutzer den Befehl nennen:** `./deploy/deploy-news.sh <TAG>`.
   Kein Theme-Deploy nötig, solange keine Vorlage geändert wurde.

## Regeln der Redaktion (aus Rückmeldungen, nicht verhandelbar)

- **Titel ohne Teampräfix.** «Cb-Junioren: Urner Derby …» → «Urner
  Derby …». Das Team steht in der Kategorie. Gleicher Titel wie ein
  älterer Beitrag ist erlaubt — dann den **Slug** unterscheiden
  (`…-cb`), sonst hängt WordPress «-2» an.
- **Titel kurz.** «Schattdorf belohnt sich spät für leidenschaftlichen
  Auftritt» wurde auf Wunsch zu «Schattdorf belohnt sich spät».
- **Beitragsbild fürs Telefon.** Der Hero der Startseite ist
  bildschirmhoch mit `cover`; auf dem Telefon bleibt von jedem
  Querformat nur der mittlere Drittel sichtbar. Spielszenen und
  Hochformate wirken dort «hereingezoomt». Deshalb: bei Spielszenen,
  Jubelbildern und Hochkant-Fotos das **Mannschaftsfoto als
  `beitragsbild`** setzen (in News-Grösse in denselben Monatsordner
  kopieren), das eigentliche Bild bleibt `bild` im Artikel. Vorbilder:
  Frauen-Bericht 10.09., Ca-Bericht 16.09.
- **Mannschaft mittig** bei Mannschaftsfotos: oben beschneiden, bis
  die Mannschaft (Köpfe bis Schuhe) auf 50 % der Höhe sitzt.
- **Guillemets** «…» statt „…“; Apostrophe sind erlaubt — die
  Startseite decodiert Entities im Hero seit 15.09.
- **Spielberichte der Junioren:** Einsender, Telefon, Rubrikzeilen
  («Fussball. FC Schattdorf.», «Junioren Db. Meisterschaftsspiel …»),
  Datum-, Resultat- und Fotozeilen entfallen; es bleibt der
  Fliesstext. Die Vorschauen der 1. Mannschaft haben drei fette
  Zwischentitel — die bleiben.
- **Datum nie in der Zukunft** (WordPress plant sonst statt zu
  veröffentlichen; das Skript fängt es ab und nimmt «jetzt»). Bei
  mehreren Beiträgen deshalb die Daten mindestens eine Viertelstunde
  in die Vergangenheit legen — sonst bekommen alle dieselbe Sekunde
  und die Hero-Reihenfolge wird zufällig (passiert am 21.09.).

## Stolpersteine

- Yoast baut `og:image` beim Speichern: Beitragsbild geht als
  `meta_input` mit in den Insert; nachträglicher Tausch **erst**
  `set_post_thumbnail`, **dann** `wp_update_post` (macht das tpl).
- Prüfmuster im Shell-Skript **nie** als `printf | grep -q`
  (pipefail meldet «Broken pipe» als Fehler) — `grep -c <<< "$body"`.
- Hostpoint-Seitencache: Verifikation erst nach 60 s, Fehlalarme nach
  1–2 min erneut prüfen.
- `docker compose cp` in ein bestehendes Zielverzeichnis legt einen
  Unterordner an — Dateien einzeln kopieren oder Zielordner vorher
  löschen.

## Beispiel (Vorschau 1. Mannschaft, 17.09.2026)

```
./scripts/pull-prod-db.sh
scripts/docx-news.py ~/Downloads/"2026-09-19_FC Hergiswil (A).docx" \
  --kategorie "1. Mannschaft" --bild FCS_1_Team_Web.jpg \
  --datum "2026-09-17 13:00:00" > /tmp/e.json      # prüfen, dann als Array nach deploy/news-import-1709.json
./deploy/deploy-news.sh 1709 --lokal
# .gitignore + UEBERGABE.md nachführen, dann dem Nutzer:
./deploy/deploy-news.sh 1709
```
