require 'test_helper'

class HistoriesControllerTest < ActionController::TestCase
  setup do
    @history = histories(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:histories)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create history" do
    assert_difference('History.count') do
      post :create, history: { data_content: @history.data_content, data_stamp_address: @history.data_stamp_address, data_type: @history.data_type, location_code: @history.location_code, location_type: @history.location_type, time_stamp: @history.time_stamp, user_device_id: @history.user_device_id }
    end

    assert_redirected_to history_path(assigns(:history))
  end

  test "should show history" do
    get :show, id: @history
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @history
    assert_response :success
  end

  test "should update history" do
    patch :update, id: @history, history: { data_content: @history.data_content, data_stamp_address: @history.data_stamp_address, data_type: @history.data_type, location_code: @history.location_code, location_type: @history.location_type, time_stamp: @history.time_stamp, user_device_id: @history.user_device_id }
    assert_redirected_to history_path(assigns(:history))
  end

  test "should destroy history" do
    assert_difference('History.count', -1) do
      delete :destroy, id: @history
    end

    assert_redirected_to histories_path
  end
end
