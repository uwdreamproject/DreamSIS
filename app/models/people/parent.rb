# Models a parent, legal guardian, or other adult advocate of a student in the system. This model is linked to a student through +child_id+. 
class Parent < Person
  validates_presence_of :lastname, :firstname
  validates_presence_of :child_id

  belongs_to :child  
  
end