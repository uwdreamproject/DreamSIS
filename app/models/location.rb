class Location < ActiveRecord::Base

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_format_of :website_url, :with => Addressable::URI::URIREGEX
  
  geocoded_by :address do |obj, results|
    if geo = results.first
      obj.latitude = geo.latitude
      obj.longitude = geo.longitude
      obj.county = geo.county # added through class_eval in initializers
      obj.city = geo.city
    end
    [geo.latitude, geo.longitude] if geo
  end  
  after_validation :geocode, :if => :address_changed?

  default_scope :order => "name"

  # Returns all the events that we should show on the attendance page for the requested term
  def events(term = nil, audience = nil, visits_only = true, limit = 1000)
    conditions = ""
    conditions_values = {} 
    conditions << "date >= '#{term.start_date.to_s(:db)}' AND date <= '#{term.end_date.to_s(:db)}'" if term
    if audience
      conditions << " AND show_for_mentors = :sfm " && conditions_values[:sfm] = true if audience.include?(:mentors)
      conditions << " AND show_for_participants = :sfp " && conditions_values[:sfp] = true if audience.include?(:participants)
    end
    conditions << " AND (location_id = '#{id}' OR location_id IS NULL)"
    conditions << " AND type = 'Visit' " if visits_only
    Event.where([conditions, conditions_values]).limit(limit)
  end

  # Returns an array of unassigned survey_ids that can be given to students at this location. The codes take this form:
  #   M <last 2 digitis of current year> <zero-padded location ID> <zero-padded number between 0 and 999>
  def unassigned_survey_ids
    all_survey_ids = Person.find(:all, :select => :survey_id).collect(&:survey_id)
    (0..999).collect{|n| "M#{Date.today.year.to_s[2,2]}#{id.to_s.rjust(2,"0")}#{n.to_s.rjust(2,"0")}"} - all_survey_ids
  end

  # Strips all non digits from the phone number before storing it
  def phone=(new_number)
    write_attribute :phone, new_number.gsub(/[^0-9]/i, '')
  end
  
end
