#!/usr/bin/env python3
"""Recalcule les durées des chapitres et modules à partir du contenu réel.

Usage :  python3 tool/content_durations.py [--check]

Barème (lecture d'un contenu technique sur mobile) :
- texte (text, tip, warning, definition, list, table, quote) : 110 mots/min ;
- code : 0,3 min par ligne (lire et comprendre) ;
- exercice « question de cours » (réponse sur une ligne) : 1,5 min ;
- exercice pratique (correction sur plusieurs lignes) : 4 min.
Durée d'un chapitre arrondie à la minute, 3 min minimum.
Durée d'un module = somme de ses chapitres (c'est ce qu'affiche l'appli).

--check : n'écrit rien, renvoie 1 si une durée est désynchronisée
(utilisable en CI ou avant un commit).
"""

import json
import math
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
COURSES = ROOT / "assets" / "data" / "courses"

WORDS_PER_MIN = 110
MIN_PER_CODE_LINE = 0.3
MIN_RECALL = 1.5
MIN_PRACTICE = 4
MIN_CHAPTER = 3

_word = re.compile(r"\w+")


def _words(text):
    return len(_word.findall(text or ""))


def section_minutes(s):
    t = s.get("type")
    if t == "code":
        return len((s.get("code") or "").strip().splitlines()) * MIN_PER_CODE_LINE
    if t == "exercise":
        answer = (s.get("answer") or "").strip()
        return MIN_PRACTICE if "\n" in answer else MIN_RECALL
    words = _words(s.get("title")) + _words(s.get("body")) + _words(s.get("term"))
    words += sum(_words(i) for i in s.get("items") or [])
    words += sum(_words(" ".join(r)) for r in s.get("table") or [])
    return words / WORDS_PER_MIN


def chapter_minutes(ch):
    total = sum(section_minutes(s) for s in ch.get("sections", []))
    return max(MIN_CHAPTER, math.ceil(total - 0.25))  # arrondi « au plus près, vers le haut »


# ---- lecture / écriture en conservant la mise en forme du dépôt ----
def _dump_value(v):
    return json.dumps(v, ensure_ascii=False)


def dump_courses(courses):
    """Même style que les fichiers d'origine : une section par ligne."""
    out = ["["]
    for ci, c in enumerate(courses):
        out.append("  {")
        keys = [k for k in c if k != "chapters"]
        lines = [f'    "{k}": {_dump_value(c[k])}' for k in keys]
        chapters = ["    \"chapters\": ["]
        for hi, ch in enumerate(c.get("chapters", [])):
            chapters.append("      {")
            hk = [k for k in ch if k != "sections"]
            hl = [f'        "{k}": {_dump_value(ch[k])}' for k in hk]
            secs = ["        \"sections\": ["]
            ss = ch.get("sections", [])
            for si, s in enumerate(ss):
                secs.append("          " + _dump_value(s) + ("," if si < len(ss) - 1 else ""))
            secs.append("        ]")
            chapters.append(",\n".join(hl + ["\n".join(secs)]))
            chapters.append("      }" + ("," if hi < len(c["chapters"]) - 1 else ""))
        chapters.append("    ]")
        out.append(",\n".join(lines + ["\n".join(chapters)]))
        out.append("  }" + ("," if ci < len(courses) - 1 else ""))
    out.append("]")
    return "\n".join(out) + "\n"


def course_files():
    manifest = json.loads((COURSES / "manifest.json").read_text(encoding="utf-8"))
    return [COURSES / m["file"] for m in manifest]


def main():
    check = "--check" in sys.argv
    stale = 0
    grand_before = grand_after = 0
    for path in course_files():
        courses = json.loads(path.read_text(encoding="utf-8"))
        for c in courses:
            for ch in c["chapters"]:
                new = chapter_minutes(ch)
                grand_before += ch.get("duration", 0)
                grand_after += new
                if ch.get("duration") != new:
                    stale += 1
                    ch["duration"] = new
            total = sum(ch["duration"] for ch in c["chapters"])
            if c.get("duration") != total:
                stale += 1
                c["duration"] = total
        if not check:
            path.write_text(dump_courses(courses), encoding="utf-8")
    print(f"durée totale : {grand_before} min -> {grand_after} min "
          f"({grand_after / 60:.1f} h) ; {stale} valeur(s) à jour")
    if check and stale:
        print("Durées désynchronisées : lancer python3 tool/content_durations.py")
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
