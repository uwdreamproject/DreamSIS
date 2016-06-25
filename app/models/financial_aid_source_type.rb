class FinancialAidSourceType < ActiveRecord::Base
  attr_accessible :category, :name
  
  has_many :sources, class_name: FinancialAidSource
  has_many :packages, through: :sources
  
  validates_presence_of :category, :name
  
  # Returns a hash of all source types, suitable for use with +grouped_options_for_select+, 
  # using categories as the keys.
  def self.grouped_by_category
    results = {}
    all.group_by(&:category).each do |category, source_types|
      key = FinancialAidPackage::BREAKDOWN_TITLES[category.pluralize.to_sym] || category.titleize
      results[key] = source_types.collect{|t| [t.name, t.id]}
    end
    results
  end
  
end
