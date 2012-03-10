class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :login
      t.string :crypted_password
      t.string :salt
      t.string :remember_token
      t.string :remember_token_expires_at
      t.string :identity_url
      t.string :type
      t.integer :person_id

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
