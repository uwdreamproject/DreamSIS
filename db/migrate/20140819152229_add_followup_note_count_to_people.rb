class AddFollowupNoteCountToPeople < ActiveRecord::Migration
  def change
    add_column :people, :followup_note_count, :integer
  end
end
