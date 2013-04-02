class CreateCustomers < ActiveRecord::Migration
  def self.up
    create_table :customers do |t|
      t.string :name
      t.integer :program_id
      t.integer :parent_customer_id
      t.boolean :link_to_uw
      t.boolean :term_system
      t.text :risk_form_content
      t.boolean :require_background_checks
      
      t.string :mentor_label
      t.string :lead_label
      t.string :participant_label
      t.string :workbook_label
      t.string :intake_survey_label
      

      t.timestamps
    end
  end

  def self.down
    drop_table :customers
  end
end
