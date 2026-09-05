# Umstellung auf www.fcschattdorf.ch

Stand: **04.09.2026**. Plan für den Wechsel der neuen WordPress-Seite von der
Test-Adresse `https://fcschattdorf.dynalias.net` auf die echte Domain
`https://www.fcschattdorf.ch`. Nach jedem erledigten Schritt hier abhaken
und `UEBERGABE.md` nachführen.

Die Faustregel für den ganzen Plan: **Die alte Seite bei cyon bleibt bis zum
Schluss unangetastet.** Der Wechsel besteht aus dem Umbiegen von zwei
DNS-Records — und ist auf demselben Weg jederzeit rückgängig zu machen.

---

## 0. Ausgangslage (Befund vom 04.09.2026)

| | Test-Seite (neu) | Echte Domain (alt) |
|---|---|---|
| Adresse | `fcschattdorf.dynalias.net` (DynDNS, NS bei Oracle) | `fcschattdorf.ch` / `www.` (CNAME auf `@`) |
| Hosting | Hostpoint `sl1819.web.hostpoint.ch`, Docroot `www/fcschattdorf` | cyon `s086.cyon.net` (`149.126.4.95`, IPv6 `2a01:ab20:0:4::95`) |
| System | WordPress, Child-Theme `fcschattdorf-child` = `main` | Joomla, gebaut von UBIQ (`ubiq.swiss`) |
| Zustand | `check-live.sh` grün, Zertifikat bis 21.10.2026, HTTPS + HSTS | läuft, ~99 News-Artikel unter `/newsblog/` |
| Registrar / NS | – | **cyon AG**, `ns1/ns2.cyon.ch`; TTL `@` A 900 s, `@` AAAA und `www` 14400 s (→ A11) |
| Mail | – | MX `mail.fcschattdorf.ch` → cyon (eigener A-Record), SPF `+a +mx +ip4:cyon -all`, DKIM `default._domainkey` bei cyon, DMARC `p=none` mit Reports an `fcschattdorf@ubiq.ch`, `webmail`/`autoconfig` als CNAME zu cyon |

Was daraus folgt:

- **Alle URLs der neuen Seite zeigen auf den Test-Host.** `siteurl`/`home`,
  Canonical, Feeds, Sitemap, oEmbed — 140 Vorkommen allein auf der
  Startseite. Das ist eine DB-Umstellung, kein Theme-Thema (das Theme ist
  hostnamenfrei).
- **Hostpoint kennt `fcschattdorf.ch` noch nicht.** Ein Aufruf mit diesem
  Host auf die Hostpoint-IP liefert die Hostpoint-Fehlerseite (HTTP 500,
  Zertifikat `*.web.hostpoint.ch`).
- **Mail bleibt bei cyon** — die ganzen Vereinsadressen (`praesident@`,
  `marketing@`, `spiko@`, `kommunikation@`, `juniorenabteilung@`) sind
  cyon-Postfächer. Die Mail-Records hängen *nicht* am Haupt-A-Record und
  überstehen die Umstellung, wenn man sie in Ruhe lässt.
- **`ftp.fcschattdorf.ch` hängt als CNAME am Haupt-A-Record** und zeigt nach
  der Umstellung auf Hostpoint. Betrifft nur, wer per FTP zur alten Seite
  geht (UBIQ) — kein Blocker, aber UBIQ informieren.
- **Formular-Mails aus WordPress würden nach dem Wechsel scheitern.**
  `wp_mail` sendet ab Hostpoint als `wordpress@www.fcschattdorf.ch`; das SPF
  von `fcschattdorf.ch` ist `-all` und kennt Hostpoint nicht → Fanshop-
  Bestellungen, Kontaktformular (FluentForm), Passwort-Resets landen im Spam
  oder werden abgewiesen. Muss vorher gelöst sein (Phase A).
- **Subdomain `m.fcschattdorf.ch` läuft über Mailgun** (MX/SPF/DKIM/DMARC
  `quarantine`, A `5.148.183.20` bei Nine) — vermutlich der
  Newsletter-Versand der alten Seite (UBIQ). Von der Umstellung nicht
  berührt; bei UBIQ nachfragen, ob das noch gebraucht wird (C5).
- **Die Test-Seite ist indexierbar** (kein noindex, `robots.txt` offen).
  Nach dem Wechsel braucht der Test-Host eine 301-Weiterleitung.
