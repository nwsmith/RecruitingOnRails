class Candidate < ApplicationRecord
  include Trackable

  # The audited candidate IS this record.
  def audit_candidate_id
    id
  end

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
  # Optional link to the internal User account belonging to this candidate.
  # Set when a candidate's user account exists in the system so the
  # self-candidate dashboard path doesn't have to rely on the brittle
  # `user_name == "first.last"` convention. Nullable; legacy rows and
  # external hires without accounts are expected to leave this blank.
  belongs_to :user, optional: true

  has_many :work_history_rows
  has_many :interviews
  has_many :code_submissions
  has_many :reference_checks
  has_many :candidate_attachments
  has_many :diary_entries
  has_many :status_changes, class_name: "CandidateStatusChange", dependent: :destroy
  has_many :candidate_tags, dependent: :destroy
  has_many :tags, through: :candidate_tags

  validates :first_name, presence: true
  validates :last_name, presence: true
  # New candidates must enter the pipeline with a status. Legacy records may
  # still have nil here, so this only fires on create — backfill before tightening.
  validates :candidate_status_id, presence: true, on: :create

  # ----- status change tracking -----
  # Virtual attribute: the candidate form can set this when the admin
  # changes the status dropdown. The after_update callback reads it and
  # attaches it to the CandidateStatusChange row. Not persisted on
  # Candidate itself.
  attr_accessor :status_change_notes

  after_create :record_initial_status, if: -> { candidate_status_id.present? }
  after_update :record_status_change,  if: :saved_change_to_candidate_status_id?

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
      :position, :experience_level, :tags,
      :reference_checks,
      interviews: [ :interview_type, :interview_reviews ],
      code_submissions: [ :code_problem, :code_submission_reviews ]
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

  # Find the active (PEND/VERBAL) candidate record belonging to the given
  # user. Used by the dashboard to show a self-candidate user their own
  # application without exposing anyone else's.
  #
  # Matching strategy, FK first:
  #   1. `candidates.user_id = user.id` — the precise, rename-proof match
  #      set by the admin when creating/editing a candidate. Added 2026-04-11.
  #   2. `LOWER(first_name).LOWER(last_name) = user.user_name` on rows
  #      where `user_id IS NULL` — legacy fallback for candidates created
  #      before the FK existed. The `IS NULL` clause prevents name-collision
  #      leakage (if candidate Bob has FK user_id=2 but his name happens to
  #      match Alice's user_name, Alice must NOT see Bob).
  #
  # Returns an ActiveRecord relation so callers can chain or .first it.
  # Returns Candidate.none if the user is nil.
  def Candidate.for_self_user(user)
    return Candidate.none unless user

    active_status_ids = CandidateStatus.where(code: %w[PEND VERBAL]).pluck(:id)
    return Candidate.none if active_status_ids.empty?

    fk_match = where(user_id: user.id)

    parts = user.user_name.to_s.split(".", 2)
    if parts.length == 2 && parts.all?(&:present?)
      name_match = where(user_id: nil)
                     .where("LOWER(first_name) = ? AND LOWER(last_name) = ?", parts[0], parts[1])
      fk_match = fk_match.or(name_match)
    end

    fk_match.where(candidate_status_id: active_status_ids)
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

  private

  def record_initial_status
    CandidateStatusChange.create!(
      candidate:   self,
      from_status: nil,
      to_status:   candidate_status,
      changed_by:  Current.user
    )
  end

  def record_status_change
    from_id, to_id = saved_change_to_candidate_status_id
    CandidateStatusChange.create!(
      candidate_id:       id,
      from_status_id:     from_id,
      to_status_id:       to_id,
      changed_by_user_id: Current.user&.id,
      notes:              status_change_notes.presence
    )
    self.status_change_notes = nil # consumed; don't carry over to the next save
  end
end
