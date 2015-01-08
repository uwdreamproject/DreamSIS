require 'digest/sha1'
class User < ActiveRecord::Base
  belongs_to :person
  validates_presence_of :login
  validates_uniqueness_of :uid, :scope => [:provider]
  attr_accessible :login, :email, :password, :password_confirmation, :identity_url, :person_attributes
  default_scope :order => 'login'
  alias_attribute :username, :login
  delegate :email, :to => :person
  
  # Pulls the current user out of Thread.current. We try to avoid this when possible, but sometimes we need 
  # to access the current user in a model (e.g., to check EmailQueue#messages_waiting?).
  def self.current_user
    Thread.current['user']
  end

  def person_attributes=(person_attributes)
    if person.nil?
      self.person = Person.new(person_attributes)
    else
      self.person.update_attributes(person_attributes)
    end
  end

  # Returns the associated person's fullname, or +login+ if there's no person record.
  def fullname(options = {})
    person.nil? ? login : (person.fullname(options).blank? ? login : person.fullname(options))
  end
  
  # Returns a username string useful for error reporting by concatenating the user's login and the
  # tenant name, like "test1/bobloblaw@facebook"
  def error_username
    Apartment::Tenant.current.to_s + "/" + login
  end

  # Returns a user ID useful for error reporting by concatenating the user's ID and the
  # tenant name, like "test1/17"
  def error_id
    Apartment::Tenant.current.to_s + "/" + id.to_s
  end
    
  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil. Note that this method is
  # case-insensitive, so "Mike" and "mike" will both return the same user object.
  def self.authenticate(login, password)
    logger.info "User.authenticate: #{login}, ******"
    u = find_by_login(login) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Creates a new user based on the auth data passed from OmniAuth.
  def self.create_with_omniauth(auth)
    u = create! do |user|
      # user.customer_id = Customer.current_customer.id
      user.provider = auth["provider"]
      user.uid = auth["uid"]
      user.login = (auth["info"]["nickname"] || auth["uid"]) + "@" + auth["provider"]
      user.person = Person.create!
    end
    # u.person.update_attribute :customer_id, Customer.current_customer.id
    u.update_from_provider!(auth)
    return u
  end

  # Updates this user's information based on the information in the auth data passed from OmniAuth.
  def update_from_provider!(auth)
    return nil if auth["extra"]["raw_info"]["updated_at"] && Time.parse(auth["extra"]["raw_info"]["updated_at"]) < person.resource_cache_updated_at
    person.update_attributes({
      :display_name => auth["info"]["name"],
      :firstname => auth["info"]["first_name"],
      :lastname => auth["info"]["last_name"],
      :email => auth["info"]["email"],
      :avatar_image_url => auth["info"]["image"] || auth["extra"]["raw_info"]["profile_image_url_https"],
      :resource_cache_updated_at => Time.now
    })
  end
  
  # Only update the avatar image from the OmniAuth data.
  def update_avatar_from_provider!(auth)
    person.update_attributes({
      :avatar_image_url => auth["info"]["image"] || auth["extra"]["raw_info"]["profile_image_url_https"],
    }) if person
  end
  
  # Returns all User records with the same provider and UID combination. Useful for switching to another customer identity.
  def identities
    User.where(:provider => provider, :uid => uid)
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def can_view?(object)
    return true if admin?
    return false unless person
    person.can_view?(object)
  end
  
  def can_edit?(object)
    return true if admin?
    return false unless person
    person.can_view?(object)
  end

  # Returns true if this User's Person is an external user (either a Volunteer or a Student).
  # It also will default to returning true if there is no person record attached to this User yet.
  def external?
    return true unless person
    (person.is_a?(Volunteer) || person.is_a?(Student)) ? true : false
  end

  protected
  
  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
    self.crypted_password = encrypt(password)
  end
  
  def password_required?
    crypted_password.blank? || !password.blank?
  end

end
