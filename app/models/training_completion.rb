class TrainingCompletion < ActiveRecord::Base
  validates_presence_of :training_id, :person_id
  validates_uniqueness_of :person_id, scope: :training_id
  
  belongs_to :training
  belongs_to :person
    
  def completed?
    !completed_at.nil?
  end
end
