class DropMultitenantProxies < ActiveRecord::Migration
  def up
    drop_table :multitenant_proxies
  end
end
