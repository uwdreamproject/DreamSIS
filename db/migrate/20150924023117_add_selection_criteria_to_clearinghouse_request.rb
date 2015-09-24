class AddSelectionCriteriaToClearinghouseRequest < ActiveRecord::Migration
  def change
    add_column :clearinghouse_requests, :selection_criteria, :text
  end
end
