require 'test_helper'

class AttrValuesControllerTest < ActionController::TestCase
  setup do
    @attr_value = attr_values(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:attr_values)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create attr_value" do
    assert_difference('AttrValue.count') do
      post :create, attr_value: {  }
    end

    assert_redirected_to attr_value_path(assigns(:attr_value))
  end

  test "should show attr_value" do
    get :show, id: @attr_value
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @attr_value
    assert_response :success
  end

  test "should update attr_value" do
    patch :update, id: @attr_value, attr_value: {  }
    assert_redirected_to attr_value_path(assigns(:attr_value))
  end

  test "should destroy attr_value" do
    assert_difference('AttrValue.count', -1) do
      delete :destroy, id: @attr_value
    end

    assert_redirected_to attr_values_path
  end
end
