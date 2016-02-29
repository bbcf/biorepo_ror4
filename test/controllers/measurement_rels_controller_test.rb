require 'test_helper'

class MeasurementRelsControllerTest < ActionController::TestCase
  setup do
    @measurement_rel = measurement_rels(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:measurement_rels)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create measurement_rel" do
    assert_difference('MeasurementRel.count') do
      post :create, measurement_rel: {  }
    end

    assert_redirected_to measurement_rel_path(assigns(:measurement_rel))
  end

  test "should show measurement_rel" do
    get :show, id: @measurement_rel
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @measurement_rel
    assert_response :success
  end

  test "should update measurement_rel" do
    patch :update, id: @measurement_rel, measurement_rel: {  }
    assert_redirected_to measurement_rel_path(assigns(:measurement_rel))
  end

  test "should destroy measurement_rel" do
    assert_difference('MeasurementRel.count', -1) do
      delete :destroy, id: @measurement_rel
    end

    assert_redirected_to measurement_rels_path
  end
end
