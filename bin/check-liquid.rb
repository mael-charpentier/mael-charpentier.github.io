#!/usr/bin/env ruby
# Parse every template with Liquid itself, the same way Jekyll does at build time.
# This catches syntax errors that a text search cannot see, such as a { inside a
# {{ }} tag, before the GitHub Actions build does.
#
#   ruby bin/check-liquid.rb   (from the root of the site)
require "liquid"

# Tags that come from plugins : parsing only needs them to exist.
class PolyglotStaticHref < Liquid::Block; end
Liquid::Template.register_tag("static_href", PolyglotStaticHref)

FRONT_MATTER = /\A---\s*\n.*?\n---\s*\n/m
problems = 0
count = 0

Dir.glob("**/*.{html,json}").sort.each do |path|
  next if path.start_with?("_site/", "vendor/")
  source = File.read(path).sub(FRONT_MATTER, "")
  count += 1
  begin
    Liquid::Template.parse(source, line_numbers: true)
  rescue Liquid::Error => e
    puts "PROBLEM: #{path}: #{e.message}"
    problems += 1
  end
end

puts "\n#{count} templates, #{problems} problem(s). Liquid #{Liquid::VERSION}."
exit(problems.zero? ? 0 : 1)
