class AddHintToHelpText < ActiveRecord::Migration
  def change
    add_column :help_texts, :hint, :text
  end
end
