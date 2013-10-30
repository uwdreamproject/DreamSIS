class Scholarship < ActiveRecord::Base
  validates_presence_of :title
  has_many :scholarship_applications
  
  default_scope :order => "title"
  
end
