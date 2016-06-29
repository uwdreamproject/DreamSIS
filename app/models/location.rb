class Location < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, use: :slugged

  validates_presence_of :name
  validates_uniqueness_of :name
  validates :website_url, format: URI::regexp(%w(http https))
  
  geocoded_by :address do |obj, results|
    if geo = results.first
      obj.latitude = geo.latitude
      obj.longitude = geo.longitude
      obj.county = geo.county # added through class_eval in initializers
      obj.city = geo.city
    end
    [geo.latitude, geo.longitude] if geo
  end
  after_validation :geocode, if: :address_changed?

  default_scope { order("name") }

  include MultitenantProxyable
  acts_as_proxyable

  def proxyable_attributes
    excluded = %w[id type created_at updated_at partner_school enable_college_mapper_integration customer_id]
    attributes.except(*excluded)
  end

  # Returns all the events that we should show on the attendance page for the requested term
  def events(term = nil, audience = nil, visits_only = true, limit = 1000)
    conditions = ""
    conditions_values = { nil: nil, true: true }
    conditions << "date >= '#{term.start_date.to_s(:db)}' AND date <= '#{term.end_date.to_s(:db)}'" if term
    if audience
      conditions << " AND show_for_mentors = :true " if audience.include?(:mentors)
      conditions << " AND show_for_participants = :true " if audience.include?(:participants)
    end
    conditions << " AND (location_id = '#{id}' OR location_id IS :nil OR always_show_on_attendance_pages = :true) "
    conditions << " AND (type = 'Visit' OR always_show_on_attendance_pages = :true) " if visits_only
    Event.where([conditions, conditions_values]).limit(limit)
  end

  # Returns an array of unassigned survey_ids that can be given to students at this location. The codes take this form:
  #   M <last 2 digitis of current year> <zero-padded location ID> <zero-padded number between 0 and 999>
  def unassigned_survey_ids
    all_survey_ids = Person.find(:all, select: :survey_id).collect(&:survey_id)
    (0..999).collect{|n| "M#{Date.today.year.to_s[2,2]}#{id.to_s.rjust(2,"0")}#{n.to_s.rjust(2,"0")}"} - all_survey_ids
  end

  # Strips all non digits from the phone number before storing it
  def phone=(new_number)
    write_attribute :phone, new_number.to_s.gsub(/[^0-9]/i, '')
  end
  
end
