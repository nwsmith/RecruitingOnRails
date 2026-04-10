class User < ApplicationRecord
  has_secure_password

  has_and_belongs_to_many :groups
  belongs_to :interview_review, optional: true
  belongs_to :auth_config

  def name
    first_name + ' ' + last_name
  end

  def User.fetch_by_auth_name(auth_name)
    User.where(auth_name: auth_name).first
  end

  def User.all_active
    User.where(active: true).all
  end
end
