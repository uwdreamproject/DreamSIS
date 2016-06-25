class FinancialAidPackage < ActiveRecord::Base
  attr_accessible :academic_year, :cost_of_attendance, :cost_of_attendance_source, :expected_family_contribution, :college_application_id, :participant_id
  
  validates_presence_of :academic_year, :participant_id, :college_application_id
  validates_uniqueness_of :participant_id, scope: [:academic_year, :college_application_id]
  
  belongs_to :participant
  belongs_to :college_application
  has_many :sources, class_name: FinancialAidSource, foreign_key: :package_id
  
  monetize :cost_of_attendance_cents, :expected_family_contribution_cents, :grants_total_cents, :loans_total_cents, :work_study_total_cents, :gap_total_cents
  
  before_validation :calculate_totals

  has_many :notes, :as => :notable, :conditions => "document_file_name IS NULL"
  has_many :documents, :as => :notable, :class_name => "Note", :conditions => "document_file_name IS NOT NULL AND title IS NOT NULL"
  
  BREAKDOWN_TITLES = {
    expected_family_contribution: "EFC",
    grants: "Grants & Scholarships"
  }
  
  # Returns a printable string of the academic year in full form (e.g., "2016-2017").
  def academic_year_range
    "" + academic_year.to_s + "-" + (academic_year+1).to_s
  end

  # Provides a hash of the current totals and percentage breakdown for the various categories of costs.
  def breakdown(money_format = { no_cents: true })
    breakdown = {
      expected_family_contribution: {
        amount_formatted: _format(expected_family_contribution, money_format),
        amount: expected_family_contribution,
        amount_raw: expected_family_contribution.to_i,
        percentage: percentage(:expected_family_contribution)
      }
    }
    for category in %w[grants loans work_study gap]
      amount = total_amount(category + "_total")
      breakdown[category.to_sym] = {
        amount_formatted: _format(amount, money_format),
        amount: amount,
        amount_raw: amount.to_i,
        percentage: percentage(category + "_total")
      }
    end
    return breakdown
  end
  
  # Returns the percentage share of a certain category of costs.
  def percentage(category)
    return 0.0 if category.to_s != "gap" && try(category).nil?
    try(category) / cost_of_attendance * 100
  end
  
  # Returns the total sum of a certain category of costs.
  def total_amount(category)
    return Money.new(0) if category.to_s != "gap" && try(category).nil?
    try(category)
  end

  def sources_in_category(category)
    sources.where(financial_aid_source_types: { category: category.singularize}).joins(:source_type)
  end
  
  private

  # Calculates the total amounts for the various cost categories.
  def calculate_totals
    self.grants_total = calculate_category_total("grant")
    self.loans_total = calculate_category_total("loan")
    self.work_study_total = calculate_category_total("work_study")
    self.gap_total = calculate_gap
    return breakdown
  end
  
  def calculate_category_total(category)
    Money.new(sources_in_category(category).sum(:amount_cents))
  end
  
  def calculate_gap
    cost_of_attendance - expected_family_contribution - [grants_total, loans_total, work_study_total].compact.sum
  end

  # Format the Money object as requested, or return the original money object otherwise.
  def _format(money, format_options)
    return money unless format_options
    return money unless money.respond_to?(:to_money)
    money.format(format_options)
  end
  
end
