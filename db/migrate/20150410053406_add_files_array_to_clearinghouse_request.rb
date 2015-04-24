class AddFilesArrayToClearinghouseRequest < ActiveRecord::Migration
  def change
    add_column :clearinghouse_requests, :filenames, :text
  end
end
