require 'change_logged'
require 'customer_scoped' if ActiveRecord::Base.connection.tables.include?("customers")

module ActiveRecord
	class Base
		
		def to_title
			return title if respond_to?(:title)
			return name if respond_to?(:name)
			nil
		end
		
	end
end

module ActionController
	class Request
		
		def html?
			template_format == :html
		end
	
	end
end