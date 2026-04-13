class CandidatesController < ApplicationController
  # Staff-only gate on the collection actions. These routes enumerate
  # candidates in bulk (index/list/timeline/events/search) or create
  # new ones (new/create), none of which should be reachable by regular
  # or self.candidate users. Per-record actions stay on the
  # check_candidate_access helper below so a self.candidate user can
  # still reach their own /candidates/:id while their application is
  # PEND or VERBAL.
  before_action :check_staff, only: [
    :index, :list, :timeline, :events, :search, :new, :create
  ]

  # Per-candidate access check. Delegates to ApplicationController's shared
  # helper so the rule stays in one place across candidates_controller and
  # the related-resource controllers (interviews, code_submissions,
  # candidate_attachments).
  def check_access(candidate)
    check_candidate_access(candidate)
  end

  def index
    @candidates = Candidate.for_table

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @candidates }
      format.csv  { send_candidates_csv(@candidates, "candidates") }
    end
  end

  def timeline
    @status_list = requested_status_codes
    @candidates = Candidate.for_table.merge(Candidate.by_status_codes(@status_list))

    respond_to do |format|
      format.html
    end
  end

  def events
    today = Date.today
    folks = Candidate.by_status_codes(requested_status_codes)
                     .where.not(start_date: nil)
                     .where("start_date <= ?", today)
                     .to_a

    # Sort newest start first; tie-break on end_date. The previous version used
    # `start_cmp || end_cmp`, but <=> returns -1/0/1 — all truthy — so the
    # secondary comparison was dead code. Use a key-based sort to make the
    # ordering explicit and nil-safe.
    folks.sort_by! { |c| [ -c.start_date.to_time.to_i, -(c.end_date || today).to_time.to_i ] }

    candidates = folks.map do |candidate|
      {
        "start" => candidate.start_date.to_s,
        "end"   => (candidate.end_date || today).to_s,
        "title" => candidate.name
      }
    end

    respond_to do |format|
      format.html
      format.json { render json: { "events" => candidates } }
    end
  end

  def search
    query = params[:q].to_s.strip
    parts = query.split(/\s+/)

    @candidates =
      if parts.empty?
        Candidate.none
      elsif parts.length == 1
        term = "%#{Candidate.sanitize_sql_like(parts[0])}%"
        Candidate.where("first_name LIKE ? OR last_name LIKE ?", term, term)
      else
        # Treat the first token as first name and the rest as last name, but
        # also accept the reverse so "Doe John" and "John Marie Doe" both work.
        first_term = "#{Candidate.sanitize_sql_like(parts.first)}%"
        last_term  = "#{Candidate.sanitize_sql_like(parts.last)}%"
        Candidate.where(
          "(first_name LIKE ? AND last_name LIKE ?) OR (first_name LIKE ? AND last_name LIKE ?)",
          first_term, last_term, last_term, first_term
        )
      end

    render "list"
  end

  def list
    @candidates = Candidate.for_table.merge(Candidate.by_status_codes(requested_status_codes))

    respond_to do |format|
      format.html
      format.json { render json: @candidates, include: { candidate_status: { only: :code }, candidate_source: { only: :code } } }
      format.csv  { send_candidates_csv(@candidates, "candidates-#{requested_status_codes.join('-').downcase}") }
    end
  end

  def show
    @candidate = Candidate
                   .includes(:work_history_rows, :diary_entries, :candidate_attachments,
                             interviews: [ :interview_type, :interview_reviews ],
                             code_submissions: [ :code_problem, :code_submission_reviews ],
                             reference_checks: [])
                   .find(params[:id])

    return if check_access(@candidate)

    @activities = Activity.where(candidate_id: @candidate.id).recent.limit(50).includes(:actor)
    @status_changes = @candidate.status_changes.recent.includes(:from_status, :to_status, :changed_by)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @candidate }
    end
  end

  def new
    @candidate = Candidate.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @candidate }
    end
  end

  def edit
    @candidate = Candidate.find(params[:id])
    # check_access redirects internally if access is denied; the implicit
    # return nil is the desired behavior either way.
    check_access(@candidate)
  end

  def create
    @candidate = Candidate.new(candidate_params)

    respond_to do |format|
      if @candidate.save
        format.html { redirect_to @candidate, notice: "Candidate was successfully created." }
        format.json { render json: @candidate, status: :created, location: @candidate }
      else
        format.html { render action: "new" }
        format.json { render json: @candidate.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @candidate = Candidate.find(params[:id])

    return if check_access(@candidate)

    respond_to do |format|
      if @candidate.update(candidate_params)
        format.html { redirect_to @candidate, notice: "Candidate was successfully updated." }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @candidate.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @candidate = Candidate.find(params[:id])

    return if check_access(@candidate)

    @candidate.destroy

    respond_to do |format|
      format.html { redirect_to candidates_url }
      format.json { head :no_content }
    end
  end

  private

  # Reads the `status` query param as a comma-separated list. When the param is
  # absent the page defaults to HIRED candidates; when the param is present but
  # contains unknown codes, the resulting query returns no rows (rather than
  # silently widening to HIRED, which used to mask bad input).
  def requested_status_codes
    return [ "HIRED" ] if params[:status].nil?
    params[:status].split(",")
  end

  def candidate_params
    params.require(:candidate).permit(
      :first_name, :middle_name, :last_name, :notes,
      :application_date, :first_contact_date, :start_date, :end_date,
      :offer_date, :offer_accept_date, :offer_turndown_date,
      :rejection_notification_date, :rejection_call_request_date,
      :fire_date, :quit_date, :is_referral, :referred_by,
      :salary_range, :replacement_for, :sadness_factor,
      :candidate_status_id, :candidate_source_id, :experience_level_id,
      :position_id, :office_location_id, :education_level_id, :school_id,
      :gender_id, :leave_reason_id, :associated_budget_id, :budgeting_type_id,
      :user_id,
      :status_change_notes,
      tag_ids: []
    )
  end

  CSV_HEADERS = [
    "First Name", "Last Name", "Middle Name",
    "Status", "Source", "Position", "Experience Level", "Office Location",
    "Application Date", "First Contact", "Start Date", "End Date",
    "Offer Date", "Offer Accepted", "Offer Declined",
    "Rejection Notified", "Fire Date", "Quit Date",
    "Referral?", "Referred By", "Notes"
  ].freeze

  def send_candidates_csv(candidates, basename)
    require "csv"

    csv_data = CSV.generate do |csv|
      csv << CSV_HEADERS
      candidates.each do |c|
        csv << [
          c.first_name, c.last_name, c.middle_name,
          c.candidate_status&.name, c.candidate_source&.name,
          c.position&.name, c.experience_level&.name, c.office_location&.name,
          c.application_date, c.first_contact_date, c.start_date, c.end_date,
          c.offer_date, c.offer_accept_date, c.offer_turndown_date,
          c.rejection_notification_date, c.fire_date, c.quit_date,
          c.is_referral ? "Yes" : "No", c.referred_by, c.notes
        ]
      end
    end

    # UTF-8 BOM so Excel auto-detects the encoding on Windows.
    bom = "\xEF\xBB\xBF"
    send_data bom + csv_data,
              filename:    "#{basename}-#{Date.today}.csv",
              type:        "text/csv; charset=utf-8",
              disposition: "attachment"
  end
end
