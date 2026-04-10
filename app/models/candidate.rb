class Candidate < ApplicationRecord
  belongs_to :gender, optional: true
  belongs_to :candidate_status, optional: true
  belongs_to :candidate_source, optional: true
  belongs_to :experience_level, optional: true
  belongs_to :position, optional: true
  belongs_to :office_location, optional: true
  belongs_to :education_level, optional: true
  belongs_to :school, optional: true
  belongs_to :budgeting_type, optional: true
  belongs_to :leave_reason, optional: true
  belongs_to :associated_budget, optional: true

  has_many :work_history_rows
  has_many :interviews
  has_many :code_submissions
  has_many :reference_checks
  has_many :candidate_attachments
  has_many :diary_entries

  validates :first_name, presence: true
  validates :last_name, presence: true

  def start_time=(start_time)
    @start_time = start_time
  end

  def start_time
      @start_time.nil? ? start_date : @start_time
  end

  def name
    "#{first_name} #{last_name}"
  end

  def username
    "#{first_name.strip.downcase}.#{last_name.strip.downcase}"
  end

  def in_pipeline?
    (!application_date.nil? || !first_contact_date.nil?) && (rejection_notification_date.nil? && start_date.nil?)
  end

  def events
    code_submissions + interviews
  end

  # Eager-loads everything candidates_table touches, so rendering a candidate
  # list does a fixed number of queries instead of one per row per association.
  scope :for_table, -> {
    includes(
      :office_location, :candidate_status, :candidate_source,
      :position, :experience_level,
      :reference_checks,
      interviews: [:interview_type, :interview_reviews],
      code_submissions: [:code_problem, :code_submission_reviews]
    )
  }

  def Candidate.by_status_code(status_code)
    status = CandidateStatus.find_by(code: status_code)
    return Candidate.none unless status
    Candidate.where(candidate_status_id: status.id)
  end

  # Single-query equivalent of mapping by_status_code over an array of codes.
  def Candidate.by_status_codes(status_codes)
    status_ids = CandidateStatus.where(code: status_codes).pluck(:id)
    return Candidate.none if status_ids.empty?
    Candidate.where(candidate_status_id: status_ids)
  end

  def Candidate.by_associated_budget_code(budget_code)
    associated_budget = AssociatedBudget.find_by(code: budget_code)
    return Candidate.none unless associated_budget
    Candidate.where(associated_budget_id: associated_budget.id)
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
