module Reports

  class YearInfo
    attr_accessor :year, :started_in_year, :left_in_year, :still_here

    def initialize(year)
      @year = year
      @started_in_year = Array.new
      @left_in_year = Array.new
      @still_here = Array.new
    end
  end


  class PeriodInfo
    attr_accessor :year_info_map

    def initialize
      @year_info_map = Hash.new
    end

    def add_year(year_info)
      @year_info_map[year_info.year] = year_info
    end

    def add_candidates(candidates)
      candidates.each {|c| add_candidate(c)}
    end

    def add_candidate(candidate)
      return if candidate.nil?

      start_year = candidate.start_date.nil? ? nil : candidate.start_date.year
      end_year = candidate.end_date.nil? ? nil : candidate.end_date.year

      return if start_year.nil?

      start_year_info = get(start_year)
      start_year_info.started_in_year << candidate unless start_year_info.started_in_year.include? candidate

      if end_year.nil?
        start_year_info.still_here << candidate unless start_year_info.still_here.include? candidate
      else
        end_year_info = get(end_year)
        end_year_info.left_in_year << candidate unless end_year_info.still_here.include? candidate
      end

    end

    def get(year)
      @year_info_map[year] = YearInfo.new(year) unless @year_info_map[year]
      @year_info_map[year]
    end

    def min_year
      @year_info_map.empty? ? nil : @year_info_map.keys.sort {|a,b| a <=> b}.first.to_i
    end


    def turnover(date)
      left_in_year = get(date.year).left_in_year.size
      left_in_year == 0 ? 0 : (left_in_year.to_f/size(date))*100
    end

    def voluntary_turnover(date)
      left_in_year = get(date.year).left_in_year.select {|c| !c.candidate_status.code.eql?('FIRED')}.size
      left_in_year == 0 ? 0 : (left_in_year.to_f/size(date)) * 100
    end

    def sad_turnover(date)
      left_in_year = get(date.year).left_in_year.select{|c| c.sadness_factor == 4 || c.sadness_factor == 5}.size
      left_in_year == 0 ? 0 : (left_in_year.to_f/size(date)) * 100
    end

    def med_turnover(date)
      left_in_year = get(date.year).left_in_year.select{|c| c.sadness_factor == 3}.size
      left_in_year == 0 ? 0 : (left_in_year.to_f/size(date)) * 100
    end

    def happy_turnover(date)
      left_in_year = get(date.year).left_in_year.select{|c| c.sadness_factor == 2 || c.sadness_factor == 1}.size
      left_in_year == 0 ? 0 : (left_in_year.to_f/size(date)) * 100
    end

    def size(date)
      size = 0
      min_year.upto(date.year.to_i) do |curr_year|
        year_info = get(curr_year)
        hired = year_info.started_in_year.size
        left = year_info.left_in_year.size
        size += (hired - left)
      end
      size
    end

    def net_gain(date)
      size(date) - size(date-1)
    end

    def tenure_list(date)
      tenure_list = Array.new
      return tenure_list unless min_year
      date.year.downto(min_year) {|curr_year| get(curr_year).still_here.each {|c| tenure_list << c.tenure_as_at(date)}}
      tenure_list
    end

    def left_list
      left_list = Array.new
      @year_info_map.each_value {|y| left_list << y.left_in_year}
      left_list.flatten!
    end

    def hired_list_ignore_left
      hired_list = Array.new
      @year_info_map.each_value {|y| hired_list << y.started_in_year}
      hired_list.flatten!
    end

    def average_tenure(date)
      tenure_list(date).reduce(:+).to_f/size(date)
    end

    def median_tenure(date)
      ee_tenures = tenure_list(date).sort
      return ee_tenures[0] if ee_tenures.size == 1
      return 0 if ee_tenures.size == 0
      middle = (ee_tenures.size/2.0).floor
      middle % 2 == 1 ? (ee_tenures[middle]+ee_tenures[middle+1])/2.0 : ee_tenures[middle]
    end
  end

  class ReportTable
    attr_accessor :title, :header, :rows

    def initialize(title)
      @title = title
      @header = @rows = []
    end
  end

end
