class AddTagsToMentorTermGroups < ActiveRecord::Migration
  def change
    add_column :mentor_terms, :steering, :boolean
    add_column :mentor_terms, :ccra, :boolean
    add_column :mentor_terms, :planning, :boolean
  end
end
