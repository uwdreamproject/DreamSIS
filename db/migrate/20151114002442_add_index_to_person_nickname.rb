class AddIndexToPersonNickname < ActiveRecord::Migration
  def change
    add_index :people, :nickname
    add_index :people, :middlename
    add_index :people, :type
  end
end