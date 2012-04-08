class Participant < Person
  belongs_to :high_school
  has_many :college_applications
  has_many :scholarship_applications
  belongs_to :college_attending, :class_name => "Institution"
  belongs_to :mother_education_level, :class_name => "EducationLevel"
  belongs_to :father_education_level, :class_name => "EducationLevel"
  belongs_to :family_income_level, :class_name => "IncomeLevel"
  belongs_to :participant_group

  has_many :mentor_participants
  has_many :mentors, :through => :mentor_participants

  attr_accessor :override_binder_date, :override_fafsa_date
  
  named_scope :in_cohort, lambda {|grad_year| {:conditions => { :grad_year => grad_year }}}
  named_scope :in_high_school, lambda {|high_school_id| {:conditions => { :high_school_id => high_school_id }}}

  def validate_name?
    true
  end
  
  # Returns an array of unique graudation years
  def self.cohorts
    Participant.find(:all).collect(&:grad_year).uniq.compact.sort.reverse
  end
  
  # Returns the grad_year of the currently-active cohort:
  # 
  # * if the current quarter is Winter, return current year
  # * if the current quarter is Summer, Autumn, or Spring, return current_year + 1
  def self.current_cohort
    q = Quarter.current_quarter || Quarter.allowing_signups.try(:first) || Quarter.last
    q.quarter_code == 1 ? Time.now.year : Time.now.year + 1
  end
  
  # Returns all Filter objects that list Participant as the object_class
  def self.object_filters
    ObjectFilter.find_all_by_object_class("Participant")
  end
  
  # Tries to find duplicate records based on name and high school. Pass an array of participant data straight from your params
  # hash. Second parameter is a limit on the number of records to return (defaults to 50).
  def self.possible_duplicates(data, limit = 50)
    Participant.find(:all, 
                    :conditions => ["firstname LIKE ? AND lastname LIKE ?", "#{data[:firstname]}%", "#{data[:lastname]}%"],
                    :limit => limit)
  end
  
  # Returns true if multiple ethnicity checkboxes were checked
  def multiracial?
    ethnicities.size > 1
  end
  
  # Returns true if none of the ethnicity checkboxes are checked, even if ethnicity_details contains a value.
  def no_ethnicity_response?
    ethnicities.empty?
  end
  
  # Returns a list of all the ethnicities for this participant. If a separator is provided, then returns a
  # concatenated string, otherwise just an array. Pass an +include_details+ option to also include the +ethnicity_details+
  # field.
  def ethnicities(separator = nil, options = {})
    ethnicities = []
    ethnicities << "hispanic" if hispanic?
    ethnicities << "african_american" if african_american?
    ethnicities << "american_indian" if american_indian?
    ethnicities << "asian" if asian?
    ethnicities << "pacific_islander" if pacific_islander?
    ethnicities << "caucasian" if caucasian?
    ethnicities << ethnicity_details if !ethnicity_details.blank? && options[:include_details]
    return ethnicities if separator.nil?
    ethnicities.join(separator)
  end

  # Returns true if there is a value in the +fafsa_submitted_date+ field.
  def submitted_fafsa?
    !fafsa_submitted_date.nil?
  end
  
  # Automatically updates the +binder_date+ to Time.now if the value is true or to nil if the value is false.
  def received_binder=(binder_boolean)
    write_attribute(:received_binder, binder_boolean)
    if received_binder?
      write_attribute(:binder_date, override_binder_date || Time.now)
    else
      write_attribute(:binder_date, nil)
    end
  end
  
  def submitted_fafsa=(fafsa_boolean)
    if fafsa_boolean == true || fafsa_boolean == "true"
      write_attribute(:fafsa_submitted_date, override_fafsa_date || Time.now)
    else
      write_attribute(:fafsa_submitted_date, nil)
    end
  end
  
  # Returns true if there is a value in the fafsa_submitted_date field
  def submitted_fafsa?
    !fafsa_submitted_date.nil?
  end
  
end
