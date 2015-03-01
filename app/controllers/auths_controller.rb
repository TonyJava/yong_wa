class AuthsController < ApplicationController
  def send_captcha
    #binding.pry
    if User.mobile_format_valid?(params[:mobile])
      captcha = Random.new
      session[:captcha] = captcha.rand(1000..9999)
      binding.pry
      #send captcha

      render :json => {
        msg: "send ok",
        request: "GET/auths/send_captcha",
        code: 10000
      }
    else
      render :json => {
        msg: "send captcha error",
        request: "GET/auts/send_captcha",
        code: 10101
      }    
    end
  end

  def check_captcha
    captcha = params[:captcha]
    binding.pry
    if captcha == session[:captcha]
      render :json => {
        msg: "check success",
        request: "POST/auths/send_captcha",
        code: 10000
      }
    else
      render :json => {
        msg: "captcha code error",
        request: "GET/auths/check_captcha",
        code: 10202
      } 
    end
  end

  def register
    if !User.mobile_format_valid?(params[:mobile])
      render :json => {
        msg: "register code error",
        request: "POST/auths/register",
        code: 10301
      }
    elsif params[:captcha] != session[:captcha]
      render :json => {
        msg: "register code error",
        request: "POST/auths/register",
        code: 10302
      }
    elsif !User.password_format_valid?(params[:password])
      render :json => {
        msg: "register code error",
        request: "POST/auths/register",
        code: 10303
      }
    else
      user = User.create(user_params)
      device = Device.find_by(params[:device])
      device.user = user
      device.save!
      session[:auth] = user.id

      render :json => {
        msg: "register success",
        request: "POST/auths/register",
        code: 10000,
        token: user.auth_token
      }
    end
      
  end

  def check_device
    if !Device.exist?(params[:device])
      render :json => {
        msg: "device code error",
        request: "POST/auths/check_device",
        code: 10401
      }   
    else
      render :json => {
        msg: "device ok",
        request: "POST/auths/check_device",
        code: 10000
      }  
    end

  end

  def login
    if !User.auth?(params[:mobile], params[:password])
      render :json => {
        msg: "login code error",
        request: "POST/auths/login",
        code: 10501
      }
    else
      user = User.find_by(mobile: mobile)
      user.regenerate_auth_token
      session[:auth] = user.id

      render :json => {
        msg: "login ok",
        request: "POST/auths/login",
        code: 10000,
        token: user.auth_token
      }
    end
  end

  def reset_password
    if !User.registered?(params[:mobile])
      render :json => {
        msg: "reset password code error",
        request: "POST/auth/reset_password",
        code: 10601
      }
    elsif params[:captcha] != session[:captcha]
      render :json => {
        msg: "reset password code error",
        request: "POST/auth/reset_password",
        code: 10602
      }
    elsif !User.password_format_valid?(params[:password])
      render :json => {
        msg: "reset password code error",
        request: "POST/auth/reset_password",
        code: 10603
      }
    else 
      user = User.update(user_params)
      render :json => {
        msg: "reset password ok",
        request: "POST/auth/reset_password",
        code: 10000
      }
    end

  end

  def is_registered
    if User.registered?(params[:mobile])
      render :json => {
        msg: "user is already registered",
        request: "GET/auth/is_registered",
        code: 10701
      }
    else
      render :json => {
        msg: "user is not registered",
        request: "GET/auth/is_registered",
        code: 10000
      }
    end
  end

  private
    def user_params
      params.permit(:mobile, :password)
    end

end
