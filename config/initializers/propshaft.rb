# dartsass-rails compiles app/assets/stylesheets/application.scss to
# app/assets/builds/application.css, which Propshaft picks up automatically.
# Exclude the raw Sass sources so they don't get fingerprinted and served
# alongside the compiled CSS.
Rails.application.config.assets.excluded_paths << Rails.root.join("app/assets/stylesheets")

# simple_calendar ships its own stylesheet via an engine load path. We fork
# the relevant rules into app/assets/stylesheets/_simple_calendar.scss, so
# exclude the gem's stylesheet to keep its raw source out of public/assets.
simple_calendar_spec = Gem.loaded_specs["simple_calendar"]
if simple_calendar_spec
  Rails.application.config.assets.excluded_paths << Pathname.new(simple_calendar_spec.gem_dir).join("app/assets/stylesheets")
end
