require 'test_helper'

class HighSchoolsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:high_schools)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_high_school
    assert_difference('HighSchool.count') do
      post :create, :high_school => { }
    end

    assert_redirected_to high_school_path(assigns(:high_school))
  end

  def test_should_show_high_school
    get :show, :id => high_schools(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => high_schools(:one).id
    assert_response :success
  end

  def test_should_update_high_school
    put :update, :id => high_schools(:one).id, :high_school => { }
    assert_redirected_to high_school_path(assigns(:high_school))
  end

  def test_should_destroy_high_school
    assert_difference('HighSchool.count', -1) do
      delete :destroy, :id => high_schools(:one).id
    end

    assert_redirected_to high_schools_path
  end
end
