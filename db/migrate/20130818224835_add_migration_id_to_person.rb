class AddMigrationIdToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :migration_id, :string
  end

  def self.down
    remove_column :people, :migration_id
  end
end
