class EducationLevel < ActiveRecord::Base

  default_scope :order => "sequence"
  
  def <=>(o)
    sequence <=> o.sequence rescue 0
  end
  
end
