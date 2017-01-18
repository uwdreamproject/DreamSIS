module Unpaginatable
  extend ActiveSupport::Concern
  
  def unpaginate
    self.limit(100000).offset(0)
  end
  
end
