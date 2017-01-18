class FinancialAidSource < ApplicationRecord
  # TODO attr_accessible :amount, :package_id, :scholarship_application_id, :source_type_id
  belongs_to :package, class_name: FinancialAidPackage
  belongs_to :source_type, class_name: FinancialAidSourceType
  belongs_to :scholarship_application
  
  delegate :category, :name, to: :source_type
  delegate :breakdown, to: :package
  validates_presence_of :package_id, :source_type_id
  monetize :amount_cents
  default_scope { includes(:source_type).order("financial_aid_source_types.category") }
  
  after_save -> { package.save }
  after_destroy -> { package.save }
  
end
