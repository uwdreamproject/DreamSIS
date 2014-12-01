class PubcookieUser < User

  # after_create :attach_person_record // we do this manually in the authenticate method below, instead.

  # Authenticates a user by their login name without a password.  Returns the user if found.  
  # If we don't find a user record, we create one. If we can't find a valid person in the Person
  # resource, then return false.
  def self.authenticate(uwnetid, password = nil, require_identity = nil, attach_mentor_record = true)
    uwnetid = uwnetid.to_s.match(/^(\w+)(@.+)?$/).try(:[], 1) # strip out the '@uw.edu' if someone tries that
    return false if uwnetid.nil?
    u = self.find_by_login uwnetid
    if u.nil?
      pr = PersonResource.find(uwnetid) rescue nil
      return false if pr.nil?
      u = PubcookieUser.create :login => uwnetid
      if attach_mentor_record
        u.attach_person_record 
      else
        u.person = Person.create
        u.save
      end
    end
    u
  end
  
  def attach_person_record
    p = Mentor.find_by_uw_net_id(login)
    if p
      update_attribute(:person_id, p.id)
      return true
    else
      pr = PersonResource.find(login)
      if pr
        p = Mentor.create(
          :reg_id         => pr.UWRegID,
          :firstname      => pr.RegisteredFirstMiddleName,
          :lastname       => pr.RegisteredSurname
        )
        if p.valid?
          update_attribute(:person_id, p.id)
          p.update_resource_cache!(true)
          return true
        elsif p.errors.on(:reg_id)
          existing_p = Mentor.find_by_reg_id(p.reg_id)
          if existing_p
            update_attribute(:person_id, existing_p.id)
            return true
          end
        else
          return false
        end
      else
        self.errors.add_to_base "Could not find a valid person resource."
        return false
      end
    end
    false
  end

  protected

  # Pubcookie users do not store passwords in our DB because weblogin contains all authentication data
  def password_required?
    false
  end

end
