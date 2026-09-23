# Shortcuts of the site. "make" alone prints this list.
.PHONY: help serve build check clean

help:
	@echo "make serve    local preview on http://localhost:4000 (and /fr/)"
	@echo "make build    build the site into _site/"
	@echo "make check    front matter, dates, links, images, Liquid syntax, html-proofer"
	@echo ""
	@echo "bin/new-post.sh <section> \"<title>\" [date]   create a post"
	@echo "bin/translate-post.sh <post>                 prepare its French version"

serve:
	bundle exec jekyll serve

build:
	bundle exec jekyll build

# Every check runs, even when an earlier one fails, so nothing stays hidden.
# The Python checks need neither Ruby nor Jekyll : they always work.
check:
	@status=0; \
	python3 bin/check-content.py || status=1; \
	if command -v ruby >/dev/null 2>&1; then \
	  ruby bin/check-liquid.rb || status=1; \
	else echo "(no ruby here : the Liquid syntax check is done by GitHub Actions)"; fi; \
	if command -v bundle >/dev/null 2>&1; then \
	  $(MAKE) build && bundle exec htmlproofer ./_site --disable-external \
	    --no-enforce-https --checks Links,Images,Scripts || status=1; \
	else echo "(no bundle here : the full HTML check is done by GitHub Actions)"; fi; \
	exit $$status

clean:
	rm -rf _site .jekyll-cache
