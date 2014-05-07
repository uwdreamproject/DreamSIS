# Models an instance of a participant taking a test represented by TestType. For example, the SAT or ACT tests.
class TestScore < CustomerScoped  
  belongs_to :participant, :touch => true
  belongs_to :test_type
  
  delegate :name, :to => :test_type
  
  validates_presence_of :participant_id, :test_type_id, :taken_at
  validate :total_score_is_below_maximum
  
  serialize :section_scores
  before_save :update_section_scores_attribute

  default_scope :joins => :test_type, :order => "test_types.name ASC, taken_at ASC", :conditions => { :customer_id => lambda {Customer.current_customer.id}.call }

  after_save :update_filter_cache
  after_destroy :update_filter_cache

  # Updates the participant filter cache
  def update_filter_cache
    participant.save
  end

  # Overrides the instantiate method to add the section score attributes to the class
  # using +attr_accessor+. This allows us to dynamically get and set the section scores,
  # which are stored in a serialized hash in the +section_scores+ attribute.
  def self.instantiate(*args)
    obj = super(*args)
    obj.add_section_score_attribute_methods
    obj
  end

  # See #self.instantiate.
  def add_section_score_attribute_methods
    if test_type
      for section_name, score in test_type.section_scores_hash
        class_eval { attr_accessor "section_score_" + section_name }
        section_score(section_name, section_score(section_name))
      end
    end
  end
  
  # Used with a +before_save+ callback, this method takes the values from the attribute
  # accessors (like +section_score_Writing+) and stores them in the serialized hash.
  def update_section_scores_attribute
    if test_type
      for section_name, score in test_type.section_scores_hash
        section_score(section_name, instance_eval("section_score_" + section_name))
      end
    end
  end
  
  # Convenience method for getting and setting section scores. If you pass a new score to
  # set, this will update the section scores hash and the attribute accessor. Otherwise,
  # it will just return the current value for the requested section store.
  def section_score(section_name, new_score = nil)
    self.section_scores = {} if self.section_scores.nil?
    unless new_score.blank?
      section_name = section_name.parameterize.underscore
      instance_eval "self.section_score_#{section_name} = #{new_score.to_s}"
      self.section_scores[section_name.to_s] = new_score
    end
    return self.section_scores[section_name.to_s]
  end

  # Makes sure that the current total_score is below or equal to the maximum total score
  # allowed for the associated TestType.
  def total_score_is_below_maximum
    return true unless test_type
    return true unless test_type.maximum_total_score && total_score
    errors.add(:total_score, "is above the maximum total score for this test type") if total_score > test_type.maximum_total_score
  end
  
  # Uses number_with_precision to display the total score with 2 fractional digits and then strips insignificant zeroes.
  #
  # TODO use native :strip_insignificant_zeroes option when upgrading to rails 3.
  def total_score_pretty
    return "" if total_score.blank?
  	formatted_number = ActionController::Base.helpers.number_with_precision(total_score, :precision => 2)
  	formatted_number.sub(/(\.)(\d*[1-9])?0+\z/, '\1\2').sub(/\.\z/, '')
  end
  
  # Returns some useful comparisons for the specified participant's test scores of the
  # requested type. Returns a hash with the relevant values below.
  # 
  # * earliest_total: the total score for the earliest test of this type
  # * highest_total: the highest total point score of any test of this type
  # * highest_total_after_earliest: the highest total score, not including the earliest test
  # * gain_or_loss: the total point gain or loss from the earliest score to the highest total after the earliest
  # * gain_or_loss_trend: "up", "down" or "same"
  # 
  # When possible, the hash will include the actual TestScore object, but if mathematics is 
  # involved, it will just return the calculated value.
  def self.score_comparison(participant, test_type)
    scores = participant.test_scores.find(:all, :joins => :test_type, :conditions => ["test_types.name LIKE ?", "%"+test_type+"%"])
    results = {}
    results[:all] = scores
    results[:earliest_total] = scores.sort_by(&:taken_at).first
    results[:highest_total] = scores.sort_by(&:total_score).last
    results[:highest_total_after_earliest] = scores.dup.reject{|s| s == results[:earliest_total]}.sort_by(&:total_score).last
    results[:gain_or_loss] = results[:highest_total_after_earliest].try(:total_score) - results[:earliest_total].try(:total_score) rescue nil
    results[:gain_or_loss_trend] = results[:gain_or_loss] > 0 ? "up" : results[:gain_or_loss] < 0 ? "down" : "same" rescue nil
    return results
  end
  
end
