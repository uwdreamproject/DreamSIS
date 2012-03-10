require 'test_helper'

class ParticipantsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:participants)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_participant
    assert_difference('Participant.count') do
      post :create, :participant => { }
    end

    assert_redirected_to participant_path(assigns(:participant))
  end

  def test_should_show_participant
    get :show, :id => participants(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => participants(:one).id
    assert_response :success
  end

  def test_should_update_participant
    put :update, :id => participants(:one).id, :participant => { }
    assert_redirected_to participant_path(assigns(:participant))
  end

  def test_should_destroy_participant
    assert_difference('Participant.count', -1) do
      delete :destroy, :id => participants(:one).id
    end

    assert_redirected_to participants_path
  end
end
