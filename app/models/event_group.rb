class EventGroup < ActiveRecord::Base
  has_many :events do
    def future
      find :all, conditions: ["date >= ?", Time.now.midnight]
    end
  end
  
  belongs_to :event_type
  validates_presence_of :name

  validates_presence_of :mentor_disable_message, if: :mentor_hours_prior_disable_cancel
  validates_presence_of :volunteer_disable_message, if: :volunteer_hours_prior_disable_cancel
  validates_presence_of :student_disable_message, if: :student_hours_prior_disable_cancel

  belongs_to :volunteer_training, class_name: "Training"
  belongs_to :mentor_training, class_name: "Training"

  default_scope { order("id DESC") }

  # Returns future events that should be displayed for the particular person or audience type.
  def future_events(person_or_type = nil)
    conditions_filters = { date_filter: Time.now.midnight }
    conditions_string = "date >= :date_filter "
    if person_or_type
      aud = Event.process_audience(person_or_type)
      conditions_string << "AND show_for_#{aud.to_s.downcase.pluralize} = :audience_filter"
      conditions_filters[:audience_filter] = true
    end
    events.where([conditions_string, conditions_filters])
  end
  
  # Returns the description based on the type of person provided as a parameter (or a class name).
  # If no parameter is given (or it is nil), the generic description (the original +description+
  # attribute in EventGroup) is returned. This is also the case if a specialized description does
  # not exist for the specified person.
  def description(person_or_type = nil)
    generic_description = read_attribute(:description)
    return generic_description if person_or_type.nil?
    aud = Event.process_audience(person_or_type)
    custom_description = attribute_for_audience(:description, aud)
    custom_description.blank? ? generic_description : custom_description
  end
  
  # Returns the confirmation message that should be displayed for this person (similar to #description).
  # Based on the value of the +hide_description_in_confirmation_message+ attribute, this
  # method will combine the appropriate description and confirmation message content into
  # a single block of rendered text.
  def confirmation_message(person_or_type = nil)
    custom_description = hide_description_in_confirmation_message? ? "" : description(person_or_type)
    custom_confirmation_message = ""
    if person_or_type
      aud = Event.process_audience(person_or_type)
      custom_confirmation_message = attribute_for_audience(:confirmation_message, aud)
    end
    custom_description.to_s + custom_confirmation_message.to_s
  end
  
  # Returns true if either +allow_external_students+ or +allow_external_volunteers+ is true.
  def open_to_public?
    allow_external_students? || allow_external_volunteers?
  end
  
  # Returns true if training is required for the specified person or person type.
  def training_required?(person_or_type)
    aud = Event.process_audience(person_or_type)
    return false if self[aud.to_s.downcase + "_training_optional"]
    !training_for(person_or_type).nil?
  end

  # Returns the training for the specified person or person type.
  def training_for(person_or_type)
    aud = Event.process_audience(person_or_type)
    return nil unless %i(Volunteer Mentor).include? aud
    attribute_for_audience(:training_for, aud)
  end

  # Returns the number of hours before group's events to disable
  # cancellation for the specified person or person type,
  # or nil if there is no such specified time
  def hours_prior_disable_cancel(person_or_type)
    aud = Event.process_audience(person_or_type)
    attribute_for_audience(:hours_prior_disable_cancel, aud)
  end

  # Returns the message to display notifying of cancellation
  # disabling for the specified person_or_type, guaranteed to exist
  # if there is +hours_prior_disable_cancel+ is set
  def disable_message(person_or_type)
    aud = Event.process_audience(person_or_type)
    attribute_for_audience(:disable_message, aud)
  end

  protected

  # Helper method for returning attributes prefixed by audience
  def attribute_for_audience(attr,  audience)
    return read_attribute(attr) if audience.nil?
    audience = Event.process_audience(audience)
    audience = :Student if audience == :Participant
    read_attribute(audience.to_s.downcase + "_" + attr.to_s)
  end
  
end
