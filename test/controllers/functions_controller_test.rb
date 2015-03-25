require 'test_helper'

class FunctionsControllerTest < ActionController::TestCase
  test "should get show_device" do
    get :show_device
    assert_response :success
  end

  test "should get update_device" do
    get :update_device
    assert_response :success
  end

  test "should get show_history" do
    get :show_history
    assert_response :success
  end

  test "should get send_command" do
    get :send_command
    assert_response :success
  end

end
