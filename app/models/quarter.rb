class Quarter < ActiveRecord::Base
  has_many :mentor_quarter_groups, :include => { :mentor_quarters => :mentor }

  validates_presence_of :year
  validates_presence_of :quarter_code
  validates_presence_of :start_date
  validates_presence_of :end_date
  validates_inclusion_of :quarter_code, :in => 1..4

  validates_uniqueness_of :quarter_code, :scope => :year

  after_create :sync_with_resource!
  
  default_scope :order => "year, quarter_code"
  
  named_scope :allowing_signups, :conditions => { :allow_signups => true }
  
  # Returns a pretty representation of the Quarter; e.g., "Autumn 2008"
  def title
    titles = %w( Winter Spring Summer Autumn)
    "#{titles[quarter_code-1]} #{year}"
  end
  
  # Returns the abbreviation for the quarter code. 1 = WIN, 2 = SPR, 3 = SUM, 4 = AUT.
  def quarter_code_abbreviation
    abbrevs = %w( WIN SPR SUM AUT )
    abbrevs[quarter_code - 1]
  end

  # Determines the next Quarter in the calendar
  def next
    next_qtr_code = quarter_code == 4 ? 1 : quarter_code + 1
    next_year = quarter_code == 4 ? year + 1 : year
    Quarter.find("#{%w( WIN SPR SUM AUT )[next_qtr_code-1]}#{next_year}")
  end
  
  # Determines the previous Quarter in the calendar
  def prev
    prev_qtr_code = quarter_code == 1 ? 4 : quarter_code - 1
    prev_year = quarter_code == 1 ? year - 1 : year
    Quarter.find("#{%w( WIN SPR SUM AUT )[prev_qtr_code-1]}#{prev_year}")
  end
  
  # Returns an abbreviated version of the Quarter name; e.g., "AUT2008"
  def to_param
    "#{quarter_code_abbreviation}#{year}"
  end

  # Overrides find to allow you to find a Quarter with any of the following types of ID's:
  # 
  # * database id, e.g., "1"
  # * SDB-style abbreviation, e.g., "SPR2010"
  # * SWS-style abbreviation, e.g., "2011,spring"
  # * a _quarter_select partial hash, with a "quarter_code_abbreviation" and "year" keys
  # 
  # Also, auto-creates the Quarter if it doesn't exist.
  def self.find(*args)
    id = args.first
    if id.is_a?(Numeric)
      return super(*args)
    elsif id.is_a?(String) && m = id.match(/(\d{4}),([spring,winter,autumn,summer]+)/)
      code_abbrevs = { :spring => "SPR", :winter => "WIN", :autumn => "AUT", :summer => "SUM" }
      abbrev = "#{code_abbrevs[m[2].to_sym]}#{m[1]}"
      return self.find_by_abbrev(abbrev)
    elsif id.is_a?(String)
      return self.find_by_abbrev(id)
    elsif id.is_a?(Hash)
      return self.find_by_abbrev("#{id[:quarter_code_abbreviation]}#{id[:year]}")
    else
      return super(*args)
    end
  end

  # Finds a quarter based on the given abbreviation, e.g., "AUT2008".
  def self.find_by_abbrev(abbrev, create_if_missing = true)
    return nil if abbrev.blank?
    qc = Quarter.quarter_code(abbrev[0,3])
    y = abbrev[3,4]
    q = Quarter.find_or_initialize_by_quarter_code_and_year(qc,y)
    if q.new_record? && create_if_missing
      q.start_date = Quarter.guess_first_day(qc,y)
      q.end_date = Quarter.guess_last_day(qc,y)
      q.save!
    end
    return q
  end
  
  # Tries to find an existing quarter record by the given quarter abbrev, if not, creates a new quarter with that abbrev
  def self.find_or_create_by_abbrev(abbrev)
    Quarter.find_by_abbrev(abbrev, true)
  end
  
  # Returns true if specified date falls between this Quarter's start and end dates.
  def include?(date)
    date >= start_date && date <= end_date
  end
  
  # Returns the grad year of participants who were dream scholars in this quarter. 
  # Eg. Spring 2008, Summer 2008, Autumn 2008 returns 2009. Winter 2009 returns 2009
  # Does not include spring quarter seniors
  def participating_cohort  
    quarter_code == 1 ? year : year + 1
  end
    
  
  # Finds quarter where current date falls before quarter.end_date and after or on quarter.start_date 
  def self.current_quarter()
    q = Quarter.find(:first, :conditions => [ "? >= start_date AND ? < end_date", Time.now, Time.now])
    q ||= Quarter.create(:year => Time.now.year,
                         :quarter_code => Quarter.guess_quarter_code, 
                         :start_date => Quarter.guess_first_day(Quarter.guess_quarter_code, Time.now.year),
                         :end_date  => Quarter.guess_last_day(Quarter.guess_quarter_code, Time.now.year))
    q.valid? ? q : nil
  end
  
  def current_quarter?
    self == Quarter.current_quarter
  end

  # Returns the CourseResources for the course_ids specified in the course_ids field.
  def courses
    @courses ||= course_ids.split.to_a.collect{|course_id| CourseResource.find(course_id)}
  end
  
  # Pulls all the mentors from the mentor_quarter_groups and returns a single, flattened array of Mentors.
  def mentors
    @mentors ||= mentor_quarter_groups.collect(&:mentors).flatten.compact.uniq
  end
  
  # Returns the TermResource that corresponds to this Quarter.
  def term_resource
    begin
      titles = %w( winter spring summer autumn )
      @term_resource ||= TermResource.find "#{year},#{titles[quarter_code-1]}"
    rescue ActiveResource::ResourceNotFound => e
      @term_resource = nil
    end
  end
  
  # Syncs the start and end dates with the TermResource FirstDay and LastFinalExamDay.
  def sync_with_resource!
    self.update_attributes({
      :start_date => term_resource.try(:FirstDay),
      :end_date => term_resource.try(:LastFinalExamDay)
    }) if term_resource
  end
  
  # Finds or creates a GroupResource based on this quarter. Name format is like this: u_uwdrmprj_mentors_spring2011
  def group_resource
    titles = %w( winter spring summer autumn )
    @group_resource ||= GroupResource.find_or_create("mentors_#{titles[quarter_code-1]}#{year}")
  end
  
  # Updates the group membership for this quarter's group membership with the current active mentors.
  # Returns true if all members were added to the group. Returns an array of members not found.
  def update_group_membership!
    group_resource.update_members(mentors.collect(&:uw_net_id))
  end

  protected
  
  def self.guess_quarter_code(date = Time.now)
    quarter_code = case date.month
    when 1..3 
      1
    when 4..5
      2
    when 6..9
      3
    when 10..12
      4
    end
    quarter_code
  end
  
  def self.guess_first_day(quarter_code, year)
    first_day = case quarter_code
    when 1
      "#{year}-01-01"
    when 2
      "#{year}-04-01"
    when 3
      "#{year}-06-01"
    when 4
      "#{year}-10-01"
    end
    first_day
  end
  
  def self.guess_last_day(quarter_code, year)
    last_day = case quarter_code
    when 1
      "#{year}-03-31"
    when 2
      "#{year}-05-31"
    when 3
      "#{year}-09-30"
    when 4
      "#{year}-12-31"
    end
    last_day
  end
  
  def self.quarter_code(abbrev)
    abbrevs = %w( WIN SPR SUM AUT )
    abbrevs.index(abbrev)+1
  end
  
end
