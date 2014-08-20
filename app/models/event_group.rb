class EventGroup < ActiveRecord::Base
  has_many :events do
    def future
      find :all, :conditions => ["date >= ?", Time.now.midnight]
    end
  end
  
  belongs_to :event_type
  validates_presence_of :name
  
  belongs_to :volunteer_training, :class_name => "Training"
  belongs_to :mentor_training, :class_name => "Training"

  default_scope :order => "id DESC"
  
  # Returns future events that should be displayed for the particular person or audience type.
  def future_events(person_or_type = nil)
    klass = person_or_type.is_a?(Person) ? person_or_type.class : person_or_type
    klass = nil unless %w(Student Participant Volunteer Mentor).include?(klass.to_s)
    conditions_filters = { :date_filter => Time.now.midnight }
    conditions_string = "date >= :date_filter "
    if klass
      conditions_string << "AND show_for_#{klass.to_s.downcase.pluralize} = :audience_filter"
      conditions_filters[:audience_filter] = true
    end
    events.find(:all, :conditions => [conditions_string, conditions_filters])
  end
  
  # Returns the description based on the type of person provided as a parameter (or a class name).
  # If no parameter is given (or it is nil), the generic description (the original +description+
  # attribute in EventGroup) is returned. This is also the case if a specialized description does
  # not exist for the specified person.
  def description(person_or_type = nil)
    generic_description = read_attribute(:description)
    return generic_description if person_or_type.nil?
    klass = person_or_type.is_a?(Person) ? person_or_type.class : person_or_type
    if klass == Student || klass == Participant
      custom_description = student_description
    elsif klass == Volunteer
      custom_description = volunteer_description
    elsif klass == Mentor
      custom_description = mentor_description
    end
    custom_description.blank? ? generic_description : custom_description
  end
  
  # Returns the confirmation message that should be displayed for this person (similar to #description).
  # Based on the value of the +hide_description_in_confirmation_message+ attribute, this
  # method will combine the appropriate description and confirmation message content into
  # a single block of rendered text.
  def confirmation_message(person_or_type = nil)
    custom_description = hide_description_in_confirmation_message? ? "" : description(person_or_type)
    klass = person_or_type.is_a?(Person) ? person_or_type.class : person_or_type
    if klass == Student || klass == Participant
      custom_confirmation_message = student_confirmation_message
    elsif klass == Volunteer
      custom_confirmation_message = volunteer_confirmation_message
    elsif klass == Mentor
      custom_confirmation_message = mentor_confirmation_message
    end
    custom_description.to_s + custom_confirmation_message.to_s
  end
  
  # Returns true if either +allow_external_students+ or +allow_external_volunteers+ is true.
  def open_to_public?
    allow_external_students? || allow_external_volunteers?
  end
  
  # Returns true if training is required for the specified person or person type.
  def training_required?(person_or_type)
    klass = person_or_type.is_a?(Person) ? person_or_type.class : person_or_type.constantize
    return false if self[klass.to_s.downcase + "_training_optional"]
    !training_for(person_or_type).nil?
  end

  # Returns the training for the specified person or person type.
  def training_for(person_or_type)
    klass = person_or_type.is_a?(Person) ? person_or_type.class : person_or_type.constantize
    if klass == Volunteer
      volunteer_training
    elsif klass == Mentor
      mentor_training
    else
      nil
    end
  end

  
end
