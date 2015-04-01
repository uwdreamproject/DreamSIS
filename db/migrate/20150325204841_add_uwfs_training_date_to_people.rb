class AddUwfsTrainingDateToPeople < ActiveRecord::Migration
  def change
    add_column :people, :uwfs_training_date, :datetime
    add_column :customers, :driver_training_validity_length, :integer
  end
end
