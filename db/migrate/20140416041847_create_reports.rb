class CreateReports < ActiveRecord::Migration
  def self.up
		create_table :reports, :force => true do |t|
			t.string :key
		  t.text :object_ids
			t.string :format
			t.string :type
			t.string :file_path
			t.string :status
			t.integer :customer_id
			t.datetime :generated_at
		  t.timestamps
		end
  end

  def self.down
		drop_table :reports
  end
end