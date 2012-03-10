class AddBadContactFlagsToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :bad_address, :boolean
    add_column :people, :bad_phone, :boolean
    add_column :people, :bad_email, :boolean
  end

  def self.down
    remove_column :people, :bad_email
    remove_column :people, :bad_phone
    remove_column :people, :bad_address
  end
end
