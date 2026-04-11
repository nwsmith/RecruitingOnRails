class AuthConfig < ApplicationRecord
  include Trackable
  belongs_to :auth_config_type
end
