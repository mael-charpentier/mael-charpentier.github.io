#!/usr/bin/env python3
"""Checks that need neither Ruby nor Jekyll : front matter of the posts, date
format, internal links, missing images, posts still marked "present".

Usage : python3 bin/check-content.py   (from the root of the site)
Output : one line per problem, exit code 1 when there is one.
"""
import pathlib
import re
import sys

import yaml

ROOT = pathlib.Path(__file__).resolve().parent.parent
SECTIONS = [item["id"] for item in yaml.safe_load((ROOT / "_data/nav.yml").read_text())
            if item.get("posts")]
FRONT_MATTER = re.compile(r"\A---\n(.*?)\n---\n", re.S)
FIELD = re.compile(r"^(\w+):\s*(.*)$", re.M)
DATE_PART = re.compile(r"^(\d{4}-\d{2}-\d{2}|present)$")
LINK = re.compile(r'(?:href|src)=["\']([^"\']+)["\']')
COMMENT = re.compile(r"<!--.*?-->", re.S)

problems = []
warnings = []
TAGS = ["if", "for", "case", "capture", "comment", "static_href", "unless"]
OPEN_TAG = re.compile(r"{%-?\s*(\w+)")
STRING_KEY = re.compile(r"{{-?\s*t\.([\w.]+)")
STRING_LOOKUP = re.compile(r"t\.(\w+)\[")


def check_front_matter(path, data):
    """title and datePost are required ; image and imageAlt go together."""
    if "title" not in data:
        problems.append(f"{path}: no title")
    if "datePost" not in data:
        problems.append(f"{path}: no datePost")
        return
    for period in data["datePost"].strip('"\' ').split(","):
        parts = period.strip().split(";")
        if len(parts) > 2 or not all(DATE_PART.match(p.strip()) for p in parts):
            problems.append(f"{path}: datePost cannot be read ({period.strip()})")
    if ("image" in data) != ("imageAlt" in data):
        problems.append(f"{path}: image and imageAlt must go together")
    if "present" in data["datePost"]:
        warnings.append(f"{path}: still running (\"present\"), to update once it is over")


def check_liquid(path, text):
    """Liquid tags opened and never closed : Jekyll would refuse to build."""
    counts = {tag: 0 for tag in TAGS}
    for name in OPEN_TAG.findall(text):
        if name in counts:
            counts[name] += 1
        elif name.startswith("end") and name[3:] in counts:
            counts[name[3:]] -= 1
    for tag, count in counts.items():
        if count != 0:
            problems.append(f"{path}: {abs(count)} {tag} tag(s) never " +
                            ("closed" if count > 0 else "opened"))


def check_strings(files):
    """Every t.xxx key used in a template must exist in both languages."""
    languages = {}
    for path in sorted((ROOT / "_data").glob("*/strings.yml")):
        languages[path.parent.name] = yaml.safe_load(path.read_text(encoding="utf-8"))
    for path in files:
        text = path.read_text(encoding="utf-8")
        keys = set(STRING_KEY.findall(text))
        for group in STRING_LOOKUP.findall(text):
            keys.add(group)  # t.nav[item.id] : only the group can be checked
        for key in sorted(keys):
            for lang, strings in languages.items():
                value = strings
                for part in key.split("."):
                    value = value.get(part) if isinstance(value, dict) else None
                if value is None:
                    problems.append(f"{path.relative_to(ROOT)}: t.{key} missing from _data/{lang}/strings.yml")
    return languages


def post_urls():
    """URL Jekyll gives to each post (the case of the file name is kept)."""
    urls = {}
    for section in SECTIONS:
        for post in (ROOT / section / "_posts").glob("*.html"):
            year, month, day, slug = post.stem.split("-", 3)
            urls[f"/{section}/{year}/{month}/{day}/{slug}.html"] = post
    return urls


def main():
    known = post_urls()
    files = [p for p in ROOT.rglob("*.html") if "_site" not in p.parts]
    for path in sorted(files):
        text = path.read_text(encoding="utf-8")
        # Links inside a comment (TODO) are not served : skip them.
        text = COMMENT.sub("", text)
        rel = path.relative_to(ROOT)
        match = FRONT_MATTER.match(text)
        if match and "_posts" in path.parts:
            check_front_matter(rel, dict(FIELD.findall(match.group(1))))
        check_liquid(rel, text)
        for link in LINK.findall(text):
            target = link.replace("{{ site.url }}", "").split("#")[0]
            if not target.startswith("/") or target.startswith("//"):
                continue
            if target.startswith("/assets/"):
                if not (ROOT / target.lstrip("/")).exists():
                    problems.append(f"{rel}: missing file {target}")
            elif target.endswith(".html") and "/20" in target:
                if target not in known:
                    problems.append(f"{rel}: dead internal link {target}")

    languages = check_strings(files)

    for line in warnings:
        print("note   :", line)
    for line in problems:
        print("PROBLEM:", line)
    print(f"\n{len(known)} posts, {len(languages)} language(s), "
          f"{len(problems)} problem(s), {len(warnings)} note(s).")
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
