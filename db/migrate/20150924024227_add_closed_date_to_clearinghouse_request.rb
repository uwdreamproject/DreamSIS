class AddClosedDateToClearinghouseRequest < ActiveRecord::Migration
  def change
    add_column :clearinghouse_requests, :closed_at, :datetime
  end
end
