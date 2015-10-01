require 'old_auth_config'

OldAuthConfig.config = YAML.load_file("#{Rails.root}/config/auth.yml")[Rails.env]
