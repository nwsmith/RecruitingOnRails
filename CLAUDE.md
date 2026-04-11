# Claude / contributor notes

This file is loaded automatically into the Claude Code agent context
and is also useful for human contributors. It documents the
non-obvious things about working on this app — the environment quirks,
gotchas, and architectural decisions that aren't visible from a surface
read of the code.

## Verified test command

```sh
PATH=/opt/homebrew/opt/ruby/bin:$PATH \
  DB_USERNAME=recruiting DB_PASSWORD=recruiting \
  bundle exec rake test
```

The PATH prefix is required because:

- `.ruby-version` says `3.2.3` but the only working Ruby on this
  machine is Homebrew's 3.3.1 at `/opt/homebrew/opt/ruby/bin/ruby`.
  Without the PATH prefix, system Ruby (2.6) gets picked up and
  bundle install fails on native gems.
- `Gemfile.lock` is `BUNDLED WITH 2.4.19`. Install bundler explicitly:
  `gem install bundler -v 2.4.19`.

The DB env vars are required because `config/database.yml`'s
`production` block does `ENV.fetch("DB_USERNAME")` with no default,
and Rails parses all environments at boot — so even running test tasks
needs `DB_USERNAME`/`DB_PASSWORD` set to *something*. The values can
be the test creds (`recruiting`/`recruiting`).

## Propshaft stale-manifest gotcha

After running `RAILS_ENV=production rake assets:precompile` to verify
the asset pipeline, **always wipe `public/assets/` before running
tests**. Propshaft picks the Static (manifest-based) resolver if
`public/assets/.manifest.json` exists, and the Static resolver only
knows about assets that were precompiled into the manifest. So if you
add a new vendored file (or change an existing one) and then run
tests without re-precompiling, you'll get
`Propshaft::MissingAssetError` — the load path can find the file but
the resolver doesn't know about it.

```sh
rm -rf public/assets && bundle exec rake test
```

This bit me twice in a single session before I documented it. It's
purely a local-dev artifact (CI never precompiles in test).

## Asset pipeline architecture

- **Sprockets is gone.** Propshaft is the asset pipeline. dartsass-rails
  compiles SCSS independently to `app/assets/builds/`. importmap-rails
  handles the lone JS entry point.
- **Zero CDN dependencies.** vis-timeline and Pico CSS are vendored
  under `vendor/javascript/` and `vendor/stylesheets/`. Don't add CDN
  refs without good reason — there's a CSP regression test that would
  blow up the moment one shows up.
