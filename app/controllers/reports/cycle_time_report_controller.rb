class Reports::CycleTimeReportController < ApplicationController

  def index

  end

  def run
    @report = Array.new

    status_list = get_list_from_params(params, :status)
    status_list << 'HIRED' if status_list.empty?

    candidates = Array.new
    status_list.each do |s|
      candidates << Candidate.by_status_code(s)
    end
    candidates.flatten!

    events_width = 0

    candidates.each do |c|
      if c.events.length > events_width
        events_width = c.events.length
      end
    end

    @header = ['Name', 'Application', 'First Contact', 'Days to Contact']
    1.upto(events_width) {|x| @header << "Event #{x}" << "Days to #{x}"}
    @header << 'Offer' << 'Accept' << 'Cycle Time'

    candidates.each do |c|
      if !c.candidate_source.nil? && (c.candidate_source.code == 'LEGACY' || c.candidate_source.code == 'ACQUISITION')
        next
      end
      base_date = c.application_date || c.first_contact_date
      offer_date = c.offer_accept_date || c.offer_date

      row = Array.new
      row << c.name
      row << c.application_date
      row << c.first_contact_date
      row << ((c.first_contact_date.nil? || c.application_date.nil?) ? 'N/A' : (c.first_contact_date - c.application_date).to_i)

      events = c.events.sort { |a, b| (a.event_date.nil? ? Date.new(2020) : a.event_date) <=> (b.event_date.nil? ? Date.new(2020) : b.event_date) }

      events.each do |event|
        row << "(#{(event.is_a?(CodeSubmission) ? 'Code' : 'Interview')}) #{event.event_date}"
        row << ((base_date.nil? || event.event_date.nil?) ? 'N/A' : (event.event_date - base_date).to_i)
      end

      0.upto(events_width - c.events.length - 1) {|x| row << ' ' << ' '}

      row << c.offer_date
      row << c.offer_accept_date

      row << ((offer_date.nil? || base_date.nil?) ? 'N/A' : (offer_date - base_date).to_i)


      @report << row
    end
  end
end
