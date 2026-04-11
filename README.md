# RecruitingOnRails

A Rails application for managing a recruiting/hiring pipeline — candidates,
interviews, code submissions, reference checks, diary entries, and the
reports that aggregate them.

## Stack

| Layer | Choice |
|---|---|
| Framework | Rails 8.1.x |
| Database | MySQL 8 / 9 (via the `mysql2` gem) |
| Asset pipeline | Propshaft + dartsass-rails for CSS, importmap-rails for JS |
| CSS framework | [Pico CSS 2.1.1](https://picocss.com/) (vendored at `vendor/stylesheets/pico.min.css`) |
| Frontend timeline | [vis-timeline 7.7.3](https://visjs.github.io/vis-timeline/) UMD bundle, vendored under `vendor/javascript/` |
| Auth | Internal bcrypt + LDAP via `net-ldap`, dispatched per `AuthConfig` |
| Markdown rendering | redcarpet |
| Tests | Minitest + Rails fixtures, ActionDispatch::IntegrationTest for controller / integration tests |

There are **zero external runtime dependencies**: no CDN refs, no
third-party API calls, no analytics. Everything ships from `/assets/`.

## Quick start

Prerequisites:

- Ruby 3.3+ (Homebrew Ruby works; `.ruby-version` is informational)
- MySQL 8 or 9 running locally
- Bundler 2.4.19 (pinned in `Gemfile.lock`)

```sh
# One-time setup: create the recruiting MySQL user and the test/dev databases.
# (See test/repo_setup.sh or follow the manual steps in CLAUDE.md.)

PATH=/opt/homebrew/opt/ruby/bin:$PATH gem install bundler -v 2.4.19
PATH=/opt/homebrew/opt/ruby/bin:$PATH bundle _2.4.19_ install

PATH=/opt/homebrew/opt/ruby/bin:$PATH \
  DB_USERNAME=recruiting DB_PASSWORD=recruiting RAILS_ENV=test \
  bundle exec rake db:schema:load

PATH=/opt/homebrew/opt/ruby/bin:$PATH \
  DB_USERNAME=recruiting DB_PASSWORD=recruiting \
  bundle exec rake test
```

Expected: `693 runs, 1948 assertions, 0 failures, 0 errors, 0 skips`
(approximate — grows over time).

## Running the app locally

```sh
PATH=/opt/homebrew/opt/ruby/bin:$PATH \
  DB_USERNAME=recruiting DB_PASSWORD=recruiting \
  bin/dev
```

`bin/dev` starts the Rails server AND the dartsass watcher in parallel
(via the `Procfile.dev`). Without it, you'd need two terminals: one for
`bin/rails server` and one for `bin/rails dartsass:watch`.

Then open `http://localhost:3000`. The first user with `admin: true` in
the seeds is the bootstrap admin.

## Access model

Five role flags on `User`:

| Role | Definition | Granted access |
|---|---|---|
| `admin` | `User#admin?` | Everything, including user/auth/registry CRUD |
| `manager` | `User#manager?` | Diary entries, all candidate views, manager fields |
| `hr` | `User#hr?` | Candidate views, HR fields (budgets etc.) |
| `staff` | `admin? \|\| manager? \|\| hr?` | Reference data, reports, candidate enumeration |
| `regular` | logged-in but no other flag | Their own self-candidate record only |

The `check_staff` / `check_admin` / `check_login` / `check_candidate_access`
helpers in `ApplicationController` enforce these. Reference-data and
reports controllers are gated to `check_staff`. Per-record candidate
access (interviews, code submissions, attachments) flows through
`check_candidate_access` which honors the `Candidate.user_id` FK and
falls back to a legacy `first.last == user_name` match.

## Content Security Policy

A strict CSP is enforced via `config/initializers/content_security_policy.rb`:

- `script-src 'self' 'nonce-<per-request>'` — no `unsafe-inline`. The
  importmap-rails inline `<script type="importmap">` and
  `<script type="module">` tags get a per-request nonce automatically.
- `style-src 'self' 'unsafe-inline'` — needed because `color_span` and the
  diary-entry color helper emit inline `style="color: ..."` attributes
  from per-record DB color values, and CSP nonces only protect `<style>`
  *elements*, not `style=""` *attributes*.
- `img-src 'self' data:` — for the `data:image/svg+xml,...` favicon.
- `default-src 'self'`, `object-src 'none'`, `base-uri 'self'`,
  `form-action 'self'`, `frame-ancestors 'none'`.

`test/integration/content_security_policy_test.rb` is the regression check.

## Asset pipeline

dartsass-rails compiles `app/assets/stylesheets/application.scss` to
`app/assets/builds/application.css`, which Propshaft then fingerprints
and serves. importmap-rails handles the JS entry point at
`app/javascript/application.js` (~70 lines: a `data-confirm` listener
plus the `candidates#timeline` initializer, gated on the presence of
the `#my-timeline` element).

Vendored libraries live under `vendor/javascript/` (vis-timeline UMD)
and `vendor/stylesheets/` (Pico CSS, vis-timeline CSS). They're added
to Propshaft's load path via `config/initializers/propshaft.rb`, which
also excludes a handful of unused Rails-default-framework engine asset
paths (action_text, actioncable, activestorage, actionview, trix) so
their JS doesn't get fingerprinted into `public/assets/`.

A clean-slate `RAILS_ENV=production assets:precompile` should emit
exactly 5 files:

```
application-<hash>.css           # compiled SCSS bundle
application-<hash>.js            # importmap entry
pico.min-<hash>.css              # vendored
vis-timeline-graph2d.min-<hash>.js   # vendored
vis-timeline-graph2d.min-<hash>.css  # vendored
```

If you see more, an engine asset path snuck back in or a new vendored
file got added without being noted here.

## Project layout notes

- `app/controllers/reports/` — 8 nested report controllers (each with
  `index` form + `run` query/render). Surface tested in
  `test/integration/reports_controllers_test.rb`.
- `lib/reports.rb` — `Reports::PeriodInfo`, `Reports::ReportTable`,
  `Reports::YearInfo`. Plain Ruby classes, not ActiveRecord. Tested in
  `test/lib/reports_test.rb`.
- `app/javascript/application.js` — the only JS file the app ships.
  Loaded by importmap-rails on every page; the timeline init is a
  no-op when `#my-timeline` isn't present.

## Production deployment

There isn't one yet. The `production` environment exists in
`config/environments/production.rb` so `RAILS_ENV=production` works for
sanity-checking the asset pipeline, but no infrastructure is
provisioned and there is no Capistrano/Kamal/Docker setup. When you
deploy for real, you'll need to:

1. Pick a host and provision MySQL there
2. Add a real `production:` block to `config/database.yml` (the gitignored one)
3. Configure object storage in `config/storage.yml` and switch
   `config.active_storage.service` from `:local` to whatever you pick
4. Rotate `secret_key_base`
5. Set up TLS, log shipping, monitoring, backups

See `CLAUDE.md` for detailed contributor / agent guidance.
