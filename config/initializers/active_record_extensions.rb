require 'change_logged'
require 'customer_scoped' if ActiveRecord::Base.connection.tables.include?("customers")