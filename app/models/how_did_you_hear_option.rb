class HowDidYouHearOption < ActiveRecord::Base
  # has_many :how_did_you_hear_people
  # has_many :people, through: :how_did_you_hear_people
  has_and_belongs_to_many :people
  
  default_scope order: "name"
  
  scope :for_participants, conditions: { show_for_participants: true }
  scope :for_mentors, conditions: { show_for_mentors: true }
  
  validates_presence_of :name
  validates_uniqueness_of :name
  
  
end
