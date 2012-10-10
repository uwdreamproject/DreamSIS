class AddStylesheetUrlToTrainings < ActiveRecord::Migration
  def self.up
    add_column :trainings, :stylesheet_url, :string
  end

  def self.down
    remove_column :trainings, :stylesheet_url
  end
end
