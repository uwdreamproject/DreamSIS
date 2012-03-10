class Location < ActiveRecord::Base

  validates_presence_of :name
  validates_uniqueness_of :name

  default_scope :order => "name"

  # Returns all the events that we should show on the attendance page for the requested quarter
  def events(quarter = nil, audience = nil)
    conditions = ""
    conditions_values = {} 
    conditions << "date >= '#{quarter.start_date.to_s(:db)}' AND date <= '#{quarter.end_date.to_s(:db)}'" if quarter
    if audience
      conditions << " AND show_for_mentors = :sfm " && conditions_values[:sfm] = true if audience.include?(:mentors)
      conditions << " AND show_for_participants = :sfp " && conditions_values[:sfp] = true if audience.include?(:participants)
    end
    conditions << " AND (location_id = '#{id}' OR location_id IS NULL)"
    Event.find(:all, :conditions => [conditions, conditions_values])
  end

  # Returns an array of unassigned survey_ids that can be given to students at this location. The codes take this form:
  #   M <last 2 digitis of current year> <zero-padded location ID> <zero-padded number between 0 and 999>
  def unassigned_survey_ids
    all_survey_ids = Person.find(:all, :select => :survey_id).collect(&:survey_id)
    (0..999).collect{|n| "M#{Date.today.year.to_s[2,2]}#{id.to_s.rjust(2,"0")}#{n.to_s.rjust(2,"0")}"} - all_survey_ids
  end
    
end
