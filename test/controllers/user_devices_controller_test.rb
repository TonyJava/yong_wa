require 'test_helper'

class UserDevicesControllerTest < ActionController::TestCase
  setup do
    @user_device = user_devices(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:user_devices)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user_device" do
    assert_difference('UserDevice.count') do
      post :create, user_device: { device_id: @user_device.device_id, user_id: @user_device.user_id }
    end

    assert_redirected_to user_device_path(assigns(:user_device))
  end

  test "should show user_device" do
    get :show, id: @user_device
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @user_device
    assert_response :success
  end

  test "should update user_device" do
    patch :update, id: @user_device, user_device: { device_id: @user_device.device_id, user_id: @user_device.user_id }
    assert_redirected_to user_device_path(assigns(:user_device))
  end

  test "should destroy user_device" do
    assert_difference('UserDevice.count', -1) do
      delete :destroy, id: @user_device
    end

    assert_redirected_to user_devices_path
  end
end
