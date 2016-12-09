class Candidate < ActiveRecord::Base
  belongs_to :gender
  belongs_to :candidate_status
  belongs_to :candidate_source
  belongs_to :experience_level
  belongs_to :position
  belongs_to :office_location
  belongs_to :education_level
  belongs_to :school
  belongs_to :budgeting_type
  belongs_to :leave_reason
  belongs_to :associated_budget

  has_many :work_history_rows
  has_many :interviews
  has_many :code_submissions
  has_many :reference_checks

  def name
    first_name + ' ' + last_name
  end

  def username
    first_name.strip.downcase + '.' + last_name.strip.downcase
  end

  def in_pipeline?
    (!application_date.nil? || !first_contact_date.nil?) && (rejection_notification_date.nil? && start_date.nil?)
  end

  def events
    code_submissions + interviews
  end

  def time_served

  end

  def Candidate.by_status_code(status_code)
    status = CandidateStatus.first(:conditions => {:code => status_code})
    id = status.nil? ? -1 : status.id
    Candidate.all(:conditions => {:candidate_status_id => id})
  end

  def tenure_in_years
    e = end_date.nil? ? Date.today : end_date
    ((e - start_date).numerator/365.0).round(2)
  end
end
