class AddDepositSentAtToCollegeApplications < ActiveRecord::Migration
  def self.up
    add_column :college_applications, :date_deposit_sent, :datetime
  end

  def self.down
    remove_column :college_applications, :date_deposit_sent
  end
end
