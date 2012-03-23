class User < ActiveRecord::Base
  has_and_belongs_to_many :groups
  belongs_to :interview_review

  def name
    first_name + ' ' + last_name
  end
end
