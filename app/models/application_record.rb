class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  
  include ChangeLoggable
  include Titleable
  include Unpaginatable
  
end
