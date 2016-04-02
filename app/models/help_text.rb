class HelpText < ActiveRecord::Base
  attr_accessible :attribute_name, :instructions, :object_class, :title, :hint, :audience
  validates_uniqueness_of :attribute_name, :scope => [:object_class, :audience]
  
  def self.for(object_class, attribute_name, audience = nil)
    HelpText.for_object_class(object_class.to_s, audience)[attribute_name.to_s] 
  end

  def self.for_object_class(object_class, audience = nil)
    if audience.nil?
      Hash[HelpText.where(object_class: object_class.to_s).map{ |ht| [ht.attribute_name.to_s, ht] }]
    else
      Hash[HelpText.where(object_class: object_class.to_s, audience: audience.to_s).map{ |ht| [ht.attribute_name.to_s, ht] }]
    end
  end

end
