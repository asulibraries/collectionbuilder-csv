###############################################################################
# TASK: build_relative
# Builds the Jekyll site and rewrites root-absolute links to relative paths so
# the generated _site can be opened via file:// (no webserver required).
###############################################################################

desc 'Build site and convert root-absolute links to relative for file:// viewing'
task :build_relative do
  ENV['JEKYLL_ENV'] = 'production'
  sh 'bundle', 'exec', 'jekyll', 'build'
  sh 'ruby', 'scripts/make_relative_links.rb', '_site'
end
