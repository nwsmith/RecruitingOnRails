# TODO: I think this is a gross hack
#require File.expand_path('../../lib/auth_config', __FILE__)
#
#
#require 'lib/auth_config'

AuthConfig.config = YAML.load("config/auth.yml")[Rails.env]
