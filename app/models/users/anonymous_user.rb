# An AnonymousUser is used for certain cases where we don't require a login but we need to track a session. For example, when RSVPing for an event.
class AnonymousUser < User
  
  # Creates a new user based on the auth data passed from OmniAuth.
  def self.create_random
    u = create! do |user|
      user.customer_id = Customer.current_customer.id
      user.login = "AnonymousUser" + Time.now.to_i.to_s + rand(10000).to_s
      user.person = Person.create!
    end
  end
  
  # Always returns nil. You can never authenticate against an AnonyousUser.
  def self.authenticate(login, password)
    nil
  end
  
  # Always returns nil. You can never authenticate against an AnonyousUser.
  def self.find(*attrs)
    nil
  end
  
  def fullname(options = {})
    person.nil? ? "Anonymous" : (person.fullname(options).nil? ? "Anonymous" : person.fullname(options))
  end
  
  # Always returns false. Anonymous users can never be admins.
  def admin?
    false
  end
  
  
end
