module CandidatesHelper
  def candidates_table(*args)
    candidates = args.first
    opts = args.second || {}

    candidates = candidates.sort { |a, b| (a.start_date.nil? ? Date.new(2020) : a.start_date) <=> (b.start_date.nil? ? Date.new(2020) : b.start_date) }
    interview_column_count = 0
    candidates.each { |c| interview_column_count = c.interviews.length if c.interviews.length > interview_column_count }
    code_submission_column_count = 0
    candidates.each { |s| code_submission_column_count = s.code_submissions.length if s.code_submissions.length > code_submission_column_count }

    out = '<table>'
    out += '<tr>'
    out += '<th>Name</th>'
    out += '<th>Office</th>'
    if opts[:include_status]
      out += '<th>Status</th>'
    end
    if opts[:include_source]
      out += '<th>Source</th>'
    end
    if opts[:include_position]
      out += '<th>Position</th>'
    end
    if opts[:include_events]
      0.upto(code_submission_column_count + interview_column_count - 1) do |i|
        out += "<th>Event #{i+1}</th>"
      end
    else
      if opts[:include_code_submissions]
        1.upto(code_submission_column_count) do |i|
          out += "<th>Code Submission #{i}</th>"
        end
      end
      if opts[:include_interviews]
        1.upto(interview_column_count) do |i|
          out += "<th>Interview #{i}</th>"
        end
      end
    end
    if opts[:include_references]
      out += '<th>References?</th>'
    end
    if opts[:include_time_served]
      out += '<th>Service Period</th>'
    end
    if opts[:include_dates]
      out += '<th>Start Date</th>'
      out += '<th>End Date</th>'
    end
    out += '</tr>'

    candidates.each do |candidate|
      out += '<tr>'
      out += '<td>'
      out += format_candidate(candidate)
      out += '</td>'
      out += '<td>'
      out += get_name candidate.office_location
      out += '</td>'
      if opts[:include_status]
        out += '<td>'
        out += get_name candidate.candidate_status
        out += '</td>'
      end
      if opts[:include_source]
        out += '<td>'
        out += get_name candidate.candidate_source
        out += '</td>'
      end
      if opts[:include_position]
        out += '<td>'
        out += get_name candidate.position
        out += '</td>'
      end
      if opts[:include_events]
        events = candidate.interviews + candidate.code_submissions
        events.sort! { |a, b| (a.event_date.nil? ? Date.new(2020) : a.event_date) <=> (b.event_date.nil? ? Date.new(2020) : b.event_date) }

        0.upto(code_submission_column_count + interview_column_count - 1) do |i|
          event = events[i]

          out += '<td>'

          if event.is_a? CodeSubmission
            out += format_submission(event)
          elsif event.is_a? Interview
            out += format_interview(event, :include_date => true)
          elsif event.nil?
            out += ''
          else
            out += 'Unknown Event'
          end

          out += '</td>'
        end
      else
        if opts[:include_code_submissions]
          0.upto(code_submission_column_count-1) do |i|
            out += '<td>'
            out += format_submission(candidate.code_submissions[i])
            out += '</td>'
          end
        end
        if opts[:include_interviews]
          0.upto(interview_column_count-1) do |i|
            out += '<td>'
            out += format_interview(candidate.interviews[i], :include_date => true)
            out += '</td>'
          end
        end
      end

      if opts[:include_references]
        out += '<td>'
        out += approved_span(candidate.reference_checks, :text => candidate.reference_checks.length)
        out += '</td>'
      end
      if opts[:include_time_served]
        out += "<td>#{time_since_hire(candidate)}</td>"
      end
      if opts[:include_dates]
        out += "<td>#{candidate.start_date}</td>"
        out += "<td>#{candidate.end_date}</td>"
      end
      out += '</tr>'
    end
    out += '</table>'
    out.html_safe
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
