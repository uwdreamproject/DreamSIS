class ObjectFilter < ActiveRecord::Base
  validates_presence_of :object_class, :title, :criteria
  
  validate :validate_criteria
  
  # If there's a value in the +opposite_title+ attribute, then we'll display the opposite perspective on the filters
  # list on the participant list.
  def display_filter_as_opposite?
    !read_attribute(:opposite_title).blank?
  end
  
  # Returns true if the passed object passes the filter criteria using +instance_eval+. Pass the "purpose" option as "stats"
  # to change the behavior for filters marked as +stats_shows_opposite+.
  def passes?(object, options = { :purpose => :filter })
    result = object.instance_eval(criteria)
    options[:purpose] == :filter && display_filter_as_opposite? ? !result : result
  end

  # If +opposite_title+ is blank, just default to the normal title.
  def opposite_title
    read_attribute(:opposite_title).blank? ? title : read_attribute(:opposite_title)
  end
  
  # Checks if the criteria can be evaluated without error.
  def validate_criteria
    object_class.constantize.first.instance_eval(criteria)
  rescue
    errors.add :criteria, "This is not valid code. Please check the syntax and try again."
    return false
  end
  
end
