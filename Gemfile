# Dependencies of the site. GitHub Pages does not build the site itself any
# more : .github/workflows/pages.yml runs `bundle exec jekyll build`, which allows
# any plugin (jekyll-polyglot is not on the GitHub Pages allow list).
#
#   bundle install            install the gems
#   bundle exec jekyll serve  local preview on http://localhost:4000
source "https://rubygems.org"

gem "jekyll", "~> 4.4"
gem "webrick", "~> 1.9" # required by `jekyll serve` since Ruby 3.0

group :jekyll_plugins do
  gem "jekyll-polyglot", "~> 1.8" # English / French site
  gem "jekyll-sitemap", "~> 1.4"  # sitemap.xml
end

group :test do
  gem "html-proofer", "~> 5.0" # link checking (make check)
end
