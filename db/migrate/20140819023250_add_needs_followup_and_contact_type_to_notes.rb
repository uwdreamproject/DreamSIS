class AddNeedsFollowupAndContactTypeToNotes < ActiveRecord::Migration
  def change
    add_column :notes, :needs_followup, :boolean
    add_column :notes, :contact_type, :string
  end
end
