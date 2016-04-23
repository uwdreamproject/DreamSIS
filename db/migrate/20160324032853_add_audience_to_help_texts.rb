class AddAudienceToHelpTexts < ActiveRecord::Migration
  def change
    add_column :help_texts, :audience, :string
  end
end
