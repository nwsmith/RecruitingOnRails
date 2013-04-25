require 'auth_config'

AuthConfig.config = YAML.load_file("#{Rails.root}/config/auth.yml")[Rails.env]
