#!/usr/bin/env python3
"""Word-Datei (.docx) in einen News-Eintrag für deploy/news-import-<TAG>.json wandeln.

Aufruf:  scripts/docx-news.py "<datei.docx>" [--slug SLUG] [--kategorie K] [--bild DATEI]
                              [--beitragsbild DATEI] [--datum "YYYY-MM-DD HH:MM:SS"] [--titel T]

Liest Absätze und erkennt Zwischentitel an zwei Mustern der Redaktion:
  1. ganzer Absatz fett (Vorschau-Vorlagen der 1. Mannschaft)
  2. fetter Lauf am Absatzanfang, dann <w:br/>, dann Fliesstext
Ohne Angabe ist der Titel der erste fette Absatz bzw. der erste
Absatz, der nicht wie eine Rubrik («2. Liga regional», «Fussball.
FC Schattdorf.») aussieht. Einsender-, Rubrik-, Resultat-, Foto- und
Telefonzeilen der Spielberichte werden weggelassen. Ausgabe: ein
JSON-Objekt auf stdout — prüfen, dann in die Textliste einsetzen.
"""
import sys, re, json, zipfile, argparse, unicodedata, datetime

def slugify(t):
    t = t.lower().replace('ä','ae').replace('ö','oe').replace('ü','ue').replace('ß','ss')
    t = unicodedata.normalize('NFKD', t).encode('ascii','ignore').decode()
    t = re.sub(r"[^a-z0-9]+", "-", t).strip('-')
    return t

def laeufe(p):
    """Liefert [(fett, text)] eines Absatzes, <w:br/> als (None, '\n')."""
    out = []
    for m in re.finditer(r'<w:r[ >].*?</w:r>', p, flags=re.S):
        s = m.group(0)
        fett = bool(re.search(r'<w:rPr>.*?(<w:b\b|<w:rStyle w:val="Fett"/>).*?</w:rPr>', s, flags=re.S))
        # <w:br/> kann mitten im Lauf stehen — Reihenfolge von Text und Umbruch beibehalten
        for tok in re.findall(r'<w:t[^>]*>.*?</w:t>|<w:br/>', s, flags=re.S):
            if tok == '<w:br/>':
                out.append((None, '\n')); continue
            t = re.sub(r'^<w:t[^>]*>|</w:t>$', '', tok)
            t = t.replace('&amp;','&').replace('&lt;','<').replace('&gt;','>').replace('&quot;','"')
            if t: out.append((fett, t))
    return out

SKIP = re.compile(r'^(Einsender|Tel\.?:|Foto:|Fotovorschlag|Text zu Foto|Fussball\.|Junioren [A-F][a-f]?\.|\d\. (Liga|Stärkeklasse)|Samstag,|Sonntag,|Mittwoch,|Freitag,|\(le\)$)', re.I)
RESULTAT = re.compile(r'\d+\s*:\s*\d+\s*\(')

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('docx'); ap.add_argument('--slug'); ap.add_argument('--titel')
    ap.add_argument('--kategorie', default='Junioren'); ap.add_argument('--bild', default='')
    ap.add_argument('--beitragsbild', default=''); ap.add_argument('--datum', default='')
    a = ap.parse_args()
    x = zipfile.ZipFile(a.docx).read('word/document.xml').decode()
    bloecke = []  # (typ 'H'|'P', text)
    for p in re.findall(r'<w:p[ >].*?</w:p>', x, flags=re.S):
        r = laeufe(p)
        if not r: continue
        text = ''.join(t for _, t in r).strip()
        if not text: continue
        alle_fett = all(f for f, t in r if f is not None and t.strip())
        if alle_fett and '\n' not in text:
            bloecke.append(('H', text)); continue
        # fetter Kopf + Umbruch + Fliesstext
        if r[0][0] and any(f is None for f, _ in r):
            i = next(i for i, (f, _) in enumerate(r) if f is None)
            kopf = ''.join(t for _, t in r[:i]).strip()
            rest = ''.join(t for _, t in r[i+1:]).strip()
            if kopf and rest:
                bloecke.append(('H', kopf)); bloecke.append(('P', rest)); continue
        bloecke.append(('P', text.replace('\n', ' ')))
    # Rubrik/Einsender/Resultat/Fotozeilen raus
    inhalt = [(k, t) for k, t in bloecke if not SKIP.match(t) and not RESULTAT.search(t)]
    titel = a.titel
    if not titel:
        for k, t in inhalt:
            if k == 'H': titel = t; break
        if not titel: titel = inhalt[0][1]
        inhalt = [(k, t) for k, t in inhalt if t != titel]
    # Teampräfix «Cb-Junioren: …» / «Team Uri Frauen: …» weg (Regel vom 10.09.2026)
    titel = re.sub(r'^[^:]{2,30}:\s+', '', titel)
    absaetze = [t for _, t in inhalt]
    zwischentitel = [t for k, t in inhalt if k == 'H']
    # deutsche Anführungszeichen -> Guillemets
    absaetze = [re.sub(r'[„“”]', '«', t) for t in absaetze]
    absaetze = [re.sub(r'«([^«]*?)«', r'«\1»', t) for t in absaetze]
    eintrag = {
        'slug': a.slug or slugify(titel),
        'titel': titel,
        'kategorie': a.kategorie,
        'bild': a.bild,
        'datum': a.datum or datetime.datetime.now().strftime('%Y-%m-%d %H:%M:00'),
        'absaetze': absaetze,
        'zwischentitel': zwischentitel,
        'quelle': a.docx.split('/')[-1],
    }
    if a.beitragsbild: eintrag['beitragsbild'] = a.beitragsbild
    print(json.dumps(eintrag, ensure_ascii=False, indent=2))

if __name__ == '__main__':
    main()
