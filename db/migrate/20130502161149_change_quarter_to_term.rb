class ChangeQuarterToTerm < ActiveRecord::Migration
  def self.up
    rename_table :quarters, :terms
    add_column :terms, :title, :string
    rename_table :mentor_quarter_groups, :mentor_term_groups
    rename_table :mentor_quarters, :mentor_terms
    rename_column :mentor_term_groups, :quarter_id, :term_id
    rename_column :mentor_term_groups, :mentor_quarters_count, :mentor_terms_count
    rename_column :mentor_terms, :mentor_quarter_group_id, :mentor_term_group_id
  end

  def self.down
    rename_column :mentor_terms, :mentor_term_group_id, :mentor_quarter_group_id
    rename_column :mentor_term_groups, :mentor_terms_count, :mentor_quarters_count
    rename_column :mentor_term_groups, :term_id, :quarter_id
    rename_table :mentor_terms, :mentor_quarters
    rename_table :mentor_term_groups, :mentor_quarter_groups
    remove_column :terms, :title
    rename_table :terms, :quarters
  end
end