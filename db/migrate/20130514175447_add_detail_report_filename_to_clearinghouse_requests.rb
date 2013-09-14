class AddDetailReportFilenameToClearinghouseRequests < ActiveRecord::Migration
  def self.up
    add_column :clearinghouse_requests, :detail_report_filename, :string
  end

  def self.down
    remove_column :clearinghouse_requests, :detail_report_filename
  end
end
