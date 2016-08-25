class ObjectFilter < ActiveRecord::Base
  validates_presence_of :object_class, :title, :criteria
  validate :validate_criteria
  validates_format_of :title, with: /\A[^.]+\Z/, message: "cannot include a period"
  after_save :expire_object_filters_cache
  
  belongs_to :earliest_grade_level, class_name: "GradeLevel", primary_key: 'level', foreign_key: 'earliest_grade_level_level'
  belongs_to :latest_grade_level, class_name: "GradeLevel", primary_key: 'level', foreign_key: 'latest_grade_level_level'

  default_scope { order("category IS NULL, category, position, earliest_grade_level_level, title") }

  acts_as_list scope: [:category]
    
  # If there's a value in the +opposite_title+ attribute, then we'll display the opposite perspective on the filters
  # list on the participant list.
  def display_filter_as_opposite?
    !read_attribute(:opposite_title).blank?
  end
  
  # Returns true if the passed object passes the filter criteria using +instance_eval+. Pass the "purpose" option as "stats"
  # to change the behavior for filters marked as +stats_shows_opposite+.
  def passes?(object, options = { purpose: :filter })
    result = object.instance_eval(criteria)
    result = false if result.nil?
    options[:purpose].to_sym == :stats && display_filter_as_opposite? ? !result : result
  rescue => e
    raise ObjectFilterEvaluationError.new(self, e)
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

  # Return the list of valid grade levels for this filter as an array.
  def grade_levels
    return [] unless !earliest_grade_level.nil? || !latest_grade_level.nil?
    [earliest_grade_level_level, latest_grade_level_level]
  end

  # Returns a string of the valid grade levels for this filter.
  def grade_levels_list_string(html = true)
    delimiter = html ? "&ndash;" : "-"
    grade_levels.join(delimiter)
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
  
  def expire_object_filters_cache
    object_class.constantize.expire_object_filters_cache
  end

  # Deletes all current filters information stored in the redis cache.
  def self.reset_filter_cache!
    if (keys = Customer.redis.keys("ObjectFilter*")) && !keys.empty?
      Customer.redis.del(keys)
    end
  end
  
  def redis_key(str)
    "ObjectFilter:#{self.id}:#{str}"
  end
  
  # Takes an array of filter conditions and returns the matching object_ids for
  # the intersection of those conditions in the filter cache. You can specify
  # direct redis keys ("ObjectFilter:6:pass") or short form ("6:pass").
  def self.intersect(filter_selections)
    keys = filter_selections.map{ |s| s.count(":") < 2 ? "ObjectFilter:" + s : s }
    Customer.redis.sinter(keys)
  end

end

class ObjectFilterEvaluationError < StandardError
  def initialize(object, original_error)
    msg = "Couldn't evaluate ObjectFilter ID ##{object.id}: " + original_error.message
    super(msg)
  end
end
