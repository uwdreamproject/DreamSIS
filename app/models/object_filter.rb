class ObjectFilter < ActiveRecord::Base
  validates_presence_of :object_class, :title, :criteria  
  validate :validate_criteria
  validates_format_of :title, :with => /\A[^.]+\Z/, :message => "cannot include a period"
  
  belongs_to :earliest_grade_level, :class_name => "GradeLevel", :primary_key => 'level', :foreign_key => 'earliest_grade_level_level'
  belongs_to :latest_grade_level, :class_name => "GradeLevel", :primary_key => 'level', :foreign_key => 'latest_grade_level_level'

  default_scope :order => "earliest_grade_level_level, title"
  
  # If there's a value in the +opposite_title+ attribute, then we'll display the opposite perspective on the filters
  # list on the participant list.
  def display_filter_as_opposite?
    !read_attribute(:opposite_title).blank?
  end
  
  # Returns true if the passed object passes the filter criteria using +instance_eval+. Pass the "purpose" option as "stats"
  # to change the behavior for filters marked as +stats_shows_opposite+.
  def passes?(object, options = { :purpose => :filter })
    result = object.instance_eval(criteria)
    options[:purpose].to_sym == :stats && display_filter_as_opposite? ? !result : result
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

  # Returns the human readable category name by looking up the value in Participant::FILTER_CATEGORIES.
  def category_name
    Participant::FILTER_CATEGORIES[category.to_sym] if category
  end

  # Returns false unless start_display_at and end_display_at are not nil.
  def has_display_period?
    !start_display_at.nil? && !end_display_at.nil?
  end

  # Returns a string representing the display period for this filter, like "December 1-June 1."
  def display_period_string(html = true)
    return "" unless has_display_period?
    delimiter = html ? "&ndash;" : "-"
    [start_display_at.to_s(:month_day), end_display_at.to_s(:month_day)].join(delimiter)
  end

  # Returns a string of the valid grade levels for this filter.
  def grade_levels_list_string(html = true)
    return "" unless !earliest_grade_level.nil? || !latest_grade_level.nil?
    delimiter = html ? "&ndash;" : "-"
    [earliest_grade_level_level, latest_grade_level_level].join(delimiter)
  end
  
  # Returns true if the display period is undefined, or if it is defined, if this filter should
  # be displayed now.
  def display_now?
    return true unless has_display_period?
    now_without_year = Date.new(1, Time.now.month, Time.now.day)
    start_display_at <= now_without_year && end_display_at >= now_without_year
  end
  
  def display_for?(participant)
    return false unless display_now?
    return true if participant.respond_to?(:grade) && participant.grade.nil?
    valid = true
    valid = participant.grade >= earliest_grade_level_level unless earliest_grade_level_level.nil?
    valid = participant.grade <= latest_grade_level_level unless latest_grade_level_level.nil?
    return valid
  end
  
end
