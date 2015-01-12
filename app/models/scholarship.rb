class Scholarship < ActiveRecord::Base
  validates_presence_of :title
  has_many :scholarship_applications
  
  default_scope :order => "title"

	ATTRIBUTES_TO_MERGE = %w[
    title organization_name description default_amount default_renewable_years default_full_ride 
    default_gap_funding default_living_stipend default_renewable
  ]

  # Strip out non-digit characters if needed, like "$" or "," or other text.
  def default_amount=(new_amount)
    new_amount = new_amount.gsub(/[^0-9.]/i, '') unless new_amount.is_a?(Numeric)
    self[:default_amount] = new_amount
  end

	# Merges this scholarship into another one. That Scholarship becomes the "master" scholarship
	# and any ScholarshipApplication records with this scholarship_id is reassigned to that scholarship.
	# Any non-blank fields are overridden, and then this record is deleted. Note that fields with values
	# in the master record are never overwritten.
	def merge_into(master_scholarship)
		raise Exception.new("Invalid master scholarship") unless master_scholarship.is_a?(Scholarship)
		Scholarship.transaction do
			new_attributes = {}
			for attribute in ATTRIBUTES_TO_MERGE
				new_attributes[attribute] = self[attribute] if !self[attribute].blank? && master_scholarship[attribute].blank?
			end
			master_scholarship.update_attributes!(new_attributes)
			for scholarship_application in scholarship_applications
				scholarship_application.scholarship_id = master_scholarship.id
				scholarship_application.save!
			end
			destroy
		end
		master_scholarship
	end
  
end
