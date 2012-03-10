class Scholarship < ActiveRecord::Base
  validates_presence_of :title
  has_many :scholarhip_applications
  
  default_scope :order => "title"
  
end
