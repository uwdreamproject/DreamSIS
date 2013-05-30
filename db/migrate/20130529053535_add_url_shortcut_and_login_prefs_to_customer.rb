class AddUrlShortcutAndLoginPrefsToCustomer < ActiveRecord::Migration
  def self.up
    add_column :customers, :url_shortcut, :string
    add_column :customers, :allowable_login_methods, :text
  end

  def self.down
    remove_column :customers, :allowable_login_methods
    remove_column :customers, :url_shortcut
  end
end
