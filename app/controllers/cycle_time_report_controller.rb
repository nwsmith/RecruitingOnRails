class CycleTimeReportController < ApplicationController
  def index

  end

  def run
    @report = Array.new
    candidates = Candidate.by_status_code('HIRED')


    interview_width = 0
    candidates.each do |c|
      if c.interviews.length > interview_width
        interview_width = c.interviews.length
      end
    end

    @header = ['Name', 'Application', 'First Contact', 'Days to Contact']
    1.upto(interview_width) {|x| @header << "Interview #{x}" << "Days to #{x}"}
    @header << 'Offer' << 'Accept' << 'Cycle Time'

    candidates.each do |c|
      base_date = c.application_date || c.first_contact_date
      offer_date = c.offer_accept_date || c.offer_date


      row = Array.new
      row << c.name
      row << c.application_date
      row << c.first_contact_date
      row << ((c.first_contact_date.nil? || c.application_date.nil?) ? 'N/A' : (c.first_contact_date - c.application_date).to_i)


      c.interviews.each do |interview|
        row << interview.meeting_time
        row << ((base_date.nil? || interview.meeting_time.nil?) ? 'N/A' : (interview.meeting_time - base_date).to_i)
      end

      0.upto(interview_width-c.interviews.length-1) {|x| row << ' ' << ' '}

      row << c.offer_date
      row << c.offer_accept_date

      row << ((offer_date.nil? || base_date.nil?) ? 'N/A' : (offer_date - base_date).to_i)


      @report << row
    end
  end
end
