require 'change_logged'

module ActiveRecord
	class Base
		
		def to_title
			return title if respond_to?(:title)
			return name if respond_to?(:name)
			nil
		end
		
	end
end