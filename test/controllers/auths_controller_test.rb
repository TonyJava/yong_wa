require 'test_helper'

class AuthsControllerTest < ActionController::TestCase
  test "should get send_captcha" do
    get :send_captcha
    assert_response :success
  end

  test "should get check_captcha" do
    get :check_captcha
    assert_response :success
  end

  test "should get register" do
    get :register
    assert_response :success
  end

  test "should get check_device" do
    get :check_device
    assert_response :success
  end

  test "should get login" do
    get :login
    assert_response :success
  end

  test "should get reset_password" do
    get :reset_password
    assert_response :success
  end

end
