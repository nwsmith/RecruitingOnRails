# config valid for current version and patch releases of Capistrano
lock "~> 3.20.0"

set :application, "recruiting_on_rails"
set :repo_url,    "git@github.com:nwsmith/RecruitingOnRails.git"

set :branch, "master"
set :deploy_to, "/var/www/recruiting.solium.com"

set :ssh_options, { user: "nathan.smith", config: false }
set :pty, true

# Files that live in shared/ on the server and are symlinked into each release.
# `aws.yml` must be placed in `#{shared_path}/config/aws.yml` on the server
# before the first deploy (same operational requirement as the old
# `symlink_shared` task).
set :linked_files, %w[config/aws.yml]

# Directories preserved across releases (logs, pids, bundled gems, uploads).
set :linked_dirs, %w[
  log
  tmp/pids
  tmp/cache
  tmp/sockets
  vendor/bundle
  public/system
  storage
]

# Keep the last 5 releases
set :keep_releases, 5

# Passenger restart is hooked into deploy:finished automatically by
# capistrano-passenger, replacing the Cap 2.x manual `touch tmp/restart.txt`.
# Pin to the touch-file approach so behavior matches what the Cap 2.x config
# was doing — flip to `false` if/when the server is on Passenger >= 4.0.33
# and `passenger-config restart-app` is available without sudo.
set :passenger_restart_with_touch, true
