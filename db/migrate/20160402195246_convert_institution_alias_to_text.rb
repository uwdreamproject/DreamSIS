class ConvertInstitutionAliasToText < ActiveRecord::Migration
  def up
    change_column :institutions, :ialias, :text, limit: nil
  end

  def down
    change_column :institutions, :ialias, :string
  end
end
