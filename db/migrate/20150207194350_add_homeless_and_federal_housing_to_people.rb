class AddHomelessAndFederalHousingToPeople < ActiveRecord::Migration
  def change
    add_column :people, :homeless, :boolean
    add_column :people, :subsidized_housing, :boolean
    add_column :people, :immigrant, :boolean
  end
end
