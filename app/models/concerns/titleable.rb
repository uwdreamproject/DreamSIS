module Titleable
  extend ActiveSupport::Concern

  def to_title
    return title if respond_to?(:title)
    return name if respond_to?(:name)
    nil
  end
  
end
