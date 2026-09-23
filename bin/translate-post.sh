#!/usr/bin/env bash
# Make a post bilingual. Both languages stay in the same file : the body is
# duplicated inside {% if site.active_lang == "fr" %} ... {% else %} ... {% endif %},
# once before <!--more--> (the card summary) and once after (the entry itself),
# so that each half stays balanced and the summary keeps working.
#
#   bin/translate-post.sh awards/_posts/2024-08-31-BRPC.html
#
# The copy starts as the English text : what is left to do is translating the
# French branch, and the title_fr added to the front matter.
set -euo pipefail

[ $# -eq 1 ] || { sed -n '2,11p' "$0" >&2; exit 1; }

post=$1
[ -f "$post" ] || { echo "No such file : $post" >&2; exit 1; }
grep -q "site.active_lang" "$post" && { echo "Already bilingual : $post" >&2; exit 1; }

tmp=$(mktemp)
awk '
  BEGIN { part = 0 }                       # 0 front matter, 1 summary, 2 entry
  NR == 1 && $0 == "---" { print; next }
  part == 0 && $0 == "---" { print; part = 1; next }
  part == 0 {
    print
    if ($0 ~ /^title:/ && !seen_title) {   # a French title, to translate
      line = $0; sub(/^title:[ \t]*/, "", line)
      print "title_fr: " line
      seen_title = 1
    }
    next
  }
  /^<!--more-->/ { flush(1); print; part = 2; next }
  { buffer[++n] = $0 }
  END { flush(2) }

  function flush(which,   i) {
    print "{% if site.active_lang == \"fr\" %}"
    for (i = 1; i <= n; i++) print buffer[i]
    print "{% else %}"
    for (i = 1; i <= n; i++) print buffer[i]
    print "{% endif %}"
    n = 0
  }
' "$post" > "$tmp"

mv "$tmp" "$post"
echo "$post  (translate the {% if %} branch and title_fr ; the {% else %} branch stays English)"
