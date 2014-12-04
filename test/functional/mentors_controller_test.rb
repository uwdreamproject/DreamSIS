require 'test_helper'

class MentorsControllerTest < ActionController::TestCase

  def setup
    login_as :admin    
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:mentors)
  end

  test "should get edit" do
    get :edit, {'id' => "4"}, {'user_id' => 5}
    assert_response :success
    assert_not_nil assigns(:mentors)
  end

  
end
