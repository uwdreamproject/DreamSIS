# Models an instance of a participant taking a test represented by TestType. For example, the SAT or ACT tests.
class TestScore < ActiveRecord::Base
  belongs_to :participant
  belongs_to :test_type
  
  delegate :name, :to => :test_type
  
  validates_presence_of :participant_id, :test_type_id, :taken_at
  
  validate :total_score_is_below_maximum
  
  serialize :section_scores
  before_save :update_section_scores_attribute

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
  
end