- **CSP is strict.** `script-src 'self' 'nonce-<X>'`. The
  importmap-rails inline tags use Rails' nonce mechanism
  automatically. Don't add inline `<script>` blocks to views — extract
  to `app/javascript/application.js` and gate on a DOM check (the
  candidates#timeline initializer is the canonical example).
- **`style-src` allows `'unsafe-inline'`** as a documented compromise
  for the per-record dynamic colors emitted by `color_span` and the
  diary entry link helper. Nonces don't apply to `style=""`
  attributes, only to `<style>` elements.

## Access control patterns

The auth gates live in `app/controllers/application_controller.rb`:

- `check_login` — runs as a global `before_action` on every controller.
  Accepts either an `Authorization: Bearer <api_key>` header or a
  session cookie. Redirects to `root_path` (which is `login#index`)
  on failure.
- `check_admin` — used on `users`, `auth_configs`, `auth_config_types`,
  `registries`. Redirects to `dashboard_path` if not admin.
- `check_staff` — used on every reference-data controller and every
  reports/* controller. Redirects to `dashboard_path` if the user
  isn't admin/manager/hr. Returns `true` if access was denied so
  callers can `return if check_staff` to avoid double-render.
- `check_candidate_access(candidate)` — used by `candidates_controller`
  and the per-record candidate-related controllers (interviews,
  code_submissions, candidate_attachments, work_history_rows,
  reference_checks, diary_entries). Honors the `Candidate.user_id` FK
  for the self-candidate flow with a legacy `first.last == user_name`
  fallback (the fallback is scoped to `where(user_id: nil)` so
  FK-owned candidates can't leak via name collision).

**All redirects from these gates use named path helpers (`root_path`,
`dashboard_path`)** rather than the `controller:`/`action:` hash form.
Hash-form redirects do namespace-relative resolution — from a
namespaced controller like `Reports::BudgetReportController`,
`controller: 'dashboard'` resolves to `Reports::DashboardController`
which doesn't exist and raises `UrlGenerationError`. We had this
exact bug latently before; don't reintroduce it.

## Test fixtures and patterns

- `test/fixtures/` only contains `users.yml`, `auth_configs.yml`,
  `auth_config_types.yml`. Everything else creates models inline in
  `setup do` blocks.
- The fixture users are: `admin`, `manager`, `hruser`, `regular`,
  `self_candidate_user`, `inactive`. All share the bcrypt password
  `password`.
- `login_as(username)` is defined in `test/test_helper.rb` for all
  `ActionDispatch::IntegrationTest` subclasses. Don't redefine it
  per-file.
- New CRUD controller test files should follow
  `test/controllers/positions_controller_test.rb` as the canonical
  pattern (auth gate cases for unauthenticated/regular, happy-path
  CRUD for admin, role parity for manager/hr, JSON spot-checks).

## MySQL upgrade gotcha (2026-04 incident)

If `brew services start mysql` silently no-ops (`Running: false` after
"Successfully started"), the binary is linked against the wrong
`libicuuc` major version (an icu4c upgrade orphaned MySQL 8.3). Fix:

```sh
brew upgrade mysql        # to 9.x
brew services stop mysql
mv /opt/homebrew/var/mysql /opt/homebrew/var/mysql.old.$(date +%s)
/opt/homebrew/opt/mysql/bin/mysqld --initialize-insecure \
  --datadir=/opt/homebrew/var/mysql --user=$(whoami)
brew services start mysql
```

After upgrading MySQL, the `mysql2` gem must be recompiled because the
old binary linked against `libmysqlclient.23.dylib` and MySQL 9.x
ships `.24`:

```sh
PATH=/opt/homebrew/opt/ruby/bin:$PATH gem uninstall mysql2 -aIx
PATH=/opt/homebrew/opt/ruby/bin:$PATH bundle _2.4.19_ install
```

## What this project is NOT

- It's not deployed. There's no production server, no Capistrano, no
  Docker, no Kamal. The `production` environment exists for
  asset-precompile sanity but is otherwise speculative.
- It doesn't use ActiveJob, ActionCable, ActionText, or rails-ujs
  even though `rails/all` is required. Their engine assets are
  excluded from Propshaft's load path in
  `config/initializers/propshaft.rb`.
- It doesn't use Turbo or Stimulus. The whole frontend is
  server-rendered ERB + Pico CSS + ~60 lines of vanilla JS in one
  file.
- It doesn't use ActiveJob, BackgroundJob, Sidekiq, or any background
  processing. All work happens inline in request handlers.
- It doesn't have model tests for the lookup-table models
  (ExperienceLevel, CandidateStatus, etc.) — they're trivial enough
  that the controller tests cover the surface.

## Things to watch when adding code

- **No `def user_params` outside `users_controller.rb`** — every other
  controller's strong-params method is named `<resource>_params`
  (the conventional Rails pattern). The codebase had it inverted for
  years; don't reintroduce.
- **No scaffold REST verb comments** (`# GET /foo`, `# POST /foo`)
  above actions. Pure noise.
- **No inline `<script>` blocks in views** — they'll be CSP-blocked.
  Extract to `app/javascript/application.js`.
- **No `controller: 'foo'` in `redirect_to`** — use named path helpers.
  Hash form breaks under namespaced controllers (see access control
  notes above).
- **No CDN refs in views.** The CSP test will catch them.
- **No `unsafe-inline` in `script-src`.** The CSP test will catch this
  too.
