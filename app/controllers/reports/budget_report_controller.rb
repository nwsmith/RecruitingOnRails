class Reports::BudgetReportController < ApplicationController
  def index
  end

  def run
    budgets = AssociatedBudget.all
    candidates_by_budget = Hash.new
    candidates_by_budget['N/A'] = Array.new
    budgets.each {|b| candidates_by_budget[b.name] = Array.new}

    candidates = Candidate.by_status_code('HIRED')

    candidates.each do |candidate|
      if candidate.associated_budget.nil?
        candidates_by_budget['N/A'] << candidate
      else
        puts candidate.associated_budget.code
        candidates_by_budget[candidate.associated_budget.name] << candidate
      end
    end

    @tables = Array.new

    candidates_by_budget.each_key do |k|
      table = Reports::ReportTable.new(k)
      table.header = ['Name']
      rows = Array.new
      candidates_by_budget[k].each{|c| rows << [c.name]}
      table.rows = rows
      @tables << table
    end

  end
end
