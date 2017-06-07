require 'test/unit'
require 'test_helper'

class ReportsTest < Test::Unit::TestCase

  def test_min_year_is_nil_if_not_set
    assert_nil(Reports::PeriodInfo.new.min_year)
  end

  def test_min_year_is_year_of_only_candidate
    pi = Reports::PeriodInfo.new
    pi.add_candidate(Candidate.new({start_date: Date.new(2012, 1, 1)}))

    assert_equal(2012, pi.min_year)
  end

  def test_min_year_is_actually_min_year
    pi = Reports::PeriodInfo.new
    pi.add_candidates([
                          Candidate.new({start_date: Date.new(2012, 1, 1)}),
                          Candidate.new({start_date: Date.new(2011, 1, 1)})
                      ])

    assert_equal(2011, pi.min_year)
  end

  def test_tenure_list_empty_if_no_data
    assert_empty(Reports::PeriodInfo.new.tenure_list(Date.new(2012, 1, 1)))
  end

  def test_tenure_list_as_at_date_less_than_min_date_is_empty
    pi = Reports::PeriodInfo.new
    pi.add_candidates([
                          Candidate.new({start_date: Date.new(2014, 1, 1)}),
                          Candidate.new({start_date: Date.new(2012, 1, 1)}),
                          Candidate.new({start_date: Date.new(2012, 1, 1)}),
                          Candidate.new({start_date: Date.new(2013, 1, 1)})
                      ])

    assert_equal([], pi.tenure_list(Date.new(2011, 12, 31)))
  end

  def test_tenure_list_as_at_start_dates_is_all_zeroes
    pi = Reports::PeriodInfo.new
    pi.add_candidates([
                          Candidate.new({start_date: Date.new(2014, 1, 1)}),
                          Candidate.new({start_date: Date.new(2012, 1, 1)}),
                          Candidate.new({start_date: Date.new(2012, 1, 1)}),
                          Candidate.new({start_date: Date.new(2013, 1, 1)})
                      ])

    assert_equal([0.0, 0.0], pi.tenure_list(Date.new(2012, 1, 1)))
  end

  def test_tenure_list_as_at_for_previous_year_uses_end_of_year
    pi = Reports::PeriodInfo.new
    pi.add_candidates([
                          Candidate.new({start_date: Date.new(2014, 1, 1)}),
                          Candidate.new({start_date: Date.new(2012, 1, 1)}),
                          Candidate.new({start_date: Date.new(2012, 1, 1)}),
                          Candidate.new({start_date: Date.new(2013, 1, 1)})
                      ])

    assert_equal([0.5, 1.5, 1.5], pi.tenure_list(Date.new(2013, 7, 1)))
  end


  def test_size_as_at_date
    pi = Reports::PeriodInfo.new
    pi.add_candidates([
                          Candidate.new({start_date: Date.new(2014, 1, 1)}),
                          Candidate.new({start_date: Date.new(2012, 1, 1)}),
                          Candidate.new({start_date: Date.new(2012, 1, 1)}),
                          Candidate.new({start_date: Date.new(2013, 1, 1)})
                      ])


    assert_equal(2, pi.size(Date.new(2012, 2, 1)))
    assert_equal(2, pi.size(Date.new(2012, 12, 31)))
    assert_equal(3, pi.size(Date.new(2013, 1, 1)))
    assert_equal(4, pi.size(Date.today))

  end

  def test_median_tenure
    pi = Reports::PeriodInfo.new
    pi.add_candidates([
                          Candidate.new({start_date: Date.new(2014, 1, 1)}),
                          Candidate.new({start_date: Date.new(2014, 1, 1)}),
                          Candidate.new({start_date: Date.new(2017, 7, 1)}),
                          Candidate.new({start_date: Date.new(2017, 7, 1)}),
                          Candidate.new({start_date: Date.new(2017, 7, 1)})
                      ])
    assert_equal(0, pi.median_tenure(Date.new(2017, 7, 1)))
  end

  def test_stuff
    l = Reports::PeriodInfo.new
    c = Candidate.new

    l.add_candidate(c)

    l.median_tenure(2012)


  end

end