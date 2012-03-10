class CreateScholarships < ActiveRecord::Migration
  def self.up
    create_table :scholarships do |t|
      t.string :title
      t.string :organization_name
      t.text :description
      t.decimal :default_amount

      t.timestamps
    end
  end

  def self.down
    drop_table :scholarships
  end
end
