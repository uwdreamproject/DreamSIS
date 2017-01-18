class GradeLevel < ApplicationRecord
  validates_presence_of :title, :level
  validates_uniqueness_of :level
  validates_uniqueness_of :abbreviation, allow_nil: true
  
  default_scope { order('level') }
  
end
