require 'test_helper'

class FinancialAidPackagesControllerTest < ActionController::TestCase
  setup do
    @financial_aid_package = financial_aid_packages(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:financial_aid_packages)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create financial_aid_package" do
    assert_difference('FinancialAidPackage.count') do
      post :create, financial_aid_package: {  }
    end

    assert_redirected_to financial_aid_package_path(assigns(:financial_aid_package))
  end

  test "should show financial_aid_package" do
    get :show, id: @financial_aid_package
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @financial_aid_package
    assert_response :success
  end

  test "should update financial_aid_package" do
    put :update, id: @financial_aid_package, financial_aid_package: {  }
    assert_redirected_to financial_aid_package_path(assigns(:financial_aid_package))
  end

  test "should destroy financial_aid_package" do
    assert_difference('FinancialAidPackage.count', -1) do
      delete :destroy, id: @financial_aid_package
    end

    assert_redirected_to financial_aid_packages_path
  end
end
