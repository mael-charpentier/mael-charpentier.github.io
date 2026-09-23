# mael-charpentier.github.io

Personal website (Jekyll, hosted on GitHub Pages, English and French).

## Structure

- `_config.yml` : site settings, default front matter for the posts, and the
  two-language setup (`languages`, `default_lang`).
- `_layouts/` : `default` (header, navigation, social icons, footer),
  `list-post` (a section listing, with the filter and sort toolbar),
  `post` (a single entry), `timeline` (ApexCharts).
- `_data/nav.yml` : the navigation menu (one entry per section). `posts: true`
  marks a section that has posts, and `rank` its place on the home page and on
  the timeline, so a new section only has to be declared here.
- `_data/en/strings.yml`, `_data/fr/strings.yml` : every piece of interface text,
  in both languages. A page reads them with
  `{% assign t = site.data[site.active_lang].strings %}` and then `{{ t.more_info }}`.
- `_data/skills.yml` : display name of the icons in `assets/images/skills/`.
- `_includes/home-sections.html` : the part of the home page shared by
  `index.html` (English) and `index-fr.html` (French).
- One folder per section, each with an `index.html` and a `_posts/` folder :
  `education`, `experience`, `teaching`, `conferences`, `awards`, `projects`.
- `search/` and `search.json` : the site search. The index is rebuilt at every
  deployment, there is nothing to maintain.
- `assets/` : `css`, `js`, `images` (logos, icons, favicons, skills) and `doc` (CV, posters).
- `bin/`, `Makefile` : the helper scripts (see below).

## Building the site

GitHub Pages no longer builds the site itself : `.github/workflows/pages.yml`
runs `bundle exec jekyll build`, which allows any plugin (`jekyll-polyglot` is
not on the GitHub Pages allow list). This is set once in
**Settings > Pages > Build and deployment > Source = GitHub Actions**.

`bin/check-liquid.rb` parses every template with Liquid itself, the same way the
build does. It catches what a text search cannot : a `{` inside a `{{ }}` tag
(Liquid stops at the first `}`), or a Liquid tag left inside an HTML comment
(Liquid parses it anyway). `bin/check-content.py` needs no Ruby at all.

## Adding an entry

```
bin/new-post.sh awards "FRQNT doctoral scholarship"
bin/new-post.sh conferences "JOPT 2027" 2027-05-10
bin/new-post.sh publications "A first paper"     # the section does not exist yet
```

This creates `<section>/_posts/YYYY-MM-DD-slug.html` with the front matter
already filled in. When the section does not exist, it is created too : the
folder, its listing page, the entry in `_data/nav.yml` and the three labels in
`_data/en|fr/strings.yml` (they start as the name of the section, and are there
to be translated). `_config.yml` sets the layout, the excerpt separator and the
social icons, so the front matter only needs :

```
---
title: "Title of the card"
image: "/assets/images/logos/logo-xxx.png"   # optional
imageAlt: "Description of the image"          # optional
datePost: "2026-01-05;2026-04-30"             # one or several periods, comma separated
---
```

`datePost` feeds the timeline : `start;end` for a period (`present` is allowed as an end),
a single date for a one-day entry, and several periods separated by commas.
The text before `<!--more-->` is the summary shown on the card.

The URL of a post keeps the case of its file name
(`awards/_posts/2024-08-31-BRPC.html` becomes `/awards/2024/08/31/BRPC.html`).

## The two languages

English is the default language and is served at the root ; French is served
under `/fr/`. **A page with no French version is still shown on the French
site**, with the menu, the titles and the links in French : translating is
optional and can be done one page at a time.

Both languages of a post live **in the same file**, separated by `{% else %}` :

```
{% if site.active_lang == "fr" %}
    ... texte français ...
{% else %}
    ... English text ...
{% endif %}
```

There is one such block for the summary (before `<!--more-->`) and one for the
entry itself, so that each half stays balanced and the card summary keeps
working. `title_fr` in the front matter translates the title of the card.

- interface text (menu, buttons, section titles) : `_data/en|fr/strings.yml`,
  nothing else to do ;
- a post : `bin/translate-post.sh awards/_posts/2024-08-31-BRPC.html` duplicates
  the two halves and adds `title_fr`, then translate the French branch.
- a page : same idea, see the "More about" section of `index.html`.

## Adding a programming language icon

Drop the logo in `assets/images/skills/` (`typescript.svg`, `c.svg`, ...) and, if
the name is not written the way the file is named, add one line to
`_data/skills.yml` (`cpp: "C++"`). The page lists the folder, so nothing else
has to be edited.

## What is automatic

- the date in the footer is the build date (`site.time`) ;
- the search index (`search.json`) is rebuilt at every deployment, in both languages ;
- every push to `main` builds and deploys the site ; a build error stops the
  deployment instead of publishing a broken site ;
- every pull request and every Monday, `.github/workflows/checks.yml` checks the
  front matter, the internal links, the images, the missing translations
  (`bin/check-content.py`) and the external links (lychee), and opens an issue
  when an external link dies.

## Notes

- The date shown in the footer is the build date (`site.time`), so it updates on
  every deployment.

## TODO

- mobile version : spacing and width/height of the timeline
- update CV
