# dartsass-rails compiles app/assets/stylesheets/application.scss to
# app/assets/builds/application.css, which Propshaft picks up automatically.
# Exclude the raw Sass sources so they don't get fingerprinted and served
# alongside the compiled CSS.
Rails.application.config.assets.excluded_paths << Rails.root.join("app/assets/stylesheets")

# simple_calendar ships its own stylesheet via an engine load path. We fork
# the relevant rules into app/assets/stylesheets/_simple_calendar.scss, so
# exclude the gem's stylesheet to keep its raw source out of public/assets.
#
# The other entries here are Rails default frameworks that come along with
# `require 'rails/all'` in config/application.rb. We don't actually use any
# of their JS/CSS — no <%= action_text|trix|rails-ujs|action_cable %> tags,
# no Active Storage direct uploads, no Action Text rich-text editors — but
# Propshaft picks up every engine asset path by default and ships them in
# precompile output anyway. Excluding them trims ~700 KB from public/assets/
# without changing app behavior. The frameworks themselves stay loaded.
{
  "simple_calendar"  => %w[app/assets/stylesheets],
  "actiontext"       => %w[app/assets/javascripts],
  "action_text-trix" => %w[app/assets/javascripts app/assets/stylesheets],
  "actioncable"      => %w[app/assets/javascripts],
  "activestorage"    => %w[app/assets/javascripts],
  "actionview"       => %w[app/assets/javascripts],
}.each do |gem_name, subdirs|
  spec = Gem.loaded_specs[gem_name]
  next unless spec
  subdirs.each do |subdir|
    Rails.application.config.assets.excluded_paths << Pathname.new(spec.gem_dir).join(subdir)
  end
end

# Vendored third-party stylesheets (e.g. vis-timeline). importmap-rails already
# adds vendor/javascript to the load path; the matching stylesheets directory
# is not standard, so add it explicitly so Propshaft fingerprints and serves
# the files.
Rails.application.config.assets.paths << Rails.root.join("vendor/stylesheets")
