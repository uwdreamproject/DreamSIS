class PubcookieUser < User

  after_create :attach_person_record

  # Authenticates a user by their login name without a password.  Returns the user if found.  
  # If we don't find a user record, we create one. If we can't find a valid person in the Person
  # resource, then return false.
  def self.authenticate(uwnetid, password = nil, require_identity = nil)
    uwnetid = uwnetid.match(/^(\w+)(@.+)?$/).try(:[], 1) # strip out the '@uw.edu' if someone tries that
    return false if uwnetid.nil?
    u = self.find_by_login uwnetid
    if u.nil?
      pr = PersonResource.find_by_uwnetid(uwnetid)
      return false if pr.nil?
      u = PubcookieUser.create :login => uwnetid
    end
    u
  end
  
  protected

  def attach_person_record
    p = Mentor.find_by_uw_net_id(login)
    if p
      update_attribute(:person_id, p.id)
      return true
    else
      pr = PersonResource.find_by_uwnetid(login)
      if pr
        p = Mentor.create(
          :reg_id         => pr.attributes["UWRegID"],
          :firstname      => pr.attributes["RegisteredFirstMiddleName"],
          :lastname       => pr.attributes["RegisteredSurname"]
        )
        update_attribute(:person_id, p.id)
        p.update_resource_cache!(true)
        return true
      else
        self.errors.add_to_base "Could not find a valid person resource."
        return false
      end
    end
    false
  end

  # Pubcookie users do not store passwords in our DB because weblogin contains all authentication data
  def password_required?
    false
  end

end
