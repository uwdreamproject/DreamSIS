class CreateMultitenantProxies < ActiveRecord::Migration
  def change
    create_table :multitenant_proxies do |t|
      t.string :proxyable_type
      t.integer :proxyable_id
      t.string :role
      t.integer :other_customer_id
      t.integer :other_id

      t.timestamps
    end
  end
end
