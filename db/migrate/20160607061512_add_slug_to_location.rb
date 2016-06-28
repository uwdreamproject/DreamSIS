class AddSlugToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :slug, :string
    add_index :locations, :slug, unique: true
  end
end
