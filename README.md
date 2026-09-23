# mael-charpentier.github.io

Personal website (Jekyll, hosted on GitHub Pages).

## Structure

- `_config.yml` : site settings and default front matter for the posts.
- `_layouts/` : `default` (header, navigation, social icons, footer),
  `list-post` (a section listing), `post` (a single entry), `timeline` (ApexCharts).
- One folder per section, each with an `index.html` and a `_posts/` folder :
  `education`, `experience`, `teaching`, `conferences`, `awards`, `projects`.
- `assets/` : `css`, `js`, `images` (logos, icons, favicons, skills) and `doc` (CV, posters).

## Adding an entry

Create a file in the `_posts` folder of the section, named `YYYY-MM-DD-slug.html`.
`_config.yml` already sets the layout, the excerpt separator and the social icons, so
the front matter only needs :

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

## Notes

- The date shown in the footer is the build date (`site.time`), so it updates on
  every deployment.

## TODO

- mobile version : spacing and width/height of the timeline
- search
- sort the posts
- multi language
- update CV
