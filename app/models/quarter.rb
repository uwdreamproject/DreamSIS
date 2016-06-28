class Quarter < Term
  validates_presence_of :year
  validates_presence_of :quarter_code
  validates_inclusion_of :quarter_code, in: 1..4
  validates_uniqueness_of :quarter_code, scope: :year

  after_create :sync_with_resource!
  

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
  
  # Returns the title of just the quarter part. Useful for the UW web services.
  def quarter_title
    titles = %w( winter spring summer autumn )
    titles[quarter_code-1]
  end

  # Determines the next Term in the calendar
  def next
    next_qtr_code = quarter_code == 4 ? 1 : quarter_code + 1
    next_year = quarter_code == 4 ? year + 1 : year
    Quarter.find("#{%w( WIN SPR SUM AUT )[next_qtr_code-1]}#{next_year}")
  end
  
  # Determines the previous Term in the calendar
  def prev
    prev_qtr_code = quarter_code == 1 ? 4 : quarter_code - 1
    prev_year = quarter_code == 1 ? year - 1 : year
    Quarter.find("#{%w( WIN SPR SUM AUT )[prev_qtr_code-1]}#{prev_year}")
  end
  
  # Returns an abbreviated version of the Quarter name; e.g., "AUT2008"
  def to_param
    "#{quarter_code_abbreviation}#{year}"
  end
  
  # Returns the TermResource that corresponds to this Term.
  def term_resource
    begin
      titles = %w( winter spring summer autumn )
      @term_resource ||= TermResource.find "#{year},#{titles[quarter_code-1]}"
    rescue ActiveResource::ResourceNotFound => e
      @term_resource = nil
    rescue ActiveResource::UnauthorizedAccess => e
      @term_resource = nil
    end
  end
  
  # Syncs the start and end dates with the TermResource FirstDay and LastFinalExamDay.
  def sync_with_resource!
    self.update_attributes({
      start_date: term_resource.try(:FirstDay),
      end_date: term_resource.try(:LastFinalExamDay)
    }) if term_resource
  rescue
    false
  end
  
  # Finds or creates a GroupResource based on this term. Name format is like this: u_uwdrmprj_mentors_spring2011
  def group_resource
    titles = %w( winter spring summer autumn )
    @group_resource ||= GroupResource.find_or_create("mentors_#{titles[quarter_code-1]}#{year}")
  end
  
  # Updates the group membership for this term's group membership with the current active mentors.
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