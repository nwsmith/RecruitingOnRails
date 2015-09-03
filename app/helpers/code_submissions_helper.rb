module CodeSubmissionsHelper
  def format_submission(*args)
    code_submission = args.first

    return '' if code_submission.nil?

    out = code_submission.name

    unless code_submission.sent_date.nil?
      if code_submission.submission_date.nil?
        out += "(#{distance_of_time_in_words_to_now(code_submission.sent_date)}+)"
      else
        out += "(#{distance_of_time_in_words(code_submission.sent_date, code_submission.submission_date)})"
      end
    end

    link_to approved_span(code_submission, :text => out), code_submission_path(code_submission)
  end
end
