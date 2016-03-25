class HelpText < ActiveRecord::Base
  attr_accessible :attribute_name, :instructions, :object_class, :title, :hint
  validates_uniqueness_of :attribute_name, :scope => [:object_class, :audience]
  
  def self.for(object_class, attribute_name)
    HelpText.for_object_class(object_class.to_s)[attribute_name.to_s] 
  end

  def self.for(object_class, attribute_name, audience)
    HelpText.for_object_class(object_class.to_s, audience)[attribute_name.to_s] 
  end
  
  def self.for_object_class(object_class)
    Hash[HelpText.where(object_class: object_class.to_s).map{ |ht| [ht.attribute_name.to_s, ht] }]
  end

  def self.for_object_class(object_class, audience)
    Hash[HelpText.where(object_class: object_class.to_s, audience: audience.to_s).map{ |ht| [ht.attribute_name.to_s, ht] }]
  end

end
