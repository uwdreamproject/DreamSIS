require 'test_helper'

class FinancialAidSourcesControllerTest < ActionController::TestCase
  setup do
    @financial_aid_source = financial_aid_sources(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:financial_aid_sources)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create financial_aid_source" do
    assert_difference('FinancialAidSource.count') do
      post :create, financial_aid_source: {  }
    end

    assert_redirected_to financial_aid_source_path(assigns(:financial_aid_source))
  end

  test "should show financial_aid_source" do
    get :show, id: @financial_aid_source
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @financial_aid_source
    assert_response :success
  end

  test "should update financial_aid_source" do
    put :update, id: @financial_aid_source, financial_aid_source: {  }
    assert_redirected_to financial_aid_source_path(assigns(:financial_aid_source))
  end

  test "should destroy financial_aid_source" do
    assert_difference('FinancialAidSource.count', -1) do
      delete :destroy, id: @financial_aid_source
    end

    assert_redirected_to financial_aid_sources_path
  end
end
