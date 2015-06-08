# For some reason some tenants have lost this column, so this adds it back if needed.
class AddDeletedAtToMentorTermsIfNeeded < ActiveRecord::Migration
  def change
    unless column_exists? :mentor_terms, :deleted_at
      add_column :mentor_terms, :deleted_at, :datetime
    end
  end
end
