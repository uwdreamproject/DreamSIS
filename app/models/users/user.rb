require 'digest/sha1'
class User < ActiveRecord::Base
  belongs_to :person
  
  # model_stamper
  
  # Virtual attribute for the unencrypted password
  # attr_accessor :password

  validates_presence_of     :login
  # validates_presence_of     :password,                   :if => :password_required?
  # validates_presence_of     :password_confirmation,      :if => :password_required?
  # validates_length_of       :password, :within => 6..40, :if => :password_required?
  # validates_confirmation_of :password,                   :if => :password_required?
  # validates_presence_of     :person
  # validates_length_of       :login,    :within => 3..40
  # validates_uniqueness_of   :login, :scope => :type, :case_sensitive => false
  # before_save               :encrypt_password

  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :password, :password_confirmation, :identity_url, :person_attributes

  default_scope :order => 'login'

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
  def fullname
    person.nil? ? login : person.fullname
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
    create! do |user|
      user.provider = auth["provider"]
      user.uid = auth["uid"]
      user.login = (auth["info"]["nickname"] || auth["uid"]) + "@" + auth["provider"]
      user.person = Person.create!
    end
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

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
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
