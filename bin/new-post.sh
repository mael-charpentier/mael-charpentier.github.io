#!/usr/bin/env bash
# Create a post in the right section, with the front matter already filled in.
#
#   bin/new-post.sh awards "FRQNT doctoral scholarship"
#   bin/new-post.sh conferences "JOPT 2027" 2027-05-10
#
# The date (today by default) is used by the file name, the URL and the sort.
#
# When the section does not exist yet, it is created : the folder, its listing
# page, the entry in _data/nav.yml and the three labels in _data/en|fr/strings.yml
# (to be translated, they start as the name of the section).
set -euo pipefail

if [ $# -lt 2 ]; then
  sed -n '2,12p' "$0" >&2
  exit 1
fi

section=$1
title=$2
date=${3:-$(date +%F)}

slugify() {
  printf '%s' "$1" \
    | iconv -f utf-8 -t ascii//TRANSLIT \
    | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[^a-z0-9]+/-/g; s/^-|-$//g'
}

section=$(slugify "$section")
label="$(tr '[:lower:]' '[:upper:]' <<< "${section:0:1}")${section:1}"

create_section() {
  mkdir -p "$section/_posts"

  cat > "$section/index.html" <<EOF
---
layout: list-post
title: $label - Maël Charpentier
socialActivate: true
id: $section
section: $label
---
EOF

  # Menu : inserted before the pages that have no posts, with the next rank.
  rank=$(($(grep -c '^  posts: true$' _data/nav.yml) + 1))
  awk -v id="$section" -v rank="$rank" '
    !done && $0 == "- id: skills" {
      print "- id: " id
      print "  url: /" id "/index.html"
      print "  section: /" id "/"
      print "  posts: true"
      print "  rank: " rank
      done = 1
    }
    { print }
  ' _data/nav.yml > _data/nav.yml.tmp && mv _data/nav.yml.tmp _data/nav.yml

  # Labels : the same text in both languages, to be translated.
  for language in en fr; do
    file="_data/$language/strings.yml"
    for group in nav section home; do
      sed -i "/^$group:\$/a\\  $section: \"$label\"" "$file"
    done
  done

  echo "$section/index.html  (new section : translate its labels in _data/fr/strings.yml)"
}

[ -d "$section/_posts" ] || create_section

file="$section/_posts/$date-$(slugify "$title").html"
[ -e "$file" ] && { echo "Already exists : $file" >&2; exit 1; }

cat > "$file" <<EOF
---
title:  "$title"
image: "/assets/images/logos/logo-xxx.png"
imageAlt: "To be completed"
datePost: "$date"
---
<div class="resume">
    To be completed : the summary shown on the card.
</div>
<!--more-->
<section class="all $section">
    <div class="header">
        <img class="logo" alt="{{ page.imageAlt }}" src="{{ page.image }}"/>
        <div class="title">
            $title
        </div>
        <div class="date">
            $date
        </div>
    </div>
    <div class="content">
        To be completed.
    </div>
</section>
EOF

echo "$file"
