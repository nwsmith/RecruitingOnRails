class Candidate < ApplicationRecord
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
  has_many :candidate_attachments

  def start_time=(start_time)
    @start_time = start_time
  end

  def start_time
      @start_time.nil? ? start_date : @start_time
  end

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
    status = CandidateStatus.where(code: status_code).first
    id = status.nil? ? -1 : status.id
    candidates = Candidate.where(candidate_status_id: id).all
    candidates
  end

  def Candidate.by_associated_budget_code(budget_code)
    associated_budget = AsscociatedBudget.where(code: budget_code).first
    id = associated_budget.nil? ? -1 : associated_budget.id
    Candidate.where(associated_budget_id: id).all
  end

  def tenure_in_years
    tenure_as_at(Date.today)
  end

  def tenure_as_at(date)
    return nil unless start_date
    e = end_date.nil? ? date : ((end_date < date) ? end_date : date)
    ((e - start_date).numerator/365.0).round(2)
  end
end
