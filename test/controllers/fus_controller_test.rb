require 'test_helper'

class FusControllerTest < ActionController::TestCase
  setup do
    @fu = fus(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:fus)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create fu" do
    assert_difference('Fu.count') do
      post :create, fu: {  }
    end

    assert_redirected_to fu_path(assigns(:fu))
  end

  test "should show fu" do
    get :show, id: @fu
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @fu
    assert_response :success
  end

  test "should update fu" do
    patch :update, id: @fu, fu: {  }
    assert_redirected_to fu_path(assigns(:fu))
  end

  test "should destroy fu" do
    assert_difference('Fu.count', -1) do
      delete :destroy, id: @fu
    end

    assert_redirected_to fus_path
  end
end
