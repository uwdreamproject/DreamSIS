class CollegeApplication < ApplicationRecord
  
  # belongs_to :institution
  belongs_to :participant, touch: true
  
  validates_presence_of :institution_id, :participant_id
  validates_uniqueness_of :institution_id, scope: :participant_id, message: "is already assigned to another college application for this participant"
  validates_numericality_of :institution_id
  validates_exclusion_of :institution_id, in: [0], message: "ID can't be set to zero" # make sure this doesn't get set to zero, but allow any other positive or negative integer
  validates :institution, presence: true
  
  delegate :name, :iclevel_description, :control_description, :sector_description, to: :institution, allow_nil: true
  delegate :firstname, :lastname, :formal_firstname, :grad_year, to: :participant
  
  Stages = %w[interested applied planning enrolled current graduated]
  
  attr_accessor :institution_name

  after_save :update_filter_cache
  after_destroy :update_filter_cache

  belongs_to :institution

  # Updates the participant filter cache
  def update_filter_cache
    participant.save
  end

  # Returns true if this application represents the college that the student is actually attending.
  def attending?
    institution_id == participant.try(:college_attending_id)
  end
  
  def applied?
    !date_applied.nil?
  end
  
  # Returns an array of the most commonly selected institution codes. Specify a number to limit.
  # Default is 10.
  def self.top_institutions(limit = 10)
		return @top_institutions[limit] if @top_institutions && @top_institutions[limit]
		@top_institutions ||= []
		@top_institutions[limit] = []
    raw = CollegeApplication
      .group(:institution_id)
      .select("institution_id, COUNT(institution_id) AS count")
      .limit(limit)
      .order("count DESC")
		raw.each do |college_application|
			i = college_application.institution
      next if i.nil?
			i.count = college_application.count
			@top_institutions[limit] << i
		end
		@top_institutions[limit].compact
  end

	# Determines the columns that are exported into xlsx pacakages. Includes most model columns
	# plus some extra attributes defined by methods.
	def self.xlsx_columns
		columns = []
    columns << [:lastname, :formal_firstname, :grad_year, :name]
		columns << self.column_names.map { |c| c = c.to_sym }
		remove_columns = [:customer_id]
		columns = columns.flatten - remove_columns
	end
  
end
