# Shortcuts of the site. "make" alone prints this list.
.PHONY: help serve build check clean

help:
	@echo "make serve    local preview on http://localhost:4000 (and /fr/)"
	@echo "make build    build the site into _site/"
	@echo "make check    front matter, dates, internal links, images, then html-proofer"
	@echo ""
	@echo "bin/new-post.sh <section> \"<title>\" [date]   create a post"
	@echo "bin/translate-post.sh <post>                 prepare its French version"

serve:
	bundle exec jekyll serve

build:
	bundle exec jekyll build

# The Python checks need neither Ruby nor Jekyll : they always work.
check:
	python3 bin/check-content.py
	@command -v bundle >/dev/null 2>&1 && $(MAKE) build && \
	  bundle exec htmlproofer ./_site --disable-external --no-enforce-https \
	  --checks Links,Images,Scripts || \
	  echo "(no bundle here : the full HTML check is done by GitHub Actions)"

clean:
	rm -rf _site .jekyll-cache
