#!/usr/bin/env ruby
# Converts absolute root-leading href/src (e.g. href="/assets/...") into relative paths
# so generated files in _site can be opened via file://

require 'find'
require 'pathname'

site_dir = ARGV[0] || '_site'
unless Dir.exist?(site_dir)
  warn "Directory not found: #{site_dir}"
  exit 1
end

Find.find(site_dir) do |path|
  next unless File.file?(path)
  # process text files where links are expected
  next unless path =~ /\.(html?|htm|js|json|css)$/i

  rel_path = Pathname.new(path).relative_path_from(Pathname.new(site_dir)).to_s
  # depth = number of path segments (items/foo.html => 1)
  depth = rel_path.count(File::SEPARATOR)
  prefix = depth == 0 ? '' : ('../' * depth)

  text = File.binread(path)

  # Replace occurrences like href="/foo" or src='/foo' but NOT protocol-relative (//) or absolute URLs (http://)
  # Fix attribute-style links first (href=, src=)
  new_text = text.gsub(/(href|src)=(["'])\/(?!\/)/i) { |m| "#{Regexp.last_match(1)}=#{Regexp.last_match(2)}#{prefix}" }
  # Also fix any quoted root-leading paths inside JS strings or other places (e.g. '/items/')
  # Only replace when the leading slash is followed by a non-terminating character (not a quote, backtick, paren, or whitespace) —
  # this avoids accidentally changing short strings like "/" used in CSS variables.
  new_text = new_text.gsub(/(["'])\/(?!\/)(?=[^"'`\)\s])/) { |m| "#{Regexp.last_match(1)}#{prefix}" }
  # Also handle ES6 template literals (backticks) like `/items/${...}`
  new_text = new_text.gsub(/(`)\/(?!\/)(?=[^"'`\)\s])/) { |m| "#{Regexp.last_match(1)}#{prefix}" }
  # Revert breadcrumb CSS variable accidentally converted earlier (e.g. var(--bs-breadcrumb-divider, "../../"))
  new_text = new_text.gsub(/var\(--bs-breadcrumb-divider,\s*(['"`])(?:\.\.\/)+\1\s*\)/, "var(--bs-breadcrumb-divider, \"/\")")

  if new_text != text
    File.open(path, 'wb') { |f| f.write(new_text) }
    puts "Patched: #{path}"
  end
end
