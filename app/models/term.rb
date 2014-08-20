# Models a specific period of time, usually aligning to an academic calendar. This used to be called "Quarter" to model the academic quarters of the UW, but was renamed to Term to handle other types of calendars, such as semesters. The change also allows customers to use completely arbitrary calendar terms, like a full year or more.
# 
# Quarter is now available as a subclass of this model so that quarter-specific funcationality can be retained.
class Term < ActiveRecord::Base
  has_many :mentor_term_groups, :include => { :mentor_terms => :mentor }

  validates_presence_of :start_date
  validates_presence_of :end_date

  default_scope :order => "year, quarter_code, title"
  
  scope :allowing_signups, :conditions => { :allow_signups => true }
  
  # Overrides find to allow you to find a Term with any of the following types of ID's:
  # 
  # * database id, e.g., "1"
  # * SDB-style abbreviation, e.g., "SPR2010"
  # * SWS-style abbreviation, e.g., "2011,spring"
  # * a _term_select partial hash, with a "quarter_code_abbreviation" and "year" keys
  # 
  # Also, auto-creates the Term if it doesn't exist.
  def self.find(*args)
    id = args.first
    if id.is_a?(Numeric)
      return super(*args)
    elsif id.is_a?(String) && id.is_integer?
      return super(*args)
    elsif id.is_a?(String) && m = id.match(/(\d{4}),([spring,winter,autumn,summer]+)/)
      code_abbrevs = { :spring => "SPR", :winter => "WIN", :autumn => "AUT", :summer => "SUM" }
      abbrev = "#{code_abbrevs[m[2].to_sym]}#{m[1]}"
      return Quarter.find_by_abbrev(abbrev)
    elsif id.is_a?(String) && m = id.match(/([SPR,WIN,AUT,SUM]+)(\d{4})/)
      return Quarter.find_by_abbrev(id)
    elsif id.is_a?(String)
      return Term.find_by_title(id)
    elsif id.is_a?(Hash)
      return Quarter.find_by_abbrev("#{id[:quarter_code_abbreviation]}#{id[:year]}")
    else
      return super(*args)
    end
  end

  # Finds a term based on the given abbreviation, e.g., "AUT2008".
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
  
  # Tries to find an existing term record by the given term abbrev, if not, creates a new term with that abbrev
  def self.find_or_create_by_abbrev(abbrev)
    Term.find_by_abbrev(abbrev, true)
  end
  
  # Includes the current term AND the terms allowing signups.
  def self.current_and_allowing_signups
    [Term.current_term, Term.allowing_signups].flatten.uniq.compact
  end
  
  # Returns true if specified date falls between this Term's start and end dates.
  def include?(date)
    date >= start_date && date <= end_date
  end
  
  # Returns the grad year of participants who were dream scholars in this term. 
  # Eg. Spring 2008, Summer 2008, Autumn 2008 returns 2009. Winter 2009 returns 2009
  # Does not include spring term seniors
  def participating_cohort
    if quarter_code
      return quarter_code == 1 ? year : year + 1
    else
      return end_date.blank? ? Time.now.year : end_date.year
    end
  end
    
  
  # Finds term where current date falls before term.end_date and after or on term.start_date 
  def self.current_term()
    q = Term.find(:first, :conditions => [ "? >= start_date AND ? < end_date", Time.now, Time.now])
    q ||= Quarter.create(:year => Time.now.year,
                         :quarter_code => Quarter.guess_quarter_code, 
                         :start_date => Quarter.guess_first_day(Quarter.guess_quarter_code, Time.now.year),
                         :end_date  => Quarter.guess_last_day(Quarter.guess_quarter_code, Time.now.year))
    q.valid? ? q : nil
  end
  
  def current_term?
    self == Term.current_term
  end
  
  # Returns an parameterized version of the Term name; e.g., "2012-2013"
  def to_param
    title.to_param
  end
  

  # Returns the CourseResources for the course_ids specified in the course_ids field.
  def courses
    return [] if course_ids.blank?
    @courses ||= course_ids.split.to_a.collect do |course_id|
      CourseResource.find(course_id)
    end
  end
  
  # Pulls all the mentors from the mentor_term_groups and returns a single, flattened array of Mentors.
  def mentors
    @mentors ||= mentor_term_groups.collect(&:mentors).flatten.compact.uniq
  end
  
end
