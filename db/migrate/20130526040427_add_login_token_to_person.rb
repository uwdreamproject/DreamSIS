class AddLoginTokenToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :login_token, :string
    add_column :people, :login_token_expires_at, :datetime
  end

  def self.down
    remove_column :people, :login_token_expires_at
    remove_column :people, :login_token
  end
end
