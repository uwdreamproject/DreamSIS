class AddVanDriverFieldsToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :van_driver_training_completed_at, :datetime
    add_column :people, :husky_card_rfid, :string
  end

  def self.down
    remove_column :people, :husky_card_rfid
    remove_column :people, :van_driver_training_completed_at
  end
end
