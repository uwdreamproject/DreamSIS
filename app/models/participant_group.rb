class ParticipantGroup < ApplicationRecord
  has_many :participants
  belongs_to :location
  
  validates_presence_of :title, :location_id
  validates_uniqueness_of :title, scope: [:grad_year, :location_id]
  
  default_scope { order("grad_year DESC, title").joins(:location).readonly(false) }
  scope :ordered, -> { order("locations.name, grad_year DESC, title") }
end
