module InterviewsHelper
  def format_interview(*args)
    interview = args.first
    opts = args.second || {}


    return '' if interview.nil?


    out = get_name(interview.interview_type)

    if opts[:include_name]
      out += " w/ #{interview.candidate.name}"
    end

    if opts[:include_date]
      out += " (#{interview.meeting_time.to_s})"
    end

    link_to approved_span(interview, :text=>out), interview_path(interview)
  end
end
