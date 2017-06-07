require 'test/unit'
require 'test_helper'

class CandidateTest < ActiveRecord::TestCase

  def test_tenure_in_years_should_be_nil_for_no_dates
    c = Candidate.new
    assert_nil(c.tenure_in_years)
  end

  def test_tenure_in_years_should_calculate_properly_for_two_years
    c = Candidate.new
    c.start_date = Date.new(2012, 1, 1)
    c.end_date = Date.new(2014, 1, 1)
    assert_equal(2, c.tenure_in_years)
  end

  def test_tenure_in_years_should_use_today_if_no_end_date
    c = Candidate.new
    c.start_date = Date.new(2012, 1, 1)
    diff = ((Date.today - c.start_date).numerator/365.0).round(2)
    assert_equal(diff, c.tenure_in_years)
  end

  def test_tenure_as_at_date
    c = Candidate.new({start_date: Date.new(2012, 1, 1)})
    assert_equal(1, c.tenure_as_at(Date.new(2013, 1, 1)))
  end

  def test_tenure_as_at_date_should_be_nil_for_no_dates
    assert_nil(Candidate.new.tenure_as_at(Date.today))
  end

  def test_tenure_as_at_date_should_use_end_date_if_before_as_at_date
    c = Candidate.new({start_date: Date.new(2012, 1, 1), end_date: Date.new(2014, 1, 1)})
    assert_equal(2, c.tenure_as_at(Date.new(2015, 1, 1)))
  end

  def test_tenure_as_at_date_should_use_as_at_date_if_end_date_after
    c = Candidate.new({start_date: Date.new(2012, 1, 1), end_date: Date.new(2014, 1, 1)})
    assert_equal(1, c.tenure_as_at(Date.new(2013, 1, 1)))
  end

  def test_tenure_as_at_date_should_be_same_as_tenure_in_years_for_today
    c = Candidate.new({start_date: Date.new(2012, 1, 1)})

    diff = ((Date.today - c.start_date).numerator/365.0).round(2)

    assert_equal(diff, c.tenure_in_years)
    assert_equal(diff, c.tenure_as_at(Date.today))
  end
end