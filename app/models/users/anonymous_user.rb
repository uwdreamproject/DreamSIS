# An AnonymousUser is used for certain cases where we don't require a login but we need to track a session. For example, when RSVPing for an event.
class AnonymousUser < User
  
  # Creates a new user based on the auth data passed from OmniAuth.
  def self.create_random
    u = create! do |user|
      user.login = "AnonymousUser" + Time.now.to_i.to_s + rand(10000).to_s
      user.person = Person.create!
    end
  end
  
  def self.authenticate(login, password)
    nil
  end
  
  def self.find(*attrs)
    nil
  end
  
  def fullname
    person.nil? ? "Anonymous" : (person.fullname.nil? ? "Anonymous" : person.fullname)
  end
  
  
end