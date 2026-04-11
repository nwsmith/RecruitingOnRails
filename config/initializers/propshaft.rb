# dartsass-rails compiles app/assets/stylesheets/application.scss to
# app/assets/builds/application.css, which Propshaft picks up automatically.
# Exclude the raw Sass sources so they don't get fingerprinted and served
# alongside the compiled CSS.
Rails.application.config.assets.excluded_paths << Rails.root.join("app/assets/stylesheets")

# Rails default frameworks come along with `require 'rails/all'` in
# config/application.rb, and each one's railtie registers its app/assets
# directory with Propshaft. We don't actually use any of their JS/CSS — no
# <%= action_text|trix|rails-ujs|action_cable %> tags, no Active Storage
# direct uploads, no Action Text rich-text editors — but Propshaft would
# ship them in precompile output anyway. Excluding their asset subdirectories
# trims ~700 KB from public/assets/ without changing app behavior. The
# frameworks themselves stay loaded.
{
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
