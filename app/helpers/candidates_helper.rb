module CandidatesHelper
  EPOCH_DATE = Date.new(2020).freeze

  def candidates_table(*args)
    candidates = args.first
    opts = args.second || {}

    candidates = candidates.sort_by { |c| c.start_date || EPOCH_DATE }
    interview_column_count = candidates.map { |c| c.interviews.length }.max || 0
    code_submission_column_count = candidates.map { |c| c.code_submissions.length }.max || 0

    tag.table do
      concat(candidates_table_header(opts, interview_column_count, code_submission_column_count))
      candidates.each do |candidate|
        concat(candidates_table_row(candidate, opts, interview_column_count, code_submission_column_count))
      end
    end
  end

  def candidates_table_header(opts, interview_count, code_submission_count)
    tag.tr do
      concat(tag.th('Name'))
      concat(tag.th('Office'))
      concat(tag.th('Status')) if opts[:include_status]
      concat(tag.th('Source')) if opts[:include_source]
      concat(tag.th('Position')) if opts[:include_position]

      if opts[:include_events]
        (1..code_submission_count + interview_count).each { |i| concat(tag.th("Event #{i}")) }
      else
        if opts[:include_code_submissions]
          (1..code_submission_count).each { |i| concat(tag.th("Code Submission #{i}")) }
        end
        if opts[:include_interviews]
          (1..interview_count).each { |i| concat(tag.th("Interview #{i}")) }
        end
      end

      concat(tag.th('References?')) if opts[:include_references]
      concat(tag.th('Service Period')) if opts[:include_time_served]
      if opts[:include_dates]
        concat(tag.th('Start Date'))
        concat(tag.th('End Date'))
      end
    end
  end

  def candidates_table_row(candidate, opts, interview_count, code_submission_count)
    tag.tr do
      concat(tag.td(format_candidate(candidate)))
      concat(tag.td(get_name(candidate.office_location)))
      concat(tag.td(get_name(candidate.candidate_status))) if opts[:include_status]
      concat(tag.td(get_name(candidate.candidate_source))) if opts[:include_source]
      concat(tag.td(get_name(candidate.position))) if opts[:include_position]

      if opts[:include_events]
        events = (candidate.interviews + candidate.code_submissions)
                   .sort_by { |e| e.event_date || EPOCH_DATE }

        (code_submission_count + interview_count).times do |i|
          concat(tag.td(format_event_cell(events[i])))
        end
      else
        if opts[:include_code_submissions]
          code_submission_count.times do |i|
            concat(tag.td(format_submission(candidate.code_submissions[i])))
          end
        end
        if opts[:include_interviews]
          interview_count.times do |i|
            concat(tag.td(format_interview(candidate.interviews[i], include_date: true)))
          end
        end
      end

      if opts[:include_references]
        concat(tag.td(approved_span(candidate.reference_checks, text: candidate.reference_checks.length)))
      end
      concat(tag.td(time_since_hire(candidate))) if opts[:include_time_served]
      if opts[:include_dates]
        concat(tag.td(candidate.start_date.to_s))
        concat(tag.td(candidate.end_date.to_s))
      end
    end
  end

  def format_event_cell(event)
    case event
    when CodeSubmission then format_submission(event)
    when Interview      then format_interview(event, include_date: true)
    when nil            then ''
    else 'Unknown Event'
    end
  end

  def format_candidate(*args)
    candidate = args.first

    out = color_span candidate.experience_level, {text: "#{candidate.name}"}
    out += " (#{time_since_application(candidate)})" if candidate.in_pipeline?

    link_to out, candidate_path(candidate)
  end

  def time_since_application(candidate)
    date_to_use = candidate.application_date.nil? ? candidate.first_contact_date : candidate.application_date
    unless date_to_use.nil?
      distance_of_time_in_words_to_now(date_to_use)
    end
  end

  def time_since_hire(candidate)
    if candidate.start_date.nil? || candidate.start_date > Date.today
      'N/A'
    else
      if candidate.end_date.nil?
        distance_of_time_in_words_to_now(candidate.start_date)
      else
        distance_of_time_in_words(candidate.start_date, candidate.end_date)
      end
    end
  end
end
