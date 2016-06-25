class CreateFinancialAidSources < ActiveRecord::Migration
  def change
    create_table :financial_aid_sources do |t|
      t.integer :package_id
      t.integer :source_type_id
      t.money :amount
      t.integer :scholarship_application_id

      t.timestamps
    end
  end
end
