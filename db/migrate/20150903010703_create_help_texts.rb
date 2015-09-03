class CreateHelpTexts < ActiveRecord::Migration
  def change
    create_table :help_texts do |t|
      t.string :object_class
      t.string :attribute_name
      t.string :title
      t.text :instructions

      t.timestamps
    end
  end
end
