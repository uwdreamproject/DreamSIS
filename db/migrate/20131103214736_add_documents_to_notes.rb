class AddDocumentsToNotes < ActiveRecord::Migration
  def self.up
    change_table :notes do |t|
      t.has_attached_file :document
    end
  end

  def self.down
    drop_attached_file :notes, :document
  end
end
