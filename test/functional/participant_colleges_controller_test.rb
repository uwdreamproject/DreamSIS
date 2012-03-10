require 'test_helper'

class ParticipantCollegesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:participant_colleges)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_participant_college
    assert_difference('ParticipantCollege.count') do
      post :create, :participant_college => { }
    end

    assert_redirected_to participant_college_path(assigns(:participant_college))
  end

  def test_should_show_participant_college
    get :show, :id => participant_colleges(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => participant_colleges(:one).id
    assert_response :success
  end

  def test_should_update_participant_college
    put :update, :id => participant_colleges(:one).id, :participant_college => { }
    assert_redirected_to participant_college_path(assigns(:participant_college))
  end

  def test_should_destroy_participant_college
    assert_difference('ParticipantCollege.count', -1) do
      delete :destroy, :id => participant_colleges(:one).id
    end

    assert_redirected_to participant_colleges_path
  end
end
