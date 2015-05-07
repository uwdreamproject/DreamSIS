class AddClearinghouseRecordFoundToPeople < ActiveRecord::Migration
  def change
    unless column_exists? :people, :clearinghouse_record_found
      add_column :people, :clearinghouse_record_found, :boolean
    end
  end
end
