# Bootstrap data for a fresh development database. Idempotent — safe to
# run repeatedly via `bin/rails db:seed`. The default admin password is
# read from ENV (with a safe-but-obvious fallback) so dev environments
# don't all share a hardcoded credential.

# --- Auth config: a single internal-bcrypt auth profile ---------------
auth_config_type = AuthConfigType.find_or_create_by!(code: 'INTERNAL') do |t|
  t.name        = 'Internal'
  t.description = 'Internal bcrypt authentication'
end

auth_config = AuthConfig.find_or_create_by!(name: 'Default Setup') do |c|
  c.auth_config_type = auth_config_type
end

# --- Bootstrap admin user ---------------------------------------------
admin_password = ENV.fetch('SEED_ADMIN_PASSWORD', 'change-me-on-first-login')
User.find_or_create_by!(user_name: 'admin') do |u|
  u.first_name  = 'Bootstrap'
  u.last_name   = 'Admin'
  u.auth_name   = 'admin'
  u.password    = admin_password
  u.admin       = true
  u.active      = true
  u.auth_config = auth_config
end

# --- Registry: dashboard default status -------------------------------
Registry.find_or_create_by!(key: 'dashboard.default_status') do |r|
  r.value = 'PEND'
end

# --- Reference data: enough lookup rows to make the candidate form ----
# render with non-empty dropdowns. Code/name pairs are intentionally
# generic; customize per organization.

candidate_statuses = {
  'PEND'   => 'Pending',
  'VERBAL' => 'Verbal Offer',
  'HIRED'  => 'Hired',
  'FIRED'  => 'Fired',
  'QUIT'   => 'Quit'
}
candidate_statuses.each do |code, name|
  CandidateStatus.find_or_create_by!(code: code) { |s| s.name = name }
end

experience_levels = {
  'JR' => ['Junior',    '#a8d5e2'],
  'MD' => ['Mid-level', '#7fbb8d'],
  'SR' => ['Senior',    '#e6b54a']
}
experience_levels.each do |code, (name, color)|
  ExperienceLevel.find_or_create_by!(code: code) do |e|
    e.name  = name
    e.color = color
  end
end

review_results = {
  'PASS' => ['Pass', true,  false],
  'FAIL' => ['Fail', false, true],
  'TBD'  => ['Pending', false, false]
}
review_results.each do |code, (name, is_approval, is_disapproval)|
  ReviewResult.find_or_create_by!(code: code) do |r|
    r.name           = name
    r.is_approval    = is_approval
    r.is_disapproval = is_disapproval
  end
end

puts "Seed complete. Admin user: 'admin' / '#{admin_password}'"
puts 'Override the admin password by setting SEED_ADMIN_PASSWORD before re-running.'
