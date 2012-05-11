class ParticipantGroup < ActiveRecord::Base
  has_many :participants
  belongs_to :location
  
  validates_presence_of :title, :location_id
  validates_uniqueness_of :title, :scope => [:grad_year, :location_id]
  
  default_scope :order => "locations.name, grad_year DESC, title", :joins => :location
end
