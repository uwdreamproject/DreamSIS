class EducationLevel < ActiveRecord::Base

  default_scope :order => "sequence"
  
  validates_uniqueness_of :title
  validates_presence_of :title, :sequence
  
  def <=>(o)
    sequence <=> o.sequence rescue 0
  end
  
end
