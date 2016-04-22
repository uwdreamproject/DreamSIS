class AddAllowParticipantLoginToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :allow_participant_login, :boolean
  end
end
