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

  delegate :fullname, :high_school_name, to: :participant
  delegate :name, :iclevel_description, :control_description, :sector_description, to: :college_application

  acts_as_xlsx
  
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
  
  def self.xlsx_columns
    columns = [
      :id, :participant_id, :fullname, :high_school_name, :academic_year,
      :name, :iclevel_description, :control_description, :sector_description, :cost_of_attendance_USD,
      :expected_family_contribution_USD, :grants_total_USD, :loans_total_USD, :work_study_total_USD, :gap_total_USD
    ]
    columns << FinancialAidSourceType.pluck(:name).collect{ |t| "Source: " + t }
    columns.flatten
  end

  def method_missing(method_name, *args)
    if m = method_name.to_s.match(/\ASource: (.+)\Z/)
      source_type = FinancialAidSourceType.find_by_name(m[1])
      return super unless source_type
      total = sources.where(source_type_id: source_type).collect(&:amount).sum
      total.to_i
    elsif m = method_name.to_s.end_with?("_USD")
      category = method_name.to_s.split("_USD").first rescue nil
      return super unless %w[expected_family_contribution grants_total loans_total work_study_total gap_total cost_of_attendance].include?(category)
      total.to_i
    else
      super(method_name, *args)
    end
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
    return money unless money.is_a?(Money)
    money.format(format_options)
  end
  
end
