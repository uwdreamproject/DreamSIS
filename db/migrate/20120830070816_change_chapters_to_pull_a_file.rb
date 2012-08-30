class ChangeChaptersToPullAFile < ActiveRecord::Migration
  def self.up
    remove_column :trainings, :chapters
    add_column :trainings, :chapters_url, :string
  end

  def self.down
    remove_column :trainings, :chapters_url
    add_column :trainings, :chapters, :text
  end
end
