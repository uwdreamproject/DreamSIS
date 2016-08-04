ENV["Rails.env"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "minitest/reporters"
Minitest::Reporters.use!

class ActiveSupport::TestCase
  fixtures :all

  def setup
    Apartment::Tenant.switch!('test-customer')
    if @request
      @request.host = 'test-customer.test.host'
      login_as(:admin)
    end
  end

  # Add more helper methods to be used by all tests here...
  def login_as(user)
    @request.session[:user_id] = users(user).id
  end
  
end