- **Die alten Joomla-URLs stimmen zum grossen Teil nicht mit den neuen
  überein** (Tabelle in Abschnitt 7). Ohne Weiterleitungen laufen Google,
  Facebook-Posts, SFV- und Gemeindelinks ins 404.

---

## 1. Grundsatzentscheide

| Entscheid | Wahl | Begründung |
|---|---|---|
| Domain und Mail | **bleiben bei cyon**, nur A/AAAA-Records werden auf Hostpoint gebogen | Kein Mail-Umzug, kein Domaintransfer, Rollback in Minuten. Ein Transfer zu Hostpoint kann später ein eigenes Projekt sein. |
| Kanonische Adresse | **`https://www.fcschattdorf.ch`** | Entspricht der alten Seite, allen bestehenden Links und dem Theme-Default in `page-trainingslager.php`. `fcschattdorf.ch` leitet auf `www.` um. |
| Weiterleitungen | **im Child-Theme** (`inc/fcs-redirects.php`), nicht in `.htaccess` und nicht per Plugin | Versioniert, lokal testbar, geht mit dem normalen Theme-rsync mit. Übernimmt auch Host-Weiterleitung (dynalias, apex) als Sicherheitsnetz. |
| Alte News | **nicht migrieren**, `/newsblog/*` → `/news/` | 99 Joomla-Artikel gegen 14 neue; Migration wäre ein eigenes Projekt. Entscheid des Vereins — kann später nachgeholt werden. |
| Mailversand | **SMTP-Plugin (FluentSMTP) über ein cyon-Postfach** | Sauber: SPF, DKIM und Absender stimmen. SPF-Erweiterung um Hostpoint nur als Notlösung. |
| Test-Host | **bleibt ~3 Monate als 301-Weiterleitung**, dann abschalten | Falls indexiert oder verlinkt. |

---

## 2. Beteiligte und Zugänge

| Wer | Braucht / liefert |
|---|---|
| Fabian | SSH `aziwivac@sl1819.web.hostpoint.ch`, Hostpoint Control Panel (`admin.hostpoint.ch`), WP-Admin live, Repo |
| Claude | bereitet Skripte, Theme-Modul und Doku vor (SSH gesperrt — Ausführung durch Fabian) |
| Verein (Präsident/Admin) | **Zugang zu `my.cyon`** (Domain, DNS-Editor, Mail-Postfächer) — der eigentliche Blocker; Freigabe Umstelltermin; Entscheid alte News |
| UBIQ | Info über Abschaltung der Joomla-Seite und `ftp.`-CNAME; ggf. Search-Console-Zugang (Verification-TXT und DMARC-Reports laufen auf UBIQ) |
| Redaktion | Inhaltsfreeze auf der alten Seite ab Termin; danach nur noch im neuen Admin |

---

## 3. Phase A – Vorbereitung (ohne Ausfall, Tage bis Wochen vorher)

Alles hier ist ohne Auswirkung auf Besucher und kann in beliebiger Reihenfolge
laufen. A5 und A6 sind Voraussetzung für Phase B.

- [x] **A1 Zugänge** *(erledigt 05.09.2026: `my.cyon`-Zugang vorhanden — damit ist B2 möglich; Search-Console-Eigentümer noch offen, wird in C1 geklärt)*. `my.cyon`-Login vom Verein; klären, wer im Google
      Search Console Eigentümer der Property `fcschattdorf.ch` ist (TXT
      `google-site-verification=IjSW…` liegt in der Zone).
