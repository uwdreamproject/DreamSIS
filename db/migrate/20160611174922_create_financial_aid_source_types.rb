class CreateFinancialAidSourceTypes < ActiveRecord::Migration  
  def up
    create_table :financial_aid_source_types do |t|
      t.string :name
      t.string :category

      t.timestamps
    end

    FinancialAidSourceType.create name: "Federal Pell Grant", category: "grant"
    FinancialAidSourceType.create name: "Federal Supplemental Education Opportunity Grant", category: "grant"
    FinancialAidSourceType.create name: "College Bound Scholarship", category: "grant"
    FinancialAidSourceType.create name: "State Need/LEAP", category: "grant"
    FinancialAidSourceType.create name: "University Grant", category: "grant"
    FinancialAidSourceType.create name: "13th Year Promise", category: "grant"
    FinancialAidSourceType.create name: "Cougar Commitment", category: "grant"
    FinancialAidSourceType.create name: "Tuition Exemption", category: "grant"
    FinancialAidSourceType.create name: "State Work Study", category: "work_study"
    FinancialAidSourceType.create name: "Federal Work Study", category: "work_study"
    FinancialAidSourceType.create name: "University Scholarship", category: "grant"
    FinancialAidSourceType.create name: "Outside Scholarship (On Award)", category: "grant"
    FinancialAidSourceType.create name: "Outside Scholarship (Not on Award)", category: "grant"
    FinancialAidSourceType.create name: "Athletic Scholarship", category: "grant"
    FinancialAidSourceType.create name: "Federal Direct Subsidized (Stafford) Loan", category: "loan"
    FinancialAidSourceType.create name: "Federal Direct Unsubsidized (Stafford) Loan", category: "loan"
    FinancialAidSourceType.create name: "Federal Perkins Loan", category: "loan"
    FinancialAidSourceType.create name: "Federal Direct Parent PLUS Loan", category: "loan"
  end
  
  def down
    drop_table :financial_aid_source_types
  end
end
