class ChangeEnglishPrimaryAtHome < ActiveRecord::Migration
  def self.up
    rename_column :people, :english_primary_at_home, :english_not_primary_at_home
  end

  def self.down
    rename_column :people, :english_not_primary_at_home, :english_primary_at_home
  end
end
