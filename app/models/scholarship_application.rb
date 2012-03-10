class ScholarshipApplication < ActiveRecord::Base
  belongs_to :scholarship
  belongs_to :participant
  
  validates_presence_of :scholarship_id, :participant_id
  validates_uniqueness_of :scholarship_id, :scope => :participant_id
  
  def title
    scholarship.try(:title)
  end

  def title=(new_title)
    s = Scholarship.find_or_create_by_title(new_title)
    update_attribute :scholarship_id, s.try(:id)
    new_title
  end
  
end