- [x] **A2 Hostpoint-Panel: Domain zuweisen** *(erledigt 04.09.2026: `fcschattdorf.ch` + `www` der Website `fcschattdorf.dynalias.net (SSL)` zugewiesen; HTTP liefert WordPress, HTTPS erst nach B2/B3 mit FreeSSL)*. `admin.hostpoint.ch` →
      *Domains* → externe Domain `fcschattdorf.ch` hinzufügen → dem Webhosting
      zuweisen → unter *Websites* auf den Docroot `www/fcschattdorf` legen,
      `www.fcschattdorf.ch` als Variante mit. Weiterleitung `fcschattdorf.ch`
      → `https://www.fcschattdorf.ch` einrichten. FreeSSL (Let's Encrypt)
      aktivieren — wird erst ausgestellt, wenn das DNS zeigt (Phase B),
      Panel meldet bis dahin «ausstehend». Das ist gefahrlos vorab möglich:
      Solange das DNS bei cyon auf die alte Seite zeigt, ändert sich nichts.
      Test: `curl -sk --resolve www.fcschattdorf.ch:443:217.26.61.134
      https://www.fcschattdorf.ch/` liefert WordPress statt der
      Hostpoint-Fehlerseite.
- [x] **A3 Mailversand** *(erledigt 05.09.2026: FluentSMTP live über cyon-Postfach via `s086.cyon.net:465`; Testmail, Fanshop-Bestellung und Kontaktformular alle zugestellt)*. In cyon ein Postfach für die Website anlegen
      (z.B. `website@fcschattdorf.ch`) oder ein bestehendes nehmen. Auf der
      Live-Seite FluentSMTP installieren, Verbindung: SMTP-Host
      **`s086.cyon.net`** (nicht `mail.fcschattdorf.ch` — dessen Zertifikat
      lautet auf `*.cyon.net`, die TLS-Prüfung schlägt sonst fehl), Port
      465/SSL, Benutzer = Postfach, Absender = dasselbe Postfach, «Absender
      erzwingen» an. Testmail, dann eine Fanshop-Testbestellung und das
      Kontaktformular auslösen. Dabei prüfen, ob das Kontaktformular in
      Fluent Forms überhaupt eine E-Mail-Benachrichtigung hat (im lokalen
      DB-Stand vom 05.09.2026 fehlt sie — dann Empfänger
      `kommunikation@fcschattdorf.ch` anlegen, wie im Seitenfeld
      `kontakt_mail`). Damit
      ist die Mailfrage schon *vor* dem Wechsel gelöst und domainunabhängig.
      Notlösung, falls kein Postfach: SPF bei cyon um
      `include:spf.mail.hostpoint.ch` ergänzen (vor `-all`).
- [x] **A4 Theme: Weiterleitungsmodul** `inc/fcs-redirects.php` bauen *(erledigt 04.09.2026, Branch `umstellung`)*
      (wird per Glob geladen): (1) Host ≠ Host von `home_url()` → 301 auf
      denselben Pfad unter `home_url()` (fängt dynalias und apex; lokal
      harmlos, weil `home` dort `localhost:8080` ist); (2) Pfadtabelle aus
      Abschnitt 7 mit 301, Muster `/newsblog/*`, `/spielberichte/*`,
      `/saison-*`, `/index.php/*`. Lokal testen (`curl -I`).
- [x] **A5 DB-Umstellskript** `deploy/fcs-domain-switch.php.tpl` + *(erledigt 04.09.2026, Branch `umstellung`, lokal in beide Richtungen getestet)*
      `deploy/deploy-domain.sh` nach dem Muster von
      `fcs-schiedsrichter-update.php.tpl`: Token, `&dry=1` zeigt Trefferzahl
      pro Tabelle, Abbruch wenn `siteurl` nicht `https://fcschattdorf.dynalias.net`
      ist; serialisierungssicheres Ersetzen `https://fcschattdorf.dynalias.net`
      → `https://www.fcschattdorf.ch` und `fcschattdorf.dynalias.net` →
      `www.fcschattdorf.ch` in **allen** Tabellen mit Textspalten (Options,
      Posts, Postmeta, Termmeta, Usermeta, Comments, Yoast-Indexables,
      FluentForm-Tabellen, SportsPress/Events-Calendar-Optionen);
      Transients löschen; Skript räumt sich vom Server. Probelauf lokal
      gegen die per `pull-prod-db.sh` geholte DB (dort `localhost:8080`
      als Quellhost).
- [x] **A6 Trainingslager-Link** *(erledigt 05.09.2026: Seitenfeld im Live-Admin geleert, Theme-Teil auf dem Branch)*. Das Seitenfeld «Link zur Anmeldung»
      (`fcs_tl_anmeldung_url`) der Trainingslager-Seite zeigt live auf das
      Joomla-Formular `www.fcschattdorf.ch/anmeldung-juniorentrainingslager`
      — nach dem Wechsel liefe der Button über den Redirect auf die eigene
      Seite zurück. *Theme-Teil erledigt 05.09.2026 (Branch):* ohne gesetztes
      Feld gibt es keinen «Jetzt anmelden»-Button mehr (der alte
      Vorlagen-Standard ist entfernt; lokal getestet). **Offen, von Hand:**
      im Live-Admin → Seiten → Trainingslager → Box «Seiteninhalte» → «Link
      zur Anmeldung» **leeren** → Aktualisieren. Das Lager 2026 ist vorbei;
      für 2027 ein Fluent-Forms-Formular bauen (Felder wie im alten:
      Name, Vorname, Adresse, E-Mail, Telefon, Vegetarier ja/nein,
      Kleidergrösse 128/140/152/164/XS/S/M/L) und dessen Seite ins Feld
      eintragen.
- [x] **A7 Inhalte gegenlesen** *(erledigt 05.09.2026: `deploy-a7-inhalte.sh` live gelaufen und geprüft; Rest ist Redaktion, Abschnitt 4 der Arbeitsliste)*. *Analyse 05.09.2026, Arbeitsliste
      in `UMSTELLUNG-A7-INHALTE.md`.* Befund: keine Nennung von cyon/Joomla,
      alle 11 PDFs erreichbar, Titel überall gesetzt — aber **Meta-Description
      auf 64/65 Seiten leer**, OG-Bild auf ~40 Seiten fehlend,
      Datenschutzerklärung von 2023 ohne Hoster. Google Fonts und AOS
      (unpkg.com) sind seit 05.09.2026 ins Theme geholt (`assets/vendor/`,
      geht mit B5 live) — dafür braucht der Datenschutz keinen Abschnitt
      mehr. **Vorbereitet als `./deploy/deploy-a7-inhalte.sh`** (auf `main`,
      jederzeit fahrbar): Descriptions für alle 53 Seiten ohne Description,
      Yoast-Standardbild (Startseiten-Foto), Datenschutz-Ergänzungen mit
      Stand September 2026. Danach bleibt für die Redaktion: veraltete
      Termine/Saison nachführen (Abschnitt 4 der Arbeitsliste).
- [x] **A8 Repo vorbereiten (Branch `umstellung`)** *(erledigt 04.09.2026)*: `scripts/lib-live.sh`
      (`LIVE_HOST`, Kommentar), `scripts/check-live.sh` (Hinweistexte —
      die Prüfung «A-Record = sl1819-IP» bleibt richtig, nur der Hinweis
      zeigt dann auf cyon statt dynalias), `scripts/pull-prod-db.sh:99`
      (Search-Replace-Quelle → `www.fcschattdorf.ch`),
      `deploy/deploy-trainingslager.sh:84` (nacktes `curl` mit Test-Host →
      `lcurl "$LIVE/..."`), `CLAUDE.md` (Domain-Abschnitt), `README.md`
      (Go-Live-Hinweis), `UEBERGABE.md`. `GO-LIVE-GUIDE.md` und
      `wp-config-production.php` löschen (Infomaniak-Anleitung von Juni,
      Salt-Platzhalter — beides überholt). **Nicht vor Phase B mergen** —
      bis dahin sprechen alle Skripte noch mit dem Test-Host.
- [x] **A9 Termin und Freeze** *(erledigt 05.09.2026: Umstelltag **Dienstag, 08.09.2026**, Vormittag)*. Umstelltag festlegen: Werktag-Vormittag,
      nicht an einem Spielwochenende, jemand vom Vorstand erreichbar.
      Redaktion informiert: ab dann keine Änderungen mehr an der alten Seite.
- [x] **A10 Server-Check** *(erledigt 05.09.2026: grep leer — keine WP_HOME/WP_SITEURL-Konstanten, kein dynalias in wp-config.php)*. `ssh aziwivac@sl1819.web.hostpoint.ch
      'grep -n "WP_HOME\|WP_SITEURL\|dynalias" www/fcschattdorf/wp-config.php'`
      — muss leer sein (sonst würde die Konstante die DB überstimmen).
      `.htaccess` im Docroot anschauen: keine hartkodierten Host-Regeln.
- [x] **A11 TTL senken** *(erledigt 05.09.2026: `@` A, `@` AAAA und `www` auf 300 s, per `dig @ns1.cyon.ch` bestätigt; Werte, MX und `mail` unverändert)*. Im cyon-DNS-Editor die
      TTL von `@` A (heute 900 s), `@` AAAA (14400 s) und `www` CNAME
      (14400 s) auf **300 s** stellen, sonst nichts ändern. Erst wenn die
      alten TTLs abgelaufen sind (4 h), greifen Wechsel *und* Rollback
      überall innert ~5 Minuten. Zonen-Dump vom 05.09.2026 liegt beim
      Verein (`cyon-zonedump-fcschattdorf.ch-2026-09-05-185443.json`).

---

## 4. Phase B – Umstelltag (Reihenfolge einhalten, ~1 Stunde)

Die Reihenfolge ist wichtig: **erst DNS, dann Zertifikat, dann DB.** Würde
die DB zuerst umgestellt, leitete WordPress alle Besucher der Test-Adresse
auf `www.fcschattdorf.ch` — und das wäre noch die alte Seite bei cyon.

**Spickzettel für Dienstag, 08.09.2026** (Vorbereitung A11 spätestens am
Montag: TTL bei cyon auf 300 s):

```bash
# ── Vormittag, vor B2 ───────────────────────────────────────────
git checkout main && git pull
./scripts/pull-prod-db.sh                                   # B1 Live-Dump -> backups/
rsync -avz aziwivac@sl1819.web.hostpoint.ch:www/fcschattdorf/wp-content/uploads/ backups/uploads-2026-09-08/
./scripts/check-live.sh                                     # muss grün sein
dig +short sl1819.web.hostpoint.ch A                        # IPv4 für cyon
dig +short sl1819.web.hostpoint.ch AAAA                     # IPv6 für cyon

# ── B2: my.cyon -> DNS-Editor: «@» A und AAAA auf die beiden Werte, Rest unverändert
dig +short www.fcschattdorf.ch A; dig +short www.fcschattdorf.ch AAAA   # bis beides = Hostpoint
dig +short fcschattdorf.ch MX                               # muss mail.fcschattdorf.ch bleiben

# ── B3: Zertifikat abwarten (Minuten bis ~1 h), alle paar Minuten:
curl -sS -o /dev/null -w '%{http_code}\n' https://www.fcschattdorf.ch/     # 200 ohne TLS-Fehler
openssl s_client -connect www.fcschattdorf.ch:443 -servername www.fcschattdorf.ch </dev/null 2>/dev/null \
  | openssl x509 -noout -subject -enddate                   # CN=www.fcschattdorf.ch

# ── B4: DB umstellen (Skript prüft DNS/Zertifikat/Dump, Probelauf, Rückfrage)
git checkout umstellung && git pull
./deploy/deploy-domain.sh

# ── B5: Branch nach main, Theme deployen (Weiterleitungen, Fonts, Trainingslager-Button)
git checkout main && git merge umstellung && git push
rsync -avz wp-content/themes/fcschattdorf-child/ aziwivac@sl1819.web.hostpoint.ch:www/fcschattdorf/wp-content/themes/fcschattdorf-child/

# ── B6: nach 60 s prüfen
./scripts/check-live.sh
curl -sI https://fcschattdorf.dynalias.net/verein/vorstand/ | grep -i '^location'   # -> www…/verein/vorstand/
curl -sI https://www.fcschattdorf.ch/verein/so-finden-sie-uns | grep -i '^location' # -> /verein/anfahrt/
curl -s  https://www.fcschattdorf.ch/ | grep -c dynalias                             # 0
# dann Checkliste Abschnitt 8: Formulare, Fanshop, Admin-Login, Bilder

# ── Rollback: DNS bei cyon zurück auf 149.126.4.95 / 2a01:ab20:0:4::95
# nach B4 zusätzlich:  git checkout umstellung && ./deploy/deploy-domain.sh --rueckwaerts
```


- [ ] **B1 Sicherung.** `./scripts/pull-prod-db.sh` (Live-Dump nach
      `backups/prod-db-<Zeit>.sql.gz` = Rückweg für die DB) und
      `rsync -avz aziwivac@sl1819.web.hostpoint.ch:www/fcschattdorf/wp-content/uploads/ backups/uploads-<Datum>/`.
      `./scripts/check-live.sh` muss grün sein.
- [ ] **B2 DNS bei cyon umstellen** (`my.cyon` → Domain → *DNS-Editor*).
      Vorher die aktuellen Hostpoint-Adressen holen — nie aus diesem
      Dokument abschreiben:

      ```
      dig +short sl1819.web.hostpoint.ch A      # 04.09.2026: 217.26.61.134
      dig +short sl1819.web.hostpoint.ch AAAA   # 04.09.2026: 2a00:d70:0:b:2002:0:d91a:3d86
      ```

      | Record | Alt (cyon) | Neu |
      |---|---|---|
      | `@` A (Haupt-A-Record) | `149.126.4.95` | Hostpoint-IPv4 |
      | `@` AAAA | `2a01:ab20:0:4::95` | Hostpoint-IPv6 (oder Record löschen) |
      | `www` CNAME → `fcschattdorf.ch` | unverändert | unverändert |
      | MX, `mail` A, SPF, DMARC, `webmail`, `autoconfig`, `_autodiscover`, `google-site-verification`, `MS=…` | unverändert | **unverändert — nicht anfassen** |
      | `ftp` CNAME | zeigt danach auf Hostpoint | belassen (UBIQ informiert) |

      TTL nach A11 300 s — die Änderung greift innert ~5 Minuten. Prüfen:
      `dig +short www.fcschattdorf.ch A` = Hostpoint-IP,
      `dig +short fcschattdorf.ch MX` = weiterhin `mail.fcschattdorf.ch`.
- [ ] **B3 Zertifikat abwarten.** Hostpoint stellt FreeSSL für
      `fcschattdorf.ch` + `www.` automatisch aus, sobald die HTTP-Validierung
      durchgeht (Minuten bis ~1 Stunde; im Panel unter *Websites* sichtbar).
      Bis dahin zeigt `https://www.fcschattdorf.ch` eine Zertifikatswarnung
      — deshalb Vormittag, deshalb Freeze. Prüfen:
      `openssl s_client -connect www.fcschattdorf.ch:443 -servername www.fcschattdorf.ch </dev/null | openssl x509 -noout -subject -enddate`
      → `CN=www.fcschattdorf.ch` (oder `fcschattdorf.ch`).
- [ ] **B4 DB umstellen.** `./deploy/deploy-domain.sh`: Probelauf lesen
      (Trefferzahlen plausibel? `siteurl` = Test-Host?), bestätigen, echter
      Lauf, Skript räumt sich vom Server (HTTP 404 prüfen). Danach im
      WP-Admin *Einstellungen → Permalinks* einmal speichern.
- [ ] **B5 Theme und Repo-Stand deployen.** Branch `umstellung` mergen,
      dann der übliche rsync des Child-Themes (Weiterleitungsmodul geht mit).
      Ab jetzt zeigen `lib-live.sh` & Co. auf die neue Domain.
- [ ] **B6 Verifikation** (nach ~1 Minute wegen Hostpoint-Cache) — Liste
      in Abschnitt 8. Mindestens: `./scripts/check-live.sh` grün,
      Startseite ohne `dynalias` im Quelltext, `curl -I
      https://fcschattdorf.dynalias.net/verein/vorstand/` → 301 auf
      `https://www.fcschattdorf.ch/verein/vorstand/`, drei alte Joomla-URLs
      → 301 auf die richtigen neuen Seiten, Kontaktformular und
      Fanshop-Bestellung kommen an.
- [ ] **B7 Freigabe.** Vorstand/Redaktion informieren: neue Seite ist live,
      Admin unter `https://www.fcschattdorf.ch/wp-admin`. `UEBERGABE.md`
      nachführen.

---

## 5. Phase C – Nachlauf (Tag 1 bis Woche 12)

- [ ] **C1 Search Console.** Property `https://www.fcschattdorf.ch/` (oder
      die Domain-Property, falls Zugang) → Sitemap
      `https://www.fcschattdorf.ch/wp-sitemap.xml` einreichen. Nach 1–2
      Wochen unter *Seiten/Indexierung* die 404-Liste ansehen und fehlende
      Weiterleitungen in `inc/fcs-redirects.php` nachtragen.
- [ ] **C2 404-Log auf Hostpoint.** Nach einer Woche:
      `ssh aziwivac@sl1819.web.hostpoint.ch 'grep " 404 " logs/*access* | awk "{print \$7}" | sort | uniq -c | sort -rn | head -40'`
      (Log-Pfad im Panel prüfen). Häufige Treffer → Redirect ergänzen.
- [ ] **C3 Mail beobachten.** Erste echte Formular-Mails: kommen sie an,
      landen sie im Spam? DMARC-Reports gehen an UBIQ — bei Problemen dort
      nachfragen oder `rua=` auf eine Vereinsadresse umstellen.
- [ ] **C4 cyon nicht kündigen.** Das Webhosting trägt die Mail. Erst wenn
      der Verein die Mail anderswo will, ist das ein separates Projekt.
      Sinnvoll: bei cyon nachfragen, ob ein kleineres (Mail-)Paket reicht.
- [ ] **C5 UBIQ abmelden.** Joomla-Seite darf offline; Search-Console-
      Eigentum und DMARC-`rua` an den Verein übergeben; klären, ob die
      Mailgun-Subdomain `m.fcschattdorf.ch` noch gebraucht wird.
- [ ] **C6 Test-Host abbauen (nach ~3 Monaten, ca. Dezember 2026).**
      Domain `fcschattdorf.dynalias.net` im Hostpoint-Panel entfernen,
      DynDNS-Konto kündigen, `lib-live.sh`-Kommentare zum DynDNS-Vorfall
      auf einen Satz kürzen. Das Zertifikat läuft am 21.10.2026 aus — bis
      dahin erneuert Hostpoint automatisch, solange die Domain noch
      zugewiesen ist.
- [ ] **C7 Backups.** Hostpoint-Backup-Einstellungen prüfen; lokal
      `./scripts/pull-prod-db.sh` regelmässig.

---

## 6. Rollback

| Wann | Was | Dauer |
|---|---|---|
| Nach B2/B3, vor B4 | A/AAAA bei cyon auf `149.126.4.95` / `2a01:ab20:0:4::95` zurück. Alte Seite läuft unverändert weiter. | ~5 Minuten (TTL 300 s nach A11) |
| Nach B4 | DNS zurück **und** DB zurück: `deploy-domain.sh` in Gegenrichtung (Skript kann beide Richtungen) oder Live-Dump aus B1 einspielen (Web-Import-Skript nach dem Muster von `fcs-db-export.php.tpl`). | ~15 Minuten |
| Nach B5 | zusätzlich Theme-Stand vor dem Merge per rsync zurück (oder `main` vor Merge auschecken und deployen) | ~5 Minuten |

Die Test-Adresse bleibt während der ganzen Umstellung erreichbar; sie ist der
Zugang zum Admin, falls die neue Domain hakt.

---

## 7. Weiterleitungstabelle (alt → neu)

Basis: Navigation und Sitemap der alten Seite vs. `wp-sitemap-posts-page-1.xml`
der neuen (04.09.2026). Unverändert und ohne Regel: `/aktive/1-mannschaft`,
`/aktive/2-mannschaft`, `/aktive/3-mannschaft`, `/news`, `/events`,
`/helfereinsaetze`, `/kontakt`, `/impressum`, `/datenschutzerklaerung`,
`/verein/vorstand`, `/verein/fanshop`, `/verein/mitglied-werden`,
`/verein/schiedsrichter`, `/verein/vereinsgeschichte`, `/sponsoren/top-club-88`,
`/junioren/teams/team-uri-ff11` (WordPress ergänzt den Schrägstrich selbst).

| Alt (Joomla) | Neu (WordPress) |
|---|---|
| `/aktive/frauen-team-uri-i` | `/aktive/frauen-uri-1/` |
| `/aktive/frauen-team-uri-ii` | `/aktive/frauen-uri-2/` |
| `/aktive/senioren-team-uri-i` | `/aktive/senioren-uri-1/` |
| `/betreuer`, `/betreuer-werden` | `/junioren/betreuer-werden/` (`/betreuer` prüfen — evtl. `/junioren/junioren-organisation/`) |
| `/fussballschule` | `/junioren/fussballschule/` |
| `/goalietraining` | `/junioren/goalietraining/` |
| `/juniorengeschichte` | `/junioren/juniorengeschichte/` |
| `/juniorenkonzept` | `/junioren/juniorenkonzept/` |
| `/organisation` | `/junioren/junioren-organisation/` |
| `/trainingslager`, `/anmeldung-juniorentrainingslager` | `/junioren/trainingslager/` |
| `/verein/so-finden-sie-uns` | `/verein/anfahrt/` |
| `/verein/ehren-und-freimitglieder` | `/verein/ehrenmitglieder/` |
| `/verein/vorfall-verdacht-melden` | `/verein/vorfall-melden/` |
| `/sponsoren/sponsorenpage`, `/sponsoren` | `/sponsoren/` |
| `/event/dorf-und-gruempelturnier` | `/gruempelturnier/` |
| `/event/events`, `/event` | `/events/` |
| `/junioren/teams/junioren-mannschaft-aa` | `/junioren/teams/junioren-a-junioren/` |
| `…-ba` / `…-bb` | `/junioren/teams/junioren-b-junioren-a/` / `…-b/` |
| `…-ca` / `…-cb` | `/junioren/teams/junioren-c-junioren-a/` / `…-b/` |
| `…-da` | `/junioren/teams/junioren-d-junioren/` |
| `…-db` / `…-dc` / `…-dd` / `…-df` | `/junioren/teams/junioren-db-junioren/` / `…-dc-…` / `…-dd-…` / `…-df-…` |
| `…-de2` | `/junioren/teams/junioren-de-junioren/` |
| `…-ea-eb-ec` | `/junioren/teams/junioren-e-junioren/` |
| `…-ec` | `/junioren/teams/junioren-ec-junioren/` |
| `…-ed-ee` | `/junioren/teams/junioren-edee-junioren/` |
| `…-ef-2` | `/junioren/teams/junioren-ef-junioren/` |
| `…-fa-fb-fc-fd` | `/junioren/teams/junioren-f-junioren/` |
| `…-fe-ff` | `/junioren/teams/junioren-feff-junioren/` |
| `/newsblog/*`, `/spielberichte/*`, `/saison-*` | `/news/` |
| `/login` | `/` |
| `/index.php/<pfad>` | `/<pfad>` (dann normale Regeln) |
| Host `fcschattdorf.dynalias.net`, `fcschattdorf.ch` | `https://www.fcschattdorf.ch` + gleicher Pfad |

Team-Zuordnungen (Da/Db, Ea-Eb-Ec → E usw.) mit dem Juniorenobmann
gegenprüfen — die Zusammensetzung der Teams ändert sich jede Saison.

---

## 8. Verifikations-Checkliste (Umstelltag)

- [ ] `./scripts/check-live.sh` grün (nach Merge des Branches)
- [ ] `https://www.fcschattdorf.ch/` HTTP 200, Zertifikat gültig, Schloss im Browser
- [ ] `http://www.fcschattdorf.ch/` → 301 https; `https://fcschattdorf.ch/` → 301 www
- [ ] `https://fcschattdorf.dynalias.net/verein/vorstand/` → 301 `https://www.fcschattdorf.ch/verein/vorstand/`
- [ ] Startseiten-Quelltext: 0 × `dynalias`, Canonical = `https://www.fcschattdorf.ch/`
- [ ] Bilder/Uploads laden (Sponsorenlogos, Personenfotos, News-Bilder)
- [ ] Kein Mixed Content (Browser-Konsole leer)
- [ ] Unterseiten: Vorstand, Teams (SportsPress), Junioren-Teams, Events (Kalender + iCal-Feed), Chronik, Sponsoren, Fanshop
- [ ] Kontaktformular sendet und kommt an; Fanshop-Testbestellung kommt an (inkl. Kundenbestätigung)
- [ ] `wp-admin`-Login, Medien-Upload, Seite speichern
- [ ] `https://www.fcschattdorf.ch/wp-sitemap.xml` und `robots.txt` zeigen die neue Domain
- [ ] Drei alte Joomla-URLs aus Abschnitt 7 → 301 auf die richtige Seite
- [ ] `dig +short fcschattdorf.ch MX` unverändert; Testmail an eine Vereinsadresse kommt an
- [ ] `UEBERGABE.md` nachgeführt

---

## 9. Was im Repo entsteht bzw. sich ändert

| Datei | Änderung |
|---|---|
| `wp-content/themes/fcschattdorf-child/inc/fcs-redirects.php` | **neu** — Host- und Pfad-Weiterleitungen (Abschnitt 7) |
| `deploy/fcs-domain-switch.php.tpl`, `deploy/deploy-domain.sh` | **neu** — DB-Umstellung mit Probelauf, beide Richtungen |
| `scripts/lib-live.sh` | `LIVE_HOST="www.fcschattdorf.ch"`, Kommentar |
| `scripts/check-live.sh` | Hinweistexte (cyon-DNS-Editor statt dynalias-Konto) |
| `scripts/pull-prod-db.sh` | Search-Replace-Quelle `www.fcschattdorf.ch` |
| `deploy/deploy-trainingslager.sh` | `lcurl "$LIVE/…"` statt nacktem `curl` mit Test-Host |
| `CLAUDE.md`, `README.md`, `UEBERGABE.md` | Domain-Abschnitt, Go-Live-Hinweis, Stand |
| `GO-LIVE-GUIDE.md`, `wp-config-production.php` | **löschen** (überholt) |
| `UMSTELLUNG.md` | dieser Plan; nach Abschluss auf einen Rückblick kürzen |
