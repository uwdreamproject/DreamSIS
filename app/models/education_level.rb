class EducationLevel < ActiveRecord::Base

  default_scope { order("sequence") }
  
  validates_uniqueness_of :title
  validates_presence_of :title, :sequence
  
  def <=>(o)
    sequence <=> o.sequence rescue 0
  end

	def above_sequence?(sequence_param)
		sequence > sequence_param
	end
  
end
