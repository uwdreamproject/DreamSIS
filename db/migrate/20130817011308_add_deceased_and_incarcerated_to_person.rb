class AddDeceasedAndIncarceratedToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :deceased, :boolean
    add_column :people, :incarcerated, :boolean
  end

  def self.down
    remove_column :people, :incarcerated
    remove_column :people, :deceased
  end
end
