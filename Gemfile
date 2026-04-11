source "https://rubygems.org"

gem "rails", ">= 7.1"
gem "propshaft"
gem "dartsass-rails"
gem "importmap-rails"

gem "json", ">= 2.3.0"
gem "nokogiri", ">= 1.15.6"

gem "mysql2", "~> 0.5"
gem "net-ldap"
gem "bcrypt", "~> 3.1"

gem "puma"

# For Markdown parsing/rendering of candidate / diary / interview / submission notes.
gem "redcarpet", "~> 3.6"

group :development, :test do
  # Ruby static analysis with the Rails-omakase preset (the Rails team's
  # opinionated, intentionally minimal style). Run via `bundle exec rubocop`.
  gem "rubocop-rails-omakase", require: false

  # Security static-analysis. Run via `bundle exec brakeman`.
  gem "brakeman", require: false
end
