class ScholarshipApplication < ActiveRecord::Base
  belongs_to :scholarship
  belongs_to :participant
  
  validates_presence_of :scholarship_id, :participant_id
  # validates_uniqueness_of :scholarship_id, :scope => :participant_id  # Deprecated. Students can earn the same scholarship more than once.
  
  def title
    scholarship.try(:title)
  end

  def title=(new_title)
    s = Scholarship.find_or_create_by_title(new_title)
    update_attribute :scholarship_id, s.try(:id)
    new_title
  end
  
  # Strip out non-digit characters if needed, like "$" or "," or other text.
  def amount=(new_amount)
    new_amount = new_amount.gsub(/[^0-9.]/i, '') unless new_amount.is_a?(Numeric)
    self.write_attribute(:amount, new_amount)
  end
  
end